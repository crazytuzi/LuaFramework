local CAchieveFinishTipsView = class("CAchieveFinishTipsView", CViewBase)
--~CAchieveFinishTipsView:ShowView()
function CAchieveFinishTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Achieve/AchieveFinishTipsView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_AnimScale = true
end

function CAchieveFinishTipsView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_BGTexture = self:NewUI(2, CTexture)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_DescLabel = self:NewUI(4, CLabel)
	self.m_CloseBtn = self:NewUI(6, CButton)
	self:InitContent()
end

function CAchieveFinishTipsView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_BGTexture:AddUIEvent("click", callback(self, "OnAchieve"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvnet"))
	self:AutoClose()
end

function CAchieveFinishTipsView.OnWarEvnet(self)
	CViewBase.CloseView(self)
end

function CAchieveFinishTipsView.SetAchieve(self, iAchieve)
	self.m_Achieve = iAchieve
	local data = data.achievedata.ACHIEVE[iAchieve]
	self.m_Direction = data.direction
	self.m_Belong = data.belong
	self.m_NameLabel:SetText(data.name)
	self.m_DescLabel:SetText(data.desc)
end

function CAchieveFinishTipsView.OnAchieve(self)
	g_AchieveCtrl:ForceShow(self.m_Direction, self.m_Belong)
	self:CloseView()
end

function CAchieveFinishTipsView.AutoClose(self)
	if self.m_AlphaAction then
		g_ActionCtrl:DelAction(self.m_AlphaAction)
	end
	self.m_AlphaAction = CActionFloat.New(self, 3, "SetAlpha", 1, 0)
	self.m_AlphaAction:SetEndCallback(callback(self, "OnClose"))
	g_ActionCtrl:AddAction(self.m_AlphaAction, 3)
end

return CAchieveFinishTipsView