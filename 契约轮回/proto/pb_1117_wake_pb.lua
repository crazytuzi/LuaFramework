-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "tolua.protobuf/protobuf"
module('pb_1117_wake_pb')


M_WAKE_INFO_TOS = protobuf.Descriptor();
M_WAKE_INFO_TOC = protobuf.Descriptor();
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD = protobuf.FieldDescriptor();
M_WAKE_TASK_TOS = protobuf.Descriptor();
M_WAKE_TASK_TOC = protobuf.Descriptor();
M_WAKE_TASK_TOC_TASKSENTRY = protobuf.Descriptor();
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD = protobuf.FieldDescriptor();
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD = protobuf.FieldDescriptor();
M_WAKE_TASK_TOC_CUR_STEP_FIELD = protobuf.FieldDescriptor();
M_WAKE_TASK_TOC_TASKS_FIELD = protobuf.FieldDescriptor();
M_WAKE_START_TOS = protobuf.Descriptor();
M_WAKE_START_TOS_WAKE_TYPE_FIELD = protobuf.FieldDescriptor();
M_WAKE_START_TOC = protobuf.Descriptor();
M_WAKE_NEXT_STEP_TOS = protobuf.Descriptor();
M_WAKE_NEXT_STEP_TOC = protobuf.Descriptor();
M_WAKE_ACTIVE_GRID_TOS = protobuf.Descriptor();
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD = protobuf.FieldDescriptor();
M_WAKE_ACTIVE_GRID_TOC = protobuf.Descriptor();
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD = protobuf.FieldDescriptor();
M_WAKE_GET_GRIDS_TOS = protobuf.Descriptor();
M_WAKE_GET_GRIDS_TOC = protobuf.Descriptor();
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD = protobuf.FieldDescriptor();

M_WAKE_INFO_TOS.name = "m_wake_info_tos"
M_WAKE_INFO_TOS.full_name = ".m_wake_info_tos"
M_WAKE_INFO_TOS.nested_types = {}
M_WAKE_INFO_TOS.enum_types = {}
M_WAKE_INFO_TOS.fields = {}
M_WAKE_INFO_TOS.is_extendable = false
M_WAKE_INFO_TOS.extensions = {}
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.name = "wake_times"
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.full_name = ".m_wake_info_toc.wake_times"
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.number = 1
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.index = 0
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.label = 2
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.has_default_value = false
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.default_value = 0
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.type = 5
M_WAKE_INFO_TOC_WAKE_TIMES_FIELD.cpp_type = 1

M_WAKE_INFO_TOC.name = "m_wake_info_toc"
M_WAKE_INFO_TOC.full_name = ".m_wake_info_toc"
M_WAKE_INFO_TOC.nested_types = {}
M_WAKE_INFO_TOC.enum_types = {}
M_WAKE_INFO_TOC.fields = {M_WAKE_INFO_TOC_WAKE_TIMES_FIELD}
M_WAKE_INFO_TOC.is_extendable = false
M_WAKE_INFO_TOC.extensions = {}
M_WAKE_TASK_TOS.name = "m_wake_task_tos"
M_WAKE_TASK_TOS.full_name = ".m_wake_task_tos"
M_WAKE_TASK_TOS.nested_types = {}
M_WAKE_TASK_TOS.enum_types = {}
M_WAKE_TASK_TOS.fields = {}
M_WAKE_TASK_TOS.is_extendable = false
M_WAKE_TASK_TOS.extensions = {}
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.name = "key"
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.full_name = ".m_wake_task_toc.TasksEntry.key"
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.number = 1
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.index = 0
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.label = 1
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.has_default_value = false
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.default_value = 0
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.type = 5
M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD.cpp_type = 1

M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.name = "value"
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.full_name = ".m_wake_task_toc.TasksEntry.value"
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.number = 2
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.index = 1
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.label = 1
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.has_default_value = false
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.default_value = 0
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.type = 5
M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD.cpp_type = 1

M_WAKE_TASK_TOC_TASKSENTRY.name = "TasksEntry"
M_WAKE_TASK_TOC_TASKSENTRY.full_name = ".m_wake_task_toc.TasksEntry"
M_WAKE_TASK_TOC_TASKSENTRY.nested_types = {}
M_WAKE_TASK_TOC_TASKSENTRY.enum_types = {}
M_WAKE_TASK_TOC_TASKSENTRY.fields = {M_WAKE_TASK_TOC_TASKSENTRY_KEY_FIELD, M_WAKE_TASK_TOC_TASKSENTRY_VALUE_FIELD}
M_WAKE_TASK_TOC_TASKSENTRY.is_extendable = false
M_WAKE_TASK_TOC_TASKSENTRY.extensions = {}
M_WAKE_TASK_TOC_TASKSENTRY.containing_type = M_WAKE_TASK_TOC
M_WAKE_TASK_TOC_CUR_STEP_FIELD.name = "cur_step"
M_WAKE_TASK_TOC_CUR_STEP_FIELD.full_name = ".m_wake_task_toc.cur_step"
M_WAKE_TASK_TOC_CUR_STEP_FIELD.number = 1
M_WAKE_TASK_TOC_CUR_STEP_FIELD.index = 0
M_WAKE_TASK_TOC_CUR_STEP_FIELD.label = 2
M_WAKE_TASK_TOC_CUR_STEP_FIELD.has_default_value = false
M_WAKE_TASK_TOC_CUR_STEP_FIELD.default_value = 0
M_WAKE_TASK_TOC_CUR_STEP_FIELD.type = 5
M_WAKE_TASK_TOC_CUR_STEP_FIELD.cpp_type = 1

