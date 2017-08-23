%%%===================================================================
%%% @author hh
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(tr_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).

-define(SERVER, ?MODULE).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%-------------------------------------------------------------------
%%% Callback Functions
%%%-------------------------------------------------------------------
init(_Args) ->
    RestartArgs = {
        one_for_one, 0, 1
    },
    Server = {tr_server, {tr_server, start_link, []}, permanent, 2000, worker, [tr_server]},
    ChildSpecs = [
        Server
        % #{
        %     id       => child_process,
        %     start    => {child_process, start_link, []},
        %     restart  => permanent,
        %     shutdown => 5000,
        %     type     => worker,
        %     modules  => [child_process]
        % }
    ],
    {ok, {RestartArgs, ChildSpecs}}.
