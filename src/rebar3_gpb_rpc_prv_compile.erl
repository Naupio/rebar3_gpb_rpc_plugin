-module(rebar3_gpb_rpc_prv_compile).

-export([init/1,
         do/1,
         format_error/1]).

-define(PROVIDER, 'compile').
-define(DEPS, [{default, app_discovery}]).
-define(SHORT_DESC, "Automatically compile Google Protocol Buffer (.proto) ",
                    "files using the gpb compiler").
-define(DESC,"Configure gpb options (gbp_opts) in your rebar.config, e.g.\n"
             "  {gpb_opts,["
             "    {i, \"path/to/proto_dir\"},"
             "    {module_name_suffix, \"_pb\"},"
             "    {o_erl, \"path/to/out_src\"},"
             "    {o_hrl, \"path/to/out_include\"},"
             "    {strings_as_binaries, true},"
             "    type_specs]}).").

%% ===================================================================
%% Public API
%% ===================================================================
-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
            {name, ?PROVIDER},            % The 'user friendly' name of the task
            {namespace, gpb_rpc},
            {module, ?MODULE},            % The module implementation of the task
            {bare, true},                 % The task can be run by the user, always true
            {deps, ?DEPS},                % The list of dependencies
            {opts, []},                   % list of options understood by the plugin
            {example, "rebar3 gpb_rpc compile"},
            {short_desc, ?SHORT_DESC},
            {desc, ?DESC}
    ]),
    {ok, rebar_state:add_provider(State, Provider)}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()}.
do(State) ->
    case rebar_state:current_app(State) of
        undefined ->
            Apps = rebar_state:project_apps(State),
            NewApps = lists:map(fun rebar3_gpb_rpc_compiler:compile/1, Apps),
            {ok, rebar_state:project_apps(State, NewApps)};
        AppInfo ->
            CurrentApp = rebar3_gpb_rpc_compiler:compile(AppInfo),
            {ok, rebar_state:current_app(State, CurrentApp)}
    end.

-spec format_error(any()) ->  iolist().
format_error(Reason) ->
    io_lib:format("~p", [Reason]).
