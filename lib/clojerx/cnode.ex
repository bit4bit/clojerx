defmodule Clojerx.CNode do
  @moduledoc """
  Documentation for `CNode`.
  """

  defmodule CNodeError do
    defexception [:message]
  end

  use GenServer

  def start_link(opts) when is_map(opts) do
    GenServer.start_link(Clojerx.CNode, opts)
  end

  def call(srv, fun, args) do
    GenServer.call(srv, {:call, fun, args})
  end

  @impl true
  def init(opts) do
    clj_dir = Map.fetch!(opts, :clj_dir)
    clj_ns = Map.fetch!(opts, :clj_ns)
    output_jar = Map.fetch!(opts, :output_jar)
    cnode = clojerx_node(clj_ns)

    port = execute_clojure(clj_dir, output_jar)
    Port.monitor(port)

    case wait_for_node(clojerx_node(clj_ns), 5000) do
      {:error, :timeout} ->
        raise CNodeError,
          message:
            "Node not available: #{cnode}. Verify that epmd is running and that the current BEAM VM is running as a distributed node."

      _ ->
        :ok
    end

    clojerx_dest = {:"#{clj_ns}", cnode}
    send(clojerx_dest, {:clojerx, make_ref(), self(), :link, {}})

    {:ok,
     %{
       clojerx_dir: clj_dir,
       clojure_port: port,
       clojerx_node: cnode,
       clojerx_dest: clojerx_dest,
       clojerx_jar: output_jar
     }}
  end

  defp clojerx_node(clj_ns) do
    [_name, domain] = Node.self() |> to_string() |> String.split("@", parts: 2)
    :"#{clj_ns}@#{domain}"
  end

  defp execute_clojure(clj_dir, output_jar) do
    java_path = System.find_executable("java")

    if is_nil(java_path) do
      raise CNodeError, message: "java executable not found"
    end

    Port.open(
      {:spawn_executable, java_path},
      [
        :nouse_stdio,
        :binary,
        cd: clj_dir,
        args: ["-jar", output_jar]
      ]
    )
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
  def handle_call({:call, fun, args}, from, state) do
    send(state.clojerx_dest, {:clojerx, from, self(), fun, List.to_tuple(args)})
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

  # TODO: verify fun_name
  def handle_info({:clojerx, from, fun_name, result}, state) do
    IO.inspect(result, label: "Result #{fun_name}")
    GenServer.reply(from, result)
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :port, _, reason}, state) do
    IO.inspect(reason)
    {:stop, reason, state}
  end

  @impl true
  def terminate(_reason, %{clojure_port: port}) do
    if not is_nil(Port.info(port)) do
      Port.close(port)
    end

    :ok
  end
end
