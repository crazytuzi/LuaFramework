TipsFocusXingZuoYiJiView = TipsFocusXingZuoYiJiView or BaseClass(BaseView)

function TipsFocusXingZuoYiJiView:__init()
	self.ui_config = {"uis/views/tips/focustips_prefab", "FocusXingZuoYiJiTips"}
	self.view_layer = UiLayer.Pop
	self.prefs_key = nil
end

function TipsFocusXingZuoYiJiView:LoadCallBack()
	self:ListenEvent("close_click", BindTool.Bind(self.CloseClick, self))
	self:ListenEvent("go_click", BindTool.Bind(self.GoClick, self))

	self.time = self:FindVariable("time")
	self.boss_desc = self:FindVariable("boss_desc")
end

function TipsFocusXingZuoYiJiView:ReleaseCallBack()
	self.boss_desc = nil
	self.time = nil
end

function TipsFocusXingZuoYiJiView:OpenCallBack()
	self:Flush()
end

function TipsFocusXingZuoYiJiView:CloseClick()
	self:Close()
end

function TipsFocusXingZuoYiJiView:GetToggleStats()
	if self.no_tip_toggle then
		return self.no_tip_toggle.toggle.isOn or false
	end
	return false
end

function TipsFocusXingZuoYiJiView:GoClick()
	if self.ok_call_back then
		self.ok_call_back()
	end
	-- ViewManager.Instance:CloseAll()
	self:Close()
end

function TipsFocusXingZuoYiJiView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.ok_call_back = nil
end

function TipsFocusXingZuoYiJiView:SetData(ok_callback)
	self.ok_call_back = ok_callback
	self:Flush()
end
function TipsFocusXingZuoYiJiView:OnFlush()
	self:SetPanelValue()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.time:SetValue(15)
	self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusXingZuoYiJiView:CountDown(elapse_time, total_time)
	if self.time then
		self.time:SetValue(total_time - elapse_time)
	end
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end

function TipsFocusXingZuoYiJiView:SetPanelValue()
	self.boss_desc:SetValue(Language.ShengXiao.OpenXingZuoYiJi)
end