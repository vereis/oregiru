defmodule Ore.Repo do
  use Ecto.Repo,
    otp_app: :ore,
    adapter: Ecto.Adapters.SQLite3
end
