defmodule Forage.ForagePlan do
  @moduledoc """
  A forage plan, which can be used to run paginated queries on your repo.

  It contains 3 parts:
    * `:filter` - a list of filters for the plan.
      They will be converted into Ecto `where` clauses
    * `:sort` - a list of fields to use when sorting
      They will be converted into Ecto `oerder_by` clauses.
    * `:pagination` - data related to pagination of entries.
      Forage uses [Paginator](https://github.com/duffelhq/paginator)
      under the hood to implement
      [cursor-based pagination](https://github.com/duffelhq/paginator#limit-offset),
      which is more efficient than the naïve
      [offset-based pagination](https://github.com/duffelhq/paginator#cursor-based-aka-keyset-pagination)
      for medium/large datasets.
  """

  defstruct filter: [],
            sort: [],
            pagination: %Forage.ForagePlan.Pagination{}

  @type t :: %__MODULE__{}
end
