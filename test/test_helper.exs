defmodule TestSchemas.DummySchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dummy_schema" do
    field :string_field, :string
    field :integer_field, :integer
  end

  @doc false
  def changeset(dummy_schema, attrs) do
    dummy_schema
    |> cast(attrs, [:string_field, :integer_field])
    |> validate_required([:string_field, :integer_field])
  end
end

ExUnit.start()
