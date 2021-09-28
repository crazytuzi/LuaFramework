-- Generated By protoc-gen-lua Do not Edit

local _pb = {}


local protobuf = require "protobuf/protobuf"
module('task_pb')


PLAYERTASKMSG = protobuf.Descriptor();
_pb.PLAYERTASKMSG_TASKID_FIELD = protobuf.FieldDescriptor();
_pb.PLAYERTASKMSG_TYPE_FIELD = protobuf.FieldDescriptor();
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD = protobuf.FieldDescriptor();
_pb.PLAYERTASKMSG_TASKSTATE_FIELD = protobuf.FieldDescriptor();
C_SUBMITTASK = protobuf.Descriptor();
_pb.C_SUBMITTASK_TASKID_FIELD = protobuf.FieldDescriptor();
S_SUBMITTASK = protobuf.Descriptor();
_pb.S_SUBMITTASK_TASKID_FIELD = protobuf.FieldDescriptor();
_pb.S_SUBMITTASK_PLAYERTASK_FIELD = protobuf.FieldDescriptor();
S_SYNTASKTRACK = protobuf.Descriptor();
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD = protobuf.FieldDescriptor();
C_COMPLETETASK = protobuf.Descriptor();
_pb.C_COMPLETETASK_TASKID_FIELD = protobuf.FieldDescriptor();
C_GETDAILYTASKLIST = protobuf.Descriptor();
C_REFRSHDAILYTASK = protobuf.Descriptor();
_pb.C_REFRSHDAILYTASK_TYPE_FIELD = protobuf.FieldDescriptor();
C_ACCEPTDAILYTASK = protobuf.Descriptor();
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD = protobuf.FieldDescriptor();
C_ABANDONTASK = protobuf.Descriptor();
_pb.C_ABANDONTASK_TASKID_FIELD = protobuf.FieldDescriptor();
S_ABANDONTASK = protobuf.Descriptor();
_pb.S_ABANDONTASK_TASKID_FIELD = protobuf.FieldDescriptor();
S_SYNDAILYTASKLIST = protobuf.Descriptor();
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD = protobuf.FieldDescriptor();
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD = protobuf.FieldDescriptor();
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD = protobuf.FieldDescriptor();
C_ACCEPTWEEKTASK = protobuf.Descriptor();

_pb.PLAYERTASKMSG_TASKID_FIELD.name = "taskId"
_pb.PLAYERTASKMSG_TASKID_FIELD.full_name = ".PlayerTaskMsg.taskId"
_pb.PLAYERTASKMSG_TASKID_FIELD.number = 1
_pb.PLAYERTASKMSG_TASKID_FIELD.index = 0
_pb.PLAYERTASKMSG_TASKID_FIELD.label = 1
_pb.PLAYERTASKMSG_TASKID_FIELD.has_default_value = false
_pb.PLAYERTASKMSG_TASKID_FIELD.default_value = 0
_pb.PLAYERTASKMSG_TASKID_FIELD.type = 5
_pb.PLAYERTASKMSG_TASKID_FIELD.cpp_type = 1

_pb.PLAYERTASKMSG_TYPE_FIELD.name = "type"
_pb.PLAYERTASKMSG_TYPE_FIELD.full_name = ".PlayerTaskMsg.type"
_pb.PLAYERTASKMSG_TYPE_FIELD.number = 2
_pb.PLAYERTASKMSG_TYPE_FIELD.index = 1
_pb.PLAYERTASKMSG_TYPE_FIELD.label = 1
_pb.PLAYERTASKMSG_TYPE_FIELD.has_default_value = false
_pb.PLAYERTASKMSG_TYPE_FIELD.default_value = 0
_pb.PLAYERTASKMSG_TYPE_FIELD.type = 5
_pb.PLAYERTASKMSG_TYPE_FIELD.cpp_type = 1

_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.name = "currentNum"
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.full_name = ".PlayerTaskMsg.currentNum"
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.number = 3
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.index = 2
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.label = 1
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.has_default_value = false
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.default_value = 0
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.type = 5
_pb.PLAYERTASKMSG_CURRENTNUM_FIELD.cpp_type = 1

