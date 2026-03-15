-module(allocator2).
-export([start/1, request/2, release/2, test/0]).

start(Resources) ->
    spawn(fun() -> allocator_loop(Resources, [], #{}) end).

request(Pid, ResourceList) ->
    Ref = make_ref(),
    Pid ! {request, self(), Ref, ResourceList},
    receive
        {response, Ref, Resources} ->
            Resources;
        {error, Ref, Reason} ->
            Reason
    end.

release(Pid, ResourceMap) ->
    Pid ! {release, ResourceMap}.

allocator_loop(Resources, Requests, Taken) ->
    receive
        {request, Pid, Ref, Requested} when map_size(Resources) - map_size(Taken) >= length(Requested) ->
            case {lists:all(fun(Key) -> maps:is_key(Key, Resources) end, Requested),
                lists:all(fun(Key) -> not maps:is_key(Key, Taken) end, Requested)} of
                {true, true} ->
                    UpdatedTaken = lists:foldl(fun(Key, Acc) -> maps:put(Key, {Ref, Pid}, Acc) end, Taken, Requested),
                    Pid ! {response, Ref, maps:with(Requested, Resources)},
                    allocator_loop(Resources, Requests, UpdatedTaken);
                {true, false} ->
                    UpdatedRequests = Requests ++ [{Pid, Ref, Requested}],
                    allocator_loop(Resources, UpdatedRequests, Taken);
                {false, _} ->
                    Pid ! {error, Ref, resources_dont_exist},
                    allocator_loop(Resources, Requests, Taken)
            end;
        {request, Pid, Ref, Requested} ->
            case lists:all(fun(Key) -> maps:is_key(Key, Resources) end, Requested) of
                true ->
                    UpdatedRequests = Requests ++ [{Pid, Ref, Requested}],
                    allocator_loop(Resources, UpdatedRequests, Taken);
                false ->
                    Pid ! {error, Ref, resources_dont_exist},
                    allocator_loop(Resources, Requests, Taken)
            end;
        {release, Resource} ->
            case lists:all(fun(Key) -> maps:is_key(Key, Taken) end, maps:keys(Resource)) of
                true ->
                    UpdatedTaken = maps:without(maps:keys(Resource), Taken),
                    handle_requests(Resources, Requests, UpdatedTaken);
                false ->
                    allocator_loop(Resources, Requests, Taken)
            end
    end.

handle_requests(Resources, Requests, Taken) ->
    handle_requests(Resources, Requests, [], Taken).

handle_requests(Resources, [], Skipped, Taken) ->
    allocator_loop(Resources, Skipped, Taken);
handle_requests(Resources, [{Pid, Ref, Requested} | Rest], Skipped, Taken) ->
    case lists:all(fun(Key) -> not maps:is_key(Key, Taken) end, Requested) of
        true ->
            UpdatedTaken = lists:foldl(fun(Key, Acc) -> maps:put(Key, {Ref, Pid}, Acc) end, Taken, Requested),
            Pid ! {response, Ref, maps:with(Requested, Resources)},
            handle_requests(Resources, Rest, Skipped, UpdatedTaken);
        false ->
            handle_requests(Resources, Rest, Skipped ++ [{Pid, Ref, Requested}], Taken)
    end.

test() ->
    Barrier = start(#{a=>10, b=>20, c=>30}),
    spawn(fun() ->
        io:format("Process 1 requesting a and b~n"),
        R = request(Barrier, [a, b]),
        io:format("Process 1 got resources: ~p~n", [R]),
        timer:sleep(3000),
        io:format("Process 1 releasing a and b~n"),
        release(Barrier, R)
    end),
    spawn(fun() ->
        timer:sleep(500),
        io:format("Process 2 requesting b and c~n"),
        R = request(Barrier, [b, c]),
        io:format("Process 2 got resources: ~p~n", [R]),
        timer:sleep(1000),
        io:format("Process 2 releasing b and c~n"),
        release(Barrier, R)
    end),
    spawn(fun() ->
        timer:sleep(500),
        io:format("Process 3 requesting a~n"),
        R = request(Barrier, [a]),
        io:format("Process 3 got resources: ~p~n", [R]),
        release(Barrier, R)
    end),
    spawn(fun() ->
        io:format("Process 4 requesting d (invalid)~n"),
        R = request(Barrier, [d]),
        io:format("Process 4 result: ~p~n", [R])
    end).