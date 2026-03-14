-module(bank).
-behaviour(gen_server).
-export([start/0, balance/2, deposit/3, withdraw/3, lend/4]).
-export([init/1, handle_call/3, handle_cast/2]).

start() ->
    {ok, Pid} = gen_server:start(?MODULE, [], []),
    Pid.

init(_Args) ->
    {ok, #{}}.

call(Pid, Function) ->
    try 
        gen_server:call(Pid, Function)
    catch
        exit:_ -> no_bank
    end.
    
balance(Pid, Who) -> 
    call(Pid, {balance, Who}).

deposit(Pid, Who, X) ->
    call(Pid, {deposit, Who, X}).

withdraw(Pid, Who, X) ->
    call(Pid, {withdraw, Who, X}).

lend(Pid, From, To, X) ->
    call(Pid, {lend, From, To, X}).

handle_call({balance, Who}, _, AccountMap) ->
    Result = case maps:find(Who, AccountMap) of
        {ok, Balance} -> {ok, Balance};
        error -> no_account 
    end,
    {reply, Result, AccountMap};

handle_call({deposit, Who, X}, _, AccountMap) ->
    {Result, NewAccountMap} = case maps:find(Who, AccountMap) of
        {ok, Balance} ->
            UpdatedMap = maps:put(Who, Balance + X, AccountMap),
            {{ok, Balance + X}, UpdatedMap};
        error ->
            UpdatedMap = maps:put(Who, X, AccountMap),
            {{ok, X}, UpdatedMap}
    end,
    {reply, Result, NewAccountMap};

handle_call({withdraw, Who, X}, _, AccountMap) ->
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
    {reply, Result, NewAccountMap};

handle_call({lend, From, To, X}, _, AccountMap) ->
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
    {reply, Result, NewAccountMap}.

handle_cast(_, State) -> 
    {noreply, State}.