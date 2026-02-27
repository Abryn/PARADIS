-module(monitor).
-export([start/0, monitor_loop/0]).

start() ->
    spawn(monitor, monitor_loop, []).

monitor_loop() ->
    Pid = double:start(),
    Monitor = erlang:monitor(process, Pid),
    monitor_double(Pid, Monitor).

monitor_double(Pid, Monitor) ->
    receive
        {'DOWN', Monitor, process, Pid, _Reason} ->
            monitor_loop()
    end.