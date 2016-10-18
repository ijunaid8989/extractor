defmodule Extractor.PageController do
  use Extractor.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
