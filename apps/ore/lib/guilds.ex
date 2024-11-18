defmodule Ore.Guilds do
  @moduledoc "Module for managing all things related to guilds."

  alias Ore.Guilds.Guild
  alias Ore.Guilds.Member
  alias Ore.Guilds.Leader
  alias Ore.Repo

  @doc "Creates a new guild."
  @spec create_guild(attrs :: map()) :: {:ok, Guild.t()} | {:error, Ecto.Changeset.t()}
  def create_guild(attrs) do
    %Guild{} |> Guild.changeset(attrs) |> Repo.insert()
  end

  @doc "Updates a guild with the given attrs."
  @spec update_guild(Guild.t(), attrs :: map()) :: {:ok, Guild.t()} | {:error, Ecto.Changeset.t()}
  def update_guild(%Guild{} = guild, attrs) do
    guild |> Guild.changeset(attrs) |> Repo.update()
  end

  @doc "Gets a guild by its id w/ optional filters."
  @spec get_guild(id :: integer(), filters :: Keyword.t()) :: Guild.t() | nil
  def get_guild(id, filters \\ []) do
    filters |> Keyword.put(:id, id) |> Guild.query() |> Repo.one()
  end

  @doc "Gets all guilds matching the given filters."
  @spec list_guilds(filters :: Keyword.t()) :: [Guild.t()]
  def list_guilds(filters \\ []) do
    filters |> Guild.query() |> Repo.all()
  end

  @doc "Creates a new guild member."
  @spec create_member(guild :: Guild.t(), attrs :: map()) ::
          {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def create_member(%Guild{} = guild, attrs) do
    %Member{guild_id: guild.id} |> Member.changeset(attrs) |> Repo.insert()
  end

  @doc "Updates a guild member with the given attrs."
  @spec update_member(member :: Member.t(), attrs :: map()) ::
          {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def update_member(%Member{} = member, attrs) do
    member |> Member.changeset(attrs) |> Repo.update()
  end

  @doc "Gets a guild member by their id w/ optional filters."
  @spec get_member(id :: integer(), filters :: Keyword.t()) :: Member.t() | nil
  def get_member(id, filters \\ []) do
    filters |> Keyword.put(:id, id) |> Member.query() |> Repo.one()
  end

  @doc "Gets all guild members matching the given filters."
  @spec list_members(filters :: Keyword.t()) :: [Member.t()]
  def list_members(%Guild{} = guild) do
    list_members(guild_id: guild.id)
  end

  def list_members(filters) do
    filters |> Member.query() |> Repo.all()
  end

  @doc "Gets all guild members for the given guild plus matching the given filters."
  @spec list_members(Guild.t(), filters :: Keyword.t()) :: [Member.t()]
  def list_members(%Guild{} = guild, filters) do
    filters |> Keyword.put(:guild_id, guild.id) |> list_members()
  end

  @doc "Creates a new guild leader."
  @spec create_leader(guild :: Guild.t(), member :: Member.t(), attrs :: map()) ::
          {:ok, Leader.t()} | {:error, Ecto.Changeset.t()}
  def create_leader(%Guild{} = guild, %Member{} = member, attrs) do
    %Leader{guild_id: guild.id, member_id: member.id} |> Leader.changeset(attrs) |> Repo.insert()
  end

  @doc "Updates a guild leader with the given attrs."
  @spec update_leader(leader :: Leader.t(), attrs :: map()) ::
          {:ok, Leader.t()} | {:error, Ecto.Changeset.t()}
  def update_leader(%Leader{} = leader, attrs) do
    leader |> Leader.changeset(attrs) |> Repo.update()
  end

  @doc "Gets a guild leader by their id w/ optional filters."
  @spec get_leader(id :: integer(), filters :: Keyword.t()) :: Leader.t() | nil
  @spec get_leader(Guild.t(), filters :: Keyword.t()) :: Leader.t() | nil
  def get_leader(id_or_guild, filters \\ [])

  def get_leader(%Guild{} = guild, filters) do
    filters |> Keyword.put(:guild_id, guild.id) |> Leader.query() |> Repo.one()
  end

  def get_leader(id, filters) do
    filters |> Keyword.put(:id, id) |> Leader.query() |> Repo.one()
  end

  @doc "Gets all guild leaders matching the given filters."
  @spec list_leaders(filters :: Keyword.t()) :: [Leader.t()]
  def list_leaders(filters \\ []) do
    filters |> Leader.query() |> Repo.all()
  end
end
