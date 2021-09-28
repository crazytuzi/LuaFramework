--Model6.lua
--/*-----------------------------------------------------------------
--* Module:  Model6.lua
--* Author:  Andy
--* Modified: 2016年05月24日
--* Purpose: 充值类
--* 111：累积充值促销 112：首次充值x元赠送x奖励　113：消费返还活动
-------------------------------------------------------------------*/

require ("base.class")
Model6 = class()

local prop = Property(Model6)
prop:accessor("modelID")
prop:accessor("activityID")
prop:accessor("roleID")
prop:accessor("roleSID")

function Model6:__init(modelID, activityID, roleID, roleSID)
    prop(self, "modelID", modelID)
    prop(self, "activityID", activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._condition = 0		--领奖条件
	self._datas = {}
	self._datas.read = true
	self:initialize()
end

function Model6:initialize()
	self._datas.status = 1		--活动领取状态（0：可领取 1：未达成 2：已领取）
	self._datas.time = 0		--状态改变时间
	self._datas.total = 0		--累计充值/消费的金额
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if model and self._condition == 0 then
		if model.modelID == ACTIVITY_MODEL.FIRSTCHARGE then
			self._condition = 60
		else
			self._condition = model.arg1
		end
	end
end

function Model6:redDot()
	if self._datas.status == 0 or self._datas.read then
		return true
	end
	return false
end

--是否已经完成首冲
function Model6:finishFirstCharge()
	if self._datas.status == 2 then
		return true
	end
	return false
end

--玩家充值
function Model6:charge(ingot)
	local roleID = self:getRoleID()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if self._datas.status ~= 1 or ingot <= 0 or self._condition == 0 or not g_ActivityMgr:canJoinActivity(roleID, model) then
		return
	end
	local modelID = model.modelID
	if modelID == ACTIVITY_MODEL.FIRSTCHARGE or modelID == ACTIVITY_MODEL.TOTALCHARGE then
		self._datas.total = self._datas.total + ingot
		if self._datas.total >= self._condition then
			self._datas.status = 0
			if modelID == ACTIVITY_MODEL.FIRSTCHARGE then
				self:req()
			end
		end
	else
		return
	end
	self._datas.time = os.time()
	self:cast2DB()
	g_ActivityMgr:getActivityList(roleID)
end

--玩家消费
function Model6:consume(ingot)
	local roleID = self:getRoleID()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if self._datas.status == 1 and ingot > 0 and self._condition > 0 and g_ActivityMgr:canJoinActivity(roleID, model) and model.modelID == ACTIVITY_MODEL.PAY then
		self._datas.total = self._datas.total + ingot
		if self._datas.total >= self._condition then
			self._datas.status = 0
			self._datas.time = os.time()
			self:cast2DB()
			g_ActivityMgr:getActivityList(roleID)
		end
	end
end

function Model6:req()
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or not model then
		return
	end
	local model6 = {}
	model6.status = self._datas.status
	model6.arg1 = self._condition
	model6.progress = self._datas.total
	model6.reward = g_ActivityMgr:filterReward(player, model.itemList)
	local ret = {}
	ret.modelID = model.modelID
	ret.activityID = activityID
	ret.startTick = model.startTime
	ret.endTick = model.endTime
	ret.desc = model.desc
	ret.model6 = model6
	fireProtoMessage(roleID, ACTIVITY_SC_RET, "ActivityRet", ret)
	if self._datas.read then
		self._datas.read = false
		self:cast2DB()
	end
end

function Model6:reward()
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
		g_logManager:writeOpactivities(self:getRoleSID(), activityID, 0, 2)
		self:req()
	end
end

--重置状态
function Model6:resetStatus()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if g_ActivityMgr:canLoop(model, self._datas.time) then
		self:initialize()
	end
end

function Model6:loadDBdata(datas)
	self._datas = datas
	self:resetStatus()
end

function Model6:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), self:getModelID(), self:getActivityID(), self._datas)
end