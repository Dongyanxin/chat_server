%%%-------------------------------------------------------------------
%%% @author xin
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 四月 2015 下午2:26
%%%-------------------------------------------------------------------
-module(dist).
-author("xin").

%% API
-export([t/1, loop/0, s/0]).

t(From) ->

  io:format("~n ~p ~n", [self()]),
  From ! node().

s() ->
  register(client, self()),
  loop().


loop() ->

  receive

    {M, Pid} -> Pid ! M

  end,
  loop().
