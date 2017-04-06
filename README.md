# Pipeline

Prototype for handling GenStage `producer_consumer` crashes.

Dynamically named and linked stages recover successfully from random crashes
_provided_ the `:max_restarts` and `:max_seconds` count is high enough! In this
prototype `:max_restarts` is set to 10.

### Trying it out

```
$ git clone ...
$ cd pipeline
$ mix do deps.get, compile
$ iex -S mix
Erlang/OTP 19 [erts-8.2] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Compiling 1 file (.ex)
Elixir.Pipeline.HTTPRequestor1 subscribed!
Elixir.Pipeline.HTTPRequestor2 subscribed!
Elixir.Pipeline.HTTPRequestor3 subscribed!
Elixir.Pipeline.HTTPRequestor4 subscribed!
Elixir.Pipeline.HTTPRequestor5 subscribed!
Elixir.Pipeline.DBLoader1 subscribed!
Elixir.Pipeline.DBLoader2 subscribed!
Elixir.Pipeline.DBLoader3 subscribed!
Interactive Elixir (1.4.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Processed by Elixir.Pipeline.HTTPRequestor2: 11
Processed by Elixir.Pipeline.HTTPRequestor3: 21
Processed by Elixir.Pipeline.HTTPRequestor5: 41
Processed by Elixir.Pipeline.HTTPRequestor4: 31
Processed by Elixir.Pipeline.HTTPRequestor1: 1
Processed by Elixir.Pipeline.HTTPRequestor1: 2
Processed by Elixir.Pipeline.HTTPRequestor3: 22
Processed by Elixir.Pipeline.HTTPRequestor5: 42
Processed by Elixir.Pipeline.HTTPRequestor2: 12
...
```
