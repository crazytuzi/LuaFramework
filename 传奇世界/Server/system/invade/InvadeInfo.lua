--InvadeInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  InvadeInfo.lua
 --* Author:  Andy
 --* Modified: 2016年03月21日
 --* Purpose: Implementation of the class InvadeInfo
 -------------------------------------------------------------------*/

InvadeInfo = class()

local prop = Property(InvadeInfo)

prop:accessor("factionID", true)	--行会ID
prop:accessor("totalIntegral", 0)	--获得的总积分
prop:accessor("monsterNum1", 0)		--击杀纵火贼数量
prop:accessor("monsterNum2", 0)		--击杀响马贼数量
prop:accessor("hasMonster3", false)	--是否触发过路霸
prop:accessor("numMonster4", 0)		--触发过盗贼头目的次数
prop:accessor("pushDataFlag", false)

--Tlog统计数据
prop:accessor("monsterNum3", 0)		--击杀路霸数量
prop:accessor("monsterNum4", 0)		--击杀盗贼头目数量

function InvadeInfo:__init(factionID)
	prop(self, "factionID", factionID)

	self._joinUser = {}		--参加活动的帮会成员
	self._areaUser = {}		--在行会据点的成员
end

--给所有在行会据点的玩家推送面板数据
function InvadeInfo:pushAllUserData()
	if self:getPushDataFlag() then
		local integral = self:getTotalIntegral()
		local ret = {
			surplusTime = g_InvadeMgr:getSurplusTime(),
			integral = integral,
			nextIntegral = g_InvadeMgr:getNextIntegral(integral),
			monsterNum1 = self:getMonsterNum1(),
			monsterNum2 = self:getMonsterNum2(),
		}
		for i = 1, #self._areaUser do
			local roleSID = self._areaUser[i]
			local player = g_entityMgr:getPlayerBySID(roleSID)
			if player and player:getMapID() == FACTION_AREA_MAP_ID then
				fireProtoMessage(player:getID(), INVADE_SC_PUSH_DATA, "InvadePushData", ret)
			end
		end
		self:setPushDataFlag(false)
	end
end

--给参加的玩家推送提示消息
function InvadeInfo:sendErrMsg2JoinUser(errId)
	local joinUser = self:getJoinUser()
	for i = 1, #joinUser do
		local roleSID = joinUser[i]
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player and player:getMapID() == FACTION_AREA_MAP_ID then
			g_InvadeMgr:sendErrMsg2Client(player:getID(), errId, 0)
		end
	end
end

function InvadeInfo:addJoinUser(roleSID)
	if not table.contains(self._joinUser, roleSID) then
		table.insert(self._joinUser, roleSID)
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.INVADE)
		end
	end
end

function InvadeInfo:removeJoinUser(roleSID)
	table.removeValue(self._joinUser, roleSID)
end

function InvadeInfo:getJoinUser()
	return self._joinUser
end

function InvadeInfo:addAreaUser(roleSID)
	if not table.contains(self._areaUser, roleSID) then
		table.insert(self._areaUser, roleSID)
		self:setPushDataFlag(true)
	end
end

function InvadeInfo:removeAreaUser(roleSID)
	table.removeValue(self._areaUser, roleSID)
end
