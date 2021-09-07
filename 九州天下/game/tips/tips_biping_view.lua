TipsBiPingView = TipsBiPingView or BaseClass(BaseView)
function TipsBiPingView:__init()
	self.ui_config = {"uis/views/tips/bipingtips", "BiPingTipview"}
end

function TipsBiPingView:LoadCallBack()
	self.hint_box = self:FindVariable("HintBox")
	self.bubble_box = self:FindVariable("BubbleBox")
	self.first_or_second = self:FindVariable("FirstOrSecond")
	self.count_down_text = self:FindVariable("Countdown")
	self.set_bg = self:FindVariable("SetBG")

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickJumpPanel", BindTool.Bind(self.OnClickJumpPanel, self))
	self:ListenEvent("OnClickPrompted", BindTool.Bind(self.OnClickPrompted, self))

	self.use_bind = self:FindObj("UseBind")
end

function TipsBiPingView:ReleaseCallBack()
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.advance_index = nil
	self.hint_box = nil
	self.bubble_box = nil
	self.first_or_second = nil
	self.count_down_text = nil
	self.set_bg = nil
	self.use_bind = nil
end

function TipsBiPingView:OpenCallBack()
	self:Flush()
end

function TipsBiPingView:GetBagUpLVDan()
	local bag_data_list = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(bag_data_list) do
		if item_id == v.item_id then
			rock_num = rock_num + v.num
		end
	end
end

function TipsBiPingView:SetData(advance_index)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if advance_index and vo.level >= 140 then
		self.advance_index = advance_index
		self:Open()
	end
end

function TipsBiPingView:OnClickClose()
	self:Close()
end

function TipsBiPingView:CloseCallBack()

end

function TipsBiPingView:OnFlush()
	if CompetitionActivityData.Instance:GetToggleState() then
		self:Close()
	end
	self:SetTipView()
	self:SetToDayTime()
end

function TipsBiPingView:SetToDayTime()
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
	self.active_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateCountDown, self), 0.5)
end

function TipsBiPingView:UpdateCountDown()
	local server_time = os.date('*t', TimeCtrl.Instance:GetServerTime())
	local hour, min, sec = 23 - server_time.hour, 59 - server_time.min, 59 - server_time.sec
	local time_str = string.format(Language.Competition.count_down_time, hour, min, sec)
	self.count_down_text:SetValue(time_str)
end

function TipsBiPingView:OnClickJumpPanel()
	ViewManager.Instance:Open(ViewName.KaifuActivityView, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP + 100000)
	self:Close()
end

function TipsBiPingView:OnClickPrompted()
	CompetitionActivityData.Instance:SetToggleState(self.use_bind.toggle.isOn)
end

function TipsBiPingView:SetTipView()
	local level = nil
	if self.advance_index then
		if self.advance_index == TabIndex.mount_jinjie then
			level = MountData.Instance:GetMountInfo().grade
		elseif self.advance_index == TabIndex.wing_jinjie then
			level = WingData.Instance:GetWingInfo().grade
		elseif self.advance_index == TabIndex.halo_jinjie then
			level = HaloData.Instance:GetHaloInfo().grade
		elseif self.advance_index == TabIndex.goddess_shengong then
			level = ShengongData.Instance:GetShengongInfo().grade
		elseif self.advance_index == TabIndex.goddess_shenyi then
			level = ShenyiData.Instance:GetShenyiInfo().grade
		end
		self:SetTipViewcfg(level)
	end
end

function TipsBiPingView:SetTipViewcfg(level)
	if level then
		if level < 6 and level > 0 then
			self.hint_box:SetValue(false)
			self.bubble_box:SetValue(true)
			self.set_bg:SetValue(false)
			if level > 0 and level <=3 then
				self.first_or_second:SetValue(false)
			elseif level >= 4 and level < 6 then
				self.first_or_second:SetValue(true)
			end
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			self.count_down = CountDown.Instance:AddCountDown(10, 1, BindTool.Bind(self.CountDown, self))
		elseif level == 6 then
			self.hint_box:SetValue(false)
			self.bubble_box:SetValue(false)
			self.set_bg:SetValue(false)
		else
			self:Close()
		end
	end
end

function TipsBiPingView:SetTipViewFiveLevelcfg()
	self.hint_box:SetValue(true)
	self.bubble_box:SetValue(false)
	self.set_bg:SetValue(true)
end

function TipsBiPingView:CountDown(elapse_time, total_time)
	if total_time == elapse_time then
		self:Close()
	end
end