--Model8.lua
--/*-----------------------------------------------------------------
--* Module:  Model8.lua
--* Author:  Andy
--* Modified: 2016年05月24日
--* Purpose: 分段类
--* 151：在线时长奖励 152：累计充值分段奖励 154：累计击杀怪物数 156.角色等级分段奖励
-------------------------------------------------------------------*/

require ("base.class")
require ("system.task.RewardTask")
require ("system.task.TaskConstant")

Model8 = class()

local prop = Property(Model8)
prop:accessor("modelID")
prop:accessor("activityID")
prop:accessor("roleID")
prop:accessor("roleSID")
prop:accessor("loadDB", false)

function Model8:__init(modelID, activityID, roleID, roleSID)
    prop(self, "modelID", modelID)
    prop(self, "activityID", activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._onlineCheckTimes = 0	--统计在线活动累计时间次数，达到指定次数后存玩家数据

	self._datas = {}
	self._datas.read = true
	self:initialize()
end

function Model8:initialize()
	self._datas.status = {}		--活动领取状态（0：可领取 1：未达成 2：已领取）
	self._datas.time = 0		--状态改变时间
	self._datas.total = 0		--累计值
	self._datas.lastOnline = 0	--上次统计在线的时间戳
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not model then
		return
	end
	for index, _ in pairs(model.itemList or {}) do
		self._datas.status[index] = 1
	end
end

function Model8:redDot()
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

function Model8:levelUp(level)
	if not self:getLoadDB() then
		return
	end
	local roleID = self:getRoleID()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(roleID, model) or model.modelID ~= ACTIVITY_MODEL.LEVEL_ACTIVITY then
		return
	end
	local achieve = false
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and level >= index then
			self._datas.status[index] = 0
			achieve = true
		end
	end
	if achieve then
		self._datas.time = os.time()
		self:cast2DB()
		g_ActivityMgr:getActivityList(roleID)
	end
end

--玩家充值
function Model8:charge(moeny)
	local roleID = self:getRoleID()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if moeny <= 0 or not g_ActivityMgr:canJoinActivity(roleID, model) or model.modelID ~= ACTIVITY_MODEL.TOTALCHARGE2 then
		return
	end
	self._datas.total = self._datas.total + moeny
	local achieve = false
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			achieve = true
			self._datas.status[index] = 0
			self._datas.time = os.time()
			self:cast2DB()
		end
	end
	if achieve then
		g_ActivityMgr:getActivityList(roleID)
	end
end

function Model8:checkOnline(logout)
	local roleID = self:getRoleID()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(roleID, model) or model.modelID ~= ACTIVITY_MODEL.ONLINE_ACTIVITY then
		return
	end
	local isFinish = true
	for _, status in pairs(self._datas.status) do
		if status == 1 then
			isFinish = false
			break
		end
	end
	if isFinish then
		return
	end
	local now = os.time()
	if self._datas.lastOnline == 0 then
		self._datas.lastOnline = now
		return
	end
	self._datas.total = self._datas.total + (now - self._datas.lastOnline)
	self._datas.lastOnline = now
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			self._datas.status[index] = 0
			self._datas.time = now
			self:cast2DB()
			g_ActivityMgr:getActivityList(roleID)
		end
	end
	self._onlineCheckTimes = self._onlineCheckTimes + 1
	if logout or self._onlineCheckTimes > 12 then
		self:cast2DB()
		self._onlineCheckTimes = 0
	end
end

function Model8:playerLogout()
	self:checkOnline(true)
end

function Model8:req()
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or not model then
		return
	end
	local model8 = {}
	for index, reward in pairs(model.itemList) do
		local data = {}
		data.status = self._datas.status[index]
		data.index = index
		data.progress = self._datas.total
		data.reward = g_ActivityMgr:filterReward(player, reward)
		table.insert(model8, data)
	end
	local ret = {}
	ret.modelID = model.modelID
	ret.activityID = activityID
	ret.startTick = model.startTime
	ret.endTick = model.endTime
	ret.desc = model.desc
	ret.model8 = model8
	fireProtoMessage(roleID, ACTIVITY_SC_RET, "ActivityRet", ret)
	if self._datas.read then
		self._datas.read = false
		self:cast2DB()
	end
end

function Model8:reward(index)
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
end

--玩家杀怪
function Model8:killMonster(monsterSID, monsterID, level)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if not g_ActivityMgr:canJoinActivity(self:getRoleID(), model) or model.modelID ~= ACTIVITY_MODEL.TOTAL_KILL_MONSTER then
		return
	end
	if model.arg1 > level and not table.contains(model.args, monsterSID) then
		return
	end
	self._datas.total = self._datas.total + 1
	local achieve = false
	for index, _ in pairs(model.itemList or {}) do
		if self._datas.status[index] == 1 and self._datas.total >= index then
			achieve = true
			self._datas.status[index] = 0
		end
	end
	if achieve then
		g_ActivityMgr:getActivityList(self:getRoleID())
	end
	self._datas.time = os.time()
	self:cast2DB()
end

--重置状态
function Model8:resetStatus()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if g_ActivityMgr:canLoop(model, self._datas.time) then
		self:initialize()
	end
end

function Model8:loadDBdata(datas)
	self._datas = datas
	self._datas.lastOnline = os.time()
	self._datas.total = math.max(0, self._datas.total)
	self:setLoadDB(true)
	self:resetStatus()
end

function Model8:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), self:getModelID(), self:getActivityID(), self._datas)
end