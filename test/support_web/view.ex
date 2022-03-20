defmodule Forage.Test.SupportWeb.Org.EmployeeView do
  use ForageWeb.ForageView,
    routes_module: Forage.Test.SupportWeb.Router.Helpers,
    error_helpers_module: Forage.Test.Support.ErrorHelpers,
    prefix: :org_employee
end
