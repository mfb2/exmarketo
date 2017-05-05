defmodule Exmarketo.PageHandler do
  alias Exmarketo.PageHandler

  @callback handle_data(any, any) :: {:noreply, any}
  @callback handle_last_result(any, any) :: {:noreply, any}

  defmacro __using__(_env) do
    quote(location: :keep) do
      @behaviour PageHandler
      def handle_info({:has_more, data}, state) do
        handle_data(data, state)
      end
      def handle_info({:last_result, data}, state) do
        handle_last_result(data, state)
      end
    end
  end
end
