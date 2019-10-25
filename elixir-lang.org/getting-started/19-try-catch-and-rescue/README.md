# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/try-catch-and-rescue.html)

## try, catch, and rescue

Elixir has three error mechanisms: errors, throws, and exits. In this chapter, we will explore each of them and include remarks about when each should be used.

### Errors

```sh
# Errors (or exceptions) are used when exceptional things happen in the code. A sample error can be retrieved by trying to add a number into an atom
iex(1)> :foo + 1
** (ArithmeticError) bad argument in arithmetic expression: :foo + 1
    :erlang.+(:foo, 1)

# A runtime error can be raised any time by using raise/1
iex(1)> raise "oops"
** (RuntimeError) oops

# Other errors can be raised with raise/2 passing the error name and a list of keyword arguments
iex(1)> raise ArgumentError, message: "invalid argument foo"
** (ArgumentError) invalid argument foo

# You can also define your own errors by creating a module and using the defexception construct inside it; this way, you’ll create an error with the same name as the module it’s defined in. The most common case is to define a custom exception with a message field
iex(1)> defmodule MyError do
...(1)>   defexception message: "default message"
...(1)> end
{:module, MyError,
 <<70, 79, 82, 49, 0, 0, 11, 240, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 1, 72,
   0, 0, 0, 33, 14, 69, 108, 105, 120, 105, 114, 46, 77, 121, 69, 114, 114, 111,
   114, 8, 95, 95, 105, 110, 102, 111, 95, ...>>, :ok}
iex(2)> raise MyError
** (MyError) default message

iex(2)> raise MyError, message: "custom message"
** (MyError) custom message

# Errors can be rescued using the try/rescue construct
iex(2)> try do
...(2)>   raise "oops"
...(2)> rescue
...(2)>   e in RuntimeError -> e
...(2)> end
%RuntimeError{message: "oops"}
# The example above rescues the runtime error and returns the error itself which is then printed in the iex session.

# If you don’t have any use for the error, you don’t have to provide it:
iex(4)> try do
...(4)>   raise "oops"
...(4)> rescue
...(4)>   RuntimeError -> "Error!"
...(4)> end
"Error!"

# In practice, however, Elixir developers rarely use the try/rescue construct. For example, many languages would force you to rescue an error when a file cannot be opened successfully. Elixir instead provides a File.read/1 function which returns a tuple containing information about whether the file was opened successfully
iex(6)> File.read "hello"
{:error, :enoent}
iex(7)> File.write "hello", "world"
:ok
iex(8)> File.read "hello"
{:ok, "world"}

# There is no try/rescue here. In case you want to handle multiple outcomes of opening a file, you can use pattern matching within the case construct
ex(1)> case File.read "hello" do
...(1)>   {:ok, body}      -> IO.puts "Success: #{body}"
...(1)>   {:error, reason} -> IO.puts "Error: #{reason}"
...(1)> end
Success: world
:ok

# At the end of the day, it’s up to your application to decide if an error while opening a file is exceptional or not. That’s why Elixir doesn’t impose exceptions on File.read/1 and many other functions. Instead, it leaves it up to the developer to choose the best way to proceed.

# For the cases where you do expect a file to exist (and the lack of that file is truly an error) you may use File.read!/1
iex(2)> File.read! "unknown"
** (File.Error) could not read file "unknown": no such file or directory
    (elixir) lib/file.ex:353: File.read!/1
```

Many functions in the standard library follow the pattern of having a counterpart that raises an exception instead of returning tuples to match against. The convention is to create a function (foo) which returns {:ok, result} or {:error, reason} tuples and another function (foo!, same name but with a trailing !) that takes the same arguments as foo but which raises an exception if there’s an error. foo! should return the result (not wrapped in a tuple) if everything goes fine. The File module is a good example of this convention.

In Elixir, we avoid using try/rescue because we don’t use errors for control flow. We take errors literally: they are reserved for unexpected and/or exceptional situations. In case you actually need flow control constructs, throws should be used. That’s what we are going to see next.

### Throws

In Elixir, a value can be thrown and later be caught. throw and catch are reserved for situations where it is not possible to retrieve a value unless by using throw and catch.

```sh
# Those situations are quite uncommon in practice except when interfacing with libraries that do not provide a proper API. For example, let’s imagine the Enum module did not provide any API for finding a value and that we needed to find the first multiple of 13 in a list of numbers:
iex(3)> try do
...(3)>   Enum.each -50..50, fn(x) ->
...(3)>     if rem(x, 13) == 0, do: throw(x)
...(3)>   end
...(3)>   "Got nothing."
...(3)> catch
...(3)>   x -> "Got #{x}"
...(3)> end
"Got -39"

# Since Enum does provide a proper API, in practice Enum.find/2 is the way to go:
iex(4)> Enum.find -50..50, &(rem(&1, 13) == 0)
-39
```

### Exits

