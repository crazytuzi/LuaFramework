ClearBlessTipView = ClearBlessTipView or BaseClass(BaseView)

function ClearBlessTipView:__init()
	self.ui_config = {"uis/views/advanceview_prefab", "ClearBlessTip"}
	self.play_audio = true
	self.data = nil
end

function ClearBlessTipView:__delete()

end

function ClearBlessTipView:LoadCallBack()
	self:ListenEvent("ClickOk",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("CloseWindow",
		BindTool.Bind(self.CloseWindow, self))
	self.clear_time = self:FindVariable("ClearTime")
	self.luck_per = self:FindVariable("LuckPer")
	self.luck_per_str = self:FindVariable("LuckPerStr")
	self.grade = self:FindVariable("Grade")
	self.index_name = self:FindVariable("IndexName")
end

function ClearBlessTipView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	-- 清理变量和对象
	self.clear_time = nil
	self.luck_per = nil
	self.luck_per_str = nil
	self.grade = nil
	self.index_name = nil
end

function ClearBlessTipView:OpenCallBack()
	self:Flush()
end

function ClearBlessTipView:CloseWindow()
	self:Close()
end

function ClearBlessTipView:SetData(data)
	self.data = data
	self:Open()
end

function ClearBlessTipView:ShowIndexCallBack(index)

end

function ClearBlessTipView:CloseCallBack()
	if self.data then
		if self.data.call_back then
			if ViewManager.Instance:IsOpen(self.data.view_name) then
				self.data.call_back()
			end
		else
			ViewManager.Instance:Close(self.data.view_name)
		end
	end
	self.data = nil
end

function ClearBlessTipView:OnFlush(param_t)
	if nil == self.data then return end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	self.luck_per_str:SetValue(self.data.cur_val.."/"..self.data.max_val)
	self.luck_per:InitValue(self.data.cur_val/self.data.max_val)
	self.grade:SetValue(self.data.grade)
	self.index_name:SetValue(Language.Advance.ClearBlessName[self.data.view_index] or "")
end

function ClearBlessTipView:FlushNextTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local over_time = TimeUtil.NowDayTimeStart(cur_time) + 3600 * 6
	local time = over_time - cur_time
	if time < 0 then
		time = time + 3600 * 24
	end
	if time > 3600 then
		self.clear_time:SetValue(TimeUtil.FormatSecond(time, 3))
	else
		self.clear_time:SetValue(TimeUtil.FormatSecond(time, 2))
	end
end
