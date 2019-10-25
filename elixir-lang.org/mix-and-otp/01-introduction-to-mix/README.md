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

One of the files generated by `mix new` is the `.formatter.exs`. Elixir ships with a code formatter that is capable of automatically formatting our codebase according to a consistent style. The formatter is triggered with the `mix format` task. The generated `.formatter.exs` file configures which files should be formatted when `mix format` runs.

To give the formatter a try, change a file in the lib or test directories to include extra spaces or extra newlines, such as `def hello do`, and then run `mix format`.

Most editors provide built-in integration with the formatter, allowing a file to be formatted on save or via a chosen keybinding. If you are learning Elixir, editor integration gives you useful and quick feedback when learning the Elixir syntax.

For companies and teams, we recommend developers to run `mix format --check-formatted` on their continuous integration servers, ensuring all current and future code follows the standard.

You can learn more about the code formatter by checking the format task documentation or by reading the release announcement for Elixir v1.6, the first version to include the formatter.

### Environments

Mix provides the concept of “environments”. They allow a developer to customize compilation and other options for specific scenarios. By default, Mix understands three environments:

`:dev` - the one in which Mix tasks (like `compile`) run by default
`:test` - used by mix test
`:prod` - the one you will use to run your project in production

The environment applies only to the current project. As we will see in future chapters, any dependency you add to your project will by default run in the `:prod` environment.

Customization per environment can be done by accessing the `Mix.env` function in your `mix.exs` file, which returns the current environment as an atom. That’s what we have used in the `:start_permanent options`:

```sh
def project do
  [
    ...,
    start_permanent: Mix.env == :prod,
    ...
  ]
end
```

When true, the `:start_permanent` option starts your application in `permanent` mode, which means the Erlang VM will crash if your application’s supervision tree shuts down. Notice we don’t want this behaviour in `dev` and `test` because it is useful to keep the VM instance running in those environments for troubleshooting purposes.

Mix will default to the `:dev` environment, except for the test task that will default to the `:test` environment. The environment can be changed via the `MIX_ENV` environment variable:

```sh
$ MIX_ENV=prod mix compile
```

Mix is a build tool and, as such, it is not expected to be available in production. Therefore, it is recommended to access `Mix.env` only in configuration files and inside `mix.exs`, never in your application code (`lib`).

### Exploring

There is much more to Mix, and we will continue to explore it as we build our project. A general overview is available on the Mix documentation. Read the Mix source code here.

Keep in mind that you can always invoke the help task to list all available tasks:

```sh
$ mix help
mix                   # Runs the default task (current: "mix run")
mix app.start         # Starts all registered apps
mix app.tree          # Prints the application tree
mix archive           # Lists installed archives
mix archive.build     # Archives this project into a .ez file
mix archive.install   # Installs an archive locally
mix archive.uninstall # Uninstalls archives
mix clean             # Deletes generated application files
mix cmd               # Executes the given command
mix compile           # Compiles source files
mix deps              # Lists dependencies and their status
mix deps.clean        # Deletes the given dependencies' files
mix deps.compile      # Compiles dependencies
mix deps.get          # Gets all out of date dependencies
mix deps.tree         # Prints the dependency tree
mix deps.unlock       # Unlocks the given dependencies
mix deps.update       # Updates the given dependencies
mix do                # Executes the tasks separated by comma
mix escript           # Lists installed escripts
mix escript.build     # Builds an escript for the project
mix escript.install   # Installs an escript locally
mix escript.uninstall # Uninstalls escripts
mix format            # Formats the given files/patterns
mix help              # Prints help information for tasks
mix hex               # Prints Hex help information
mix hex.audit         # Shows retired Hex deps for the current project
mix hex.build         # Builds a new package version locally
mix hex.config        # Reads, updates or deletes local Hex config
mix hex.docs          # Fetches or opens documentation of a package
mix hex.info          # Prints Hex information
mix hex.organization  # Manages Hex.pm organizations
mix hex.outdated      # Shows outdated Hex deps for the current project
mix hex.owner         # Manages Hex package ownership
mix hex.package       # Fetches or diffs packages
mix hex.publish       # Publishes a new package version
mix hex.repo          # Manages Hex repositories
mix hex.retire        # Retires a package version
mix hex.search        # Searches for package names
mix hex.user          # Manages your Hex user account
mix loadconfig        # Loads and persists the given configuration
mix local             # Lists local tasks
mix local.hex         # Installs Hex locally
mix local.phx         # Updates the Phoenix project generator locally
mix local.public_keys # Manages public keys
mix local.rebar       # Installs Rebar locally
mix new               # Creates a new Elixir project
mix phx.new           # Creates a new Phoenix v1.4.10 application
mix phx.new.ecto      # Creates a new Ecto project within an umbrella project
mix phx.new.web       # Creates a new Phoenix web project within an umbrella project
mix profile.cprof     # Profiles the given file or expression with cprof
mix profile.eprof     # Profiles the given file or expression with eprof
mix profile.fprof     # Profiles the given file or expression with fprof
mix release           # Assembles a self-contained release
mix release.init      # Generates sample files for releases
mix run               # Starts and runs the current application
mix test              # Runs a project's tests
mix xref              # Performs cross reference checks
iex -S mix            # Starts IEx and runs the default task
```

You can get further information about a particular task by invoking `mix help TASK`
