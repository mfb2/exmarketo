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

    HTTPoison.request(:get, endpoint() <> @rest_url <> "/" <> object <> ".json?" <> query, [], recv_timeout: timeout())
  end

  defp timeout() do
    Application.get_env(:exmarketo, :timeout, 15000)
  end
end
