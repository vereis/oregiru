defmodule Ore.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Ore.Repo

  alias Ore.Guilds.Guild

  def guild_factory do
    %Guild{
      name: Enum.random(["Teahouse", "Elm Tree", "Silly Cubs"]),
      slogan: "We will be the best!",
      level: 1
    }
  end
end
