defmodule Forage.Codec.Decoder do
  @moduledoc """
  Functionality to decode a Phoenix `params` map into a form suitable for use
  with the query builders and pagination libraries
  """
  alias Forage.Codec.Exceptions.InvalidFieldError
  alias Forage.Codec.Exceptions.InvalidSortDirectionError
  alias Forage.Codec.Exceptions.InvalidPaginationDataError
  alias Forage.ForagePlan

  @doc """
  Encodes a params map into a forage plan (`Forage.ForagerPlan`).
  """
  def decode(schema, params) do
    search = decode_search(schema, params)
    sort = decode_sort(schema, params)
    pagination = decode_pagination(schema, params)
    %ForagePlan{search: search, sort: sort, pagination: pagination}
  end

  @doc """
  Extract and decode the search filters from the `params` map into a keyword list.
  """
  def decode_search(schema, %{"_search" => search}) do
    decoded =
      for {field_name, field_params} <- search do
        field_atom = safe_field_name_to_atom!(schema, field_name)
        operator = field_params["operator"]
        value = field_params["value"]
        [field: field_atom, operator: operator, value: value]
      end

    # Sort the result so that the order is always the same
    Enum.sort(decoded)
  end

  def decode_search(_schema, _params), do: []

  @doc """
  Extract and decode the sort fields from the `params` map into a keyword list.
  """
  def decode_sort(schema, %{"_sort" => sort}) do
    decoded =
      # TODO: make this more robust
      for {field_name, %{"direction" => direction}} <- sort do
        field_atom = safe_field_name_to_atom!(schema, field_name)
        direction = decode_direction(direction)
        [field: field_atom, direction: direction]
      end

    # Sort the result so that the order is always the same
    Enum.sort(decoded)
  end

  def decode_sort(_schema, _params), do: []

  @doc """
  Extract and decode the pagination data from the `params` map into a keyword list.
  """
  def decode_pagination(_schema, %{"_pagination" => pagination}) do
    page_size_data =
      case pagination["page_size"] do
        nil -> []
        # Will raise if it's not a valid integer
        page_size -> [page_size: pagination_data_to_integer!(page_size)]
      end

    page_nr_data =
      case pagination["page"] do
        nil -> []
        # Will raise if it's not a valid integer
        page -> [page: pagination_data_to_integer!(page)]
      end

      # Already sorted
      page_nr_data ++ page_size_data
  end

  def decode_pagination(_schema, _params), do: []


  @spec decode_direction(String.t | nil) :: atom() | nil
  defp decode_direction("asc"), do: :asc
  defp decode_direction("desc"), do: :desc
  defp decode_direction(nil), do: nil
  defp decode_direction(value), do: raise InvalidSortDirectionError, value

  def pagination_data_to_integer!(value) do
    try do
      String.to_integer(value)
    rescue
      ArgumentError -> raise InvalidPaginationDataError, value
    end
  end

  @doc false
  @spec safe_field_name_to_atom!(atom(), String.t()) :: atom()
  def safe_field_name_to_atom!(schema, field_name) do
    # This function performs the dangerous job of turning a string into an atom.
    # Because the atom table on the BEAM is limited, there is a limit of atoms that can exist.
    # This means generating atoms at runtime is very dangerous,
    # especially if they're being generated from user input.
    # The whole goal of `forage` is to generate process "raw" (i.e. untrusted) user input,
    # so we must be especially careful.
    # Using `String.to_atom()` is completely out of the question.
    # Using `String.to_existing_atom()` is a possibility, but we have chosen to do it in another way.
    # Instead of turning the string into an atom, we iterate over the schema fields,
    # convert them into strings and check the strings for equality.
    # When we find a match, we return the atom.
    schema_fields = schema.__schema__(:fields)
    found = Enum.find(schema_fields, fn field -> field_name == Atom.to_string(field) end)
    case found do
      nil ->
        raise InvalidFieldError, {schema, field_name}

      _ ->
        found
    end
  end
end