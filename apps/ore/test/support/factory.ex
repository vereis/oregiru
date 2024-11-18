defmodule Ore.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Ore.Repo

  alias Ore.Guilds.Guild
  alias Ore.Guilds.Leader
  alias Ore.Guilds.Member

  def guild_factory do
    %Guild{
      name: Enum.random(["Teahouse", "Elm Tree", "Silly Cubs"]),
      slogan: "We will be the best!",
      level: Enum.random(1..100)
    }
  end

  def member_factory do
    %Member{
      guild: build(:guild),
      given_name: Enum.random(["John", "Jane", "Alice", "Bob", "Charlie", "Diana"]),
      family_name: Enum.random(["Smith", "Doe", "Johnson", "Brown", "White", "Black"]),
      level: Enum.random(1..100),
      gender: Enum.random([:male, :female, nil])
    }
  end

  def leader_factory do
    guild = insert(:guild)
    member = insert(:member, guild: guild)

    %Leader{
      guild: guild,
      member: member,
      email: Ecto.UUID.generate() <> "@example.com",
      password_hash: "password"
    }
  end
end
