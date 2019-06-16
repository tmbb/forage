defmodule Forage do
  @moduledoc """
  Documentation for Forage.
  """
  import Ecto.Query, only: [where: 3]
  alias Forage.Codec.Decoder

  defdelegate build_query(params, schema, options), to: Forage.QueryBuilder
  defdelegate paginate(params, schema, options, repo_opts), to: Forage.Paginator

  @doc """
  ABC
  """
  def cast_related(params, schema, repo) do
    for {key, value} <- params, into: %{} do
      case key do
        "__forage_select_many__" <> name ->
          remote_schema = Decoder.remote_schema(name, schema)
          # In this case, value is a list of `id`s
          items = remote_schema |> where([p], p.id in ^value) |> repo.all()
          {name, items}

        name ->
          {name, value}
      end
    end
  end
end
