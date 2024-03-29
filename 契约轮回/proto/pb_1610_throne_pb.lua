-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "tolua.protobuf/protobuf"
module('pb_1610_throne_pb')


M_THRONE_PANEL_TOS = protobuf.Descriptor();
M_THRONE_PANEL_TOC = protobuf.Descriptor();
M_THRONE_PANEL_TOC_ROLESENTRY = protobuf.Descriptor();
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD = protobuf.FieldDescriptor();
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD = protobuf.FieldDescriptor();
M_THRONE_PANEL_TOC_ROLES_FIELD = protobuf.FieldDescriptor();
M_THRONE_PANEL_TOC_UNLOCK_FIELD = protobuf.FieldDescriptor();
M_THRONE_BOSS_TOS = protobuf.Descriptor();
M_THRONE_BOSS_TOC = protobuf.Descriptor();
M_THRONE_BOSS_TOC_BOSSES_FIELD = protobuf.FieldDescriptor();
M_THRONE_BOSS_UPDATE_TOC = protobuf.Descriptor();
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD = protobuf.FieldDescriptor();
M_THRONE_DAMAGE_TOS = protobuf.Descriptor();
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD = protobuf.FieldDescriptor();
M_THRONE_DAMAGE_TOC = protobuf.Descriptor();
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD = protobuf.FieldDescriptor();
M_THRONE_DAMAGE_TOC_RANKING_FIELD = protobuf.FieldDescriptor();
M_THRONE_SCORE_TOS = protobuf.Descriptor();
M_THRONE_SCORE_TOC = protobuf.Descriptor();
M_THRONE_SCORE_TOC_RANKING_FIELD = protobuf.FieldDescriptor();
M_THRONE_IS_UNLOCK_TOS = protobuf.Descriptor();
M_THRONE_IS_UNLOCK_TOC = protobuf.Descriptor();
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD = protobuf.FieldDescriptor();
P_THRONE_BOSS = protobuf.Descriptor();
P_THRONE_BOSS_ID_FIELD = protobuf.FieldDescriptor();
P_THRONE_BOSS_BORN_FIELD = protobuf.FieldDescriptor();
P_THRONE_BOSS_LEVEL_FIELD = protobuf.FieldDescriptor();
P_THRONE_DAMAGE = protobuf.Descriptor();
P_THRONE_DAMAGE_ID_FIELD = protobuf.FieldDescriptor();
P_THRONE_DAMAGE_DAMAGE_FIELD = protobuf.FieldDescriptor();
P_THRONE_DAMAGE_RANK_FIELD = protobuf.FieldDescriptor();
P_THRONE_SCORE = protobuf.Descriptor();
P_THRONE_SCORE_ID_FIELD = protobuf.FieldDescriptor();
P_THRONE_SCORE_SCORE_FIELD = protobuf.FieldDescriptor();
P_THRONE_SCORE_RANK_FIELD = protobuf.FieldDescriptor();

M_THRONE_PANEL_TOS.name = "m_throne_panel_tos"
M_THRONE_PANEL_TOS.full_name = ".m_throne_panel_tos"
M_THRONE_PANEL_TOS.nested_types = {}
M_THRONE_PANEL_TOS.enum_types = {}
M_THRONE_PANEL_TOS.fields = {}
M_THRONE_PANEL_TOS.is_extendable = false
M_THRONE_PANEL_TOS.extensions = {}
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.name = "key"
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.full_name = ".m_throne_panel_toc.RolesEntry.key"
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.number = 1
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.index = 0
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.label = 1
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.has_default_value = false
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.default_value = 0
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.type = 5
M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD.cpp_type = 1

M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.name = "value"
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.full_name = ".m_throne_panel_toc.RolesEntry.value"
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.number = 2
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.index = 1
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.label = 1
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.has_default_value = false
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.default_value = 0
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.type = 5
M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD.cpp_type = 1

