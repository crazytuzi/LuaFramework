TipsTaskRewardRollView = TipsTaskRewardRollView or BaseClass(BaseView)

local CellCount = 8						--奖励格子数量
local TaskType = {
	Normal = 0,							--普通任务
	Fb = 1,								--副本任务
}
function TipsTaskRewardRollView:__init()
	self.ui_config =  {"uis/views/tips/taskrewardtip_prefab", "TaskRewardRollView"}
	self.reward_cells = {}
	self.imageshow = {}
	self.task_complete_event = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskComplete, self))
	self.mainview_complete_event = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnMainViewComplete, self))
	self.view_layer = UiLayer.Pop
	self.is_rolling = false
	self.is_send = false
	-- self.turn_complete = true
	self.task_type = -1
	self.is_first = true
	self.diff_time = 0
	self.play_audio = true
	self.type = TaskType.Normal
	--需要立即销毁
	self.vew_cache_time = 0
end

function TipsTaskRewardRollView:LoadCallBack()

	self.time = self:FindVariable("Time")
	self.wheel = self:FindObj("Wheel")
	self.is_show_time = self:FindVariable("IsShowTime")
	for i = 1, CellCount do
		self.reward_cells[i] = ItemCell.New(self:FindObj("Reward"..i))
	end

	for i = 1,CellCount do
		self.imageshow[i] = self:FindVariable("Image"..i)
	end

	self:ListenEvent("OnClickStart",
		BindTool.Bind(self.OnClickStart, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self.is_show_time:SetValue(true)
end

function TipsTaskRewardRollView:ReleaseCallBack()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	for k,v in pairs(self.reward_cells) do
		v:DeleteMe()
	end

	self.reward_cells = {}

	for k,v in pairs(self.imageshow) do
		v = nil
	end
	self.imageshow = {}

	-- 清理变量和对象
	self.wheel = nil
	self.time = nil
	self.is_show_time = nil
end

function TipsTaskRewardRollView:OpenCallBack()
	if FunctionGuide.Instance:GetIsGuide() then
		self:Close()
		return
	end
	self.is_rolling = false
	self:Flush()
end

function TipsTaskRewardRollView:CloseCallBack()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.task_id and not self.is_send then
		TaskCtrl.SendTaskCommit(self.task_id)
	end
	-- local day_counter_id = self.task_type == TASK_TYPE.RI and DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT or DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT
	-- if DayCounterData.Instance:GetDayCount(day_counter_id) + 1 >= max_task_num then
	TaskCtrl.Instance:SetAutoTalkState(true)
	self.diff_time = 0
	self.task_type = -1
	self.task_id = 0
	self.is_send = false
	self.is_rolling = false
	self.data = nil
end

function TipsTaskRewardRollView:__delete()
	self.is_rolling = nil
	self.is_send = nil
	self.task_id = nil
	self.task_type = nil
	self.type = nil

	if self.task_complete_event then
		GlobalEventSystem:UnBind(self.task_complete_event)
		self.task_complete_event = nil
	end
	if self.mainview_complete_event then
		GlobalEventSystem:UnBind(self.mainview_complete_event)
		self.mainview_complete_event = nil
	end
	if self.taskfb_complete_event then
		GlobalEventSystem:UnBind(self.taskfb_complete_event)
		self.taskfb_complete_event = nil
	end
end

-- 控制奖励栏的高亮
function TipsTaskRewardRollView:OpenHighLight(index)  -- index = 0  全灭
	for i = 1, CellCount do
		self.reward_cells[i]:ShowHighLight(i == index)
	end
end

function TipsTaskRewardRollView:CloseRollView()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	-- self.root_node:SetActive(false)
	-- self.turn_complete = true

	self:Close()
end

-- 点击开始
function TipsTaskRewardRollView:OnClickStart()
	if self.is_rolling then
		return
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.is_show_time:SetValue(false)
	-- self.turn_complete = false
	self.is_rolling = true
	local time = 0
	local tween = self.wheel.transform:DORotate(Vector3(0, 0, -360 * 10),10,DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		if nil == self.wheel then return end
		time = time + UnityEngine.Time.deltaTime
		if not self.is_send then
			self:SetTaskAutoCount(1)
			TaskCtrl.SendTaskCommit(self.task_id)
			self.is_send = true
		end
		if time >= 1 or FunctionGuide.Instance:GetIsGuide() then
			if FunctionGuide.Instance:GetIsGuide() then
				self:Close()
			end
			if TaskData.Instance:GetRewardRollInfo()[1].index then
				tween:Pause()
				local angle = TaskData.Instance:GetRewardRollInfo()[1].index * -45
				local tween1 = self.wheel.transform:DORotate(
						Vector3(0, 0, -360 * 1 + angle),
						1,
						DG.Tweening.RotateMode.FastBeyond360)
				tween1:OnComplete(function ()
					if self.wheel then
						self:OpenHighLight(TaskData.Instance:GetRewardRollInfo()[1].index + 1)
						self.imageshow[TaskData.Instance:GetRewardRollInfo()[1].index + 1]:SetValue(true)
						self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 1)
						ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_LUCKYROLL)
					end
				end)
			end
		end
	end)
	tween:OnComplete(function ()
			self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 1)
		end)
