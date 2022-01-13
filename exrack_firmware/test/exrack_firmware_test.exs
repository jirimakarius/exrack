defmodule ExRackTest do
  use ExUnit.Case
  doctest ExRack

  test "greets the world" do
    assert ExRack.hello() == :world
  end
end
