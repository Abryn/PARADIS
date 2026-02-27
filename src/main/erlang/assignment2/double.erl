-module(double).
-export([start/0, double/1]).

start() -> 
    case whereis(double) of
        undefined -> 
            Pid = spawn(fun() -> double_loop() end),
            register(double, Pid),
            Pid;
        Pid ->
            Pid
    end.

double_loop() ->
    receive 
        {Pid, Ref, N} ->
            Pid ! {Ref, N * 2}
    end,
    double_loop().

double(N) ->
    Ref = make_ref(),
    try double ! {self(), Ref, N} of
        _ ->
            receive
                {Ref, X} -> X
            end
    catch
        error:badarg ->
            double(N)
    end.