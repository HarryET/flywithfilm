defmodule Flywithfilm.Repo.Migrations.CreateTerminals do
  use Ecto.Migration

  def change do
    create table(:terminals) do
      add :name, :string
      add :has_ct, :boolean, default: false, null: false
      add :has_xray, :boolean, default: false, null: false

      add :airport_id, references(:airports, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
