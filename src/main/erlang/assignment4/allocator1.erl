-module(allocator1).
-export([start/1, request/2, release/2]).

start(Resources) ->
    spawn(fun() -> allocator(Resources, []) end).

request(Alloc, N) ->
    Ref = make_ref(),
    Alloc ! {request, self(), Ref, N},
    receive
        {response, Ref, ok} ->
            ok
    end. 

release(Alloc, N) ->
    Alloc ! {release, N}.

allocator(Resources, Requestors) ->
    receive
        {request, Pid, Ref, N} when N =< Resources ->
            Pid ! {response, Ref, ok},
            allocator(Resources - N, Requestors);
        {request, Pid, Ref, N} ->
            allocator(Resources, Requestors ++ [{Pid, Ref, N}]);
        {release, N} ->
            allocator_try(Resources + N, Requestors)
    end.

allocator_try(Resources, []) ->
    allocator(Resources, []);
allocator_try(Resources, [{Pid, Ref, N} | Rest] = Requestors) ->
    case N =< Resources of
        true ->
            Pid ! {response, Ref, ok},
            allocator_try(Resources - N, Rest);
        false ->
            allocator(Resources, Requestors)
    end.