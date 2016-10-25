defmodule Extractor.SnapshotExtractorController do
  use Extractor.Web, :controller

  def index(conn, _params) do
    render conn, "extractor.html"
  end
end