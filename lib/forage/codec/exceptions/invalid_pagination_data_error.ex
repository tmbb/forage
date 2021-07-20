defmodule Forage.Codec.Exceptions.InvalidPaginationDataError do
  defexception [:message]

  @impl true
  def exception(value) do
    msg = """
    Pagination data (page number or page size) must parse to an integer. \
    Got #{inspect value}.
    """
    %__MODULE__{message: msg}
  end
end