-module(pmap).
-export([unordered/2]).

unordered(Fun, L) ->
    Pids = [spawn_work(Fun, Element) || Element <- L],
    gather(Pids).

gather([]) -> [];
gather([_Head | Tail]) ->
    receive
        Element -> [Element | gather(Tail)]
    end.

spawn_work(Fun, E) ->
    Pid = spawn(fun() -> worker(Fun, E) end),
    Pid ! {self(), Fun, E},
    Pid.

worker(Fun, E) ->
    receive
        {Main, Fun, E} ->
            Main ! Fun(E)
    end.