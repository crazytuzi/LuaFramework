-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "tolua.protobuf/protobuf"
module('pb_1128_achieve_pb')


M_ACHIEVE_INFO_TOS = protobuf.Descriptor();
M_ACHIEVE_INFO_TOC = protobuf.Descriptor();
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD = protobuf.FieldDescriptor();
M_ACHIEVE_REWARD_TOS = protobuf.Descriptor();
M_ACHIEVE_REWARD_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_ACHIEVE_REWARD_TOC = protobuf.Descriptor();
M_ACHIEVE_REWARD_TOC_ID_FIELD = protobuf.FieldDescriptor();
P_ACHIEVE = protobuf.Descriptor();
P_ACHIEVE_ID_FIELD = protobuf.FieldDescriptor();
P_ACHIEVE_NUM_FIELD = protobuf.FieldDescriptor();
P_ACHIEVE_STATE_FIELD = protobuf.FieldDescriptor();

M_ACHIEVE_INFO_TOS.name = "m_achieve_info_tos"
M_ACHIEVE_INFO_TOS.full_name = ".m_achieve_info_tos"
M_ACHIEVE_INFO_TOS.nested_types = {}
M_ACHIEVE_INFO_TOS.enum_types = {}
M_ACHIEVE_INFO_TOS.fields = {}
M_ACHIEVE_INFO_TOS.is_extendable = false
M_ACHIEVE_INFO_TOS.extensions = {}
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.name = "achieves"
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.full_name = ".m_achieve_info_toc.achieves"
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.number = 1
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.index = 0
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.label = 3
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.has_default_value = false
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.default_value = {}
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.message_type = P_ACHIEVE
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.type = 11
M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD.cpp_type = 10

M_ACHIEVE_INFO_TOC.name = "m_achieve_info_toc"
M_ACHIEVE_INFO_TOC.full_name = ".m_achieve_info_toc"
M_ACHIEVE_INFO_TOC.nested_types = {}
M_ACHIEVE_INFO_TOC.enum_types = {}
M_ACHIEVE_INFO_TOC.fields = {M_ACHIEVE_INFO_TOC_ACHIEVES_FIELD}
M_ACHIEVE_INFO_TOC.is_extendable = false
M_ACHIEVE_INFO_TOC.extensions = {}
M_ACHIEVE_REWARD_TOS_ID_FIELD.name = "id"
M_ACHIEVE_REWARD_TOS_ID_FIELD.full_name = ".m_achieve_reward_tos.id"
M_ACHIEVE_REWARD_TOS_ID_FIELD.number = 1
M_ACHIEVE_REWARD_TOS_ID_FIELD.index = 0
M_ACHIEVE_REWARD_TOS_ID_FIELD.label = 2
M_ACHIEVE_REWARD_TOS_ID_FIELD.has_default_value = false
M_ACHIEVE_REWARD_TOS_ID_FIELD.default_value = 0
M_ACHIEVE_REWARD_TOS_ID_FIELD.type = 5
M_ACHIEVE_REWARD_TOS_ID_FIELD.cpp_type = 1

M_ACHIEVE_REWARD_TOS.name = "m_achieve_reward_tos"
M_ACHIEVE_REWARD_TOS.full_name = ".m_achieve_reward_tos"
M_ACHIEVE_REWARD_TOS.nested_types = {}
M_ACHIEVE_REWARD_TOS.enum_types = {}
M_ACHIEVE_REWARD_TOS.fields = {M_ACHIEVE_REWARD_TOS_ID_FIELD}
M_ACHIEVE_REWARD_TOS.is_extendable = false
M_ACHIEVE_REWARD_TOS.extensions = {}
M_ACHIEVE_REWARD_TOC_ID_FIELD.name = "id"
M_ACHIEVE_REWARD_TOC_ID_FIELD.full_name = ".m_achieve_reward_toc.id"
M_ACHIEVE_REWARD_TOC_ID_FIELD.number = 1
M_ACHIEVE_REWARD_TOC_ID_FIELD.index = 0
M_ACHIEVE_REWARD_TOC_ID_FIELD.label = 2
M_ACHIEVE_REWARD_TOC_ID_FIELD.has_default_value = false
M_ACHIEVE_REWARD_TOC_ID_FIELD.default_value = 0
M_ACHIEVE_REWARD_TOC_ID_FIELD.type = 5
M_ACHIEVE_REWARD_TOC_ID_FIELD.cpp_type = 1

M_ACHIEVE_REWARD_TOC.name = "m_achieve_reward_toc"
M_ACHIEVE_REWARD_TOC.full_name = ".m_achieve_reward_toc"
M_ACHIEVE_REWARD_TOC.nested_types = {}
M_ACHIEVE_REWARD_TOC.enum_types = {}
M_ACHIEVE_REWARD_TOC.fields = {M_ACHIEVE_REWARD_TOC_ID_FIELD}
M_ACHIEVE_REWARD_TOC.is_extendable = false
M_ACHIEVE_REWARD_TOC.extensions = {}
P_ACHIEVE_ID_FIELD.name = "id"
P_ACHIEVE_ID_FIELD.full_name = ".p_achieve.id"
P_ACHIEVE_ID_FIELD.number = 1
P_ACHIEVE_ID_FIELD.index = 0
P_ACHIEVE_ID_FIELD.label = 2
P_ACHIEVE_ID_FIELD.has_default_value = false
P_ACHIEVE_ID_FIELD.default_value = 0
P_ACHIEVE_ID_FIELD.type = 5
P_ACHIEVE_ID_FIELD.cpp_type = 1

P_ACHIEVE_NUM_FIELD.name = "num"
P_ACHIEVE_NUM_FIELD.full_name = ".p_achieve.num"
P_ACHIEVE_NUM_FIELD.number = 2
P_ACHIEVE_NUM_FIELD.index = 1
P_ACHIEVE_NUM_FIELD.label = 2
P_ACHIEVE_NUM_FIELD.has_default_value = false
P_ACHIEVE_NUM_FIELD.default_value = 0
P_ACHIEVE_NUM_FIELD.type = 5
P_ACHIEVE_NUM_FIELD.cpp_type = 1

P_ACHIEVE_STATE_FIELD.name = "state"
P_ACHIEVE_STATE_FIELD.full_name = ".p_achieve.state"
P_ACHIEVE_STATE_FIELD.number = 3
P_ACHIEVE_STATE_FIELD.index = 2
P_ACHIEVE_STATE_FIELD.label = 2
P_ACHIEVE_STATE_FIELD.has_default_value = false
P_ACHIEVE_STATE_FIELD.default_value = 0
P_ACHIEVE_STATE_FIELD.type = 5
P_ACHIEVE_STATE_FIELD.cpp_type = 1

P_ACHIEVE.name = "p_achieve"
P_ACHIEVE.full_name = ".p_achieve"
P_ACHIEVE.nested_types = {}
P_ACHIEVE.enum_types = {}
P_ACHIEVE.fields = {P_ACHIEVE_ID_FIELD, P_ACHIEVE_NUM_FIELD, P_ACHIEVE_STATE_FIELD}
P_ACHIEVE.is_extendable = false
P_ACHIEVE.extensions = {}

m_achieve_info_toc = protobuf.Message(M_ACHIEVE_INFO_TOC)
m_achieve_info_tos = protobuf.Message(M_ACHIEVE_INFO_TOS)
m_achieve_reward_toc = protobuf.Message(M_ACHIEVE_REWARD_TOC)
m_achieve_reward_tos = protobuf.Message(M_ACHIEVE_REWARD_TOS)
p_achieve = protobuf.Message(P_ACHIEVE)

