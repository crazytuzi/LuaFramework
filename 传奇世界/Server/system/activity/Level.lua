--Level.lua
--/*-----------------------------------------------------------------
--* Module:  Level.lua
--* Author:  Andy
--* Modified: 2015年9月23日
--* Purpose: 等级礼包
-------------------------------------------------------------------*/

require ("base.class")
Level = class()

local prop = Property(Level)
prop:accessor("roleID")
prop:accessor("roleSID")

function Level:__init(roleID, roleSID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._datas = {
    	status = {},
    }
    self:initialize()
end

function Level:initialize()
	local player = g_entityMgr:getPlayer(self:getRoleID())
	local level = 0
	if player then level = player:getLevel() end
	for index, _ in pairs(g_DataMgr:getLevelConfig()) do
		if level >= index then
			self._datas.status[index] = 0
		else
			self._datas.status[index] = 1
		end
	end
end

function Level:redDot()
	for _, state in pairs(self._datas.status) do
		if state == 0 then
			return true
		end
	end
	return false
end

function Level:levelUp(level)
	for index, _ in pairs(g_DataMgr:getLevelConfig()) do
		if level >= index and self._datas.status[index] == 1 then
			self._datas.status[index] = 0
			self:cast2DB()
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end
end

function Level:req()
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if player then
		local levels = {}
		for index, reward in pairs(g_DataMgr:getLevelConfig()) do
			local data = {}
			data.level = index
			data.status = self._datas.status[index]
			data.reward = g_ActivityMgr:filterReward(player, reward)
			table.insert(levels, data)
		end
		local ret = {}
		ret.modelID = ACTIVITY_MODEL.LEVEL
		ret.activityID = ACTIVITY_LEVEL_ID
		ret.level = levels
		fireProtoMessage(self:getRoleID(), ACTIVITY_SC_RET, "ActivityRet", ret)
	end
end

function Level:reward(index)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if self._datas.status[index] ~= 0 or not player then
		return
	end
	local itemMgr = player:getItemMgr()
	if not itemMgr then
		return
	end
	local config = g_DataMgr:getLevelConfig() or {}
	local reward = g_ActivityMgr:filterReward(player, config[index])
	if g_ActivityMgr:isEmpty(reward) then
		return
	end
	local roleSID = self:getRoleSID()
	local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
	if table.size(reward) > emptySize then
		g_ActivityMgr:sendRewardByEmail(roleSID, reward, 65)
	else
		for _, item in pairs(reward) do
			itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind, 0, 0, item.strength)
			g_ActivityMgr:writeLog(roleSID, 1, 65, item.itemID, item.count, item.bind, player)
			g_ChatSystem:GetMoneyIntoChat(roleSID, item.itemID, item.count)
		end
		g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_SUCCESS, 0, {})
	end
	self._datas.status[index] = 2
	self:req()
	g_ActivityMgr:getActivityList(self:getRoleID())
	g_logManager:writeOpactivities(roleSID, ACTIVITY_LEVEL_ID, index, 2)
	self:cast2DB()
end

function Level:loadDBdata(datas)
	self._datas = datas
end

function Level:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), ACTIVITY_MODEL.LEVEL, ACTIVITY_LEVEL_ID, self._datas)
end