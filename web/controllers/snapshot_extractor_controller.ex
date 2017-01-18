defmodule Extractor.SnapshotExtractorController do
  use Extractor.Web, :controller

  def index(conn, _params) do
    render conn, "extractor.html"
  end

  def newest(conn, %{"camera_exid" => camera_exid} = params) do
    url = "#{System.get_env["FILER"]}/#{camera_exid}/snapshots/recordings/"
    with {:year, year} <- newest_year(url),
         {:month, month} <- newest_month(url <> "#{year}/"),
         {:day, day} <- newest_day(url <> "#{year}/" <> "#{month}/"),
         {:hour, hour} <- newest_hour(url <> "#{year}/" <> "#{month}/" <> "#{day}/"),
         {:image, latest_image} <- newest_image(url <> "#{year}/" <> "#{month}/" <> "#{day}/" <> "#{hour}/?limit=3600") do
      json(conn, %{message: url <> "#{year}/" <> "#{month}/" <> "#{day}/" <> "#{hour}/" <> "#{latest_image}"})
    else
      _ -> []
    end
  end

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

  defp newest_year(year_url) do
    IO.inspect year_url
    {:year, request_from_seaweedfs(year_url, "Subdirectories", "Name") |> Enum.sort(&(&1 > &2)) |> List.first}
  end

  defp newest_month(month_url) do
    IO.inspect month_url
    {:month, request_from_seaweedfs(month_url, "Subdirectories", "Name") |> Enum.sort(&(&1 > &2)) |> List.first}
  end

  defp newest_day(day_url) do
    IO.inspect day_url
    {:day, request_from_seaweedfs(day_url, "Subdirectories", "Name") |> Enum.sort(&(&1 > &2)) |> List.first}
  end

  defp newest_hour(hour_url) do
    IO.inspect hour_url
    {:hour, request_from_seaweedfs(hour_url, "Subdirectories", "Name") |> Enum.sort(&(&1 > &2)) |> List.first}
  end

  defp newest_image(image_url) do
    IO.inspect image_url
    {:image, request_from_seaweedfs(image_url, "Files", "name") |> Enum.sort(&(&1 > &2)) |> List.first}
  end
end