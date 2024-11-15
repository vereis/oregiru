defmodule Ore.Guilds do
  @moduledoc "Module for managing all things related to guilds."

  alias Ore.Guilds.Guild
  alias Ore.Guilds.Member
  alias Ore.Repo

  @doc "Creates a new guild."
  @spec create_guild(attrs :: map()) :: {:ok, Guild.t()} | {:error, Ecto.Changeset.t()}
  def create_guild(attrs) do
    %Guild{} |> Guild.changeset(attrs) |> Repo.insert()
  end

  @doc "Updates a guild with the given attrs."
  @spec update_guild(Guild.t(), attrs :: map()) :: {:ok, Guild.t()} | {:error, Ecto.Changeset.t()}
  def update_guild(guild, attrs) do
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
  @spec create_member(guild :: Guild.t(), attrs :: map()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def create_member(guild, attrs) do
    %Member{guild_id: guild.id} |> Member.changeset(attrs) |> Repo.insert()
  end

  @doc "Updates a guild member with the given attrs."
  @spec update_member(member :: Member.t(), attrs :: map()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def update_member(member, attrs) do
    member |> Member.changeset(attrs) |> Repo.update()
  end

  @doc "Gets a guild member by their id w/ optional filters."
  @spec get_member(id :: integer(), filters :: Keyword.t()) :: Member.t() | nil
  def get_member(id, filters \\ []) do
    filters |> Keyword.put(:id, id) |> Member.query() |> Repo.one()
  end

  @doc "Gets all guild members matching the given filters."
  @spec list_members(filters :: Keyword.t()) :: [Member.t()]
  def list_members(filters \\ []) do
    filters |> Member.query() |> Repo.all()
  end
end
