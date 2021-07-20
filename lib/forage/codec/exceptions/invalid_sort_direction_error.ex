defmodule Forage.Codec.Exceptions.InvalidSortDirectionError do
  defexception [:message]

  @impl true
  def exception(direction) do
    msg = """
    #{inspect direction} is not a valid sorting direction. \
    Valid sort directions are: ["asc", "desc"].\
    """
    %__MODULE__{message: msg}
  end
end