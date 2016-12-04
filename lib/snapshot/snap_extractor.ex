defmodule Extractor.SnapExtractor do

  def extract(nil), do: IO.inspect "No extrator with status 0"
  def extract(extractor) do
    schedule = extractor.schedule
    interval = extractor.interval |> intervaling
    camera_exid = extractor.camera_exid
    {:ok, agent} = Agent.start_link fn -> [] end
    {:ok, t_agent} = Agent.start_link fn -> [] end

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

    total_days = find_difference(end_date, start_date) / 86400 |> round |> round_2

    case SnapshotExtractor.update_extractor_status(extractor.id, %{status: 1}) do
      {:ok, _extractor} ->
        send_mail_start(Application.get_env(:extractor, :send_emails_for_extractor))
        Dropbox.mkdir! %Dropbox.Client{access_token: System.get_env["DROP_BOX_TOKEN"]}, "Construction/#{camera_exid}/#{extractor.id}"
      _ ->
        IO.inspect "Status update failed!"
    end

    1..total_days |> Enum.reduce(start_date, fn _i, acc ->
      day_of_week = acc |> Calendar.Date.day_of_week_name
      rec_head = get_head_tail(schedule[day_of_week])
      rec_head |> Enum.each(fn(x) ->
        iterate(x, acc, timezone) |> t_download(interval, t_agent)
      end)
      acc |> Calendar.DateTime.to_erl |> Calendar.DateTime.from_erl!(timezone, {123456, 6}) |> Calendar.DateTime.add!(86400)
    end)

    1..total_days |> Enum.reduce(start_date, fn _i, acc ->
      url_day = "#{System.get_env["FILER"]}/#{camera_exid}/snapshots/recordings/"
      with :ok <- ensure_a_day(acc, url_day)
      do
        day_of_week = acc |> Calendar.Date.day_of_week_name
        rec_head = get_head_tail(schedule[day_of_week])
        rec_head |> Enum.each(fn(x) ->
          iterate(x, acc, timezone) |> download(camera_exid, interval, extractor.id, agent)
        end)
        acc |> Calendar.DateTime.to_erl |> Calendar.DateTime.from_erl!(timezone, {123456, 6}) |> Calendar.DateTime.add!(86400)
      else
        :not_ok ->
          acc |> Calendar.DateTime.to_erl |> Calendar.DateTime.from_erl!(timezone, {123456, 6}) |> Calendar.DateTime.add!(86400)
      end
    end)

    count =
      Agent.get(agent, fn list -> list end)
      |> Enum.filter(fn(item) -> item end)
      |> Enum.count

    expected_count =
      Agent.get(t_agent, fn list -> list end)
      |> Enum.filter(fn(item) -> item end)
      |> Enum.count

    case SnapshotExtractor.update_extractor_status(extractor.id, %{status: 2, notes: "total images = #{count}"}) do
      {:ok, _} ->
        instruction = %{
          from_date: start_date |> Calendar.Strftime.strftime!("%A, %b %d %Y, %H:%M"),
          to_date: end_date |> Calendar.Strftime.strftime!("%A, %b %d %Y, %H:%M"),
          schedule: schedule,
          frequency: interval |> humanize_interval
        }
        File.write("instruction.json", Poison.encode!(instruction), [:binary])
        Dropbox.upload_file! %Dropbox.Client{access_token: System.get_env["DROP_BOX_TOKEN"]}, "instruction.json", "Construction/#{camera_exid}/#{extractor.id}/instruction.json"
        IO.inspect "instruction written"
        send_mail_end(Application.get_env(:extractor, :send_emails_for_extractor), count, extractor.camera_name, expected_count)
      _ -> IO.inspect "Status update failed!"
    end
  end

  defp get_head_tail([]), do: []
  defp get_head_tail([head|tail]) do
    [[head]|get_head_tail(tail)]
  end

  def t_download([], _interval, _t_agent), do: IO.inspect "I am empty!"
  def t_download([starting, ending], interval, t_agent) do
    t_do_loop(starting, ending, interval, t_agent)
  end

  defp t_do_loop(starting, ending, _interval, _t_agent) when starting >= ending, do: IO.inspect "We are finished!"
  defp t_do_loop(starting, ending, interval, t_agent) do
    Agent.update(t_agent, fn list -> ["true" | list] end)
    t_do_loop(starting + interval, ending, interval, t_agent)
  end

  def download([], _camera_exid, _interval, _id, _agent), do: IO.inspect "I am empty!"
  def download([starting, ending], camera_exid, interval, id, agent) do
    do_loop(starting, ending, interval, camera_exid, id, agent)
  end

  defp do_loop(starting, ending, _interval, _camera_exid, _id, _agent) when starting >= ending, do: IO.inspect "We are finished!"
  defp do_loop(starting, ending, interval, camera_exid, id, agent) do
    %{year: s_year, month: s_month, day: s_day, hour: s_hour, min: _s_min, sec: _s_sec} = make_me_complete(starting)
    %{year: _e_year, month: _e_month, day: _e_day, hour: e_hour, min: _e_min, sec: _e_sec} = make_me_complete(ending)
    url = "#{System.get_env["FILER"]}/#{camera_exid}/snapshots/recordings/#{s_year}/#{s_month}/#{s_day}/"
    all_hour =
      request_from_seaweedfs(url, "Subdirectories", "Name")
      |> Enum.uniq
      |> Enum.sort
      |> Enum.map(fn(h) ->
        Integer.parse(h) |> elem(0)
      end)
    {starting_hour, ""} = Integer.parse(s_hour)
    {ending_hour, ""} = Integer.parse(e_hour)
    valid_hours = Enum.filter(all_hour, fn(x) -> x >= starting_hour && x <= ending_hour end)
    Enum.each(valid_hours, fn(hour) ->
      url_for_hour = url <> "#{String.rjust("#{hour}", 2, ?0)}/?limit=3600"
      all_files = request_from_seaweedfs(url_for_hour, "Files", "name") |> Enum.uniq |> Enum.sort |> Enum.take_every(interval)
      Enum.each(all_files, fn(file) ->
        url_for_file = url <> "#{String.rjust("#{hour}", 2, ?0)}/" <> "#{file}"
        IO.inspect url_for_file
        case HTTPoison.get(url_for_file, [], []) do
          {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
            upload(200, body, starting, camera_exid, id, agent)
            IO.inspect "Going for NEXT!"
          {:ok, %HTTPoison.Response{body: "", status_code: 404}} ->
            IO.inspect "Not An Image!"
          {:error, %HTTPoison.Error{reason: reason}} ->
            IO.inspect "Weed: #{reason}!"
            :timer.sleep(:timer.seconds(3))
        end
      end)
    end)
  end

  def upload(200, response, starting, camera_exid, id, agent) do
    IO.inspect response
    imagef = File.write("image.jpg", response, [:binary])
    IO.inspect "writing"
    File.close imagef
    case Dropbox.upload_file! %Dropbox.Client{access_token: System.get_env["DROP_BOX_TOKEN"]}, "image.jpg", "Construction/#{camera_exid}/#{id}/#{starting}.jpg" do
      {:skipping, reason} ->
        IO.inspect reason
        :timer.sleep(:timer.seconds(3))
        upload(200, response, starting, camera_exid, id, agent)
      _ ->
        Agent.update(agent, fn list -> ["true" | list] end)
        IO.inspect "written"
    end
  end
  def upload(_, response, _starting, _camera_exid, _id, _agent), do: IO.inspect "Not an Image! #{response}"

  defp decode_image("data:image/jpeg;base64," <> encoded_image) do
    Base.decode64!(encoded_image)
  end

  defp find_difference(end_date, start_date) do
    case Calendar.DateTime.diff(end_date, start_date) do
      {:ok, seconds, _, :after} -> seconds
      _ -> 1
    end
  end

  def iterate([], _check_time, _timezone), do: []
  def iterate([head], check_time, timezone) do
    [from, to] = String.split head, "-"
    [from_hour, from_minute] = String.split from, ":"
    [to_hour, to_minute] = String.split to, ":"

    from_unix_timestamp = unix_timestamp(from_hour, from_minute, check_time, timezone)
    to_unix_timestamp = unix_timestamp(to_hour, to_minute, check_time, timezone)
    [from_unix_timestamp, to_unix_timestamp]
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

  defp round_2(0), do: 2
  defp round_2(n), do: n + 1

  defp intervaling(0), do: 1
  defp intervaling(n), do: n

  defp send_mail_start(false), do: IO.inspect "We are in Development Mode!"
  defp send_mail_start(true), do: Extractor.ExtractMailer.extractor_started

  defp send_mail_end(false, _count, _camera_name, _expected_count), do: IO.inspect "We are in Development Mode!"
  defp send_mail_end(true, count, camera_name, expected_count), do: Extractor.ExtractMailer.extractor_completed(count, camera_name, expected_count)

  defp make_me_complete(date) do
    %{year: year, month: month, day: day, hour: hour, min: min, sec: sec} = Calendar.DateTime.Parse.unix! date
    month = String.rjust("#{month}", 2, ?0)
    day = String.rjust("#{day}", 2, ?0)
    hour = String.rjust("#{hour}", 2, ?0)
    min = String.rjust("#{min}", 2, ?0)
    sec = String.rjust("#{sec}", 2, ?0)
    %{year: year, month: month, day: day, hour: hour, min: min, sec: sec}
  end

  defp humanize_interval(60), do: "1 Frame Every 1 min"
  defp humanize_interval(300), do: "1 Frame Every 5 min"
  defp humanize_interval(600), do: "1 Frame Every 10 min"
  defp humanize_interval(1200), do: "1 Frame Every 20 min"
  defp humanize_interval(1800), do: "1 Frame Every 30 min"
  defp humanize_interval(3600), do: "1 Frame Every hour"
  defp humanize_interval(7200), do: "1 Frame Every 2 hour"
  defp humanize_interval(21600), do: "1 Frame Every 6 hour"
  defp humanize_interval(43200), do: "1 Frame Every 12 hour"
  defp humanize_interval(86400), do: "1 Frame Every 24 hour"
  defp humanize_interval(1), do: "All"

  defp request_from_seaweedfs(url, type, attribute) do
    with {:ok, response} <- HTTPoison.get(url, [], []),
         %HTTPoison.Response{status_code: 200, body: body} <- response,
         {:ok, data} <- Poison.decode(body),
         true <- is_list(data[type]) do
      Enum.map(data[type], fn(item) -> item[attribute] end)
    else
      _ -> []
    end
  end

  defp ensure_a_day(date, url) do
    day = Calendar.Strftime.strftime!(date, "%Y/%m/%d/")
    url_day = url <> "#{day}"
    case request_from_seaweedfs(url_day, "Subdirectories", "Name") |> Enum.empty? do
      true -> :not_ok
      false -> :ok
    end
  end
end