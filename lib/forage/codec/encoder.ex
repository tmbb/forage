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
    # Each of the forage components (search, sort and pagination) will be encoded as maps,
    # so that they can simply be merged together
    search_map = encode_search(plan)
    sort_map = encode_sort(plan)
    pagination_map = encode_pagination(plan)
    # Merge the three maps
    search_map |> Map.merge(sort_map) |> Map.merge(pagination_map)
  end

  @doc """
  Encode the "search" part of a forage plan. Returns a map.
  """
  def encode_search(%ForagePlan{search: []} = _plan), do: %{}

  def encode_search(%ForagePlan{search: search} = _plan) do
    search_value =
      for search_filter <- search, into: %{} do
        field_name = Atom.to_string(search_filter[:field])
        # Return key-value pair
        {field_name, %{
          "operator" => search_filter[:operator],
          "value" => search_filter[:value]
          }
        }
      end
    %{"_search" => search_value}
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
    encoded_page_nr =
      case Keyword.fetch(pagination, :page) do
        :error -> %{}
        {:ok, value} -> %{"page" => value}
      end

    encoded_page_size =
      case Keyword.fetch(pagination, :page_size) do
        :error -> %{}
        {:ok, value} -> %{"page_size" => value}
      end

    case Map.merge(encoded_page_nr, encoded_page_size) do
      empty when empty == %{} ->
        %{}

      not_empty ->
        %{"_pagination" => not_empty}
    end
  end
end