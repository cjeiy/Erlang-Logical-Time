-module(logger).
-export([start/1, stop/1]).

start(Nodes) ->

    spawn_link(fun() ->init(Nodes) end).

stop(Logger) ->
    Logger ! stop.

init(Nodes) ->
    Clock = time:clock(Nodes),
    Queue = [],
    loop(Clock, Queue).

loop(Clock, Queue) ->
    receive
	{log, From, Time, Msg} ->
	    Clock1 = time:update(From, Time, Clock),
	    Queue1 = add_to_queue(From, Time, Msg, Queue),
	    Queue2 = flush_queue(Clock1, Queue1,length(Queue1)),
	    %io:format("Clock: ~w~n", [Clock1]),
	    loop(Clock1, Queue2);
	stop ->
	    ok
    end.

log(From, Time, Msg) ->
    io:format("log: ~w ~w ~p~n", [Time, From, Msg]).

add_to_queue(From, Time, Msg, Queue) ->
    Queue1 = lists:keysort(2,[{From, Time, Msg}| Queue]),
    Queue1.

flush_queue(Clock, Queue, 1) ->
    Clock1 = lists:keysort(2,Clock),
    [{From, Time, Msg}] = Queue,
    [{_,MinClock} | _] = Clock1,
    case time:safe(Time,MinClock) of 
	 true ->
	    log(From, Time, Msg),
	    io:format("LOL~n", []),
	    [];
	false ->
	     Queue
     end;
    
flush_queue(Clock, Queue, Length) ->
    Clock1 = lists:keysort(2,Clock),
    [{From, Time, Msg} | TailQueue] = Queue,
    [{_,MinClock} | _] = Clock1, 
    case time:safe(Time,MinClock) of 
	false ->
	    Queue;
	 true ->
	    log(From, Time, Msg),
	    flush_queue(Clock1, TailQueue, Length-1)
     end.
    
    
