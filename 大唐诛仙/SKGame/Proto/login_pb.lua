-- Generated By protoc-gen-lua Do not Edit

local _pb = {}


local protobuf = require "protobuf/protobuf"
local PLAYER_PB = require("player_pb")
local BAG_PB = require("bag_pb")
local SKILL_PB = require("skill_pb")
local TASK_PB = require("task_pb")
local EQUIPMENT_PB = require("equipment_pb")
local SIGN_PB = require("sign_pb")
local FURNACE_PB = require("furnace_pb")
module('login_pb')


C_LOGINGAME = protobuf.Descriptor();
_pb.C_LOGINGAME_USERID_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINGAME_KEY_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINGAME_TIME_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINGAME_SIGN_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINGAME_SERVERNO_FIELD = protobuf.FieldDescriptor();
S_LOGINGAME = protobuf.Descriptor();
_pb.S_LOGINGAME_PLAYERMSGS_FIELD = protobuf.FieldDescriptor();
C_CREATEPLAYER = protobuf.Descriptor();
_pb.C_CREATEPLAYER_SERVERNO_FIELD = protobuf.FieldDescriptor();
_pb.C_CREATEPLAYER_CAREER_FIELD = protobuf.FieldDescriptor();
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD = protobuf.FieldDescriptor();
_pb.C_CREATEPLAYER_TELEPHONE_FIELD = protobuf.FieldDescriptor();
S_CREATEPLAYER = protobuf.Descriptor();
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD = protobuf.FieldDescriptor();
C_DELETEPLAYER = protobuf.Descriptor();
_pb.C_DELETEPLAYER_PLAYERID_FIELD = protobuf.FieldDescriptor();
S_DELETEPLAYER = protobuf.Descriptor();
_pb.S_DELETEPLAYER_PLAYERID_FIELD = protobuf.FieldDescriptor();
C_ENTERGAME = protobuf.Descriptor();
_pb.C_ENTERGAME_PLAYERID_FIELD = protobuf.FieldDescriptor();
_pb.C_ENTERGAME_TELEPHONE_FIELD = protobuf.FieldDescriptor();
LOGINMSG = protobuf.Descriptor();
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD = protobuf.FieldDescriptor();
_pb.LOGINMSG_MAPID_FIELD = protobuf.FieldDescriptor();
_pb.LOGINMSG_SERVERTIME_FIELD = protobuf.FieldDescriptor();
S_ENTERGAME = protobuf.Descriptor();
_pb.S_ENTERGAME_LOGINMSG_FIELD = protobuf.FieldDescriptor();
S_EXITGAME = protobuf.Descriptor();
S_STOPSERVER = protobuf.Descriptor();
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD = protobuf.FieldDescriptor();
C_ENTERCOMPLETE = protobuf.Descriptor();
C_LOGINAGAIN = protobuf.Descriptor();
_pb.C_LOGINAGAIN_USERID_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINAGAIN_KEY_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINAGAIN_TIME_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINAGAIN_SIGN_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINAGAIN_PLAYERID_FIELD = protobuf.FieldDescriptor();
_pb.C_LOGINAGAIN_SERVERNO_FIELD = protobuf.FieldDescriptor();
S_ENTERCOMPLETE = protobuf.Descriptor();
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD = protobuf.FieldDescriptor();
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD = protobuf.FieldDescriptor();

_pb.C_LOGINGAME_USERID_FIELD.name = "userId"
_pb.C_LOGINGAME_USERID_FIELD.full_name = ".C_LoginGame.userId"
_pb.C_LOGINGAME_USERID_FIELD.number = 1
_pb.C_LOGINGAME_USERID_FIELD.index = 0
_pb.C_LOGINGAME_USERID_FIELD.label = 2
_pb.C_LOGINGAME_USERID_FIELD.has_default_value = false
_pb.C_LOGINGAME_USERID_FIELD.default_value = 0
_pb.C_LOGINGAME_USERID_FIELD.type = 3
_pb.C_LOGINGAME_USERID_FIELD.cpp_type = 2

