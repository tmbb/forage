defmodule ForageWeb.ForageViewTest do
  use ExUnit.Case, async: true

  defmodule Org.EmployeeView do
    use ForageWeb.ForageView,
      routes_module: Forage.Test.SupportWeb.Router.Helpers,
      error_helpers_module: Forage.Test.Support.ErrorHelpers,
      prefix: :org_employee
  end
end
