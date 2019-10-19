# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/basic-operators.html)

## Basic operators

```sh
# In the previous chapter, we saw Elixir provides +, -, *, / as arithmetic operators, plus the functions div/2 and rem/2 for integer division and remainder

# Elixir also provides ++ and -- to manipulate lists
iex(1)> [1, 2, 3] ++ [4, 5, 6]
[1, 2, 3, 4, 5, 6]
iex(2)> [1, 2, 3] -- [2]
[1, 3]

# String concatenation is done with <>
iex(3)> "foo" <> "bar"
"foobar"

# Elixir also provides three boolean operators: or, and and not. These operators are strict in the sense that they expect something that evaluates to a boolean (true or false) as their first argument
iex(5)> true and true
true
iex(6)> false or is_atom(:example)
true

# Providing a non-boolean will raise an exception
iex(7)> 1 and true
** (BadBooleanError) expected a boolean on left-side of "and", got: 1

# or and and are short-circuit operators. They only execute the right side if the left side is not enough to determine the result
iex(8)> false and raise("This error will never be raised")
false
iex(9)> true or raise("This error will never be raised")
true

# Besides these boolean operators, Elixir also provides ||, && and ! which accept arguments of any type. For these operators, all values except false and nil will evaluate to true
iex(11)> 1 || true
1
iex(12)> false || 11
11
iex(13)> nil && 13
nil
iex(14)> true && 17
17
iex(15)> !true
false
iex(16)> !1
false
iex(17)> !nil
true
# As a rule of thumb, use and, or and not when you are expecting booleans. If any of the arguments are non-boolean, use &&, || and !

# Elixir also provides ==, !=, ===, !==, <=, >=, < and > as comparison operators
iex(19)> 1 == 1
true
iex(20)> 1 != 2
true
iex(21)> 1 < 2
true

# The difference between == and === is that the latter is more strict when comparing integers and floats
iex(23)> 1 == 1.0
true
iex(24)> 1 === 1.0
false

# In Elixir, we can compare two different data types
iex(26)> 1 < :atom
true
```

What? Yes. It's true. The reason we can compare different data types is pragmatism. Sorting algorithms don’t need to worry about different data types in order to sort. The overall sorting order is defined below:

`number < atom < reference < function < port < pid < tuple < map < list < bitstring`