M_WAKE_TASK_TOC_TASKS_FIELD.name = "tasks"
M_WAKE_TASK_TOC_TASKS_FIELD.full_name = ".m_wake_task_toc.tasks"
M_WAKE_TASK_TOC_TASKS_FIELD.number = 2
M_WAKE_TASK_TOC_TASKS_FIELD.index = 1
M_WAKE_TASK_TOC_TASKS_FIELD.label = 3
M_WAKE_TASK_TOC_TASKS_FIELD.has_default_value = false
M_WAKE_TASK_TOC_TASKS_FIELD.default_value = {}
M_WAKE_TASK_TOC_TASKS_FIELD.message_type = M_WAKE_TASK_TOC_TASKSENTRY
M_WAKE_TASK_TOC_TASKS_FIELD.type = 11
M_WAKE_TASK_TOC_TASKS_FIELD.cpp_type = 10

M_WAKE_TASK_TOC.name = "m_wake_task_toc"
M_WAKE_TASK_TOC.full_name = ".m_wake_task_toc"
M_WAKE_TASK_TOC.nested_types = {M_WAKE_TASK_TOC_TASKSENTRY}
M_WAKE_TASK_TOC.enum_types = {}
M_WAKE_TASK_TOC.fields = {M_WAKE_TASK_TOC_CUR_STEP_FIELD, M_WAKE_TASK_TOC_TASKS_FIELD}
M_WAKE_TASK_TOC.is_extendable = false
M_WAKE_TASK_TOC.extensions = {}
M_WAKE_START_TOS_WAKE_TYPE_FIELD.name = "wake_type"
M_WAKE_START_TOS_WAKE_TYPE_FIELD.full_name = ".m_wake_start_tos.wake_type"
M_WAKE_START_TOS_WAKE_TYPE_FIELD.number = 1
M_WAKE_START_TOS_WAKE_TYPE_FIELD.index = 0
M_WAKE_START_TOS_WAKE_TYPE_FIELD.label = 1
M_WAKE_START_TOS_WAKE_TYPE_FIELD.has_default_value = false
M_WAKE_START_TOS_WAKE_TYPE_FIELD.default_value = 0
M_WAKE_START_TOS_WAKE_TYPE_FIELD.type = 5
M_WAKE_START_TOS_WAKE_TYPE_FIELD.cpp_type = 1

M_WAKE_START_TOS.name = "m_wake_start_tos"
M_WAKE_START_TOS.full_name = ".m_wake_start_tos"
M_WAKE_START_TOS.nested_types = {}
M_WAKE_START_TOS.enum_types = {}
M_WAKE_START_TOS.fields = {M_WAKE_START_TOS_WAKE_TYPE_FIELD}
M_WAKE_START_TOS.is_extendable = false
M_WAKE_START_TOS.extensions = {}
M_WAKE_START_TOC.name = "m_wake_start_toc"
M_WAKE_START_TOC.full_name = ".m_wake_start_toc"
M_WAKE_START_TOC.nested_types = {}
M_WAKE_START_TOC.enum_types = {}
M_WAKE_START_TOC.fields = {}
M_WAKE_START_TOC.is_extendable = false
M_WAKE_START_TOC.extensions = {}
M_WAKE_NEXT_STEP_TOS.name = "m_wake_next_step_tos"
M_WAKE_NEXT_STEP_TOS.full_name = ".m_wake_next_step_tos"
M_WAKE_NEXT_STEP_TOS.nested_types = {}
M_WAKE_NEXT_STEP_TOS.enum_types = {}
M_WAKE_NEXT_STEP_TOS.fields = {}
M_WAKE_NEXT_STEP_TOS.is_extendable = false
M_WAKE_NEXT_STEP_TOS.extensions = {}
M_WAKE_NEXT_STEP_TOC.name = "m_wake_next_step_toc"
M_WAKE_NEXT_STEP_TOC.full_name = ".m_wake_next_step_toc"
M_WAKE_NEXT_STEP_TOC.nested_types = {}
M_WAKE_NEXT_STEP_TOC.enum_types = {}
M_WAKE_NEXT_STEP_TOC.fields = {}
M_WAKE_NEXT_STEP_TOC.is_extendable = false
M_WAKE_NEXT_STEP_TOC.extensions = {}
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.name = "grid_id"
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.full_name = ".m_wake_active_grid_tos.grid_id"
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.number = 1
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.index = 0
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.label = 2
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.has_default_value = false
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.default_value = 0
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.type = 5
M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD.cpp_type = 1

