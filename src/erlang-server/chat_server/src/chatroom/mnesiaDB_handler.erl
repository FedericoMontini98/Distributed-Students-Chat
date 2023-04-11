- module(mnesiaDB_handler).

-include("chat.hrl").
-export([mnesia_start/0, add_student/2, get_online_students_for_chatroom/1, logout/1]).

-record(online_students, {course_name, student_pid}).


mnesia_start() ->
	% Create mnesia schema if doesn't exists
	Result = mnesia:create_schema([node()]), %TODO
	mnesia:start(),
	case Result of
		ok->
			io:format("[MNESIA] Mnesia DB started ~n"),
			% Create table
			mnesia:create_table(online_students,[{attributes, record_info(fields, online_students)}, {type, bag}, {ram_copies, [node()]}]); %%TODO
			
		_ ->
			%Print error
			io:format("~p~n", [Result])
	end,
	mnesia:info().



add_student(Course, OnlineStudentPid) ->

	A = fun() ->
		io:format("[MNESIA] Check if the pid of the student: ~p is already in a chatroom ~n", [OnlineStudentPid]), %TODO controllare che tipo è il pid
		NewStudent = #online_students{course_name='$1', student_pid = '$2'},
		Guard = {'==', '$2', OnlineStudentPid},
		NewStudentCheck = mnesia:select(online_students, [{NewStudent, [Guard], ['$2']}]),

		io:format("[MNESIA] Check result: ~p~n", [NewStudentCheck]),
		case NewStudentCheck == [] of 
			true ->
				io:format(" [MNESIA] Student not in any chatrooms, student can be join this chat ~n"),
				mnesia:write(#online_students{course_name=Course, student_pid = OnlineStudentPid});

			false ->
				io:format(" [MNESIA] Student is already in a chatroom ~n"),
				false  
		end
	end,

	{atomic, Result} = mnesia:transaction(A),
	io:format(" [MNESIA] Chatroom student join response: ~p~n",[Result]),
	Result.


  
get_online_students_for_chatroom(Course) ->
	
	G = fun() ->
		io:format("[MNESIA] Get all the online students for the course: ~p~n", [Course]),
		OnlineUser = #online_students{course_name='$1', student_pid = '$2'},
		Guard = {'==', '$1', Course},
		mnesia:select(online_students, [{OnlineUser, [Guard], ['$2']}])
	end,
	
	{atomic, Result} = mnesia:transaction(G),
	io:format("[MNESIA] get_online_students_for_chatroom => ~p~n", [Result]),
	Result.

logout(OnlineStudentPid) -> % TODO ADD COURSE ID
	L = fun() ->

		%io:format("[MNESIA] Check if the pid of the student: ~p exists in a chatroom ~n", [OnlineStudentPid]), %TODO controllare che tipo è il pid
		%StudentToDelete = #online_students{course_name='$1', student_pid = '$2'},
		%Guard = {'==', '$2', OnlineStudentPid},
		%StudentToDeleteCheck = mnesia:select(online_students, [{StudentToDelete, [Guard], ['$2']}]),
		
		%io:format("[MNESIA] Check result: ~p~n", [StudentToDeleteCheck]),
		%case StudentToDeleteCheck == [] of 
		%	true ->
		%		io:format(" [MNESIA] Student not in any chatrooms, student can't execute the logout ~n"),
		%		false;

		%	false ->
		mnesia:delete_object(#online_students{course_name = 1, student_pid = OnlineStudentPid}),
		io:format(" [MNESIA] Student logout from the chatroom ~n")
		%end
	end,

	{atomic, Result} = mnesia:transaction(L),
	io:format("[MNESIA] logout => ~p~n", [Result]),
	Result.

