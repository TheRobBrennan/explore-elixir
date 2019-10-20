# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html)

## Binaries, strings, and charlists

In “Basic types”, we learned about strings and used the is_binary/1 function for checks:

```sh
iex(1)> string = "hello"
"hello"
iex(2)> is_binary(string)
true
```

In this chapter, we will understand what binaries are, how they associate with strings, and what a single-quoted value, 'like this', means in Elixir.

### UTF-8 and Unicode

In this chapter, we will understand what binaries are, how they associate with strings, and what a single-quoted value, 'like this', means in Elixir.

Please look at the section [UTF-8 and Unicode](https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html#utf-8-and-unicode) for a great explanation.

The Unicode standard assigns code points to many of the characters we know. For example, the letter a has code point 97 while the letter ł has code point 322. When writing the string "hełło" to disk, we need to convert this sequence of characters to bytes. If we adopted a rule that said one byte represents one code point, we wouldn’t be able to write "hełło", because it uses the code point 322 for ł, and one byte can only represent a number from 0 to 255. But of course, given you can actually read "hełło" on your screen, it must be represented somehow. That’s where encodings come in.

When representing code points in bytes, we need to encode them somehow. Elixir chose the UTF-8 encoding as its main and default encoding. When we say a string is a UTF-8 encoded binary, we mean a string is a bunch of bytes organized in a way to represent certain code points, as specified by the UTF-8 encoding.

```sh
# Since we have characters like ł assigned to the code point 322, we actually need more than one byte to represent them. That’s why we see a difference when we calculate the `byte_size/1` of a string compared to its `String.length/1`
iex(4)> string = "hełło"
"hełło"
iex(5)> byte_size(string)
7
iex(6)> String.length(string)
5

# In Elixir, you can get a character’s code point by using ?
iex(8)> ?a
97
iex(9)> ?ł
322

# You can also use the functions in the String module to split a string in its individual characters, each one as a string of length 1
iex(11)> String.codepoints("hełło")
["h", "e", "ł", "ł", "o"]

```

### Binaries (and bitstrings)

```sh
# In Elixir, you can define a binary using <<>>
iex(13)> <<0, 1, 2, 3>>
<<0, 1, 2, 3>>
iex(14)> byte_size(<<0, 1, 2, 3>>)
4

# A binary is a sequence of bytes. Those bytes can be organized in any way, even in a sequence that does not make them a valid string
iex(15)> String.valid?(<<239, 191, 19>>)
false

# The string concatenation operation is actually a binary concatenation operator
iex(16)> <<0, 1>> <> <<2, 3>>
<<0, 1, 2, 3>>

# A common trick in Elixir is to concatenate the null byte <<0>> to a string to see its inner binary representation
iex(18)> "hełło" <> <<0>>
<<104, 101, 197, 130, 197, 130, 111, 0>>

# Each number given to a binary is meant to represent a byte and therefore must go up to 255. Binaries allow modifiers to be given to store numbers bigger than 255 or to convert a code point to its UTF-8 representation
iex(20)> <<255>>
<<255>>
iex(21)> <<256>> # truncated
<<0>>
iex(22)> <<256 :: size(16)>> # use 16 bits (2 bytes) to store the number
<<1, 0>>
iex(23)> <<256 :: utf8>> # the number is a code point
"Ā"
iex(24)> <<256 :: utf8, 0>>
<<196, 128, 0>>

# If a byte has 8 bits, what happens if we pass a size of 1 bit?
iex(26)> <<1 :: size(1)>>
<<1::size(1)>>
iex(27)> <<2 :: size(1)>> # truncated
<<0::size(1)>>
iex(28)> is_binary(<<1 :: size(1)>>)
false
iex(29)> is_bitstring(<<1 :: size(1)>>)
true
iex(30)> bit_size(<<1 :: size(1)>>)
1

# The value is no longer a binary, but a bitstring – a bunch of bits! So a binary is a bitstring where the number of bits is divisible by 8
iex(34)> is_binary(<<1 :: size(16)>>)
true
iex(35)> is_binary(<<1 :: size(15)>>)
false

# We can also pattern match on binaries / bitstrings
iex(37)> <<0, 1, x>> = <<0, 1, 2>>
<<0, 1, 2>>
iex(38)> x
2
iex(39)> <<0, 1, x>> = <<0, 1, 2, 3>>
** (MatchError) no match of right hand side value: <<0, 1, 2, 3>>
    (stdlib) erl_eval.erl:453: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:257: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:237: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:215: IEx.Evaluator.eval/3 
    (iex) lib/iex/evaluator.ex:103: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:27: IEx.Evaluator.init/4

# Note each entry in the binary pattern is expected to match exactly 8 bits. If we want to match on a binary of unknown size, it is possible by using the binary modifier at the end of the pattern
iex(40)> <<0, 1, x :: binary>> = <<0, 1, 2, 3>>
<<0, 1, 2, 3>>
iex(41)> x
<<2, 3>>

# Similar results can be achieved with the string concatenation operator <>
iex(43)> "he" <> rest = "hello"
"hello"
iex(44)> rest
"llo"

```

### Charlists

```sh
# A charlist is nothing more than a list of code points. Char lists may be created with single-quoted literals
iex(46)> 'hełło'
[104, 101, 322, 322, 111]
iex(47)> is_list 'hełło'
true
iex(48)> 'hello'
'hello'
iex(49)> List.first('hello')
104

# You can see that, instead of containing bytes, a charlist contains the code points of the characters between single-quotes (note that by default IEx will only output code points if any of the integers is outside the ASCII range). So while double-quotes represent a string (i.e. a binary), single-quotes represent a charlist (i.e. a list).

# In practice, charlists are used mostly when interfacing with Erlang, in particular old libraries that do not accept binaries as arguments. You can convert a charlist to a string and back by using the to_string/1 and to_charlist/1 functions
iex(51)> to_charlist "hełło"
[104, 101, 322, 322, 111]
iex(52)> to_string 'hełło'
"hełło"
iex(53)> to_string :hello
"hello"
iex(54)> to_string 1
"1"

# String (binary) concatenation uses the <> operator but charlists use the lists concatenation operator ++
iex(59)> 'this ' <> 'fails'
** (ArgumentError) expected binary argument in <> operator but got: 'this '
    (elixir) lib/kernel.ex:1767: Kernel.wrap_concatenation/3
    (elixir) lib/kernel.ex:1754: Kernel.extract_concatenations/2
    (elixir) expanding macro: Kernel.<>/2
    iex:59: (file)
iex(59)> 'this ' ++ 'works'
'this works'
iex(60)> "he" ++ "llo"
** (ArgumentError) argument error
    :erlang.++("he", "llo")
iex(60)> "he" <> "llo"
"hello"

```
