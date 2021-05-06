	local CWarRT = class("CWarRT", CBox)

function CWarRT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_WarSpeedBox = self:NewUI(1, CWarSpeedControlBox)

	self.m_JumpShowWarBtn = self:NewUI(3, CButton)
	self.m_OrderMenu = self:NewUI(4, CWarOrderMenu)

	self.m_JumpShowWarBtn:AddUIEvent("click", callback(self, "JumpShowWar"))
	self.m_WarSpeedBox:SetAlly(nil)
	self:CheckShow()
	g_GuideCtrl:AddGuideUI("war_speed_box", self.m_WarSpeedBox.m_BgSpr)
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CWarRT.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.Replace then
		self:CheckShow()
	end
end

function CWarRT.Bout(self)
	self:CheckShow()
	self.m_WarSpeedBox:RefreshSpeedList()
end

function CWarRT.CheckShow(self)
	local bActive = g_WarCtrl:IsPrepare() or g_WarCtrl:IsReplace()
	self.m_OrderMenu:SetActive(not bActive and not g_WarCtrl:IsWarStart())
	self.m_JumpShowWarBtn:SetActive(not g_ShowWarCtrl:IsCanOperate())
	self.m_WarSpeedBox:SetActive(g_ShowWarCtrl:IsCanOperate() and (not g_WarCtrl:IsReplace()) and (not g_WarCtrl:IsWarStart()))
		g_GuideCtrl:TriggerCheck("war")
end


function CWarRT.JumpShowWar(self)
	g_GuideCtrl:JumpShowWar()
end

return CWarRT