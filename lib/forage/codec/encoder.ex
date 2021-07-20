defmodule Forage.Codec.Encoder do
  @moduledoc """
  Functionality to encode a `Forage.Plan` into a Phoenix `param` map
  for use with the `ApplicationWeb.Router.Helpers`.
  """
  alias Forage.ForagePlan

  @doc """
  Encodes a forage plan into a params map.

  This function doesn't need to take the schema as an argument
  because it will never have to convert a string into an atom
  (the params map contains only strings and never atoms)
  """
  def encode(%ForagePlan{} = plan) do
    # Each of the forage components (filter, sort and pagination) will be encoded as maps,
    # so that they can simply be merged together
    filter_map = encode_filter(plan)
    sort_map = encode_sort(plan)
    pagination_map = encode_pagination(plan)
    # Merge the three maps
    filter_map |> Map.merge(sort_map) |> Map.merge(pagination_map)
  end

  @doc """
  Encode the "filter" part of a forage plan. Returns a map.
  """
  def encode_filter(%ForagePlan{filter: []} = _plan), do: %{}

  def encode_filter(%ForagePlan{filter: filter} = _plan) do
    filter_value =
      for filter_filter <- filter, into: %{} do
        field_name =
          case filter_filter[:field] do
            {:simple, name} when is_atom(name) ->
              Atom.to_string(name)

            {:assoc, {_schema, local, remote}} when is_atom(local) and is_atom(remote) ->
              local_string = Atom.to_string(local)
              remote_string = Atom.to_string(remote)
              local_string <> "." <> remote_string
          end

        # Return key-value pair
        {field_name,
         %{
           "op" => filter_filter[:operator],
           "val" => filter_filter[:value]
         }}
      end

    %{"_filter" => filter_value}
  end

  @doc """
  Encode the "sort" part of a forage plan. Returns a map.
  """
  def encode_sort(%ForagePlan{sort: []} = _plan), do: %{}

  def encode_sort(%ForagePlan{sort: sort} = _plan) do
    sort_value =
      for sort_column <- sort, into: %{} do
        field_name = Atom.to_string(sort_column[:field])
        direction_name = Atom.to_string(sort_column[:direction])
        # Return key-value pair
        {field_name, %{"direction" => direction_name}}
      end

    %{"_sort" => sort_value}
  end

  @doc """
  Encode the "pagination" part of a forage plan. Returns a map.
  """
  def encode_pagination(%ForagePlan{pagination: pagination} = _plan) do
    encoded_after =
      case Keyword.fetch(pagination, :after) do
        :error -> %{}
        {:ok, value} -> %{"after" => value}
      end

    encoded_before =
      case Keyword.fetch(pagination, :before) do
        :error -> %{}
        {:ok, value} -> %{"before" => value}
      end

    Map.merge(encoded_after, encoded_before)
  end
end
