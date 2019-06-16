defmodule Forage.Codec.Exceptions.InvalidAssocError do
  defexception [:message]

  @impl true
  def exception({schema, assoc_name}) do
    assoc_atoms = schema.__schema__(:associations)
    valid_assoc_names = Enum.map(assoc_atoms, &Atom.to_string/1)

    msg = """
    #{inspect(assoc_name)} is not valid for schema #{inspect(schema)}. \
    Valid field names are: #{inspect(valid_assoc_names)}.\
    """

    %__MODULE__{message: msg}
  end
end
