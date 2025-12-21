defmodule Clojerx do
  @moduledoc """
  Documentation for `Clojerx`.
  """

  defmodule Compiler do
    defmacro __before_compile__(env) do
      %{file: file} = env
      _code_dir = Path.dirname(file)

      quote do
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      use GenServer

      @before_compile Clojerx.Compiler

      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, opts)
      end

      def call(srv, :sum, args) do
        GenServer.call(srv, {:sum, args})
      end

      @impl true
      def init(_opts) do
        clojure_path = System.find_executable("clojure")

        port =
          Port.open({:spawn_executable, clojure_path},
            [
            :nouse_stdio,
            :binary,
              cd: "test/MinimalExample",
              args: ["-M", "-m", "MinimalExample"]
            ]
          )

        Port.monitor(port)
        case wait_for_node(:MinimalExample@tere, 1000) do
            {:error, :timeout} ->
              raise "Node not available MinimalExample@tere"
            _ ->
              :ok
        end

        send({:MinimalExample, :MinimalExample@tere}, {:clojerx, make_ref(), self(), :link, {}})

        {:ok, %{clojure_port: port}}
      end

      defp wait_for_node(_node_name, timeout) when timeout <= 0, do: {:error, :timeout}
      defp wait_for_node(node_name, timeout) do
        case Node.ping(node_name) do
          :pong ->
            :ok
          _ ->
            Process.sleep(100)
            wait_for_node(node_name, timeout - 100)
        end
      end
      @impl true
      def handle_call({:sum, [a, b]}, from, state) do
        send({:MinimalExample, :MinimalExample@tere}, {:clojerx, from, self(), :sum, {a, b}})
        {:noreply, state}
      end

      @impl true
      def handle_info({_, {:data, out}}, state) do
        IO.inspect(out)
        {:noreply, state}
      end

      @impl true
      def handle_info({:clojerx, _ref, :link}, state) do
        {:noreply, state}
      end

      def handle_info({:clojerx, from, :sum, result}, state) do
        GenServer.reply(from, result)
        {:noreply, state}
      end

      def handle_info({:DOWN, _, :port, _, reason}, state) do
        IO.inspect(reason)
        {:stop, reason, state}
      end

      @impl true
      def terminate(_reason, %{clojure_port: port}) do
        Port.close(port)
        :ok
      end
    end
  end
end
