# defmodule Forage.Test.Forage.FilterTest do
#   use ExUnit.Case, async: true
#   alias Forage.QueryBuilder
#   alias Forage.Codec.Decoder

#   alias Forage.Test.Support.PrimarySchema

#   test "xxx" do
#     encoded_filters = %{
#       "string_field" => %{
#         "op" => "contains",
#         "val" => "s1"
#       },
#       "owner.remote_string_field" => %{
#         "op" => "contains",
#         "val" => "s2"
#       }
#     }

#     params = %{
#       "_sort" => %{},
#       "_pagination" => %{},
#       "_filter" => encoded_filters
#     }

#     decoded = Decoder.decode(params, PrimarySchema)

#     {plan, query} = QueryBuilder.build_plan_and_query(params, PrimarySchema)

#     IO.inspect(query)
#   end
# end
