defmodule PMBackendTTest do
  use ExUnit.Case
  doctest PMBackend

  test "greets the world" do
    assert PMBackend.hello() == :world
  end
end
