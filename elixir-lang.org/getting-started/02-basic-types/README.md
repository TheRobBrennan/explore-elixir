# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/basic-types.html)

## Basic types

In this chapter we will learn more about Elixir basic types: integers, floats, booleans, atoms, strings, lists and tuples.

```sh
# Start iex
$ iex
Erlang/OTP 22 [erts-10.5.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe] [dtrace]

Interactive Elixir (1.9.2) - press Ctrl+C to exit (type h() ENTER for help)
```

### Basic arithmetic

```sh
iex(1)> 1 + 2
3
iex(2)> 5 * 5
25

# The / operator in Elixir will always return a float; not an integer
iex(3)> 10 / 2
5.0

# To perform integer division or get the division remainder
# Notice that Elixir allows you to drop the parentheses when invoking named functions. This feature gives a cleaner syntax when writing declarations and control-flow constructs.
iex(4)> div(10,2)
5
iex(5)> div 10,2
5
iex(6)> rem 10,3
1

# Elixir also supports shortcut notations for entering binary, octal, and hexadecimal numbers
iex(7)> 0b1010
10
iex(8)> 0o777
511
iex(9)> 0x1F
31

# Float numbers require a dot followed by at least one digit and also support e for scientific notation
ex(10)> 1.0
1.0
iex(11)> 1.0e-10
1.0e-10
# Floats in Elixir are 64-bit double precision

# You can invoke the round function to get the closest integer to a given float, or the trunc function to get the integer part of a float.
iex(12)> round(3.58)
4
iex(13)> trunc(3.58)
3

```

### Identifying functions and documentation

```sh
# Functions are identified both by their name and their arity. round/1 identifies the function which is named round and takes 1 argument, whereas round/2 identifies a different (nonexistent) function with the same name but with an arity of 2.

# Let's use the h function - defined in the Elixir shell - to access documentation for the round/1 function
iex(14)> h round/1

                               def round(number)                                

  @spec round(float()) :: integer()
  @spec round(value) :: value when value: integer()

guard: true

Rounds a number to the nearest integer.

If the number is equidistant to the two nearest integers, rounds away from
zero.

Allowed in guard tests. Inlined by the compiler.

## Examples

    iex> round(5.6)
    6
    
    iex> round(5.2)
    5
    
    iex> round(-9.9)
    -10
    
    iex> round(-9)
    -9
    
    iex> round(2.5)
    3
    
    iex> round(-2.5)
    -3

```

### Booleans

```sh
iex(16)> true
true
iex(17)> true == false
false
iex(18)> is_boolean(true)
true
iex(19)> is_boolean(1)
false

# You can also use is_integer/1, is_float/1 or is_number/1 to check, respectively, if an argument is an integer, a float, or either.
```

### Atoms

An atom is a constant whose value is its own name. Often they are used to express the state of an operation, by using values such as :ok and :error

```sh
iex(21)> :apple
:apple
iex(22)> :orange
:orange
iex(23)> :watermelon
:watermelon
iex(24)> :apple == :apple
true
iex(25)> :apple == :orange
false

# The booleans true and false are also atoms.
iex(27)> true == :true
true
iex(28)> is_atom(false)
true
iex(29)> is_boolean(:false)
true
# Elixir allows you to skip the leading : for the atoms false, true and nil

# Finally, Elixir has a construct called aliases which we will explore later. Aliases start in upper case and are also atoms
iex(31)> is_atom(Hello) 
true
```

### Strings

```sh
# Strings in Elixir are delimited by double quotes, and they are encoded in UTF-8
iex(33)> "hellö"
"hellö"

# String interpolation
iex(34)> "hellö #{:world}"
"hellö world"

# Multiline strings
iex(35)> "hello
...(35)> world"
"hello\nworld"
iex(36)> "hello\nworld"
"hello\nworld"

# Print a string - notice how IO.puts returns the :ok atom
iex(37)> IO.puts "hello\nworld"
hello
world
:ok

# Strings in Elixir are represented internally by binaries which are sequences of bytes
iex(39)> is_binary("hellö")
true

# Notice that the number of bytes in that string is 6, even though it has 5 characters. That’s because the character “ö” takes 2 bytes to be represented in UTF-8
iex(40)> byte_size("hellö")
6

# String length
iex(41)> String.length("hellö")
5

# The String module contains functions that can operate on strings
iex(42)> String.upcase("hellö")
"HELLÖ"

```

