defmodule Extractor.ExtractMailer do

  @config Application.get_env(:extractor, :mailgun)
  @from "support@evercam.io"
  @year Calendar.DateTime.now_utc |> Calendar.Strftime.strftime!("%Y")

  def extractor_started do
    Mailgun.Client.send_email @config,
      to: "junaid@evercam.io",
      subject: "SnapShot Extraction Started",
      from: @from,
      bcc: "marco@evercam.io,info@lensmen.ie",
      html: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_started.html", year: @year),
      text: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_started.txt", year: @year)
  end

  def extractor_completed(count, camera_name) do
    Mailgun.Client.send_email @config,
      to: "junaid@evercam.io",
      subject: "SnapShot Extraction Completed",
      from: @from,
      bcc: "marco@evercam.io,info@lensmen.ie",
      html: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_completed.html", count: count, camera_name: camera_name),
      text: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_completed.txt", count: count, camera_name: camera_name)
  end
end