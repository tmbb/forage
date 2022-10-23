defmodule Forage.Test.Support.Repo1 do
  use Ecto.Repo,
    otp_app: :forage,
    adapter: Ecto.Adapters.SQLite3

  use Paginator, page_size: 20
end
