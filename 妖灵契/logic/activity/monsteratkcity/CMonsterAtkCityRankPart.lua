local CMonsterAtkCityRankPart = class("CMonsterAtkCityRankPart", CBox)

function CMonsterAtkCityRankPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_BehindTexture = self:NewUI(2, CTexture)
	self.m_WrapContent = self:NewUI(3, CWrapContent)
	self.m_ScrollView = self:NewUI(4, CGrid)
	self.m_RankBox = self:NewUI(5, CBox)
	self.m_PlayerInfoBox = self:NewUI(6, CBox)
	self.m_RefreshInfoLabel = self:NewUI(7, CLabel)
	self.m_RankListPart = self:NewUI(8, CWidget)
	self.m_CountingTips = self:NewUI(9, CLabel)
	self.m_GetingDataSprite = self:NewUI(10, CSprite)
	self:InitContent()
end

function CMonsterAtkCityRankPart.InitContent(self)
	self.m_RankBox:SetActive(false)
	self.m_GetingDataSprite:SetActive(false)
	self.m_CountingTips:SetActive(false)
	self.m_BehindTexture:AddUIEvent("click", callback(self, "ShowPart", false))
	g_MonsterAtkCityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMonsterAtkCityEvnet"))
	self:InitPlayerInfoBox()
	self:InitWrapContent()
end

function CMonsterAtkCityRankPart.OnMonsterAtkCityEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.MonsterAtkCity.Event.Rank then
		if oCtrl.m_EventData["type"] == define.MonsterAtkCity.RankType.RankPart then
			self:RefreshRank(oCtrl.m_EventData["list"])
		end
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.MyRank then
		self:RefreshPlayerInfoBox()
	end
end

function CMonsterAtkCityRankPart.ShowPart(self, bShow)
	if bShow then
		netrank.C2GSGetRankMsattack(define.MonsterAtkCity.RankType.RankPart, 1, 100)
		self:RefreshPlayerInfoBox()
	end
	self:SetActive(bShow)
end

function CMonsterAtkCityRankPart.InitPlayerInfoBox(self)
	local oBox = self.m_PlayerInfoBox
	oBox.m_RankSprite = oBox:NewUI(1, CSprite)
	oBox.m_RankLabel = oBox:NewUI(2, CLabel)
	oBox.m_NameLabel = oBox:NewUI(3, CLabel)
	oBox.m_OrgLabel = oBox:NewUI(4, CLabel)
	oBox.m_ScoreLabel = oBox:NewUI(5, CLabel)
	oBox.m_ItemGrid = oBox:NewUI(6, CGrid)
	oBox.m_ItemClone = oBox:NewUI(7, CItemRewardBox)
	oBox.m_BGSprite = oBox:NewUI(8, CSprite)
	oBox.m_ShapeSprite = oBox:NewUI(9, CSprite)
	oBox.m_ItemClone:SetActive(false)
	oBox.m_ItemGrid:Clear()
end

