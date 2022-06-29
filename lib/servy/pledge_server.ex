defmodule Servy.PledgeServer do
  def create_pledge(name, amount) do
    {:ok, id} = send_pledge_to_service(name, amount)

    [{"pedro", 10}]

  end

  defp recent_pledges do
    # Retorna as 3 mais recentes.
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
