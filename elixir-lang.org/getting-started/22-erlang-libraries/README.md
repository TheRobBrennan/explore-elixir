# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/erlang-libraries.html)

## Erlang libraries

Elixir provides excellent interoperability with Erlang libraries. In fact, Elixir discourages simply wrapping Erlang libraries in favor of directly interfacing with Erlang code. In this section, we will present some of the most common and useful Erlang functionality that is not found in Elixir.

As you grow more proficient in Elixir, you may want to explore the Erlang STDLIB Reference Manual in more detail.

### The binary module

The built-in Elixir String module handles binaries that are UTF-8 encoded. The binary module is useful when you are dealing with binary data that is not necessarily UTF-8 encoded.

```sh
# String module returns Unicode codepoints
iex(1)> String.to_charlist "Ø"
[216]

# :binary deals with raw data bytes
iex(2)> :binary.bin_to_list "Ø"
[195, 152]

```

### Formatted text output

Elixir does not contain a function similar to printf found in C and other languages. Luckily, the Erlang standard library functions `:io.format/2` and `:io_lib.format/2` may be used. The first formats to terminal output, while the second formats to an `iolist`. The format specifiers differ from printf, refer to the Erlang documentation for details.

```sh
iex(4)> :io.format("Pi is approximately given by:~10.3f~n", [:math.pi])
Pi is approximately given by:     3.142
:ok
iex(5)> to_string :io_lib.format("Pi is approximately given by:~10.3f~n", [:math.pi])
"Pi is approximately given by:     3.142\n"
```

### The crypto module

The crypto module contains hashing functions, digital signatures, encryption and more:

```sh
iex(7)> Base.encode16(:crypto.hash(:sha256, "Elixir"))
"3315715A7A3AD57428298676C5AE465DADA38D951BDFAC9348A8A31E9C7401CB"
```

The :crypto module is not part of the Erlang standard library, but is included with the Erlang distribution. This means you must list :crypto in your project’s applications list whenever you use it. To do this, edit your mix.exs file to include:

```sh
def application do
  [extra_applications: [:crypto]]
end
```

### The digraph module

The digraph module (as well as digraph_utils) contains functions for dealing with directed graphs built of vertices and edges. After constructing the graph, the algorithms in there will help find, for instance, the shortest path between two vertices, or loops in the graph.

```sh
# Given three vertices, find the shortest path from the first to the last
iex(9)> digraph = :digraph.new()
{:digraph, #Reference<0.1669346300.474611714.26081>,
 #Reference<0.1669346300.474611714.26082>,
 #Reference<0.1669346300.474611714.26083>, true}
iex(10)> coords = [{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}]
[{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}]
iex(11)> [v0, v1, v2] = (for c <- coords, do: :digraph.add_vertex(digraph, c))
[{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}]
iex(12)> :digraph.add_edge(digraph, v0, v1)
[:"$e" | 0]
iex(13)> :digraph.add_edge(digraph, v1, v2)
[:"$e" | 1]
iex(14)> :digraph.get_short_path(digraph, v0, v2)
[{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}]
```

Note that the functions in `:digraph` alter the graph structure in-place, this is possible because they are implemented as ETS tables, explained next.

### Erlang Term Storage

The modules `ets` and `dets` handle storage of large data structures in memory or on disk respectively.

ETS lets you create a table containing tuples. By default, ETS tables are protected, which means only the owner process may write to the table but any other process can read. ETS has some functionality to allow a table to be used as a simple database, a key-value store or as a cache mechanism.

```sh
# The functions in the ets module will modify the state of the table as a side-effect.
iex(16)> table = :ets.new(:ets_test, [])
#Reference<0.1669346300.474611714.26148>
iex(17)> # Store as tuples with {name, population}
nil
iex(18)> :ets.insert(table, {"China", 1_374_000_000})
true
iex(19)> :ets.insert(table, {"India", 1_284_000_000})
true
iex(20)> :ets.insert(table, {"USA", 322_000_000})
true
iex(21)> :ets.i(table)
<1   > {<<"India">>,1284000000}
<2   > {<<"USA">>,322000000}
<3   > {<<"China">>,1374000000}
EOT  (q)uit (p)Digits (k)ill /Regexp -->q
:ok
```