M_THRONE_PANEL_TOC_ROLESENTRY.name = "RolesEntry"
M_THRONE_PANEL_TOC_ROLESENTRY.full_name = ".m_throne_panel_toc.RolesEntry"
M_THRONE_PANEL_TOC_ROLESENTRY.nested_types = {}
M_THRONE_PANEL_TOC_ROLESENTRY.enum_types = {}
M_THRONE_PANEL_TOC_ROLESENTRY.fields = {M_THRONE_PANEL_TOC_ROLESENTRY_KEY_FIELD, M_THRONE_PANEL_TOC_ROLESENTRY_VALUE_FIELD}
M_THRONE_PANEL_TOC_ROLESENTRY.is_extendable = false
M_THRONE_PANEL_TOC_ROLESENTRY.extensions = {}
M_THRONE_PANEL_TOC_ROLESENTRY.containing_type = M_THRONE_PANEL_TOC
M_THRONE_PANEL_TOC_ROLES_FIELD.name = "roles"
M_THRONE_PANEL_TOC_ROLES_FIELD.full_name = ".m_throne_panel_toc.roles"
M_THRONE_PANEL_TOC_ROLES_FIELD.number = 1
M_THRONE_PANEL_TOC_ROLES_FIELD.index = 0
M_THRONE_PANEL_TOC_ROLES_FIELD.label = 3
M_THRONE_PANEL_TOC_ROLES_FIELD.has_default_value = false
M_THRONE_PANEL_TOC_ROLES_FIELD.default_value = {}
M_THRONE_PANEL_TOC_ROLES_FIELD.message_type = M_THRONE_PANEL_TOC_ROLESENTRY
M_THRONE_PANEL_TOC_ROLES_FIELD.type = 11
M_THRONE_PANEL_TOC_ROLES_FIELD.cpp_type = 10

M_THRONE_PANEL_TOC_UNLOCK_FIELD.name = "unlock"
M_THRONE_PANEL_TOC_UNLOCK_FIELD.full_name = ".m_throne_panel_toc.unlock"
M_THRONE_PANEL_TOC_UNLOCK_FIELD.number = 2
M_THRONE_PANEL_TOC_UNLOCK_FIELD.index = 1
M_THRONE_PANEL_TOC_UNLOCK_FIELD.label = 2
M_THRONE_PANEL_TOC_UNLOCK_FIELD.has_default_value = false
M_THRONE_PANEL_TOC_UNLOCK_FIELD.default_value = false
M_THRONE_PANEL_TOC_UNLOCK_FIELD.type = 8
M_THRONE_PANEL_TOC_UNLOCK_FIELD.cpp_type = 7

M_THRONE_PANEL_TOC.name = "m_throne_panel_toc"
M_THRONE_PANEL_TOC.full_name = ".m_throne_panel_toc"
M_THRONE_PANEL_TOC.nested_types = {M_THRONE_PANEL_TOC_ROLESENTRY}
M_THRONE_PANEL_TOC.enum_types = {}
M_THRONE_PANEL_TOC.fields = {M_THRONE_PANEL_TOC_ROLES_FIELD, M_THRONE_PANEL_TOC_UNLOCK_FIELD}
M_THRONE_PANEL_TOC.is_extendable = false
M_THRONE_PANEL_TOC.extensions = {}
M_THRONE_BOSS_TOS.name = "m_throne_boss_tos"
M_THRONE_BOSS_TOS.full_name = ".m_throne_boss_tos"
M_THRONE_BOSS_TOS.nested_types = {}
M_THRONE_BOSS_TOS.enum_types = {}
M_THRONE_BOSS_TOS.fields = {}
M_THRONE_BOSS_TOS.is_extendable = false
M_THRONE_BOSS_TOS.extensions = {}
M_THRONE_BOSS_TOC_BOSSES_FIELD.name = "bosses"
M_THRONE_BOSS_TOC_BOSSES_FIELD.full_name = ".m_throne_boss_toc.bosses"
M_THRONE_BOSS_TOC_BOSSES_FIELD.number = 1
M_THRONE_BOSS_TOC_BOSSES_FIELD.index = 0
M_THRONE_BOSS_TOC_BOSSES_FIELD.label = 3
M_THRONE_BOSS_TOC_BOSSES_FIELD.has_default_value = false
M_THRONE_BOSS_TOC_BOSSES_FIELD.default_value = {}
M_THRONE_BOSS_TOC_BOSSES_FIELD.message_type = P_THRONE_BOSS
M_THRONE_BOSS_TOC_BOSSES_FIELD.type = 11
M_THRONE_BOSS_TOC_BOSSES_FIELD.cpp_type = 10

