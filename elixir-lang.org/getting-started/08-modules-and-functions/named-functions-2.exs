defmodule Math do
  # The trailing question mark in zero? means that this function returns a boolean; see Naming Conventions.
  def zero?(0) do
    true
  end

  # The trailing question mark in zero? means that this function returns a boolean; see Naming Conventions.
  def zero?(x) when is_integer(x) do
    false
  end
end

IO.puts Math.zero?(0)         #=> true
IO.puts Math.zero?(1)         #=> false
IO.puts Math.zero?([1, 2, 3]) #=> ** (FunctionClauseError)
IO.puts Math.zero?(0.0)       #=> ** (FunctionClauseError)
