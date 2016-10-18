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

  def fetch_schedule do
    SnapshotExtractor
    |> order_by(desc: :created_at)
    |> limit(1)
    |> Repo.one
  end

end