-module(monitor).
-behaviour(supervisor).
-export([start/0, init/1, start_double/0]).

start() ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    Pid.
    
start_double() ->
    Pid = double:start(),
    link(Pid),
    {ok, Pid}.

init(_Args) ->
    SupervisorSpecification = #{
        strategy => one_for_one,
        intensity => 3,
        period => 10},

    ChildSpecifications = [
        #{
            id => double_worker,
            start => {?MODULE, start_double, []}
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.