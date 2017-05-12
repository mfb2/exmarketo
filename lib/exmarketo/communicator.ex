defmodule Exmarketo.Communicator do
  alias Exmarketo.Client
  import Exmarketo.RestUtil
  require Logger

  def get(%Client{} = client, object, params) do
    client
    |> get_json(object, params)
  end

  @spec get_by_page(Client.t, String.t, pid, map) :: :ok
  def get_by_page(%Client{} = client, object, pid, params) do
    Logger.debug("get_by_page -- params: #{inspect params}")

    client
    |> get_json(object, params)
    |> handle_paged_response(client, object, pid, params)
  end

  @spec get_all(Client.t, String.t, map) :: map
  def get_all(%Client{} = client, object, params) do
    Logger.debug("get_all -- params: #{inspect params}")

    client
    |> get_json(object, params)
    |> handle_response(client, object, params, [])
  end

  defp get_json(client, object, params) do
    Logger.debug("get_json; client: #{inspect client}, object: #{inspect object}, params: #{inspect params}")

    client
    |> rest_get_request(object, params)
    |> case do
      {:error, error} ->
        throw "Request failed: #{inspect error}"
      {:ok, result} ->
        result
      end
    |> Map.get(:body)
    |> Poison.decode!
  end

  defp handle_paged_response(%{"result" => results, "nextPageToken" => next_page_token, "moreResult" => true}, client, object, pid, params) do
    Logger.debug "Handle Response!  params: #{inspect params}"

    send(pid, {:has_more, results})
    sleep()

    Logger.debug("Retrieving next page using token: #{inspect next_page_token}")
    next_params = params
    |> Map.put(:nextPageToken, next_page_token)

    get_by_page(client, object, pid, next_params)
  end
  defp handle_paged_response(%{"result" => results, "moreResult" => false}, _client, object, pid, _params) do
    Logger.debug("Reached last result for object #{inspect object}")

    send(pid, {:last_result, results})
    Logger.info("Retrieval complete for object: #{inspect object}")
  end
  defp handle_paged_response(%{"nextPageToken" => next_page_token} = results, client, object, pid, params) do
    Logger.debug("No results received, got #{inspect results}")
    sleep()

    Logger.debug("Initiating next call with token #{inspect next_page_token}")
    get_by_page(client, object, pid, Map.put(params, :nextPageToken, next_page_token))
  end
  defp handle_paged_response(%{"result" => results}, _client, object, pid, _params) do
    Logger.info("Catch-all handle response --> Retrieval complete for object: #{inspect object}")
    send(pid, {:last_result, results})
  end

  defp handle_response(%{"result" => results, "nextPageToken" => next_page_token, "moreResult" => true}, client, object, params, all_results) do
    Logger.debug "Handle Response!  params: #{inspect params}"
    sleep()

    Logger.debug("Retrieving next page using token: #{inspect next_page_token}")
    next_params = params
    |> Map.put(:nextPageToken, next_page_token)

    client
    |> get_json(object, next_params)
    |> handle_response(client, object, next_params, all_results ++ results)
  end
  defp handle_response(%{"result" => results, "moreResult" => false}, _client, object, _params, all_results) do
    Logger.info("Retrieval complete; reached last result for object #{inspect object}")
    results ++ all_results
  end
  defp handle_response(%{"nextPageToken" => next_page_token} = results, client, object, params, all_results) do
    Logger.debug("No results received, gonna make another call with token #{inspect next_page_token}, here's what we got instead: #{inspect results}")
    sleep()

    next_params = params
    |> Map.put(:nextPageToken, next_page_token)

    client
    |> get_json(object, next_params)
    |> handle_response(client, object, next_params, all_results)
  end
  defp handle_response(%{"result" => results}, _client, object, _params, all_results) do
    Logger.info("Catch-all handle response --> Retrieval complete for object: #{inspect object}")
    results ++ all_results
  end

  defp sleep(), do: :timer.sleep(api_throttle_rate())
  defp api_throttle_rate(), do: Application.get_env(:exmarketo, :api_throttle_rate, 250)
end
