defmodule TestSchemas.PrimarySchema do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestSchemas.RemoteSchema

  schema "dummy_schema" do
    field(:string_field, :string)
    field(:integer_field, :integer)
    field(:remote_schema_id, :integer)
    belongs_to(:owner, RemoteSchema)
  end

  @doc false
  def changeset(remote_schema, attrs) do
    remote_schema
    |> cast(attrs, [:string_field, :integer_field])
    |> validate_required([:string_field, :integer_field])
  end
end
