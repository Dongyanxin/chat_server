#!/bin/sh


cd /Users/xin/erlang/chat_server

rebar clean compile

cd /Users/xin/erlang/chat_server/src

./startup.sh