### Anonymous functions

Elixir also provides anonymous functions. Anonymous functions allow us to store and pass executable code around as if it was an integer or a string. They are delimited by the keywords `fn` and `end`

```sh
# Define a function accepting arguments a and b. The function will simply add a + b.
iex(44)> add = fn a, b -> a + b end
#Function<13.126501267/2 in :erl_eval.expr/5>

# This fails because Elixir needs to make sure there is no ambiguity between the anonymous function defined in the variable add versus a function add/2
iex(45)> add(1,2)
** (CompileError) iex:45: undefined function add/2

# Call our anonymous function
iex(45)> add.(1,2)
3
iex(46)> is_function(add)
true

# check if add is a function that expects exactly 2 arguments
iex(47)> is_function(add, 2)
true

# check if add is a function that expects exactly 1 argument
iex(48)> is_function(add, 1)
false
```

Finally, anonymous functions are also closures and as such they can access variables that are in scope when the function is defined. Let’s define a new anonymous function that uses the add anonymous function we have previously defined:

```sh
iex(50)> double = fn a -> add.(a, a) end
#Function<7.126501267/1 in :erl_eval.expr/5>
iex(51)> double.(2)
4

# A variable assigned inside a function does not affect its surrounding environment
iex(53)> x = 42
42
iex(54)> (fn -> x = 0 end).()
warning: variable "x" is unused (if the variable is not meant to be used, prefix it with an underscore)
  iex:54

0
iex(55)> x
42

```

### (Linked) Lists

```sh
# Elixir uses square brackets to specify a list of values. Values can be of any type
iex(57)> [1, 2, true, 3]
[1, 2, true, 3]
iex(58)> length [1,2,3]
3

# Two lists can be concatenated or subtracted using the ++/2 and --/2 operators respectively
iex(60)> [1, 2, 3] ++ [4, 5, 6]
[1, 2, 3, 4, 5, 6]
iex(61)> [1, true, 2, false, 3, true] -- [true, false]
[1, 2, 3, true]
```

List operators never modify the existing list. Concatenating to or removing elements from a list returns a new list. We say that Elixir data structures are immutable. One advantage of immutability is that it leads to clearer code. You can freely pass the data around with the guarantee no one will mutate it in memory - only transform it.

A core concept is working with the head and tail of a list - `hd/1` and `tl/1` respectively:

```sh
iex(63)> list = [1, 2, 3]
[1, 2, 3]
iex(64)> hd(list)
1
iex(65)> tl(list)
[2, 3]

# Getting the head or tail of an empty list will throw an error
iex(66)> emptylist = []
[]
iex(67)> hd(emptylist)
** (ArgumentError) argument error
    :erlang.hd([])
iex(67)> tl(emptylist)
** (ArgumentError) argument error
    :erlang.tl([])
```

Sometimes you will create a list and it will return a value in single quotes.

```sh
iex(68)> [11, 12, 13]
'\v\f\r'
iex(69)> [104, 101, 108, 108, 111]
'hello'

# When Elixir sees a list of printable ASCII numbers, Elixir will print that as a charlist (literally a list of characters). Charlists are quite common when interfacing with existing Erlang code.
```

Whenever you see a value in IEx and you are not quite sure what it is, you can use the i/1 to retrieve information about it:

```sh
iex(71)> i 'hello'
Term
  'hello'
Data type
  List
Description
  This is a list of integers that is printed as a sequence of characters
  delimited by single quotes because all the integers in it represent printable
  ASCII characters. Conventionally, a list of Unicode code points is known as a
  charlist and a list of ASCII characters is a subset of it.
Raw representation
  [104, 101, 108, 108, 111]
Reference modules
  List
Implemented protocols
  Collectable, Enumerable, IEx.Info, Inspect, List.Chars, String.Chars
```

