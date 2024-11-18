defmodule Ore.Quests.Quest do
  @moduledoc false
  use Ore.Schema

  alias Ore.Guilds.Guild
  alias Ore.Guilds.Member

  @default_state :proposed
  @state_transitions %{
    proposed: [:pending],
    pending: [:active, :failed],
    active: [:completed, :failed],
    completed: [],
    failed: []
  }

  schema "quests" do
    field(:name, :string)
    field(:state, Ecto.Enum, values: Map.keys(@state_transitions), default: @default_state)

    field(:min_level, :integer, default: 0)
    field(:max_level, :integer, default: 999)

    belongs_to(:guild, Guild)
    many_to_many(:members, Member, join_through: "guild_members_quests")
  end

  def changeset(%Quest{} = quest, attrs) do
    quest
    |> cast(attrs, [:guild_id, :name, :state, :min_level, :max_level])
    |> validate_required([:guild_id, :name, :state])
    |> validate_state_transition()
    |> preload_put_assoc(attrs, :members, :member_ids, guild_id: quest.guild_id)
  end

  @doc false
  def state_transitions do
    @state_transitions
  end

  defp validate_state_transition(changeset) do
    validate_change(changeset, :state, fn :state, new_state ->
      old_state = Map.get(changeset.data, :state, @default_state)

      if new_state in @state_transitions[old_state] do
        []
      else
        [
          state:
            {"invalid state transition",
             [
               new_state: new_state,
               old_state: old_state,
               valid_states: @state_transitions[old_state]
             ]}
        ]
      end
    end)
  end
end
