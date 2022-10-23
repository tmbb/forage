# This file is responsible for configuring your application
import Config

if Mix.env() == :test do
  config :phoenix, :json_library, Jason

  config :forage, Forage.Test.Support.Repo,
    database: Path.expand("../test/databases/repo1.db", Path.dirname(__ENV__.file)),
    pool_size: 5,
    pool: Ecto.Adapters.SQL.Sandbox
end
