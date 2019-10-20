# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/enumerables-and-streams.html)

## Enumerables and Streams

### Enumerables

```sh
# Elixir provides the concept of enumerables and the Enum module to work with them. We have already learned two enumerables: lists and maps.
iex(1)> Enum.map([1, 2, 3], fn x -> x * 2 end)
[2, 4, 6]
iex(2)> Enum.map(%{1 => 2, 3 => 4}, fn {k, v} -> k * v end)
[2, 12]

# The Enum module provides a huge range of functions to transform, sort, group, filter and retrieve items from enumerables. It is one of the modules developers use frequently in their Elixir code.

# Elixir also provides ranges
iex(3)> Enum.map(1..3, fn x -> x * 2 end)
[2, 4, 6]
iex(4)> Enum.reduce(1..3, 0, &+/2)
6
```

The functions in the Enum module are limited to, as the name says, enumerating values in data structures. For specific operations, like inserting and updating particular elements, you may need to reach for modules specific to the data type. For example, if you want to insert an element at a given position in a list, you should use the List.insert_at/3 function from the List module, as it would make little sense to insert a value into, for example, a range.

We say the functions in the Enum module are polymorphic because they can work with diverse data types. In particular, the functions in the Enum module can work with any data type that implements the Enumerable protocol. We are going to discuss Protocols in a later chapter; for now we are going to move on to a specific kind of enumerable called a stream.

### Eager vs Lazy

```sh
# All the functions in the Enum module are eager. Many functions expect an enumerable and return a list back
iex(6)> odd? = &(rem(&1, 2) != 0)
#Function<7.126501267/1 in :erl_eval.expr/5>
iex(7)> Enum.filter(1..3, odd?)
[1, 3]

# This means that when performing multiple operations with Enum, each operation is going to generate an intermediate list until we reach the result. This example has a pipeline of operations. We start with a range and then multiply each element in the range by 3. This first operation will now create and return a list with 100_000 items. Then we keep all odd elements from the list, generating a new list, now with 50_000 items, and then we sum all entries.
iex(8)> total_sum = 1..100_000 |> Enum.map(&(&1 * 3)) |> Enum.filter(odd?) |> Enum.sum
7500000000

```

### The pipe operator

The |> symbol used in the snippet above is the pipe operator: it takes the output from the expression on its left side and passes it as the first argument to the function call on its right side. It’s similar to the Unix | operator. Its purpose is to highlight the data being transformed by a series of functions. To see how it can make the code cleaner, have a look at the example above rewritten without using the |> operator:

```sh
iex(9)> Enum.sum(Enum.filter(Enum.map(1..100_000, &(&1 * 3)), odd?))
7500000000

```

### Streams

```sh
# As an alternative to Enum, Elixir provides the Stream module which supports lazy operations. Streams are lazy, composable enumerables.
iex(10)> 1..100_000 |> Stream.map(&(&1 * 3)) |> Stream.filter(odd?) |> Enum.sum
7500000000

# In the example above, 1..100_000 |> Stream.map(&(&1 * 3)) returns a data type, an actual stream, that represents the map computation over the range 1..100_000
iex(11)> 1..100_000 |> Stream.map(&(&1 * 3))
#Stream<[enum: 1..100000, funs: [#Function<49.119101820/1 in Stream.map/2>]]>

# Furthermore, they are composable because we can pipe many stream operations
iex(12)> 1..100_000 |> Stream.map(&(&1 * 3)) |> Stream.filter(odd?)
#Stream<[
  enum: 1..100000,
  funs: [#Function<49.119101820/1 in Stream.map/2>,
   #Function<41.119101820/1 in Stream.filter/2>]
]>
```

Instead of generating intermediate lists, streams build a series of computations that are invoked only when we pass the underlying stream to the Enum module. Streams are useful when working with large, possibly infinite, collections.

Many functions in the Stream module accept any enumerable as an argument and return a stream as a result. It also provides functions for creating streams. For example, Stream.cycle/1 can be used to create a stream that cycles a given enumerable infinitely. Be careful to not call a function like Enum.map/2 on such streams, as they would cycle forever:

```sh
iex(13)> stream = Stream.cycle([1, 2, 3])
#Function<65.119101820/2 in Stream.unfold/2>
iex(14)> Enum.take(stream, 10)
[1, 2, 3, 1, 2, 3, 1, 2, 3, 1]

# On the other hand, Stream.unfold/2 can be used to generate values from a given initial value
iex(16)> stream = Stream.unfold("hełło", &String.next_codepoint/1)
#Function<65.119101820/2 in Stream.unfold/2>
iex(17)> Enum.take(stream, 3)
["h", "e", "ł"]
```

Another interesting function is `Stream.resource/3` which can be used to wrap around resources, guaranteeing they are opened right before enumeration and closed afterwards, even in the case of failures. For example, we can use it to stream a file:

```sh
iex> stream = File.stream!("path/to/file")
%File.Stream{
  line_or_bytes: :line,
  modes: [:raw, :read_ahead, :binary],
  path: "path/to/file",
  raw: true
}
iex> Enum.take(stream, 10)  # Fetches the first ten (10) lines of the file you selected
# NOTE: This could be useful for processing extremely large files or slow network resources
```

The amount of functionality in the Enum and Stream modules can be daunting at first, but you will get familiar with them case by case. In particular, focus on the Enum module first and only move to Stream for the particular scenarios where laziness is required, to either deal with slow resources or large, possibly infinite, collections.

Next, we’ll look at a feature central to Elixir, Processes, which allows us to write concurrent, parallel and distributed programs in an easy and understandable way.
