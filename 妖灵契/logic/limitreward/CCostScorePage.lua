local CCostScorePage = class("CCostScorePage", CPageBase)

function CCostScorePage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CCostScorePage.OnInitPage(self)
	self.m_ScoreLabel = self:NewUI(1, CLabel)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_ItemBox = self:NewUI(4, CBox)
	self.m_MyPointLabel = self:NewUI(5, CLabel)
	self.m_TimeLabel = self:NewUI(6, CLabel)
	self:InitContent()
end

function CCostScorePage.InitContent(self)
	self.m_ItemBox:SetActive(false)
	self.m_MyPointLabel:SetText("")
	self.m_TimeLabel:SetText("活动暂未开放")
	self:InitItemData()
end

function CCostScorePage.OnShowPage(self)
	netfuli.C2GSGetFuliPointInfo()
end

function CCostScorePage.InitItemData(self)
	local dScoreData = data.welfaredata.CostScoreData
	local dKeys = table.keys(dScoreData)
	self.m_KeyList = dKeys
	self.m_ItemData = {}
	for _, id in ipairs(dKeys) do
		self.m_ItemData[id] = table.copy(dScoreData[id])
	end
end

function CCostScorePage.UpdateCostPoint(self, iPoint, dItemList, version, iPlanID, iStartTime, iEndTime)
	self.m_Version = version
	self.m_Point = iPoint
	for _, id in ipairs(self.m_KeyList) do
		self.m_ItemData[id]["rest"] = -1
	end
	for _, dDict in ipairs(dItemList) do
		self.m_ItemData[dDict.id]["rest"] = dDict.rest
	end
	self.m_PlanList = data.welfaredata.ConsumePlan[iPlanID]["detail"]
	self.m_MyPointLabel:SetText(string.format("当前积分：%d", iPoint))
	self.m_Point = iPoint


	local str1 = os.date("%Y年%m月%d日", iStartTime)
	local str2 = os.date("%Y年%m月%d日", iEndTime)
	self.m_TimeLabel:SetText(str1.."-"..str2)
	self:RefreshData()
end

function CCostScorePage.RefreshData(self, dData)
	self.m_Data = dData
	self.m_Grid:Clear()
	for _, id in ipairs(self.m_PlanList) do
		local itembox = self:CreateItemBox()
		self:RefreshItemBox(itembox, self.m_ItemData[id])
		self.m_Grid:AddChild(itembox)
	end
	self.m_Grid:Reposition()
end

function CCostScorePage.CreateItemBox(self)
	local oBox = self.m_ItemBox:Clone()
	oBox:SetActive(true)
	oBox.m_BG = oBox:NewUI(1, CSprite)
	oBox.m_Item = oBox:NewUI(2, CItemTipsBox)
	oBox.m_CostLabel = oBox:NewUI(3, CLabel)
	return oBox
end

function CCostScorePage.RefreshItemBox(self, oBox, dData)
	local iItemID = dData.reward.sid
	local config = {isLocal = true, uiType = 1}
	local iAmount = 0
	local bIsNoLimit = false
	if dData.buy_limit == 0 then
		iAmount = 1
		bIsNoLimit = true
	else
		if dData.rest == -1 then
			iAmount = 1
		else
			iAmount = dData.rest
		end
	end
	oBox.m_Item:SetItemData(iItemID, iAmount, nil, config)
	if iAmount == 0 then
		oBox.m_Item.m_CountLabel:SetActive(true)
		oBox.m_Item.m_CountLabel:SetNumberString("0")
	end
	oBox.m_CostLabel:SetText(string.format("积分：%d", dData.point))
	if bIsNoLimit then
		iAmount = 200
	end
	oBox.m_Item:AddUIEvent("click", callback(self, "OnBuyItem", dData.id, iItemID, dData.point, iAmount))
	oBox.m_BG:AddUIEvent("click", callback(self, "OnBuyItem", dData.id, iItemID, dData.point, iAmount))
end

function CCostScorePage.OnBuyItem(self, id, iShape, iPrice, iRestAmount)
	local iVersion = self.m_Version
	CCostScoreBuyView:ShowView(function (oView)
		oView:SetInfo(iShape, iRestAmount, iPrice, self.m_Point)
		oView:SetBuyCb(function (iAmount)
			if iAmount > 0 then
				netfuli.C2GSBuyFuliPointItem(id, iAmount, iVersion)
			end
		end)
	end)
end

return CCostScorePage