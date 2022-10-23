defmodule Forage do
  @moduledoc """
  Documentation for Forage.
  """
  import Ecto.Query, only: [where: 3]
  alias Ecto.Changeset
  alias Forage.Codec.Decoder

  defdelegate build_query(params, schema, options \\ []), to: Forage.QueryBuilder
  defdelegate build_plan_and_query(params, schema, options), to: Forage.QueryBuilder
  defdelegate paginate(params, schema, options, repo_opts), to: Forage.Paginator
  defdelegate naive_search_params(params, field), to: Forage.SearchPostgreSQL

  @doc """
  TODO
  """
  def cast_related(repo, schema, attrs) do
    for {key, value} <- attrs, into: %{} do
      case key do
        "__forage_select_many__" <> name ->
          {remote_schema, _name_as_atom} =
            Decoder.remote_schema_and_field_name_as_atom(name, schema)

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

  @doc """
  Preload the associations in a database result.
  
  It accepts the following types of result:
  
    - `{:ok, struct}` where `struct` is an ecto schema
    - `{:error, changeset}` where `changeset` is a changeset
  
  This function is optimized to process the results of operations such as
  `c:Repo.insert/1` and `c:Repo.update/1`.
  """
  def preload_in_result({:ok, struct}, repo, preloads) do
    {:ok, repo.preload(struct, preloads)}
  end

  def preload_in_result({:error, changeset}, repo, preloads) do
    {:error, preload_in_changeset(changeset, repo, preloads)}
  end

  @doc """
  Preload the associations in a changeset
  """
  def preload_in_changeset(changeset, repo, preloads) do
    # Preloading the data is very easy, because the data
    # is usually a struct already
    new_data = repo.preload(changeset.data, preloads)
    # Handling changes is harder.
    # We'll have to create a fake changeset.
    schema = changeset.data.__meta__.schema
    changes = changeset.changes
    # Create a "fake" struct so that we can preload the assocs.
    changes_struct = struct(schema, changes)
    changes_preloaded = repo.preload(changes_struct, preloads)
    preloaded_assocs = Map.take(changes_preloaded, preloads)
    merged_changes = Map.merge(changes, preloaded_assocs)
    # Update the data and the changesets
    %{changeset | data: new_data, changes: merged_changes}
  end
end
