# Welcome

This folder has been created to contain useful commands and observations that correlated to the original [guide](https://elixir-lang.org/getting-started/io-and-the-file-system.html)

## IO and the file system

This chapter is a quick introduction to input/output mechanisms and file-system-related tasks, as well as to related modules like IO, File and Path.

We had originally sketched this chapter to come much earlier in the getting started guide. However, we noticed the IO system provides a great opportunity to shed some light on some philosophies and curiosities of Elixir and the VM.

### The IO module

The IO module is the main mechanism in Elixir for reading and writing to standard input/output (:stdio), standard error (:stderr), files, and other IO devices. Usage of the module is pretty straightforward.

```sh
iex(1)> IO.puts("hello world")
hello world
:ok
iex(2)> IO.gets("yes or no? ")
yes or no? yes
"yes\n"

# By default, functions in the IO module read from the standard input and write to the standard output. We can change that by passing, for example, :stderr as an argument (in order to write to the standard error device)
iex(3)> IO.puts(:stderr, "hello world")
hello world
:ok

```

### The File module

The File module contains functions that allow us to open files as IO devices. By default, files are opened in binary mode, which requires developers to use the specific IO.binread/2 and IO.binwrite/2 functions from the IO module.

```sh
iex(5)> {:ok, file} = File.open("hello", [:write])
{:ok, #PID<0.110.0>}
iex(6)> IO.binwrite(file, "world")
:ok
iex(7)> File.close(file)
:ok
iex(8)> File.read("hello")
{:ok, "world"}
```

A file can also be opened with :utf8 encoding, which tells the File module to interpret the bytes read from the file as UTF-8-encoded bytes.

Besides functions for opening, reading and writing files, the File module has many functions to work with the file system. Those functions are named after their UNIX equivalents. For example, File.rm/1 can be used to remove files, File.mkdir/1 to create directories, File.mkdir_p/1 to create directories and all their parent chain. There are even File.cp_r/2 and File.rm_rf/1 to respectively copy and remove files and directories recursively (i.e., copying and removing the contents of the directories too).

You will also notice that functions in the File module have two variants: one “regular” variant and another variant with a trailing bang (!). For example, when we read the "hello" file in the example above, we use File.read/1. Alternatively, we can use File.read!/1:

```sh
iex(10)> File.read("hello")
{:ok, "world"}
iex(11)> File.read!("hello")
"world"
iex(12)> File.read("unknown")
{:error, :enoent}
iex(13)> File.read!("unknown")
** (File.Error) could not read file "unknown": no such file or directory
    (elixir) lib/file.ex:353: File.read!/1
```

Notice that the version with ! returns the contents of the file instead of a tuple, and if anything goes wrong the function raises an error.

The version without ! is preferred when you want to handle different outcomes using pattern matching:

```sh
case File.read(file) do
  {:ok, body}      -> # do something with the `body`
  {:error, reason} -> # handle the error caused by `reason`
end
```

However, if you expect the file to be there, the bang variation is more useful as it raises a meaningful error message. Avoid writing:

```sh
{:ok, body} = File.read(file)
```

As, in case of an error, `File.read/1` will return {:error, reason} and the pattern matching will fail. You will still get the desired result (a raised error), but the message will be about the pattern which doesn’t match (thus being cryptic in respect to what the error actually is about).

Therefore, if you don’t want to handle the error outcomes, prefer using `File.read!/1`

### The Path module

The majority of the functions in the File module expect paths as arguments. Most commonly, those paths will be regular binaries. The Path module provides facilities for working with such paths:

```sh
iex(14)> Path.join("foo", "bar")
"foo/bar"
iex(15)> Path.expand("~/hello")
"/Users/rob/hello"
```

Using functions from the Path module as opposed to directly manipulating strings is preferred since the Path module takes care of different operating systems transparently. Finally, keep in mind that Elixir will automatically convert slashes (/) into backslashes (\) on Windows when performing file operations.

With this, we have covered the main modules that Elixir provides for dealing with IO and interacting with the file system. In the next sections, we will discuss some advanced topics regarding IO. Those sections are not necessary in order to write Elixir code, so feel free to skip them, but they do provide a nice overview of how the IO system is implemented in the VM and other curiosities.

### Processes and group leaders

```sh
# You may have noticed that File.open/2 returns a tuple like {:ok, pid}
iex(17)> {:ok, file} = File.open("hello", [:write])
{:ok, #PID<0.124.0>}

# That happens because the IO module actually works with processes (see chapter 11). Given a file is a process, when you write to a file that has been closed, you are actually sending a message to a process which has been terminated
iex(18)> File.close(file)
:ok
iex(19)> IO.write(file, "is anybody out there")
** (ErlangError) Erlang error: :terminated
    (stdlib) :io.put_chars(#PID<0.124.0>, :unicode, "is anybody out there")
```

Let’s see in more detail what happens when you request IO.write(pid, binary). The IO module sends a message to the process identified by pid with the desired operation. A small ad-hoc process can help us see it:

```sh
iex(20)> pid = spawn fn ->
...(20)>   receive do: (msg -> IO.inspect msg)
...(20)> end
#PID<0.131.0>
iex(21)> IO.write(pid, "hello")
{:io_request, #PID<0.104.0>, #Reference<0.2866775154.1890582532.98912>,
 {:put_chars, :unicode, "hello"}}
** (ErlangError) Erlang error: :terminated
    (stdlib) :io.put_chars(#PID<0.131.0>, :unicode, "hello")
```

After IO.write/2, we can see the request sent by the IO module (a four-elements tuple) printed out. Soon after that, we see that it fails since the IO module expected some kind of result, which we did not supply.

By modeling IO devices with processes, the Erlang VM allows I/O messages to be routed between different nodes running Distributed Erlang or even exchange files to perform read/write operations across nodes.

### iodata and chardata

In all of the examples above, we used binaries when writing to files. In the chapter “Binaries, strings, and charlists”, we mentioned how strings are made of bytes while charlists are lists with Unicode codepoints.

The functions in IO and File also allow lists to be given as arguments. Not only that, they also allow a mixed list of lists, integers, and binaries to be given:

```sh
iex(22)> IO.puts('hello world')
hello world
:ok
iex(23)> IO.puts(['hello', ?\s, "world"])
hello world
:ok
```

However, using lists in IO operations requires some attention. A list may represent either a bunch of bytes or a bunch of characters and which one to use depends on the encoding of the IO device. If the file is opened without encoding, the file is expected to be in raw mode, and the functions in the IO module starting with bin* must be used. Those functions expect an iodata as an argument; i.e., they expect a list of integers representing bytes or binaries to be given.

On the other hand, :stdio and files opened with :utf8 encoding work with the remaining functions in the IO module. Those functions expect a char_data as an argument, that is, a list of characters or strings.

Although this is a subtle difference, you only need to worry about these details if you intend to pass lists to those functions. Binaries are already represented by the underlying bytes and as such their representation is always “raw”.

This finishes our tour of IO devices and IO related functionality. We have learned about three Elixir modules - IO, File, and Path - as well as how the VM uses processes for the underlying IO mechanisms and how to use chardata and iodata for IO operations.