_pb.PLAYERTASKMSG_TASKSTATE_FIELD.name = "taskState"
_pb.PLAYERTASKMSG_TASKSTATE_FIELD.full_name = ".PlayerTaskMsg.taskState"
_pb.PLAYERTASKMSG_TASKSTATE_FIELD.number = 4
_pb.PLAYERTASKMSG_TASKSTATE_FIELD.index = 3
_pb.PLAYERTASKMSG_TASKSTATE_FIELD.label = 1
_pb.PLAYERTASKMSG_TASKSTATE_FIELD.has_default_value = false
_pb.PLAYERTASKMSG_TASKSTATE_FIELD.default_value = 0
_pb.PLAYERTASKMSG_TASKSTATE_FIELD.type = 5
_pb.PLAYERTASKMSG_TASKSTATE_FIELD.cpp_type = 1

PLAYERTASKMSG.name = "PlayerTaskMsg"
PLAYERTASKMSG.full_name = ".PlayerTaskMsg"
PLAYERTASKMSG.nested_types = {}
PLAYERTASKMSG.enum_types = {}
PLAYERTASKMSG.fields = {_pb.PLAYERTASKMSG_TASKID_FIELD, _pb.PLAYERTASKMSG_TYPE_FIELD, _pb.PLAYERTASKMSG_CURRENTNUM_FIELD, _pb.PLAYERTASKMSG_TASKSTATE_FIELD}
PLAYERTASKMSG.is_extendable = false
PLAYERTASKMSG.extensions = {}
_pb.C_SUBMITTASK_TASKID_FIELD.name = "taskId"
_pb.C_SUBMITTASK_TASKID_FIELD.full_name = ".C_SubmitTask.taskId"
_pb.C_SUBMITTASK_TASKID_FIELD.number = 1
_pb.C_SUBMITTASK_TASKID_FIELD.index = 0
_pb.C_SUBMITTASK_TASKID_FIELD.label = 1
_pb.C_SUBMITTASK_TASKID_FIELD.has_default_value = false
_pb.C_SUBMITTASK_TASKID_FIELD.default_value = 0
_pb.C_SUBMITTASK_TASKID_FIELD.type = 5
_pb.C_SUBMITTASK_TASKID_FIELD.cpp_type = 1

C_SUBMITTASK.name = "C_SubmitTask"
C_SUBMITTASK.full_name = ".C_SubmitTask"
C_SUBMITTASK.nested_types = {}
C_SUBMITTASK.enum_types = {}
C_SUBMITTASK.fields = {_pb.C_SUBMITTASK_TASKID_FIELD}
C_SUBMITTASK.is_extendable = false
C_SUBMITTASK.extensions = {}
_pb.S_SUBMITTASK_TASKID_FIELD.name = "taskId"
_pb.S_SUBMITTASK_TASKID_FIELD.full_name = ".S_SubmitTask.taskId"
_pb.S_SUBMITTASK_TASKID_FIELD.number = 1
_pb.S_SUBMITTASK_TASKID_FIELD.index = 0
_pb.S_SUBMITTASK_TASKID_FIELD.label = 1
_pb.S_SUBMITTASK_TASKID_FIELD.has_default_value = false
_pb.S_SUBMITTASK_TASKID_FIELD.default_value = 0
_pb.S_SUBMITTASK_TASKID_FIELD.type = 5
_pb.S_SUBMITTASK_TASKID_FIELD.cpp_type = 1

_pb.S_SUBMITTASK_PLAYERTASK_FIELD.name = "playerTask"
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.full_name = ".S_SubmitTask.playerTask"
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.number = 2
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.index = 1
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.label = 3
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.has_default_value = false
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.default_value = {}
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.message_type = PLAYERTASKMSG
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.type = 11
_pb.S_SUBMITTASK_PLAYERTASK_FIELD.cpp_type = 10

S_SUBMITTASK.name = "S_SubmitTask"
S_SUBMITTASK.full_name = ".S_SubmitTask"
S_SUBMITTASK.nested_types = {}
S_SUBMITTASK.enum_types = {}
S_SUBMITTASK.fields = {_pb.S_SUBMITTASK_TASKID_FIELD, _pb.S_SUBMITTASK_PLAYERTASK_FIELD}
S_SUBMITTASK.is_extendable = false
S_SUBMITTASK.extensions = {}
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.name = "playerTask"
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.full_name = ".S_SynTaskTrack.playerTask"
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.number = 1
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.index = 0
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.label = 1
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.has_default_value = false
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.default_value = nil
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.message_type = PLAYERTASKMSG
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.type = 11
_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD.cpp_type = 10