All Elixir code runs inside processes that communicate with each other. When a process dies of “natural causes” (e.g., unhandled exceptions), it sends an exit signal. A process can also die by explicitly sending an exit signal:

```sh
iex(7)> spawn_link fn -> exit(1) end
** (EXIT from #PID<0.104.0>) shell process exited with reason: 1

# In the example above, the linked process died by sending an exit signal with a value of 1. The Elixir shell automatically handles those messages and prints them to the terminal.

# exit can also be “caught” using try/catch
iex(1)> try do
...(1)>   exit "I am exiting"
...(1)> catch
...(1)>   :exit, _ -> "not really"
...(1)> end
"not really"
```

Using try/catch is already uncommon and using it to catch exits is even rarer.

`exit` signals are an important part of the fault tolerant system provided by the Erlang VM. Processes usually run under supervision trees which are themselves processes that listen to `exit` signals from the supervised processes. Once an `exit` signal is received, the supervision strategy kicks in and the supervised process is restarted.

It is exactly this supervision system that makes constructs like `try/catch` and `try/rescue` so uncommon in Elixir. Instead of rescuing an error, we’d rather “fail fast” since the supervision tree will guarantee our application will go back to a known initial state after the error.

### After

```sh
# Sometimes it’s necessary to ensure that a resource is cleaned up after some action that could potentially raise an error. The try/after construct allows you to do that. For example, we can open a file and use an after clause to close it–even if something goes wrong
iex(3)> {:ok, file} = File.open "sample", [:utf8, :write]
{:ok, #PID<0.132.0>}
iex(4)> try do
...(4)>   IO.write file, "olá"
...(4)>   raise "oops, something went wrong"
...(4)> after
...(4)>   File.close(file)
...(4)> end
** (RuntimeError) oops, something went wrong

# The after clause will be executed regardless of whether or not the tried block succeeds. Note, however, that if a linked process exits, this process will exit and the after clause will not get run. Thus after provides only a soft guarantee. Luckily, files in Elixir are also linked to the current processes and therefore they will always get closed if the current process crashes, independent of the after clause. You will find the same to be true for other resources like ETS tables, sockets, ports and more.

# Sometimes you may want to wrap the entire body of a function in a try construct, often to guarantee some code will be executed afterwards. In such cases, Elixir allows you to omit the try line:
iex(5)> defmodule RunAfter do
...(5)>   def without_even_trying do
...(5)>     raise "oops"
...(5)>   after
...(5)>     IO.puts "cleaning up!"
...(5)>   end
...(5)> end
{:module, RunAfter,
 <<70, 79, 82, 49, 0, 0, 5, 208, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 230,
   0, 0, 0, 19, 15, 69, 108, 105, 120, 105, 114, 46, 82, 117, 110, 65, 102, 116,
   101, 114, 8, 95, 95, 105, 110, 102, 111, ...>>, {:without_even_trying, 0}}
iex(6)> RunAfter.without_even_trying
cleaning up!
** (RuntimeError) oops
    iex:7: RunAfter.without_even_trying/0
# Elixir will automatically wrap the function body in a try whenever one of after, rescue or catch is specified.
```

### Else

```sh
# If an else block is present, it will match on the results of the try block whenever the try block finishes without a throw or an error.
iex(7)> x = 2
2
iex(8)> try do
...(8)>   1 / x
...(8)> rescue
...(8)>   ArithmeticError ->
...(8)>     :infinity
...(8)> else
...(8)>   y when y < 1 and y > -1 ->
...(8)>     :small
...(8)>   _ ->
...(8)>     :large
...(8)> end
:small

# Exceptions in the else block are not caught. If no pattern inside the else block matches, an exception will be raised; this exception is not caught by the current try/catch/rescue/after block.
```

### Variables scope

```sh
# It is important to bear in mind that variables defined inside try/catch/rescue/after blocks do not leak to the outer context. This is because the try block may fail and as such the variables may never be bound in the first place.

# In other words, this code is invalid:
iex(10)> try do
...(10)>   raise "fail"
...(10)>   what_happened = :did_not_raise
...(10)> rescue
...(10)>   _ -> what_happened = :rescued
...(10)> end
warning: variable "what_happened" is unused (if the variable is not meant to be used, prefix it with an underscore)
  iex:12

warning: variable "what_happened" is unused (if the variable is not meant to be used, prefix it with an underscore)
  iex:14

:rescued
iex(11)> what_happened
** (CompileError) iex:11: undefined function what_happened/0

# Instead, you can store the value of the try expression:
iex(12)> what_happened =
...(12)>   try do
...(12)>     raise "fail"
...(12)>     :did_not_raise
...(12)>   rescue
...(12)>     _ -> :rescued
...(12)>   end
:rescued
iex(13)> what_happened
:rescued
```

This finishes our introduction to try, catch, and rescue. You will find they are used less frequently in Elixir than in other languages, although they may be handy in some situations where a library or some particular code is not playing “by the rules”