M_THRONE_BOSS_TOC.name = "m_throne_boss_toc"
M_THRONE_BOSS_TOC.full_name = ".m_throne_boss_toc"
M_THRONE_BOSS_TOC.nested_types = {}
M_THRONE_BOSS_TOC.enum_types = {}
M_THRONE_BOSS_TOC.fields = {M_THRONE_BOSS_TOC_BOSSES_FIELD}
M_THRONE_BOSS_TOC.is_extendable = false
M_THRONE_BOSS_TOC.extensions = {}
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.name = "id"
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.full_name = ".m_throne_boss_update_toc.id"
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.number = 1
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.index = 0
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.label = 2
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.has_default_value = false
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.default_value = 0
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.type = 5
M_THRONE_BOSS_UPDATE_TOC_ID_FIELD.cpp_type = 1

M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.name = "born"
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.full_name = ".m_throne_boss_update_toc.born"
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.number = 2
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.index = 1
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.label = 2
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.has_default_value = false
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.default_value = 0
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.type = 5
M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD.cpp_type = 1

M_THRONE_BOSS_UPDATE_TOC.name = "m_throne_boss_update_toc"
M_THRONE_BOSS_UPDATE_TOC.full_name = ".m_throne_boss_update_toc"
M_THRONE_BOSS_UPDATE_TOC.nested_types = {}
M_THRONE_BOSS_UPDATE_TOC.enum_types = {}
M_THRONE_BOSS_UPDATE_TOC.fields = {M_THRONE_BOSS_UPDATE_TOC_ID_FIELD, M_THRONE_BOSS_UPDATE_TOC_BORN_FIELD}
M_THRONE_BOSS_UPDATE_TOC.is_extendable = false
M_THRONE_BOSS_UPDATE_TOC.extensions = {}
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.name = "boss_id"
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.full_name = ".m_throne_damage_tos.boss_id"
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.number = 1
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.index = 0
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.label = 2
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.has_default_value = false
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.default_value = 0
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.type = 5
M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD.cpp_type = 1

M_THRONE_DAMAGE_TOS.name = "m_throne_damage_tos"
M_THRONE_DAMAGE_TOS.full_name = ".m_throne_damage_tos"
M_THRONE_DAMAGE_TOS.nested_types = {}
M_THRONE_DAMAGE_TOS.enum_types = {}
M_THRONE_DAMAGE_TOS.fields = {M_THRONE_DAMAGE_TOS_BOSS_ID_FIELD}
M_THRONE_DAMAGE_TOS.is_extendable = false
M_THRONE_DAMAGE_TOS.extensions = {}
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.name = "boss_id"
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.full_name = ".m_throne_damage_toc.boss_id"
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.number = 1
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.index = 0
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.label = 2
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.has_default_value = false
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.default_value = 0
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.type = 5
M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD.cpp_type = 1

M_THRONE_DAMAGE_TOC_RANKING_FIELD.name = "ranking"
M_THRONE_DAMAGE_TOC_RANKING_FIELD.full_name = ".m_throne_damage_toc.ranking"
M_THRONE_DAMAGE_TOC_RANKING_FIELD.number = 2
M_THRONE_DAMAGE_TOC_RANKING_FIELD.index = 1
M_THRONE_DAMAGE_TOC_RANKING_FIELD.label = 3
M_THRONE_DAMAGE_TOC_RANKING_FIELD.has_default_value = false
M_THRONE_DAMAGE_TOC_RANKING_FIELD.default_value = {}
M_THRONE_DAMAGE_TOC_RANKING_FIELD.message_type = P_THRONE_DAMAGE
M_THRONE_DAMAGE_TOC_RANKING_FIELD.type = 11
M_THRONE_DAMAGE_TOC_RANKING_FIELD.cpp_type = 10

