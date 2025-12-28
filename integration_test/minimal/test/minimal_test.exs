defmodule MinimalTest do
  use ExUnit.Case

  test "call" do
    {:ok, _pid} = Node.start(:minimal, :shortnames, 5000)
    cnode = start_supervised!(Minimal)
    assert Minimal.call(cnode, :sum, [1, 2]) == 3
  end
end
