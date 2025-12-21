defmodule ClojerxTest do
  use ExUnit.Case

  defmodule MinimalExample do
    use Clojerx, otp_app: :clojerx
  end

  test "cnode" do
    {:ok, _pid} = Node.start(:clojerx_test, :shortnames, 5000)

    cnode = start_supervised!(MinimalExample)

    assert MinimalExample.call(cnode, :sum, [1, 2]) == 3
  end
end
