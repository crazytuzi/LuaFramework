require "luaprotocolhandler.knight_gsp_minigame"
require "luaprotocolhandler.knight_gsp_pet"
require "luaprotocolhandler.knight_gsp_item"
require "luaprotocolhandler.knight_gsp"
require "luaprotocolhandler.knight_gsp_yuanbao"
require "luaprotocolhandler.knight_gsp_npc"
require "luaprotocolhandler.knight_gsp_task"
require "luaprotocolhandler.knight_gsp_xiake"
require "luaprotocolhandler.knight_gsp_xiake_xiaganyidan"
require "luaprotocolhandler.knight_gsp_move"
require "luaprotocolhandler.knight_gsp_faction"
require "luaprotocolhandler.knight_gsp_friends"
require "luaprotocolhandler.knight_gsp_battle"
require "luaprotocolhandler.knight_gsp_team"
require "luaprotocolhandler.knight_gsp_ranklist"
require "luaprotocolhandler.knight_gsp_title"
require "luaprotocolhandler.knight_gsp_skill"
require "luaprotocolhandler.knight_gsp_skill_specialskill"
require "luaprotocolhandler.knight_gsp_specialquest"
require "luaprotocolhandler.knight_gsp_buff"
require "luaprotocolhandler.knight_gsp_lock"
require "luaprotocolhandler.knight_gsp_msg"
require "luaprotocolhandler.knight_gsp_campleader"
require "luaprotocolhandler.knight_gsp_springfestival"
require "luaprotocolhandler.knight_gsp_shenmishop"
require "luaprotocolhandler.knight_gsp_pingbi"
require "luaprotocolhandler.knight_gsp_faction_enhance"
require "luaprotocolhandler.knight_gsp_activity_yzdd"
require "luaprotocolhandler.knight_gsp_qijingbamai"
require "luaprotocolhandler.knight_gsp_activity_common"
require "luaprotocolhandler.knight_gsp_activity_gumumijing"
require "luaprotocolhandler.knight_gsp_activity_dazhuanpan"
require "luaprotocolhandler.knight_gsp_binglinchengxia"
require "luaprotocolhandler.knight_gsp_activity_fanfanle"
require "luaprotocolhandler.knight_gsp_activity_veteran"
require "luaprotocolhandler.knight_gsp_cross"
require "luaprotocolhandler.knight_gsp_marry"
require "luaprotocolhandler.knight_gsp_xiake_practice"
require "luaprotocolhandler.knight_gsp_sworn"
require "luaprotocolhandler.knight_gsp_activity_shijiebei"
require "luaprotocolhandler.knight_gsp_activity_yibaiceng"
require "luaprotocolhandler.knight_gsp_master"
require "luaprotocolhandler.knight_gsp_activity_homework"
require "luaprotocolhandler.knight_gsp_activity_gangman"
require "luaprotocolhandler.knight_gsp_activity_chargefeedback"
require "luaprotocolhandler.knight_gsp_sdzhaji"
require "luaprotocolhandler.knight_gsp_activity_cszhuanpan"

LuaProtocolManager = {}
LuaProtocolManager.__index = LuaProtocolManager

function LuaProtocolManager.Dispatch(luap)
	print("dispatch enter")
	LuaProtocolManager.getInstance():ProtocolRun(luap.type, luap.data)
end

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LuaProtocolManager.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = LuaProtocolManager:new()
    end

    return _instance
end

function LuaProtocolManager.removeInstance()
	_instance = nil
end

function LuaProtocolManager:new()
    local self = {}
    setmetatable(self, LuaProtocolManager)

	self.m_MapLuaProtocols = {}
    return self
end

function LuaProtocolManager:send(p)
	local _os_ = p:encode()
	print("protocolrun enter type " .. p.type)
    GetNetConnection():luasend(_os_:getdata())
end

function LuaProtocolManager:ProtocolRun(type, octdata)

	print("protocolrun enter type " .. type)
	local createfunc = self.m_MapLuaProtocols[type] 
	if createfunc then 
		print("createfunc exist")
		local lp = createfunc() 
		if lp then 
			local _os_  = GNET.Marshal.OctetsStream:new(octdata)
			lp:unmarshal(_os_)
			lp:process() 
		end
	else
		print("lua protocol unknown: type: " .. type)
	end
end

function LuaProtocolManager:RegisterLuaProtocolCreator(type, func)
	self.m_MapLuaProtocols[type] = func
end

function LuaProtocolManager:UnRegisterLuaProtocolCreator(type)
	self.m_MapLuaProtocols[type] = nil
end

return LuaProtocolManager
