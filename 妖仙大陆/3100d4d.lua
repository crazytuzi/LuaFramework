
local protobuf = require "protobuf"
module('sysSetHandler_pb')


SETDATA = protobuf.Descriptor();
local SETDATA_RECVMAILSET_FIELD = protobuf.FieldDescriptor();
local SETDATA_TEAMINVITESET_FIELD = protobuf.FieldDescriptor();
local SETDATA_RECVSTRANGERMSGSET_FIELD = protobuf.FieldDescriptor();
local SETDATA_RECVADDFRIENDSET_FIELD = protobuf.FieldDescriptor();
CHANGESYSSETREQUEST = protobuf.Descriptor();
local CHANGESYSSETREQUEST_C2S_SETDATA_FIELD = protobuf.FieldDescriptor();
CHANGESYSSETRESPONSE = protobuf.Descriptor();
local CHANGESYSSETRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local CHANGESYSSETRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();

SETDATA_RECVMAILSET_FIELD.name = "recvMailSet"
SETDATA_RECVMAILSET_FIELD.full_name = ".pomelo.area.SetData.recvMailSet"
SETDATA_RECVMAILSET_FIELD.number = 1
SETDATA_RECVMAILSET_FIELD.index = 0
SETDATA_RECVMAILSET_FIELD.label = 2
SETDATA_RECVMAILSET_FIELD.has_default_value = false
SETDATA_RECVMAILSET_FIELD.default_value = 0
SETDATA_RECVMAILSET_FIELD.type = 5
SETDATA_RECVMAILSET_FIELD.cpp_type = 1

SETDATA_TEAMINVITESET_FIELD.name = "teamInviteSet"
SETDATA_TEAMINVITESET_FIELD.full_name = ".pomelo.area.SetData.teamInviteSet"
SETDATA_TEAMINVITESET_FIELD.number = 2
SETDATA_TEAMINVITESET_FIELD.index = 1
SETDATA_TEAMINVITESET_FIELD.label = 2
SETDATA_TEAMINVITESET_FIELD.has_default_value = false
SETDATA_TEAMINVITESET_FIELD.default_value = 0
SETDATA_TEAMINVITESET_FIELD.type = 5
SETDATA_TEAMINVITESET_FIELD.cpp_type = 1

SETDATA_RECVSTRANGERMSGSET_FIELD.name = "recvStrangerMsgSet"
SETDATA_RECVSTRANGERMSGSET_FIELD.full_name = ".pomelo.area.SetData.recvStrangerMsgSet"
SETDATA_RECVSTRANGERMSGSET_FIELD.number = 3
SETDATA_RECVSTRANGERMSGSET_FIELD.index = 2
SETDATA_RECVSTRANGERMSGSET_FIELD.label = 2
SETDATA_RECVSTRANGERMSGSET_FIELD.has_default_value = false
SETDATA_RECVSTRANGERMSGSET_FIELD.default_value = 0
SETDATA_RECVSTRANGERMSGSET_FIELD.type = 5
SETDATA_RECVSTRANGERMSGSET_FIELD.cpp_type = 1

SETDATA_RECVADDFRIENDSET_FIELD.name = "recvAddFriendSet"
SETDATA_RECVADDFRIENDSET_FIELD.full_name = ".pomelo.area.SetData.recvAddFriendSet"
SETDATA_RECVADDFRIENDSET_FIELD.number = 4
SETDATA_RECVADDFRIENDSET_FIELD.index = 3
SETDATA_RECVADDFRIENDSET_FIELD.label = 2
SETDATA_RECVADDFRIENDSET_FIELD.has_default_value = false
SETDATA_RECVADDFRIENDSET_FIELD.default_value = 0
SETDATA_RECVADDFRIENDSET_FIELD.type = 5
SETDATA_RECVADDFRIENDSET_FIELD.cpp_type = 1

SETDATA.name = "SetData"
SETDATA.full_name = ".pomelo.area.SetData"
SETDATA.nested_types = {}
SETDATA.enum_types = {}
SETDATA.fields = {SETDATA_RECVMAILSET_FIELD, SETDATA_TEAMINVITESET_FIELD, SETDATA_RECVSTRANGERMSGSET_FIELD, SETDATA_RECVADDFRIENDSET_FIELD}
SETDATA.is_extendable = false
SETDATA.extensions = {}
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.name = "c2s_setData"
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.full_name = ".pomelo.area.ChangeSysSetRequest.c2s_setData"
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.number = 1
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.index = 0
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.label = 2
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.has_default_value = false
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.default_value = nil
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.message_type = SETDATA
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.type = 11
CHANGESYSSETREQUEST_C2S_SETDATA_FIELD.cpp_type = 10

CHANGESYSSETREQUEST.name = "ChangeSysSetRequest"
CHANGESYSSETREQUEST.full_name = ".pomelo.area.ChangeSysSetRequest"
CHANGESYSSETREQUEST.nested_types = {}
CHANGESYSSETREQUEST.enum_types = {}
CHANGESYSSETREQUEST.fields = {CHANGESYSSETREQUEST_C2S_SETDATA_FIELD}
CHANGESYSSETREQUEST.is_extendable = false
CHANGESYSSETREQUEST.extensions = {}
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.ChangeSysSetResponse.s2c_code"
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.number = 1
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.index = 0
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.label = 2
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.has_default_value = false
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.default_value = 0
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.type = 5
CHANGESYSSETRESPONSE_S2C_CODE_FIELD.cpp_type = 1

CHANGESYSSETRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
CHANGESYSSETRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.ChangeSysSetResponse.s2c_msg"
CHANGESYSSETRESPONSE_S2C_MSG_FIELD.number = 2
CHANGESYSSETRESPONSE_S2C_MSG_FIELD.index = 1
CHANGESYSSETRESPONSE_S2C_MSG_FIELD.label = 1
CHANGESYSSETRESPONSE_S2C_MSG_FIELD.has_default_value = false
CHANGESYSSETRESPONSE_S2C_MSG_FIELD.default_value = ""
CHANGESYSSETRESPONSE_S2C_MSG_FIELD.type = 9
CHANGESYSSETRESPONSE_S2C_MSG_FIELD.cpp_type = 9

CHANGESYSSETRESPONSE.name = "ChangeSysSetResponse"
CHANGESYSSETRESPONSE.full_name = ".pomelo.area.ChangeSysSetResponse"
CHANGESYSSETRESPONSE.nested_types = {}
CHANGESYSSETRESPONSE.enum_types = {}
CHANGESYSSETRESPONSE.fields = {CHANGESYSSETRESPONSE_S2C_CODE_FIELD, CHANGESYSSETRESPONSE_S2C_MSG_FIELD}
CHANGESYSSETRESPONSE.is_extendable = false
CHANGESYSSETRESPONSE.extensions = {}

ChangeSysSetRequest = protobuf.Message(CHANGESYSSETREQUEST)
ChangeSysSetResponse = protobuf.Message(CHANGESYSSETRESPONSE)
SetData = protobuf.Message(SETDATA)
