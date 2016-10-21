defmodule Extractor.SnapExtractor do

  def extract do
    extractor = SnapshotExtractor.fetch_details
    schedule = extractor.schedule
    interval = extractor.interval |> intervaling
    camera_exid = extractor.camera_exid

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

    case SnapshotExtractor.update_extractor_status(%{status: 1}) do
      {:ok, extractor} ->
        Extractor.ExtractMailer.extractor_started
        Dropbox.mkdir! %Dropbox.Client{access_token: System.get_env["DROP_BOX_TOKEN"]}, "secrets/#{camera_exid}"
      _ ->
        IO.inspect "Status update failed!"
    end

    1..total_days |> Enum.reduce(start_date, fn _i, acc ->
      day_of_week = acc |> Calendar.Date.day_of_week_name
      rec_head = get_head_tail(schedule[day_of_week])
      rec_head |> Enum.each(fn(x) ->
        iterate(x, acc, timezone) |> download(camera_exid, interval)
      end)
      acc |> Calendar.DateTime.to_erl |> Calendar.DateTime.from_erl!(timezone, {123456, 6}) |> Calendar.DateTime.add!(86400)
    end)

    case SnapshotExtractor.update_extractor_status(%{status: 2}) do
      {:ok, _} -> Extractor.ExtractMailer.extractor_completed
      _ -> IO.inspect "Status update failed!"
    end
  end

  defp get_head_tail([]), do: []
  defp get_head_tail([head|tail]) do
    [[head]|get_head_tail(tail)]
  end

  def download([], _camera_exid, _interval), do: IO.inspect "I am empty!"
  def download([starting, ending], camera_exid, interval) do
    do_loop(starting, ending, interval, camera_exid)
  end

  defp do_loop(starting, ending, interval, _camera_exid) when starting >= ending, do: IO.inspect "We are finished!"
  defp do_loop(starting, ending, interval, camera_exid) do
    url = "#{System.get_env["EVERCAM_URL"]}/#{camera_exid}/recordings/snapshots/#{starting}?with_data=true&range=2&api_id=#{System.get_env["USER_ID"]}&api_key=#{System.get_env["USER_KEY"]}&notes=Evercam+Proxy"
    case HTTPoison.get!(url, [], []) do
      %HTTPoison.Error{reason: reason} ->
        IO.inspect "Media: #{reason}!"
        :timer.sleep(:timer.seconds(3))
        do_loop(starting + interval, ending, interval, camera_exid)
      response ->
        upload(response.status_code, response.body, starting, camera_exid)
        do_loop(starting + interval, ending, interval, camera_exid)
    end
  end

  def upload(200, response, starting, camera_exid) do
    image = response |> Poison.decode! |> Map.get("snapshots") |> List.first
    data = decode_image(image["data"])
    IO.inspect data
    File.write("image.jpg", data, [:binary])
    IO.inspect "writing"
    case Dropbox.upload_file! %Dropbox.Client{access_token: System.get_env["DROP_BOX_TOKEN"]}, "image.jpg", "secrets/#{camera_exid}/#{starting}.jpg" do
      {:skipping, reason} ->
        IO.inspect reason
        :timer.sleep(:timer.seconds(3))
      _ ->
        IO.inspect "written"
    end
  end
  def upload(_, _response, _starting, _camera_exid), do: IO.inspect "Not an Image!"

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
end