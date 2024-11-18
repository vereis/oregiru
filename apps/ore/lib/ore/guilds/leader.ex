defmodule Ore.Guilds.Leader do
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
    attrs =
      attrs
      |> Map.drop([:password, :hashed_password])
      |> Map.put(:hashed_password, &encrypt_and_hash_password/1)

    leader
    |> cast(attrs, [:email, :hashed_password])
    |> validate_required([:email, :password])
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

  # TODO: Don't do it this way! This is just for demonstration purposes.
  defp encrypt_and_hash_password(password) do
    Base.encode64(:erlang.term_to_binary(password), padding: false)
  end
end
