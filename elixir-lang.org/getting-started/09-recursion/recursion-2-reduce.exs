# We will try each clause until we find one that matches according to the pattern matching rules. In this case, the list [1, 2, 3] matches against [head | tail] which binds head to 1 and tail to [2, 3]; accumulator is set to 0.

# Then, we add the head of the list to the accumulator head + accumulator and call sum_list again, recursively, passing the tail of the list as its first argument. The tail will once again match [head | tail] until the list is empty, as seen below

# Note that we are reducing a list to one value

defmodule Math do
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end

# We invoke sum_list with the list [1, 2, 3] and the initial value 0 as arguments.
IO.puts Math.sum_list([1, 2, 3], 0) #=> 6
# sum_list [1, 2, 3], 0
# sum_list [2, 3], 1
# sum_list [3], 3
# sum_list [], 6
