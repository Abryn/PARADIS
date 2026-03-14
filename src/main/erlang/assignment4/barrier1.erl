-module(barrier1).
-export([start/1, wait/1, test/0]).

start(N) ->
    spawn(fun() -> barrier_loop(N, []) end).

wait(Barrier) ->
    Ref = make_ref(),
    Barrier ! {arrived, self(), Ref},
    receive 
        {continue, Ref} ->
            ok
    end.

notify([]) ->
    ok;
notify([{Pid, Ref} | Rest]) ->
    Pid ! {continue, Ref},
    notify(Rest).

barrier_loop(0, Notify) ->
    notify(Notify),
    barrier_loop(length(Notify), []);
barrier_loop(N, Notify) ->
    receive
        {arrived, Pid, Ref} ->
            barrier_loop(N - 1, [{Pid, Ref} | Notify])
    end.

test() ->
    Barrier = start(4),
    lists:foreach(fun(I) -> 
        spawn(fun() ->
            io:format("I'm process ~p~n", [I]),
            receive
                after I * 1000 -> ok
            end,
            wait(Barrier),
            io:format("I'm process ~p after barrier~n", [I])
        end)
    end, lists:seq(1, 4)).