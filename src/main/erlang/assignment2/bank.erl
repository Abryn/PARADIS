-module(bank).
-export([start/0, balance/2, deposit/3, withdraw/3, lend/4]).

start() ->
    spawn(fun() -> bank_loop(#{}) end).

balance(Pid, Who) -> 
    message_server(Pid, {balance, Who}).

deposit(Pid, Who, X) ->
    message_server(Pid, {deposit, Who, X}).

withdraw(Pid, Who, X) ->
    message_server(Pid, {withdraw, Who, X}).

lend(Pid, From, To, X) ->
    message_server(Pid, {lend, From, To, X}).

message_server(Pid, Message) ->
    Ref = make_ref(),
    Monitor = erlang:monitor(process, Pid),
    Pid ! {self(), Ref, Message},
    receive
        {Ref, Result} ->
            erlang:demonitor(Monitor, [flush]),
            Result;
        {'DOWN', Monitor, process, Pid, _} ->
            no_bank
    end.

bank_loop(AccountMap) ->
    receive 
        {Pid, Ref, {balance, Who}} ->
            Result = case maps:find(Who, AccountMap) of
                {ok, Balance} -> {ok, Balance};
                error -> no_account
            end,
            Pid ! {Ref, Result},
            bank_loop(AccountMap);
        {Pid, Ref, {deposit, Who, X}} ->
            {Result, NewAccountMap} = case maps:find(Who, AccountMap) of
                {ok, Balance} ->
                    UpdatedMap = maps:put(Who, Balance + X, AccountMap),
                    {{ok, Balance + X}, UpdatedMap};
                error ->
                    UpdatedMap = maps:put(Who, X, AccountMap),
                    {{ok, X}, UpdatedMap}
            end,
            Pid ! {Ref, Result},
            bank_loop(NewAccountMap);
        {Pid, Ref, {withdraw, Who, X}} ->
            {Result, NewAccountMap} = case maps:find(Who, AccountMap) of
                {ok, Balance} ->
                    case Balance >= X of
                        true ->
                            UpdatedMap = maps:put(Who, Balance - X, AccountMap),
                            {{ok, Balance - X}, UpdatedMap};
                        false ->
                            {insufficient_funds, AccountMap}
                    end;
                error ->
                    {no_account, AccountMap}
            end,
            Pid ! {Ref, Result},
            bank_loop(NewAccountMap);
        {Pid, Ref, {lend, From, To, X}} ->
            {Result, NewAccountMap} = case {maps:find(From, AccountMap), maps:find(To, AccountMap)} of
                {{ok, FromBalance}, {ok, ToBalance}} ->
                    case FromBalance >= X of
                        true ->
                            Temp = maps:put(From, FromBalance - X, AccountMap),
                            UpdatedMap = maps:put(To, ToBalance + X, Temp),
                            {ok, UpdatedMap};
                        false ->
                            {insufficient_funds, AccountMap}
                    end;
                {{ok, _FromBalance}, error} ->
                    {{no_account, To}, AccountMap};
                {error, {ok, _ToBalance}} ->
                    {{no_account, From}, AccountMap};
                {error, error} ->
                    {{no_account, both}, AccountMap}
            end,
            Pid ! {Ref, Result},
            bank_loop(NewAccountMap)
    end.