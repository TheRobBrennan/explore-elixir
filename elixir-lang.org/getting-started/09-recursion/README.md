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
