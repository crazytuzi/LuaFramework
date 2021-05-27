
TaskData = TaskData or BaseClass(BaseData)

TaskData.IsMonsterTask = {[45] = true, [59] = true, [70] = true, [73] = true}

-- 客户端主动触发事件
TaskData.CLIENT_TRIGGER_EVENT = {
	ONE_KEY_EQUIP = 1 -- 一键换装
}

-- 事件
TaskData.ON_TASK_LIST = "ON_TASK_LIST"
TaskData.ADD_ONE_TASK = "ADD_ONE_TASK"
TaskData.FINISH_ONE_TASK = "FINISH_ONE_TASK"
TaskData.GIVEUP_ONE_TASK = "GIVEUP_ONE_TASK"
TaskData.ON_ACCEPT_LIST = "ON_ACCEPT_LIST"
TaskData.ADD_ACCEPT_LIST = "ADD_ACCEPT_LIST"
TaskData.REMOVE_ACCEPT = "REMOVE_ACCEPT"
TaskData.TASK_VALUE_CHANGE = "TASK_VALUE_CHANGE"
TaskData.TIANSHU_NUM = "TIANSHU_NUM"

function TaskData:__init()
	if TaskData.Instance ~= nil then
		ErrorLog("[TaskData] attempt to create singleton twice!")
		return
	end
	TaskData.Instance = self

	self.task_list = {}					-- 已接任务列表，内容参看 CommonReader.ReadTaskInfo()
	self.accept_task_list = {}			-- 可接任务列表


	------------------------------------------------------------ 以下废弃
	self.task_state_list = {}			-- 任务状态顺序列表
	self.task_state_t = {}				-- 任务状态顺序列表 {task_id = {task_state = xx, show_order = xx}, ...}

	self.task_id = 0                    --记录任务ID
	self.double_reward_coefficient = 0
	self.quick_finish_coefficient = 0
	self.accept_again_coefficient = 0
	
	self.callback_list = {}
	
	self.mark_task_no_complete_list = {}
	self.mark_old_accept_task_list = {}
	self.mark_task_do_count_list = {}

	self.had_compelete_num = 0
	self.buy_time = 0
end

function TaskData:__delete()
	TaskData.Instance = nil
end

--------------------------------------------------------
function TaskData:OnTaskList(task_list)
	self.task_list = {}
	--PrintTable(task_list)
	for _, v in pairs(task_list) do
		self.task_list[v.task_id] = v
		if v.task_type == 0 then
			self.task_id = v.task_id
		end
	end
	self:DispatchEvent(TaskData.ON_TASK_LIST)
end

function TaskData:AddTask(task_info)
	self.task_list[task_info.task_id] = task_info
	self.accept_task_list[task_info.task_id] = nil
	self.task_id = task_info.task_id
	self:DispatchEvent(TaskData.ADD_ONE_TASK, task_info)
end

function TaskData:RemoveTask(task_id, event_id)
	local task_info = self.task_list[task_id]
	if nil ~= task_info then
		self.task_list[task_id] = nil
	end
	self:DispatchEvent(event_id, task_info)
end

function TaskData:OnAcceptTaskList(accept_task_list)
	self.accept_task_list = {}
	for i, v in pairs(accept_task_list) do
		self.accept_task_list[v.task_id] = v
	end

	self:DispatchEvent(TaskData.ON_ACCEPT_LIST)
end

function TaskData:RemoveAcceptTask(task_id)
	if not task_id then return end
	self.accept_task_list[task_id] = nil

	self:DispatchEvent(TaskData.REMOVE_ACCEPT, task_id)
end

function TaskData:OnAddAcceptTaskList(accept_task_list)
	for i, v in pairs(accept_task_list) do
		self.accept_task_list[v.task_id] = v
	end

	self:DispatchEvent(TaskData.ADD_ACCEPT_LIST, task_id)
end

function TaskData:SetTitle(task_id, title)
	if nil ~= self.task_list[task_id] then
		self.task_list[task_id].title = title
	elseif nil ~= self.accept_task_list[task_id] then
		self.accept_task_list[task_id].title = title
	end

	self:DispatchEvent(TaskData.TASK_VALUE_CHANGE, task_id)
end

function TaskData:SetCurValue(task_id, target_index, cur_value)
	local task_info = self.task_list[task_id]
	if nil ~= task_info then
		for k, v in pairs(task_info.targets) do
			if v.target_index == target_index then
				if task_info.target then
					task_info.target.cur_value = task_info.target.cur_value + (cur_value - v.cur_value)
				end
				v.cur_value = cur_value
			end
		end
	elseif nil ~= self.accept_task_list[task_id] and self.accept_task_list[task_id].target then
		self.accept_task_list[task_id].target.cur_value = cur_value
	end

	self:DispatchEvent(TaskData.TASK_VALUE_CHANGE, task_id)
