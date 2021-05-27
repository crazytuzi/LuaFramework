-- 限时活动开启提醒视图
ActivityOpenStateRemindView = ActivityOpenStateRemindView or BaseClass(XuiBaseView)

function ActivityOpenStateRemindView:__init()
	self.texture_path_list[1] = "res/xui/activity.png"
	self.config_tab = {{"activity_open_state_remind_ui_cfg", 1, {0}}}
	self.is_async_load = false
	self.zorder = -1
	self.cur_idx = 1
	self.cur_act_data = nil
	self.all_acts_data = {}
	self.can_penetrate = true
	self.act_open_state_evt = GlobalEventSystem:Bind(ActivityEventType.ACT_OPEN_STATE_CHANGE, BindTool.Bind(self.SetAllData, self))
end

function ActivityOpenStateRemindView:__delete()
	if self.act_open_state_evt then
		GlobalEventSystem:UnBind(self.act_open_state_evt)
		self.act_open_state_evt = nil
	end
	self:DeleteTimer()
	self.effect = nil
end

function ActivityOpenStateRemindView:ReleaseCallBack()
end

function ActivityOpenStateRemindView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		-- self.root_node:setAnchorPoint(0, 1)
		self.root_node:setPosition(screen_w - 116, 540)
		-- self.node_t_list.rich_content.node:setIgnoreSize(true)
		-- self.node_t_list.rich_content.node:setHorizontalAlignment(RichHAlignment.HA_LEFT)
		
		XUI.AddClickEventListener(self.node_t_list.btn_change.node, BindTool.Bind(self.OnChangeActClicked, self), true)
		self.node_t_list.btn_change.node:setHittedScale(1.03)
		XUI.AddClickEventListener(self.node_t_list.remind_view_bg.node, BindTool.Bind(self.OnLayoutClicked, self), false)
		self.effect = RenderUnit.CreateEffect(44, self.node_t_list.remind_view_bg.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		-- effect:setScaleX(2.5)
		self.effect:setPosition(43,40)
		self.effect:setVisible(true)
	end

	-- self.timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.DelayClose, self), 30)
end

function ActivityOpenStateRemindView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityOpenStateRemindView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ActivityOpenStateRemindView:DelayClose()
	self:Close()
end

function ActivityOpenStateRemindView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:DeleteTimer()
	self.cur_idx = 1
	self.cur_act_data = nil
	self.all_acts_data = {}
end

function ActivityOpenStateRemindView:OnFlush(param_t, index)
	self:FlushInfo()
end

function ActivityOpenStateRemindView:SetAllData(data)
	if SupplyContentionScoreCtrl.Instance.isInSupplyContention == true then
		self:Close()
		return
	end 
	self.all_acts_data = data
	if nil == next(self.all_acts_data) then
		self:Close()
		return
	end
	self.cur_idx = 1
	if not self:IsOpen() then
		self:Open()
	else
		self:FlushInfo()
	end
end

function ActivityOpenStateRemindView:FlushInfo()
	self.node_t_list.layout_change.node:setVisible(#self.all_acts_data > 1)
	local str = #self.all_acts_data
	self.node_t_list.txt_act_num.node:setString(str)
	self.cur_act_data = self.all_acts_data[self.cur_idx]
	if self.cur_act_data == nil then
		return
	end
	local path = ResPath.GetMainui(string.format("act_icon_%d", self.cur_act_data.icon))
	self.node_t_list.img_act_icon.node:loadTexture(path)
	path = ResPath.GetMainui(string.format("act_word_%d", self.cur_act_data.icon))
	self.node_t_list.img_act_name.node:loadTexture(path)
	self.effect:setVisible(true)
	if self.cur_act_data.incoming_time > 0 then
		self:CreateTimer()
		self:FlushRestTime()
	else
		self:DeleteTimer()
		self:SetOpenedStr()
	end
end

function ActivityOpenStateRemindView:SetOpenedStr()
	local color = COLOR3B.BRIGHT_GREEN
	local bottom_str = Language.Activity.Opened
	self.node_t_list.txt_state.node:setString(bottom_str)
	self.node_t_list.txt_state.node:setColor(color)
end

function ActivityOpenStateRemindView:FlushRestTime()
	if self.cur_act_data == nil then return end
	local now_time = ActivityData.GetNowShortTime()
	local incoming_time = self.cur_act_data.incoming_time
	local rest_time = incoming_time - now_time
	local rest_time_str = TimeUtil.FormatSecond2Str(rest_time, 1)
	if rest_time_str ~= "" then
		local color = COLOR3B.RED
		self.node_t_list.txt_state.node:setColor(color)
		self.node_t_list.txt_state.node:setString(rest_time_str)
	else
		self:SetOpenedStr()
	end
end

function ActivityOpenStateRemindView:CreateTimer()
	if self.timer == nil then
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushRestTime, self),  1)
	end
end

function ActivityOpenStateRemindView:DeleteTimer()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function ActivityOpenStateRemindView:GetAllActsData()
	return self.all_acts_data or {}
end

function ActivityOpenStateRemindView:OnLayoutClicked()
	-- ViewManager.Instance:Open(ViewName.Activity)
	-- ActivityCtrl.Instance:SendActiveGuidanceReq(self.item_id)
	if self.cur_act_data then
		ActivityCtrl.Instance:OpenRewardTip(self.cur_act_data)
	end
	self.effect:setVisible(false)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function ActivityOpenStateRemindView:OnChangeActClicked()
	self.cur_idx = ((self.cur_idx + 1) <= #self.all_acts_data) and (self.cur_idx + 1) or 1
	self:FlushInfo()
end