_pb.C_LOGINGAME_KEY_FIELD.name = "key"
_pb.C_LOGINGAME_KEY_FIELD.full_name = ".C_LoginGame.key"
_pb.C_LOGINGAME_KEY_FIELD.number = 3
_pb.C_LOGINGAME_KEY_FIELD.index = 1
_pb.C_LOGINGAME_KEY_FIELD.label = 2
_pb.C_LOGINGAME_KEY_FIELD.has_default_value = false
_pb.C_LOGINGAME_KEY_FIELD.default_value = ""
_pb.C_LOGINGAME_KEY_FIELD.type = 9
_pb.C_LOGINGAME_KEY_FIELD.cpp_type = 9

_pb.C_LOGINGAME_TIME_FIELD.name = "time"
_pb.C_LOGINGAME_TIME_FIELD.full_name = ".C_LoginGame.time"
_pb.C_LOGINGAME_TIME_FIELD.number = 4
_pb.C_LOGINGAME_TIME_FIELD.index = 2
_pb.C_LOGINGAME_TIME_FIELD.label = 1
_pb.C_LOGINGAME_TIME_FIELD.has_default_value = false
_pb.C_LOGINGAME_TIME_FIELD.default_value = ""
_pb.C_LOGINGAME_TIME_FIELD.type = 9
_pb.C_LOGINGAME_TIME_FIELD.cpp_type = 9

_pb.C_LOGINGAME_SIGN_FIELD.name = "sign"
_pb.C_LOGINGAME_SIGN_FIELD.full_name = ".C_LoginGame.sign"
_pb.C_LOGINGAME_SIGN_FIELD.number = 5
_pb.C_LOGINGAME_SIGN_FIELD.index = 3
_pb.C_LOGINGAME_SIGN_FIELD.label = 1
_pb.C_LOGINGAME_SIGN_FIELD.has_default_value = false
_pb.C_LOGINGAME_SIGN_FIELD.default_value = ""
_pb.C_LOGINGAME_SIGN_FIELD.type = 9
_pb.C_LOGINGAME_SIGN_FIELD.cpp_type = 9

_pb.C_LOGINGAME_SERVERNO_FIELD.name = "serverNo"
_pb.C_LOGINGAME_SERVERNO_FIELD.full_name = ".C_LoginGame.serverNo"
_pb.C_LOGINGAME_SERVERNO_FIELD.number = 6
_pb.C_LOGINGAME_SERVERNO_FIELD.index = 4
_pb.C_LOGINGAME_SERVERNO_FIELD.label = 1
_pb.C_LOGINGAME_SERVERNO_FIELD.has_default_value = false
_pb.C_LOGINGAME_SERVERNO_FIELD.default_value = 0
_pb.C_LOGINGAME_SERVERNO_FIELD.type = 5
_pb.C_LOGINGAME_SERVERNO_FIELD.cpp_type = 1

C_LOGINGAME.name = "C_LoginGame"
C_LOGINGAME.full_name = ".C_LoginGame"
C_LOGINGAME.nested_types = {}
C_LOGINGAME.enum_types = {}
C_LOGINGAME.fields = {_pb.C_LOGINGAME_USERID_FIELD, _pb.C_LOGINGAME_KEY_FIELD, _pb.C_LOGINGAME_TIME_FIELD, _pb.C_LOGINGAME_SIGN_FIELD, _pb.C_LOGINGAME_SERVERNO_FIELD}
C_LOGINGAME.is_extendable = false
C_LOGINGAME.extensions = {}
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.name = "playerMsgs"
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.full_name = ".S_LoginGame.playerMsgs"
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.number = 1
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.index = 0
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.label = 3
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.has_default_value = false
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.default_value = {}
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.message_type = PLAYER_PB.PLAYERMSG
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.type = 11
_pb.S_LOGINGAME_PLAYERMSGS_FIELD.cpp_type = 10

S_LOGINGAME.name = "S_LoginGame"
S_LOGINGAME.full_name = ".S_LoginGame"
S_LOGINGAME.nested_types = {}
S_LOGINGAME.enum_types = {}
S_LOGINGAME.fields = {_pb.S_LOGINGAME_PLAYERMSGS_FIELD}
S_LOGINGAME.is_extendable = false
S_LOGINGAME.extensions = {}
_pb.C_CREATEPLAYER_SERVERNO_FIELD.name = "serverNo"
_pb.C_CREATEPLAYER_SERVERNO_FIELD.full_name = ".C_CreatePlayer.serverNo"
_pb.C_CREATEPLAYER_SERVERNO_FIELD.number = 1
_pb.C_CREATEPLAYER_SERVERNO_FIELD.index = 0
_pb.C_CREATEPLAYER_SERVERNO_FIELD.label = 1
_pb.C_CREATEPLAYER_SERVERNO_FIELD.has_default_value = false
_pb.C_CREATEPLAYER_SERVERNO_FIELD.default_value = 0
_pb.C_CREATEPLAYER_SERVERNO_FIELD.type = 5
_pb.C_CREATEPLAYER_SERVERNO_FIELD.cpp_type = 1