S_SYNTASKTRACK.name = "S_SynTaskTrack"
S_SYNTASKTRACK.full_name = ".S_SynTaskTrack"
S_SYNTASKTRACK.nested_types = {}
S_SYNTASKTRACK.enum_types = {}
S_SYNTASKTRACK.fields = {_pb.S_SYNTASKTRACK_PLAYERTASK_FIELD}
S_SYNTASKTRACK.is_extendable = false
S_SYNTASKTRACK.extensions = {}
_pb.C_COMPLETETASK_TASKID_FIELD.name = "taskId"
_pb.C_COMPLETETASK_TASKID_FIELD.full_name = ".C_CompleteTask.taskId"
_pb.C_COMPLETETASK_TASKID_FIELD.number = 1
_pb.C_COMPLETETASK_TASKID_FIELD.index = 0
_pb.C_COMPLETETASK_TASKID_FIELD.label = 1
_pb.C_COMPLETETASK_TASKID_FIELD.has_default_value = false
_pb.C_COMPLETETASK_TASKID_FIELD.default_value = 0
_pb.C_COMPLETETASK_TASKID_FIELD.type = 5
_pb.C_COMPLETETASK_TASKID_FIELD.cpp_type = 1

C_COMPLETETASK.name = "C_CompleteTask"
C_COMPLETETASK.full_name = ".C_CompleteTask"
C_COMPLETETASK.nested_types = {}
C_COMPLETETASK.enum_types = {}
C_COMPLETETASK.fields = {_pb.C_COMPLETETASK_TASKID_FIELD}
C_COMPLETETASK.is_extendable = false
C_COMPLETETASK.extensions = {}
C_GETDAILYTASKLIST.name = "C_GetDailyTaskList"
C_GETDAILYTASKLIST.full_name = ".C_GetDailyTaskList"
C_GETDAILYTASKLIST.nested_types = {}
C_GETDAILYTASKLIST.enum_types = {}
C_GETDAILYTASKLIST.fields = {}
C_GETDAILYTASKLIST.is_extendable = false
C_GETDAILYTASKLIST.extensions = {}
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.name = "type"
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.full_name = ".C_RefrshDailyTask.type"
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.number = 1
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.index = 0
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.label = 1
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.has_default_value = false
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.default_value = 0
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.type = 5
_pb.C_REFRSHDAILYTASK_TYPE_FIELD.cpp_type = 1

C_REFRSHDAILYTASK.name = "C_RefrshDailyTask"
C_REFRSHDAILYTASK.full_name = ".C_RefrshDailyTask"
C_REFRSHDAILYTASK.nested_types = {}
C_REFRSHDAILYTASK.enum_types = {}
C_REFRSHDAILYTASK.fields = {_pb.C_REFRSHDAILYTASK_TYPE_FIELD}
C_REFRSHDAILYTASK.is_extendable = false
C_REFRSHDAILYTASK.extensions = {}
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.name = "taskId"
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.full_name = ".C_AcceptDailyTask.taskId"
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.number = 1
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.index = 0
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.label = 1
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.has_default_value = false
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.default_value = 0
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.type = 5
_pb.C_ACCEPTDAILYTASK_TASKID_FIELD.cpp_type = 1

C_ACCEPTDAILYTASK.name = "C_AcceptDailyTask"
C_ACCEPTDAILYTASK.full_name = ".C_AcceptDailyTask"
C_ACCEPTDAILYTASK.nested_types = {}
C_ACCEPTDAILYTASK.enum_types = {}
C_ACCEPTDAILYTASK.fields = {_pb.C_ACCEPTDAILYTASK_TASKID_FIELD}
C_ACCEPTDAILYTASK.is_extendable = false
C_ACCEPTDAILYTASK.extensions = {}
_pb.C_ABANDONTASK_TASKID_FIELD.name = "taskId"
_pb.C_ABANDONTASK_TASKID_FIELD.full_name = ".C_AbandonTask.taskId"
_pb.C_ABANDONTASK_TASKID_FIELD.number = 1
_pb.C_ABANDONTASK_TASKID_FIELD.index = 0
_pb.C_ABANDONTASK_TASKID_FIELD.label = 1
_pb.C_ABANDONTASK_TASKID_FIELD.has_default_value = false
_pb.C_ABANDONTASK_TASKID_FIELD.default_value = 0
_pb.C_ABANDONTASK_TASKID_FIELD.type = 5
_pb.C_ABANDONTASK_TASKID_FIELD.cpp_type = 1

