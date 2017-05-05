defmodule Exmarketo do
  @moduledoc """
  Documentation for Exmarketo.
  """

  alias Exmarketo.Client
  import Exmarketo.RestUtil
  require Logger

  def get(%Client{} = client, object, params \\ %{}) do
    client
    |> get_json(object, params)
  end

  @spec get_by_page(Client.t, String.t, pid, map) :: any
  def get_by_page(%Client{} = client, object, pid, params \\ %{}) do
    handle_get(client, object, pid, params)
  end

  defp handle_get(%Client{} = client, object, pid, params) do
    client
    |> get_json(object, params)
    |> handle_response(client, object, pid)
  end

  defp get_json(client, object, params) do
    client
    |> rest_get_request(object, params)
    |> elem(1)
    |> Map.get(:body)
    |> Poison.decode!
  end

  defp handle_response(%{"result" => results, "nextPageToken" => next_page_token}, client, object, pid) do
    send(pid, {:has_more, results})
    :timer.sleep(api_throttle_rate())
    Logger.debug("Retrieving next page using token: #{inspect next_page_token}")
    handle_get(client, object, pid, %{nextPageToken: next_page_token})
  end
  defp handle_response(%{"nextPageToken" => next_page_token}, client, "activities/pagingtoken", pid) do
    Logger.debug("Retrieving next page using token: #{inspect next_page_token}")
    handle_get(client, "activities", pid, %{nextPageToken: next_page_token, activityTypeIds: 12})
  end
  defp handle_response(%{"nextPageToken" => next_page_token}, client, object, pid) do
    Logger.debug("Retrieving next page using token: #{inspect next_page_token}")
    handle_get(client, object, pid, %{nextPageToken: next_page_token})
  end
  defp handle_response(%{"result" => results}, _client, object, pid) do
    send(pid, {:last_result, results})
    Logger.info("Retrieval complete for object: #{inspect object}")
  end

  defp api_throttle_rate(), do: Application.get_env(:exmarketo, :api_throttle_rate, 250)
end
