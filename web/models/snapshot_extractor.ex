defmodule SnapshotExtractor do
  use Extractor.Web, :model
  import Ecto.Changeset
  import Ecto.Query
  alias Extractor.Repo

  @required_fields ~w(status)
  @optional_fields ~w(notes)

  schema "snapshot_extractors" do
    field :camera_id, :integer
    field :from_date, Ecto.DateTime, default: Ecto.DateTime.utc
    field :to_date, Ecto.DateTime, default: Ecto.DateTime.utc
    field :interval, :integer
    field :schedule, Extractor.Types.JSON
    field :status, :integer
    field :notes, :string
    field :create_mp4, :boolean
    field :jpegs_to_dropbox, :boolean
    field :inject_to_cr, :boolean
    field :requestor, :string
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
    |> where(status: 0)
    |> join(:inner_lateral, [se], cam in fragment("SELECT * FROM cameras as cam WHERE cam.id = ?", se.camera_id))
    |> select([se, cam], %{ id: se.id, from_date: se.from_date, to_date: se.to_date, interval: se.interval, schedule: se.schedule, camera_exid: cam.exid, timezone: cam.timezone, camera_name: cam.name, requestor: se.requestor, create_mp4: se.create_mp4, jpegs_to_dropbox: se.jpegs_to_dropbox})
    |> Repo.one
  end

  def update_extractor_status(extractor_id, params) do
    SnapshotExtractor
    |> where(id: ^extractor_id)
    |> Repo.one
    |> changeset(params)
    |> Repo.update
  end

  def if_its_running do
    SnapshotExtractor
    |> limit(1)
    |> where(status: 1)
    |> Repo.one
  end

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end