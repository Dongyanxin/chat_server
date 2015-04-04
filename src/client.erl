%%%-------------------------------------------------------------------
%%% @author xin
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 三月 2015 下午2:01
%%%-------------------------------------------------------------------
-module(client).
-author("xin").

-include("common.hrl").
-compile(export_all).

start() ->
  % 创建一个进程建立socket连接，并且等待服务器返回的信息
  Pid = spawn(fun() -> getMessage() end),
  {ok, Socket} = rpc(Pid, {getsocket}),

  % 注册一个进程用户保存socket，并且提供发送信息的接口
  register(client, spawn(fun() -> loop(Socket) end)).



loop(Socket) ->
  receive
    {From, Str} ->
      ok = gen_tcp:send(Socket, list_to_binary(Str)),
      From ! ok,
      loop(Socket)
  end.

% 发送信息接口
sendmsg(Str) ->
  client ! {self(), Str},
  receive
    Response -> Response
  end.



rpc(Pid, Q) ->
  Pid ! {self(), Q},
  receive
    {Pid, Reply} -> Reply
  end.

getMessage() ->
  receive
    {From, {getsocket}} ->
      {ok, Socket} = gen_tcp:connect("localhost", 2222, [binary, {packet, 2}]),
      From ! {self(), {ok, Socket}},
      getMessage();
    {tcp, Socket, Bin} ->
      io:format("Chat Room News = ~p   ~p ~n", [Bin,Socket]),
      getMessage()
  end.
