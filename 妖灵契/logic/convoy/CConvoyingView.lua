local CConvoyingView = class("CConvoyingView", CViewBase)

function CConvoyingView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Convoy/ConvoyingView.prefab", cb)
end

function CConvoyingView.OnCreateView(self)
	self.m_Label = self:NewUI(1, CLabel)
	self:InitContent()
end

function CConvoyingView.OnShowView(self)
	if not g_ConvoyCtrl:IsConvoying() or g_WarCtrl:IsWar() then
		self:DelayCall(0, "OnClose")
	end
end

function CConvoyingView.InitContent(self)
	self.m_count = 0
	self.m_Label:SetText("委托进行中")
	self.m_StrDic = {"·", "··", "···"}
	Utils.AddTimer(callback(self, "ChangeText"), 1, 1)
	g_ConvoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnConvoyEvent"))
end

function CConvoyingView.ChangeText(self)
	self.m_count = (self.m_count + 1) % 4
	self.m_Label:SetText("委托进行中" .. (self.m_StrDic[self.m_count] or ""))
	return true
end

function CConvoyingView.OnConvoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Convoy.Event.UpdateConvoyInfo then
		if not g_ConvoyCtrl:IsConvoying() then
			self:DelayCall(0, "OnClose")
		end
	end
end

return CConvoyingView