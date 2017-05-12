defmodule Exmarketo do
  alias Exmarketo.Client
  alias Exmarketo.Communicator

  @moduledoc """
  Documentation for Exmarketo.
  """

  @doc """
  Performs a single 'GET' request to the Marketo REST API.

  Returns a map representing the JSON content returned from Marketo.

  ## Arguments

    * `client` - the Marketo client.

    * `object` - Object to be requested from Marketo.

    * `params` - Parameters to be provided to the API call.
    Must conform to header parameters as dictated by the Marketo
    REST API spec.

  ## Examples

      iex> Exmarketo.get(Exmarketo.Client.new(), "campaigns", %{})
      %{result: %{...}}

  """
  def get(%Client{} = client, object, params \\ %{}) do
    Communicator.get(client, object, params)
  end

  @doc """
  Performs multiple 'GET' requests to the Marketo REST API.  Results
  are sent back to the `pid` provided to the method via messaging.

  The `pid` provided must conform to the Exmarketo.PageHandler callbacks.
  A GenServer that can handle these callbacks may be a good place to start.

  ## Arguments

    * `client` - the Marketo client.

    * `object` - Object to be requested from Marketo.

    * `pid`    - Process ID of the `Exmarketo.PageHandler`-compliant handler
    that will handle pages retrieved from Marketo.

    * `params` - Parameters to be provided to the API call.
    Must conform to header parameters as dictated by the Marketo
    REST API spec.

  ## Examples

      iex> Exmarketo.get_by_page(Exmarketo.new(), "campaigns", pid, %{})
      :ok

  """
  @spec get_by_page(Client.t, String.t, pid, map) :: :ok
  def get_by_page(%Client{} = client, object, pid, params \\ %{}) do
    Communicator.get_by_page(client, object, pid, params)
  end

  @doc """
  Performs multiple 'GET' requests to the Marketo REST API.  Method
  returns all data retrieved from Marketo.  NOTE!  This should not
  be called for large datasets as it may consume all available memory.

  ## Arguments

    * `client` - the Marketo client.

    * `object` - Object to be requested from Marketo.

    * `params` - Parameters to be provided to the API call.
    Must conform to header parameters as dictated by the Marketo
    REST API spec.

  ## Examples
      iex> Exmarketo.get_all(Exmarketo.Client.new(), "activities", %{nextPageToken: token})
      %{result: %{...}, ...}
  """
  @spec get_all(Client.t, String.t, map) :: map
  def get_all(%Client{} = client, object, params \\ %{}) do
    Communicator.get_all(client, object, params)
  end
end
