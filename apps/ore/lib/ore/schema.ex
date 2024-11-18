defmodule Ore.Schema do
  @moduledoc "Imports and aliases for schema modules."

  defmacro __using__(_) do
    quote do
      @behaviour EctoHooks

      use Ecto.Schema
      use EctoModel.Queryable

      import Ecto.Changeset

      alias __MODULE__

      @type t :: %__MODULE__{}

      @doc "Preloads an association before overwriting it with `Ecto.Schema.put_assoc/3`."
      @spec preload_put_assoc(
              Ecto.Changeset.t(),
              attrs :: map(),
              field :: atom(),
              attr_key :: atom(),
              filters :: Keyword.t()
            ) ::
              Ecto.Changeset.t()
      def preload_put_assoc(changeset, attrs, field, attr_key, filters \\ []) do
        Ore.Schema.preload_put_assoc(Ore.Repo, changeset, attrs, field, attr_key, filters)
      end
    end
  end

  @doc """
  Helper function for handling the boilerplate of preloading associations before setting them
  as an association, particularly useful for many-to-many or has-many relations.
  """
  @spec preload_put_assoc(
          repo :: module(),
          Ecto.Changeset.t(),
          attrs :: map(),
          field :: atom(),
          attr_key :: atom(),
          filters :: Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def preload_put_assoc(repo, changeset, attrs, field, attr_key, filters \\ [])

  def preload_put_assoc(repo, %Ecto.Changeset{} = changeset, attrs, field, attr_key, filters) do
    case Map.get(attrs, attr_key) do
      nil ->
        changeset

      item ->
        items = handle_preload_put_assoc_items(repo, changeset, field, item, filters)

        changeset
        |> Map.fetch!(:data)
        |> repo.preload(field)
        |> then(fn data -> %Ecto.Changeset{changeset | data: data} end)
        |> Ecto.Changeset.put_assoc(field, items)
    end
  end

  defp handle_preload_put_assoc_items(
         repo,
         %Ecto.Changeset{data: %schema{}},
         field,
         items,
         filters
       ) do
    import Ecto.Query

    queryable =
      field
      |> schema.association()
      |> Map.get(:queryable)

    cond do
      Enum.all?(items, &is_struct(&1, queryable)) ->
        items

      Enum.all?(items, &is_binary/1) ->
        items = Enum.map(items, &String.to_integer/1)
        repo.all(from(x in queryable, where: x.id in ^items, where: ^filters))

      Enum.all?(items, &is_integer/1) ->
        repo.all(from(x in queryable, where: x.id in ^items, where: ^filters))

      true ->
        raise ArgumentError,
          message:
            "Function `preload_put_assoc/3` expects items to either be a list of IDs, or a list of structs, got: #{inspect(items)}"
    end
  end
end