end
--------------------------------------------------------
-- 正在进行中的任务
function TaskData:GetTaskList()
	return self.task_list
end

-- 任务的信息
function TaskData:GetTaskInfo(task_id)
	return self.task_list[task_id] or self.accept_task_list[task_id]
end

-- 主线
function TaskData:GetMainTaskInfo()
	for k, v in pairs(self.task_list) do
		if v.task_type == TaskType.Main then
			return v
		end
	end
end


-- 任务状态
function TaskData:GetTaskStateById(task_id)
	return self:GetTaskState(self:GetTaskInfo(task_id))
end

-- 任务状态
function TaskData:GetTaskState(task_data)
	if nil ~= task_data and nil ~= task_data.target then
		if task_data.target.cur_value >= task_data.target.target_value then
			return TaskState.Complete
		else
			return TaskState.NotComplete
		end
	end
	return TaskState.NotComplete
end

function TaskData:GetCurTaskId()
	-- print(self.accept_task_list)
	-- PrintTable(self.accept_task_list)
	return self.task_id
end

--天书任务完成次数
function TaskData:SetHadCompeleteTime(protocol)
	self.had_compelete_num = protocol.complete_time
	self.buy_time = protocol.buy_time
	GlobalEventSystem:Fire(TIANSHUTASK_EVENT.NUM_CHANGE)
	self:DispatchEvent(TaskData.TIANSHU_NUM)
end

--获得完成次数
function TaskData:GetHadCompeleteNum()
	return self.had_compelete_num, self.buy_time
end

function TaskData:GetConfigDataItemData()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local data = {}
	for k, v in pairs(TianShuRenWuConfig.AwardsTb) do
		if v.circle == 0 then
			if level >= v.level then
				data = v.awards
			end
		elseif v.level == 0 then
			if circle >= v.circle then
				data = v.awards
			end
		end
	end
	if TianShuRenWuConfig.extraAwards then
		table.insert(data, TianShuRenWuConfig.extraAwards.award)
	end
	return data
end

function TaskData:GetRemianNum()
	local had_num = TianShuRenWuConfig.daylimit + self.buy_time
	local remian_num = (had_num - self.had_compelete_num) > 0 and (had_num - self.had_compelete_num) or 0
	return remian_num
end

function TaskData:GetConsumeId()
	return TianShuRenWuConfig.getAwardsType[1].consume[1].id
end
----------------------------------------------------------------------------------
-- function TaskData:OnTaskList(task_list)
-- 	self.task_list = {}
-- 	for i, v in pairs(task_list) do
-- 		self:UpdateTaskState(v)
-- 		self.task_list[v.task_id] = v
-- 	end

-- 	self:NotifyChangeEvent("task_list")
-- end


-- function TaskData:GetMainTaskInfo()
-- 	for k, v in pairs(self.task_list) do
-- 		if v.task_type == TaskType.Main then
-- 			return v
-- 		end
-- 	end

-- 	for k, v in pairs(self.accept_task_list) do
-- 		if v.task_type == TaskType.Main then
-- 			return v
-- 		end
-- 	end
	
-- 	return nil
-- end

-- function TaskData:AddTask(task_info)
-- 	self:UpdateTaskState(task_info)
-- 	self.task_list[task_info.task_id] = task_info
-- 	self.accept_task_list[task_info.task_id] = nil

-- 	self:NotifyChangeEvent("add", task_info.task_id)

-- 	if task_info.task_id then
-- 		self.mark_task_no_complete_list[task_info.task_id] = true
-- 	end
-- end

-- function TaskData.GetStateByTarget(target, task_id)
-- 	if nil == target or target.cur_value >= target.target_value then
-- 		return TaskState.Complete
-- 	end
-- 	-- 记录任务未完成
-- 	local ins = TaskData.Instance
-- 	if nil ~= ins then
-- 		local state = ins.task_state_t[task_id] and ins.task_state_t[task_id].task_state
-- 		if state and state ~= TaskState.NotComplete then
-- 			return state
-- 		end
-- 		if task_id then
-- 			ins.mark_task_no_complete_list[task_id] = true
-- 		end
-- 	end

-- 	return TaskState.NotComplete
-- end

-- function TaskData:GetTaskIsJustComplete(task_id)
-- 	if nil == self.task_list[task_id] then
-- 		return false
-- 	end
-- 	if self.task_list[task_id].task_state == TaskState.Complete and self.mark_task_no_complete_list[task_id] then
-- 		return true
-- 	end
-- 	return false
-- end

