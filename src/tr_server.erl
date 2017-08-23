%%%===================================================================
%%% @author hh
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(tr_server).

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%% API
-export([start_link/0, start_link/1]).

-define(SERVER, ?MODULE).
-define(DEFAULT_PORT, 1055).

-record(state, {port, lsock, request_count = 0}).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
    start_link(?DEFAULT_PORT).

start_link(Port) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, [Port]).

get_count() ->
    gen_server:call(?SERVER, get_count).

%%%-------------------------------------------------------------------
%%% Callback Functions
%%%-------------------------------------------------------------------
init([Port]) ->
    {ok, LSock} = gen_tcp:listen(Port, [{active, ture}]),
    {ok, #state{port = Port, lsock = LSock}, 0}.

handle_call(get_count, _From, State) ->
    {reply, {ok, State#state.request_count}, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.

handle_info({tcp, Socket, Rawdata}, State) ->
    do_rpc(Socket, Rawdata),
    Request_count = State#state.request_count,
    {noreply, State#state{request_count = Request_count + 1}};

handle_info(timeout, #state{lsock = LSock} = State) ->
    {ok, _Sock} = gen_tcp:accept(LSock), 
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-------------------------------------------------------------------
%%% Internal Functions
%%%-------------------------------------------------------------------

do_rpc(Socket, Rawdata) ->
    try
        {M, F, A} = split_out_mfa(Rawdata),
        Result = apply(M, F, A),
        gen_tcp:send(Socket, io_lib:format("~p~n", [Result]))
    catch
        _Class:Err ->
            gen_tcp:send(Socket, io_lib:format("~p~n", [Err]))
    end.

split_out_mfa(Rawdata) ->
    MFA = re:replace(Rawdata, "\r\n$", "", [{return, list}]),
    {match, [M, F, A]} = 
        re:run(MFA,
               "(.*):(.*)\s*\\((.*)\s*\\)\s*.\s*$",
                   [{capture, [1,2,3], list}, ungreedy]),
    {list_to_atom(M), list_to_atom(F), args_to_term(A)}.

args_to_term(A) ->
    {ok, Toks, _Line} = erl_scan:string("[ " ++ A ++ " ]. ", 1),
    {ok, Args} = erl_parse:parse_term(Toks),
    Args.