end

function TipsTaskRewardRollView:OnFlush()
	-- if not self.root_node.gameObject.activeSelf then return end
	local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
	if task_cfg then
		self.task_type = task_cfg.task_type
		-- self.reward_btn_txt:SetValue(self.is_onekey_complete and Language.Task.TaskRewardBtnText[2] or Language.Task.TaskRewardBtnText[1])
	end
	local reward_cfg = TaskData.Instance:GetTaskRewardRoll(self.task_type)
	for k, v in pairs(self.reward_cells) do
		-- v:SetQualityState(2)
		v:SetData(reward_cfg[k].item)
	end
	TaskCtrl.Instance:SetAutoTalkState(false)
	self:SetCountDown()
end

-- function TipsTaskRewardRollView:GetIsTrunComplete()
-- 	return self.turn_complete
-- end

function TipsTaskRewardRollView:OnClickClose()
	self:SetTaskAutoCount(1)
	self:Close()
end

function TipsTaskRewardRollView:SetCountDown()
	local diff_time = 8
	if self.count_down == nil then
		local diff_func = function(elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0 then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
					self:OnClickStart()
					return
				end
				self.time:SetValue(left_time)
			end
		diff_func(0, diff_time)
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_func)
	end
end

local old_com_type, old_task_id = "", 0
function TipsTaskRewardRollView:OnTaskComplete(com_type, task_id)
	if old_com_type == com_type and old_task_id == task_id and not TaskData.Instance:GetTaskIsCanCommint(task_id) then return end

	if self.is_first then return end
	old_com_type = com_type
	old_task_id = task_id
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)

	if com_type == "one_key" then
		-- self.is_onekey_complete = true
		self.data = task_id
		self.task_id = self.data.task_id
		task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
		if task_cfg then
			self.diff_time = TaskData.Instance:GetTaskCount(task_cfg.task_type)
		end
		MainUIViewTask.OnClickQuickDone(self.data)
		if task_cfg.task_type == TASK_TYPE.HUAN then
			TaskCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_PAOHUAN_TASK, -1)
		else
			TaskCtrl.Instance:SendQuickDone(task_cfg.task_type, self.task_id)
		end
	end
	if com_type == "no_complete_daily" then
		local accepted_info = TaskData.Instance:GetTaskAcceptedInfoList()
		for k, v in pairs(accepted_info) do
			if TaskData.Instance:GetTaskConfig(k) and TaskData.Instance:GetTaskConfig(k).task_type == TASK_TYPE.RI then
				self.task_id = k
			end
		end
	end
	-- local daily_info = TaskData.Instance:GetDailyTaskInfo()
	-- if not daily_info or (daily_info.commit_times <= 0 and daily_info.is_accept == 0) then
	-- 	return
	-- end

	if com_type ~= "one_key" and task_cfg and task_cfg.task_type and (task_cfg.task_type == TASK_TYPE.RI or task_cfg.task_type == TASK_TYPE.GUILD or task_cfg.task_type == TASK_TYPE.HUAN) then
		if TaskData.Instance:GetTaskIsCanCommint(task_id) then -- or (com_type == "accepted_remove")
			self.task_id = task_id
			if TASK_ACCEPT_OP.ENTER_DAILY_TASKFB == task_cfg.accept_op then
				self.type = TaskType.Fb
				self.taskfb_complete_event = GlobalEventSystem:Bind(OtherEventType.FUBEN_QUIT, BindTool.Bind(self.ShowRoll, self, task_cfg))
			else
				self.type = TaskType.Normal
				self:ShowRoll(task_cfg)
			end
		end
	end
	if task_cfg then
		if com_type == "accepted_add" then
			if task_cfg.task_type == TASK_TYPE.GUILD and DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) > 0 then
				if TaskData.Instance:GetNextGuildTaskConfig() and TaskData.Instance:GetNextGuildTaskConfig().task_id then
					TASK_GUILD_AUTO = true
					TaskCtrl.Instance:DoTask(task_id)
				end
			elseif task_cfg.task_type == TASK_TYPE.RI and DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) > 0 then
				TASK_RI_AUTO = true
				TaskCtrl.Instance:DoTask(task_id)
			elseif task_cfg.task_type == TASK_TYPE.HUAN and TaskData.Instance:GetPaohuanTaskInfo().commit_times > 0 then
				TASK_HUAN_AUTO = true
				TaskCtrl.Instance:DoTask(task_id)
			end
		elseif com_type == "can_accept_list" and task_cfg and next(task_cfg) then
			if task_cfg.task_type == TASK_TYPE.GUILD and DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) > 0 then
				-- self.is_onekey_complete = false
				TASK_GUILD_AUTO = true
				self.data = nil
				self:Flush()
				-- TaskCtrl.Instance:DoTask(task_cfg.task_id)
			end
		end
	end
