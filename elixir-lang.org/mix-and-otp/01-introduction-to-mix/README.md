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

A file named `mix.exs` was generated inside our new project folder (`kv`) and its main responsibility is to configure our project. Let’s take a look at it.

Our `mix.exs` defines two public functions: `project`, which returns project configuration like the project name and version, and `application`, which is used to generate an application file.

There is also a private function named `deps`, which is invoked from the project function, that defines our project dependencies. Defining deps as a separate function is not required, but it helps keep the project configuration tidy.

Mix also generates a file at `lib/kv.ex` with a module containing exactly one function, called `hello`

This structure is enough to compile our project:

```sh
$ cd kv
$ mix compile
Compiling 1 file (.ex)
Generated kv app
```

The `lib/kv.ex` file was compiled, an application manifest named `kv.app` was generated and all protocols were consolidated as described in the Getting Started guide. All compilation artifacts are placed inside the `_build` directory using the options defined in the `mix.exs` file.

Once the project is compiled, you can start an iex session inside the project by running:

```sh
$ iex -S mix
```

We are going to work on this `kv` project, making modifications and trying out the latest changes from an `iex` session. While you may start a new session whenever there are changes to the project source code, you can also recompile the project from within `iex` with the recompile helper, like this:

```sh
iex(1)> recompile()
Compiling 1 file (.ex)
:ok
iex(2)> recompile()
:noop
```

If anything had to be compiled, you see some informative text, and get the `:ok` atom back, otherwise the function is silent, and returns `:noop`.

### Running tests

Mix also generated the appropriate structure for running our project tests. Mix projects usually follow the convention of having a `<filename>_test.exs` file in the test directory for each file in the `lib` directory. For this reason, we can already find a `test/kv_test.exs` corresponding to our `lib/kv.ex` file. It doesn’t do much at this point.

It is important to note a couple of things:

+ The test file is an Elixir script file (`.exs`). This is convenient because we don’t need to compile test files before running them
+ We define a test module named `KVTest`, in which we use `ExUnit.Case` to inject the testing API
+ We use one of the injected macros, `doctest/1`, to indicate that the `KV` module contains `doctests` (we will discuss those in a later chapter)
+ We use the `test/2` macro to define a simple test

Mix also generated a file named `test/test_helper.exs` which is responsible for setting up the test framework.

This file will be required by Mix every time before we run our tests. We can run tests with:

```sh
$ mix test
Compiling 1 file (.ex)
Generated kv app
..

Finished in 0.03 seconds
1 doctest, 1 test, 0 failures

Randomized with seed 44575
```

Notice that by running mix test, Mix has compiled the source files and generated the application manifest once again. This happens because Mix supports multiple environments, which we will discuss later in this chapter.

Furthermore, you can see that ExUnit prints a dot for each successful test and automatically randomizes tests too. Let’s make the test fail on purpose and see what happens:

```sh
# Change the assertion in test/kv_test.exs to the following
assert KV.hello() == :oops

# Now run "mix test" again (notice this time there will be no compilation):
$ mix test
.

  1) test greets the world (KVTest)
     test/kv_test.exs:5
     Assertion with == failed
     code:  assert KV.hello() == :oops
     left:  :world
     right: :oops
     stacktrace:
       test/kv_test.exs:6: (test)



Finished in 0.03 seconds
1 doctest, 1 test, 1 failure

Randomized with seed 53599
```

For each failure, ExUnit prints a detailed report, containing the test name with the test case, the code that failed and the values for the left side and right side (rhs) of the == operator.

In the second line of the failure, right below the test name, there is the location where the test was defined. If you copy the test location in full, including the file and line number, and append it to mix test, Mix will load and run just that particular test:

```sh
$ mix test test/kv_test.exs:5
Excluding tags: [:test]
Including tags: [line: "5"]



  1) test greets the world (KVTest)
     test/kv_test.exs:5
     Assertion with == failed
     code:  assert KV.hello() == :oops
     left:  :world
     right: :oops
     stacktrace:
       test/kv_test.exs:6: (test)



Finished in 0.02 seconds
1 doctest, 1 test, 1 failure, 1 excluded

Randomized with seed 49393
```

This shortcut will be extremely useful as we build our project, allowing us to quickly iterate by running a single test.

Finally, the stacktrace relates to the failure itself, giving information about the test and often the place the failure was generated from within the source files.
### Automatic code formatting

```sh

```

### Environments

```sh

```

### Exploring

```sh

```
