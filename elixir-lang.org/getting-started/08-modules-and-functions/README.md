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

Throughout this tutorial, we have been using the notation name/arity to refer to functions. It happens that this notation can actually be used to retrieve a named function as a function type. Start iex, running the math.exs file defined above:

```sh
$ iex math.exs

iex(1)> Math.zero?(0)
true
iex(2)> fun = &Math.zero?/1
&Math.zero?/1
iex(3)> is_function(fun)
true
iex(4)> fun.(0)
true

# Remember Elixir makes a distinction between anonymous functions and named functions, where the former must be invoked with a dot (.) between the variable name and parentheses. The capture operator bridges this gap by allowing named functions to be assigned to variables and passed as arguments in the same way we assign, invoke and pass anonymous functions.

# Local or imported functions, like is_function/1, can be captured without the module
iex(5)> &is_function/1
&:erlang.is_function/1
iex(6)> (&is_function/1).(fun)
true

# Note the capture syntax can also be used as a shortcut for creating functions
# The &1 represents the first argument passed into the function. &(&1 + 1) is exactly the same as fn x -> x + 1 end. This syntax is useful for short function definitions.
iex(8)> fun = &(&1 + 1)
#Function<7.126501267/1 in :erl_eval.expr/5>
iex(9)> fun.(1)
2

iex(10)> fun2 = &"Good #{&1}"
#Function<7.126501267/1 in :erl_eval.expr/5>
iex(11)> fun2.("morning")
"Good morning"

# If you want to capture a function from a module, you can do &Module.function()
# &List.flatten(&1, &2) is the same as writing fn(list, tail) -> List.flatten(list, tail) end
iex(13)> fun = &List.flatten(&1, &2)
&List.flatten/2
iex(14)> fun.([1, [[2], 3]], [4, 5])
[1, 2, 3, 4, 5]

```

### Default arguments

```sh
# Named functions in Elixir also support default arguments
$ elixir default-arguments.exs

# Any expression is allowed to serve as a default value, but it won’t be evaluated during the function definition. Every time the function is invoked and any of its default values have to be used, the expression for that default value will be evaluated
$ elixirc default-arguments-2.ex
$ iex

iex(1)> DefaultTest.dowork
"hello"
iex(2)> DefaultTest.dowork 123
123
iex(3)> DefaultTest.dowork
"hello"

# If a function with default values has multiple clauses, it is required to create a function head (without an actual body) for declaring defaults
$ elixir default-arguments-3.exs
Hello world
Hello_world
Hello

# When using default values, one must be careful to avoid overlapping function definitions. Consider default-arguments-4.ex
$ elixirc default-arguments-4.ex
warning: this clause cannot match because a previous clause at line 2 always matches
  default-arguments-4.ex:7

$ iex default-arguments-4.ex
# The compiler is telling us that invoking the join function with two arguments will always choose the first definition of join whereas the second one will only be invoked when three arguments are passed
iex(1)> Concat.join "Hello", "world"
***First join
"Helloworld"
iex(2)> Concat.join "Hello", "world", "_"
***Second join
"Hello_world"

```
