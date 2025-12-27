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

  test "cnode filelayout", %{cnode: cnode} do
    app_dir = Clojerx.app_dir(cnode)

    # same as module
    assert File.exists?(Path.join(app_dir, "src/MinimalExample.clj"))
    assert File.exists?(Path.join(app_dir, "build.clj"))
    assert File.exists?(Path.join(app_dir, "deps.edn"))
  end

  test "cnode", %{cnode: cnode} do
    assert MinimalExample.call(cnode, :sum, [1, 2]) == 3
  end
end
