# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/pattern-matching.html)

## Pattern matching

In this chapter, we will show how the = operator in Elixir is actually a match operator and how to use it to pattern match inside data structures. Finally, we will learn about the pin operator ^ used to access previously bound values.

### The match operator

Why is `=` called the `match operator` in Elixir?

```sh
iex(1)> x = 1
1
iex(2)> x
1

# Notice that 1 = x is a valid expression, and it matched because both the left and right side are equal to 1
iex(3)> 1 = x
1

# When the sides do not match, a MatchError is raised
iex(4)> 2 = x
** (MatchError) no match of right hand side value: 1
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# A variable can only be assigned on the left side of =
iex(4)> 1 = unknown
** (CompileError) iex:4: undefined function unknown/0
# Since there is no variable unknown previously defined, Elixir assumed you were trying to call a function named unknown/0, but such a function does not exist.
```

### Pattern matching

The match operator is not only used to match against simple values, but it is also useful for destructuring more complex data types.

```sh
# We can pattern match on tuples
iex(5)> {a, b, c} = {:hello, "world", 42}
{:hello, "world", 42}
iex(6)> a
:hello
iex(7)> b
"world"

# A pattern match error will occur if the sides can’t be matched, for example if the tuples have different sizes
iex(9)> {a, b, c} = {:hello, "world"}
** (MatchError) no match of right hand side value: {:hello, "world"}
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# A pattern match error will occur if trying to compare two different tyles, for example a tuple and a list
iex(10)> {a, b, c} = [:hello, "world", 42]
** (MatchError) no match of right hand side value: [:hello, "world", 42]
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# We can match on specific values. The example below asserts that the left side will only match the right side when the right side is a tuple that starts with the atom :ok
iex(11)> {:ok, result} = {:ok, 13}
{:ok, 13}
iex(12)> result
13
iex(13)> {:ok, result} = {:error, :oops}
** (MatchError) no match of right hand side value: {:error, :oops}
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# We can pattern match on lists
iex(14)> [a, b, c] = [1, 2, 3]
[1, 2, 3]
iex(15)> a
1

# A list also supports matching on its own head and tail
iex(17)> [head | tail] = [1, 2, 3]
[1, 2, 3]
iex(18)> head
1
iex(19)> tail
[2, 3]

# Similar to the hd/1 and tl/1 functions, we can’t match an empty list with a head and tail pattern
iex(21)> [h | t] = []
** (MatchError) no match of right hand side value: []
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# The [head | tail] format is not only used on pattern matching but also for prepending items to a list
iex(22)> list = [1, 2, 3]
[1, 2, 3]
iex(23)> [0 | list]
[0, 1, 2, 3]

```

Pattern matching allows developers to easily destructure data types such as tuples and lists. As we will see in the following chapters, it is one of the foundations of recursion in Elixir and applies to other types as well, like maps and binaries.

### The pin operator

```sh
# Variables in Elixir can be rebound
iex(1)> x = 1
1
iex(2)> x = 2
2

# Use the pin operator ^ when you want to pattern match against an existing variable’s value rather than rebinding the variable
iex(1)> x = 1
iex(4)> x = 1
1
iex(5)> ^x = 2
** (MatchError) no match of right hand side value: 2
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4
iex(5)> {y, ^x} = {2, 1}
{2, 1}
iex(6)> y
2
iex(7)> {y, ^x} = {2, 2}
** (MatchError) no match of right hand side value: {2, 2}
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# If a variable is mentioned more than once in a pattern, all references should bind to the same pattern
iex(8)> {x, x} = {1, 1}
{1, 1}
iex(9)> {x, x} = {1, 2}
** (MatchError) no match of right hand side value: {1, 2}
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# In some cases, you don’t care about a particular value in a pattern. It is a common practice to bind those values to the underscore, _. For example, if only the head of the list matters to us, we can assign the tail to underscore
iex(10)> [h | _] = [1, 2, 3]
[1, 2, 3]
iex(11)> h
1

# The variable _ is special in that it can never be read from. Trying to read from it gives a compile error
iex(12)> _
** (CompileError) iex:12: invalid use of _. "_" represents a value to be ignored in a pattern and cannot be used in expressions

# Although pattern matching allows us to build powerful constructs, its usage is limited. For instance, you cannot make function calls on the left side of a match. The following example is invalid
iex(13)> length([1, [2], 3]) = 3
** (CompileError) iex:13: cannot invoke remote function :erlang.length/1 inside a match

```
