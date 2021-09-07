TipsTaskRewardView = TipsTaskRewardView or BaseClass(BaseView)

local DALIY_MAX_TASK = 10
local GUILD_MAX_TASK = 10

local GONGHUI_GONGXIAN_ID = 90009

function TipsTaskRewardView:__init()
	self.ui_config = {"uis/views/tips/taskrewardtip", "TaskRewardTip"}
	self.view_layer = UiLayer.Pop
	self.task_complete_event = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskComplete, self))
	self.mainview_complete_event = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnMainViewComplete, self))
	self.cur_item_list = {}
	self.final_item_list = {}
	self.task_type = -1
	self.is_first = true
	self.is_onekey_complete = false
	self.diff_time = 0
	self.complete_task_num = 0
	self.complete_guild_task_num = 0
	self.play_audio = true
	self.richang_task_id = nil
end

function TipsTaskRewardView:__delete()
	for k, v in pairs(self.cur_item_list) do
		v:DeleteMe()
	end
	self.cur_item_list = {}

	for k, v in pairs(self.final_item_list) do
		v:DeleteMe()
	end
	self.final_item_list = {}
	self.task_id = nil
	self.task_type = nil

	if self.task_complete_event then
		GlobalEventSystem:UnBind(self.task_complete_event)
		self.task_complete_event = nil
	end
	if self.mainview_complete_event then
		GlobalEventSystem:UnBind(self.mainview_complete_event)
		self.mainview_complete_event = nil
	end
	self.is_onekey_complete = nil
	self.diff_time = nil
	self.complete_guild_task_num = nil
end

function TipsTaskRewardView:OnMainViewComplete()
	self.is_first = false
end

function TipsTaskRewardView:ReleaseCallBack()
	for k, v in pairs(self.cur_item_list) do
		v:DeleteMe()
	end
	self.cur_item_list = {}

	for k, v in pairs(self.final_item_list) do
		v:DeleteMe()
	end
	self.final_item_list = {}

	-- 清理变量和对象
	self.time = nil
	self.cur_task_num = nil
	self.max_task_num = nil
	self.task_type_name = nil
	self.task_onekey_reward_count = nil
	self.show_onekey_title = nil
	self.reward_btn_txt = nil
end

-- 创建完调用
function TipsTaskRewardView:LoadCallBack()
	self.time = self:FindVariable("Time")
	self.cur_task_num = self:FindVariable("CurTaskNum")
	self.max_task_num = self:FindVariable("MaxTaskNum")
	self.task_type_name = self:FindVariable("TaskTypeName")
	self.task_onekey_reward_count = self:FindVariable("TaskOneKeyCount")
	self.show_onekey_title = self:FindVariable("ShowOnekeyTitle")
	self.reward_btn_txt = self:FindVariable("RewardBtnTxt")

	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("CloseView",
		BindTool.Bind(self.CloseView, self))

	self.cur_item_list = {}
	for i = 1, 3 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("CurItem" .. i))
		table.insert(self.cur_item_list, item_cell)
	end

	self.final_item_list = {}
	for i = 1, 8 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("FinalItem" .. i))
		table.insert(self.final_item_list, item_cell)
	end
end

