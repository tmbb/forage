defmodule Post do
  use Ecto.Schema

  schema "posts" do
    field :title, :string
    field :subtitle, :string
    field :text, :string
    has_many :comments, Comment
  end
end

defmodule Comment do
  use Ecto.Schema

  schema "comments" do
    field :title, :string
    field :text, :string
    belongs_to :post, Post
  end
end

defmodule Utils do
  def fields(schema) do
    schema.__schema__(:fields)
  end

  def associations(schema) do
    schema.__schema__(:associations)
  end

  def association(schema, assoc) do
    schema.__schema__(:association, assoc)
  end

  def association_fields(schema, assoc) do
    schema |> association(assoc) |> fields()
  end
end