end

function TipsTaskRewardRollView:OnMainViewComplete()
	self.is_first = false
end

function TipsTaskRewardRollView:ShowRoll(task_cfg)
	if self:IsOpen() then
		self:Flush()
	else
		if task_cfg.condition == TASK_COMPLETE_CONDITION.HUG then
			if task_cfg.task_type == TASK_TYPE.GUILD then
				TASK_GUILD_AUTO = false
			end
			if task_cfg.task_type == TASK_TYPE.RI then
				TASK_RI_AUTO = false
			end
			if task_cfg.task_type == TASK_TYPE.HUAN then
				TASK_HUAN_AUTO = false
			end
			TaskCtrl.Instance:DoTask(task_cfg.task_id)
		else
			local count = TaskData.Instance:GetTaskCurrentCount(task_cfg.task_type) + 1
			if count % TaskData.Instance:GetRewardRollCountShow() == 0 and FunctionGuide.Instance:GetIsGuide() == false then
				self.task_id = task_cfg.task_id
				self:Open()
			else
				TaskCtrl.SendTaskCommit(task_cfg.task_id)
			end
		end
	end
	if self.taskfb_complete_event then
		GlobalEventSystem:UnBind(self.taskfb_complete_event)
		self.taskfb_complete_event = nil
	end
end

--设置当剩余任务小于Count时关闭自动做任务
function TipsTaskRewardRollView:SetTaskAutoCount(count)
	if self.type == TaskType.Fb then
		count = count - 1
	end
	if TaskData.Instance:GetTaskCount(self.task_type) <= count then
		if self.task_type == TASK_TYPE.RI then
			TaskCtrl.Instance:SendGetTaskReward()
			TASK_RI_AUTO = false
		elseif self.task_type == TASK_TYPE.GUILD then
			TASK_GUILD_AUTO = false
		elseif self.task_type == TASK_TYPE.HUAN then
			TASK_HUAN_AUTO = false
		end
	-- else
	-- 	if self.task_type == TASK_TYPE.RI then
	-- 		TASK_RI_AUTO = true
	-- 	elseif self.task_type == TASK_TYPE.GUILD then
	-- 		TASK_GUILD_AUTO = true
	-- 	elseif self.task_type == TASK_TYPE.HUAN then
	-- 		TASK_HUAN_AUTO = true
	-- 	end
	end
end