local old_com_type, old_task_id = "", 0
function TipsTaskRewardView:OnTaskComplete(com_type, task_id)
	if old_com_type == com_type and old_task_id == task_id and not TaskData.Instance:GetTaskIsCanCommint(task_id) then return end

	if self.is_first then return end
	old_com_type = com_type
	old_task_id = task_id
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)

	if com_type == "one_key" then
		self.is_onekey_complete = true
		self.data = task_id
		self.task_id = self.data.task_id
		task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
		if task_cfg then
			self.diff_time = TaskData.Instance:GetTaskCount(task_cfg.task_type)
		end
		if self:IsOpen() then
			self:Flush()
		else
			self:Open()
		end
	elseif com_type == "no_complete_daily" then
		local daily_info = TaskData.Instance:GetDailyTaskInfo()
		self.complete_task_num = daily_info and daily_info.commit_times or 0
		local accepted_info = TaskData.Instance:GetTaskAcceptedInfoList()
		for k, v in pairs(accepted_info) do
			if TaskData.Instance:GetTaskConfig(k) and TaskData.Instance:GetTaskConfig(k).task_type == TASK_TYPE.RI then
				self.task_id = k
			end
		end
	elseif com_type == "no_complete_guild" then
		local guild_info = TaskData.Instance:GetGuildTaskInfo()
		self.complete_guild_task_num = guild_info and guild_info.complete_task_count or 0
	end

	-- local daily_info = TaskData.Instance:GetDailyTaskInfo()
	-- if not daily_info or (daily_info.commit_times <= 0 and daily_info.is_accept == 0) then
	-- 	return
	-- end

	if task_cfg and task_cfg.task_type then
		local is_daily_or_guild = task_cfg.task_type == TASK_TYPE.RI or task_cfg.task_type == TASK_TYPE.GUILD
		if com_type ~= "one_key" and is_daily_or_guild and task_cfg.accept_op ~= TASK_ACCEPT_OP.ENTER_DAILY_TASKFB then
			if TaskData.Instance:GetTaskIsCanCommint(task_id) or com_type == "accepted_remove" then
				if task_cfg.task_type == TASK_TYPE.GUILD then
					TASK_GUILD_AUTO = false
				elseif task_cfg.task_type == TASK_TYPE.RI then
					TASK_RI_AUTO = false
				end
				self.task_id = task_id
				if self:IsOpen() then
					self:Flush()
				-- else
					-- self:Open()
				end
			end
		end

		if com_type == "accepted_add" then
			if task_cfg.task_type == TASK_TYPE.GUILD and DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) > 0 then
				if TaskData.Instance:GetNextGuildTaskConfig() and TaskData.Instance:GetNextGuildTaskConfig().task_id then
					TASK_GUILD_AUTO = true
					TaskCtrl.Instance:DoTask(task_id)
				end
			elseif task_cfg.task_type == TASK_TYPE.RI and DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) > 0 then
				self.richang_task_id = task_id
				TaskData.Instance:SetRichangTaskId(self.richang_task_id)
				TASK_RI_AUTO = true
				return --日常任务处理，点确定再继续跑
			end
		elseif com_type == "can_accept_list" and task_cfg and next(task_cfg) then
			if task_cfg.task_type == TASK_TYPE.GUILD and DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) > 0 then
				TASK_GUILD_AUTO = true
				self.is_onekey_complete = false
				self.data = nil
				self:Flush()
				-- TaskCtrl.Instance:DoTask(task_cfg.task_id)
			end
		end
	end
end

function TipsTaskRewardView:OpenCallBack()
	self:Flush()
end

function TipsTaskRewardView:ShowRollPanle()
	-- local richang_day_num = GuildData.Instance:GetRiChangTask()
	-- if richang_day_num then
	-- 	if richang_day_num % 2 == 0 then
	-- 		MainUICtrl.Instance:SetIsAutoTaskState(false)
	-- 		GuildCtrl.Instance:GuildRollViewOpen()
	-- 	end
	-- end
end

function TipsTaskRewardView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.is_onekey_complete and self.data then
		MainUIViewTask.OnClickQuickDone(self.data)
		TaskCtrl.Instance:SendQuickDone(self.task_type, self.task_id)
	elseif self.task_id then
		-- TaskCtrl.SendTaskCommit(self.task_id)
	end
	local day_counter_id = self.task_type == TASK_TYPE.RI and DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT or DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT

	local guild_info = TaskData.Instance:GetGuildTaskInfo() or {}
	local max_guid_task = (guild_info.guild_task_max_count and guild_info.guild_task_max_count > 0) and guild_info.guild_task_max_count or TaskData.Instance:GetMaxGuildTaskCount()

	local max_task_num = self.task_type == TASK_TYPE.RI and DALIY_MAX_TASK or max_guid_task
	if DayCounterData.Instance:GetDayCount(day_counter_id) + 1 >= max_task_num then
		if self.task_type == TASK_TYPE.RI then
			-- TaskCtrl.Instance:SendGetTaskReward() --现在没有完成所有任务奖励
			TASK_RI_AUTO = false
		else
			TASK_GUILD_AUTO = false
		end
	end
	self.diff_time = 0
	self.task_type = -1
	self.task_id = 0
	if self.is_onekey_complete then
		self.complete_guild_task_num = 0
		self.complete_task_num = 0
	end
	self.is_onekey_complete = false
	self.data = nil
end

function TipsTaskRewardView:OnClickClose()
	-- FuBenCtrl.Instance:SendExitFBReq()
	local is_continue = self:CheckIsRiChangTaskRoll()
	if TASK_RI_AUTO and self.richang_task_id and is_continue then
		TaskCtrl.Instance:DoTask(self.richang_task_id)
		self.richang_task_id = nil
		TaskData.Instance:SetRichangTaskId(nil)
	end
	self:Close()
end

function TipsTaskRewardView:CloseView()
	self:CheckIsRiChangTaskRoll()
	-- self:OnClickClose()
	self:Close()
end

function TipsTaskRewardView:CheckIsRiChangTaskRoll()
	local richang_day_num = GuildData.Instance:GetRiChangTask()
	if richang_day_num then
		if richang_day_num % 2 == 0 then
			MainUICtrl.Instance:SetTaskAutoState(false)
			GuildCtrl.Instance:GuildRollViewOpen()
			return false
		end
	end
	return true
end

