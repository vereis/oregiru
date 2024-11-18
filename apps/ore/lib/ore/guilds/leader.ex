defmodule Ore.Guilds.Leader do
  @moduledoc false
  use Ore.Schema

  alias Ore.Guilds.Guild
  alias Ore.Guilds.Member

  schema "guild_leaders" do
    field(:email, :string)
    field(:password_hash, :string, redact: true)
    field(:password, :string, virtual: true)

    belongs_to(:guild, Guild)
    belongs_to(:member, Member)
  end

  def changeset(%Leader{} = leader, attrs) do
    {password, attrs} = Map.pop(attrs, :password)

    attrs =
      if password do
        attrs
        |> Map.put(:password_hash, encrypt_and_hash_password(password))
        |> Map.delete(:password)
      else
        Map.drop(attrs, [:password, :password_hash])
      end

    leader
    |> cast(attrs, __schema__(:fields))
    |> validate_required([:email, :password_hash])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  @impl EctoModel.Queryable
  def query(base_query \\ base_query(), filters) do
    Enum.reduce(filters, base_query, fn
      {password, value}, query when password in [:password, :password_hash] ->
        from(x in query, where: x.password_hash == ^encrypt_and_hash_password(value))

      filter, query ->
        apply_filter(query, filter)
    end)
  end

  defp encrypt_and_hash_password(password) do
    Base.encode64(:erlang.term_to_binary(password, [:deterministic]), padding: false)
  end
end
