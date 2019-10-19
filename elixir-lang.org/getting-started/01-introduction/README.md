# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/introduction.html)

## Introduction

### Installation

```sh
# What version of Erlang/OTP and Elixir are we working with?
$ elixir -v
Erlang/OTP 22 [erts-10.5.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe] [dtrace]

Elixir 1.9.2 (compiled with Erlang/OTP 22)
```

### Interactive mode

```sh
$ iex
Erlang/OTP 22 [erts-10.5.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe] [dtrace]

Interactive Elixir (1.9.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 

# Let's warm up with a few commands at the prompt
iex(1)> 40 + 2
42
iex(2)> "hello" <> " world"
"hello world"
iex(3)> 

# To exit iex, press CTRL+C twice
BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded
 (v)ersion (k)ill (D)b-tables (d)istribution
^C%
```

### Running scripts

Make sure you're in the `01-introduction` folder before running any of these commands 😁

```sh
$ elixir simple.exs
Hello world from Elixir
```

If you want to find and execute a given script in PATH so it will be loaded in `iex` use: `iex -S <script>`

```sh
$ iex -S simple.exs
Erlang/OTP 22 [erts-10.5.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe] [dtrace]

Hello world from Elixir
Interactive Elixir (1.9.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 

```

### Asking questions

When asking questions, remember these two tips:

+ Instead of asking “how to do X in Elixir”, ask “how to solve Y in Elixir”. In other words, don’t ask how to implement a particular solution, instead describe the problem at hand. Stating the problem gives more context and less bias for a correct answer.

+ In case things are not working as expected, please include as much information as you can in your report, for example, your Elixir version, the code snippet and the error message alongside the error stack trace. Use sites like Gist to paste this information.
