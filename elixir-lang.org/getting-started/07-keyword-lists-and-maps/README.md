# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/keywords-and-maps.html)

## Keyword lists and maps

So far we haven’t discussed any associative data structures, i.e. data structures that are able to associate a certain value (or multiple values) to a key. Different languages call these different names like dictionaries, hashes, associative arrays, etc.

### Keyword lists

```sh
# In many functional programming languages, it is common to use a list of 2-item tuples as the representation of a key-value data structure. In Elixir, when we have a list of tuples and the first item of the tuple (i.e. the key) is an atom, we call it a keyword list
iex(1)> list = [{:a, 1}, {:b, 2}]
[a: 1, b: 2]

# Elixir supports a special syntax for defining such lists: [key: value]
iex(2)> list == [a: 1, b: 2]
true

# Since keyword lists are lists, we can use all operations available to lists. For example, we can use ++ to add new values to a keyword list
iex(3)> list ++ [c: 3]
[a: 1, b: 2, c: 3]
iex(4)> [a: 0] ++ list
[a: 0, a: 1, b: 2]

# Note that values added to the front are the ones fetched on lookup
iex(5)> new_list = [a: 0] ++ list
[a: 0, a: 1, b: 2]
iex(6)> new_list[:a]
0
```

Keyword lists are important because they have three special characteristics:

+ Keys must be atoms.
+ Keys are ordered, as specified by the developer.
+ Keys can be given more than once.

For example, the Ecto library makes use of these features to provide an elegant DSL for writing database queries:

```sh
query = from w in Weather,
      where: w.prcp > 0,
      where: w.temp < 20,
     select: w
```

These characteristics are what prompted keyword lists to be the default mechanism for passing options to functions in Elixir. In chapter 5, when we discussed the if/2 macro, we mentioned the following syntax is supported:

```sh
iex(9)> if false, do: :this, else: :that
:that

# The do: and else: pairs form a keyword list! In fact, the call above is equivalent to:
iex(10)> if(false, [do: :this, else: :that])
:that

# Which, as we have seen above, is the same as:
if(false, [{:do, :this}, {:else, :that}])
```

In general, when the keyword list is the last argument of a function, the square brackets are optional.

Although we can pattern match on keyword lists, it is rarely done in practice since pattern matching on lists requires the number of items and their order to match:

```sh
iex(12)> [a: a] = [a: 1]
[a: 1]
iex(13)> a
1
iex(14)> [a: a] = [a: 1, b: 2]
** (MatchError) no match of right hand side value: [a: 1, b: 2]
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4
iex(14)> [b: b, a: a] = [a: 1, b: 2]
** (MatchError) no match of right hand side value: [a: 1, b: 2]
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4
```

In order to manipulate keyword lists, Elixir provides the Keyword module. Remember, though, keyword lists are simply lists, and as such they provide the same linear performance characteristics as lists. The longer the list, the longer it will take to find a key, to count the number of items, and so on. For this reason, keyword lists are used in Elixir mainly for passing optional values. If you need to store many items or guarantee one-key associates with at maximum one-value, you should use maps instead.

### Maps

Whenever you need a key-value store, maps are the “go to” data structure in Elixir. A map is created using the %{} syntax.

```sh
iex(1)> map = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(2)> map[:a]
1
iex(3)> map[2]
:b
iex(4)> map[:c]
nil
```

Compared to keyword lists, we can already see two differences:

Maps allow any value as a key.
Maps’ keys do not follow any ordering.
In contrast to keyword lists, maps are very useful with pattern matching. When a map is used in a pattern, it will always match on a subset of the given value:

