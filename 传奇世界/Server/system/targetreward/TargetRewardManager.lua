--TargetRewardManager.lua
--/*-----------------------------------------------------------------
 --* Module:  TargetRewardManager.lua
 --* Author:  liucheng
 --* Modified: 2016年03月21日
 --* Purpose: 目标奖励
 -------------------------------------------------------------------*/
require ("system.targetreward.TargetRewardServlet")
require ("system.targetreward.TargetRewardRoleInfo")

TargetRewardManager = class(nil, Singleton)

function TargetRewardManager:__init()	
 	self._staticReward = {}		--存储目标奖励表的内容	1战士	2法师	3道士
	self._roleInfoBySID = {} 	--数据库ID

	self:loadTargetData()
	g_listHandler:addListener(self)
end

--加载目标奖励	20150302
function TargetRewardManager:loadTargetData()
--[[	
	local TargetRewardDB = require 'data.TargetReward'
	self._staticReward[1] = {}
	self._staticReward[2] = {}
	self._staticReward[3] = {}

	for _,record in pairs(TargetRewardDB or table.empty) do
		if 1==record.q_job then
			--self._staticReward[1][record.record_id] = record
			table.insert(self._staticReward[1],record)
		elseif 2==record.q_job then
			--self._staticReward[2][record.record_id] = record
			table.insert(self._staticReward[2],record)
		elseif 3==record.q_job then
			--self._staticReward[3][record.record_id] = record
			table.insert(self._staticReward[3],record)
		else 
		end
	end
]]	
end

--获取目标奖励数据表的数据	20150304
function TargetRewardManager:getTargetReward(tSchool)
	if tSchool then
		return self._staticReward[tSchool]
	end
	return {}
end

--玩家上线
function TargetRewardManager:onPlayerLoaded(player)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	local memInfo = self:getRoleInfoBySID(roleSID)
	if not memInfo then
		memInfo = TargetRewardRoleInfo()
		memInfo:setRoleSID(roleSID)
		self._roleInfoBySID[roleSID] = memInfo
	end
end

--数据库加载回调
function TargetRewardManager.loadDBData(player, cacha_buf, roleSid)
	g_TargetRewardMgr:loadDBDataImpl(player, cacha_buf, roleSid)
end

--数据库加载回调
function TargetRewardManager:loadDBDataImpl(player, cacha_buf, roleSid)
	if not player then return end
	local roleID = player:getID()
	local roleSID = player:getSerialID()

	local memInfo = self:getRoleInfoBySID(roleSID)
	if not memInfo then
		memInfo = TargetRewardRoleInfo()
		memInfo:setRoleSID(roleSID)
		self._roleInfoBySID[roleSID] = memInfo
	end

	if memInfo then
		memInfo:loadDBData(cacha_buf)
	end
end

--玩家注销
function TargetRewardManager:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	local memInfo = self:getRoleInfoBySID(roleSID)
	if memInfo then
		self._roleInfoBySID[roleSID] = nil
	end
end

--掉线登陆
function TargetRewardManager:onActivePlayer(player)
	local memInfo = self:getRoleInfoBySID(player:getSerialID()) 
	if memInfo then
		--memInfo:notifyChargeInfo()
    end
end

--切换world的通知
function TargetRewardManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then return end
	local roleSID = player:getSerialID()

	local memInfo = self:getRoleInfoBySID(roleSID)
	if memInfo then
		memInfo:switchOut(peer, dbid, mapID)
	end
end

--切换到本world的通知
function TargetRewardManager:onPlayerSwitch(player, type, buff)
	if type == EVENT_TARGET_REWARD_SET then
		local roleID = player:getID()
		local roleSID = player:getSerialID()
		local memInfo = self:getRoleInfoBySID(roleSID)
		if not memInfo then
			memInfo = TargetRewardRoleInfo()
			memInfo:setRoleSID(roleSID)
			self._roleInfoBySID[roleSID] = memInfo
		end

		if memInfo then
			memInfo:switchIn(player, buff)
		end
	end	
end

--玩家升级
function TargetRewardManager:onLevelChanged(player)
	if not player then return end
	local memInfo = self:getRoleInfoBySID(player:getSerialID())
	if memInfo then
		memInfo:SendTargetReward()
	end
end

--获取玩家数据通过数据库ID
function TargetRewardManager:getRoleInfoBySID(roleSID)
	return self._roleInfoBySID[roleSID]
end

function TargetRewardManager.getInstance()
	return TargetRewardManager()
end

g_TargetRewardMgr = TargetRewardManager.getInstance()