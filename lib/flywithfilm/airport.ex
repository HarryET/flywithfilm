defmodule Flywithfilm.Airport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "airports" do
    field :name, :string
    field :iata_code, :string
    field :country, :string

    field :policies_verified, :boolean, default: false
    field :positive_votes, :integer, default: 0
    field :negative_votes, :integer, default: 0

    field :latitude, :float
    field :longitude, :float

    field :notes, :string, default: nil

    has_many :terminals, Flywithfilm.Terminal

    embeds_one :policies, Policies do
      embeds_one :instant, Flywithfilm.Policy
      embeds_one :film, Flywithfilm.Policy
    end

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(airport, attrs) do
    airport
    |> cast(attrs, [
      :name,
      :iata_code,
      :policies_verified,
      :positive_votes,
      :negative_votes,
      :latitude,
      :longitude,
      :notes
    ])
    |> validate_required([
      :name,
      :iata_code,
      :policies_verified,
      :positive_votes,
      :negative_votes,
      :latitude,
      :longitude,
      :notes
    ])
  end
end
