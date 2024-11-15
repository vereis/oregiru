defmodule Ore.Schema do
  @moduledoc "Imports and aliases for schema modules."

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use EctoModel.Queryable

      import Ecto.Changeset

      alias __MODULE__

      @type t :: %__MODULE__{}
    end
  end
end
