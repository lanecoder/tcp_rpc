%%%===================================================================
%%% @author hh
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(tr_app).

-behaviour(application).

%% application callbacks
-export([start/2, stop/1]).

%%%-------------------------------------------------------------------
%%% Callback Functions
%%%-------------------------------------------------------------------
start(_Type, _StartArgs) ->
    case tr_sup:start_link() of
        {ok, Pid} ->
            {ok, Pid};
        Other ->
            {error, Other}
    end.

stop(_State) ->
    ok.