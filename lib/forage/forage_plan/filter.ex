defmodule Forage.ForagePlan.Filter do
  defstruct field: nil,
            operator: nil,
            value: nil

  @type t :: %__MODULE__{}
end
