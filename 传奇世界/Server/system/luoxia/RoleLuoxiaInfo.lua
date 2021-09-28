--RoleLuoxiaInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  RoleLuoxiaInfo.lua
 --* Author:  seezon
 --* Modified: 2015年6月24日
 --* Purpose: Implementation of the class RoleLuoxiaInfo
 -------------------------------------------------------------------*/
--删除头顶物品后，这个文件几乎没用了，不过没关系，保留着以后万一扩展可以用
RoleLuoxiaInfo = class()

local prop = Property(RoleLuoxiaInfo)
prop:accessor("roleSID", 0)
prop:accessor("roleID", 0)
prop:accessor("startTime", 0)

function RoleLuoxiaInfo:__init()
	
end

--切换world的通知
function RoleLuoxiaInfo:switchWorld(peer, dbid, mapID)
	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_LUOXIA_SET)
	--具体数据跟在后面
	luaBuf:pushInt(self:getStartTime())
	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
end

function RoleLuoxiaInfo:loadDBDataImpl(player, luaBuf)
	if luaBuf:size() > 0 then
		self:setStartTime(luaBuf:popInt())
	end
end