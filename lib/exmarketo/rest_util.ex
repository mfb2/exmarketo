defmodule Exmarketo.RestUtil do
  require Logger

  @rest_url "rest/v1/"
  @identity_url "identity/oauth/token"
  @grant_type "client_credentials"

  def identity_url() do
    endpoint() <> @identity_url <> identity_query()
  end

  def endpoint() do
    Application.get_env(:exmarketo, :endpoint)
  end

  defp client_id() do
    Application.get_env(:exmarketo, :client_id)
  end

  defp client_secret() do
    Application.get_env(:exmarketo, :client_secret)
  end

  defp identity_query() do
    "?" <> URI.encode_query(%{client_id: client_id(), client_secret: client_secret(), grant_type: @grant_type})
  end

  def rest_get_request(client, object, params \\ %{}) do
    query = params
    |> Map.merge(%{access_token: client.access_token})
    |> URI.encode_query

    HTTPoison.get(request_url(object, query), [], [recv_timeout: timeout(), timeout: timeout()])
  end

  defp request_url(object, query), do: endpoint() <> @rest_url <> "/" <> object <> ".json?" <> query
  defp timeout(),                  do: Application.get_env(:exmarketo, :timeout, 15_000)
end
