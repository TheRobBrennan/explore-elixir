# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/alias-require-and-import.html)

## alias, require, and import

In order to facilitate software reuse, Elixir provides three directives (alias, require and import) plus a macro called use summarized below:

```sh
# Alias the module so it can be called as Bar instead of Foo.Bar
alias Foo.Bar, as: Bar

# Require the module in order to use its macros
require Foo

# Import functions from Foo so they can be called without the `Foo.` prefix
import Foo

# Invokes the custom code defined in Foo as an extension point
use Foo
```

We are going to explore them in detail now. Keep in mind the first three are called directives because they have lexical scope, while use is a common extension point that allows the used module to inject code.

### alias

`alias` allows you to set up aliases for any given module name.

```sh
# Imagine a module uses a specialized list implemented in Math.List. The alias directive allows referring to Math.List just as List within the module definition
defmodule Stats do
  alias Math.List, as: List
  # In the remaining module definition List expands to Math.List.
end

# The original List can still be accessed within Stats by the fully-qualified name Elixir.List
# Note: All modules defined in Elixir are defined inside the main Elixir namespace. However, for convenience, you can omit “Elixir.” when referencing them.

# Aliases are frequently used to define shortcuts. In fact, calling alias without an :as option sets the alias automatically to the last part of the module name, for example:
alias Math.List
# ...is the same as:
alias Math.List, as: List

# Note that alias is lexically scoped, which allows you to set aliases inside specific functions
defmodule Math do
  def plus(a, b) do
    alias Math.List
    # ...
  end

  def minus(a, b) do
    # ...
  end
end
# In the example above, since we are invoking alias inside the function plus/2, the alias will be valid only inside the function plus/2. minus/2 won’t be affected at all.
```

### require

Elixir provides macros as a mechanism for meta-programming (writing code that generates code). Macros are expanded at compile time.

Public functions in modules are globally available, but in order to use macros, you need to opt-in by requiring the module they are defined in.

```sh
iex(1)> Integer.is_odd(3)
** (CompileError) iex:1: you must require Integer before invoking the macro Integer.is_odd/1
    (elixir) src/elixir_dispatch.erl:97: :elixir_dispatch.dispatch_require/6
iex(1)> require Integer
Integer
iex(2)> Integer.is_odd(3)
true
```

In Elixir, Integer.is_odd/1 is defined as a macro so that it can be used as a guard. This means that, in order to invoke Integer.is_odd/1, we need to first require the Integer module.

Note that like the alias directive, require is also lexically scoped. We will talk more about macros in a later chapter.

### import

We use import whenever we want to easily access functions or macros from other modules without using the fully-qualified name. For instance, if we want to use the duplicate/2 function from the List module several times, we can import it:

```sh
iex(3)> import List, only: [duplicate: 2]
List
iex(4)> duplicate :ok, 3
[:ok, :ok, :ok]

# In this case, we are importing only the function duplicate (with arity 2) from List. Although :only is optional, its usage is recommended in order to avoid importing all the functions of a given module inside the namespace. :except could also be given as an option in order to import everything in a module except a list of functions.

# import also supports :macros and :functions to be given to :only. For example, to import all macros, one could write
iex(5)> import Integer, only: :macros
Integer

# Or to import all functions, you could write:
iex(6)> import Integer, only: :functions
Integer
```

Note that import is lexically scoped too. This means that we can import specific macros or functions inside function definitions:

```sh
defmodule Math do
  def some_function do
    import List, only: [duplicate: 2]
    duplicate(:ok, 10)
  end
end
```

In the example above, the imported List.duplicate/2 is only visible within that specific function. duplicate/2 won’t be available in any other function in that module (or any other module for that matter).

Note that importing a module automatically requires it.

### use

The use macro is frequently used as an extension point. This means that, when you use a module FooBar, you allow that module to inject any code in the current module, such as importing itself or other modules, defining new functions, setting a module state, etc.

For example, in order to write tests using the ExUnit framework, a developer should use the ExUnit.Case module:

```sh
defmodule AssertionTest do
  use ExUnit.Case, async: true

  test "always pass" do
    assert true
  end
end
```

Behind the scenes, use requires the given module and then calls the __using__/1 callback on it allowing the module to inject some code into the current context. Some modules (for example, the above ExUnit.Case, but also Supervisor and GenServer) use this mechanism to populate your module with some basic behaviour, which your module is intended to override or complete.

```sh
# Generally speaking, the following module
defmodule Example do
  use Feature, option: :value
end

# is compiled into
defmodule Example do
  require Feature
  Feature.__using__(option: :value)
end
```

Since use allows any code to run, we can’t really know the side-effects of using a module without reading its documentation. For this reason, import and alias are often preferred, as their semantics are defined by the language.

### Understanding Aliases

At this point, you may be wondering: what exactly is an Elixir alias and how is it represented?

An alias in Elixir is a capitalized identifier (like String, Keyword, etc) which is converted to an atom during compilation. For instance, the String alias translates by default to the atom :"Elixir.String"

```sh
iex(1)> is_atom(String)
true
iex(2)> to_string(String)
"Elixir.String"
iex(3)> :"Elixir.String" == String
true
```

By using the alias/2 directive, we are changing the atom the alias expands to.

Aliases expand to atoms because in the Erlang VM (and consequently Elixir) modules are always represented by atoms. For example, that’s the mechanism we use to call Erlang modules:

```sh
iex(4)> :lists.flatten([1, [2], 3])
[1, 2, 3]

```

### Module nesting

Now that we have talked about aliases, we can talk about nesting and how it works in Elixir. Consider the following example:

```sh
defmodule Foo do
  defmodule Bar do
  end
end
```

The example above will define two modules: Foo and Foo.Bar. The second can be accessed as Bar inside Foo as long as they are in the same lexical scope. The code above is exactly the same as:

```sh
defmodule Elixir.Foo do
  defmodule Elixir.Foo.Bar do
  end
  alias Elixir.Foo.Bar, as: Bar
end
```

If, later, the Bar module is moved outside the Foo module definition, it must be referenced by its full name (Foo.Bar) or an alias must be set using the alias directive discussed above.

Note: in Elixir, you don’t have to define the Foo module before being able to define the Foo.Bar module, as the language translates all module names to atoms. You can define arbitrarily-nested modules without defining any module in the chain (e.g., Foo.Bar.Baz without defining Foo or Foo.Bar first).

As we will see in later chapters, aliases also play a crucial role in macros, to guarantee they are hygienic.

### Multi alias/import/require/use

From Elixir v1.2, it is possible to alias, import or require multiple modules at once. This is particularly useful once we start nesting modules, which is very common when building Elixir applications. For example, imagine you have an application where all modules are nested under MyApp, you can alias the modules MyApp.Foo, MyApp.Bar and MyApp.Baz at once as follows:

`alias MyApp.{Foo, Bar, Baz}`
