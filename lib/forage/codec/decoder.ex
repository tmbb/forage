defmodule Forage.Codec.Decoder do
  @moduledoc """
  Functionality to decode a Phoenix `params` map into a form suitable for use
  with the query builders and pagination libraries
  """
  alias Forage.Codec.Exceptions.InvalidAssocError
  alias Forage.Codec.Exceptions.InvalidFieldError
  alias Forage.Codec.Exceptions.InvalidSortDirectionError
  alias Forage.Codec.Exceptions.InvalidPaginationDataError
  alias Forage.ForagePlan

  @type schema() :: atom()
  @type assoc() :: {schema(), atom(), atom()}

  @doc """
  Encodes a params map into a forage plan (`Forage.ForagerPlan`).
  """
  def decode(params, schema) do
    filter = decode_filter(params, schema)
    sort = decode_sort(params, schema)
    pagination = decode_pagination(params, schema)
    %ForagePlan{filter: filter, sort: sort, pagination: pagination}
  end

  @doc """
  Extract and decode the filter filters from the `params` map into a list of filters.

  ## Examples:

  TODO
  """
  def decode_filter(%{"_filter" => filter_data}, schema) do
    decoded_fields =
      for {field_string, %{"op" => op, "val" => val}} <- filter_data do
        field_or_assoc = decode_field_or_assoc(field_string, schema)
        [field: field_or_assoc, operator: op, value: val]
      end

    Enum.sort(decoded_fields)
  end

  def decode_filter(_params, _schema), do: []

  def decode_field_or_assoc(field_string, schema) do
    parts = String.split(field_string, ".")

    case parts do
      [field_name] ->
        field = safe_field_name_to_atom!(field_name, schema)
        {:simple, field}

      [local_name, remote_name] ->
        assoc = safe_field_names_to_assoc!(local_name, remote_name, schema)
        {:assoc, assoc}

      _ ->
        raise ArgumentError, "Invalid field name '#{field_string}'."
    end
  end

  @doc """
  Extract and decode the sort fields from the `params` map into a keyword list.
  To be used with a schema.
  """
  def decode_sort(%{"_sort" => sort}, schema) do
    # TODO: make this more robust
    decoded =
      for {field_name, %{"direction" => direction}} <- sort do
        field_atom = safe_field_name_to_atom!(field_name, schema)
        direction = decode_direction(direction)
        [field: field_atom, direction: direction]
      end

    # Sort the result so that the order is always the same
    Enum.sort(decoded)
  end

  def decode_sort(_params, _schema), do: []

  @doc """
  Extract and decode the sort fields from the `params` map into a keyword list.
  To be used without a schema.
  """
  def decode_sort(%{"_sort" => sort}) do
    # TODO: make this more robust
    decoded =
      for {field_name, %{"direction" => direction}} <- sort do
        field_atom = safe_field_name_to_atom!(field_name)
        direction = decode_direction(direction)
        [field: field_atom, direction: direction]
      end

    # Sort the result so that the order is always the same
    Enum.sort(decoded)
  end

  def decode_sort(_params), do: []

  @doc """
  Extract and decode the pagination data from the `params` map into a keyword list.
  """
  def decode_pagination(%{"_pagination" => pagination}, _schema) do
    decoded_after =
      case pagination["after"] do
        nil -> []
        after_ -> [after: after_]
      end

    decoded_before =
      case pagination["before"] do
        nil -> []
        before -> [before: before]
      end

    decoded_after ++ decoded_before
  end

  def decode_pagination(_params, _schema), do: []

  @spec decode_direction(String.t() | nil) :: atom() | nil
  defp decode_direction("asc"), do: :asc
  defp decode_direction("desc"), do: :desc
  defp decode_direction(nil), do: nil
  defp decode_direction(value), do: raise(InvalidSortDirectionError, value)

  def pagination_data_to_integer!(value) do
    try do
      String.to_integer(value)
    rescue
      ArgumentError -> raise InvalidPaginationDataError, value
    end
  end

  @doc false
  @spec safe_field_names_to_assoc!(String.t(), String.t(), atom()) :: assoc()
  def safe_field_names_to_assoc!(local_name, remote_name, local_schema) do
    local = safe_assoc_name_to_atom!(local_name, local_schema)
    remote_schema = local_schema.__schema__(:association, local).related
    remote = safe_field_name_to_atom!(remote_name, remote_schema)
    {remote_schema, local, remote}
  end

  @doc false
  def remote_schema(local_name, local_schema) do
    local = safe_assoc_name_to_atom!(local_name, local_schema)
    remote_schema = local_schema.__schema__(:association, local).related
    remote_schema
  end

  @doc false
  def remote_schema_and_field_name_as_atom(local_name_as_string, local_schema) do
    local = safe_assoc_name_to_atom!(local_name_as_string, local_schema)
    remote_schema = local_schema.__schema__(:association, local).related
    {remote_schema, local}
  end

  @doc false
  @spec safe_assoc_name_to_atom!(String.t(), schema()) :: atom()
  def safe_assoc_name_to_atom!(assoc_name, schema) do
    # This function performs the dangerous job of turning a string into an atom.
    schema_associations = schema.__schema__(:associations)
    found = Enum.find(schema_associations, fn assoc -> assoc_name == Atom.to_string(assoc) end)

    case found do
      nil ->
        raise InvalidAssocError, {schema, assoc_name}

      _ ->
        found
    end
  end

  @doc false
  @spec safe_field_name_to_atom!(String.t()) :: atom()
  def safe_field_name_to_atom!(field_name) do
    String.to_existing_atom(field_name)
  end

  @doc false
  @spec safe_field_name_to_atom!(String.t(), schema()) :: atom()
  def safe_field_name_to_atom!(field_name, schema) do
    schema_fields = schema.__schema__(:fields)

    try do
      field_name_as_atom = String.to_existing_atom(field_name)
      case field_name_as_atom in schema_fields do
        true ->
          field_name_as_atom

        false ->
          raise InvalidFieldError, {schema, field_name}
      end
    rescue
      _e in ArgumentError ->
        raise InvalidFieldError, {schema, field_name}
    end
  end
end
