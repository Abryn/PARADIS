-module(barrier2).
-export([start/1, wait/2, test/0]).

start(Refs) ->
    spawn(fun() -> barrier_loop(Refs, []) end).

wait(Barrier, Ref) ->
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

barrier_loop(Block, Notify) ->
    case lists:all(fun(Ref) -> lists:keymember(Ref, 2, Notify) end, Block) of
        true ->
            notify(Notify),
            barrier_loop(Block, []);
        false ->
            receive
                {arrived, Pid, Ref} ->
                    case lists:member(Ref, Block) andalso not lists:keymember(Ref, 2, Notify) of
                        true ->
                            barrier_loop(Block, [{Pid, Ref} | Notify]);
                        false ->
                            Pid ! {continue, Ref},
                            barrier_loop(Block, Notify)
                    end
            end
    end.

test() ->
    A = make_ref(), B = make_ref(), C = make_ref(),
    Barrier = start([A, B]),
    spawn(fun() ->
        io:format("call do_a()~n"),
        receive
            after 1000 -> ok
        end,
        io:format("finished do_a()~n"),
        wait(Barrier, A),
        io:format("call do_more_a(), has to wait for do_a() and do_b()~n")
        end),
    spawn(fun() ->
        io:format("call do_b()~n"),
        receive
            after 5000 -> ok
        end,
        io:format("finished do_b()~n"),
        wait(Barrier, B),
        io:format("call do_more_b(), has to wait for do_a() and do_b()~n")
        end),
    spawn(fun() ->
        io:format("call do_c()~n"),
        receive
            after 1000 -> ok
        end,
        io:format("finished do_c()~n"),
        wait(Barrier, C),
        io:format("call do_more_c(), runs immediately~n")
        end).