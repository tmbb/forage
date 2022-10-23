defmodule Forage.QueryBuilder.Filter do
  @moduledoc false
  alias Forage.QueryBuilder.AddFilterToWhereClause
  require Ecto.Query, as: Query

  @doc """
  Compile a list of filters from a forage plan into an Ecto query
  """
  def build_where_clause(filters) do
    assocs = extract_non_empty_assocs(filters)
    simple_filters = extract_non_empty_simple_filters(filters)

    where_clause_without_assocs = build_where_clause_without_assocs(true, simple_filters)

    where_clause_with_assocs = build_where_clause_with_assocs(where_clause_without_assocs, assocs)

    where_clause_with_assocs
  end

  def build_query_with_joins(schema, filters) do
    assocs = extract_non_empty_assocs(filters)

    query =
      Enum.reduce(assocs, schema, fn filter, query_so_far ->
        assoc = filter.field
        {:assoc, {_schema, local, _remote}} = assoc

        query_so_far
        |> Query.join(:inner, [p], assoc(p, ^local), as: ^local)
      end)

    query
  end

  defp build_where_clause_without_assocs(clause_so_far, simple_filters) do
    where_clause_without_assocs =
      Enum.reduce(simple_filters, clause_so_far, fn filter, clause_so_far ->
        {:simple, field} = filter.field

        AddFilterToWhereClause.add_filter_on_field(
          clause_so_far,
          filter.operator,
          field,
          filter.value
        )
      end)

    where_clause_without_assocs
  end

  defp build_where_clause_with_assocs(clause_so_far, assocs) do
    where_clause_with_assocs =
      Enum.reduce(assocs, clause_so_far, fn filter, clause_so_far ->
        {:assoc, {_schema, local, remote}} = filter.field

        AddFilterToWhereClause.add_filter_on_assoc(
          clause_so_far,
          filter.operator,
          local,
          remote,
          filter.value
        )
      end)

    where_clause_with_assocs
  end

  defp extract_non_empty_assocs(filters) do
    Enum.filter(filters, fn filter ->
      match?({:assoc, _assoc}, filter.field) and filter.value != ""
    end)
  end

  defp extract_non_empty_simple_filters(filters) do
    Enum.filter(filters, fn filter ->
      match?({:simple, _simple}, filter.field) and filter.value != ""
    end)
  end
end
