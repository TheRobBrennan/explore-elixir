# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/module-attributes.html)

## Module attributes

Module attributes in Elixir serve three purposes:

+ They serve to annotate the module, often with information to be used by the user or the VM.
+ They work as constants.
+ They work as a temporary module storage to be used during compilation.

### As annotations

Elixir brings the concept of module attributes from Erlang. For example:

```sh
defmodule MyServer do
  @vsn 2
end
```

In the example above, we are explicitly setting the version attribute for that module. `@vsn` is used by the code reloading mechanism in the Erlang VM to check if a module has been updated or not. If no version is specified, the version is set to the MD5 checksum of the module functions.

Elixir has a handful of reserved attributes. Here are a few of them, the most commonly used ones:

+ `@moduledoc` - provides documentation for the current module.
+ `@doc` - provides documentation for the function or macro that follows the attribute.
+ `@behaviour` - (notice the British spelling) used for specifying an OTP or user-defined behaviour.
+ `@before_compile` - provides a hook that will be invoked before the module is compiled. This makes it possible to inject functions inside the module exactly before compilation.
+ `@moduledoc` and `@doc` are by far the most used attributes, and we expect you to use them a lot. Elixir treats documentation as first-class and provides many functions to access documentation. You can read more about writing documentation in Elixir in our official documentation.

Let's add some documentation to `math.ex`

Elixir promotes the use of Markdown with heredocs to write readable documentation. Heredocs are multi-line strings, they start and end with triple double-quotes, keeping the formatting of the inner text. We can access the documentation of any compiled module directly from IEx:

```sh
# Compile our module and newly added annotations
$ elixirc math.ex
$ iex

iex(1)> h Math # Access the docs for the module Math

                                      Math                                      

Provides math-related functions.

## Examples

    iex> Math.sum(1, 2)
    3

iex(2)> h Math.sum # Access the docs for the sum function

                                 def sum(a, b)                                  

Calculates the sum of two numbers.
```

We also provide a tool called ExDoc which is used to generate HTML pages from the documentation.

You can take a look at the docs for Module for a complete list of supported attributes. Elixir also uses attributes to define typespecs.

This section covers built-in attributes. However, attributes can also be used by developers or extended by libraries to support custom behaviour.

### As constants

```sh
# Elixir developers will often use module attributes as constants
defmodule MyServer do
  @initial_state %{host: "127.0.0.1", port: 3456}
  IO.inspect @initial_state
end

iex(4)> defmodule MyServer do
...(4)>   @initial_state %{host: "127.0.0.1", port: 3456}
...(4)>   IO.inspect @initial_state
...(4)> end
%{host: "127.0.0.1", port: 3456}
{:module, MyServer,
 <<70, 79, 82, 49, 0, 0, 3, 152, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 122,
   0, 0, 0, 12, 15, 69, 108, 105, 120, 105, 114, 46, 77, 121, 83, 101, 114, 118,
   101, 114, 8, 95, 95, 105, 110, 102, 111, ...>>,
 %{host: "127.0.0.1", port: 3456}}

# Trying to access an attribute that was not defined will print a warning
iex(1)> defmodule MyServer do
...(1)>   @unknown
...(1)> end
warning: undefined module attribute @unknown, please remove access to @unknown or explicitly set it before access
  iex:2: MyServer (module)

{:module, MyServer,
 <<70, 79, 82, 49, 0, 0, 3, 152, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 122,
   0, 0, 0, 12, 15, 69, 108, 105, 120, 105, 114, 46, 77, 121, 83, 101, 114, 118,
   101, 114, 8, 95, 95, 105, 110, 102, 111, ...>>, nil}

# Finally, attributes can also be read inside functions
defmodule MyServer do
  @my_data 14
  def first_data, do: @my_data
  @my_data 13
  def second_data, do: @my_data
end

MyServer.first_data #=> 14
MyServer.second_data #=> 13
```

Every time an attribute is read inside a function, a snapshot of its current value is taken. In other words, the value is read at compilation time and not at runtime. As we are going to see, this also makes attributes useful to be used as storage during module compilation.

Any functions may be called when defining a module attribute.

When defining an attribute, do not leave a line break between the attribute name and its value.

### As temporary storage

One of the projects in the Elixir organization is the Plug project, which is meant to be a common foundation for building web libraries and frameworks in Elixir.

The Plug library also allows developers to define their own plugs which can be run in a web server:

```sh
defmodule MyPlug do
  use Plug.Builder

  plug :set_header
  plug :send_ok

  def set_header(conn, _opts) do
    put_resp_header(conn, "x-header", "set")
  end

  def send_ok(conn, _opts) do
    send_resp(conn, 200, "ok")
  end
end

IO.puts "Running MyPlug with Cowboy on http://localhost:4000"
Plug.Adapters.Cowboy.http MyPlug, []
```

In the example above, we have used the `plug/1` macro to connect functions that will be invoked when there is a web request. Internally, every time you call `plug/1`, the Plug library stores the given argument in a @plugs attribute. Just before the module is compiled, Plug runs a callback that defines a function (`call/2`) which handles HTTP requests. This function will run all plugs inside @plugs in order.

In order to understand the underlying code, we’d need macros, so we will revisit this pattern in the meta-programming guide. However, the focus here is on how using module attributes as storage allows developers to create DSLs.

Another example comes from the ExUnit framework which uses module attributes as annotation and storage:

```sh
defmodule MyTest do
  use ExUnit.Case

  @tag :external
  test "contacts external service" do
    # ...
  end
end
```

Tags in ExUnit are used to annotate tests. Tags can be later used to filter tests. For example, you can avoid running external tests on your machine because they are slow and dependent on other services, while they can still be enabled in your build system.

We hope this section shines some light on how Elixir supports meta-programming and how module attributes play an important role when doing so.

In the next chapters, we’ll explore structs and protocols before moving to exception handling and other constructs like sigils and comprehensions.
