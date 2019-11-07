# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/mix-otp/agent.html)

## Agent

In this chapter, we will learn how to keep and share state between multiple entities. If you have previous programming experience, you may think of globally shared variables, but the model we will learn here is quite different. The next chapters will generalize the concepts introduced here.

If you have skipped the Getting Started guide or read it long ago, be sure to re-read the [Processes](https://elixir-lang.org/getting-started/processes.html) chapter. We will use it as a starting point.

### The trouble with state

Elixir is an immutable language where nothing is shared by default. If we want to share information, which can be read and modified from multiple places, we have two main options in Elixir:

+ Using Processes and message passing
+ ETS (Erlang Term Storage) - [http://www.erlang.org/doc/man/ets.html](http://www.erlang.org/doc/man/ets.html)

We covered processes in the Getting Started guide. ETS is a new topic that we will explore in later chapters. When it comes to processes though, we rarely hand-roll our own, instead we use the abstractions available in Elixir and OTP:

+ [Agent](https://hexdocs.pm/elixir/Agent.html) - Simple wrappers around state.
+ [GenServer](https://hexdocs.pm/elixir/GenServer.html) - “Generic servers” (processes) that encapsulate state, provide sync and async calls, support code reloading, and more.
+ [Task](https://hexdocs.pm/elixir/Task.html) - Asynchronous units of computation that allow spawning a process and potentially retrieving its result at a later time.

We will explore most of these abstractions in this guide. Keep in mind that they are all implemented on top of processes using the basic features provided by the VM, like `send`, `receive`, `spawn` and `link`.

Here we will use Agents, and create a module named `KV.Bucket`, responsible for storing our key-value entries in a way that allows them to be read and modified by other processes.

### Agents

Agents are simple wrappers around state. If all you want from a process is to keep state, agents are a great fit. Let’s start an iex session inside the project with:

```sh
$ cd elixir-lang.org/mix-and-otp/kv
$ iex -S mix

# Let's play a bit with agents

# Start an agent with an initial state of an empty list
iex(1)> {:ok, agent} = Agent.start_link fn -> [] end
{:ok, #PID<0.134.0>}

# Update the agent's state by adding a new item to the head of the list
# NOTE: The second argument of Agent.update/3 is a function that takes the agent’s current state as input and returns its desired new state.
iex(2)> Agent.update(agent, fn list -> ["eggs" | list] end)
:ok

# Retrieve the whole list
# NOTE: The second argument of Agent.get/3 is a function that takes the state as input and returns the value that Agent.get/3 itself will return.
iex(3)> Agent.get(agent, fn list -> list end)
["eggs"]

# Once we are done with the agent, we can call Agent.stop/3 to terminate the agent process.
iex(4)> Agent.stop(agent)
:ok
```

The `Agent.update/3` function accepts as a second argument any function that receives one argument and returns a value:

```sh
iex(6)> {:ok, agent} = Agent.start_link fn -> [] end
{:ok, #PID<0.141.0>}
iex(7)> Agent.update(agent, fn _list -> 123 end)
:ok
iex(8)> Agent.update(agent, fn content -> %{a: content} end)
:ok
iex(9)> Agent.update(agent, fn content -> [12 | [content]] end)
:ok
iex(10)>  Agent.update(agent, fn list -> [:nop | list] end)
:ok
iex(11)> Agent.get(agent, fn content -> content end)
[:nop, 12, %{a: 123}]
iex(12)> Agent.stop(agent)
:ok
```

As you can see, we can modify the agent state in any way we want. Therefore, we most likely don’t want to access the Agent API throughout many different places in our code. Instead, we want to encapsulate all Agent-related functionality in a single module, which we will call `KV.Bucket`. Before we implement it, let’s write some tests which will outline the API exposed by our module.

Take a look at `elixir-lang.org/mix-and-otp/kv/test/kv/bucket_test.exs`.

`use ExUnit.Case` is responsible for setting up our module for testing and imports many test-related functionality, such as the `test/2` macro.

Our first test starts a new `KV.Bucket` by calling the `start_link/1` and passing an empty list of options. Then we perform some `get/2` and `put/3` operations on it, asserting the result.

Also note the `async: true` option passed to `ExUnit.Case`. This option makes the test case run in parallel with other `:async` test cases by using multiple cores in our machine. This is extremely useful to speed up our test suite. However, `:async` must only be set if the test case does not rely on or change any global values.

IMPORTANT: If the test requires writing to the filesystem or access a database, keep it synchronous (omit the :async option) to avoid race conditions between tests.

Async or not, our new test should obviously fail, as none of the functionality is implemented in the module being tested:

```sh
$ mix test 
  1) test stores values by key (KV.BucketTest)
     test/kv/bucket_test.exs:4
     ** (UndefinedFunctionError) function KV.Bucket.start_link/1 is undefined (module KV.Bucket is not available)
     code: {:ok, bucket} = KV.Bucket.start_link([])
     stacktrace:
       KV.Bucket.start_link([])
       test/kv/bucket_test.exs:5: (test)

..

Finished in 0.04 seconds
1 doctest, 2 tests, 1 failure

Randomized with seed 987794
```

Let's fix this failing test by implementing our `KV.Bucket` module at `elixir-lang.org/mix-and-otp/kv/lib/kv/bucket.ex`

The first step in our implementation is to call `use Agent`.

Then we define a `start_link/1` function, which will effectively start the agent. It is a convention to define a `start_link/1` function that always accepts a list of options. We don’t plan on using any options right now, but we might later on. We then proceed to call `Agent.start_link/1`, which receives an anonymous function that returns the Agent’s initial state.

We are keeping a map inside the agent to store our keys and values. Getting and putting values on the map is done with the Agent API and the capture operator `&`, introduced in the [Getting Started](https://elixir-lang.org/getting-started/modules-and-functions.html#function-capturing) guide.

Now that the `KV.Bucket` module has been defined, our test should pass! You can try it yourself by running:

```sh
$ mix test
Compiling 1 file (.ex)
Generated kv app
...

Finished in 0.02 seconds
1 doctest, 2 tests, 0 failures

Randomized with seed 58950
```

### Test setup with ExUnit callbacks

Before moving on and adding more features to `KV.Bucket`, let’s talk about ExUnit callbacks. As you may expect, all `KV.Bucket` tests will require a bucket agent to be up and running. Luckily, ExUnit supports callbacks that allow us to skip such repetitive tasks.

Let’s rewrite the test case at `elixir-lang.org/mix-and-otp/kv/test/kv/bucket_test.exs` to use callbacks.

We have first defined a setup callback with the help of the `setup/1` macro. The `setup/1` macro defines a callback that is run before every test, in the same process as the test itself.

Note that we need a mechanism to pass the `bucket` pid from the callback to the test. We do so by using the test context. When we return `%{bucket: bucket}` from the callback, ExUnit will merge this map into the test context. Since the test context is a map itself, we can pattern match the bucket out of it, providing access to the bucket inside the test.

How? By changing the original `test "stores values by key" do` to `test "stores values by key", %{bucket: bucket} do`

### Other agent functions

Besides getting a value and updating the agent state, agents allow us to get a value and update the agent state in one function call via `Agent.get_and_update/2`. Let’s implement a `KV.Bucket.delete/2` function that deletes a key from the bucket, returning its current value

```sh
# elixir-lang.org/mix-and-otp/kv/lib/kv/bucket.ex
@doc """
Deletes `key` from `bucket`.

Returns the current value of `key`, if `key` exists.
"""
def delete(bucket, key) do
  Agent.get_and_update(bucket, &Map.pop(&1, key))
end
```

CHALLENGE: Update `elixir-lang.org/mix-and-otp/kv/test/kv/bucket_test.exs` to test the new functionality.

### Client/Server in agents

```sh

```
