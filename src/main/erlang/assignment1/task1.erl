-module(task1).
-export([eval/1, eval/2, map/2, filter/2, split/2, groupby/2]).

% eval/1
eval(Expr) -> 
    try
        Result = evaluate(Expr),
        {ok, Result}
    catch
        _:_ -> error
    end.

evaluate({add, E1, E2}) -> evaluate(E1) + evaluate(E2);
evaluate({sub, E1, E2}) -> evaluate(E1) - evaluate(E2);
evaluate({mul, E1, E2}) -> evaluate(E1) * evaluate(E2);
evaluate({'div', E1, E2}) -> evaluate(E1) div evaluate(E2); 
evaluate(N) when is_integer(N) -> N;
evaluate(_) -> throw(error).

% eval/2
eval(Expr, Map) -> 
    try
        Result = evaluate(Expr, Map),
        {ok, Result}
    catch
        throw:variable_not_found -> {error, variable_not_found};
        _:_ -> {error, unknown_error}
    end.

evaluate({add, E1, E2}, Map) -> evaluate(E1, Map) + evaluate(E2, Map);
evaluate({sub, E1, E2}, Map) -> evaluate(E1, Map) - evaluate(E2, Map);
evaluate({mul, E1, E2}, Map) -> evaluate(E1, Map) * evaluate(E2, Map);
evaluate({'div', E1, E2}, Map) -> evaluate(E1, Map) div evaluate(E2, Map); 

evaluate({'let', Var, E1, E2}, Map) ->
    Val = evaluate(E1, Map),
    NewMap = maps:put(Var, Val, Map),
    evaluate(E2, NewMap);
    
evaluate(Atom, Map) when is_atom(Atom) -> 
    case maps:find(Atom, Map) of
        {ok, Val} -> Val;
        error -> throw(variable_not_found)
    end;

evaluate(N, _Map) when is_integer(N) -> N;
evaluate(_, _Map) -> throw(unknown_error).

% map/2
map(F, L) -> map_helper(F, L, []).
map_helper(F, [Head | Tail], Acc) -> map_helper(F, Tail, [F(Head) | Acc]);
map_helper(_, [], Acc) -> lists:reverse(Acc).

% filter/2
filter(P, L) -> filter_helper(P, L, []).
filter_helper(P, [Head | Tail], Acc) -> 
    case P(Head) of 
        true -> filter_helper(P, Tail, [Head | Acc]);
        _ -> filter_helper(P, Tail, Acc)
    end;
filter_helper(_, [], Acc) -> lists:reverse(Acc).

% split/2
split(P, L) -> split_helper(P, L, [], []).
split_helper(P, [Head | Tail], TrueAcc, FalseAcc) ->
    case P(Head) of
        true -> split_helper(P, Tail, [Head | TrueAcc], FalseAcc);
        false -> split_helper(P, Tail, TrueAcc, [Head | FalseAcc])
    end;
split_helper(_, [], TrueAcc, FalseAcc) -> 
    {lists:reverse(TrueAcc), lists:reverse(FalseAcc)}.

% groupby/2
groupby(F, L) -> 
    Map = groupby_helper(F, L, 1, #{}),
    maps:map(fun(_, Entries) -> lists:reverse(Entries) end, Map).
groupby_helper(F, [Head | Tail], Index, MapAcc) ->
    Key = F(Head),
    case maps:find(Key, MapAcc) of
        {ok, IndicesFromKey} -> 
            IndicesUpdated = [Index | IndicesFromKey],
            NewMapAcc = maps:put(Key, IndicesUpdated, MapAcc);
        error -> 
            NewMapAcc = maps:put(Key, [Index], MapAcc)
    end,
    groupby_helper(F, Tail, Index + 1, NewMapAcc);
groupby_helper(_, [], _, MapAcc) -> MapAcc.

