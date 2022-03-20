defmodule Forage.Test.SupportWeb.Router do
  use Phoenix.Router

  scope "/org", Forage.Test.SupportWeb.Org, as: :org do
    get("/benefit/select", EmployeeController, :select)
    resources("/benefit", EmployeeController)
  end
end
