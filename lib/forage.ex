defmodule Forage do
  @moduledoc """
  Documentation for Forage.
  """

  defdelegate build_query(params, schema, options), to: Forage.QueryBuilder
  defdelegate paginate(params, schema, options, repo_opts), to: Forage.Paginator
end