-- -- reason(finish/giveup)
-- function TaskData:RemoveTask(task_id, reason)
-- 	self.mark_task_no_complete_list[task_id] = nil

-- 	self.task_list[task_id] = nil

-- 	self:NotifyChangeEvent(reason, task_id)
-- end

-- function TaskData:RemoveAcceptTask(task_id)
-- 	if not task_id then return end
-- 	self.accept_task_list[task_id] = nil
-- 	if self.mark_old_accept_task_list then self.mark_old_accept_task_list[task_id] = nil end

-- 	self:NotifyChangeEvent("remove_accept", task_id)
-- end

-- -- 任务显示顺序 和 任务状态
-- function TaskData:SetTaskStateList(task_state_list)
-- 	self.task_state_list = {}
-- 	self.task_state_t = {}
-- 	for i, v in pairs(task_state_list) do
-- 		self.task_state_t[v.task_id] = {task_state = v.task_state, show_order = i}
-- 		self.task_state_list[i] = v

-- 		self:UpdateTaskState(self:GetTaskInfo(v.task_id))
-- 		if v.task_state == TaskState.Complete then
-- 			self:NotifyChangeEvent("complete", v.task_id)
-- 		elseif v.task_state == TaskState.NotComplete then
-- 			self:NotifyChangeEvent("no_complete", v.task_id)
-- 		end
-- 	end
-- 	self:NotifyChangeEvent("task_state")
-- end

-- function TaskData:GetTaskStateList()
-- 	return self.task_state_list
-- end

-- function TaskData:GetAcceptTaskList()
-- 	return self.accept_task_list
-- end

-- -- 同步服务端的任务状态和排序信息
-- function TaskData:UpdateTaskState(task_info)
-- 	if nil == task_info then
-- 		return
-- 	end

-- 	local state_info = self.task_state_t[task_info.task_id]
-- 	if state_info then
-- 		if TaskState.Complete ~= state_info.task_state then
-- 			self.mark_task_no_complete_list[task_info.task_id] = true
-- 		end
-- 		task_info.task_state = state_info.task_state
-- 		task_info.show_order = state_info.show_order
-- 	end
-- end

-- function TaskData:OnAcceptTaskList(accept_task_list)
-- 	self.mark_old_accept_task_list = self.accept_task_list
-- 	self.accept_task_list = {}
-- 	for i, v in pairs(accept_task_list) do
-- 		self.accept_task_list[v.task_id] = v
-- 	end
-- 	self:OnAcceptTaskChange()
-- 	self:RestoreDailyTask()
-- 	self:NotifyChangeEvent("accept_list")
-- end

-- function TaskData:OnAddAcceptTaskList(accept_task_list)
-- 	for i, v in ipairs(accept_task_list) do
-- 		self.accept_task_list[v.task_id] = v
-- 	end
-- 	self:OnAcceptTaskChange()
-- 	self:NotifyChangeEvent("add_accept_list")
-- end

-- function TaskData:OnRoleDataChangeCallback(key, value, old_value)
-- 	if key == OBJ_ATTR.CREATURE_LEVEL then
-- 	end
-- end

-- function TaskData:OnAcceptTaskChange()
-- 	for i, v in pairs(self.accept_task_list) do
-- 		self:UpdateTaskState(v)
-- 	end
-- end

