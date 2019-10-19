# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/case-cond-and-if.html)

## case, cond, and if

### case

```sh
# case allows us to compare a value against many patterns until we find a matching one
iex(1)> case {1, 2, 3} do
...(1)>   {4, 5, 6} ->
...(1)>     "This clause won't match"
...(1)>   {1, x, 3} ->
...(1)>     "This clause will match and bind x to 2 in this clause"
...(1)>   _ ->
...(1)>     "This clause would match any value"
...(1)> end
warning: variable "x" is unused (if the variable is not meant to be used, prefix it with an underscore)
  iex:4

"This clause will match and bind x to 2 in this clause"

# If you want to pattern match against an existing variable, you need to use the ^ operator
iex(3)> x = 1
1
iex(4)> case 10 do
...(4)>   ^x -> "Won't match"
...(4)>   _ -> "Will match"
...(4)> end
"Will match"

# Clauses also allow extra conditions to be specified via guards
# Since x will bind to 2, the clause will match
iex(1)> case {1, 2, 3} do
...(1)>   {1, x, 3} when x > 0 ->
...(1)>     "Will match"
...(1)>   _ ->
...(1)>     "Would match, if guard condition were not satisfied"
...(1)> end
"Will match"

# Keep in mind errors in guards do not leak but simply make the guard fail
iex(3)> hd(1)
** (ArgumentError) argument error
    :erlang.hd(1)
iex(3)> case 1 do
...(3)>   x when hd(x) -> "Won't match"
...(3)>   x -> "Got #{x}"
...(3)> end
"Got 1"

# If none of the clauses match, an error is raised
iex(5)> case :ok do
...(5)>   :error -> "Won't match"
...(5)> end
** (CaseClauseError) no case clause matching: :ok
    (stdlib) erl_eval.erl:968: :erl_eval.case_clauses/6
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# Anonymous functions can also have multiple clauses and guards
iex(1)> f = fn
...(1)>   x, y when x > 0 -> x + y
...(1)>   x, y -> x * y
...(1)> end
#Function<13.126501267/2 in :erl_eval.expr/5>
iex(2)> f.(1,3)
4
iex(3)> f.(-1,3)
-3

# The number of arguments in each anonymous function clause needs to be the same, otherwise an error is raised
iex(1)> f2 = fn
...(1)>   x, y when x > 0 -> x + y
...(1)>   x, y, z -> x * y + z
...(1)> end
** (CompileError) iex:1: cannot mix clauses with different arities in anonymous functions

```

### cond

`case` is useful when you need to match against different values. However, in many circumstances, we want to check different conditions and find the first one that does not evaluate to `nil` or `false`. In such cases, one may use `cond`

```sh
iex(2)> cond do
...(2)>   2 + 2 == 5 ->
...(2)>     "This will not be true"
...(2)>   2 * 2 == 3 ->
...(2)>     "Nor this"
...(2)>   1 + 1 == 2 ->
...(2)>     "But this will"
...(2)> end
"But this will"

# If all of the conditions return nil or false, an error (CondClauseError) is raised. For this reason, it may be necessary to add a final condition, equal to true, which will always match
iex(4)> cond do
...(4)>  2 + 2 == 5 -> "This will not be true"
...(4)>  2 * 2 == 3 -> "Nor this"
...(4)>  true -> "This is always true (equivalent to else)"
...(4)> end
"This is always true (equivalent to else)"

# Finally, note cond considers any value besides nil and false to be true
iex(6)> cond do
...(6)>   hd([1, 2, 3]) -> "1 is considered as true"
...(6)> end
"1 is considered as true"

```

### if and unless

```sh
# Besides case and cond, Elixir also provides the macros if/2 and unless/2 which are useful when you need to check for only one condition
iex(8)> if true do
...(8)>   "This works!"
...(8)> end
"This works!"
iex(9)> unless true do
...(9)>   "This will never be seen"
...(9)> end
nil

# If the condition given to if/2 returns false or nil, the body given between do/end is not executed and instead it returns nil. The opposite happens with unless/2

# They also support else blocks
iex(11)> if nil do
...(11)>   "This won't be seen"
...(11)> else
...(11)>   "This will"
...(11)> end
"This will"

```

### do/end blocks

```sh
# At this point, we have learned four control structures: case, cond, if, and unless, and they were all wrapped in do/end blocks. It happens we could also write if as follows
iex(13)> if true, do: 1 + 2
3
# We say the above syntax is using keyword listse

# We can also pass else using keywords, too
iex(16)> if false, do: :this, else: :that
:that

# do/end blocks are a syntactic convenience built on top of the keywords one. That’s why do/end blocks do not require a comma between the previous argument and the block. They are useful exactly because they remove the verbosity when writing blocks of code. These are equivalent:
iex(18)> if true do
...(18)>   a = 1 + 2
...(18)>   a + 10
...(18)> end
13
iex(19)> if true, do: (
...(19)>   a = 1 + 2
...(19)>   a + 10
...(19)> )
13

# Add explicit parenthese if you need to bind a block to if - such as when passed in as an argument
iex(21)> is_number(if true do
...(21)>   1 + 2
...(21)> end)
true

```
