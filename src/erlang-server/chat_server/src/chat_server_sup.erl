-module(chat_server_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

-define(SERVER, ?MODULE).


% Start supervisor
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).


%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    % Supervisor parameters
    SupFlags = #{strategy => one_for_one,
                 intensity => 1,
                 period => 1},
    % Specs for child processes
    ChatroomServerChild = #{id => chatroom_server,
                            start => {chatroom_server, start_link, []},
                            restart => permanent},
    CourseManagerChild = #{id => course_manager, 
                           start => {course_manager, start_link, []},
                           restart => permanent},
    ChildSpecs = [ChatroomServerChild, CourseManagerChild],
    % Return value
    {ok, {SupFlags, ChildSpecs}}.
