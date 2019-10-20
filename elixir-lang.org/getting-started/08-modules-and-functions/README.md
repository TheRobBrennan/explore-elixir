# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/modules-and-functions.html)

## Modules and functions

```sh
# In Elixir we group several functions into modules.
iex(1)> String.length("hello")
5

# In order to create our own modules in Elixir, we use the defmodule macro. We use the def macro to define functions in that module
iex(2)> defmodule Math do
...(2)>   def sum(a, b) do
...(2)>     a + b
...(2)>   end
...(2)> end
{:module, Math,
 <<70, 79, 82, 49, 0, 0, 4, 128, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 124,
   0, 0, 0, 14, 11, 69, 108, 105, 120, 105, 114, 46, 77, 97, 116, 104, 8, 95,
   95, 105, 110, 102, 111, 95, 95, 7, 99, ...>>, {:sum, 2}}
iex(3)> Math.sum(1, 2)
3
```

In the following sections, our examples are going to get longer in size, and it can be tricky to type them all in the shell. It’s about time for us to learn how to compile Elixir code and also how to run Elixir scripts.

### Compilation

Let's write a custom `Math` module:

+ Create `math.ex`
+ Compile it with `elixirc math.ex`

This will generate a file named `Elixir.Math.beam` containing the bytecode for the defined module. If we start `iex` again, our module definition will be available (provided that iex is started in the same directory the bytecode file is in)

```sh
iex(1)> Math.sum(1,2)
3
```

Elixir projects are usually organized into three directories:

+ ebin - contains the compiled bytecode
+ lib - contains elixir code (usually .ex files)
+ test - contains tests (usually .exs files)

When working on actual projects, the build tool called `mix` will be responsible for compiling and setting up the proper paths for you. For learning purposes, Elixir also supports a scripted mode which is more flexible and does not generate any compiled artifacts.

### Scripted mode

In addition to the Elixir file extension `.ex`, Elixir also supports `.exs` files for scripting. Elixir treats both files exactly the same way, the only difference is in intention. `.ex` files are meant to be compiled while `.exs` files are used for scripting. When executed, both extensions compile and load their modules into memory, although only `.ex` files write their bytecode to disk in the format of `.beam` files.

+ Create a file called `math.exs`
+ Execute it as `elixir math.exs`

The file will be compiled in memory and executed, printing “3” as the result. No bytecode file will be created. In the following examples, we recommend you write your code into script files and execute them as shown above.

### Named functions

Inside a module, we can define functions with `def/2` and private functions with `defp/2`. A function defined with `def/2` can be invoked from other modules while a private function can only be invoked locally.

```sh
$ elixir named-functions.exs
```

Function declarations also support guards and multiple clauses. If a function has several clauses, Elixir will try each clause until it finds one that matches. Here is an implementation of a function that checks if the given number is zero or not.

```sh
$ elixir named-functions-2.exs
```

Similar to constructs like if, named functions support both do: and do/end block syntax, as we learned do/end is a convenient syntax for the keyword list format. For example, let's look at `named-functions-3.exs`.

```sh
$ elixir named-functions-3.exs
```

You may use `do:` for one-liners but always use `do/end` for functions spanning multiple lines.

### Function capturing

### Default arguments
