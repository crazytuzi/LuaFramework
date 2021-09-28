DaFuHaoInfoView = DaFuHaoInfoView or BaseClass(BaseRender)

function DaFuHaoInfoView:__init(instance)

	self.rewards = {}
	for i = 1, 3 do
		self.rewards[i] = {item = ItemCell.New(self:FindObj("NormalItem"..i)), show = self:FindVariable("ShowReward"..i)
		}
	end

	self.scene_name = self:FindVariable("FBName")
	-- self.cur_hour = self:FindVariable("CurHour")
	self.cur_min = self:FindVariable("CurMin")
	self.cur_sec = self:FindVariable("CurSec")
	self.cur_collect_num = self:FindVariable("CurCollectNum")
	self.max_collect_num = self:FindVariable("AllCollectNum")
	-- self.flush_time_hour = self:FindVariable("FlushTimeHour")
	self.flush_time_min = self:FindVariable("FlushTimeMin")
	self.flush_time_sec = self:FindVariable("FlushTimeSec")
	self.special_time = self:FindVariable("SpecialTime")
	self.dafuhao_buff = self:FindVariable("IsDaFuHao")

	self.task_info_content = self:FindObj("TaskAnimator")

	self.ShowPanel = self:FindVariable("ShowPanel")--隐藏任务面板
	-- self.shrink_btn = self:FindObj("ShrinkAnimator")
	-- self.trun_reward_item = ItemCell.New(self:FindObj("TrunRewardItem"))
	-- self.special_item = ItemCell.New(self:FindObj("SpecialItem"))

	-- self.show_special_reward_text = self:FindVariable("ShowSpecialReward")
	self.show_ten_des = self:FindVariable("ShowTenDes")
	-- self.show_get_reward = self:FindVariable("ShowGetReward")
	self:ListenEvent("ClickDaFuHao", BindTool.Bind(self.ClickDaFuHao, self))
	-- self.turn_complete = GlobalEventSystem:Bind(OtherEventType.TURN_COMPLETE, BindTool.Bind(self.TrunComplete, self))
	self.is_dafuhao = false
	self.is_trun_complete = false
	self.is_trun = false
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO,
		BindTool.Bind(self.SwitchButtonState, self))
end

function DaFuHaoInfoView:__delete()
	for k,v in pairs(self.rewards) do
		if v.item then
			v.item:DeleteMe()
		end
	end
	self.rewards = {}
	-- if self.trun_reward_item then
	-- 	self.trun_reward_item:DeleteMe()
	-- 	self.trun_reward_item = nil
	-- end

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.gather_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.gather_count_down)
		self.gather_count_down = nil
	end

	if self.turn_complete ~= nil then
		GlobalEventSystem:UnBind(self.turn_complete)
		self.turn_complete = nil
	end
end

function DaFuHaoInfoView:OpenCallBack()
	self.turn_complete = GlobalEventSystem:Bind(OtherEventType.TURN_COMPLETE, BindTool.Bind(self.TrunComplete, self))
	if MainUICtrl.Instance:GetMenuToggleState() then
		if self.task_info_content then
			self.task_info_content.canvas_group.alpha = 0
		end
	else
		if self.task_info_content then
			self.task_info_content.canvas_group.alpha = 1
		end
	end
	self:Flush()
end

function DaFuHaoInfoView:OnFlush()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if MainUICtrl.Instance:GetMenuToggleState() then
		if self.task_info_content then
			self.task_info_content.canvas_group.alpha = 0
		end
	else
		if self.task_info_content then
			self.task_info_content.canvas_group.alpha = 1
		end
	end
    if main_role_vo.millionare_type and main_role_vo.millionare_type > 0 then
    	self.dafuhao_buff:SetValue(true)
    else
        self.dafuhao_buff:SetValue(false)
    end
end

function DaFuHaoInfoView:CloseCallBack()
	self.diff_time = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.gather_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.gather_count_down)
		self.gather_count_down = nil
	end

	if self.turn_complete ~= nil then
		GlobalEventSystem:UnBind(self.turn_complete)
		self.turn_complete = nil
	end
end

function DaFuHaoInfoView:ClickDaFuHao()
	ViewManager.Instance:Open(ViewName.DaFuHaoRoll)
end

