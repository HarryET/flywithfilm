defmodule Flywithfilm.Suggestion do
  use Ecto.Schema

  schema "suggestions" do
    field :email, :string

    belongs_to :airport, Flywithfilm.Airport

    embeds_many :terminal_changesets, Flywithfilm.TerminalChangeset
    embeds_one :policies, Flywithfilm.Policy

    timestamps(type: :utc_datetime)
  end
end

defmodule Flywithfilm.TerminalChangeset do
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :has_ct, :boolean, default: false
    field :has_xray, :boolean, default: false

    # Should this terminal be created?
    field :is_created, :boolean, default: false

    # Should this terminal be deleted?
    field :is_deleted, :boolean, default: false
  end
end
