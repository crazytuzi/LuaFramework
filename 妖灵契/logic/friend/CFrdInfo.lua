local CFrdInfo = class("CFrdInfo", CViewBase)

function CFrdInfo.ctor(self, cb)
	CViewBase.ctor(self, "UI/friend/FrdInfoView.prefab", cb)
	self.m_DepthType = "Dialog"
end

function CFrdInfo.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconBtn = self:NewUI(2, CButton)
	self.m_EquipBtn = self:NewUI(3, CButton)
	self.m_IconPart = self:NewUI(4, CBox)
	self.m_InfoPart = self:NewUI(5, CBox)
	self:InitContent()
	
end

function CFrdInfo.InitContent(self)
	self:InitInfoPart()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CFrdInfo.InitInfoPart(self)
	local infopart = self.m_InfoPart
	self.m_NameLabel = infopart:NewUI(1, CLabel)
	self.m_IDLabel = infopart:NewUI(2, CLabel)
	self.m_GradeLabel = infopart:NewUI(3, CLabel)
	self.m_SchoolLabel = infopart:NewUI(4, CLabel)
	self.m_OrgLabel = infopart:NewUI(5, CLabel)
	self.m_StarLabel = infopart:NewUI(6, CLabel)
	
	self.m_BirthDayLabel = infopart:NewUI(8, CBox)

	self.m_TagGrid = infopart:NewUI(9, CGrid)
	self.m_TagBtn = infopart:NewUI(10, CButton)
	self.m_PosLabel = infopart:NewUI(11, CLabel)
	self.m_SexLabel = infopart:NewUI(12, CLabel)
	self.m_SignLabel = infopart:NewUI(13, CLabel)
	self.m_CopyBtn = infopart:NewUI(15, CButton)
	self:InitBirthBox()
end



function CFrdInfo.OpenView(self)
	CShowView:ShowView()
end

return CFrdInfo