M_THRONE_DAMAGE_TOC.name = "m_throne_damage_toc"
M_THRONE_DAMAGE_TOC.full_name = ".m_throne_damage_toc"
M_THRONE_DAMAGE_TOC.nested_types = {}
M_THRONE_DAMAGE_TOC.enum_types = {}
M_THRONE_DAMAGE_TOC.fields = {M_THRONE_DAMAGE_TOC_BOSS_ID_FIELD, M_THRONE_DAMAGE_TOC_RANKING_FIELD}
M_THRONE_DAMAGE_TOC.is_extendable = false
M_THRONE_DAMAGE_TOC.extensions = {}
M_THRONE_SCORE_TOS.name = "m_throne_score_tos"
M_THRONE_SCORE_TOS.full_name = ".m_throne_score_tos"
M_THRONE_SCORE_TOS.nested_types = {}
M_THRONE_SCORE_TOS.enum_types = {}
M_THRONE_SCORE_TOS.fields = {}
M_THRONE_SCORE_TOS.is_extendable = false
M_THRONE_SCORE_TOS.extensions = {}
M_THRONE_SCORE_TOC_RANKING_FIELD.name = "ranking"
M_THRONE_SCORE_TOC_RANKING_FIELD.full_name = ".m_throne_score_toc.ranking"
M_THRONE_SCORE_TOC_RANKING_FIELD.number = 1
M_THRONE_SCORE_TOC_RANKING_FIELD.index = 0
M_THRONE_SCORE_TOC_RANKING_FIELD.label = 3
M_THRONE_SCORE_TOC_RANKING_FIELD.has_default_value = false
M_THRONE_SCORE_TOC_RANKING_FIELD.default_value = {}
M_THRONE_SCORE_TOC_RANKING_FIELD.message_type = P_THRONE_SCORE
M_THRONE_SCORE_TOC_RANKING_FIELD.type = 11
M_THRONE_SCORE_TOC_RANKING_FIELD.cpp_type = 10

M_THRONE_SCORE_TOC.name = "m_throne_score_toc"
M_THRONE_SCORE_TOC.full_name = ".m_throne_score_toc"
M_THRONE_SCORE_TOC.nested_types = {}
M_THRONE_SCORE_TOC.enum_types = {}
M_THRONE_SCORE_TOC.fields = {M_THRONE_SCORE_TOC_RANKING_FIELD}
M_THRONE_SCORE_TOC.is_extendable = false
M_THRONE_SCORE_TOC.extensions = {}
M_THRONE_IS_UNLOCK_TOS.name = "m_throne_is_unlock_tos"
M_THRONE_IS_UNLOCK_TOS.full_name = ".m_throne_is_unlock_tos"
M_THRONE_IS_UNLOCK_TOS.nested_types = {}
M_THRONE_IS_UNLOCK_TOS.enum_types = {}
M_THRONE_IS_UNLOCK_TOS.fields = {}
M_THRONE_IS_UNLOCK_TOS.is_extendable = false
M_THRONE_IS_UNLOCK_TOS.extensions = {}
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.name = "unlock"
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.full_name = ".m_throne_is_unlock_toc.unlock"
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.number = 1
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.index = 0
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.label = 2
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.has_default_value = false
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.default_value = false
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.type = 8
M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD.cpp_type = 7

M_THRONE_IS_UNLOCK_TOC.name = "m_throne_is_unlock_toc"
M_THRONE_IS_UNLOCK_TOC.full_name = ".m_throne_is_unlock_toc"
M_THRONE_IS_UNLOCK_TOC.nested_types = {}
M_THRONE_IS_UNLOCK_TOC.enum_types = {}
M_THRONE_IS_UNLOCK_TOC.fields = {M_THRONE_IS_UNLOCK_TOC_UNLOCK_FIELD}
M_THRONE_IS_UNLOCK_TOC.is_extendable = false
M_THRONE_IS_UNLOCK_TOC.extensions = {}
P_THRONE_BOSS_ID_FIELD.name = "id"
P_THRONE_BOSS_ID_FIELD.full_name = ".p_throne_boss.id"
P_THRONE_BOSS_ID_FIELD.number = 1
P_THRONE_BOSS_ID_FIELD.index = 0
P_THRONE_BOSS_ID_FIELD.label = 2
P_THRONE_BOSS_ID_FIELD.has_default_value = false
P_THRONE_BOSS_ID_FIELD.default_value = 0
P_THRONE_BOSS_ID_FIELD.type = 5
P_THRONE_BOSS_ID_FIELD.cpp_type = 1

