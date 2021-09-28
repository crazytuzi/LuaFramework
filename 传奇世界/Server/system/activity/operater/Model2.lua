--Model2.lua
--/*-----------------------------------------------------------------
--* Module:  Model2.lua
--* Author:  Andy
--* Modified: 2016年05月24日
--* Purpose: 出售类
--* 31：购买资源打折
-------------------------------------------------------------------*/

require ("base.class")
Model2 = class()

local prop = Property(Model2)
prop:accessor("modelID")
prop:accessor("activityID")
prop:accessor("roleID")
prop:accessor("roleSID")

function Model2:__init(modelID, activityID, roleID, roleSID)
    prop(self, "modelID", modelID)
    prop(self, "activityID", activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._datas = {}
	self._datas.read = true
	self:initialize()
end

function Model2:initialize()
	self._datas.status = {}
	self._datas.time = 0		--状态改变时间
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not model then
		return
	end
	for index, _ in pairs(model.discountList or {}) do
		self._datas.status[index] = 1
	end
end

function Model2:redDot()
	--[[
	if self._datas.read then
		return true
	end
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not model or not player then
		return
	end
	for index, config in pairs(model.discountList or {}) do
		if self._datas.status[index] == 1 and ((config.disType == 1 and player:getIngot() >= config.disPrice) or (config.disType == 2 and player:getBindIngot() >= config.disPrice) or
			(config.disType == 3 and player:getMoney() >= config.disPrice)) then
			return true
		end
	end
	]]
	return false
end

function Model2:canBuy(index)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not model or not player then
		return false
	end
	local config = model.discountList[index]
	if config and self._datas.status[index] ~= 2 and ((config.disType == 1 and player:getIngot() >= config.disPrice) or (config.disType == 2 and player:getBindIngot() >= config.disPrice) or
		(config.disType == 3 and player:getMoney() >= config.disPrice)) then
		return true
	end
	return false
end

function Model2:req()
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or not model then
		return
	end
	local model2 = {}
	for index, config in pairs(model.discountList) do
		local data = {}
		data.index = index
		data.status = self._datas.status[index]
		if data.status ~= 2 then
			if self:canBuy(index) then
				data.status = 0
			else
				data.status = 1
			end
		end
		data.groupName = config.groupName
		data.oldType = config.oldType
		data.oldPrice = config.oldPrice
		data.disType = config.disType
		data.disPrice = config.disPrice
		data.disDesc = config.disDesc
		data.reward = g_ActivityMgr:filterReward(player, config.itemList)
		table.insert(model2, data)
	end
	local ret = {}
	ret.modelID = self:getModelID()
	ret.activityID = activityID
	ret.startTick = model.startTime
	ret.endTick = model.endTime
	ret.desc = model.desc
	ret.model2 = model2
	fireProtoMessage(roleID, ACTIVITY_SC_RET, "ActivityRet", ret)
	if self._datas.read then
		self._datas.read = false
		self:cast2DB()
	end
end

function Model2:reward(index)
	local roleID = self:getRoleID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not player or self._datas.status[index] == 2 or not self:canBuy(index) or not model then
		return
	end
	local config = model.discountList[index]
	if config then
		if config.disType == 1 and isIngotEnough(player, config.disPrice) then
			local context = {roleID = roleID, modelID = self:getModelID(), activityID = self:getActivityID(), index = index}
			local ret = g_tPayMgr:TPayScriptUseMoney(player, config.disPrice, 43, "", 0, 0, "ActivityManager.costIngotCallback", serialize(context))
			-- if ret == 0 then
			-- 	print("Success")
			-- else
			-- 	print("error")
			-- end
		elseif config.disType == 2 and player:getBindIngot() >= config.disPrice then
			player:setBindIngot(player:getBindIngot() - config.disPrice)
			self:rewardCallBack(index)
		elseif config.disType == 3 and isMoneyEnough(player, config.disType) then
			if costMoney(player, config.disPrice, 43) then
				self:rewardCallBack(index)
			end
		end
	end
end

function Model2:rewardCallBack(index)
	local ret = TPAY_FAILED
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or self._datas.status[index] == 2 or not self:canBuy(index) or not model then
		return ret
	end
	local itemMgr = player:getItemMgr()
	if itemMgr then
		local rewards = g_ActivityMgr:filterReward(player, model.discountList[index].itemList)
		local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
		if #rewards > emptySize then
			g_ActivityMgr:sendRewardByEmail(self:getRoleSID(), rewards, 91)
		else
			g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_BUY_SUCCESS, 0, {})
			for _, item in pairs(rewards) do
				itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind)
				-- g_ActivityMgr:writeLog(self:getRoleSID(), 1, 91, item.itemID, item.count, item.bind, player)
			end
		end
		self._datas.status[index] = 2
		self._datas.time = os.time()
		self:cast2DB()
		g_ActivityMgr:getActivityList(roleID)
		g_logManager:writeOpactivities(self:getRoleSID(), activityID, 0, 2)
		self:req()
		ret = TPAY_SUCESS
	end
	return ret
end

--重置状态
function Model2:resetStatus()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if g_ActivityMgr:canLoop(model, self._datas.time) then
		self:initialize()
	end
end

function Model2:loadDBdata(datas)
	self._datas = datas
	self:resetStatus()
end

function Model2:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), self:getModelID(), self:getActivityID(), self._datas)
end