_pb.C_CREATEPLAYER_CAREER_FIELD.name = "career"
_pb.C_CREATEPLAYER_CAREER_FIELD.full_name = ".C_CreatePlayer.career"
_pb.C_CREATEPLAYER_CAREER_FIELD.number = 2
_pb.C_CREATEPLAYER_CAREER_FIELD.index = 1
_pb.C_CREATEPLAYER_CAREER_FIELD.label = 1
_pb.C_CREATEPLAYER_CAREER_FIELD.has_default_value = false
_pb.C_CREATEPLAYER_CAREER_FIELD.default_value = 0
_pb.C_CREATEPLAYER_CAREER_FIELD.type = 5
_pb.C_CREATEPLAYER_CAREER_FIELD.cpp_type = 1

_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.name = "playerName"
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.full_name = ".C_CreatePlayer.playerName"
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.number = 3
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.index = 2
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.label = 2
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.has_default_value = false
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.default_value = ""
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.type = 9
_pb.C_CREATEPLAYER_PLAYERNAME_FIELD.cpp_type = 9

_pb.C_CREATEPLAYER_TELEPHONE_FIELD.name = "telePhone"
_pb.C_CREATEPLAYER_TELEPHONE_FIELD.full_name = ".C_CreatePlayer.telePhone"
_pb.C_CREATEPLAYER_TELEPHONE_FIELD.number = 4
_pb.C_CREATEPLAYER_TELEPHONE_FIELD.index = 3
_pb.C_CREATEPLAYER_TELEPHONE_FIELD.label = 1
_pb.C_CREATEPLAYER_TELEPHONE_FIELD.has_default_value = false
_pb.C_CREATEPLAYER_TELEPHONE_FIELD.default_value = 0
_pb.C_CREATEPLAYER_TELEPHONE_FIELD.type = 3
_pb.C_CREATEPLAYER_TELEPHONE_FIELD.cpp_type = 2

C_CREATEPLAYER.name = "C_CreatePlayer"
C_CREATEPLAYER.full_name = ".C_CreatePlayer"
C_CREATEPLAYER.nested_types = {}
C_CREATEPLAYER.enum_types = {}
C_CREATEPLAYER.fields = {_pb.C_CREATEPLAYER_SERVERNO_FIELD, _pb.C_CREATEPLAYER_CAREER_FIELD, _pb.C_CREATEPLAYER_PLAYERNAME_FIELD, _pb.C_CREATEPLAYER_TELEPHONE_FIELD}
C_CREATEPLAYER.is_extendable = false
C_CREATEPLAYER.extensions = {}
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.name = "playerMsg"
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.full_name = ".S_CreatePlayer.playerMsg"
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.number = 1
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.index = 0
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.label = 1
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.has_default_value = false
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.default_value = nil
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.message_type = PLAYER_PB.PLAYERMSG
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.type = 11
_pb.S_CREATEPLAYER_PLAYERMSG_FIELD.cpp_type = 10

S_CREATEPLAYER.name = "S_CreatePlayer"
S_CREATEPLAYER.full_name = ".S_CreatePlayer"
S_CREATEPLAYER.nested_types = {}
S_CREATEPLAYER.enum_types = {}
S_CREATEPLAYER.fields = {_pb.S_CREATEPLAYER_PLAYERMSG_FIELD}
S_CREATEPLAYER.is_extendable = false
S_CREATEPLAYER.extensions = {}
_pb.C_DELETEPLAYER_PLAYERID_FIELD.name = "playerId"
_pb.C_DELETEPLAYER_PLAYERID_FIELD.full_name = ".C_DeletePlayer.playerId"
_pb.C_DELETEPLAYER_PLAYERID_FIELD.number = 1
_pb.C_DELETEPLAYER_PLAYERID_FIELD.index = 0
_pb.C_DELETEPLAYER_PLAYERID_FIELD.label = 2
_pb.C_DELETEPLAYER_PLAYERID_FIELD.has_default_value = false
_pb.C_DELETEPLAYER_PLAYERID_FIELD.default_value = 0
_pb.C_DELETEPLAYER_PLAYERID_FIELD.type = 3
_pb.C_DELETEPLAYER_PLAYERID_FIELD.cpp_type = 2

