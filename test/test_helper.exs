defmodule TestSchemas.PrimarySchema do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestSchemas.RemoteSchema

  schema "dummy_schema" do
    field :string_field, :string
    field :integer_field, :integer
    belongs_to :owner, RemoteSchema
  end

  @doc false
  def changeset(remote_schema, attrs) do
    remote_schema
    |> cast(attrs, [:string_field, :integer_field])
    |> validate_required([:string_field, :integer_field])
  end
end

defmodule TestSchemas.RemoteSchema do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestSchemas.PrimarySchema

  schema "dummy_schema" do
    field :remote_string_field, :string
    field :remote_integer_field, :integer
    has_many :children, PrimarySchema
  end

  @doc false
  def changeset(remote_schema, attrs) do
    remote_schema
    |> cast(attrs, [:remote_string_field, :remote_integer_field])
    |> validate_required([:remote_string_field, :remote_integer_field])
  end
end


ExUnit.start()
