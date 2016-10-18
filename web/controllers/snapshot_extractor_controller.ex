defmodule Extractor.SnapshotExtractorController do
  use Extractor.Web, :controller

  def index(conn, _params) do
    snapshot_extractors = SnapshotExtractor.all_extractors
    render conn, "extractor.html", snapshot_extractors: snapshot_extractors
  end
end