local CWarMainView = class("CWarMainView", CViewBase)

function CWarMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarMainView.prefab", cb)

	self.m_GroupName = "WarMain"
	self.m_DepthType = "Menu"
end

function CWarMainView.OnCreateView(self)
	self.m_Contanier = self:NewUI(1, CWidget)
	self.m_Texture = self:NewUI(2, CTexture)
	UITools.ResizeToRootSize(self.m_Contanier)
	UITools.ResizeToRootSize(self.m_Texture)
	self.m_LT = self:NewUI(3, CWarLT)
	self.m_LB = self:NewUI(4, CWarLB)
	self.m_RT = self:NewUI(5, CWarRT)
	self.m_RB = self:NewUI(6, CWarRB)

	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	--装备副本处理
	g_EquipFubenCtrl:SwitchEnv(true)
end

function CWarMainView.OnShowView(self)
	self:CheckShow()
end

function CWarMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.SectionStart then
		self:Section()
	elseif oCtrl.m_EventID == define.War.Event.BoutStart then
		self:Bout()
	elseif oCtrl.m_EventID == define.War.Event.Replace then
		self:CheckShow()
	end
end

function CWarMainView.CheckShow(self)
	if g_ShowWarCtrl:IsCanOperate() then
		self.m_RB:DelayCall(0, "CheckShow")
		self.m_LB:DelayCall(0, "CheckShow")
	else
		self.m_RB:SetActive(false)
		self.m_LB:SetActive(false)

	end 
	self.m_RT:DelayCall(0, "CheckShow")
end

function CWarMainView.Section(self)
	self:DelayCall(0, "CheckShow")
end

function CWarMainView.Bout(self)
	self.m_LT:SetActive(true)
	self.m_LT:Bout()
	self.m_RT:SetActive(true)
	self.m_RT:Bout()
end

return CWarMainView