defprotocol ForageWeb.Display do
  @doc """
  Displays the model as plaintext.

  This is meant to be used to diplay options in a select widget.
  """
  def display(model)
end
