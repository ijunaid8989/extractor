defmodule Extractor.SnapExtractor do
  def fetch_dates_unix do
    extractor = SnapshotExtractor.fetch_details
    schedule = extractor.schedule

    timezone =
      case extractor.timezone do
        nil -> "Etc/UTC"
        _ -> extractor.timezone
      end

    start_date =
      extractor.from_date
      |> Ecto.DateTime.to_erl
      |> Calendar.DateTime.from_erl!(timezone)

    end_date =
      extractor.to_date
      |> Ecto.DateTime.to_erl
      |> Calendar.DateTime.from_erl!(timezone)

    total_days = find_difference(end_date, start_date)
    # all_valid_dates_in_range(start_date, end_date) |> Enum.each(fn(date) ->
    #   check_day = date |> Calendar.Date.day_of_week_name
    #   IO.inspect iterate(schedule[check_day], date, timezone)
    #   end)
  end

  defp find_difference(end_date, start_date) do
    
  end

  defp iterate([head|tail], check_time, timezone) do
    head_pattern = ~r/^\d{1,2}:\d{1,2}-\d{1,2}:\d{1,2}$/
    case Regex.match? head_pattern, head do
      true ->
        [from, to] = String.split head, "-"
        [from_hour, from_minute] = String.split from, ":"
        [to_hour, to_minute] = String.split to, ":"

        check_time_unix_timestamp = check_time |> Calendar.DateTime.Format.unix
        from_unix_timestamp = unix_timestamp(from_hour, from_minute, check_time, timezone)
        to_unix_timestamp = unix_timestamp(to_hour, to_minute, check_time, timezone)
        %{
          from_unix_timestamp: from_unix_timestamp,
          to_unix_timestamp: to_unix_timestamp
        }
      _ ->
        {:error, "Scheduler got an invalid time format: #{inspect(head)}. Expecting Time in the format HH:MM-HH:MM"}
    end
  end

  defp unix_timestamp(hours, minutes, date, nil) do
    unix_timestamp(hours, minutes, date, "UTC")
  end
  defp unix_timestamp(hours, minutes, date, timezone) do
    %{year: year, month: month, day: day} = date
    {h, _} = Integer.parse(hours)
    {m, _} = Integer.parse(minutes)
    erl_date_time = {{year, month, day}, {h, m, 0}}
    case Calendar.DateTime.from_erl(erl_date_time, timezone) do
      {:ok, datetime} -> datetime |> Calendar.DateTime.Format.unix
      {:ambiguous, datetime} -> datetime.possible_date_times |> hd |> Calendar.DateTime.Format.unix
      _ -> raise "Timezone conversion error"
    end
  end
end