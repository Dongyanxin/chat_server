-module(client_demo).
-export([start/0, client_loop/0]).

start() ->

  Pid = spawn(fun() -> client_loop() end),
  register(demo_client, Pid),

  ServerNode = 'server@127.0.0.1',
  case net_kernel:connect(ServerNode) of
    true ->
      io:format("connect server success! ~n"),
      %% 第一种通信方式：发信息
      {demo, ServerNode} ! {msg, demo_client, node(), "hello world send msg test ~n"},
      %% 第二种通信方式：远程调用
      rpc:call(ServerNode, server_demo, rpc_call, [self(), "hello2 rpc call test ~n"]),
      io:format("connect server success! -----"),
      ok;
    _ ->
      io:format("connect server fail!")
  end,
  ok.
client_loop() ->
  receive
    {msg, Pid, _Node, Msg} ->
      io:format("~n~n~n receive msg ~p from server pid ~p ~n", [Msg, Pid]);
    {rpc, Pid, Msg} ->
      io:format("receive rpc ~p from server pid ~p ~n", [Msg, Pid])
  end,
  client_loop().
