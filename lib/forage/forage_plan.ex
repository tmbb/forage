defmodule Forage.ForagePlan do
  @moduledoc """
  A forage plan, which can be used to run paginated queries on your repo.
  """
  defstruct search: [],
            sort: [],
            pagination: []

  def new(opts) do
    %__MODULE__{
      search: Keyword.get(opts, :search, []),
      sort: Keyword.get(opts, :sort, []),
      pagination: Keyword.get(opts, :pagination, [])
    }
  end
end
