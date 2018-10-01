defmodule Extractor.ExtractMailer do

  use Phoenix.Swoosh, view: ExtractorWeb.EmailView
  @from "support@evercam.io"
  @year Calendar.DateTime.now_utc |> Calendar.Strftime.strftime!("%Y")

  def extractor_started(e_start_date, e_to_date, e_schedule, e_interval, camera_name, requestor) do
    new()
    |> from(@from)
    |> to("junaid@evercam.io")
    |> bcc(["marco@evercam.io, #{requestor}"])
    |> subject("SnapShot Extraction Started")
    |> render_body("extractor_started.html", %{start_date: e_start_date, to_date: e_to_date, interval: e_interval, schedule: e_schedule, camera_name: camera_name, requestor: requestor})
    |> Extractor.Mailer.deliver
  end

  def extractor_completed(count, camera_name, expected_count, extractor_id, camera_exid, requestor, execution_time) do
    new()
    |> from(@from)
    |> to("junaid@evercam.io")
    |> bcc(["marco@evercam.io, #{requestor}"])
    |> subject("SnapShot Extraction Completed")
    |> render_body("extractor_completed.html", %{count: count, camera_name: camera_name, expected_count: expected_count, extractor_id: extractor_id, camera_exid: camera_exid, execution_time: execution_time, requestor: requestor})
    |> Extractor.Mailer.deliver
  end
end