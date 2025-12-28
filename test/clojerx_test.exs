defmodule ClojerxTest do
  use ExUnit.Case

  defmodule MinimalExample do
    use Clojerx, otp_app: :clojerx
  end

  setup_all do
    {:ok, _pid} = Node.start(:clojerx_test, :shortnames, 5000)
    cnode = start_supervised!(MinimalExample)
    {:ok, cnode: cnode}
  end

  test "module dependencies" do
    defmodule MinimalExampleShare do
      use Clojerx,
        otp_app: :clojerx,
        deps: [
          {:"clojure.java-time/clojure.java-time", {:"mvn/version", "1.4.3"}}
        ]
    end

    defmodule MinimalExampleRoot do
      use Clojerx,
        otp_app: :clojerx,
        deps: [
          MinimalExampleShare
        ]
    end

    cnode = start_supervised!(MinimalExampleRoot)

    assert MinimalExampleRoot.call(cnode, :"first-month-of-year", [2022]) == 1
  end

  test "allow clojure dependencies" do
    defmodule MinimalExampleDependencies do
      use Clojerx,
        otp_app: :clojerx,
        deps: [
          {:"clojure.java-time/clojure.java-time", {:"mvn/version", "1.4.3"}}
        ]
    end

    cnode = start_supervised!(MinimalExampleDependencies)

    app_dir = MinimalExampleDependencies.__clojerx__() |> Map.fetch!(:clj_dir)
    deps_edn = File.read!(Path.join(app_dir, "deps.edn"))

    assert deps_edn =~ ~s(clojure.java-time/clojure.java-time {:mvn/version "1.4.3"})

    assert MinimalExampleDependencies.call(cnode, :"first-month-of-year", [2022]) == 1
  end

  test "cnode filelayout", %{cnode: _cnode} do
    app_dir = MinimalExample.__clojerx__() |> Map.fetch!(:clj_dir)

    # same as module
    assert File.exists?(Path.join(app_dir, "src/MinimalExample.clj"))
    assert File.exists?(Path.join(app_dir, "build.clj"))
    assert File.exists?(Path.join(app_dir, "deps.edn"))
  end

  test "cnode", %{cnode: cnode} do
    assert MinimalExample.call(cnode, :sum, [1, 2]) == 3
  end

  test "cnode clojerx" do
    defmodule MinimalExampleClojerx do
      use Clojerx,
        otp_app: :clojerx,
        deps: [Clojerx.Clojure]
    end

    cnode = start_supervised!(MinimalExampleClojerx)

    assert MinimalExampleClojerx.call(cnode, :sum, [1, 2]) == 3
  end
end
