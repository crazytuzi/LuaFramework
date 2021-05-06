local CEndlessPVEWarView = class("CWarEndlessPVEBox", CViewBase)

function CEndlessPVEWarView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/EndlessPVE/EndlessPVEWarView.prefab", cb)
end

function CEndlessPVEWarView.OnCreateView(self)
	self.m_RingInfoLabel = self:NewUI(1, CLabel)
	self.m_CurturnLabel = self:NewUI(2, CLabel)
	self.m_CountDownLabel = self:NewUI(3, CLabel)

	self:InitContent()
end

function CEndlessPVEWarView.InitContent(self)
	self:BeginCount()
	self.m_ParentTimerID = Utils.AddTimer(callback(self, "SetParentView"), 10, 0)
	g_EndlessPVECtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEndlessEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:Bout()
end

function CEndlessPVEWarView.SetParentView(self)
	self.m_ParentView = CWarMainView:GetView()
	if self.m_ParentView ~= nil then
		self.m_Transform:SetParent(self.m_ParentView.m_Transform)
		self.m_ParentTimerID = nil
		return false
	end
	return true
end

function CEndlessPVEWarView.BeginCount(self)
	if self.m_TimerID ~= nil then
		return
	end
	self.m_TimerID = Utils.AddTimer(callback(self, "CountDown"), 1, 0)
end

function CEndlessPVEWarView.Bout(self)
	local s = string.format("第%d回合", g_WarCtrl:GetBout())
	local waveText = g_WarCtrl:GetWaveText()
	if waveText then
		self.m_RingInfoLabel:SetActive(true)
		self.m_RingInfoLabel:SetText(waveText)
	else
		self.m_RingInfoLabel:SetActive(false)
	end
	self.m_CurturnLabel:SetText(s)
end

function CEndlessPVEWarView.CountDown(self)
	self.m_CountDownValue = g_EndlessPVECtrl:GetRestTimeS()
	if self.m_CountDownValue < 0 then
		self.m_TimerID = nil
		return false
	end
	self.m_CountDownLabel:SetText(tostring(string.format("%d:%02d", math.floor(self.m_CountDownValue / 60), (self.m_CountDownValue % 60))))
	return true
end

function CEndlessPVEWarView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.BoutStart then
		self:Bout()
	end
end

function CEndlessPVEWarView.OnEndlessEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EndlessPVE.Event.OnReceiveRingInfo then
		
	elseif oCtrl.m_EventID == define.EndlessPVE.Event.BeginCountDown then
		self:BeginCount()
		self:SetParentView()
	end
end

function CEndlessPVEWarView.Destroy(self)
	if self.m_TimerID ~= nil then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
	if self.m_ParentTimerID ~= nil then
		Utils.DelTimer(self.m_ParentTimerID)
		self.m_ParentTimerID = nil
	end
	CViewBase.Destroy(self)
end

return CEndlessPVEWarView