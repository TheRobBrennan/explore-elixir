# Similar to case, a function may have many clauses. A particular clause is executed when the arguments passed to the function match the clause’s argument patterns and its guard evaluates to true
# When print_multiple_times/2 is initially called, the argument n is equal to 3
# The first clause has a guard which says “use this definition if and only if n is less than or equal to 1”. Since this is not the case, Elixir proceeds to the next clause’s definition.
# The second definition matches the pattern and has no guard so it will be executed. It first prints our msg and then calls itself passing n - 1 (2) as the second argument.
# Our msg is printed and print_multiple_times/2 is called again, this time with the second argument set to 1. Because n is now set to 1, the guard in our first definition of print_multiple_times/2 evaluates to true, and we execute this particular definition. The msg is printed, and there is nothing left to execute.
# We defined print_multiple_times/2 so that, no matter what number is passed as the second argument, it either triggers our first definition (known as a base case) or it triggers our second definition, which will ensure that we get exactly one step closer to our base case.

defmodule Recursion do
  # Here is where we stop recursively calling print_multiple_times
  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  # Recursively call print_multiple_times
  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end
end

Recursion.print_multiple_times("Hello!", 3)
# Hello!
# Hello!
# Hello!
