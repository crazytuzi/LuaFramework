--Model5.lua
--/*-----------------------------------------------------------------
--* Module:  Model5.lua
--* Author:  Andy
--* Modified: 2016年05月24日
--* Purpose: 兑换类
--* 91：上交指定物品集齐送礼
-------------------------------------------------------------------*/

require ("base.class")
Model5 = class()

local prop = Property(Model5)
prop:accessor("modelID")
prop:accessor("activityID")
prop:accessor("roleID")
prop:accessor("roleSID")

function Model5:__init(modelID, activityID, roleID, roleSID)
    prop(self, "modelID", modelID)
    prop(self, "activityID", activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._datas = {}
	self._datas.read = true
	self:initialize()
end

function Model5:initialize()
	self._datas.status = {}
	self._datas.time = 0		--状态改变时间
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not model then
		return
	end
	for index, _ in pairs(model.exchangeList) do
		self._datas.status[index] = 1
	end
end

function Model5:redDot()
	if self._datas.read then
		return true
	end
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if model then
		for index, config in pairs(model.exchangeList) do
			if self._datas.status[index] == 1 and self:exchangeValid(index) then
				return true
			end
		end
	end
	return false
end

--兑换所需要的材料是否足够
function Model5:exchangeValid(index)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not player or not model then
		return false
	end
	local itemMgr = player:getItemMgr()
	if not itemMgr then
		return false
	end
	local config = model.exchangeList[index]
	if not config then
		return false
	end
	local items = {}
	for _, item in pairs(config.needItemList) do
		local itemID = item.itemID
		items[itemID] = (items[itemID] or 0) + item.count
	end
	for itemID, count in pairs(items) do
		local num = 0		-- 持有的道具数量
		if itemID == ITEM_INGOT_ID then
			num = player:getIngot()
		elseif itemID == ITEM_BIND_INGOT_ID then
			num = player:getBindIngot()
		elseif itemID == ITEM_MONEY_ID then
			num = player:getMoney()
		else
			num = itemMgr:getItemCount(itemID)
		end
		if num < count then
			return false
		end
	end
	return true
end

function Model5:req()
	local roleID = self:getRoleID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not player or not model then
		return
	end
	local model5 = {}
	for index, config in pairs(model.exchangeList) do
		local data = {}
		data.index = index
		data.status = self._datas.status[index]
		if data.status ~= 2 then
			if self:exchangeValid(index) then
				data.status = 0
			else
				data.status = 1
			end
		end
		data.need = {}
		for _, item in pairs(config.needItemList) do
			local tmp = {}
			tmp.itemID = item.itemID
			tmp.count = item.count
			tmp.bind = item.bind
			table.insert(data.need, tmp)
		end
		data.reward = g_ActivityMgr:filterReward(player, config.givenItemList)
		table.insert(model5, data)
	end
	local ret = {}
	ret.modelID = self:getModelID()
	ret.activityID = self:getActivityID()
	ret.startTick = model.startTime
	ret.endTick = model.endTime
	ret.desc = model.desc
	ret.model5 = model5
	fireProtoMessage(roleID, ACTIVITY_SC_RET, "ActivityRet", ret)
	if self._datas.read then
		self._datas.read = false
		self:cast2DB()
	end
end

function Model5:reward(index)
	local roleID = self:getRoleID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not player or self._datas.status[index] == 2 or not self:exchangeValid(index) or not model then
		return
	end
	local config = model.exchangeList[index]
	if config then
		local ingot = 0
		for _, item in pairs(config.needItemList) do
			if item.itemID == ITEM_INGOT_ID then
				ingot = ingot + item.count
			end
		end
		if ingot > 0 then
			local context = {roleID = roleID, modelID = self:getModelID(), activityID = self:getActivityID(), index = index}
			local ret = g_tPayMgr:TPayScriptUseMoney(player, ingot, 42, "", 0, 0, "ActivityManager.costIngotCallback", serialize(context))
			-- if ret == 0 then
			-- 	print("Success")
			-- else
			-- 	print("error")
			-- end
		else
			self:rewardCallBack(index)
		end
	end
end

function Model5:rewardCallBack(index)
	local ret = TPAY_FAILED
	local roleID = self:getRoleID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not player or self._datas.status[index] == 2 or not self:exchangeValid(index) or not model then
		return
	end
	local config = model.exchangeList[index]
	local itemMgr = player:getItemMgr()
	if config and itemMgr then
		local roleSID = self:getRoleSID()
		for _, item in pairs(config.needItemList) do
			if item.itemID == ITEM_INGOT_ID then
			elseif item.itemID == ITEM_BIND_INGOT_ID then
				player:setBindIngot(player:getBindIngot() - item.count)
				g_logManager:writeMoneyChange(roleSID, "", 4, 42, player:getBindIngot(), -item.count, 2)
			elseif item.itemID == ITEM_MONEY_ID then
				player:setMoney(player:getMoney() - item.count)
				g_logManager:writeMoneyChange(roleSID, "", 1, 42, player:getMoney(), -item.count, 2)
			else
				local ret, errorCode = itemMgr:destoryItem(item.itemID, item.count, 0)
				g_logManager:writePropChange(roleSID, 2, 42, item.itemID, 0, item.count, item.bind)
			end
		end
		local rewards = g_ActivityMgr:filterReward(player, config.givenItemList)
		local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
		if #rewards > emptySize then
			g_ActivityMgr:sendRewardByEmail(roleSID, rewards, 91)
		else
			g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_SUCCESS, 0, {})
			for _, item in pairs(rewards) do
				if item.itemID == ITEM_INGOT_ID then
				elseif item.itemID == ITEM_BIND_INGOT_ID then
					player:setBindIngot(player:getBindIngot() + item.count)
					g_logManager:writeMoneyChange(roleSID, "", 4, 42, player:getBindIngot(), item.count, 1)
				elseif item.itemID == ITEM_MONEY_ID then
					player:setMoney(player:getMoney() + item.count)
					g_logManager:writeMoneyChange(roleSID, "", 1, 42, player:getMoney(), item.count, 1)
				else
					itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind)
					-- g_ActivityMgr:writeLog(self:getRoleSID(), 1, 91, item.itemID, item.count, item.bind, player)
				end
			end
		end
		self._datas.status[index] = 2
		self._datas.time = os.time()
		self:cast2DB()
		g_ActivityMgr:getActivityList(roleID)
		g_logManager:writeOpactivities(roleSID, self:getActivityID(), 0, 2)
		self:req()
		ret = TPAY_SUCESS
	end
	return ret
end

--重置状态
function Model5:resetStatus()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if g_ActivityMgr:canLoop(model, self._datas.time) then
		self:initialize()
	end
end

function Model5:loadDBdata(datas)
	self._datas = datas
	self:resetStatus()
end

function Model5:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), self:getModelID(), self:getActivityID(), self._datas)
end