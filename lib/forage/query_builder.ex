defmodule Forage.QueryBuilder do
  @moduledoc false
  import Ecto.Query, only: [from: 2]
  alias Forage.Codec.Decoder
  alias Forage.QueryBuilder.Filter
  alias Forage.QueryBuilder.SortField

  defp sorts_by_id?(forage_plan) do
    Enum.find(forage_plan.sort, fn f -> f[:field] == :id end)
  end

  defp maybe_add_sort_fields(forage_plan, sort_fields, direction) do
    case forage_plan.sort do
      [] ->
        sort_data = Enum.map(sort_fields, fn field -> [field: field, direction: direction] end)
        %{forage_plan | sort: sort_data}

      [[field: _, direction: field_direction] | _rest] ->
        if sorts_by_id?(forage_plan) do
          forage_plan
        else
          sort = forage_plan.sort
          %{forage_plan | sort: sort ++ [[field: :id, direction: field_direction]]}
        end
    end
  end

  def join_assocs(query, assocs) do
    Enum.reduce(assocs, query, fn {:assoc, {_, local, _}}, query_so_far ->
      from([p, ...] in query_so_far,
        join: x in assoc(p, ^local)
      )
    end)
  end

  @doc """
  Build a (non-paginated) query from `params`.
  """
  def build_query(params, schema, options \\ []) do
    # Process the raw Phoenix params into a form that can be more easily digested
    # by Forage and some other pagination library like scrivener
    raw_forage_plan = Decoder.decode(params, schema)
    # It's really important that there is a stable sort order.
    # If the `params` don't contain sort information, we try to extract
    # sort information from the `options`.
    default_sort = Keyword.get(options, :sort, [])
    default_sort_direction = Keyword.get(options, :sort_direction, :asc)
    preload = Keyword.get(options, :preload, [])
    # This plan has sort information, even if the `params` don't.
    forage_plan = maybe_add_sort_fields(raw_forage_plan, default_sort, default_sort_direction)

    # Build parts of the query (the filters and the sorting columns)
    {joins, where_clause} = Filter.joins_and_where_clause(forage_plan.filter)
    order_by_clause = SortField.build_order_by_clause(forage_plan.sort)
    # Build the query (except for the pagination)
    query_with_joins = join_assocs(schema, joins)

    final_query =
      from([...] in query_with_joins,
        where: ^where_clause,
        order_by: ^order_by_clause,
        preload: ^preload
      )

    # Return the forage plan and the query
    {forage_plan, final_query}
  end

  # Helpers

  @doc false
  def extract_non_empty_assocs(filters) do
    assocs =
      Enum.filter(filters, fn filter ->
        match?({:assoc, _assoc}, filter[:field])
      end)

    Enum.map(assocs, fn {:assoc, {_schema, local, remote}} ->
      {local, remote}
    end)
  end
end