C_DELETEPLAYER.name = "C_DeletePlayer"
C_DELETEPLAYER.full_name = ".C_DeletePlayer"
C_DELETEPLAYER.nested_types = {}
C_DELETEPLAYER.enum_types = {}
C_DELETEPLAYER.fields = {_pb.C_DELETEPLAYER_PLAYERID_FIELD}
C_DELETEPLAYER.is_extendable = false
C_DELETEPLAYER.extensions = {}
_pb.S_DELETEPLAYER_PLAYERID_FIELD.name = "playerId"
_pb.S_DELETEPLAYER_PLAYERID_FIELD.full_name = ".S_DeletePlayer.playerId"
_pb.S_DELETEPLAYER_PLAYERID_FIELD.number = 1
_pb.S_DELETEPLAYER_PLAYERID_FIELD.index = 0
_pb.S_DELETEPLAYER_PLAYERID_FIELD.label = 2
_pb.S_DELETEPLAYER_PLAYERID_FIELD.has_default_value = false
_pb.S_DELETEPLAYER_PLAYERID_FIELD.default_value = 0
_pb.S_DELETEPLAYER_PLAYERID_FIELD.type = 3
_pb.S_DELETEPLAYER_PLAYERID_FIELD.cpp_type = 2

S_DELETEPLAYER.name = "S_DeletePlayer"
S_DELETEPLAYER.full_name = ".S_DeletePlayer"
S_DELETEPLAYER.nested_types = {}
S_DELETEPLAYER.enum_types = {}
S_DELETEPLAYER.fields = {_pb.S_DELETEPLAYER_PLAYERID_FIELD}
S_DELETEPLAYER.is_extendable = false
S_DELETEPLAYER.extensions = {}
_pb.C_ENTERGAME_PLAYERID_FIELD.name = "playerId"
_pb.C_ENTERGAME_PLAYERID_FIELD.full_name = ".C_EnterGame.playerId"
_pb.C_ENTERGAME_PLAYERID_FIELD.number = 1
_pb.C_ENTERGAME_PLAYERID_FIELD.index = 0
_pb.C_ENTERGAME_PLAYERID_FIELD.label = 2
_pb.C_ENTERGAME_PLAYERID_FIELD.has_default_value = false
_pb.C_ENTERGAME_PLAYERID_FIELD.default_value = 0
_pb.C_ENTERGAME_PLAYERID_FIELD.type = 3
_pb.C_ENTERGAME_PLAYERID_FIELD.cpp_type = 2

_pb.C_ENTERGAME_TELEPHONE_FIELD.name = "telePhone"
_pb.C_ENTERGAME_TELEPHONE_FIELD.full_name = ".C_EnterGame.telePhone"
_pb.C_ENTERGAME_TELEPHONE_FIELD.number = 2
_pb.C_ENTERGAME_TELEPHONE_FIELD.index = 1
_pb.C_ENTERGAME_TELEPHONE_FIELD.label = 1
_pb.C_ENTERGAME_TELEPHONE_FIELD.has_default_value = false
_pb.C_ENTERGAME_TELEPHONE_FIELD.default_value = 0
_pb.C_ENTERGAME_TELEPHONE_FIELD.type = 3
_pb.C_ENTERGAME_TELEPHONE_FIELD.cpp_type = 2

C_ENTERGAME.name = "C_EnterGame"
C_ENTERGAME.full_name = ".C_EnterGame"
C_ENTERGAME.nested_types = {}
C_ENTERGAME.enum_types = {}
C_ENTERGAME.fields = {_pb.C_ENTERGAME_PLAYERID_FIELD, _pb.C_ENTERGAME_TELEPHONE_FIELD}
C_ENTERGAME.is_extendable = false
C_ENTERGAME.extensions = {}
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.name = "playerCommonMsg"
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.full_name = ".LoginMsg.playerCommonMsg"
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.number = 1
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.index = 0
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.label = 1
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.has_default_value = false
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.default_value = nil
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.message_type = PLAYER_PB.PLAYERCOMMONMSG
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.type = 11
_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD.cpp_type = 10

