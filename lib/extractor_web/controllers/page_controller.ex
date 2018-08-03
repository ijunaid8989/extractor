defmodule ExtractorWeb.PageController do
  use ExtractorWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
