--MountManager.lua
--/*-----------------------------------------------------------------
--* Module:  MountManager.lua
--* Author:  zhaofg
--* Modified: 2016年5月24日 
--* Purpose: Implementation of the class MountManager 
-------------------------------------------------------------------*/
require "system.mount.MountConstant"

MountManager = class(nil, Singleton)

function MountManager:__init()	
	
	self._UserPassInfo = {} 				--密码和过期时间
	self._UserCheckInfo = {}                --验证结果

	g_listHandler:addListener(self)         --增加接口回调
end

function MountManager.doEnterScene(playerID, npcID, params)

	local player = g_entityMgr:getPlayer(playerID)
	if not player then
		print('MountManager doEnterScene player not found '.. playerID)
		return
	end

	--进入场景
	local arrLen = #MountScenePosConfig;
	local nIndex = 1
	if arrLen > 1 then
		nIndex = math.random(1,arrLen)
	end	

	local pos = {x=MountScenePosConfig[nIndex][1], y=MountScenePosConfig[nIndex][2]}
	if g_sceneMgr:posValidate(MOUNT_SCNEN_MAP_ID, pos.x, pos.y) then
		print("MountManager doEnterScene pos valid",pos.x, pos.y, playerID)
		local old_pos = player:getPosition()
		player:setLastMapID(player:getMapID())
		player:setLastPosX(old_pos.x)
		player:setLastPosY(old_pos.y)
		g_sceneMgr:enterPublicScene(playerID, MOUNT_SCNEN_MAP_ID, pos.x, pos.y)
	else
		print("MountManager doEnterScene pos invalid")
	end

end

--灵兽开启前置任务完成
function MountManager:OnTaskComplete(player)
	player:SetCompleteMountPerTask();
end



function MountManager:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(0, roleId, EVENT_SECOND_PASS, errId, paramCount, params)
end

function MountManager.getInstance()
	return MountManager()
end

g_MountManager = MountManager.getInstance()