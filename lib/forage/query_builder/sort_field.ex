defmodule Forage.QueryBuilder.SortField do
  @moduledoc false

  def build_order_by_clause(sort_data) do
    # Return a keyword list
    for row <- sort_data do
      # May not exist if the user hasn't specified it.
      # By default, sort results in ascending order
      direction = row[:direction] || :asc
      # Will always existe becuase of how the keyword list is constructed
      field = row[:field]
      # Return the pair
      {direction, field}
    end
  end
end