_pb.LOGINMSG_MAPID_FIELD.name = "mapId"
_pb.LOGINMSG_MAPID_FIELD.full_name = ".LoginMsg.mapId"
_pb.LOGINMSG_MAPID_FIELD.number = 2
_pb.LOGINMSG_MAPID_FIELD.index = 1
_pb.LOGINMSG_MAPID_FIELD.label = 1
_pb.LOGINMSG_MAPID_FIELD.has_default_value = false
_pb.LOGINMSG_MAPID_FIELD.default_value = 0
_pb.LOGINMSG_MAPID_FIELD.type = 5
_pb.LOGINMSG_MAPID_FIELD.cpp_type = 1

_pb.LOGINMSG_SERVERTIME_FIELD.name = "serverTime"
_pb.LOGINMSG_SERVERTIME_FIELD.full_name = ".LoginMsg.serverTime"
_pb.LOGINMSG_SERVERTIME_FIELD.number = 3
_pb.LOGINMSG_SERVERTIME_FIELD.index = 2
_pb.LOGINMSG_SERVERTIME_FIELD.label = 1
_pb.LOGINMSG_SERVERTIME_FIELD.has_default_value = false
_pb.LOGINMSG_SERVERTIME_FIELD.default_value = 0
_pb.LOGINMSG_SERVERTIME_FIELD.type = 3
_pb.LOGINMSG_SERVERTIME_FIELD.cpp_type = 2

LOGINMSG.name = "LoginMsg"
LOGINMSG.full_name = ".LoginMsg"
LOGINMSG.nested_types = {}
LOGINMSG.enum_types = {}
LOGINMSG.fields = {_pb.LOGINMSG_PLAYERCOMMONMSG_FIELD, _pb.LOGINMSG_MAPID_FIELD, _pb.LOGINMSG_SERVERTIME_FIELD}
LOGINMSG.is_extendable = false
LOGINMSG.extensions = {}
_pb.S_ENTERGAME_LOGINMSG_FIELD.name = "loginMsg"
_pb.S_ENTERGAME_LOGINMSG_FIELD.full_name = ".S_EnterGame.loginMsg"
_pb.S_ENTERGAME_LOGINMSG_FIELD.number = 1
_pb.S_ENTERGAME_LOGINMSG_FIELD.index = 0
_pb.S_ENTERGAME_LOGINMSG_FIELD.label = 1
_pb.S_ENTERGAME_LOGINMSG_FIELD.has_default_value = false
_pb.S_ENTERGAME_LOGINMSG_FIELD.default_value = nil
_pb.S_ENTERGAME_LOGINMSG_FIELD.message_type = LOGINMSG
_pb.S_ENTERGAME_LOGINMSG_FIELD.type = 11
_pb.S_ENTERGAME_LOGINMSG_FIELD.cpp_type = 10

S_ENTERGAME.name = "S_EnterGame"
S_ENTERGAME.full_name = ".S_EnterGame"
S_ENTERGAME.nested_types = {}
S_ENTERGAME.enum_types = {}
S_ENTERGAME.fields = {_pb.S_ENTERGAME_LOGINMSG_FIELD}
S_ENTERGAME.is_extendable = false
S_ENTERGAME.extensions = {}
S_EXITGAME.name = "S_ExitGame"
S_EXITGAME.full_name = ".S_ExitGame"
S_EXITGAME.nested_types = {}
S_EXITGAME.enum_types = {}
S_EXITGAME.fields = {}
S_EXITGAME.is_extendable = false
S_EXITGAME.extensions = {}
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.name = "endStopTime"
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.full_name = ".S_StopServer.endStopTime"
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.number = 1
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.index = 0
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.label = 1
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.has_default_value = false
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.default_value = 0
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.type = 3
_pb.S_STOPSERVER_ENDSTOPTIME_FIELD.cpp_type = 2

