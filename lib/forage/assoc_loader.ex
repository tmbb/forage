defmodule Forage.AssocLoader do
  @moduledoc false
  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  def load_assocs(repo, schema, attrs) do
    assoc_fields = schema.__schema__(:associations)

    # Let's process the attrs a little
    attrs_with_assocs =
      for {k, v} <- attrs, into: %{} do
        case string_to_existing_atom(k) do
          {:ok, k_atom} ->
            # We use some heuristics to discover whether a certains field
            # contains a list of raw ids.
            # These heuristics might be invalid!
            # We should have a more robust approach in the future, possibly
            # with namespaces.
            case contains_valid_list_of_raw_ids?(k_atom, v, assoc_fields) do
              true ->
                assoc = schema.__schema__(:association, k_atom)

                # Load the items with those ids from the database:
                # (this is somewhat wasteful, as we don't actually need the full
                # rows from the foreign column, but it's the most "portable" way
                # of getting what we want)
                queryable = assoc.queryable
                items = repo.all(from(u in queryable, where: u.id in ^v))

                # Replace the list of raw ids with actual items from the database
                # so that Ecto will do the right thing.
                # Make it so that the key/field is an atom so that it's easier
                # to deal with the data in the changeset.
                {k, items}

              false ->
                {k, v}
            end

          :error ->
            # Pass the problem a little further up the chain;
            # Ecto will catch this eventually.
            {k, v}
        end
      end

    # Return a new map of attributes ready for Ecto
    attrs_with_assocs
  end

  def put_assoc(changeset, name, attrs) do
    {name_string, maybe_name_atom} = string_and_maybe_atom(name)

    # The nested cases might be complex, but the underlying idea is simple.
    # First we try to find the assoc using the atom as key, then we try
    # to find it using a string as key.
    # In any case, we set the assoc using an atom as key.
    case maybe_name_atom do
      {:ok, name_atom} ->
        case Map.fetch(attrs, name_atom) do
          {:ok, value} ->
            Changeset.put_assoc(changeset, name_atom, value)

          :error ->
            case Map.fetch(attrs, name_string) do
              {:ok, value} ->
                Changeset.put_assoc(changeset, name_atom, value)

              :error ->
                changeset
            end
        end

      :error ->
        changeset
    end
  end

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

  defp contains_valid_list_of_raw_ids?(field_name, values, assoc_fields) do
    field_name in assoc_fields and is_list(values) and Enum.any?(values, fn i -> not is_map(i) end)
  end

  defp string_and_maybe_atom(value) when is_binary(value) do
    {value, string_to_existing_atom(value)}
  end

  defp string_and_maybe_atom(value) when is_atom(value) do
    {Atom.to_string(value), {:ok, value}}
  end
end