Keep in mind single-quoted and double-quoted representations are not equivalent in Elixir as they are represented by different types:

```sh
iex(73)> 'hello' == "hello"
false

iex(74)> i "hello"
Term
  "hello"
Data type
  BitString
Byte size
  5
Description
  This is a string: a UTF-8 encoded binary. It's printed surrounded by
  "double quotes" because all UTF-8 encoded code points in it are printable.
Raw representation
  <<104, 101, 108, 108, 111>>
Reference modules
  String, :binary
Implemented protocols
  Collectable, IEx.Info, Inspect, List.Chars, String.Chars
```

Single quotes are charlists, double quotes are strings.

### Tuples

Elixir uses curly brackets to define tuples. Like lists, tuples can hold any value.

```sh
iex(76)> {:ok, "hello"}
{:ok, "hello"}
iex(77)> tuple_size {:ok, "hello"}
2

```

Tuples store elements contiguously in memory. This means accessing a tuple element by index or getting the tuple size is a fast operation. Indexes start from zero.

```sh
iex(79)> tuple = {:ok, "hello"}
{:ok, "hello"}
iex(80)> elem(tuple, 1)
"hello"
iex(81)> tuple_size(tuple)
2

```

It is also possible to put an element at a particular index in a tuple with `put_elem/3`. Notice that `put_elem/3` returns a new typle. The original tuple stored in the `tuple` variable was not modified because it is immutable.

```sh
iex(83)> tuple = {:ok, "hello"}
{:ok, "hello"}
iex(84)> put_elem(tuple, 1, "world")
{:ok, "world"}
iex(85)> tuple
{:ok, "hello"}

```

### Lists or tuples

What is the difference between lists and tuples?

Lists are stored in memory as linked lists, meaning that each element in a list holds its value and points to the following element until the end of the list is reached. This means accessing the length of a list is a linear operation: we need to traverse the whole list in order to figure out its size.

Similarly, the performance of list concatenation depends on the length of the left-hand list.

```sh
iex(89)> list = [1, 2, 3]
[1, 2, 3]

# This is fast as we only need to traverse `[0]` to prepend to `list`
iex(90)> [0] ++ list
[0, 1, 2, 3]

# This is slow as we need to traverse `list` to append 4
iex(91)> list ++ [4]
[1, 2, 3, 4]

```

Tuples, on the other hand, are stored contiguously in memory. This means getting the tuple size or accessing an element by index is fast. However, updating or adding elements to tuples is expensive because it requires creating a new tuple in memory. Note that this applies only to the tuple itself, not its contents. For instance, when you update a tuple, all entries are shared between the old and the new tuple, except for the entry that has been replaced. In other words, tuples and lists in Elixir are capable of sharing their contents. This reduces the amount of memory allocation the language needs to perform and is only possible thanks to the immutable semantics of the language.

```sh
iex(93)> tuple = {:a, :b, :c, :d}
{:a, :b, :c, :d}
iex(94)> put_elem(tuple, 2, :e)
{:a, :b, :e, :d}
```

Those performance characteristics dictate the usage of those data structures. One very common use case for tuples is to use them to return extra information from a function. For example, File.read/1 is a function that can be used to read file contents. It returns a tuple.

```sh
# File exists
iex> File.read("path/to/existing/file")
{:ok, "... contents ..."}

# File does not exist - returns an error and the error description
iex> File.read("path/to/unknown/file")
{:error, :enoent}
```

Most of the time, Elixir is going to guide you to do the right thing. For example, there is an elem/2 function to access a tuple item but there is no built-in equivalent for lists.

```sh
iex(96)> tuple = {:ok, "hello"}
{:ok, "hello"}

# elem/2 exists for a tuple, but does not exist for a list
iex(97)> elem(tuple, 1)
"hello"

```

When counting the elements in a data structure, Elixir also abides by a simple rule: the function is named size if the operation is in constant time (i.e. the value is pre-calculated) or length if the operation is linear (i.e. calculating the length gets slower as the input grows). As a mnemonic, both “length” and “linear” start with “l”.
