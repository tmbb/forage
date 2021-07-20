defmodule Forage do
  @moduledoc """
  Documentation for Forage.
  """
  import Ecto.Query, only: [where: 3]
  alias Ecto.Changeset
  alias Forage.Codec.Decoder

  defdelegate build_query(params, schema, options), to: Forage.QueryBuilder
  defdelegate paginate(params, schema, options, repo_opts), to: Forage.Paginator
  defdelegate load_assocs(repo, schema, attrs), to: Forage.AssocLoader
  defdelegate naive_search_params(params, field), to: Forage.Search

  @doc """
  TODO
  """
  def cast_related(repo, schema, attrs) do
    for {key, value} <- attrs, into: %{} do
      case key do
        "__forage_select_many__" <> name ->
          {remote_schema, _name_as_atom} = Decoder.remote_schema_and_field_name_as_atom(name, schema)
          # In this case, value is a list of `id`s
          items = remote_schema |> where([p], p.id in ^value) |> repo.all()
          {name, items}

        name ->
          {name, value}
      end
    end
  end

  @doc """
  TODO
  """
  def put_assoc(%Changeset{} = changeset, attrs, field) do
    assoc = Map.get(attrs, to_string(field), [])
    Changeset.put_assoc(changeset, field, assoc)
  end
end