-- function TaskData:SetCurValue(task_id, target_index, cur_value)
-- 	local task_info = self.task_list[task_id]
-- 	local target_update = false
-- 	if nil ~= task_info then
-- 		for k,v in ipairs(task_info.targets) do
-- 			if v.target_index == target_index then
-- 				if task_info.target then
-- 					task_info.target.cur_value = task_info.target.cur_value + (cur_value - v.cur_value)
-- 				end
-- 				v.cur_value = cur_value
-- 			end
-- 			if task_info.target then
-- 				if not target_update and (v.cur_value < v.target_value or k == #task_info.targets) then
-- 					local old_target_id = task_info.target.id 
-- 					task_info.target.target_type = v.target_type
-- 					task_info.target.id = v.id
-- 					task_info.target.scene_id = v.scene_id
-- 					task_info.target.x = v.x
-- 					task_info.target.y = v.y
-- 					task_info.target.name = v.name
-- 					target_update = true
-- 				end
-- 			end
-- 		end
-- 		if nil ~= task_info.target then
-- 			-- local old_state = task_info.task_state
-- 			-- task_info.task_state = TaskData.GetStateByTarget(task_info.target, task_id)
-- 			-- if old_state ~= task_info.task_state and task_info.task_state == TaskState.Complete then
-- 				-- self:NotifyChangeEvent("complete", task_id)
-- 			-- end
-- 		end
-- 	elseif nil ~= self.accept_task_list[task_id] and self.accept_task_list[task_id].target then
-- 		self.accept_task_list[task_id].target.cur_value = cur_value
-- 	end

-- 	self:NotifyChangeEvent("set_value", task_id)
-- end

-- function TaskData:SetTitle(task_id, title)
-- 	if nil ~= self.task_list[task_id] then
-- 		self.task_list[task_id].title = title
-- 	elseif nil ~= self.accept_task_list[task_id] then
-- 		self.accept_task_list[task_id].title = title
-- 	end

-- 	self:NotifyChangeEvent("set_title", task_id)
-- end

-- function TaskData:SetCoefficient(double_reward_coefficient, quick_finish_coefficient, accept_again_coefficient)
-- 	self.double_reward_coefficient = double_reward_coefficient
-- 	self.quick_finish_coefficient = quick_finish_coefficient
-- 	self.accept_again_coefficient = accept_again_coefficient
-- end

-- function TaskData:GetTaskByTaskId(task_id)
-- 	return self.task_list[task_id]
-- end

-- -- 监听任务改变 callback(reason, task_id)
-- function TaskData:ListenerTaskChange(callback)
-- 	self.callback_list[callback] = callback
-- end

-- function TaskData:UnListenerTaskChange(callback)
-- 	self.callback_list[callback] = nil
-- end

-- function TaskData:NotifyChangeEvent(reason, task_id)
-- 	for k, v in pairs(self.callback_list) do
-- 		v(reason, task_id)
-- 	end
-- end

-- function TaskData.GetSpecialQuestsCfg(task_id)
-- 	local cfg = {}
-- 	return cfg[task_id]
-- end

-- function TaskData.GetSpecialQuestsOpenView(task_id)
-- 	local cfg = TaskData.GetSpecialQuestsCfg(task_id)
-- 	if nil == cfg then return end
-- 	return cfg.openView
-- end

-- function TaskData.GetSpecialQuestIsSetTop(task_id, task_list)
-- 	local cfg = {}
-- 	if nil == cfg or nil == cfg[task_id] or nil == cfg[task_id].main_task_id or nil == cfg[task_id].role_level then return false end
-- 	local main_task_id_list = cfg[task_id].main_task_id
-- 	local role_level_list = cfg[task_id].role_level

-- 	-- 判断有没有出现目标主线任务
-- 	local has_main_task = false
-- 	local id_index = 0
-- 	for k,v in pairs(task_list) do
-- 		for k1,v1 in pairs(main_task_id_list) do
-- 			if v.task_id and v.task_id == v1 then
-- 				has_main_task = true
-- 				id_index = k1
-- 				break
-- 			end
-- 		end
-- 	end
-- 	if not has_main_task then return false end

-- 	local now_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
-- 	local c_role_level = role_level_list[id_index]
-- 	if nil == c_role_level then return false end

-- 	return now_level <= c_role_level
-- end

-- function TaskData:RestoreDailyTask()
-- 	if not self.mark_old_accept_task_list or type(self.mark_old_accept_task_list) ~= "table" then return end
-- 	local temp_list = {}
-- 	for k,v in pairs(self.mark_old_accept_task_list) do
-- 		if v.task_id >= 4000 and v.task_id <= 4100 then
-- 			table.insert(temp_list, v)
-- 		end
-- 	end
-- 	self:OnAddAcceptTaskList(temp_list)
-- 	self.mark_old_accept_task_list = {}
-- end

-- function TaskData:SetTaskDoCount(protocol)
-- 	if not self.mark_task_do_count_list then self.mark_task_do_count_list = {} end
-- 	if not protocol.task_id then return end
-- 	self.mark_task_do_count_list[protocol.task_id] = self.mark_task_do_count_list[protocol.task_id] or {}
-- 	self.mark_task_do_count_list[protocol.task_id].task_id = protocol.task_id
-- 	self.mark_task_do_count_list[protocol.task_id].now_count = protocol.now_count
-- 	self.mark_task_do_count_list[protocol.task_id].max_count = protocol.max_count
-- end

-- function TaskData:GetTaskDoCount(task_id)
-- 	return self.mark_task_do_count_list[task_id]
-- end

-- function TaskData:GetSSGRewardLis(idx)
-- 	local list = {}
-- 	local self_prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
-- 	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
-- 	local cfg = FourPalaceCfg and FourPalaceCfg.Rewards[idx][self_prof]

-- 	for k,v in pairs(cfg) do
-- 		if v.sex == sex then
-- 			table.insert(list, v)
-- 		end
-- 	end

-- 	return list
-- end