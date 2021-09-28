WorshipView = WorshipView or BaseClass(BaseView)

function WorshipView:__init()
	self.ui_config = {"uis/views/citycombatview_prefab","WorshipView"}
	self.view_layer = UiLayer.MainUI
end

function WorshipView:__delete()

end

function WorshipView:LoadCallBack()
	self.show_worship = self:FindVariable("ShowWorship")
	self.show_worship:SetValue(true)
	self.is_open_panel = true

	self.cd = self:FindVariable("CD")
	self.is_in_worship = self:FindVariable("IsInWorship")
	self.cdtext = self:FindVariable("CDText")
	self.worshiptimes = self:FindVariable("WorshipTimes")

	self:ListenEvent("Worship",
		BindTool.Bind(self.OnWorship, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.TogglePanel, self))
	self.day_count_change = GlobalEventSystem:Bind(OtherEventType.DAY_COUNT_CHANGE, BindTool.Bind(self.DaycountChange, self))


	local worship_times, _, _ = CityCombatData.Instance:GetGCZWorshipInfo()
	local cfg_num = CityCombatData.Instance:GetWorshipCfgNum()
	if nil ~= cfg_num then
		worship_times = worship_times or 0
		self.worshiptimes:SetValue(cfg_num - worship_times)
	end
end

function WorshipView:ShowIndexCallBack()
	self:Flush()
end

function WorshipView:ReleaseCallBack()
	if self.day_count_change then
		GlobalEventSystem:UnBind(self.day_count_change)
		self.day_count_change = nil
	end

	if nil ~= self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
	end

	self.show_worship = nil
	self.cd = nil
	self.is_in_worship = nil
	self.cdtext = nil
	self.worshiptimes = nil
end

function WorshipView:CloseCallBack()

end

function WorshipView:TogglePanel()
	self.is_open_panel = not self.is_open_panel
	self.show_worship:SetValue(self.is_open_panel)
end

function WorshipView:DaycountChange(day_counter_id)
	self:Flush()
end

function WorshipView:OnFlush()
	local worship_times, next_worship_timestamp, next_interval_addexp_timestamp = CityCombatData.Instance:GetGCZWorshipInfo()
	if nil == worship_times or nil == next_worship_timestamp or nil ==  next_interval_addexp_timestamp then
		return
	end

	if nil ~= self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
	end

	local cd = next_worship_timestamp - TimeCtrl.Instance:GetServerTime()
	self.is_in_worship:SetValue(true)
	self.count_down = CountDown.Instance:AddCountDown(cd, 0.1, BindTool.Bind(self.SetCd, self))

	local cfg_num = CityCombatData.Instance:GetWorshipCfgNum()
	if nil ~= cfg_num then
		self.worshiptimes:SetValue(cfg_num - worship_times)
	end
end

function WorshipView:OnWorship()
	local _, next_worship_timestamp, _ = CityCombatData.Instance:GetGCZWorshipInfo()
	next_worship_timestamp = next_worship_timestamp or TimeCtrl.Instance:GetServerTime()
	if next_worship_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.CD)
		return
	end

	CityCombatCtrl.Instance:SendWorshipReq()
end

function WorshipView:SetCd(elapse_time, total_time)
	if self.cd then
		local left_time = total_time - elapse_time
		if left_time > 0 then
			self.cd:SetValue(left_time / total_time)
			self.cdtext:SetValue(math.ceil(left_time))
		else
			self.is_in_worship:SetValue(false)
			self.cd:SetValue(0)
		end
	end
end

