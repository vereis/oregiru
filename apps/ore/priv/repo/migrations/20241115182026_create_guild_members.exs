defmodule Ore.Repo.Migrations.CreateGuildMembers do
  use Ecto.Migration

  def change do
    create table(:guild_members) do
      add :guild_id, references(:guilds, on_delete: :delete_all), null: false

      add :given_name, :string, null: false
      add :family_name, :string, null: false
      add :level, :integer, null: false, default: 1
      add :gender, :string, null: true
    end

    create index(:guild_members, [:guild_id])
  end
end
