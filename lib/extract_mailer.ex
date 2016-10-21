defmodule Extractor.ExtractMailer do

  @config Application.get_env(:extractor, :mailgun)
  @from Application.get_env(:extractor, EvercamMedia.Endpoint)[:email]
  @year Calendar.DateTime.now_utc |> Calendar.Strftime.strftime!("%Y")

  def extractor_started do
    Mailgun.Client.send_email @config,
      to: "junaid@evercam.io",
      subject: "SnapShot Extraction Started",
      from: @from,
      html: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_started.html", year: @year),
      text: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_started.txt", year: @year)
  end

  def extractor_completed do
    Mailgun.Client.send_email @config,
      to: "junaid@evercam.io",
      subject: "SnapShot Extraction Completed",
      from: @from,
      html: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_completed.html", year: @year),
      text: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_completed.txt", year: @year)
  end
end