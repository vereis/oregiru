defmodule Ore.Repo do
  use Ecto.Repo,
    otp_app: :ore,
    adapter: Ecto.Adapters.SQLite3

  use EctoMiddleware

  @dialyzer {:nowarn_function, middleware: 2}
  def middleware(_action, _resource) do
    [EctoHooks.Middleware.Before, EctoMiddleware.Super, EctoHooks.Middleware.After]
  end
end
