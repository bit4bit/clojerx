defmodule Clojerx.Compiler do
  @moduledoc false

  defmacro __before_compile__(%{module: module}) do
    clj_dir = Module.get_attribute(module, :clojerx_clj_dir)
    clj_ns = Module.get_attribute(module, :clojerx_clj_ns)
    output_jar = Module.get_attribute(module, :clojerx_output_jar)
    deps_edn = Module.get_attribute(module, :clojerx_deps)
    erl_jar = Clojerx.Compiler.ensure_jinterface_jar()
    Clojerx.ClojureProject.ensure_clojure_project(clj_dir, clj_ns)
    Clojerx.ClojureProject.ensure_build_clj(clj_dir, clj_ns, erl_jar, output_jar)
    Clojerx.ClojureProject.ensure_deps_edns(clj_dir, deps_edn)

    Clojerx.Compiler.create_jar(clj_dir)
    quote do
    end
  end

  def ensure_jinterface_jar() do
    otp_release = :erlang.system_info(:otp_release)
    erl_jar = Path.join(:code.priv_dir(:clojerx), "OtpErlang-#{otp_release}.jar")

    if not File.exists?(erl_jar) do
      raise "Erlang JInterface jar not found at #{erl_jar}"
    end

    erl_jar
  end

  def create_jar(clj_dir) do
    clojure_path = System.find_executable("clojure")

    if is_nil(clojure_path) do
      raise "Clojure executable not found"
    end

    {output, exit_code} = System.cmd(clojure_path, ["-T:build", "uber"], cd: clj_dir)

    if exit_code != 0 do
      raise "Clojure build for #{clj_dir} failed with exit code #{exit_code}:\n#{output}"
    end
  end
end
