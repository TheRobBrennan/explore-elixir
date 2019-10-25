# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)

## Introduction to Mix

In this guide, we will learn how to build a complete Elixir application, with its own supervision tree, configuration, tests and more.

The requirements for this guide are (see `elixir -v`):

+ Elixir 1.9.0 onwards
+ Erlang/OTP 20 onwards

```sh
$ elixir -v
Erlang/OTP 22 [erts-10.5.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe] [dtrace]

Elixir 1.9.2 (compiled with Erlang/OTP 22)
```

The application works as a distributed key-value store. We are going to organize key-value pairs into buckets and distribute those buckets across multiple nodes. We will also build a simple client that allows us to connect to any of those nodes and send requests such as:

```sh
CREATE shopping
OK

PUT shopping milk 1
OK

PUT shopping eggs 3
OK

GET shopping milk
1
OK

DELETE shopping eggs
OK
```

In order to build our key-value application, we are going to use three main tools:

+ OTP (Open Telecom Platform) is a set of libraries that ships with Erlang. Erlang developers use OTP to build robust, fault-tolerant applications. In this chapter we will explore how many aspects from OTP integrate with Elixir, including supervision trees, event managers and more
+ Mix is a build tool that ships with Elixir that provides tasks for creating, compiling, testing your application, managing its dependencies and much more
+ ExUnit is a test-unit based framework that ships with Elixir

In this chapter, we will create our first project using Mix and explore different features in OTP, Mix and ExUnit as we go.

### Our first project

When you install Elixir, besides getting the `elixir`, `elixirc` and `iex` executables, you also get an executable Elixir script named `mix`.

Let’s create our first project by invoking `mix new` from the command line. We’ll pass the project name as the argument (`kv`, in this case), and tell Mix that our main module should be the all-uppercase `KV`, instead of the default, which would have been `Kv`:

```sh
$ mix new kv --module KV
```

Mix will create a directory named kv with a few files in it:

```sh
* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating lib
* creating lib/kv.ex
* creating test
* creating test/test_helper.exs
* creating test/kv_test.exs
```

Let’s take a brief look at those generated files.

Note: Mix is an Elixir executable. This means that in order to run `mix`, you need to have both `mix` and `elixir` executables in your PATH. That’s what happens when you install Elixir.

### Project compilation

```sh

```

### Running tests

```sh

```

### Automatic code formatting

```sh

```

### Environments

```sh

```

### Exploring

```sh

```
