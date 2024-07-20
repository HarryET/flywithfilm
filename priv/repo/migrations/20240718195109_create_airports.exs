defmodule Flywithfilm.Repo.Migrations.CreateAirports do
  use Ecto.Migration

  def change do
    create table(:airports) do
      add :name, :string
      add :iata_code, :string
      add :country, :string

      add :policies_verified, :boolean, default: false, null: false
      add :positive_votes, :integer, default: 0
      add :negative_votes, :integer, default: 0

      add :latitude, :float
      add :longitude, :float

      add :notes, :string, default: nil

      add :policies, :map, default: %{instant: %{xray: -1, ct: -1}, film: %{xray: -1, ct: -1}}

      timestamps(type: :utc_datetime)
    end
  end
end
