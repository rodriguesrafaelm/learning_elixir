# defmodule PledgeServerTest do
#   use ExUnit.Case

#   alias Servy.PledgeServer

# test "Armazena os 3 pledges mais recentes e mostra seu total" do
#   PledgeServer.start()

#   PledgeServer.create_pledge("pessoa1", 10)
#   PledgeServer.create_pledge("pessoa2", 20)
#   PledgeServer.create_pledge("pessoa3", 30)
#   PledgeServer.create_pledge("pessoa4", 40)
#   PledgeServer.create_pledge("pessoa5", 50)

#   most_recent_pledges = [{"pessoa5", 50},{"pessoa4", 40},{"pessoa3", 30}]

#   assert PledgeServer.recent_pledges() == most_recent_pledges

#   assert PledgeServer.total_pledged() == 120

# end

# end
