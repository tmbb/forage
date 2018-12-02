defmodule Forage.Paginator do
  alias Forage.QueryBuilder

  defp get_sort_direction!(forage_plan) do
    all_asc? = Enum.all?(forage_plan.sort, fn field_data -> field_data[:direction] == :asc end)
    all_desc? = Enum.all?(forage_plan.sort, fn field_data -> field_data[:direction] == :desc end)
    # TODO: better exceptions
    case {all_asc?, all_desc?} do
      {true, false} -> :asc
      {false, true} -> :desc
      {false, false} -> raise ArgumentError, "Sort fields must be all `:asc` or all `:desc`"
      {true, true} -> raise "This state is impossible unless there are no sort fields!"
    end
  end

  defp get_fields(forage_plan) do
    Enum.map(forage_plan.sort, fn field_data -> field_data[:field] end)
  end

  @doc """
  Build properly paginated Ecto queries from a set of parameters.

  Requires a repo with a `paginate/2` function.
  The easiest way of having a compliant repo is to `use Paginator, ...` inside your `Repo`.
  """
  def paginate(params, schema, repo, options, repo_opts \\ []) do
    # Get an initial query (before pagination)
    {forage_plan, query} = QueryBuilder.build_query(params, schema, options)
    # The cursor fields are the fields used to sort the query
    cursor_fields = get_fields(forage_plan)
    # The sort direction is identified from the Ecto query.
    # It's possible that the ecto query sorts the sort fields in different directions.
    # If that happens, raise an exception with extreme prejudice.
    sort_direction = get_sort_direction!(forage_plan)
    # Gather all pagination option in one place
    pagination_options =
      forage_plan.pagination ++
        [
          cursor_fields: cursor_fields,
          sort_direction: sort_direction
        ]

    # Finally, run the (paginated) query and return the data.
    repo.paginate(query, pagination_options ++ repo_opts)
  end
end
