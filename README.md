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
```

### In action

You can see the 5 `HTTP.Requestor` `producer_consumer`s subscribe to the `producer`
on startup, followed by the `DB.Loader` `consumer`s.

Each `HTTP.Requestor` takes 10 events, so 5 are processing concurrently. You can
see below that after the 67th event is processed, the `HTTPRequestor5` crashes,
and appears to take down the three `DB.Loader` consumers with it.

However, you can see in the console that `HTTPRequestor5` resubscribes to the
producer immediately followed by the three `DB.Loader` consumers subscribing to
it. They begin processing events soon after.

```
$iex -S mix
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
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
[11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
[21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
[31, 32, 33, 34, 35, 36, 37, 38, 39, 40]
')*+,-./012'
iex(1)> Processed by Elixir.Pipeline.HTTPRequestor1: 1
Processed by Elixir.Pipeline.HTTPRequestor2: 11
Processed by Elixir.Pipeline.HTTPRequestor4: 31
Processed by Elixir.Pipeline.HTTPRequestor3: 21
Processed by Elixir.Pipeline.HTTPRequestor5: 41
Processed by Elixir.Pipeline.HTTPRequestor1: 2
Processed by Elixir.Pipeline.HTTPRequestor2: 12
Processed by Elixir.Pipeline.HTTPRequestor4: 32
Processed by Elixir.Pipeline.HTTPRequestor3: 22
Processed by Elixir.Pipeline.HTTPRequestor5: 42
Processed by Elixir.Pipeline.HTTPRequestor1: 3
Processed by Elixir.Pipeline.HTTPRequestor2: 13
Processed by Elixir.Pipeline.HTTPRequestor4: 33
Processed by Elixir.Pipeline.HTTPRequestor3: 23
Processed by Elixir.Pipeline.HTTPRequestor5: 43
Processed by Elixir.Pipeline.HTTPRequestor1: 4
Processed by Elixir.Pipeline.HTTPRequestor2: 14
Processed by Elixir.Pipeline.HTTPRequestor4: 34
Processed by Elixir.Pipeline.HTTPRequestor3: 24
Processed by Elixir.Pipeline.HTTPRequestor5: 44
Processed by Elixir.Pipeline.HTTPRequestor1: 5
'34567'
Processed by Elixir.Pipeline.HTTPRequestor4: 35
Processed by Elixir.Pipeline.HTTPRequestor3: 25
'89:;<'
'=>?@A'
Elixir.Pipeline.HTTPRequestor2 subscribed!
'BCDEFGHIJK'
Elixir.Pipeline.DBLoader3 subscribed!
Processed by Elixir.Pipeline.HTTPRequestor5: 45
'LMNOP'

16:53:32.419 [error] GenServer Pipeline.HTTPRequestor2 terminating
** (RuntimeError) Elixir.Pipeline.HTTPRequestor2 just Crashed
    (pipeline) lib/pipeline/http_requestor.ex:21: anonymous fn/3 in Pipeline.HTTPRequestor.handle_events/3
    (elixir) lib/enum.ex:1755: Enum."-reduce/3-lists^foldl/2-0-"/3
    (pipeline) lib/pipeline/http_requestor.ex:18: Pipeline.HTTPRequestor.handle_events/3
    (gen_stage) lib/gen_stage.ex:2408: GenStage.consumer_dispatch/7
    (gen_stage) lib/gen_stage.ex:2531: GenStage.take_pc_events/3
    (stdlib) gen_server.erl:601: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:667: :gen_server.handle_msg/5
    (stdlib) proc_lib.erl:247: :proc_lib.init_p_do_apply/3
Last message: {:"$gen_consumer", {#PID<0.166.0>, #Reference<0.0.1.370>}, [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]}
State: Pipeline.HTTPRequestor2

16:53:32.423 [error] GenServer Pipeline.DBLoader3 terminating
** (RuntimeError) Elixir.Pipeline.HTTPRequestor2 just Crashed
    (pipeline) lib/pipeline/http_requestor.ex:21: anonymous fn/3 in Pipeline.HTTPRequestor.handle_events/3
    (elixir) lib/enum.ex:1755: Enum."-reduce/3-lists^foldl/2-0-"/3
    (pipeline) lib/pipeline/http_requestor.ex:18: Pipeline.HTTPRequestor.handle_events/3
    (gen_stage) lib/gen_stage.ex:2408: GenStage.consumer_dispatch/7
    (gen_stage) lib/gen_stage.ex:2531: GenStage.take_pc_events/3
    (stdlib) gen_server.erl:601: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:667: :gen_server.handle_msg/5
    (stdlib) proc_lib.erl:247: :proc_lib.init_p_do_apply/3
Last message: {:DOWN, #Reference<0.0.1.406>, :process, #PID<0.168.0>, {%RuntimeError{message: "Elixir.Pipeline.HTTPRequestor2 just Crashed"}, [{Pipeline.HTTPRequestor, :"-handle_events/3-fun-0-", 3, [file: 'lib/pipeline/http_requestor.ex', line: 21]}, {Enum, :"-reduce/3-lists^foldl/2-0-", 3, [file: 'lib/enum.ex', line: 1755]}, {Pipeline.HTTPRequestor, :handle_events, 3, [file: 'lib/pipeline/http_requestor.ex', line: 18]}, {GenStage, :consumer_dispatch, 7, [file: 'lib/gen_stage.ex', line: 2408]}, {GenStage, :take_pc_events, 3, [file: 'lib/gen_stage.ex', line: 2531]}, {:gen_server, :try_dispatch, 4, [file: 'gen_server.erl', line: 601]}, {:gen_server, :handle_msg, 5, [file: 'gen_server.erl', line: 667]}, {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]}}
State: Pipeline.DBLoader3
Processed by Elixir.Pipeline.HTTPRequestor1: 4 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor1: 1 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor1: 5 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor1: 2 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor4: 34 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor1: 3 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor1: 6
Processed by Elixir.Pipeline.HTTPRequestor4: 36
Processed by Elixir.Pipeline.HTTPRequestor3: 26
Processed by Elixir.Pipeline.HTTPRequestor2: 66
Processed by Elixir.Pipeline.HTTPRequestor5: 46
Processed by Elixir.Pipeline.HTTPRequestor4: 35 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor4: 31 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor3: 24 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor4: 32 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor3: 25 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor4: 33 |> Processed by Elixir.Pipeline.DBLoader1
Elixir.Pipeline.DBLoader2 subscribed!

16:53:35.414 [error] GenServer Pipeline.DBLoader2 terminating
** (RuntimeError) Elixir.Pipeline.HTTPRequestor2 just Crashed
    (pipeline) lib/pipeline/http_requestor.ex:21: anonymous fn/3 in Pipeline.HTTPRequestor.handle_events/3
    (elixir) lib/enum.ex:1755: Enum."-reduce/3-lists^foldl/2-0-"/3
    (pipeline) lib/pipeline/http_requestor.ex:18: Pipeline.HTTPRequestor.handle_events/3
    (gen_stage) lib/gen_stage.ex:2408: GenStage.consumer_dispatch/7
    (gen_stage) lib/gen_stage.ex:2531: GenStage.take_pc_events/3
    (stdlib) gen_server.erl:601: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:667: :gen_server.handle_msg/5
    (stdlib) proc_lib.erl:247: :proc_lib.init_p_do_apply/3
Last message: {:DOWN, #Reference<0.0.1.395>, :process, #PID<0.168.0>, {%RuntimeError{message: "Elixir.Pipeline.HTTPRequestor2 just Crashed"}, [{Pipeline.HTTPRequestor, :"-handle_events/3-fun-0-", 3, [file: 'lib/pipeline/http_requestor.ex', line: 21]}, {Enum, :"-reduce/3-lists^foldl/2-0-", 3, [file: 'lib/enum.ex', line: 1755]}, {Pipeline.HTTPRequestor, :handle_events, 3, [file: 'lib/pipeline/http_requestor.ex', line: 18]}, {GenStage, :consumer_dispatch, 7, [file: 'lib/gen_stage.ex', line: 2408]}, {GenStage, :take_pc_events, 3, [file: 'lib/gen_stage.ex', line: 2531]}, {:gen_server, :try_dispatch, 4, [file: 'gen_server.erl', line: 601]}, {:gen_server, :handle_msg, 5, [file: 'gen_server.erl', line: 667]}, {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]}}
State: Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor3: 21 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor1: 7
Processed by Elixir.Pipeline.HTTPRequestor4: 37
Processed by Elixir.Pipeline.HTTPRequestor3: 27
Processed by Elixir.Pipeline.HTTPRequestor2: 67
Elixir.Pipeline.HTTPRequestor5 subscribed!
Elixir.Pipeline.DBLoader2 subscribed!
'QRSTUVWXYZ'
Elixir.Pipeline.DBLoader3 subscribed!

16:53:36.412 [error] GenServer Pipeline.HTTPRequestor5 terminating
** (RuntimeError) Elixir.Pipeline.HTTPRequestor5 just Crashed
    (pipeline) lib/pipeline/http_requestor.ex:21: anonymous fn/3 in Pipeline.HTTPRequestor.handle_events/3
    (elixir) lib/enum.ex:1755: Enum."-reduce/3-lists^foldl/2-0-"/3
    (pipeline) lib/pipeline/http_requestor.ex:18: Pipeline.HTTPRequestor.handle_events/3
    (gen_stage) lib/gen_stage.ex:2408: GenStage.consumer_dispatch/7
    (gen_stage) lib/gen_stage.ex:2531: GenStage.take_pc_events/3
    (stdlib) gen_server.erl:601: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:667: :gen_server.handle_msg/5
    (stdlib) proc_lib.erl:247: :proc_lib.init_p_do_apply/3
Last message: {:"$gen_consumer", {#PID<0.166.0>, #Reference<0.0.1.379>}, ')*+,-./012'}
State: Pipeline.HTTPRequestor5

16:53:36.413 [error] GenServer Pipeline.DBLoader2 terminating
** (RuntimeError) Elixir.Pipeline.HTTPRequestor5 just Crashed
    (pipeline) lib/pipeline/http_requestor.ex:21: anonymous fn/3 in Pipeline.HTTPRequestor.handle_events/3
    (elixir) lib/enum.ex:1755: Enum."-reduce/3-lists^foldl/2-0-"/3
    (pipeline) lib/pipeline/http_requestor.ex:18: Pipeline.HTTPRequestor.handle_events/3
    (gen_stage) lib/gen_stage.ex:2408: GenStage.consumer_dispatch/7
    (gen_stage) lib/gen_stage.ex:2531: GenStage.take_pc_events/3
    (stdlib) gen_server.erl:601: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:667: :gen_server.handle_msg/5
    (stdlib) proc_lib.erl:247: :proc_lib.init_p_do_apply/3
Last message: {:DOWN, #Reference<0.0.2.1092>, :process, #PID<0.171.0>, {%RuntimeError{message: "Elixir.Pipeline.HTTPRequestor5 just Crashed"}, [{Pipeline.HTTPRequestor, :"-handle_events/3-fun-0-", 3, [file: 'lib/pipeline/http_requestor.ex', line: 21]}, {Enum, :"-reduce/3-lists^foldl/2-0-", 3, [file: 'lib/enum.ex', line: 1755]}, {Pipeline.HTTPRequestor, :handle_events, 3, [file: 'lib/pipeline/http_requestor.ex', line: 18]}, {GenStage, :consumer_dispatch, 7, [file: 'lib/gen_stage.ex', line: 2408]}, {GenStage, :take_pc_events, 3, [file: 'lib/gen_stage.ex', line: 2531]}, {:gen_server, :try_dispatch, 4, [file: 'gen_server.erl', line: 601]}, {:gen_server, :handle_msg, 5, [file: 'gen_server.erl', line: 667]}, {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]}}
State: Pipeline.DBLoader2

16:53:36.414 [error] GenServer Pipeline.DBLoader3 terminating
** (RuntimeError) Elixir.Pipeline.HTTPRequestor5 just Crashed
    (pipeline) lib/pipeline/http_requestor.ex:21: anonymous fn/3 in Pipeline.HTTPRequestor.handle_events/3
    (elixir) lib/enum.ex:1755: Enum."-reduce/3-lists^foldl/2-0-"/3
    (pipeline) lib/pipeline/http_requestor.ex:18: Pipeline.HTTPRequestor.handle_events/3
    (gen_stage) lib/gen_stage.ex:2408: GenStage.consumer_dispatch/7
    (gen_stage) lib/gen_stage.ex:2531: GenStage.take_pc_events/3
    (stdlib) gen_server.erl:601: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:667: :gen_server.handle_msg/5
    (stdlib) proc_lib.erl:247: :proc_lib.init_p_do_apply/3
Last message: {:DOWN, #Reference<0.0.3.66>, :process, #PID<0.171.0>, {%RuntimeError{message: "Elixir.Pipeline.HTTPRequestor5 just Crashed"}, [{Pipeline.HTTPRequestor, :"-handle_events/3-fun-0-", 3, [file: 'lib/pipeline/http_requestor.ex', line: 21]}, {Enum, :"-reduce/3-lists^foldl/2-0-", 3, [file: 'lib/enum.ex', line: 1755]}, {Pipeline.HTTPRequestor, :handle_events, 3, [file: 'lib/pipeline/http_requestor.ex', line: 18]}, {GenStage, :consumer_dispatch, 7, [file: 'lib/gen_stage.ex', line: 2408]}, {GenStage, :take_pc_events, 3, [file: 'lib/gen_stage.ex', line: 2531]}, {:gen_server, :try_dispatch, 4, [file: 'gen_server.erl', line: 601]}, {:gen_server, :handle_msg, 5, [file: 'gen_server.erl', line: 667]}, {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]}}
State: Pipeline.DBLoader3
Processed by Elixir.Pipeline.HTTPRequestor3: 22 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor3: 23 |> Processed by Elixir.Pipeline.DBLoader1
Elixir.Pipeline.DBLoader1 subscribed!

16:53:36.917 [error] GenServer Pipeline.DBLoader1 terminating
** (RuntimeError) Elixir.Pipeline.HTTPRequestor2 just Crashed
    (pipeline) lib/pipeline/http_requestor.ex:21: anonymous fn/3 in Pipeline.HTTPRequestor.handle_events/3
    (elixir) lib/enum.ex:1755: Enum."-reduce/3-lists^foldl/2-0-"/3
    (pipeline) lib/pipeline/http_requestor.ex:18: Pipeline.HTTPRequestor.handle_events/3
    (gen_stage) lib/gen_stage.ex:2408: GenStage.consumer_dispatch/7
    (gen_stage) lib/gen_stage.ex:2531: GenStage.take_pc_events/3
    (stdlib) gen_server.erl:601: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:667: :gen_server.handle_msg/5
    (stdlib) proc_lib.erl:247: :proc_lib.init_p_do_apply/3
Last message: {:DOWN, #Reference<0.0.1.384>, :process, #PID<0.168.0>, {%RuntimeError{message: "Elixir.Pipeline.HTTPRequestor2 just Crashed"}, [{Pipeline.HTTPRequestor, :"-handle_events/3-fun-0-", 3, [file: 'lib/pipeline/http_requestor.ex', line: 21]}, {Enum, :"-reduce/3-lists^foldl/2-0-", 3, [file: 'lib/enum.ex', line: 1755]}, {Pipeline.HTTPRequestor, :handle_events, 3, [file: 'lib/pipeline/http_requestor.ex', line: 18]}, {GenStage, :consumer_dispatch, 7, [file: 'lib/gen_stage.ex', line: 2408]}, {GenStage, :take_pc_events, 3, [file: 'lib/gen_stage.ex', line: 2531]}, {:gen_server, :try_dispatch, 4, [file: 'gen_server.erl', line: 601]}, {:gen_server, :handle_msg, 5, [file: 'gen_server.erl', line: 667]}, {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]}}
State: Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor1: 8
Processed by Elixir.Pipeline.HTTPRequestor4: 38
Processed by Elixir.Pipeline.HTTPRequestor3: 28
Processed by Elixir.Pipeline.HTTPRequestor2: 68
Processed by Elixir.Pipeline.HTTPRequestor5: 81
Processed by Elixir.Pipeline.HTTPRequestor1: 9
Processed by Elixir.Pipeline.HTTPRequestor4: 39
Processed by Elixir.Pipeline.HTTPRequestor3: 29
Processed by Elixir.Pipeline.HTTPRequestor2: 69
Processed by Elixir.Pipeline.HTTPRequestor5: 82
Processed by Elixir.Pipeline.HTTPRequestor1: 10
'[\\]^_'
Processed by Elixir.Pipeline.HTTPRequestor4: 40
Processed by Elixir.Pipeline.HTTPRequestor3: 30
'`abcd'
[]
Processed by Elixir.Pipeline.HTTPRequestor2: 70
[]
Processed by Elixir.Pipeline.HTTPRequestor5: 83
Processed by Elixir.Pipeline.HTTPRequestor1: 51
Processed by Elixir.Pipeline.HTTPRequestor4: 56
Processed by Elixir.Pipeline.HTTPRequestor3: 61
Processed by Elixir.Pipeline.HTTPRequestor2: 71
Processed by Elixir.Pipeline.HTTPRequestor5: 84
Processed by Elixir.Pipeline.HTTPRequestor1: 52
Processed by Elixir.Pipeline.HTTPRequestor4: 57
Processed by Elixir.Pipeline.HTTPRequestor3: 62
Processed by Elixir.Pipeline.HTTPRequestor2: 72
Processed by Elixir.Pipeline.HTTPRequestor5: 85
[]
Processed by Elixir.Pipeline.HTTPRequestor5: 81 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor5: 82 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor5: 83 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor1: 53
Processed by Elixir.Pipeline.HTTPRequestor4: 58
Processed by Elixir.Pipeline.HTTPRequestor3: 63
Processed by Elixir.Pipeline.HTTPRequestor2: 73
Processed by Elixir.Pipeline.HTTPRequestor5: 86
Processed by Elixir.Pipeline.HTTPRequestor1: 54
Processed by Elixir.Pipeline.HTTPRequestor4: 59
Processed by Elixir.Pipeline.HTTPRequestor3: 64
Processed by Elixir.Pipeline.HTTPRequestor2: 74
Processed by Elixir.Pipeline.HTTPRequestor5: 87
Processed by Elixir.Pipeline.HTTPRequestor1: 55
[]
Processed by Elixir.Pipeline.HTTPRequestor4: 60
Processed by Elixir.Pipeline.HTTPRequestor3: 65
[]
[]
Processed by Elixir.Pipeline.HTTPRequestor2: 75
[]
Processed by Elixir.Pipeline.HTTPRequestor5: 88
Processed by Elixir.Pipeline.HTTPRequestor2: 72 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor2: 75 |> Processed by Elixir.Pipeline.DBLoader3
Processed by Elixir.Pipeline.HTTPRequestor2: 73 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor2: 74 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor1: 91
Processed by Elixir.Pipeline.HTTPRequestor4: 96
Processed by Elixir.Pipeline.HTTPRequestor5: 89
Processed by Elixir.Pipeline.HTTPRequestor1: 92
Processed by Elixir.Pipeline.HTTPRequestor4: 97
Processed by Elixir.Pipeline.HTTPRequestor5: 90
[]
Processed by Elixir.Pipeline.HTTPRequestor5: 84 |> Processed by Elixir.Pipeline.DBLoader3
Processed by Elixir.Pipeline.HTTPRequestor5: 87 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor5: 90 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor5: 85 |> Processed by Elixir.Pipeline.DBLoader3
Processed by Elixir.Pipeline.HTTPRequestor5: 88 |> Processed by Elixir.Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor5: 86 |> Processed by Elixir.Pipeline.DBLoader3
Elixir.Pipeline.DBLoader1 subscribed!

16:53:57.925 [error] GenServer Pipeline.DBLoader1 terminating
** (RuntimeError) Elixir.Pipeline.DBLoader1 just Crashed!
    (pipeline) lib/pipeline/db_loader.ex:24: anonymous fn/3 in Pipeline.DBLoader.handle_events/3
    (elixir) lib/enum.ex:1755: Enum."-reduce/3-lists^foldl/2-0-"/3
    (pipeline) lib/pipeline/db_loader.ex:21: Pipeline.DBLoader.handle_events/3
    (gen_stage) lib/gen_stage.ex:2408: GenStage.consumer_dispatch/7
    (gen_stage) lib/gen_stage.ex:1949: GenStage.handle_info/2
    (stdlib) gen_server.erl:601: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:667: :gen_server.handle_msg/5
    (stdlib) proc_lib.erl:247: :proc_lib.init_p_do_apply/3
Last message: {:"$gen_consumer", {#PID<0.180.0>, #Reference<0.0.2.1123>}, ["Processed by Elixir.Pipeline.HTTPRequestor5: 87", "Processed by Elixir.Pipeline.HTTPRequestor5: 88", "Processed by Elixir.Pipeline.HTTPRequestor5: 89"]}
State: Pipeline.DBLoader1
Processed by Elixir.Pipeline.HTTPRequestor1: 93
Processed by Elixir.Pipeline.HTTPRequestor4: 98
Processed by Elixir.Pipeline.HTTPRequestor1: 94
Processed by Elixir.Pipeline.HTTPRequestor4: 99
Processed by Elixir.Pipeline.HTTPRequestor1: 95
[]
Processed by Elixir.Pipeline.HTTPRequestor4: 100
[]
Processed by Elixir.Pipeline.HTTPRequestor1: 94 |> Processed by Elixir.Pipeline.DBLoader2
Processed by Elixir.Pipeline.HTTPRequestor1: 95 |> Processed by Elixir.Pipeline.DBLoader2
```