M_WAKE_ACTIVE_GRID_TOS.name = "m_wake_active_grid_tos"
M_WAKE_ACTIVE_GRID_TOS.full_name = ".m_wake_active_grid_tos"
M_WAKE_ACTIVE_GRID_TOS.nested_types = {}
M_WAKE_ACTIVE_GRID_TOS.enum_types = {}
M_WAKE_ACTIVE_GRID_TOS.fields = {M_WAKE_ACTIVE_GRID_TOS_GRID_ID_FIELD}
M_WAKE_ACTIVE_GRID_TOS.is_extendable = false
M_WAKE_ACTIVE_GRID_TOS.extensions = {}
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.name = "grid_id"
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.full_name = ".m_wake_active_grid_toc.grid_id"
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.number = 1
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.index = 0
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.label = 2
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.has_default_value = false
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.default_value = 0
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.type = 5
M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD.cpp_type = 1

M_WAKE_ACTIVE_GRID_TOC.name = "m_wake_active_grid_toc"
M_WAKE_ACTIVE_GRID_TOC.full_name = ".m_wake_active_grid_toc"
M_WAKE_ACTIVE_GRID_TOC.nested_types = {}
M_WAKE_ACTIVE_GRID_TOC.enum_types = {}
M_WAKE_ACTIVE_GRID_TOC.fields = {M_WAKE_ACTIVE_GRID_TOC_GRID_ID_FIELD}
M_WAKE_ACTIVE_GRID_TOC.is_extendable = false
M_WAKE_ACTIVE_GRID_TOC.extensions = {}
M_WAKE_GET_GRIDS_TOS.name = "m_wake_get_grids_tos"
M_WAKE_GET_GRIDS_TOS.full_name = ".m_wake_get_grids_tos"
M_WAKE_GET_GRIDS_TOS.nested_types = {}
M_WAKE_GET_GRIDS_TOS.enum_types = {}
M_WAKE_GET_GRIDS_TOS.fields = {}
M_WAKE_GET_GRIDS_TOS.is_extendable = false
M_WAKE_GET_GRIDS_TOS.extensions = {}
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.name = "grid_id"
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.full_name = ".m_wake_get_grids_toc.grid_id"
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.number = 2
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.index = 0
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.label = 2
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.has_default_value = false
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.default_value = 0
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.type = 5
M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD.cpp_type = 1

M_WAKE_GET_GRIDS_TOC.name = "m_wake_get_grids_toc"
M_WAKE_GET_GRIDS_TOC.full_name = ".m_wake_get_grids_toc"
M_WAKE_GET_GRIDS_TOC.nested_types = {}
M_WAKE_GET_GRIDS_TOC.enum_types = {}
M_WAKE_GET_GRIDS_TOC.fields = {M_WAKE_GET_GRIDS_TOC_GRID_ID_FIELD}
M_WAKE_GET_GRIDS_TOC.is_extendable = false
M_WAKE_GET_GRIDS_TOC.extensions = {}

m_wake_active_grid_toc = protobuf.Message(M_WAKE_ACTIVE_GRID_TOC)
m_wake_active_grid_tos = protobuf.Message(M_WAKE_ACTIVE_GRID_TOS)
m_wake_get_grids_toc = protobuf.Message(M_WAKE_GET_GRIDS_TOC)
m_wake_get_grids_tos = protobuf.Message(M_WAKE_GET_GRIDS_TOS)
m_wake_info_toc = protobuf.Message(M_WAKE_INFO_TOC)
m_wake_info_tos = protobuf.Message(M_WAKE_INFO_TOS)
m_wake_next_step_toc = protobuf.Message(M_WAKE_NEXT_STEP_TOC)
m_wake_next_step_tos = protobuf.Message(M_WAKE_NEXT_STEP_TOS)
m_wake_start_toc = protobuf.Message(M_WAKE_START_TOC)
m_wake_start_tos = protobuf.Message(M_WAKE_START_TOS)
m_wake_task_toc = protobuf.Message(M_WAKE_TASK_TOC)
m_wake_task_toc.TasksEntry = protobuf.Message(M_WAKE_TASK_TOC_TASKSENTRY)
m_wake_task_tos = protobuf.Message(M_WAKE_TASK_TOS)