```sh
iex(6)> %{} = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(7)> %{:a => a} = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(8)> a
1
iex(9)> %{:c => c} = %{:a => 1, 2 => :b}
** (MatchError) no match of right hand side value: %{2 => :b, :a => 1}
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# As shown above, a map matches as long as the keys in the pattern exist in the given map. Therefore, an empty map matches all maps.

# Variables can be used when accessing, matching and adding map keys
iex(10)> n = 1
1
iex(11)> map = %{n => :one}
%{1 => :one}
iex(12)> map[n]
:one
iex(13)> %{^n => :one} = %{1 => :one, 2 => :two, 3 => :three}
%{1 => :one, 2 => :two, 3 => :three}

# The Map module provides a very similar API to the Keyword module with convenience functions to manipulate maps
iex(15)> Map.get(%{:a => 1, 2 => :b}, :a)
1
iex(16)> Map.put(%{:a => 1, 2 => :b}, :c, 3)
%{2 => :b, :a => 1, :c => 3}
iex(17)> Map.to_list(%{:a => 1, 2 => :b})
[{2, :b}, {:a, 1}]

# Maps have the following syntax for updating a key’s value provided the given key exists
iex(19)> map = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(20)> %{map | 2 => "two"}
%{2 => "two", :a => 1}
iex(21)> %{map | :c => 3}
** (KeyError) key :c not found in: %{2 => :b, :a => 1}
    (stdlib) :maps.update(:c, 3, %{2 => :b, :a => 1})
    (stdlib) erl_eval.erl:256: anonymous fn/2 in :erl_eval.expr/5
    (stdlib) lists.erl:1263: :lists.foldl/3

# Another interesting property of maps is that they provide their own syntax for accessing atom keys
iex(22)> map = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(23)> map.a
1
iex(24)> map.c
** (KeyError) key :c not found in: %{2 => :b, :a => 1}
```

Elixir developers typically prefer to use the map.field syntax and pattern matching instead of the functions in the Map module when working with maps because they lead to an assertive style of programming.

Note: Maps were recently introduced into the Erlang VM and only from Elixir v1.2 are they capable of holding millions of keys efficiently. Therefore, if you are working with previous Elixir versions (v1.0 or v1.1) and you need to support at least hundreds of keys, you may consider using the HashDict module.

### Nested data structures

Often we will have maps inside maps, or even keywords lists inside maps, and so forth. Elixir provides conveniences for manipulating nested data structures via the put_in/2, update_in/2 and other macros giving the same conveniences you would find in imperative languages while keeping the immutable properties of the language.

```sh
# Imagine you have the following structure
iex(25)> users = [
...(25)>   john: %{name: "John", age: 27, languages: ["Erlang", "Ruby", "Elixir"]},
...(25)>   mary: %{name: "Mary", age: 29, languages: ["Elixir", "F#", "Clojure"]}
...(25)> ]
[
  john: %{age: 27, languages: ["Erlang", "Ruby", "Elixir"], name: "John"},
  mary: %{age: 29, languages: ["Elixir", "F#", "Clojure"], name: "Mary"}
]

# We have a keyword list of users where each value is a map containing the name, age and a list of programming languages each user likes. If we wanted to access the age for john, we could write
iex(26)> users[:john].age
27

# It happens we can also use this same syntax for updating the value
iex(27)> users = put_in users[:john].age, 31
[
  john: %{age: 31, languages: ["Erlang", "Ruby", "Elixir"], name: "John"},
  mary: %{age: 29, languages: ["Elixir", "F#", "Clojure"], name: "Mary"}
]

# The update_in/2 macro is similar but allows us to pass a function that controls how the value changes. For example, let’s remove “Clojure” from Mary’s list of languages
iex(28)> users = update_in users[:mary].languages, fn languages -> List.delete(languages, "Clojure") end
[
  john: %{age: 31, languages: ["Erlang", "Ruby", "Elixir"], name: "John"},
  mary: %{age: 29, languages: ["Elixir", "F#"], name: "Mary"}
]
```

There is more to learn about `put_in/2` and `update_in/2`, including the `get_and_update_in/2` that allows us to extract a value and update the data structure at once. There are also `put_in/3`, `update_in/3` and `get_and_update_in/3` which allow dynamic access into the data structure.
