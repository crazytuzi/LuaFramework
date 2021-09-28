--Model4.lua
--/*-----------------------------------------------------------------
--* Module:  Model4.lua
--* Author:  Andy
--* Modified: 2016年05月24日
--* Purpose: 达标类
--* 71：副本累计参与送　72：世界BOSS参与送　73：熔炼N次返利 74：熔炼指定部位返利 75：强化N次返利 76：强化指定部位返利 78：任务送
--* 77：组队击杀指定怪物
-------------------------------------------------------------------*/

require ("base.class")
Model4 = class()

local prop = Property(Model4)
prop:accessor("modelID")
prop:accessor("activityID")
prop:accessor("roleID")
prop:accessor("roleSID")

function Model4:__init(modelID, activityID, roleID, roleSID)
    prop(self, "modelID", modelID)
    prop(self, "activityID", activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._datas = {}
	self._datas.read = true
	self:initialize()
end

function Model4:initialize()
	self._datas.status = {}		--活动领取状态（0：可领取 1：未达成 2：已领取）
	self._datas.time = 0		--状态改变时间
	self._datas.total = 0		--累计充值/消费的金额
	self._datas.taskFinish = 0	--悬赏任务完成次数
	self._datas.bossTime = 0	--打世界boss的时间
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if model then
		for index, _ in pairs(model.itemList or {}) do
			self._datas.status[index] = 1
		end
	end
end

function Model4:redDot()
	if self._datas.read then
		return true
	end
	for _, state in pairs(self._datas.status) do
		if state == 0 then
			return true
		end
	end
	return false
end

function Model4:joinWorldBoss(monsterSID)
	local roleID = self:getRoleID()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(roleID, model) or model.modelID ~= ACTIVITY_MODEL.JOIN_WORLD_BOSS or not table.contains(model.args, monsterSID) then
		return
	end
	local startTime = g_normalLimitMgr:getNowWorldBossStartTime(ACTIVITY_NORMAL_ID.WORLD_BOSS)
	if startTime == 0 or startTime == self._datas.bossTime then
		return
	end
	self._datas.bossTime = startTime
	self._datas.total = self._datas.total + 1
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(roleID)
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end

function Model4:finishCopy(copyID)
	local roleID = self:getRoleID()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(roleID, model) or model.modelID ~= ACTIVITY_MODEL.TOTAL_JOIN_COPY or not table.contains(model.args, copyID) then
		return
	end
	self._datas.total = self._datas.total + 1
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(roleID)
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end

function Model4:req()
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or not model then
		return
	end
	local model4 = {}
	for index, reward in pairs(model.itemList) do
		local data = {}
		data.status = self._datas.status[index]
		data.index = index
		data.progress = self._datas.total
		data.reward = g_ActivityMgr:filterReward(player, reward)
		table.insert(model4, data)
	end
	local ret = {}
	ret.modelID = model.modelID
	ret.activityID = activityID
	ret.startTick = model.startTime
	ret.endTick = model.endTime
	ret.desc = model.desc
	ret.model8 = model4
	fireProtoMessage(roleID, ACTIVITY_SC_RET, "ActivityRet", ret)
	if self._datas.read then
		self._datas.read = false
		self:cast2DB()
	end
end

function Model4:reward(index)
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or self._datas.status[index] ~= 0 or not model then
		return
	end
	local itemMgr = player:getItemMgr()
	if itemMgr then
		local rewards = g_ActivityMgr:filterReward(player, model.itemList[index])
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
		self._datas.status[index] = 2
		self._datas.time = os.time()
		self:cast2DB()
		g_ActivityMgr:getActivityList(roleID)
		g_logManager:writeOpactivities(self:getRoleSID(), activityID, 0, 2)
		self:req()
	end
	self._datas.time = os.time()
	self:cast2DB()
end

function Model4:onEquipSmelter()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(self:getRoleID(), model) or model.modelID ~= ACTIVITY_MODEL.SMELT then
		return
	end
	self._datas.total = self._datas.total + 1
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end

function Model4:onEquipSmelterSpecial(pos)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(self:getRoleID(), model) or model.modelID ~= ACTIVITY_MODEL.SMELT_SPECIAL or not table.contains(model.args, pos) then
		return
	end
	self._datas.total = self._datas.total + 1
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end

function Model4:onEquipStrength()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(self:getRoleID(), model) or model.modelID ~= ACTIVITY_MODEL.STRENGTHEN then
		return
	end
	self._datas.total = self._datas.total + 1
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end

function Model4:onEquipStrengthSpecial(pos)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(self:getRoleID(), model) or model.modelID ~= ACTIVITY_MODEL.STRENGTHEN_SPECIAL or not table.contains(model.args, pos) then
		return
	end
	self._datas.total = self._datas.total + 1
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end

function Model4:onEquipBaptize()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(self:getRoleID(), model) or model.modelID ~= ACTIVITY_MODEL.BAPTIZE then
		return
	end
	self._datas.total = self._datas.total + 1
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end

function Model4:onEquipBaptizeSpecial(pos)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(self:getRoleID(), model) or model.modelID ~= ACTIVITY_MODEL.BAPTIZE_SPECIAL or not table.contains(model.args, pos) then
		return
	end
	self._datas.total = self._datas.total + 1
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end

--任务送
function Model4:OnTask(taskId, taskType, taskLevel, operateType)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(self:getRoleID(), model) or model.modelID ~= ACTIVITY_MODEL.TASK then
		return
	end
	if TaskType.Daily == taskType then
		if model.arg2 == 11 or ( model.arg2 == 12 and table.contains(model.args, taskId)) then
			self._datas.total = self._datas.total + 1
		end
	elseif TaskType.Reward == taskType then
		if (model.arg2 == 21 and taskLevel == REWARDTASK_RANK_BLUE)
		 or (model.arg2 == 31 and taskLevel == REWARDTASK_RANK_PURPLE)
		 or (model.arg2 == 41 and taskLevel == REWARDTASK_RANK_SUPER)
		 or (model.arg2 == 22 and taskLevel == REWARDTASK_RANK_BLUE and table.contains(model.args, taskId)) 
		 or (model.arg2 == 32 and taskLevel == REWARDTASK_RANK_PURPLE and table.contains(model.args, taskId))
		 or (model.arg2 == 42 and taskLevel == REWARDTASK_RANK_SUPER and table.contains(model.args, taskId)) then
			if operateType == ACTIVITY_TASK_OPERATE.PUBLISH_GET_REWARD then
				self._datas.total = self._datas.total + 1
			elseif operateType == ACTIVITY_TASK_OPERATE.FINISH_GET_REWARD then
				self._datas.taskFinish = self._datas.taskFinish + 1
			end
		end
	end
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end
	self._datas.time = os.time()
	self:cast2DB()
end


--重置状态
function Model4:resetStatus()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if g_ActivityMgr:canLoop(model, self._datas.time) then
		self:initialize()
	end
end

function Model4:loadDBdata(datas)
	self._datas = datas
	self:resetStatus()
end

function Model4:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), self:getModelID(), self:getActivityID(), self._datas)
end