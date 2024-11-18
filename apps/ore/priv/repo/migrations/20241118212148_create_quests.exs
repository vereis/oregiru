defmodule Ore.Repo.Migrations.CreateQuests do
  use Ecto.Migration

  def change do
    create table(:quests) do
      add(:guild_id, references(:guilds, on_delete: :delete_all), null: false)
      add(:name, :string, null: false)
      add(:state, :string, null: false)
      add(:min_level, :integer, default: 0)
      add(:max_level, :integer, default: 999)
    end

    create table(:guild_members_quests) do
      add(:quest_id, references(:quests, on_delete: :delete_all), null: false)
      add(:member_id, references(:guild_members, on_delete: :delete_all), null: false)
    end

    create(index(:quests, [:guild_id, :state]))
  end
end
