-module(chat_server_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, startup/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

startup() ->
  application:start(chat_server).

start(_StartType, _StartArgs) ->

  chat_acceptor:start(2222),
  chat_server_sup:start_link().

stop(_State) ->
  ok.
