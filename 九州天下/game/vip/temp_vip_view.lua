TempVipView = TempVipView or BaseClass(BaseView)

function TempVipView:__init()
	TempVipView.Instance = self
	self.ui_config = {"uis/views/vipview","TempVipView"}
	self.full_screen = false
	self.time_end = false
	self.play_audio = true
end

function TempVipView:__delete()
	
end

function TempVipView:LoadCallBack()
	self.time_is_end = self:FindVariable("TimeIsEnd")
	self.time_str = self:FindVariable("TimeStr")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("ClickBtn", BindTool.Bind(self.ClickBtn,self))
end

function TempVipView:ReleaseCallBack()
	self.time_is_end = nil
	self.time_str = nil
end

function TempVipView:ClearCountDown()
	if self.count_down_get then
		CountDown.Instance:RemoveCountDown(self.count_down_get)
		self.count_down_get = nil
	end
end

function TempVipView:OpenCallBack()
	self:ClearCountDown()
	TaskCtrl.Instance:SetAutoTalkState(false)
	self.time_is_end:SetValue(self.time_end)

	local str = Language.Vip.NotEndTempVipDes
	if self.time_end then
		str = Language.Vip.EndTempVipDes
	end
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			if not self.time_end then
				VipCtrl.Instance:SendCSFetchTimeLimitVip()
			end
			self:Close()
			self:ClearCountDown()
			return
		end
		local diff_time = math.ceil(total_time - elapse_time)
		local time_str = string.format(str, diff_time)
		self.time_str:SetValue(time_str)
	end
	-- if not self.time_end then
	local total_time = 10				--10秒后自动开启限时vip
	local time_str = string.format(str, total_time)
	self.time_str:SetValue(time_str)
	self.count_down_get = CountDown.Instance:AddCountDown(total_time, 1, timer_func)
	-- end
end

function TempVipView:CloseCallBack()
	self:ClearCountDown()
	TaskCtrl.Instance:SetAutoTalkState(true)
end

function TempVipView:CloseWindow()
	if self.time_end then
		self:Close()
	end
end

function TempVipView:SetIsTimeEnd(value)
	self.time_end = value
end

function TempVipView:ClickBtn()
	if self.time_end then
		ViewManager.Instance:Open(ViewName.SecondChargeView)
	else
		VipData.Instance:SetIsSendLimitVip()
		VipCtrl.Instance:SendCSFetchTimeLimitVip()
	end
	self:Close()
end