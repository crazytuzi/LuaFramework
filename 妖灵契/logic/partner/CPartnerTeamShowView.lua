local CPartnerTeamShowView = class("CPartnerTeamShowView", CViewBase)

CPartnerTeamShowView.SortType = 
{
	All = 0,
	SSR = 4, 
	SR = 3,
	R = 2,
	N = 1,
}
CPartnerTeamShowView.Tab = 
{
	[1] = CPartnerTeamShowView.SortType.All,
	[2] = CPartnerTeamShowView.SortType.SSR,
	[3] = CPartnerTeamShowView.SortType.SR,
	[4] = CPartnerTeamShowView.SortType.R,
	[5] = CPartnerTeamShowView.SortType.N,
}

function CPartnerTeamShowView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerTeamShowView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_SortType = CPartnerTeamShowView.SortType.All
	self.m_PartnerBoxList = {}
	self.m_ParId = nil
	self.m_Pos = nil
end

function CPartnerTeamShowView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_FliterGrid = self:NewUI(2, CGrid)
	self.m_PartnerGrid = self:NewUI(3, CGrid)
	self.m_PartnerBox = self:NewUI(4, CBox)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_PartnerScrollView = self:NewUI(6, CScrollView)
	self.m_PartnerBox:SetActive(false)
	self:InitContent()
end

function CPartnerTeamShowView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:InitGrid()
end

function CPartnerTeamShowView.InitGrid(self)
	self.m_FliterGrid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		oBox:SetGroup(self.m_FliterGrid:GetInstanceID())
		oBox:AddUIEvent("click", callback(self, "OnSwitchSort", CPartnerTeamShowView.Tab[index]))
		if CPartnerTeamShowView.Tab[index] == self.m_SortType then
			oBox:SetSelected(true)
		end
		return oBox
	end)
end

function CPartnerTeamShowView.ShowPartner(self, parid, pos)
	self.m_ParId = parid
	self.m_Pos = pos
	self:RefreshAll()
end

function CPartnerTeamShowView.RefreshAll(self)
	self:RefreshPartnerGrid()
end

function CPartnerTeamShowView.RefreshPartnerGrid(self)
	local t = {}
	if self.m_SortType == CPartnerTeamShowView.SortType.All then
		t = g_PartnerCtrl:GetPartners()
	else
		t = g_PartnerCtrl:GetPartnerByRare(self.m_SortType)
	end
	local partnerList = {}
	for k, v in pairs(t) do
		if v:GetValue("parid") ~= self.m_ParId then
			table.insert(partnerList, v)
		end		
	end

	if partnerList and #partnerList > 1 then
		table.sort(partnerList, function (a,b )
			return a:GetValue("power") > b:GetValue("power")
		end)
	end
	if #partnerList > #self.m_PartnerBoxList then
		local count = #partnerList - #self.m_PartnerBoxList
		for i = 1, count do
			local oBox = self.m_PartnerBox:Clone()
			oBox.m_IconSprite = oBox:NewUI(1, CSprite)
			oBox.m_NameLabel = oBox:NewUI(2, CLabel)
			oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
			oBox.m_ScoreLabel = oBox:NewUI(4, CLabel)
			oBox.m_IsWarBox = oBox:NewUI(5, CBox)
			self.m_PartnerGrid:AddChild(oBox)
			table.insert(self.m_PartnerBoxList, oBox)
		end
	end
	for i = 1, #self.m_PartnerBoxList do
		local oBox = self.m_PartnerBoxList[i]
		if i <= #partnerList then
			oBox:SetActive(true)
			self:UpdatePartnerBox(oBox, partnerList[i], i)
			oBox:AddUIEvent("click", callback(self, "OnFight"))
		else
			oBox:SetActive(false)
		end
	end

	self.m_PartnerGrid:Reposition()
	self.m_PartnerScrollView:ResetPosition()
end

function CPartnerTeamShowView.UpdatePartnerBox(self, oBox, dPartner, pos)
	oBox.m_IconSprite:SpriteAvatar(dPartner:GetValue("shape"))
	oBox.m_NameLabel:SetText(dPartner:GetValue("name"))
	oBox.m_GradeLabel:SetText("" .. tostring(dPartner:GetValue("grade")))
	oBox.m_ScoreLabel:SetText("战力:".. tostring(dPartner:GetValue("power")))
	oBox.m_IsWarBox:SetActive(g_PartnerCtrl:IsFight(dPartner:GetValue("parid")))
	oBox.m_IsWar = g_PartnerCtrl:IsFight(dPartner:GetValue("parid"))
	oBox.m_Pos = pos
	oBox.m_ParId = dPartner:GetValue("parid")
end

function CPartnerTeamShowView.OnSwitchSort(self, sortType)
	self.m_SortType = sortType
	self:RefreshPartnerGrid()
end

function CPartnerTeamShowView.OnFight(self, oBox)	
	g_PartnerCtrl:C2GSPartnerFight(self.m_Pos, oBox.m_ParId)
	self:OnClose()
end

return CPartnerTeamShowView