defmodule Ore.Guilds.Member do
  @moduledoc false

  use Ore.Schema

  alias Ore.Guilds.Guild

  schema "guild_members" do
    field(:given_name, :string)
    field(:family_name, :string)
    field(:level, :integer, default: 0)
    field(:gender, Ecto.Enum, values: [:male, :female])

    field(:name, :string, virtual: true)

    belongs_to(:guild, Guild)
  end

  @impl EctoHooks
  def after_get(%Member{} = member, _delta) do
    resolve_name!(member)
  end

  @impl EctoHooks
  def after_insert(%Member{} = member, _delta) do
    resolve_name!(member)
  end

  @impl EctoHooks
  def after_update(%Member{} = member, _delta) do
    resolve_name!(member)
  end

  @impl EctoHooks
  def after_delete(%Member{} = member, _delta) do
    resolve_name!(member)
  end

  def changeset(%Member{} = member, attrs) do
    member
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:given_name, :family_name, :level])
  end

  defp resolve_name!(%Member{} = member) do
    %{member | name: "#{member.given_name} #{member.family_name}"}
  end
end