-- 设置活动时间
function DaFuHaoInfoView:SetActivityCountDown()
	local activity_data = ActivityData.Instance:GetActivityStatuByType(DaFuHaoDataActivityId.ID)
	local diff_time = (activity_data and activity_data.next_time or 0) - TimeCtrl.Instance:GetServerTime()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.count_down == nil and diff_time > 0 then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			-- self.cur_hour:SetValue(left_hour)
			self.cur_min:SetValue(left_min)
			self.cur_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function DaFuHaoInfoView:TrunComplete(is_dafuhao)
	local gather_total_times = DaFuHaoData.Instance:GetDaFuHaoInfo().gather_total_times
	local reward_index = DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index or -1

	self.is_trun = true
	self.is_dafuhao = is_dafuhao
	-- self.show_special_reward_text:SetValue(is_dafuhao or false)
	-- if gather_total_times and gather_total_times >= 10 then
	-- 	for k, v in pairs(DaFuHaoData.Instance:GetTurnTableCfg()) do
	-- 		if v.item_index == reward_index then
	-- 			self.is_trun = false
	-- 			if is_dafuhao then
	-- 				-- self.special_item:SetData(v.reward_item)
	-- 			else
	-- 				-- self.show_get_reward:SetValue(true)
	-- 				self.trun_reward_item:SetData(v.reward_item)
	-- 			end
	-- 		end
	-- 	end
	-- end
	self.is_trun_complete = is_dafuhao
end

function DaFuHaoInfoView:Flush( ... )
	BaseRender.Flush(self, ...)
	self:SetActivityCountDown()
	-- local cfg = ActivityData.Instance:GetClockActivityByID(DaFuHaoDataActivityId.ID)
	local cfg = DaFuHaoData.Instance:GetDaFuHaoSpecialRewardCfg()
	for k, v in pairs(self.rewards) do
		if cfg then
			v.item:SetActive(nil ~= cfg["item"..k] and cfg["item"..k].item_id and cfg["item"..k].item_id > 0)
			if cfg["item"..k] then
				v.item:SetData(cfg["item"..k])
			end
		end
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local millionare_type = vo.millionare_type and (vo.millionare_type == 1) or false
	local reward_index = DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index or -1
	if (not self.is_trun and millionare_type) then
		reward_index = 0
	end
	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo()
	local gather_total_times = dafuhao_info.gather_total_times
	if reward_index == -1 then
		reward_index = dafuhao_info.reward_index or -1
	end
	-- self.show_special_reward_text:SetValue(false)
	-- self.show_get_reward:SetValue(false)

	if gather_total_times and gather_total_times >= 10 and not self.is_trun then
		-- self.show_special_reward_text:SetValue(self.is_dafuhao or (not self.is_trun and millionare_type) or false)
		-- for k, v in pairs(DaFuHaoData.Instance:GetTurnTableCfg()) do
		-- 	if v.item_index == reward_index then
		-- 		if self.is_dafuhao or (not self.is_trun and millionare_type) then
		-- 			-- self.special_item:SetData(v.reward_item)
		-- 		else
		-- 			-- self.show_get_reward:SetValue(true)
		-- 			self.trun_reward_item:SetData(v.reward_item)
		-- 		end
		-- 	end
		-- end
	end
	if gather_total_times then
		self.cur_collect_num:SetValue(gather_total_times)
		self.show_ten_des:SetValue(gather_total_times < 10)
	end
	self.max_collect_num:SetValue(DaFuHaoData.Instance:GetDaFuHaoOtherCfg().role_gather_max_time)
	if cfg then
		self.special_time:SetValue(cfg.extra_index)
	end
end

function DaFuHaoInfoView:SwitchButtonState(enable, is_model_list)
	if is_model_list then
		self.root_node:SetActive(enable)
	else
		self.ShowPanel:SetValue(enable)
		-- if self.task_animator then
		-- 	self.task_animator:SetBool("fade", not enable)
		-- end
		if self.task_info_content then
			self.task_info_content.canvas_group.alpha = enable and 1 or 0
		end
	end
end

function DaFuHaoInfoView:GetTime(time)
	local index = string.find(time, ":")
	local next_index = string.find(string.sub(time, index + 1, -1), ":")
	if next_index ~= nil then
		return string.sub(time, 1, index - 1), string.sub(string.sub(time, index + 1, -1), 1, next_index - 1),
				string.sub(string.sub(time, index + 1, -1), next_index + 1, -1)
	end
	return string.sub(time, 1, index - 1), string.sub(time, index + 1, -1)
end