C_ABANDONTASK.name = "C_AbandonTask"
C_ABANDONTASK.full_name = ".C_AbandonTask"
C_ABANDONTASK.nested_types = {}
C_ABANDONTASK.enum_types = {}
C_ABANDONTASK.fields = {_pb.C_ABANDONTASK_TASKID_FIELD}
C_ABANDONTASK.is_extendable = false
C_ABANDONTASK.extensions = {}
_pb.S_ABANDONTASK_TASKID_FIELD.name = "taskId"
_pb.S_ABANDONTASK_TASKID_FIELD.full_name = ".S_AbandonTask.taskId"
_pb.S_ABANDONTASK_TASKID_FIELD.number = 1
_pb.S_ABANDONTASK_TASKID_FIELD.index = 0
_pb.S_ABANDONTASK_TASKID_FIELD.label = 1
_pb.S_ABANDONTASK_TASKID_FIELD.has_default_value = false
_pb.S_ABANDONTASK_TASKID_FIELD.default_value = 0
_pb.S_ABANDONTASK_TASKID_FIELD.type = 5
_pb.S_ABANDONTASK_TASKID_FIELD.cpp_type = 1

S_ABANDONTASK.name = "S_AbandonTask"
S_ABANDONTASK.full_name = ".S_AbandonTask"
S_ABANDONTASK.nested_types = {}
S_ABANDONTASK.enum_types = {}
S_ABANDONTASK.fields = {_pb.S_ABANDONTASK_TASKID_FIELD}
S_ABANDONTASK.is_extendable = false
S_ABANDONTASK.extensions = {}
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.name = "dailyTaskNum"
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.full_name = ".S_SynDailyTaskList.dailyTaskNum"
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.number = 1
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.index = 0
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.label = 1
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.has_default_value = false
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.default_value = 0
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.type = 5
_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD.cpp_type = 1

_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.name = "dailyRefNum"
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.full_name = ".S_SynDailyTaskList.dailyRefNum"
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.number = 2
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.index = 1
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.label = 1
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.has_default_value = false
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.default_value = 0
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.type = 5
_pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD.cpp_type = 1

_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.name = "taskIds"
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.full_name = ".S_SynDailyTaskList.taskIds"
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.number = 3
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.index = 2
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.label = 3
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.has_default_value = false
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.default_value = {}
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.type = 5
_pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD.cpp_type = 1

S_SYNDAILYTASKLIST.name = "S_SynDailyTaskList"
S_SYNDAILYTASKLIST.full_name = ".S_SynDailyTaskList"
S_SYNDAILYTASKLIST.nested_types = {}
S_SYNDAILYTASKLIST.enum_types = {}
S_SYNDAILYTASKLIST.fields = {_pb.S_SYNDAILYTASKLIST_DAILYTASKNUM_FIELD, _pb.S_SYNDAILYTASKLIST_DAILYREFNUM_FIELD, _pb.S_SYNDAILYTASKLIST_TASKIDS_FIELD}
S_SYNDAILYTASKLIST.is_extendable = false
S_SYNDAILYTASKLIST.extensions = {}
C_ACCEPTWEEKTASK.name = "C_AcceptWeekTask"
C_ACCEPTWEEKTASK.full_name = ".C_AcceptWeekTask"
C_ACCEPTWEEKTASK.nested_types = {}
C_ACCEPTWEEKTASK.enum_types = {}
C_ACCEPTWEEKTASK.fields = {}
C_ACCEPTWEEKTASK.is_extendable = false
C_ACCEPTWEEKTASK.extensions = {}

C_AbandonTask = protobuf.Message(C_ABANDONTASK)
C_AcceptDailyTask = protobuf.Message(C_ACCEPTDAILYTASK)
C_AcceptWeekTask = protobuf.Message(C_ACCEPTWEEKTASK)
C_CompleteTask = protobuf.Message(C_COMPLETETASK)
C_GetDailyTaskList = protobuf.Message(C_GETDAILYTASKLIST)
C_RefrshDailyTask = protobuf.Message(C_REFRSHDAILYTASK)
C_SubmitTask = protobuf.Message(C_SUBMITTASK)
PlayerTaskMsg = protobuf.Message(PLAYERTASKMSG)
S_AbandonTask = protobuf.Message(S_ABANDONTASK)
S_SubmitTask = protobuf.Message(S_SUBMITTASK)
S_SynDailyTaskList = protobuf.Message(S_SYNDAILYTASKLIST)
S_SynTaskTrack = protobuf.Message(S_SYNTASKTRACK)

