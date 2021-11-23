defmodule Forage.AssocLoader do
  @moduledoc false
  import Ecto.Query, only: [from: 2]

  defp string_to_existing_atom(s) do
    try do
      {:ok, String.to_existing_atom(s)}
    rescue
      ArgumentError -> :error
    end
  end

  def struct_to_map(map) do
    for {k, v} <- map, into: %{} do
      {to_string(k), v}
    end
  end

  def load_assocs(repo, schema, attrs) do
    assoc_fields = schema.__schema__(:associations)

    for {k, v} <- attrs, into: %{} do
      case string_to_existing_atom(k) do
        {:ok, k_atom} ->
          case k_atom in assoc_fields and is_list(v) and Enum.any?(v, fn i -> not is_map(i) end) do
            true ->
              assoc = schema.__schema__(:association, k_atom)
              queryable = assoc.queryable
              items = repo.all(from(u in queryable, where: u.id in ^v))

              {k, items}

            false ->
              {k, v}
          end

        :error ->
          {k, v}
      end
    end
  end
end
