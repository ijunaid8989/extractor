defmodule SnapshotExtractor do
  use Extractor.Web, :model
  import Ecto.Changeset
  import Ecto.Query
  alias Extractor.Repo

  schema "snapshot_extractors" do
    field :camera_id, :integer
    field :from_date, Ecto.DateTime, default: Ecto.DateTime.utc
    field :to_date, Ecto.DateTime, default: Ecto.DateTime.utc
    field :interval, :integer
    field :schedule, Extractor.Types.JSON
    field :status, :integer
    field :notes, :string
    timestamps(inserted_at: :created_at, type: Ecto.DateTime, default: Ecto.DateTime.utc)
  end

  def all_extractors do
    SnapshotExtractor
    |> Repo.all
  end

  def fetch_details do
    SnapshotExtractor
    |> order_by(desc: :created_at)
    |> limit(1)
    |> join(:inner_lateral, [se], cam in fragment("SELECT * FROM cameras as cam WHERE cam.id = ?", se.camera_id))
    |> select([se, cam], %{ from_date: se.from_date, to_date: se.to_date, interval: se.interval, schedule: se.schedule, camera_exid: cam.exid, timezone: cam.timezone})
    |> Repo.one
  end
end