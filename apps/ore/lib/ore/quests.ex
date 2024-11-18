defmodule Ore.Quests do
  @moduledoc "Context module for managing quests."

  alias Ore.Guilds.Guild
  alias Ore.Guilds.Member
  alias Ore.Quests.Quest
  alias Ore.Repo

  @doc "Creates a new quest."
  @spec create_quest(Guild.t(), map()) :: {:ok, Quest.t()} | {:error, Ecto.Changeset.t()}
  def create_quest(%Guild{} = guild, attrs) do
    %Quest{guild_id: guild.id}
    |> Quest.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a quest."
  @spec update_quest(Quest.t(), map()) :: {:ok, Quest.t()} | {:error, Ecto.Changeset.t()}
  def update_quest(%Quest{} = quest, attrs) do
    quest
    |> Quest.changeset(attrs)
    |> Repo.update()
  end

  @doc "Gets a quest by ID w/ optional filters."
  @spec get_quest(id :: integer(), Keyword.t()) :: Quest.t() | nil
  def get_quest(id, filters \\ []) do
    filters |> Keyword.put(:id, id) |> Quest.query() |> Repo.one()
  end

  @doc "Gets all quests w/ optional filters."
  @spec list_quests(Guild.t() | Keyword.t()) :: [Quest.t()]
  @spec list_quests(Guild.t(), Keyword.t()) :: [Quest.t()]
  def list_quests(%Guild{} = guild) do
    list_quests(guild_id: guild.id)
  end

  def list_quests(filters) do
    filters |> Quest.query() |> Repo.all()
  end

  def list_quests(%Guild{} = guild, filters) do
    filters |> Keyword.put(:guild_id, guild.id) |> list_quests()
  end

  @doc "Enrolls the member or members in the given quest."
  @spec enroll_quest(Quest.t(), Member.t()) :: {:ok, Quest.t()} | {:error, term()}
  @spec enroll_quest(Quest.t(), [Member.t()]) :: {:ok, Quest.t()} | {:error, term()}
  def enroll_quest(%Quest{} = quest, _members) when quest.state in [:proposed, :active, :completed, :failed] do
    {:error, {:invalid_state, quest.state}}
  end

  def enroll_quest(%Quest{} = quest, %Member{} = member) do
    enroll_quest(quest, [member])
  end

  def enroll_quest(%Quest{} = quest, []) do
    {:ok, quest}
  end

  def enroll_quest(%Quest{} = quest, members) do
    level_range = (quest.min_level || 0)..(quest.max_level || 999)
    ineligible_members = Enum.reject(members, &(&1.level in level_range))

    if ineligible_members == [] do
      update_quest(quest, %{member_ids: Enum.map(members, & &1.id), state: :active})
    else
      {:error, {:level_range_mismatch, ineligible_members: ineligible_members, range: level_range}}
    end
  end

  @doc "Transitions the quest to the given state if possible."
  @spec transition_quest(Quest.t(), state :: atom()) ::
          {:ok, Quest.t()} | {:error, Ecto.Changeset.t()}
  def transition_quest(%Quest{} = quest, state) do
    update_quest(quest, %{state: state})
  end
end
