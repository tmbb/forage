defmodule Forage.Test.ForageWeb.ForageViewTest do
  use ExUnit.Case, async: true
  alias ForageWeb.ForageView

  # Get a view build using `use ForageWeb.ForageView` so we can test
  # the automatically defined callbacks
  alias Forage.Test.SupportWeb.Org.EmployeeView
  alias Forage.Test.SupportWeb.Router

  defp test_conn(params \\ %{}) do
    Plug.Test.conn(:get, "/", params)
  end

  def to_html(rendered) do
    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> to_string()
  end

  describe "sort_link widget:" do
    test "MyView.resource_sort_link/4 is equivalent to ForageView.forage_sort_link/6 (default direction)" do
      conn = test_conn()

      safe_html4 =
        EmployeeView.org_employee_sort_link(
          conn,
          :name,
          "Name",
          []
        )

      safe_html6 =
        ForageView.forage_sort_link(
          conn,
          Router.Helpers,
          :org_employee_path,
          :name,
          "Name",
          []
        )

      assert safe_html4 == safe_html6
    end

    test "MyView.resource_sort_link/4 is equivalent to ForageView.forage_sort_link/6 (specified direction)" do
      for direction <- ["asc", "desc"] do
        conn_with_direction =
          test_conn(%{
            "_sort" => %{
              "name" => %{
                "direction" => direction
              }
            }
          })

        safe_html4 =
          EmployeeView.org_employee_sort_link(
            conn_with_direction,
            :name,
            "Name",
            []
          )

        safe_html6 =
          ForageView.forage_sort_link(
            conn_with_direction,
            Router.Helpers,
            :org_employee_path,
            :name,
            "Name",
            []
          )

        assert safe_html4 == safe_html6
      end
    end

    test "sanity check on MyView.resource_sort_link/4 - default direction is :desc" do
      conn = test_conn()

      safe_html_no_opts = EmployeeView.org_employee_sort_link(conn, :name, "Name")
      safe_html = EmployeeView.org_employee_sort_link(conn, :name, "Name", [])
      # Can be called without opts
      assert safe_html_no_opts == safe_html

      html = to_html(safe_html)

      {:ok, doc} = Floki.parse_fragment(html)

      assert [_a] = Floki.find(doc, "a")

      # The sort direction in the link will be the opposite of the current
      # sort direction (i.e. the link works as a toggle)
      [href] = Floki.attribute(doc, "a", "href")
      assert href =~ ~S(/org/employee?_sort[name][direction]=desc)
      a_text = Floki.find(doc, "a") |> Floki.text()
      assert a_text =~ "Name"
      refute a_text =~ "↓"
      refute a_text =~ "↑"
    end

    test "sanity check on MyView.resource_sort_link/4 - :asc" do
      conn =
        test_conn(%{
          "_sort" => %{
            "name" => %{
              "direction" => "asc"
            }
          }
        })

      safe_html = EmployeeView.org_employee_sort_link(conn, :name, "Name", [])

      html = to_html(safe_html)

      {:ok, doc} = Floki.parse_fragment(html)

      assert [_a] = Floki.find(doc, "a")

      [href] = Floki.attribute(doc, "a", "href")
      assert href =~ ~S(/org/employee?_sort[name][direction]=desc)
      assert Floki.find(doc, "a") |> Floki.text() =~ "\u00A0↓"
    end

    test "sanity check on MyView.resource_sort_link/4 - :desc" do
      conn =
        test_conn(%{
          "_sort" => %{
            "name" => %{
              "direction" => "desc"
            }
          }
        })

      safe_html = EmployeeView.org_employee_sort_link(conn, :name, "Name", [])

      html = to_html(safe_html)

      {:ok, doc} = Floki.parse_fragment(html)

      assert [_a] = Floki.find(doc, "a")

      # The sort direction in the link will be the opposite of the current
      # sort direction (i.e. the link works as a toggle)
      [href] = Floki.attribute(doc, "a", "href")
      assert href =~ ~S(/org/employee?_sort[name][direction]=asc)
      assert Floki.find(doc, "a") |> Floki.text() =~ "\u00A0↑"
    end
  end
end
