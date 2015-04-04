-module(server_demo).
-export([start/0, rpc_call/2]).

start() ->
  Pid = spawn(fun() -> server_loop() end),
  register(demo, Pid), %%注册进程名字
  ok.

server_loop() ->
  receive
    {msg, Pid, Node, Msg} ->
      io:format("~n~n receive msg ~p from pid ~p~n", [Msg, Pid]),
      {Pid, Node} ! {msg, self(), node(), "client hello"};

    {rpc, Pid, Msg} ->
      io:format(" receive rpc ~p from pid ~p ~n", [Msg, Pid])
  end,
  server_loop().

rpc_call(Pid, Msg) ->

  io:format("rpc call"),
  demo ! {rpc, Pid, Msg}.
