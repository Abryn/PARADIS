-module(ring).
-export([start/2]).

start(N, M) ->
    Self = self(),
    FirstProcess = spawn(fun() -> loop(Self, Self) end), 
    LastProcess = 
        case N of
            1 -> FirstProcess;
            _ -> spawn_ring(N - 1, FirstProcess, Self)
        end,
    FirstProcess ! {set_next, LastProcess},
    LastProcess ! {N * M, 0},
    receive
        Number ->
            Number
    end.

spawn_ring(1, Next, Start) ->
    spawn(fun() -> loop(Next, Start) end);
spawn_ring(N, Next, Start) ->
    MyNext = spawn(fun() -> loop(Next, Start) end),
    spawn_ring(N - 1, MyNext, Start).

loop(Pid, Start) ->
    receive
        {set_next, Next} ->
            loop(Next, Start);
        {0, Number} ->
            Start ! Number,
            Pid ! done;
        {RoundsLeft, Number} ->
            Pid ! {RoundsLeft - 1, Number + 1},
            loop(Pid, Start);
        done ->
            Pid ! done
    end.