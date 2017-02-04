defmodule Extractor.ExtractMailer do

  @config Application.get_env(:extractor, :mailgun)
  @from "support@evercam.io"
  @year Calendar.DateTime.now_utc |> Calendar.Strftime.strftime!("%Y")

  def extractor_started(e_start_date, e_to_date, e_schedule, e_interval, camera_name, requestor) do
    Mailgun.Client.send_email @config,
      to: "junaid@evercam.io",
      subject: "SnapShot Extraction Started",
      from: @from,
      bcc: "marco@evercam.io,#{requestor}",
      html: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_started.html", start_date: e_start_date, to_date: e_to_date, interval: e_interval, schedule: e_schedule, camera_name: camera_name, requestor: requestor),
      text: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_started.txt", start_date: e_start_date, to_date: e_to_date, interval: e_interval, schedule: e_schedule, camera_name: camera_name, requestor: requestor)
  end

  def extractor_completed(count, camera_name, expected_count, extractor_id, camera_exid, requestor, execution_time) do
    Mailgun.Client.send_email @config,
      to: "junaid@evercam.io",
      subject: "SnapShot Extraction Completed",
      from: @from,
      bcc: "marco@evercam.io,#{requestor}",
      html: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_completed.html", count: count, camera_name: camera_name, expected_count: expected_count, extractor_id: extractor_id, camera_exid: camera_exid, execution_time: execution_time),
      text: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_completed.txt", count: count, camera_name: camera_name, expected_count: expected_count, extractor_id: extractor_id, camera_exid: camera_exid, execution_time: execution_time)
  end
end