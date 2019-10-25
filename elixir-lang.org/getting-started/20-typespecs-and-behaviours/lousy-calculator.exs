# As you can see in the example, tuples are a compound type and each tuple is identified by the types inside it. To understand why String.t is not written as string, have another look at the typespecs docs.
# defmodule LousyCalculator do
#   @spec add(number, number) :: {number, String.t}
#   def add(x, y), do: {x + y, "You need a calculator to do that?!"}

#   @spec multiply(number, number) :: {number, String.t}
#   def multiply(x, y), do: {x * y, "Jeez, come on!"}
# end

# Defining function specs this way works, but it quickly becomes annoying since we’re repeating the type {number, String.t} over and over. We can use the @type directive in order to declare our own custom type.
defmodule LousyCalculator do
  @typedoc """
  Just a number followed by a string.
  """
  @type number_with_remark :: {number, String.t}

  @spec add(number, number) :: number_with_remark
  def add(x, y), do: {x + y, "You need a calculator to do that?"}

  @spec multiply(number, number) :: number_with_remark
  def multiply(x, y), do: {x * y, "It is like addition on steroids."}
end
