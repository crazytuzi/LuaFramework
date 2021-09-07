TipsFocusFuBenView = TipsFocusFuBenView or BaseClass(BaseView)

function TipsFocusFuBenView:__init()
	self.ui_config = {"uis/views/tips/focustips", "FocusTips"}

	self.view_layer = UiLayer.Pop
	self.timer_cal = 15
end

function TipsFocusFuBenView:LoadCallBack()
	self:ListenEvent("close_click",
		BindTool.Bind(self.CloseClick, self))
	self:ListenEvent("go_click",
		BindTool.Bind(self.GoClick, self))
	self.time = self:FindVariable("time")
	self.fuben_icon = self:FindVariable("boss_icon")
	self.show_frame = self:FindVariable("show_frame")
	self.fuben_desc = self:FindVariable("boss_desc")
	self.no_mask_icon = self:FindVariable("no_mask_icon")
	self.show_no_mask_icon = self:FindVariable("show_no_mask_icon")
	self.grade_curr = self:FindVariable("GradeCurr")

	self.btn_text = self:FindVariable("btn_text")
	self.show_time = self:FindVariable("show_time")	
end

function TipsFocusFuBenView:ReleaseCallBack()
	self.time = nil
	self.fuben_icon = nil
	self.show_frame = nil
	self.fuben_desc = nil
	self.no_mask_icon = nil
	self.show_no_mask_icon = nil
	self.grade_curr = nil
	self.btn_text = nil
	self.show_time = nil
end

function TipsFocusFuBenView:OpenCallBack()
	self:Flush()
end

function TipsFocusFuBenView:CloseClick()
	self:Close()
end

function TipsFocusFuBenView:GoClick()
	if self.ok_call_back then
		self.ok_call_back()
	end
	self:Close()
end

function TipsFocusFuBenView:CloseCallBack()
	self.is_rune = false
	self.fuben_icon_id = nil
	self.ok_call_back = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

end

function TipsFocusFuBenView:SetData(fuben_icon_id, ok_call_back)
	self.fuben_icon_id = fuben_icon_id
	self.ok_call_back = ok_call_back
	self:Flush()
end

function TipsFocusFuBenView:OnFlush()
	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	self.grade_curr:SetValue(fb_info.pass_level)
	self.show_no_mask_icon:SetValue(true)
	self.show_time:SetValue(true)
	if self.fuben_icon_id then
		local bundle, asset = ResPath.GetfuBenIcon(self.fuben_icon_id)
		self.no_mask_icon:SetAsset(bundle, asset)
	end

	self.fuben_desc:SetValue(Language.FuBen.PataFlushDesc)
	self:CalTime()
end

function TipsFocusFuBenView:CalTime()
	if self.time_quest then
		return
	end

	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer_cal = self.timer_cal - UnityEngine.Time.deltaTime
		if self.timer_cal >= 0 then
			local str = Language.Common.AutoExit
			if nil ~= self.boss_id then
				str = Language.Boss.AutoRefresh
			end
			self.time:SetValue(math.floor(self.timer_cal) .. str)
		end
		if self.timer_cal < 0 then
			self:CloseClick()
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end, 0)
end

function TipsFocusFuBenView:SetCountdown(time)
	self.timer_cal = time or 15
end