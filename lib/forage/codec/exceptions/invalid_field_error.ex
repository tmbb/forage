defmodule Forage.Codec.Exceptions.InvalidFieldError do
  defexception [:message]

  @impl true
  def exception({schema, field_name}) do
    field_atoms = schema.__schema__(:fields)
    valid_field_names = Enum.map(field_atoms, &Atom.to_string/1)
    msg = """
    #{inspect field_name} is not valid for schema #{inspect schema}. \
    Valid field names are: #{inspect valid_field_names}.\
    """
    %__MODULE__{message: msg}
  end
end