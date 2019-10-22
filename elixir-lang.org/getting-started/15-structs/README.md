# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/structs.html)

## Structs

In chapter 7 we learned about maps:

```sh
iex> map = %{a: 1, b: 2}
%{a: 1, b: 2}

# Read the data contained within a key
iex> map[:a]
1

# Take the existing map and update key a to have a value of 3
iex> %{map | a: 3}
%{a: 3, b: 2}
```

Structs are extensions built on top of maps that provide compile-time checks and default values.

### Defining structs

```sh
# To define a struct, the defstruct construct is used
defmodule User do
  defstruct name: "John", age: 27
end

# The keyword list used with defstruct defines what fields the struct will have along with their default values.

# Structs take the name of the module they’re defined in. In the example above, we defined a struct named User.

# We can now create User structs by using a syntax similar to the one used to create maps (if you have defined the struct in a separate file, you can compile the file inside IEx before proceeding by running c "file.exs"; be aware you may get an error saying the struct was not yet defined if you try the below example in a file directly due to when definitions are resolved):
iex(2)> %User{}
%User{age: 27, name: "John"}

iex(3)> %User{name: "Jane"}
%User{age: 27, name: "Jane"}

# Structs provide compile-time guarantees that only the fields (and all of them) defined through defstruct will be allowed to exist in a struct
iex(5)> %User{oops: :field}
** (KeyError) key :oops not found
    expanding struct: User.__struct__/1
    iex:5: (file)

```

### Accessing and updating structs

```sh
# When we discussed maps, we showed how we can access and update the fields of a map. The same techniques (and the same syntax) apply to structs as well:
iex(2)> john = %User{}
%User{age: 27, name: "John"}

iex(3)> john.name
"John"

iex(4)> jane = %{john | name: "Jane"}
%User{age: 27, name: "Jane"}

iex(5)> %{jane | oops: :field}
** (KeyError) key :oops not found in: %User{age: 27, name: "Jane"}
    (stdlib) :maps.update(:oops, :field, %User{age: 27, name: "Jane"})
    (stdlib) erl_eval.erl:256: anonymous fn/2 in :erl_eval.expr/5
    (stdlib) lists.erl:1263: :lists.foldl/3

# When using the update syntax (|), the VM is aware that no new keys will be added to the struct, allowing the maps underneath to share their structure in memory. In the example above, both john and jane share the same key structure in memory.

# Structs can also be used in pattern matching, both for matching on the value of specific keys as well as for ensuring that the matching value is a struct of the same type as the matched value.
iex(6)> %User{name: name} = john
%User{age: 27, name: "John"}
iex(7)> name
"John"
iex(8)> %User{} = %{}
** (MatchError) no match of right hand side value: %{}
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

```

### Structs are bare maps underneath

```sh
# In the example above, pattern matching works because underneath structs are bare maps with a fixed set of fields. As maps, structs store a “special” field named __struct__ that holds the name of the struct
iex(9)> is_map(john)
true
iex(10)> john.__struct__
User

# Notice that we referred to structs as bare maps because none of the protocols implemented for maps are available for structs. For example, you can neither enumerate nor access a struct
iex(12)> john = %User{}
%User{age: 27, name: "John"}
iex(13)> john[:name]
** (UndefinedFunctionError) function User.fetch/2 is undefined (User does not implement the Access behaviour)
    User.fetch(%User{age: 27, name: "John"}, :name)
    (elixir) lib/access.ex:267: Access.get/3
iex(13)> Enum.each john, fn({field, value}) -> IO.puts(value) end
warning: variable "field" is unused (if the variable is not meant to be used, prefix it with an underscore)
  iex:13

** (Protocol.UndefinedError) protocol Enumerable not implemented for %User{age: 27, name: "John"} of type User (a struct)
    (elixir) lib/enum.ex:1: Enumerable.impl_for!/1
    (elixir) lib/enum.ex:141: Enumerable.reduce/3
    (elixir) lib/enum.ex:3023: Enum.each/2

# However, since structs are just maps, they work with the functions from the Map module
iex(14)> jane = Map.put(%User{}, :name, "Jane")
%User{age: 27, name: "Jane"}
iex(15)> Map.merge(jane, %User{name: "John"})
%User{age: 27, name: "John"}
iex(16)> Map.keys(jane)
[:__struct__, :age, :name]
```

### Default values and required keys

```sh
# If you don’t specify a default key value when defining a struct, nil will be assumed
iex(18)> defmodule Product do
...(18)>   defstruct [:name]
...(18)> end
{:module, Product,
 <<70, 79, 82, 49, 0, 0, 5, 248, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 184,
   0, 0, 0, 18, 14, 69, 108, 105, 120, 105, 114, 46, 80, 114, 111, 100, 117, 99,
   116, 8, 95, 95, 105, 110, 102, 111, 95, ...>>, %Product{name: nil}}
iex(19)> %Product{}
%Product{name: nil}

# You can define a structure combining both fields with explicit default values, and implicit nil values. In this case you must first specify the fields which implicitly default to nil
iex(1)> defmodule User do
...(1)>   defstruct [:email, name: "John", age: 27]
...(1)> end
{:module, User,
 <<70, 79, 82, 49, 0, 0, 6, 20, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 181,
   0, 0, 0, 18, 11, 69, 108, 105, 120, 105, 114, 46, 85, 115, 101, 114, 8, 95,
   95, 105, 110, 102, 111, 95, 95, 7, 99, ...>>,
 %User{age: 27, email: nil, name: "John"}}
iex(2)> %User{}
%User{age: 27, email: nil, name: "John"}

# Doing it in reverse order will raise a syntax error
iex(1)> defmodule User do
...(1)>   defstruct [name: "John", age: 27, :email]
...(1)> end
** (SyntaxError) iex:2: syntax error before: email

# You can also enforce that certain keys have to be specified when creating the struct
iex(2)> defmodule Car do
...(2)>   @enforce_keys [:make]
...(2)>   defstruct [:model, :make]
...(2)> end
{:module, Car,
 <<70, 79, 82, 49, 0, 0, 8, 156, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 1, 16,
   0, 0, 0, 27, 10, 69, 108, 105, 120, 105, 114, 46, 67, 97, 114, 8, 95, 95,
   105, 110, 102, 111, 95, 95, 7, 99, 111, ...>>, %Car{make: nil, model: nil}}
iex(3)> %Car{}
** (ArgumentError) the following keys must also be given when building struct Car: [:make]
    expanding struct: Car.__struct__/1
    iex:3: (file)

```
