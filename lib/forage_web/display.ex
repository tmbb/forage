defprotocol ForageWeb.Display do
  @doc """
  Displays the model as plaintext.

  This is meant to be used to diplay options in a select widget and
  when you want to show the user a resource as HTML.
  """
  def as_text(model)
  def as_html(model)
end
