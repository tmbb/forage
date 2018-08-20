defmodule Forage.QueryBuilder do
  import Ecto.Query, only: [from: 2]
  alias Forage.Codec.Decoder
  alias Forage.QueryBuilder.SearchFilter
  alias Forage.QueryBuilder.SortField

  def build_query(schema, params) do
    # Process the raw Phoenix params into a form that can be more easily digested
    # by Forage and some other pagination library like scrivener
    forage_plan = Decoder.decode(schema, params)
    # Build parts of the query (the filters and the sorting columns)
    where_clause = SearchFilter.filters_to_where_clause(forage_plan.search)
    order_by_clause = SortField.build_order_by_clause(forage_plan.sort)
    # We won't deal with pagination here

    # Build the query (except for the pagination)
    query =
      from _ in schema,
        # Apply search filters
        where: ^where_clause,
        # apply sort
        order_by: ^order_by_clause

    # Return the forage plan and the query
    {forage_plan, query}
  end
end