TipWaBaoDigView = TipWaBaoDigView or BaseClass(BaseView)

function TipWaBaoDigView:__init()
	self.ui_config = {"uis/views/tips/wabaotips_prefab","WaBaoDigTips"}
	self.full_screen = false
	self.play_audio = true
	self.view_layer = UiLayer.MainUI
end

function TipWaBaoDigView:LoadCallBack()
	self.show_bar = self:FindVariable("ShowBar")
	self.set_slider = self:FindVariable("SetSlider")
	self:ListenEvent("OnClickWaBao",BindTool.Bind(self.OnClickWaBao, self))
	self:ListenEvent("OnClose",BindTool.Bind(self.OnClose,self))
end

function TipWaBaoDigView:OpenCallBack()
	self.show_bar:SetValue(false)
end

function TipWaBaoDigView:OnClickWaBao()
	self.show_bar:SetValue(true)
	self:CountDown()
end

function TipWaBaoDigView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.show_bar = nil
	self.set_slider = nil
end

function TipWaBaoDigView:OnClose()
	self:Close()
end

function TipWaBaoDigView:CountDown()
	local timer_cal = 2
	if nil == self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			timer_cal = timer_cal - UnityEngine.Time.deltaTime
			if timer_cal >= 0 then
				self.set_slider:SetValue((2 - timer_cal)/2)
			else
				self.show_bar:SetValue(false)
				local baotu_count = WaBaoData.Instance:GetWaBaoInfo().baotu_count
				if baotu_count > 0 then
					WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_DIG, 0)
				end
				GlobalTimerQuest:CancelQuest(self.time_quest)
				self.time_quest = nil
			end
		end, 0)
	end
end

