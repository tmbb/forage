defmodule Forage.Test.SupportWeb.Router do
  use Phoenix.Router

  scope "/org", Forage.Test.SupportWeb.Org, as: :org do
    get("/employee/select", EmployeeController, :select)
    resources("/employee", EmployeeController)
  end
end