S_STOPSERVER.name = "S_StopServer"
S_STOPSERVER.full_name = ".S_StopServer"
S_STOPSERVER.nested_types = {}
S_STOPSERVER.enum_types = {}
S_STOPSERVER.fields = {_pb.S_STOPSERVER_ENDSTOPTIME_FIELD}
S_STOPSERVER.is_extendable = false
S_STOPSERVER.extensions = {}
C_ENTERCOMPLETE.name = "C_EnterComplete"
C_ENTERCOMPLETE.full_name = ".C_EnterComplete"
C_ENTERCOMPLETE.nested_types = {}
C_ENTERCOMPLETE.enum_types = {}
C_ENTERCOMPLETE.fields = {}
C_ENTERCOMPLETE.is_extendable = false
C_ENTERCOMPLETE.extensions = {}
_pb.C_LOGINAGAIN_USERID_FIELD.name = "userId"
_pb.C_LOGINAGAIN_USERID_FIELD.full_name = ".C_LoginAgain.userId"
_pb.C_LOGINAGAIN_USERID_FIELD.number = 1
_pb.C_LOGINAGAIN_USERID_FIELD.index = 0
_pb.C_LOGINAGAIN_USERID_FIELD.label = 2
_pb.C_LOGINAGAIN_USERID_FIELD.has_default_value = false
_pb.C_LOGINAGAIN_USERID_FIELD.default_value = 0
_pb.C_LOGINAGAIN_USERID_FIELD.type = 3
_pb.C_LOGINAGAIN_USERID_FIELD.cpp_type = 2

_pb.C_LOGINAGAIN_KEY_FIELD.name = "key"
_pb.C_LOGINAGAIN_KEY_FIELD.full_name = ".C_LoginAgain.key"
_pb.C_LOGINAGAIN_KEY_FIELD.number = 3
_pb.C_LOGINAGAIN_KEY_FIELD.index = 1
_pb.C_LOGINAGAIN_KEY_FIELD.label = 2
_pb.C_LOGINAGAIN_KEY_FIELD.has_default_value = false
_pb.C_LOGINAGAIN_KEY_FIELD.default_value = ""
_pb.C_LOGINAGAIN_KEY_FIELD.type = 9
_pb.C_LOGINAGAIN_KEY_FIELD.cpp_type = 9

_pb.C_LOGINAGAIN_TIME_FIELD.name = "time"
_pb.C_LOGINAGAIN_TIME_FIELD.full_name = ".C_LoginAgain.time"
_pb.C_LOGINAGAIN_TIME_FIELD.number = 4
_pb.C_LOGINAGAIN_TIME_FIELD.index = 2
_pb.C_LOGINAGAIN_TIME_FIELD.label = 1
_pb.C_LOGINAGAIN_TIME_FIELD.has_default_value = false
_pb.C_LOGINAGAIN_TIME_FIELD.default_value = ""
_pb.C_LOGINAGAIN_TIME_FIELD.type = 9
_pb.C_LOGINAGAIN_TIME_FIELD.cpp_type = 9

_pb.C_LOGINAGAIN_SIGN_FIELD.name = "sign"
_pb.C_LOGINAGAIN_SIGN_FIELD.full_name = ".C_LoginAgain.sign"
_pb.C_LOGINAGAIN_SIGN_FIELD.number = 5
_pb.C_LOGINAGAIN_SIGN_FIELD.index = 3
_pb.C_LOGINAGAIN_SIGN_FIELD.label = 1
_pb.C_LOGINAGAIN_SIGN_FIELD.has_default_value = false
_pb.C_LOGINAGAIN_SIGN_FIELD.default_value = ""
_pb.C_LOGINAGAIN_SIGN_FIELD.type = 9
_pb.C_LOGINAGAIN_SIGN_FIELD.cpp_type = 9

_pb.C_LOGINAGAIN_PLAYERID_FIELD.name = "playerId"
_pb.C_LOGINAGAIN_PLAYERID_FIELD.full_name = ".C_LoginAgain.playerId"
_pb.C_LOGINAGAIN_PLAYERID_FIELD.number = 6
_pb.C_LOGINAGAIN_PLAYERID_FIELD.index = 4
_pb.C_LOGINAGAIN_PLAYERID_FIELD.label = 2
_pb.C_LOGINAGAIN_PLAYERID_FIELD.has_default_value = false
_pb.C_LOGINAGAIN_PLAYERID_FIELD.default_value = 0
_pb.C_LOGINAGAIN_PLAYERID_FIELD.type = 3
_pb.C_LOGINAGAIN_PLAYERID_FIELD.cpp_type = 2

