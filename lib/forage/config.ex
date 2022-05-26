defmodule Forage.Config do
  @moduledoc false

  def messages_module() do
    Application.get_env(:forage, :messages, Forage.DefaultMessages)
  end
end
