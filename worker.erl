-module(worker).
-export([start/5, stop/1, peers/2]).
start(Name, Logger, Seed, Sleep, Jitter) ->
    spawn_link(fun() -> init(Name, Logger, Seed, Sleep, Jitter) end).

stop(Worker) ->
    Worker ! stop.
init(Name, Log, Seed, Sleep, Jitter) ->
    random:seed(Seed, Seed, Seed),
    receive
	{peers, Peers} ->
	    loop(Name, Log, Peers, Sleep, Jitter, time:zero());
	stop ->
	    ok
    end.

peers(Wrk, Peers) ->
    Wrk ! {peers, Peers}.

loop(Name, Log, Peers, Sleep, Jitter, LTime)->
    Wait = random:uniform(Sleep),
    receive
	{msg, Time, Msg} ->
	    LTime1= time:inc(Name,time:merge(LTime,Time)),
	    
	    Log ! {log, Name, LTime1, {received, Msg}},

	    loop(Name, Log, Peers, Sleep, Jitter,LTime1);
	stop ->
	    ok;
	Error ->
	    Log ! {log, Name, time, {error, Error}}
    after Wait ->
	    Selected = select(Peers),
	    Message = {hello, random:uniform(100)},
	    Selected ! {msg, LTime, Message},
	    jitter(Jitter),
	    Log ! {log, Name, LTime, {sending, Message}},
	    loop(Name, Log, Peers, Sleep, Jitter, time:inc(Name,LTime))
    end.

select(Peers) ->
    lists:nth(random:uniform(length(Peers)), Peers).

jitter(0) ->
    ok;

jitter(Jitter) ->
    timer:sleep(random:uniform(Jitter)).
