
-- 限时任务
TimeLimitTaskData = TimeLimitTaskData or BaseClass(BaseData)

-- 任务类型
TimeLimitTaskData.TASK_TYPE = {
	KillFieldBoss = 0,				--击杀野外boss
	Treasure = 1,					--参与寻宝
	Material = 2,					--材料副本
	Trial = 3,						--闯关卡
	KillPeronalBoss = 4,			--击杀个人boss
	SwingUpGrade = 5,				--翅膀升级
	KillPlayer = 6,					--击杀玩家
	ChargeOrLogin = 7,				--首充或者次日登陆
}

-- 任务状态
TimeLimitTaskData.TASK_STATE = {
	NOT_OK = 1,		-- 未完成
	OK = 2,			-- 已完成
	OK_AND_REC = 3,	-- 已完成并已领取奖励
}

TimeLimitTaskData.MAX_TASK_COUNT = 8

-- 事件
TimeLimitTaskData.LIMIT_TASK_DATA_CHG = "limit_task_data_chg"

local OpenServerLimitTimeTaskCfg = OpenServerLimitTimeTaskCfg

function TimeLimitTaskData:__init()
	if	TimeLimitTaskData.Instance then
		ErrorLog("[TimeLimitTaskData]:Attempt to create singleton twice!")
	end
	TimeLimitTaskData.Instance = self

	self.task_data_list = {}

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetTimeLimitTaskRewardRemind, self), RemindName.TimeLimitTaskReward)
end

function TimeLimitTaskData:__delete()
	TimeLimitTaskData.Instance = nil
end

-- 有可领取的奖励
function TimeLimitTaskData:GetTimeLimitTaskRewardRemind()
	for task_type, v in pairs(self.task_data_list) do
		if self:TaskState(task_type) == TimeLimitTaskData.TASK_STATE.OK then
			return 1
		end
	end
	return 0
end

-- 任务数据
function TimeLimitTaskData:SetTaskData(data, disp_event)
	self.task_data_list[data.task_type] = data

	if disp_event then
		self:DispatchEvent(TimeLimitTaskData.LIMIT_TASK_DATA_CHG, data.task_type)
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.TimeLimitTaskReward)
end

-- 获取单个数据
function TimeLimitTaskData:GetTaskData(task_type)
	return self.task_data_list[task_type]
end

-- 获取任务完成状态
function TimeLimitTaskData:TaskState(task_type)
	local cfg = self:GetTaskCfg(task_type)
	local task_data = self:GetTaskData(task_type)
	if nil == cfg or nil == task_data then
		return TimeLimitTaskData.TASK_STATE.NOT_OK, "前往"
	end

	if task_data.rec_state == 1 then
		return TimeLimitTaskData.TASK_STATE.OK_AND_REC, "已完成"
	else
		if task_data.done_times >= cfg.limitTimes then
			return TimeLimitTaskData.TASK_STATE.OK, "领取"
		else
			return TimeLimitTaskData.TASK_STATE.NOT_OK, "前往"
		end
	end
end

-- 任务配置
function TimeLimitTaskData:GetTaskCfg(task_type)
	return OpenServerLimitTimeTaskCfg.task[task_type + 1]
end

-- 任务列表
function TimeLimitTaskData:GetTaskDataList()
	local t = {}
	for k, v in pairs(OpenServerLimitTimeTaskCfg.task) do
		table.insert(t, {task_type = (k - 1), cfg = v})
	end
	return t
end

-- 已完成的任务数量
function TimeLimitTaskData:GetOkTaskCount()
	local count = 0
	for k, v in pairs(OpenServerLimitTimeTaskCfg.task) do
		if self:TaskState(k - 1) == TimeLimitTaskData.TASK_STATE.OK_AND_REC then
			count = count + 1
		end
	end
	return count
end

-- 任务剩余时间
function TimeLimitTaskData:TaskLeftTime()
	return OpenServerLimitTimeTaskCfg.limitTimes - (TimeCtrl.Instance:GetServerTime() - OtherData.Instance:GetOpenServerTime())
end

-- 符文数据
function TimeLimitTaskData:GetFuwenData(index)
	local task_type = index - 1
	local cfg = self:GetTaskCfg(task_type)
	local task_data = self:GetTaskData(task_type)
	if nil == cfg or nil == task_data then
		return nil
	end

	local state = self:TaskState(task_type)
	if state == TimeLimitTaskData.TASK_STATE.OK_AND_REC then
		return nil
	end

	return ItemData.FormatItemData(cfg.award[1])
end