P_THRONE_BOSS_BORN_FIELD.name = "born"
P_THRONE_BOSS_BORN_FIELD.full_name = ".p_throne_boss.born"
P_THRONE_BOSS_BORN_FIELD.number = 2
P_THRONE_BOSS_BORN_FIELD.index = 1
P_THRONE_BOSS_BORN_FIELD.label = 2
P_THRONE_BOSS_BORN_FIELD.has_default_value = false
P_THRONE_BOSS_BORN_FIELD.default_value = 0
P_THRONE_BOSS_BORN_FIELD.type = 5
P_THRONE_BOSS_BORN_FIELD.cpp_type = 1

P_THRONE_BOSS_LEVEL_FIELD.name = "level"
P_THRONE_BOSS_LEVEL_FIELD.full_name = ".p_throne_boss.level"
P_THRONE_BOSS_LEVEL_FIELD.number = 3
P_THRONE_BOSS_LEVEL_FIELD.index = 2
P_THRONE_BOSS_LEVEL_FIELD.label = 2
P_THRONE_BOSS_LEVEL_FIELD.has_default_value = false
P_THRONE_BOSS_LEVEL_FIELD.default_value = 0
P_THRONE_BOSS_LEVEL_FIELD.type = 5
P_THRONE_BOSS_LEVEL_FIELD.cpp_type = 1

P_THRONE_BOSS.name = "p_throne_boss"
P_THRONE_BOSS.full_name = ".p_throne_boss"
P_THRONE_BOSS.nested_types = {}
P_THRONE_BOSS.enum_types = {}
P_THRONE_BOSS.fields = {P_THRONE_BOSS_ID_FIELD, P_THRONE_BOSS_BORN_FIELD, P_THRONE_BOSS_LEVEL_FIELD}
P_THRONE_BOSS.is_extendable = false
P_THRONE_BOSS.extensions = {}
P_THRONE_DAMAGE_ID_FIELD.name = "id"
P_THRONE_DAMAGE_ID_FIELD.full_name = ".p_throne_damage.id"
P_THRONE_DAMAGE_ID_FIELD.number = 1
P_THRONE_DAMAGE_ID_FIELD.index = 0
P_THRONE_DAMAGE_ID_FIELD.label = 2
P_THRONE_DAMAGE_ID_FIELD.has_default_value = false
P_THRONE_DAMAGE_ID_FIELD.default_value = 0
P_THRONE_DAMAGE_ID_FIELD.type = 5
P_THRONE_DAMAGE_ID_FIELD.cpp_type = 1

P_THRONE_DAMAGE_DAMAGE_FIELD.name = "damage"
P_THRONE_DAMAGE_DAMAGE_FIELD.full_name = ".p_throne_damage.damage"
P_THRONE_DAMAGE_DAMAGE_FIELD.number = 2
P_THRONE_DAMAGE_DAMAGE_FIELD.index = 1
P_THRONE_DAMAGE_DAMAGE_FIELD.label = 2
P_THRONE_DAMAGE_DAMAGE_FIELD.has_default_value = false
P_THRONE_DAMAGE_DAMAGE_FIELD.default_value = 0
P_THRONE_DAMAGE_DAMAGE_FIELD.type = 5
P_THRONE_DAMAGE_DAMAGE_FIELD.cpp_type = 1

P_THRONE_DAMAGE_RANK_FIELD.name = "rank"
P_THRONE_DAMAGE_RANK_FIELD.full_name = ".p_throne_damage.rank"
P_THRONE_DAMAGE_RANK_FIELD.number = 3
P_THRONE_DAMAGE_RANK_FIELD.index = 2
P_THRONE_DAMAGE_RANK_FIELD.label = 2
P_THRONE_DAMAGE_RANK_FIELD.has_default_value = false
P_THRONE_DAMAGE_RANK_FIELD.default_value = 0
P_THRONE_DAMAGE_RANK_FIELD.type = 5
P_THRONE_DAMAGE_RANK_FIELD.cpp_type = 1

