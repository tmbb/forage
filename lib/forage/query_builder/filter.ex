defmodule Forage.QueryBuilder.Filter do
  @moduledoc false
  import Forage.QueryBuilder.Filter.AddFilterToQuery

  @doc """
  Compile a list of filters from a forage plan into an Ecto query
  """
  def joins_and_where_clause(filters) do
    assocs = extract_non_empty_assocs(filters)
    simple_filters = extract_non_empty_simple_filters(filters)
    join_fields = Enum.map(assocs, fn assoc -> assoc[:field] end)
    nr_of_variables = length(assocs) + 1
    assoc_to_index = map_of_assoc_to_index(assocs)

    query_without_assocs =
      Enum.reduce(simple_filters, true, fn filter, query_so_far ->
        {:simple, field} = filter[:field]

        add_filter_to_query(
          nr_of_variables,
          # fields belong to the zeroth variable
          0,
          query_so_far,
          filter[:operator],
          field,
          filter[:value]
        )
      end)

    # Should we deprecate queries with assocs?
    # Using foreign key columns is much, much simpler, and play better with the HTML widgets...
    # I'm not even sure I understand this code right now...
    # We will keep them for now.
    query_with_assocs =
      Enum.reduce(assocs, query_without_assocs, fn filter, query_so_far ->
        {:assoc, {_schema, _local, remote} = assoc} = filter[:field]
        variable_index = assoc_to_index[assoc]

        add_filter_to_query(
          nr_of_variables,
          variable_index,
          query_so_far,
          filter[:operator],
          remote,
          filter[:value]
        )
      end)

    {join_fields, query_with_assocs}
  end

  # Define the private function `add_filter_to_query/6`.
  @spec add_filter_to_query(
          n :: integer(),
          i :: integer(),
          query_so_far :: any(),
          operator :: String.t(),
          field :: atom(),
          value :: any()
        ) :: any()
  define_filter_adder(:add_filter_to_query, 8)

  defp map_of_assoc_to_index(assocs) do
    assocs
    |> Enum.map(fn filter ->
      {:assoc, assoc} = filter[:field]
      assoc
    end)
    |> Enum.with_index(1)
    |> Enum.into(%{})
  end

  defp extract_non_empty_assocs(filters) do
    Enum.filter(filters, fn filter ->
      match?({:assoc, _assoc}, filter[:field]) and filter[:value] != ""
    end)
  end

  defp extract_non_empty_simple_filters(filters) do
    Enum.filter(filters, fn filter ->
      match?({:simple, _simple}, filter[:field]) and filter[:value] != ""
    end)
  end
end
