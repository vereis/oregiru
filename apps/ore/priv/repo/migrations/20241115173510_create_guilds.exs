defmodule Ore.Repo.Migrations.CreateGuilds do
  use Ecto.Migration

  def change do
    create table(:guilds) do
      add :name, :string, null: false
      add :slogan, :string, null: false, default: ""
      add :level, :integer, null: false, default: 0
    end
  end
end
