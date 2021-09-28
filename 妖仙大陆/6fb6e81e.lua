
local protobuf = require "protobuf"
module('task_pb')


TASK = protobuf.Descriptor();
local TASK_TEMPLATEID_FIELD = protobuf.FieldDescriptor();
local TASK_PROGRESS_FIELD = protobuf.FieldDescriptor();
local TASK_STATE_FIELD = protobuf.FieldDescriptor();
local TASK_LEFTTIME_FIELD = protobuf.FieldDescriptor();
TASKS = protobuf.Descriptor();
local TASKS_TASKLIST_FIELD = protobuf.FieldDescriptor();

TASK_TEMPLATEID_FIELD.name = "templateId"
TASK_TEMPLATEID_FIELD.full_name = ".pomelo.task.Task.templateId"
TASK_TEMPLATEID_FIELD.number = 1
TASK_TEMPLATEID_FIELD.index = 0
TASK_TEMPLATEID_FIELD.label = 2
TASK_TEMPLATEID_FIELD.has_default_value = false
TASK_TEMPLATEID_FIELD.default_value = 0
TASK_TEMPLATEID_FIELD.type = 5
TASK_TEMPLATEID_FIELD.cpp_type = 1

TASK_PROGRESS_FIELD.name = "progress"
TASK_PROGRESS_FIELD.full_name = ".pomelo.task.Task.progress"
TASK_PROGRESS_FIELD.number = 2
TASK_PROGRESS_FIELD.index = 1
TASK_PROGRESS_FIELD.label = 3
TASK_PROGRESS_FIELD.has_default_value = false
TASK_PROGRESS_FIELD.default_value = {}
TASK_PROGRESS_FIELD.type = 5
TASK_PROGRESS_FIELD.cpp_type = 1

TASK_STATE_FIELD.name = "state"
TASK_STATE_FIELD.full_name = ".pomelo.task.Task.state"
TASK_STATE_FIELD.number = 3
TASK_STATE_FIELD.index = 2
TASK_STATE_FIELD.label = 2
TASK_STATE_FIELD.has_default_value = false
TASK_STATE_FIELD.default_value = 0
TASK_STATE_FIELD.type = 5
TASK_STATE_FIELD.cpp_type = 1

TASK_LEFTTIME_FIELD.name = "leftTime"
TASK_LEFTTIME_FIELD.full_name = ".pomelo.task.Task.leftTime"
TASK_LEFTTIME_FIELD.number = 4
TASK_LEFTTIME_FIELD.index = 3
TASK_LEFTTIME_FIELD.label = 2
TASK_LEFTTIME_FIELD.has_default_value = false
TASK_LEFTTIME_FIELD.default_value = 0
TASK_LEFTTIME_FIELD.type = 5
TASK_LEFTTIME_FIELD.cpp_type = 1

TASK.name = "Task"
TASK.full_name = ".pomelo.task.Task"
TASK.nested_types = {}
TASK.enum_types = {}
TASK.fields = {TASK_TEMPLATEID_FIELD, TASK_PROGRESS_FIELD, TASK_STATE_FIELD, TASK_LEFTTIME_FIELD}
TASK.is_extendable = false
TASK.extensions = {}
TASKS_TASKLIST_FIELD.name = "taskList"
TASKS_TASKLIST_FIELD.full_name = ".pomelo.task.Tasks.taskList"
TASKS_TASKLIST_FIELD.number = 1
TASKS_TASKLIST_FIELD.index = 0
TASKS_TASKLIST_FIELD.label = 3
TASKS_TASKLIST_FIELD.has_default_value = false
TASKS_TASKLIST_FIELD.default_value = {}
TASKS_TASKLIST_FIELD.message_type = TASK
TASKS_TASKLIST_FIELD.type = 11
TASKS_TASKLIST_FIELD.cpp_type = 10

TASKS.name = "Tasks"
TASKS.full_name = ".pomelo.task.Tasks"
TASKS.nested_types = {}
TASKS.enum_types = {}
TASKS.fields = {TASKS_TASKLIST_FIELD}
TASKS.is_extendable = false
TASKS.extensions = {}

Task = protobuf.Message(TASK)
Tasks = protobuf.Message(TASKS)
