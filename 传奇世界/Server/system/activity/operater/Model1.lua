--Model1.lua
--/*-----------------------------------------------------------------
--* Module:  Model1.lua
--* Author:  Andy
--* Modified: 2016年05月24日
--* Purpose: 注册／登陆／在线类
--* 11: 登陆送奖励 13：累计登陆送 14：连续登陆送 16：指定时间段在线
-------------------------------------------------------------------*/

require ("base.class")
Model1 = class()

local prop = Property(Model1)
prop:accessor("modelID")
prop:accessor("activityID")
prop:accessor("roleID")
prop:accessor("roleSID")

function Model1:__init(modelID, activityID, roleID, roleSID)
    prop(self, "modelID", modelID)
    prop(self, "activityID", activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._datas = {}
	self._datas.read = true
	self:initialize()
end

function Model1:initialize()
	self._datas.status = 1		--活动领取状态（0：可领取 1：未达成 2：已领取）
	self._datas.time = 0		--状态改变时间
	self._datas.total = 0
end

function Model1:redDot()
	if self._datas.status == 0 or self._datas.read then
		return true
	end
	return false
end

function Model1:login()
	local now = os.time()
	local roleID = self:getRoleID()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if self._datas.status ~= 1 or not g_ActivityMgr:canJoinActivity(roleID, model) or isSameDay(now, self._datas.time) then
		return
	end
	if model.modelID == ACTIVITY_MODEL.LOGIN then
		self._datas.status = 0
	elseif model.modelID == ACTIVITY_MODEL.TOTAL_LOGIN then
		self._datas.total = self._datas.total + 1
		if self._datas.total >= model.arg1 then
			self._datas.status = 0
		end
	elseif model.modelID == ACTIVITY_MODEL.CONTINUOUS_LOGIN then
		if self._datas.time == 0 or dayBetween(now, self._datas.time) == 1 then
			self._datas.total = self._datas.total + 1
		else
			self._datas.total = 1
		end
		if self._datas.total >= model.arg1 then
			self._datas.status = 0
		end
	else
		return
	end
	self._datas.time = os.time()
	self:cast2DB()
	g_ActivityMgr:getActivityList(roleID)
end

function Model1:checkOnline()
	local roleID, now = self:getRoleID(), os.time()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if self._datas.status == 1 and g_ActivityMgr:canJoinActivity(roleID, model) and model.modelID == ACTIVITY_MODEL.SPECIFIC_ONLINE
		and model.cycleStartTime <= now and now <= model.cycleEndTime then
		self._datas.status = 0
		self._datas.time = now
		self:cast2DB()
		g_ActivityMgr:getActivityList(roleID)
	end
end

function Model1:req()
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or not model then
		return
	end
	local model1 = {}
	model1.status = self._datas.status
	model1.arg1 = model.arg1
	model1.progress = self._datas.total
	model1.cycleStartTime = model.cycleStartTime
	model1.cycleEndTime = model.cycleEndTime
	model1.reward = g_ActivityMgr:filterReward(player, model.itemList)
	local ret = {}
	ret.modelID = self:getModelID()
	ret.activityID = activityID
	ret.startTick = model.startTime
	ret.endTick = model.endTime
	ret.desc = model.desc
	ret.model1 = model1
	fireProtoMessage(roleID, ACTIVITY_SC_RET, "ActivityRet", ret)
	if self._datas.read then
		self._datas.read = false
		self:cast2DB()
	end
end

function Model1:reward()
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or self._datas.status ~= 0 or not model then
		return
	end
	local itemMgr = player:getItemMgr()
	if itemMgr then
		local rewards = g_ActivityMgr:filterReward(player, model.itemList)
		local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
		if #rewards > emptySize then
			g_ActivityMgr:sendRewardByEmail(self:getRoleSID(), rewards, 91)
		else
			g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_SUCCESS, 0, {})
			for _, item in pairs(rewards) do
				if item.itemID == ITEM_INGOT_ID then
					player:setIngot(player:getIngot() + item.count)
				elseif item.itemID == ITEM_BIND_INGOT_ID then
					player:setBindIngot(player:getBindIngot() + item.count)
				elseif item.itemID == ITEM_MONEY_ID then
					player:setMoney(player:getMoney() + item.count)
				else
					itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind)
				end
				-- g_ActivityMgr:writeLog(self:getRoleSID(), 1, 91, item.itemID, item.count, item.bind, player)
			end
		end
		self._datas.status = 2
		self._datas.time = os.time()
		self:cast2DB()
		g_ActivityMgr:getActivityList(roleID)
		g_logManager:writeOpactivities(self:getRoleSID(), self:getActivityID(), 0, 2)
		self:req()
	end
end

--重置状态
function Model1:resetStatus()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if g_ActivityMgr:canLoop(model, self._datas.time) then
		self:initialize()
	end
end

function Model1:loadDBdata(datas)
	self._datas = datas
	self:resetStatus()
end

function Model1:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), self:getModelID(), self:getActivityID(), self._datas)
end