defmodule Extractor.StartExtractor do

  def start do
    current_status = SnapshotExtractor.if_its_running

    run_or_not(current_status)
  end

  def run_or_not(nil) do
    extractor = SnapshotExtractor.fetch_details

    IO.inspect "Starting Job"
    Extractor.SnapExtractor.extract(extractor)
  end
  def run_or_not(_), do: IO.inspect "Job is already running"
end