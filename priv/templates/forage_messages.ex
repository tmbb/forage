defmodule ApplicationWebModule.ForageMessages do
  @behaviour Forage.Messages

  use ApplicationWebModule.Gettext

  def message("Contains"), do: dgettext("forage.messages", "Contains")
  def message("Equal to"), do: dgettext("forage.messages", "Equal to"
  def message("Starts with"), do: dgettext("forage.messages", "Starts with")
  def message("Ends with"), do: dgettext("forage.messages", "Ends with")
  def message("Greater than"), do: dgettext("forage.messages", "Greater than")
  def message("Less than"), do: dgettext("forage.messages", "Less than")
  def message("Greater than or equal to"), do: dgettext("forage.messages", "Greater than or equal to")
  def message("Less than or equal to"), do: dgettext("forage.messages", "Less than or equal to")
  def message(other), do: other
end
