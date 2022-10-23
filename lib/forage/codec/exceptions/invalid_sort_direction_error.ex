defmodule Forage.Codec.Exceptions.InvalidSortDirectionError do
  @moduledoc """
  An invalid sort direction was used.
  Valid sort directions are `"asc"` and `"desc"`.
  """
  defexception [:message]

  @impl true
  def exception(direction) do
    msg = """
    #{inspect(direction)} is not a valid sorting direction. \
    Valid sort directions are: ["asc", "desc"].\
    """

    %__MODULE__{message: msg}
  end
end
