defmodule Ore.Repo.Migrations.CreateGuildLeaders do
  use Ecto.Migration

  def change do
    create table(:guild_leaders) do
      add(:guild_id, references(:guilds, on_delete: :delete_all), null: false)
      add(:member_id, references(:guild_members, on_delete: :delete_all), null: false)
      add(:email, :string, null: false)
      add(:password_hash, :string, null: false)
    end

    create(unique_index(:guild_leaders, [:email]))
    create(index(:guild_leaders, [:guild_id]))
  end
end
