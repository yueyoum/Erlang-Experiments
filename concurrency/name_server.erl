-module(name_server).
-export([start/0, store/2, lookup/1]).


start() -> register(kvs, spawn(fun() -> loop() end)).

store(Key, Value) -> rpc({store, Key, Value}).

lookup(Key)	-> rpc({lookup, Key}).


rpc(Request) ->
	kvs ! {self(), Request},
	receive
		{kvs, Reply} -> Reply
	end.


loop() ->
	receive
		{From, {store, Key, Value}} ->
			put(Key, {ok, Value}),
			From ! {kvs, true},
			loop();
		{From, {lookup, Key}} ->
			From ! {kvs, get(Key)},
			loop()
	end.

