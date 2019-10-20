# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/recursion.html)

## Recursion

### Loops through recursion

Due to immutability, loops in Elixir (as in any functional programming language) are written differently from imperative languages. For example, in an imperative language like C, one would write:

```sh
for(i = 0; i < sizeof(array); i++) {
  array[i] = array[i] * 2;
}
```

In the example above, we are mutating both the array and the variable i. Mutating is not possible in Elixir. Instead, functional languages rely on recursion: a function is called recursively until a condition is reached that stops the recursive action from continuing. No data is mutated in this process.

```sh
$ elixir recursion.exs
Hello!
Hello!
Hello!

```

### Reduce and map algorithms

```sh
$ elixir recursion-2-reduce.exs
6
```

Recursion and tail call optimization are an important part of Elixir and are commonly used to create loops. However, when programming in Elixir you will rarely use recursion as above to manipulate lists.

The Enum module, which we’re going to see in the next chapter, already provides many conveniences for working with lists.

```sh
$ iex

iex(1)> Enum.reduce([1, 2, 3], 0, fn(x, acc) -> x + acc end)
6
iex(2)> Enum.map([1, 2, 3], fn(x) -> x * 2 end)
[2, 4, 6]

# Using the capture syntax
iex(3)> Enum.reduce([1, 2, 3], 0, &+/2)
6
iex(4)> Enum.map([1, 2, 3], &(&1 * 2))
[2, 4, 6]

```
