defmodule Flywithfilm.Policy do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :xray, :integer
    field :ct, :integer
  end

  @doc false
  def changeset(policy, attrs) do
    policy
    |> cast(attrs, [
      :xray,
      :ct
    ])
    |> validate_required([
      :xray,
      :ct
    ])
  end
end
