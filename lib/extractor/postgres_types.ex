Postgrex.Types.define(Extractor.PostgresTypes,
                    [
                      {Geo.PostGIS.Extension, library: Geo}
                    ] ++ Ecto.Adapters.Postgres.extensions(),
                    json: Poison)
