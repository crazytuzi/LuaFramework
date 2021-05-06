local CTerraWarServerRankPage = class("CTerraWarServerRankPage", CPageBase)

function CTerraWarServerRankPage.ctor(self, cb)
	CPageBase.ctor(self, cb)

	self.m_RankID = define.Rank.RankId.TerrawarServer
end

function CTerraWarServerRankPage.OnInitPage(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_ContentWidget = self:NewUI(2, CWidget)
	self.m_ScrollView = self:NewUI(3, CRecyclingScrollView)
	self.m_Cell = self:NewUI(4, CBox)
	self.m_PlayerInfoBox = self:NewUI(5, CBox)
	self.m_RefreshInfoLabel = self:NewUI(6, CLabel)
	self.m_RankListPart = self:NewUI(7, CWidget)
	self.m_CountingTips = self:NewUI(8, CLabel)
	self.m_GetingDataSprite = self:NewUI(9, CSprite)
	self.m_NotJoinTexture = self:NewUI(10, CTexture, false)
	self:InitContent()
end

function CTerraWarServerRankPage.InitContent(self)
	--UITools.ResizeToRootSize(self.m_Container)
	self.m_Cell:SetActive(false)
	self.m_GetingDataSprite:SetActive(false)
	self:PlayerCellInit()
	g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRankCtrl"))
end

function CTerraWarServerRankPage.ShowPage(self)
	CPageBase.ShowPage(self)
	g_RankCtrl:GetDataFromServer(self.m_RankID, 1, g_AttrCtrl.org_id)
end

function CTerraWarServerRankPage.OnRankCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Rank.Event.ReceiveEmptyData then
		if oCtrl.m_EventData.ranklistId == define.Rank.RankId.TerrawarServer then
			self:RefreshServerRank()
		end
	elseif oCtrl.m_EventID == define.Rank.Event.ReceiveData then
		if oCtrl.m_EventData.ranklistId == self.m_RankID then
			--非本页刷新数据
			self:RefreshServerRank()
			--self:OnChangeTab(oCtrl.m_EventData.ranklistId)
		else
			if self.m_GetDataTimeUp then
				self:AfterGetData(oCtrl.m_EventData)
			else
				self.m_GetDataCallbackData = oCtrl.m_EventData
			end
		end
	elseif oCtrl.m_EventID == define.Rank.Event.RefreshData then
		--数据过期刷新
		g_NotifyCtrl:FloatMsg("排行榜数据已刷新")
		--self:OnChangeTab(oCtrl.m_EventData.ranklistId)
		self:RefreshServerRank()
	-- elseif oCtrl.m_EventID == define.Rank.Event.ClearAll then
		-- g_NotifyCtrl:FloatMsg("排行榜数据已刷新")
		-- self.m_Location = 1
		-- g_RankCtrl:GetDataFromServer(self.m_RankID, 1)
	elseif oCtrl.m_EventID == define.Rank.Event.ReceiveEmptyData then
		--self:OnChangeTab(oCtrl.m_EventData.ranklistId)
		self:RefreshServerRank()
	end
end

function CTerraWarServerRankPage.PlayerCellInit(self)
	self.m_PlayerInfoBox.m_RankSprite = self.m_PlayerInfoBox:NewUI(1, CSprite)
	self.m_PlayerInfoBox.m_RankLabel = self.m_PlayerInfoBox:NewUI(2, CLabel)
	self.m_PlayerInfoBox.m_OrgNameLabel = self.m_PlayerInfoBox:NewUI(3, CLabel)
	self.m_PlayerInfoBox.m_OrgFlagLabel = self.m_PlayerInfoBox:NewUI(4, CLabel)
	self.m_PlayerInfoBox.m_ScoreLabel = self.m_PlayerInfoBox:NewUI(5, CLabel)
	self.m_PlayerInfoBox.m_ItemGrid = self.m_PlayerInfoBox:NewUI(6, CGrid)
	self.m_PlayerInfoBox.m_ItemClone = self.m_PlayerInfoBox:NewUI(7, CItemTipsBox)
	self.m_PlayerInfoBox:SetActive(false)
	self.m_PlayerInfoBox.m_ItemClone:SetActive(false)
	self.m_PlayerInfoBox.m_ItemGrid:Clear()
end

function CTerraWarServerRankPage.RefreshServerRank(self)
	local rankCount = g_RankCtrl:GetRankCount(self.m_RankID)
	self.m_RankInfo = g_RankCtrl:GetRankInfo(self.m_RankID)
	if g_TerrawarCtrl:IsOpenTerrawar() then
		self.m_RefreshInfoLabel:SetText(self.m_RankInfo.refresh_tips)
	else
		self.m_RefreshInfoLabel:SetText("上次据点攻防战结算")
	end
	if rankCount == 0 then
		self.m_PlayerInfoBox:SetActive(false)
		self.m_RankListPart:SetActive(false)
		self.m_CountingTips:SetActive(true)
		return
	else
		self.m_PlayerInfoBox:SetActive(true)
		self.m_RankListPart:SetActive(true)
		self.m_CountingTips:SetActive(false)
	end
	self.m_Data = g_RankCtrl:GetRankData(self.m_RankID)
	self.m_ExtraData = g_RankCtrl:GetExtraData(self.m_RankID)
	self:RefreshPlayerInfoBox()
	self.m_ScrollView:SetData(self.m_ScrollWidget, self.m_RankInfo.per_page, self.m_Cell, callback(self, "CellInit"), callback(self, "CellSetData"))
	self.m_ScrollView:SetCrossPageEvent(self.m_RankInfo.per_page, callback(self, "GetPageData"))
	self.m_ScrollView:SetMaxIndex(rankCount)
end

function CTerraWarServerRankPage.CellInit(self, oBox)
	oBox.m_ParentView = self
	oBox.m_RankSprite = oBox:NewUI(1, CSprite)
	oBox.m_RankLabel = oBox:NewUI(2, CLabel)
	oBox.m_OrgNameLabel = oBox:NewUI(3, CLabel)
	oBox.m_OrgFlagLabel = oBox:NewUI(4, CLabel)
	oBox.m_ScoreLabel = oBox:NewUI(5, CLabel)
	oBox.m_ItemGrid = oBox:NewUI(6, CGrid)
	oBox.m_ItemClone = oBox:NewUI(7, CItemTipsBox)
	oBox.m_BGSprite = oBox:NewUI(8, CSprite)
	oBox.m_OrgFlagBgSprite = oBox:NewUI(9, CSprite)
	oBox.m_ItemClone:SetActive(false)
	oBox.m_ItemGrid:Clear()
end

function CTerraWarServerRankPage.CellSetData(self, oBox, index)
	local dData = self.m_Data[index]
	if dData and dData.org_points > 0 then
		oBox:SetActive(true)
		local iRank = dData.rank
		local bSprite = iRank < 4
		oBox.m_RankSprite:SetActive(bSprite)
		oBox.m_RankLabel:SetActive(not bSprite)
		if bSprite then
			oBox.m_RankSprite:SetSpriteName("pic_rank_0" .. iRank)
		else
			oBox.m_RankLabel:SetText(tostring(iRank))
		end
		oBox.m_OrgNameLabel:SetText(dData.org_name)
		oBox.m_OrgFlagLabel:SetText(dData.flag)
		oBox.m_ScoreLabel:SetText(dData.org_points)
		if index % 2 == 0 then
			oBox.m_BGSprite:SetSpriteName("pic_rank_di02")
		else
			oBox.m_BGSprite:SetSpriteName("pic_rank_di01")
		end
		if dData.orgid == g_AttrCtrl.org_id then
			oBox.m_OrgFlagBgSprite:SetSpriteName("pic_lanse_qizi01")
		else
			oBox.m_OrgFlagBgSprite:SetSpriteName("pic_hongse_qizi01")
		end
		
		self:CellItmeGrid(oBox, iRank)
	else
		oBox:SetActive(false)
	end
	return oBox
end

function CTerraWarServerRankPage.CellItmeGrid(self, oBox, iRank)
	oBox.m_ItemGrid:Clear()
	local dData = data.terrawardata.SERVERREWARD[iRank]
	if dData then
		for i,reward in ipairs(dData.rewardlist) do
			local oItem = oBox.m_ItemClone:Clone()
			oItem:SetActive(true)
			local config = {isLocal = true,}
			local sid = reward.sid
			local num = reward.num
			if string.find(sid, "value") then
				local sid, value = g_ItemCtrl:SplitSidAndValue(sid)
				oItem:SetItemData(sid, value, nil, config)
			elseif string.find(sid, "partner") then
				local sid, parId = g_ItemCtrl:SplitSidAndValue(sid)
				oItem:SetItemData(sid, num, parId, config)
			else
				oItem:SetItemData(sid, num, nil, config)
			end
			oBox.m_ItemGrid:AddChild(oItem)
		end
	end
	oBox.m_ItemGrid:Reposition()
end

function CTerraWarServerRankPage.GetPageData(self, page)
	if g_RankCtrl:GetDataFromServer(self.m_RankID, page) then
		self:ShowGettingData(page)
	end
end

function CTerraWarServerRankPage.ShowGettingData(self, page)
	if self.m_RankInfo.per_page * (page - 1) < g_RankCtrl:GetRankCount(self.m_RankID) then
		self.m_GetingDataSprite:SetActive(true)
		self.m_GetDataTimeUp = false
		self.m_GetDataCallbackData = nil
		self.m_TimerId = Utils.AddTimer(callback(self, "GetDataTimeUp"), 0, 0.5)
	end
end

function CTerraWarServerRankPage.GetDataTimeUp(self)
	self.m_GetDataTimeUp = true
	self.m_TimerId = nil
	if self.m_GetDataCallbackData ~= nil then
		self:AfterGetData(self.m_GetDataCallbackData)
	end
end

function CTerraWarServerRankPage.AfterGetData(self, oData)
	local to = oData.page * self.m_RankInfo.per_page
	local from = to - self.m_RankInfo.per_page + 1
	self.m_ScrollView:AddCanShowSpace(from, to)
	if self.m_Location ~= nil then
		self.m_ScrollView:SetLocation(self.m_Location)
		self.m_Location = nil
	else

	end
	--本页内刷新数据
	self.m_GetingDataSprite:SetActive(false)
end

function CTerraWarServerRankPage.RefreshPlayerInfoBox(self)
	self.m_GetingDataSprite:SetActive(false)
	local dData = g_RankCtrl:GetPlayerRankData(self.m_RankID)
	if dData then
		self.m_PlayerInfoBox:SetActive(true)
		local iRank = dData.my_rank
		local bSprite
		if type(iRank) == "number" then
			iRank = tonumber(iRank)
			bSprite = iRank < 4
			self:CellItmeGrid(self.m_PlayerInfoBox, iRank)
		end
		self.m_PlayerInfoBox.m_RankSprite:SetActive(bSprite)
		self.m_PlayerInfoBox.m_RankLabel:SetActive(not bSprite)
		if bSprite then
			self.m_PlayerInfoBox.m_RankSprite:SetSpriteName("pic_rank_0" .. iRank)
		elseif iRank then
			self.m_PlayerInfoBox.m_RankLabel:SetText(tostring(iRank))
		else
			self.m_PlayerInfoBox.m_RankLabel:SetText("未上榜")
		end
		self.m_PlayerInfoBox.m_OrgNameLabel:SetText(dData.org_name)
		self.m_PlayerInfoBox.m_ScoreLabel:SetText(dData.org_points)
		self.m_PlayerInfoBox.m_OrgFlagLabel:SetText(dData.flag)
		
	else
		self.m_PlayerInfoBox:SetActive(false)
	end
	--公会活动中心的据点战界面特有
	local bAct = g_TerrawarCtrl:IsClose() and dData.org_points == 0
	self.m_ContentWidget:SetActive(not bAct)
	if self.m_NotJoinTexture then
		self.m_NotJoinTexture:SetActive(bAct)
	end	
	if dData.org_points == 0 then
		self.m_PlayerInfoBox.m_ItemGrid:Clear()
		self.m_PlayerInfoBox.m_RankLabel:SetActive(true)
		self.m_PlayerInfoBox.m_RankSprite:SetActive(false)
		self.m_PlayerInfoBox.m_RankLabel:SetText("未上榜")
	end
end

return CTerraWarServerRankPage