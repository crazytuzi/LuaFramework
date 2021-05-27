--------------------------------------------------------
-- 神鼎数据
--------------------------------------------------------
ShenDingData = ShenDingData or BaseClass()

ShenDingData.TASK_DATA_CHANGE = "task_data_change"

function ShenDingData:__init()
	if ShenDingData.Instance then
		ErrorLog("[ShenDingData]:Attempt to create singleton twice!")
	end
	ShenDingData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.task_list = {} --活跃任务列表
	self.rew_state = 0 --活跃度奖励领取状态

	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.ShenDingCanUp)
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_ACTIVITY, BindTool.Bind(self.OnActorActivityChange, self))
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShenDingCanUp)
end

function ShenDingData:__delete()
	ShenDingData.Instance = nil

	self.task_list = nil
end

----------神鼎等级----------

-- 获取神鼎数据 .level总等级 .phase神鼎阶数 .child_level神鼎等级
function ShenDingData.GetData()
	local data = {}
	data.level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_TRIPOD_LEVEL)

	-- 算出神鼎阶数和神鼎等级
	data.child_level = data.level == 0 and 0 or (data.level % 20 == 0 and 20 or data.level % 20) -- 0级时返回0,(level%20)为0时返回20,否则,返回(level%20)
	data.phase = (data.level - data.child_level) / 20 + 1 -- 先减去当阶的等级再除于6加1,得出神鼎阶数

	return data
end

-- 获取神鼎阶数
function ShenDingData.GetPhase()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_TRIPOD_LEVEL)
	local child_level = level == 0 and 0 or (level % 20 == 0 and 20 or level % 20)
	local phase = (level - child_level) / 20 + 1

	return phase
end

-- 获取当前神鼎等级
function ShenDingData.GetgChildLevel()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_TRIPOD_LEVEL)
	local child_level = level == 0 and 0 or (level % 20 == 0 and 20 or level % 20)
	return child_level
end

---------end-----------

---------活跃任务-----------

-- 设置活跃任务数据
function ShenDingData:SetTaskList(protocol)
	-- 接收数据时,不对参数进行提取和排序
	self.task_list = protocol.task_list
	self.rew_state = protocol.rew_state
	self:DispatchEvent(ShenDingData.TASK_DATA_CHANGE)
end

-- 设置活跃任务数据改变
function ShenDingData:SetTaskListChange(protocol)
	self.task_list[protocol.index + 1].comtime = protocol.com_num
	self.task_list[protocol.index + 1].protime = protocol.done_num
	self:DispatchEvent(ShenDingData.TASK_DATA_CHANGE)
end

-- 获取任务数据
function ShenDingData:GetTaskList()
	local task_list = {}
	local finshed = {} -- 已完成的任务

	-- 将已完成的任务排在后面
	for k, v in ipairs(self.task_list) do
		if ActivityAllConfig.tasklist then
			if ActivityAllConfig.tasklist[k].score ~= 0 then
				if v.comtime >= ActivityAllConfig.tasklist[k].limitTimes then
					finshed[#finshed + 1] = {["times"] = v.comtime, ["index"] =  k}
				else
					task_list[#task_list + 1] = {["times"] = v.comtime, ["index"] =  k}
				end
			end
		end
	end
	for k, v in ipairs(finshed) do
		task_list[#task_list + 1] = v
	end

	return task_list
end

function ShenDingData:SetActRewacdStatr(protocol)
	self.rew_state = protocol.receive_state

	self:DispatchEvent(ShenDingData.TASK_DATA_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShenDingCanUp)
end

-- 获取奖励是否领取
function ShenDingData:GetIsRewIndex()
	local index = {}
	local index_item = bit:d2b(self.rew_state)
	
	for k, v in pairs(index_item) do
		if (33 - k) <= 6 then
			local vo = {
				index = 33 - k,
				state = v,
			}
			table.insert(index, vo)
		end
	end
	return index
end

-- 获取领取显示
function ShenDingData:GetRewaedIndex()
	local data = ShenDingData.Instance:GetTaskList()
	local index = 0
	local rew_index = 1
	for k, v in pairs(data) do
		local times2 = ActivityAllConfig.tasklist[v.index].limitTimes -- 需完成的次数
		local score = ActivityAllConfig.tasklist[v.index].score -- 活跃点
		index = index + score * v.times
	end

	local rew_data = ShenDingData.Instance:GetIsRewIndex()

	for k1, v1 in pairs(rew_data) do
		local score = ActivityAllConfig.awardslist[v1.index].needScore
		if score <= index and v1.state == 0 then
			rew_index = v1.index
		end
	end
	return rew_index
end

----------end----------

----------红点提示----------

function ShenDingData.OnActorActivityChange()
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShenDingCanUp)
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function ShenDingData.GetRemindIndex()

	local data = ShenDingData.Instance:GetTaskList()
	local index = 0
	local state = 0
	for k, v in pairs(data) do
		local times2 = ActivityAllConfig.tasklist[v.index].limitTimes -- 需完成的次数
		local score = ActivityAllConfig.tasklist[v.index].score -- 活跃点
		index = index + score * v.times
	end

	local rew_item = ShenDingData.Instance:GetIsRewIndex()
	for k1, v1 in pairs(rew_item) do
		local score = ActivityAllConfig.awardslist[v1.index].needScore
		if score <= index and v1.state == 0 then
			state = 1
		end
	end
	
	return state
end

----------end----------