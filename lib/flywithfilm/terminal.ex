defmodule Flywithfilm.Terminal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "terminals" do
    field :name, :string
    field :has_ct, :boolean, default: false
    field :has_xray, :boolean, default: false

    belongs_to :airport, Flywithfilm.Airport

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(terminal, attrs) do
    terminal
    |> cast(attrs, [
      :name,
      :has_ct,
      :has_xray
    ])
    |> validate_required([
      :name,
      :has_ct,
      :has_xray
    ])
  end
end
