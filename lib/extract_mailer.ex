defmodule Extractor.ExtractMailer do

  @config Application.get_env(:extractor, :mailgun)
  @from Application.get_env(:extractor, EvercamMedia.Endpoint)[:email]
  @year Calendar.DateTime.now_utc |> Calendar.Strftime.strftime!("%Y")

  def extractor_started do
    Mailgun.Client.send_email @config,
      to: "abc@bcd.com",
      subject: "SnapShot Extraction Started",
      from: @from,
      html: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_started.html", user: user, code: code, year: @year),
      text: Phoenix.View.render_to_string(Extractor.EmailView, "extractor_started.txt", user: user, code: code)
  end
end