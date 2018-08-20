defmodule Forage.ForagePlan do
  defstruct [
    search: [],
    sort: [],
    pagination: []
  ]

  def new(opts) do
    %__MODULE__{
      search: Keyword.get(opts, :search, []),
      sort: Keyword.get(opts, :sort, []),
      pagination: Keyword.get(opts, :pagination, [])
    }
  end
end

