# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/protocols.html)

## Protocols

Protocols are a mechanism to achieve polymorphism in Elixir. Dispatching on a protocol is available to any data type as long as it implements the protocol. Let’s see an example.

In Elixir, we have two idioms for checking how many items there are in a data structure: length and size. length means the information must be computed. For example, length(list) needs to traverse the whole list to calculate its length. On the other hand, tuple_size(tuple) and byte_size(binary) do not depend on the tuple and binary size as the size information is pre-computed in the data structure.

Even if we have type-specific functions for getting the size built into Elixir (such as tuple_size/1), we could implement a generic Size protocol that all data structures for which size is pre-computed would implement.

The protocol definition would look like this:

```sh
defprotocol Size do
  @doc "Calculates the size (and not the length!) of a data structure"
  def size(data)
end
```

The Size protocol expects a function called size that receives one argument (the data structure we want to know the size of) to be implemented. We can now implement this protocol for the data structures that would have a compliant implementation:

```sh
defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end

defimpl Size, for: Map do
  def size(map), do: map_size(map)
end

defimpl Size, for: Tuple do
  def size(tuple), do: tuple_size(tuple)
end
```

We didn’t implement the Size protocol for lists as there is no “size” information pre-computed for lists, and the length of a list has to be computed (with length/1).

Now with the protocol defined and implementations in hand, we can start using it:

```sh
iex(8)> Size.size("foo")
3
iex(9)> Size.size({:ok, "hello"})
2
iex(10)> Size.size(%{label: "some label"})
1

# Passing a data type that doesn’t implement the protocol raises an error:
iex(11)> Size.size([1, 2, 3])
** (Protocol.UndefinedError) protocol Size not implemented for [1, 2, 3] of type List
    iex:1: Size.impl_for!/1
    iex:3: Size.size/1
```

It’s possible to implement protocols for all Elixir data types:

+ Atom
+ BitString
+ Float
+ Function
+ Integer
+ List
+ Map
+ PID
+ Port
+ Reference
+ Tuple

### Protocols and structs

The power of Elixir’s extensibility comes when protocols and structs are used together.

In the previous chapter, we have learned that although structs are maps, they do not share protocol implementations with maps. For example, MapSets (sets based on maps) are implemented as structs. Let’s try to use the Size protocol defined above with a MapSet:

```sh
iex(11)> Size.size(%{})
0
iex(12)> set = %MapSet{} = MapSet.new
#MapSet<[]>
iex(13)> Size.size(set)
** (Protocol.UndefinedError) protocol Size not implemented for #MapSet<[]> of type MapSet (a struct)
    iex:1: Size.impl_for!/1
    iex:3: Size.size/1

# Instead of sharing protocol implementation with maps, structs require their own protocol implementation. Since a MapSet has its size precomputed and accessible through MapSet.size/1, we can define a Size implementation for it:
defimpl Size, for: MapSet do
  def size(set), do: MapSet.size(set)
end
```

If desired, you could come up with your own semantics for the size of your struct. Not only that, you could use structs to build more robust data types, like queues, and implement all relevant protocols, such as Enumerable and possibly Size, for this data type:

```sh
defmodule User do
  defstruct [:name, :age]
end

defimpl Size, for: User do
  def size(_user), do: 2
end
```

### Implementing Any

Manually implementing protocols for all types can quickly become repetitive and tedious. In such cases, Elixir provides two options: we can explicitly derive the protocol implementation for our types or automatically implement the protocol for all types. In both cases, we need to implement the protocol for `Any`.

#### Deriving

```sh
# Elixir allows us to derive a protocol implementation based on the Any implementation. Let’s first implement Any as follows:
defimpl Size, for: Any do
  def size(_), do: 0
end

# The implementation above is arguably not a reasonable one. For example, it makes no sense to say that the size of a PID or an Integer is 0

# However, should we be fine with the implementation for Any, in order to use such implementation we would need to tell our struct to explicitly derive the Size protocol
defmodule OtherUser do
  @derive [Size]
  defstruct [:name, :age]
end
```

When deriving, Elixir will implement the Size protocol for OtherUser based on the implementation provided for `Any`.

#### Fallback to Any

Another alternative to `@derive` is to explicitly tell the protocol to fallback to `Any` when an implementation cannot be found. This can be achieved by setting `@fallback_to_any` to `true` in the protocol definition:

```sh
defprotocol Size do
  @fallback_to_any true
  def size(data)
end
```

As we said in the previous section, the implementation of `Size` for `Any` is not one that can apply to any data type. That’s one of the reasons why `@fallback_to_any` is an opt-in behaviour. For the majority of protocols, raising an error when a protocol is not implemented is the proper behaviour. That said, assuming we have implemented `Any` as in the previous section:

```sh
defimpl Size, for: Any do
  def size(_), do: 0
end
```

Now all data types (including structs) that have not implemented the Size protocol will be considered to have a size of 0.

Which technique is best between deriving and falling back to any depends on the use case but, given Elixir developers prefer explicit over implicit, you may see many libraries pushing towards the @derive approach.

### Built-in protocols

```sh
# Elixir ships with some built-in protocols. In previous chapters, we have discussed the Enum module which provides many functions that work with any data structure that implements the Enumerable protocol:
iex(19)> Enum.map [1, 2, 3], fn(x) -> x * 2 end
[2, 4, 6]
iex(20)> Enum.reduce 1..3, 0, fn(x, acc) -> x + acc end
6

# Another useful example is the String.Chars protocol, which specifies how to convert a data structure with characters to a string. It’s exposed via the to_string function.
iex(21)> to_string :hello
"hello"

# Notice that string interpolation in Elixir calls the to_string function
iex(22)> "age: #{25}"
"age: 25"

# The snippet above only works because numbers implement the String.Chars protocol. Passing a tuple, for example, will lead to an error
iex(23)> tuple = {1, 2, 3}
{1, 2, 3}
iex(24)> "tuple: #{tuple}"
** (Protocol.UndefinedError) protocol String.Chars not implemented for {1, 2, 3} of type Tuple
    (elixir) lib/string/chars.ex:3: String.Chars.impl_for!/1
    (elixir) lib/string/chars.ex:22: String.Chars.to_string/1

# When there is a need to “print” a more complex data structure, one can use the inspect function, based on the Inspect protocol
iex(25)> "tuple: #{inspect tuple}"
"tuple: {1, 2, 3}"

# The Inspect protocol is the protocol used to transform any data structure into a readable textual representation. This is what tools like IEx use to print results
iex(27)> {1, 2, 3}
{1, 2, 3}

# Keep in mind that, by convention, whenever the inspected value starts with #, it is representing a data structure in non-valid Elixir syntax. This means the inspect protocol is not reversible as information may be lost along the way
iex(28)> inspect &(&1+2)
"#Function<7.126501267/1 in :erl_eval.expr/5>"
```

### Protocol consolidation

When working with Elixir projects, using the Mix build tool, you may see the output as follows:

```sh
Consolidated String.Chars
Consolidated Collectable
Consolidated List.Chars
Consolidated IEx.Info
Consolidated Enumerable
Consolidated Inspect
```

Those are all protocols that ship with Elixir and they are being consolidated. Because a protocol can dispatch to any data type, the protocol must check on every call if an implementation for the given type exists. This may be expensive.

However, after our project is compiled using a tool like Mix, we know all modules that have been defined, including protocols and their implementations. This way, the protocol can be consolidated into a very simple and fast dispatch module.

From Elixir v1.2, protocol consolidation happens automatically for all projects. We will build our own project in the Mix and OTP guide.

You can learn more about protocols and implementations in the Protocol module.