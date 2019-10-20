defmodule Math do
  def zero?(0), do: true
  def zero?(x) when is_integer(x), do: false

  def sum(a,b) do
    a + b
  end
end

IO.puts Math.sum(1,2)
