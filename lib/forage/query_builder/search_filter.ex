defmodule Forage.QueryBuilder.SearchFilter do
  import Ecto.Query, only: [dynamic: 2]

  def filters_to_where_clause(filters) do
    Enum.reduce filters, true, fn filter, query_so_far ->
      add_filter_to_query(query_so_far, filter.operator, filter.field, filter.value)
    end
  end

  # Currently `add_filter_to_query()` only supports AND in queries (and not OR)

  # Generic
  defp add_filter_to_query(fragment, "equal_to", field_atom, value) do
    dynamic([p], field(p, ^field_atom) == ^value and ^fragment)
  end

  defp add_filter_to_query(fragment, "not_equal_to", field_atom, value) do
    dynamic([p], field(p, ^field_atom) != ^value and ^fragment)
  end

  # Numeric
  defp add_filter_to_query(fragment, "greater_than_or_equal_to", field_atom, value) do
    dynamic([p], field(p, ^field_atom) >= ^value and ^fragment)
  end

  defp add_filter_to_query(fragment, "less_than_or_equal_to", field_atom, value) do
    dynamic([p], field(p, ^field_atom) <= ^value and ^fragment)
  end

  defp add_filter_to_query(fragment, "greater_than", field_atom, value) do
    dynamic([p], field(p, ^field_atom) > ^value and ^fragment)
  end

  defp add_filter_to_query(fragment, "less_than", field_atom, value) do
    dynamic([p], field(p, ^field_atom) < ^value and ^fragment)
  end

  # Text
  defp add_filter_to_query(fragment, "contains", field_atom, value) do
    text = value <> "%"
    dynamic([p], ilike(field(p, ^field_atom), ^text) and ^fragment)
  end

  defp add_filter_to_query(fragment, "starts_with", field_atom, value) do
    text = value <> "%"
    dynamic([p], ilike(field(p, ^field_atom), ^text) and ^fragment)
  end

  defp add_filter_to_query(fragment, "ends_with", field_atom, value) do
    text = value <> "%"
    dynamic([p], ilike(field(p, ^field_atom), ^text) and ^fragment)
  end

  # No operator is given: assume "equal_to"
  defp add_filter_to_query(fragment, nil, field_atom, value) do
    text = value
    dynamic([p], field(p, ^field_atom) == ^text and ^fragment)
  end
end