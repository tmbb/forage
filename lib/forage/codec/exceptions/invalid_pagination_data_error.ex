defmodule Forage.Codec.Exceptions.InvalidPaginationDataError do
  @moduledoc """
  Invalid pagination data was used.
  """
  defexception [:message]

  @impl true
  def exception(value) do
    msg = """
    Pagination data (page number or page size) must parse to an integer. \
    Got #{inspect(value)}.
    """

    %__MODULE__{message: msg}
  end
end
