local COrgWarRankView = class("COrgWarRankView", CViewBase)

function COrgWarRankView.ctor(self, cb)
	-- CViewBase.ctor(self, "UI/Org/OrgWarRankView.prefab", cb)
	-- self.m_ExtendClose = "Shelter"
end

function COrgWarRankView.OnCreateView(self)
	-- self.m_Container = self:NewUI(1, CBox)
	-- self.m_HideBtn = self:NewUI(2, CBox)
	-- self.m_Bg = self:NewUI(3, CSprite)
	-- self.m_PlayerRankLabel = self:NewUI(4, CLabel)
	-- self.m_RankBox = self:NewUI(5, CBox)
	-- self.m_MyOrgInfoBox = self:NewUI(6, CBox)
	-- self.m_EnemyOrgInfoBox = self:NewUI(7, CBox)
	-- self.m_ShowBtn = self:NewUI(8, CButton)

	-- self:InitContent()
end

function COrgWarRankView.OnShowView(self)
	self:Refresh()
	self.m_Bg:SetActive(true)
end

function COrgWarRankView.InitContent(self)
	self:InitInfoBox(self.m_MyOrgInfoBox)
	self:InitInfoBox(self.m_EnemyOrgInfoBox)
	self.m_HideBtn:AddUIEvent("click", callback(self, "HideBg"))
	self.m_ShowBtn:AddUIEvent("click", callback(self, "GetData"))
	g_OrgWarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgWarEvent"))
end

function COrgWarRankView.GetData(self)
	printc("GetData")
end

function COrgWarRankView.HideBg(self)
	self.m_Bg:SetActive(false)
end

function COrgWarRankView.InitRankBox(self, oRankBox)
	oRankBox.m_RankLabel = oRankBox:NewUI(1, CLabel)
	oRankBox.m_NameLabel = oRankBox:NewUI(2, CLabel)
	oRankBox.m_PointLabel = oRankBox:NewUI(3, CLabel)

	function oRankBox.SetData(self, oData)
		oRankBox.m_RankLabel:SetText(oData.rank)
		oRankBox.m_RankLabel:SetText(oData.name)
		oRankBox.m_RankLabel:SetText(oData.point)
	end
	return oRankBox
end

function COrgWarRankView.InitInfoBox(self, oInfoBox)
	oInfoBox.m_ScrollView = oInfoBox:NewUI(1, CScrollView)
	oInfoBox.m_WrapContent = oInfoBox:NewUI(2, CWrapContent)
	oInfoBox.m_OrgNameLabel = oInfoBox:NewUI(3, CLabel)

	oInfoBox.m_WrapContent:SetCloneChild(self.m_RankBox, callback(self, "InitRankBox"))
	
	oInfoBox.m_WrapContent:SetRefreshFunc(function(oChild, oData)
		if oData then
			oChild:SetData(oData)
			oChild:SetActive(true)
		else
			oChild:SetActive(false)
		end
	end)

	function oInfoBox.SetData(self, oData)
		oInfoBox.m_OrgNameLabel:SetText(oData.name)
		oInfoBox.m_WrapContent:SetData(oData.rankinfo, true)
	end
end

function COrgWarRankView.SetData(self)
	local oMyOrgInfo = oData[1]
	local oEnemyOrgInfo = oData[2]
	self.m_MyOrgInfoBox:SetData(oMyOrgInfo)
	self.m_EnemyOrgInfoBox:SetData(oEnemyOrgInfo)
	self.m_PlayerRankLabel:SetText(string.format("我的积分：%s  排名：%s", oData.point, (oData.Rank == 0 and oData.Rank or "未上榜")))
end

function COrgWarRankView.Refresh(self)
	self.m_ShowBtn:SetActive(g_OrgWarCtrl:GetRestTime() > 0)
	self:SetData()
end

function COrgWarRankView.OnOrgWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgWarRank then
		self:Refresh()
	end
end


return COrgWarRankView