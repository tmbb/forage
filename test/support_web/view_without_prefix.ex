defmodule Forage.Test.SupportWeb.Org.EmployeeViewWithoutPrefix do
  @moduledoc """
  Using ForageWeb.ForageView without a prefix won't raise an error.
  """

  use ForageWeb.ForageView,
    routes_module: Forage.Test.SupportWeb.Router.Helpers,
    error_helpers_module: Forage.Test.Support.ErrorHelpers,
    prefix: nil
end
