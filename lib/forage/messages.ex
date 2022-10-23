defmodule Forage.Messages do

  @callback message(String.t()) :: String.t()

  def message(message), do: message
end