### The math module

The math module contains common mathematical operations covering trigonometry, exponential, and logarithmic functions.

```sh
iex(23)> angle_45_deg = :math.pi() * 45.0 / 180.0
0.7853981633974483
iex(24)> :math.sin(angle_45_deg)
0.7071067811865475
iex(25)> :math.exp(55.0)
7.694785265142018e23
iex(26)> :math.log(7.694785265142018e23)
55.0
```

### The queue module

The queue is a data structure that implements (double-ended) FIFO (first-in first-out) queues efficiently:

```sh
iex(28)> q = :queue.new
{[], []}
iex(29)> q = :queue.in("A", q)
{["A"], []}
iex(30)> q = :queue.in("B", q)
{["B"], ["A"]}
iex(31)> {value, q} = :queue.out(q)
{{:value, "A"}, {[], ["B"]}}
iex(32)> value
{:value, "A"}
iex(33)> {value, q} = :queue.out(q)
{{:value, "B"}, {[], []}}
iex(34)> value
{:value, "B"}
iex(35)> {value, q} = :queue.out(q)
{:empty, {[], []}}
iex(36)> value
:empty
```

### The rand module

`rand` has functions for returning random values and setting the random seed.

```sh
iex(38)> :rand.uniform()
0.7448878470498819
iex(39)> _ = :rand.seed(:exs1024, {123, 123534, 345345})
{%{
   jump: #Function<16.8986388/1 in :rand.mk_alg/1>,
   max: 18446744073709551615,
   next: #Function<15.8986388/1 in :rand.mk_alg/1>,
   type: :exs1024
 },
 {[1777391367797874666, 1964529382746821925, 7996041688159811731,
   16797603918550466679, 13239206057622895956, 2190120427146910527,
   18292739386017762693, 7995684206500985125, 1619687243448614582,
   961993414031414042, 10239938031393579756, 12249841489256032092,
   1457887945073169212, 16031477380367994289, 12526413104181201380,
   16202025130717851397], []}}
iex(40)> :rand.uniform()
0.5820506340260994
iex(41)> :rand.uniform(6)
6
```

### The zip and zlib modules

The zip module lets you read and write ZIP files to and from disk or memory, as well as extracting file information.

```sh
# This code counts the number of files in a ZIP file
iex> :zip.foldl(fn _, _, _, acc -> acc + 1 end, 0, :binary.bin_to_list("file.zip"))
{:ok, 633}
```

The zlib module deals with data compression in zlib format, as found in the gzip command.

```sh
iex(43)> song = "
...(43)> Mary had a little lamb,
...(43)> His fleece was white as snow,
...(43)> And everywhere that Mary went,
...(43)> The lamb was sure to go."
"\nMary had a little lamb,\nHis fleece was white as snow,\nAnd everywhere that Mary went,\nThe lamb was sure to go."
iex(44)> compressed = :zlib.compress(song)
<<120, 156, 37, 140, 187, 13, 195, 48, 12, 5, 123, 77, 241, 6, 16, 188, 67, 186,
  52, 233, 188, 0, 109, 189, 132, 2, 100, 9, 144, 152, 16, 222, 62, 254, 116,
  87, 220, 93, 120, 73, 223, 161, 146, 32, 40, 217, 172, 16, 69, 182, ...>>
iex(45)> byte_size song
110
iex(46)> byte_size compressed
99
iex(47)> :zlib.uncompress(compressed)
"\nMary had a little lamb,\nHis fleece was white as snow,\nAnd everywhere that Mary went,\nThe lamb was sure to go."
```