function TipsTaskRewardView:SetRewardData(task_type, max_task_num)
	local reward_cfg = TaskData.Instance:GetTaskReward(task_type)
	if reward_cfg then
		local exp = reward_cfg.exp
		local gongxian = reward_cfg.gongxian
		if (self.is_onekey_complete and task_type == TASK_TYPE.RI) or (task_type == TASK_TYPE.GUILD and max_task_num == 5) then
			exp = exp * 2
			if gongxian then
				gongxian = gongxian * 2
			end
		end
		local data_list = {[1] = {item_id = FuBenDataExpItemId.ItemId, num = exp}}
		if reward_cfg.gongxian then
			data_list = {[1] = {item_id = FuBenDataExpItemId.ItemId, num = exp}, [2] = {item_id = GONGHUI_GONGXIAN_ID, num = gongxian}}
		end
		if reward_cfg.guild_gongxian_reward then
			table.insert(data_list, {item_id = COMMON_CONSTS.VIRTUAL_ITEM_JIAZU, num = reward_cfg.guild_gongxian_reward})
		end
		if task_type == TASK_TYPE.RI then
			for k, v in pairs(self.cur_item_list) do
				v:SetParentActive(nil ~= data_list[k])
				if data_list[k] then
					v:SetData(data_list[k])
				end
			end
			for k, v in pairs(self.final_item_list) do
				v:SetParentActive(nil ~= reward_cfg.reward_item[k - 1])
				if reward_cfg.reward_item[k - 1] then
					v:SetData(reward_cfg.reward_item[k - 1])
				end
			end
		else
			local guild_reward = TaskData.Instance:GetGuildTaskReward()
			local gift_cfg = ConfigManager.Instance:GetAutoItemConfig("gift_auto")[guild_reward.item_id]
			local cur_count = 1
			for k, v in pairs(self.cur_item_list) do
				v:SetParentActive(nil ~= reward_cfg.reward_item[k - 1] and reward_cfg.reward_item[k - 1].item_id > 0)
				if reward_cfg.reward_item[k - 1] then
					v:SetData(reward_cfg.reward_item[k - 1])
					cur_count = cur_count + 1
				end
			end
			for k, v in pairs(data_list) do
				if self.cur_item_list[cur_count] then
					self.cur_item_list[cur_count]:SetParentActive(true)
					self.cur_item_list[cur_count]:SetData(v)
					cur_count = cur_count + 1
				end
			end
			for k, v in pairs(self.final_item_list) do
				v:SetParentActive(gift_cfg["item_"..k.."_id"] > 0)
				if gift_cfg["item_"..k.."_id"] > 0 then
					local data = {item_id = gift_cfg["item_"..k.."_id"], num = gift_cfg["item_"..k.."_num"], is_bind = gift_cfg["is_bind_"..k]}
					v:SetData(data)
				end
			end
		end
	else
		for k, v in pairs(self.final_item_list) do
			v:SetParentActive(false)
		end
		for k, v in pairs(self.cur_item_list) do
			v:SetParentActive(false)
		end
	end
end

function TipsTaskRewardView:OnFlush(param_list)
	local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
	if task_cfg then
		local day_counter_id = task_cfg.task_type == TASK_TYPE.RI and DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT or DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT

		local guild_info = TaskData.Instance:GetGuildTaskInfo() or {}
		local max_guid_task = (guild_info.guild_task_max_count and guild_info.guild_task_max_count > 0) and guild_info.guild_task_max_count or TaskData.Instance:GetMaxGuildTaskCount()

		local max_task_num = task_cfg.task_type == TASK_TYPE.RI and DALIY_MAX_TASK or max_guid_task
		self.max_task_num:SetValue(max_task_num)

		local cur_task_num = self.is_onekey_complete and max_task_num or DayCounterData.Instance:GetDayCount(day_counter_id + 1)
		local day_num = GuildData.Instance:GetRiChangTask()
		self.cur_task_num:SetValue(day_num)
		self.task_type_name:SetValue(Language.Task.task_title[task_cfg.task_type])
		-- self.reward_btn_txt:SetValue(Language.Task.TaskRewardBtnText[2])
		-- self.reward_btn_txt:SetValue(self.is_onekey_complete and Language.Task.TaskRewardBtnText[2] or Language.Task.TaskRewardBtnText[1])
		self.task_type = task_cfg.task_type

		self:SetRewardData(task_cfg.task_type, max_task_num)
		if self.diff_time > 0 then
			self.task_onekey_reward_count:SetValue("x"..self.diff_time)
		end
		self.show_onekey_title:SetValue(self.is_onekey_complete)
	end
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	local diff_time = 5
	if self.count_down == nil then
		local diff_func = function(elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0 then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
					self:OnClickClose()
					return
				end
				self.time:SetValue(left_time)
			end
		diff_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_func)
	end
end