function CMonsterAtkCityRankPart.InitWrapContent(self)
	self.m_WrapContent:SetCloneChild(self.m_RankBox, 
		function(oBox)
			oBox.m_RankSprite = oBox:NewUI(1, CSprite)
			oBox.m_RankLabel = oBox:NewUI(2, CLabel)
			oBox.m_NameLabel = oBox:NewUI(3, CLabel)
			oBox.m_OrgLabel = oBox:NewUI(4, CLabel)
			oBox.m_ScoreLabel = oBox:NewUI(5, CLabel)
			oBox.m_ItemGrid = oBox:NewUI(6, CGrid)
			oBox.m_ItemClone = oBox:NewUI(7, CItemRewardBox)
			oBox.m_BGSprite = oBox:NewUI(8, CSprite)
			oBox.m_ShapeSprite = oBox:NewUI(9, CSprite)
			oBox.m_ItemClone:SetActive(false)
			oBox.m_ItemGrid:Clear()
			return oBox
		end)
	self.m_WrapContent:SetRefreshFunc(function(oBox, dData)
		if dData then
			dData = table.copy(dData)
			oBox.m_PID = dData.pid
			oBox.m_Name = dData.name
			oBox.m_Shape = dData.shape
			oBox.m_Rank = dData.rank or 0
			oBox.m_Point = dData.point
			oBox.m_School = dData.school
			oBox.m_OrgName = dData.orgname or "无"
			local bSprite = oBox.m_Rank > 0 and oBox.m_Rank < 4
			oBox.m_RankSprite:SetActive(bSprite)
			oBox.m_RankLabel:SetActive(not bSprite)
			if bSprite then
				oBox.m_RankSprite:SetSpriteName("pic_rank_0" .. oBox.m_Rank)
			else
				if oBox.m_Rank > 0 and oBox.m_Rank <= 50 then
					oBox.m_RankLabel:SetText(tostring(oBox.m_Rank))
				else
					oBox.m_RankLabel:SetText("榜外")
				end
			end
			if oBox.m_Rank % 2 == 0 then
				oBox.m_BGSprite:SetSpriteName("pic_rank_di02")
			else
				oBox.m_BGSprite:SetSpriteName("pic_rank_di01")
			end
			oBox.m_NameLabel:SetText(oBox.m_Name)
			oBox.m_ScoreLabel:SetText(oBox.m_Point)
			oBox.m_OrgLabel:SetText(oBox.m_OrgName)
			oBox.m_ShapeSprite:SpriteAvatar(oBox.m_Shape)
			self:RefreshItmeGrid(oBox, oBox.m_Rank)
			oBox:SetActive(true)
		else
			oBox:SetActive(false)
		end
	end)
end

function CMonsterAtkCityRankPart.RefreshPlayerInfoBox(self)
	local oBox = self.m_PlayerInfoBox
	local dData = g_MonsterAtkCityCtrl:GetMyRankInfo()	
	oBox.m_PID = g_AttrCtrl.pid
	oBox.m_Name = g_AttrCtrl.name
	oBox.m_Shape = g_AttrCtrl.model_info.shape
	oBox.m_Rank = dData.rank or 0
	oBox.m_Point = dData.point or 0
	oBox.m_School = g_AttrCtrl.school
	local bSprite = oBox.m_Rank > 0 and oBox.m_Rank < 4
	oBox.m_RankSprite:SetActive(bSprite)
	oBox.m_RankLabel:SetActive(not bSprite)
	if bSprite then
		oBox.m_RankSprite:SetSpriteName("pic_rank_0" .. oBox.m_Rank)
	else
		if oBox.m_Rank > 0 and oBox.m_Rank <= 50 then
			oBox.m_RankLabel:SetText(tostring(oBox.m_Rank))
		else
			oBox.m_RankLabel:SetText("榜外")
		end
	end
	oBox.m_NameLabel:SetText(oBox.m_Name)
	oBox.m_ScoreLabel:SetText(oBox.m_Point)
	if g_AttrCtrl.orgname and g_AttrCtrl.orgname ~= "" then
		oBox.m_OrgLabel:SetText(g_AttrCtrl.orgname)
	else
		oBox.m_OrgLabel:SetText("无")
	end
	oBox.m_ShapeSprite:SpriteAvatar(oBox.m_Shape)
	self:RefreshItmeGrid(oBox, oBox.m_Rank)
end

function CMonsterAtkCityRankPart.RefreshRank(self, list)
	self.m_WrapContent:SetData(list, true)
end

function CMonsterAtkCityRankPart.RefreshItmeGrid(self, oBox, iRank)
	oBox.m_ItemGrid:Clear()
	local dData = data.msattackdata.RankReward
	local dRankReward
	for i=1,#dData-1 do
		if iRank == dData[i].desc then
			dRankReward = dData[i]
		elseif iRank > dData[i].desc and iRank < dData[i+1].desc then
			dRankReward = dData[i+1]
		end
	end
	if dRankReward then
		for i,reward in ipairs(dRankReward.rewardlist) do
			local oItem = oBox.m_ItemClone:Clone()
			oItem:SetActive(true)
			local config = {isLocal = true,}
			oItem:SetItemBySid(reward.sid, reward.num, config)
			oBox.m_ItemGrid:AddChild(oItem)
		end
	end
	oBox.m_ItemGrid:Reposition()
end

return CMonsterAtkCityRankPart