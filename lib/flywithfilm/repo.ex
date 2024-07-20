defmodule Flywithfilm.Repo do
  use Ecto.Repo,
    otp_app: :flywithfilm,
    adapter: Ecto.Adapters.Postgres
end