P_THRONE_DAMAGE.name = "p_throne_damage"
P_THRONE_DAMAGE.full_name = ".p_throne_damage"
P_THRONE_DAMAGE.nested_types = {}
P_THRONE_DAMAGE.enum_types = {}
P_THRONE_DAMAGE.fields = {P_THRONE_DAMAGE_ID_FIELD, P_THRONE_DAMAGE_DAMAGE_FIELD, P_THRONE_DAMAGE_RANK_FIELD}
P_THRONE_DAMAGE.is_extendable = false
P_THRONE_DAMAGE.extensions = {}
P_THRONE_SCORE_ID_FIELD.name = "id"
P_THRONE_SCORE_ID_FIELD.full_name = ".p_throne_score.id"
P_THRONE_SCORE_ID_FIELD.number = 1
P_THRONE_SCORE_ID_FIELD.index = 0
P_THRONE_SCORE_ID_FIELD.label = 2
P_THRONE_SCORE_ID_FIELD.has_default_value = false
P_THRONE_SCORE_ID_FIELD.default_value = 0
P_THRONE_SCORE_ID_FIELD.type = 5
P_THRONE_SCORE_ID_FIELD.cpp_type = 1

P_THRONE_SCORE_SCORE_FIELD.name = "score"
P_THRONE_SCORE_SCORE_FIELD.full_name = ".p_throne_score.score"
P_THRONE_SCORE_SCORE_FIELD.number = 2
P_THRONE_SCORE_SCORE_FIELD.index = 1
P_THRONE_SCORE_SCORE_FIELD.label = 2
P_THRONE_SCORE_SCORE_FIELD.has_default_value = false
P_THRONE_SCORE_SCORE_FIELD.default_value = 0
P_THRONE_SCORE_SCORE_FIELD.type = 5
P_THRONE_SCORE_SCORE_FIELD.cpp_type = 1

P_THRONE_SCORE_RANK_FIELD.name = "rank"
P_THRONE_SCORE_RANK_FIELD.full_name = ".p_throne_score.rank"
P_THRONE_SCORE_RANK_FIELD.number = 3
P_THRONE_SCORE_RANK_FIELD.index = 2
P_THRONE_SCORE_RANK_FIELD.label = 2
P_THRONE_SCORE_RANK_FIELD.has_default_value = false
P_THRONE_SCORE_RANK_FIELD.default_value = 0
P_THRONE_SCORE_RANK_FIELD.type = 5
P_THRONE_SCORE_RANK_FIELD.cpp_type = 1

P_THRONE_SCORE.name = "p_throne_score"
P_THRONE_SCORE.full_name = ".p_throne_score"
P_THRONE_SCORE.nested_types = {}
P_THRONE_SCORE.enum_types = {}
P_THRONE_SCORE.fields = {P_THRONE_SCORE_ID_FIELD, P_THRONE_SCORE_SCORE_FIELD, P_THRONE_SCORE_RANK_FIELD}
P_THRONE_SCORE.is_extendable = false
P_THRONE_SCORE.extensions = {}

m_throne_boss_toc = protobuf.Message(M_THRONE_BOSS_TOC)
m_throne_boss_tos = protobuf.Message(M_THRONE_BOSS_TOS)
m_throne_boss_update_toc = protobuf.Message(M_THRONE_BOSS_UPDATE_TOC)
m_throne_damage_toc = protobuf.Message(M_THRONE_DAMAGE_TOC)
m_throne_damage_tos = protobuf.Message(M_THRONE_DAMAGE_TOS)
m_throne_is_unlock_toc = protobuf.Message(M_THRONE_IS_UNLOCK_TOC)
m_throne_is_unlock_tos = protobuf.Message(M_THRONE_IS_UNLOCK_TOS)
m_throne_panel_toc = protobuf.Message(M_THRONE_PANEL_TOC)
m_throne_panel_toc.RolesEntry = protobuf.Message(M_THRONE_PANEL_TOC_ROLESENTRY)
m_throne_panel_tos = protobuf.Message(M_THRONE_PANEL_TOS)
m_throne_score_toc = protobuf.Message(M_THRONE_SCORE_TOC)
m_throne_score_tos = protobuf.Message(M_THRONE_SCORE_TOS)
p_throne_boss = protobuf.Message(P_THRONE_BOSS)
p_throne_damage = protobuf.Message(P_THRONE_DAMAGE)
p_throne_score = protobuf.Message(P_THRONE_SCORE)

