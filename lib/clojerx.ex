defmodule Clojerx do
  @moduledoc """
  Documentation for `Clojerx`.
  """

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    deps_edn = Keyword.get(opts, :deps, [])
    module = __CALLER__.module |> Module.split() |> List.last()
    clj_dir = Path.join(Path.dirname(__CALLER__.file), module)
    clj_ns = module
    output_jar = Clojerx.ensure_jar_path(otp_app, clj_ns)

    quote do
      @clojerx_otp_app unquote(otp_app)
      @clojerx_clj_dir unquote(clj_dir)
      @clojerx_clj_ns unquote(clj_ns)
      @clojerx_output_jar unquote(output_jar)
      @clojerx_deps unquote(deps_edn)
      @clojerx_default_opts %{
        otp_app: @clojerx_otp_app,
        clj_dir: @clojerx_clj_dir,
        clj_ns: @clojerx_clj_ns,
        output_jar: @clojerx_output_jar,
        deps: @clojerx_deps
      }
      @before_compile Clojerx.Compiler

      def start_link(_opts) do
        Clojerx.CNode.start_link(@clojerx_default_opts)
      end

      def child_spec(_opts) do
        Clojerx.CNode.child_spec(@clojerx_default_opts)
      end

      def call(srv, fun, args) when is_atom(fun) and is_list(args) do
        Clojerx.CNode.call(srv, fun, args)
      end

      def __clojerx__, do: @clojerx_default_opts
    end
  end

  # HOW to make private?
  def ensure_jar_path(otp_app, clj_ns) do
    jar_dir =
      otp_app
      |> :code.lib_dir()
      |> Path.join("priv")

    File.mkdir_p!(jar_dir)

    Path.join(jar_dir, "#{clj_ns}.jar")
  end
end