_pb.C_LOGINAGAIN_SERVERNO_FIELD.name = "serverNo"
_pb.C_LOGINAGAIN_SERVERNO_FIELD.full_name = ".C_LoginAgain.serverNo"
_pb.C_LOGINAGAIN_SERVERNO_FIELD.number = 7
_pb.C_LOGINAGAIN_SERVERNO_FIELD.index = 5
_pb.C_LOGINAGAIN_SERVERNO_FIELD.label = 1
_pb.C_LOGINAGAIN_SERVERNO_FIELD.has_default_value = false
_pb.C_LOGINAGAIN_SERVERNO_FIELD.default_value = 0
_pb.C_LOGINAGAIN_SERVERNO_FIELD.type = 5
_pb.C_LOGINAGAIN_SERVERNO_FIELD.cpp_type = 1

C_LOGINAGAIN.name = "C_LoginAgain"
C_LOGINAGAIN.full_name = ".C_LoginAgain"
C_LOGINAGAIN.nested_types = {}
C_LOGINAGAIN.enum_types = {}
C_LOGINAGAIN.fields = {_pb.C_LOGINAGAIN_USERID_FIELD, _pb.C_LOGINAGAIN_KEY_FIELD, _pb.C_LOGINAGAIN_TIME_FIELD, _pb.C_LOGINAGAIN_SIGN_FIELD, _pb.C_LOGINAGAIN_PLAYERID_FIELD, _pb.C_LOGINAGAIN_SERVERNO_FIELD}
C_LOGINAGAIN.is_extendable = false
C_LOGINAGAIN.extensions = {}
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.name = "testSwitch"
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.full_name = ".S_EnterComplete.testSwitch"
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.number = 1
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.index = 0
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.label = 1
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.default_value = 0
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.type = 5
_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD.cpp_type = 1

_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.name = "bagGrid"
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.full_name = ".S_EnterComplete.bagGrid"
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.number = 2
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.index = 1
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.label = 1
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.default_value = 0
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.type = 5
_pb.S_ENTERCOMPLETE_BAGGRID_FIELD.cpp_type = 1

_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.name = "listPlayerBags"
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.full_name = ".S_EnterComplete.listPlayerBags"
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.number = 3
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.index = 2
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.label = 3
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.default_value = {}
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.message_type = BAG_PB.PLAYERBAGMSG
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.type = 11
_pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD.cpp_type = 10

_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.name = "listPlayerEquipments"
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.full_name = ".S_EnterComplete.listPlayerEquipments"
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.number = 4
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.index = 3
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.label = 3
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.default_value = {}
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.message_type = EQUIPMENT_PB.PLAYEREQUIPMENTMSG
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.type = 11
_pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD.cpp_type = 10

_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.name = "hpDrugLumns"
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.full_name = ".S_EnterComplete.hpDrugLumns"
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.number = 5
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.index = 4
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.label = 3
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.default_value = {}
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.message_type = BAG_PB.DRUGLUMNMSG
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.type = 11
_pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD.cpp_type = 10

_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.name = "mpDrugLumns"
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.full_name = ".S_EnterComplete.mpDrugLumns"
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.number = 6
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.index = 5
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.label = 3
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.default_value = {}
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.message_type = BAG_PB.DRUGLUMNMSG
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.type = 11
_pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD.cpp_type = 10

_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.name = "listPlayerSkills"
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.full_name = ".S_EnterComplete.listPlayerSkills"
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.number = 7
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.index = 6
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.label = 3
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.default_value = {}
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.message_type = SKILL_PB.PLAYERSKILLMSG
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.type = 11
_pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD.cpp_type = 10

_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.name = "haveNewMail"
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.full_name = ".S_EnterComplete.haveNewMail"
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.number = 8
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.index = 7
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.label = 1
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.default_value = 0
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.type = 5
_pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD.cpp_type = 1

_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.name = "haveMailTotalNum"
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.full_name = ".S_EnterComplete.haveMailTotalNum"
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.number = 9
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.index = 8
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.label = 1
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.default_value = 0
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.type = 5
_pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD.cpp_type = 1

_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.name = "listPlayerTasks"
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.full_name = ".S_EnterComplete.listPlayerTasks"
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.number = 10
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.index = 9
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.label = 3
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.default_value = {}
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.message_type = TASK_PB.PLAYERTASKMSG
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.type = 11
_pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD.cpp_type = 10

_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.name = "equipmentGrid"
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.full_name = ".S_EnterComplete.equipmentGrid"
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.number = 11
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.index = 10
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.label = 1
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.default_value = 0
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.type = 5
_pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD.cpp_type = 1

