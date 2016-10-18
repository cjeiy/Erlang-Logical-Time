-module(time).
-export([zero/0,inc/2,merge/2,leq/2,clock/1,update/3,safe/2]).

zero() ->
    0.

inc(Name, Time) ->
    Time+1.

merge(TimeI,TimeJ) ->
    erlang:max(TimeI,TimeJ).

leq(TimeI,TimeJ) ->
    if
	TimeI=<TimeJ ->
	    true;
	true ->
	    false
end.

clock(Nodes) ->
    L = lists:foldl(fun(Node,MultiClock) -> [{Node, 0}| MultiClock ] end, [], Nodes),
    io:format("~w~n", [L]),
    L.

update(Node, Time, Clock) ->
     case lists:keyfind(Node,1,Clock) of 
				  {Node, OldTime} ->
					NC = lists:keydelete(Node,1,Clock),
					[{Node, time:merge(Time,OldTime)} | NC];
				      false ->
			   		[{Node, Time} | Clock]
    end.
safe(Time, Clock) ->
    leq(Time,Clock).
