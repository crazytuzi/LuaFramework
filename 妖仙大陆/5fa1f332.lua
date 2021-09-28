
local protobuf = require "protobuf"
local item_pb = require("item_pb")
module('stealHandler_pb')


STEALRESPONSE = protobuf.Descriptor();
local STEALRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local STEALRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local STEALRESPONSE_S2C_RESULT_FIELD = protobuf.FieldDescriptor();
local STEALRESPONSE_S2C_ITEMS_FIELD = protobuf.FieldDescriptor();
STEALREQUEST = protobuf.Descriptor();
local STEALREQUEST_C2S_ID_FIELD = protobuf.FieldDescriptor();

STEALRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
STEALRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.StealResponse.s2c_code"
STEALRESPONSE_S2C_CODE_FIELD.number = 1
STEALRESPONSE_S2C_CODE_FIELD.index = 0
STEALRESPONSE_S2C_CODE_FIELD.label = 2
STEALRESPONSE_S2C_CODE_FIELD.has_default_value = false
STEALRESPONSE_S2C_CODE_FIELD.default_value = 0
STEALRESPONSE_S2C_CODE_FIELD.type = 5
STEALRESPONSE_S2C_CODE_FIELD.cpp_type = 1

STEALRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
STEALRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.StealResponse.s2c_msg"
STEALRESPONSE_S2C_MSG_FIELD.number = 2
STEALRESPONSE_S2C_MSG_FIELD.index = 1
STEALRESPONSE_S2C_MSG_FIELD.label = 1
STEALRESPONSE_S2C_MSG_FIELD.has_default_value = false
STEALRESPONSE_S2C_MSG_FIELD.default_value = ""
STEALRESPONSE_S2C_MSG_FIELD.type = 9
STEALRESPONSE_S2C_MSG_FIELD.cpp_type = 9

STEALRESPONSE_S2C_RESULT_FIELD.name = "s2c_result"
STEALRESPONSE_S2C_RESULT_FIELD.full_name = ".pomelo.area.StealResponse.s2c_result"
STEALRESPONSE_S2C_RESULT_FIELD.number = 3
STEALRESPONSE_S2C_RESULT_FIELD.index = 2
STEALRESPONSE_S2C_RESULT_FIELD.label = 1
STEALRESPONSE_S2C_RESULT_FIELD.has_default_value = false
STEALRESPONSE_S2C_RESULT_FIELD.default_value = 0
STEALRESPONSE_S2C_RESULT_FIELD.type = 5
STEALRESPONSE_S2C_RESULT_FIELD.cpp_type = 1

STEALRESPONSE_S2C_ITEMS_FIELD.name = "s2c_items"
STEALRESPONSE_S2C_ITEMS_FIELD.full_name = ".pomelo.area.StealResponse.s2c_items"
STEALRESPONSE_S2C_ITEMS_FIELD.number = 4
STEALRESPONSE_S2C_ITEMS_FIELD.index = 3
STEALRESPONSE_S2C_ITEMS_FIELD.label = 3
STEALRESPONSE_S2C_ITEMS_FIELD.has_default_value = false
STEALRESPONSE_S2C_ITEMS_FIELD.default_value = {}
STEALRESPONSE_S2C_ITEMS_FIELD.message_type = item_pb.MINIITEM
STEALRESPONSE_S2C_ITEMS_FIELD.type = 11
STEALRESPONSE_S2C_ITEMS_FIELD.cpp_type = 10

STEALRESPONSE.name = "StealResponse"
STEALRESPONSE.full_name = ".pomelo.area.StealResponse"
STEALRESPONSE.nested_types = {}
STEALRESPONSE.enum_types = {}
STEALRESPONSE.fields = {STEALRESPONSE_S2C_CODE_FIELD, STEALRESPONSE_S2C_MSG_FIELD, STEALRESPONSE_S2C_RESULT_FIELD, STEALRESPONSE_S2C_ITEMS_FIELD}
STEALRESPONSE.is_extendable = false
STEALRESPONSE.extensions = {}
STEALREQUEST_C2S_ID_FIELD.name = "c2s_id"
STEALREQUEST_C2S_ID_FIELD.full_name = ".pomelo.area.StealRequest.c2s_id"
STEALREQUEST_C2S_ID_FIELD.number = 1
STEALREQUEST_C2S_ID_FIELD.index = 0
STEALREQUEST_C2S_ID_FIELD.label = 2
STEALREQUEST_C2S_ID_FIELD.has_default_value = false
STEALREQUEST_C2S_ID_FIELD.default_value = 0
STEALREQUEST_C2S_ID_FIELD.type = 5
STEALREQUEST_C2S_ID_FIELD.cpp_type = 1

STEALREQUEST.name = "StealRequest"
STEALREQUEST.full_name = ".pomelo.area.StealRequest"
STEALREQUEST.nested_types = {}
STEALREQUEST.enum_types = {}
STEALREQUEST.fields = {STEALREQUEST_C2S_ID_FIELD}
STEALREQUEST.is_extendable = false
STEALREQUEST.extensions = {}

StealRequest = protobuf.Message(STEALREQUEST)
StealResponse = protobuf.Message(STEALRESPONSE)