_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.name = "listPlayerWeaponEffect"
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.full_name = ".S_EnterComplete.listPlayerWeaponEffect"
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.number = 12
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.index = 11
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.label = 3
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.default_value = {}
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.message_type = EQUIPMENT_PB.PLAYERWEAPONEFFECTMSG
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.type = 11
_pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD.cpp_type = 10

_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.name = "playerFamilyId"
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.full_name = ".S_EnterComplete.playerFamilyId"
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.number = 13
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.index = 12
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.label = 1
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.default_value = 0
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.type = 3
_pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD.cpp_type = 2

_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.name = "signMsg"
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.full_name = ".S_EnterComplete.signMsg"
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.number = 14
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.index = 13
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.label = 1
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.default_value = nil
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.message_type = SIGN_PB.SIGNMSG
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.type = 11
_pb.S_ENTERCOMPLETE_SIGNMSG_FIELD.cpp_type = 10

_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.name = "curLayerId"
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.full_name = ".S_EnterComplete.curLayerId"
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.number = 15
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.index = 14
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.label = 1
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.default_value = 0
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.type = 5
_pb.S_ENTERCOMPLETE_CURLAYERID_FIELD.cpp_type = 1

_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.name = "furnaceList"
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.full_name = ".S_EnterComplete.furnaceList"
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.number = 16
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.index = 15
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.label = 3
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.has_default_value = false
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.default_value = {}
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.message_type = FURNACE_PB.PLAYERFURNACEMSG
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.type = 11
_pb.S_ENTERCOMPLETE_FURNACELIST_FIELD.cpp_type = 10

S_ENTERCOMPLETE.name = "S_EnterComplete"
S_ENTERCOMPLETE.full_name = ".S_EnterComplete"
S_ENTERCOMPLETE.nested_types = {}
S_ENTERCOMPLETE.enum_types = {}
S_ENTERCOMPLETE.fields = {_pb.S_ENTERCOMPLETE_TESTSWITCH_FIELD, _pb.S_ENTERCOMPLETE_BAGGRID_FIELD, _pb.S_ENTERCOMPLETE_LISTPLAYERBAGS_FIELD, _pb.S_ENTERCOMPLETE_LISTPLAYEREQUIPMENTS_FIELD, _pb.S_ENTERCOMPLETE_HPDRUGLUMNS_FIELD, _pb.S_ENTERCOMPLETE_MPDRUGLUMNS_FIELD, _pb.S_ENTERCOMPLETE_LISTPLAYERSKILLS_FIELD, _pb.S_ENTERCOMPLETE_HAVENEWMAIL_FIELD, _pb.S_ENTERCOMPLETE_HAVEMAILTOTALNUM_FIELD, _pb.S_ENTERCOMPLETE_LISTPLAYERTASKS_FIELD, _pb.S_ENTERCOMPLETE_EQUIPMENTGRID_FIELD, _pb.S_ENTERCOMPLETE_LISTPLAYERWEAPONEFFECT_FIELD, _pb.S_ENTERCOMPLETE_PLAYERFAMILYID_FIELD, _pb.S_ENTERCOMPLETE_SIGNMSG_FIELD, _pb.S_ENTERCOMPLETE_CURLAYERID_FIELD, _pb.S_ENTERCOMPLETE_FURNACELIST_FIELD}
S_ENTERCOMPLETE.is_extendable = false
S_ENTERCOMPLETE.extensions = {}

C_CreatePlayer = protobuf.Message(C_CREATEPLAYER)
C_DeletePlayer = protobuf.Message(C_DELETEPLAYER)
C_EnterComplete = protobuf.Message(C_ENTERCOMPLETE)
C_EnterGame = protobuf.Message(C_ENTERGAME)
C_LoginAgain = protobuf.Message(C_LOGINAGAIN)
C_LoginGame = protobuf.Message(C_LOGINGAME)
LoginMsg = protobuf.Message(LOGINMSG)
S_CreatePlayer = protobuf.Message(S_CREATEPLAYER)
S_DeletePlayer = protobuf.Message(S_DELETEPLAYER)
S_EnterComplete = protobuf.Message(S_ENTERCOMPLETE)
S_EnterGame = protobuf.Message(S_ENTERGAME)
S_ExitGame = protobuf.Message(S_EXITGAME)
S_LoginGame = protobuf.Message(S_LOGINGAME)
S_StopServer = protobuf.Message(S_STOPSERVER)

