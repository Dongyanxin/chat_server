%%%-------------------------------------------------------------------
%%% @author xin
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 三月 2015 下午3:59
%%%-------------------------------------------------------------------
-module(chat_acceptor).
-author("xin").

%% API
-export([]).

-export([start/1,accept_loop/1]).
-include("common.hrl").

%%
%% API Functions
%%

%%start listen server
start(Port)->
  case (do_init(Port))of

    {ok,ListenSocket}->
      spawn(chat_acceptor, accept_loop, [ListenSocket]);
    _Els ->
      error
  end.

%%listen port
do_init(Port) when is_list(Port)->
  start(list_to_integer(Port));

do_init([Port]) when is_atom(Port)->
  start(list_to_integer(atom_to_list(Port)));

do_init(Port) when is_integer(Port)->

  Options=[binary, {packet, 2}, {reuseaddr, true}, {backlog, 1024}, {active, true}],

  case gen_tcp:listen(Port, Options) of
    {ok,ListenSocket}->
      {ok,ListenSocket};
    {error,Reason} ->
      {error,Reason}
  end.

accept_loop(ListenSocket)->
  case (gen_tcp:accept(ListenSocket, 3000))of
    {ok,Socket} ->
      process_clientSocket(Socket),
      ?MODULE:accept_loop(ListenSocket);
    {error,Reason} ->
      ?MODULE:accept_loop(ListenSocket);
    {exit,Reason}->
      ?MODULE:accept_loop(ListenSocket)
  end.

process_clientSocket(Socket)->

  ?DEBUG(Socket),

  Client = #clientInfo{uid = get_id(), socket = Socket},

  case chat_server_handler:start_link(Client) of
      {ok, Pid} ->  gen_tcp:controlling_process(Socket, Pid),

      gen_server:call(chat_manager, {register, Client#clientInfo{pid = Pid}});

    _Other -> ?DEBUG(_Other)
  end,
  ok.

get_id() ->

  list_to_atom([trunc(random:uniform()  * 100), trunc(random:uniform()  * 100), trunc(random:uniform()  * 100)]).

%% bindPid(Record,Socket)->
%%   io:format("binding socket...~n"),
%%   case gen_tcp:controlling_process(Socket, Record#clientinfo.pid) of
%%     {error,Reason}->
%%       io:format("binding socket...error~n");
%%     ok ->
%%
%%       NewRec =#clientinfo{id=Record#clientinfo.id,socket=Socket,pid=Record#clientinfo.pid},
%%       io:format("chat_room:insert record ~p~n",[NewRec]),
%%       ets:insert(clientinfo, NewRec),
%%       Pid=Record#clientinfo.pid,
%%       Pid!{bind,Socket},
%%       io:format("clientBinded~n")
%%   end
