defmodule Forage.ForagePlan.Pagination do
  defstruct before: nil,
            after: nil

  @type t :: %__MODULE__{}

  @doc false
  def to_keyword_list(%__MODULE__{} = pagination) do
    after_kw =
      case pagination.after do
        nil -> []
        value -> [after: value]
      end

    before_kw =
      case pagination.before do
        nil -> []
        value -> [before: value]
      end

    after_kw ++ before_kw
  end
end
