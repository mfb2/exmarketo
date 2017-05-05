defmodule Exmarketo.Client do
  alias Exmarketo.Client
  import Exmarketo.RestUtil
  require Logger

  @type t :: %Client{}

  @enforce_keys [:endpoint, :access_token]
  defstruct [:endpoint, :access_token]

  def new() do
    access_token = HTTPoison.request(:get, identity_url())
    |> elem(1)
    |> Map.get(:body)
    |> Poison.decode!
    |> Map.get("access_token")

    %Client{
      endpoint: endpoint(),
      access_token: access_token
    }
  end
end
