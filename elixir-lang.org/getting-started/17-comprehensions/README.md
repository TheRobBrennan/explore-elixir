# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/comprehensions.html)

## Comprehensions

In Elixir, it is common to loop over an Enumerable, often filtering out some results and mapping values into another list. Comprehensions are syntactic sugar for such constructs: they group those common tasks into the for special form.

```sh
# For example, we can map a list of integers into their squared values:
iex(1)> for n <- [1, 2, 3, 4], do: n * n
[1, 4, 9, 16]
```

A comprehension is made of three parts: generators, filters, and collectables.

### Generators and filters

```sh
# In the expression above, n <- [1, 2, 3, 4] is the generator. It is literally generating values to be used in the comprehension. Any enumerable can be passed on the right-hand side of the generator expression:

# Generator expressions also support pattern matching on their left-hand side; all non-matching patterns are ignored. Imagine that, instead of a range, we have a keyword list where the key is the atom :good or :bad and we only want to compute the square of the :good values
iex(2)> values = [good: 1, good: 2, bad: 3, good: 4]
[good: 1, good: 2, bad: 3, good: 4]
iex(3)> for {:good, n} <- values, do: n * n
[1, 4, 16]

# Alternatively to pattern matching, filters can be used to select some particular elements. For example, we can select the multiples of 3 and discard all others
iex(5)> multiple_of_3? = fn(n) -> rem(n, 3) == 0 end
#Function<7.126501267/1 in :erl_eval.expr/5>
iex(6)> for n <- 0..5, multiple_of_3?.(n), do: n * n
[0, 9]
```

Comprehensions discard all elements for which the filter expression returns false or nil; all other values are selected.

Comprehensions generally provide a much more concise representation than using the equivalent functions from the Enum and Stream modules. Furthermore, comprehensions also allow multiple generators and filters to be given.

Here is an example that receives a list of directories and gets the size of each file in those directories:

```sh
dirs = ['/Users/rob/repos/']
for dir  <- dirs,
    file <- File.ls!(dir),
    path = Path.join(dir, file),
    File.regular?(path) do
  File.stat!(path).size
end
```

Multiple generators can also be used to calculate the cartesian product of two lists:

```sh
iex(3)> for i <- [:a, :b, :c], j <- [1, 2], do:  {i, j}
[a: 1, a: 2, b: 1, b: 2, c: 1, c: 2]
```

Finally, keep in mind that variable assignments inside the comprehension, be it in generators, filters or inside the block, are not reflected outside of the comprehension.

### Bitstring generators

Bitstring generators are also supported and are very useful when you need to comprehend over bitstring streams. The example below receives a list of pixels from a binary with their respective red, green and blue values and converts them into tuples of three elements each:

```sh
iex(5)> pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
<<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
iex(6)> for <<r::8, g::8, b::8 <- pixels>>, do: {r, g, b}
[{213, 45, 132}, {64, 76, 32}, {76, 0, 0}, {234, 32, 15}]
```

A bitstring generator can be mixed with “regular” enumerable generators, and supports filters as well.

### The :into option

In the examples above, all the comprehensions returned lists as their result. However, the result of a comprehension can be inserted into different data structures by passing the :into option to the comprehension.

```sh
# For example, a bitstring generator can be used with the :into option in order to easily remove all spaces in a string:
iex(7)> for <<c <- " hello world ">>, c != ?\s, into: "", do: <<c>>
"helloworld"

# Sets, maps, and other dictionaries can also be given to the :into option. In general, :into accepts any structure that implements the Collectable protocol.

# A common use case of :into can be transforming values in a map, without touching the keys:
iex(9)> for {key, val} <- %{"a" => 1, "b" => 2}, into: %{}, do: {key, val * val}
%{"a" => 1, "b" => 4}

# Let’s make another example using streams. Since the IO module provides streams (that are both Enumerables and Collectables), an echo terminal that echoes back the upcased version of whatever is typed can be implemented using comprehensions

# Now type any string into the terminal and you will see that the same value will be printed in upper-case. Unfortunately, this example also got your IEx shell stuck in the comprehension, so you will need to hit Ctrl+C twice to get out of it. :)
```
