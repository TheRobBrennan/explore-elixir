# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/where-to-go-next.html)

## Where to go next

Eager to learn more? Keep reading!

### Build your first Elixir project

In order to get your first project started, Elixir ships with a build tool called Mix. You can get your new project started by running:

```sh
$ mix new path/to/new/project
```

We have written a guide that covers how to build an Elixir application, with its own supervision tree, configuration, tests, and more. The application works as a distributed key-value store where we organize key-value pairs into buckets and distribute those buckets across multiple nodes - Mix and OTP.

If you are planning to write your first library for other developers to use, don’t forget to read our Library Guidelines.

### Meta-programming

Elixir is an extensible and very customizable programming language thanks to its meta-programming support. Most meta-programming in Elixir is done through macros, which are very useful in several situations, especially for writing DSLs. We have written a short guide that explains the basic mechanisms behind macros, shows how to write macros, and how to use macros to create DSLs.

### Community and other resources

We have a Learning section that suggests books, screencasts, and other resources for learning Elixir and exploring the ecosystem. There are also plenty of Elixir resources out there, like conference talks, open source projects, and other learning material produced by the community.

Don’t forget that you can also check the source code of Elixir itself, which is mostly written in Elixir (mainly the lib directory), or explore Elixir’s documentation.

### A byte of Erlang

Elixir runs on the Erlang Virtual Machine and, sooner or later, an Elixir developer will want to interface with existing Erlang libraries. Here’s a list of online resources that cover Erlang’s fundamentals and its more advanced features:

This Erlang Syntax: A Crash Course provides a concise intro to Erlang’s syntax. Each code snippet is accompanied by equivalent code in Elixir. This is an opportunity for you to not only get some exposure to Erlang’s syntax but also review some of the things you have learned in this guide.

Erlang’s official website has a short tutorial with pictures that briefly describe Erlang’s primitives for concurrent programming.

Learn You Some Erlang for Great Good! is an excellent introduction to Erlang, its design principles, standard library, best practices, and much more. Once you have read through the crash course mentioned above, you’ll be able to safely skip the first couple of chapters in the book that mostly deal with the syntax. When you reach The Hitchhiker’s Guide to Concurrency chapter, that’s where the real fun starts.
