defmodule Ore.Guilds.Guild do
  @moduledoc false
  use Ore.Schema

  alias Ore.Guilds.Leader
  alias Ore.Guilds.Member

  schema "guilds" do
    field(:name, :string)
    field(:slogan, :string, default: "")
    field(:level, :integer, default: 0)

    has_one(:leader, Leader)
    has_many(:members, Member)
  end

  def changeset(%Guild{} = guild, attrs) do
    guild
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:name, :slogan, :level])
  end
end
