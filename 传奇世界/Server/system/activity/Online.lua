--Online.lua
--/*-----------------------------------------------------------------
--* Module:  Online.lua
--* Author:  Andy
--* Modified: 2015年10月26日
--* Purpose: Implementation of the class Online
-------------------------------------------------------------------*/

require ("base.class")
Online = class()

local prop = Property(Online)
prop:accessor("roleID")
prop:accessor("roleSID")

function Online:__init(roleID, roleSID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)
	self._datas = {}
    self:initialize()
end

function Online:initialize()
	self._checkTimes = 0
	self._lastTick = 0
	self._datas.date = 0
	self._datas.continueTime = 0	-- 累计在线时长
   	self._datas.status = {}
	for index, _ in pairs(g_DataMgr:getOnlineConfig()) do
		self._datas.status[index] = 1
	end
end

function Online:redDot()
	for _, status in pairs(self._datas.status) do
		if status == 0 then
			return true
		end
	end
	return false
end

function Online:isFinish()
	for _, status in pairs(self._datas.status) do
		if status == 1 then
			return false
		end
	end
	return true
end

function Online:playerLogout()
	self:check(true)
end

-- 定时检测是否达到在线时长
function Online:check(logout, timeTick)
	local now = os.time()
	-- local timeTick = time.toedition("day", now - ACTIVITY_REFRESH * 3600)
	if timeTick and self._datas.date ~= timeTick then
		self:initialize()
		self._datas.date = timeTick
	end
	if self:isFinish() then
		return
	end
	if self._lastTick == 0 then
		self._lastTick = now
		return
	end
	self._datas.continueTime = self._datas.continueTime + (now - self._lastTick)
	self._lastTick = now
	for index, _ in pairs(g_DataMgr:getOnlineConfig()) do
		if self._datas.status[index] == 1 and self._datas.continueTime >= index * 60 then
			self._datas.status[index] = 0
			self:cast2DB()
			g_ActivityMgr:getActivityList(self:getRoleID())
			if self._datas.continueTime >= 3600 then
				fireProtoMessage(self:getRoleID(), ACTIVITY_SC_PUSH_ONLINE_TIME, "ActivityPushOnlineTime", {time = self._datas.continueTime})
			end
		end
	end
	self._checkTimes = self._checkTimes + 1
	if logout or self._checkTimes > 12 then
		self:cast2DB()
		self._checkTimes = 0
	end
end

function Online:req()
	local roleID = self:getRoleID()
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end
	local onlines = {}
	for index, reward in pairs(g_DataMgr:getOnlineConfig()) do
		local endTime = index * 60 - self._datas.continueTime
		if endTime < 0 then
			endTime = 0
		end
		local online = {}
		online.time = index
		online.endTime = endTime
		online.status = self._datas.status[index]
		online.reward = g_ActivityMgr:filterReward(player, reward)
		table.insert(onlines, online)
	end
	local ret = {}
	ret.modelID = ACTIVITY_MODEL.ONLINE
	ret.activityID = ACTIVITY_ONLIINE_ID
	ret.online = onlines
	fireProtoMessage(roleID, ACTIVITY_SC_RET, "ActivityRet", ret)
end

function Online:reward(index)
	local roleID = self:getRoleID()
	local player = g_entityMgr:getPlayer(roleID)
	if self._datas.status[index] ~= 0 or not player then
		return
	end
	local itemMgr = player:getItemMgr()
	if not itemMgr then
		return
	end
	local config = g_DataMgr:getOnlineConfig() or {}
	local reward = g_ActivityMgr:filterReward(player, config[index])
	if g_ActivityMgr:isEmpty(reward) then
		return
	end
	local roleSID = self:getRoleSID()
	if #reward > itemMgr:getEmptySize(Item_BagIndex_Bag) then
		g_ActivityMgr:sendRewardByEmail(roleSID, reward, 16)
	else
		for _, item in pairs(reward) do
			itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind)
			g_ActivityMgr:writeLog(roleSID, 1, 16, item.itemID, item.count, item.bind, player)
			g_ChatSystem:GetMoneyIntoChat(roleSID, item.itemID, item.count)
		end
		g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_SUCCESS, 0, {})
	end
	self._datas.status[index] = 2
	self:req()
	g_ActivityMgr:getActivityList(roleID)
	g_logManager:writeOpactivities(roleSID, ACTIVITY_ONLIINE_ID, index, 2)
	self:cast2DB()
end

function Online:loadDBdata(datas)
	self._datas = datas
	fireProtoMessage(self:getRoleID(), ACTIVITY_SC_PUSH_ONLINE_TIME, "ActivityPushOnlineTime", {time = self._datas.continueTime})
end

function Online:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), ACTIVITY_MODEL.ONLINE, ACTIVITY_ONLIINE_ID, self._datas)
end