local CTerraWarServerRewardPage = class("CTerraWarServerRewardPage", CPageBase)

function CTerraWarServerRewardPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CTerraWarServerRewardPage.OnInitPage(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_ContentWidget = self:NewUI(2, CWidget)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_TotalTable = self:NewUI(4, CTable)
	self.m_TitleLabelClone = self:NewUI(5, CLabel)
	self.m_DescLabelClone = self:NewUI(6, CLabel)
	self.m_RewardClone = self:NewUI(7, CBox)
	self:InitContent()
end

function CTerraWarServerRewardPage.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_TitleLabelClone:SetActive(false)
	self.m_DescLabelClone:SetActive(false)
	self.m_RewardClone:SetActive(false)
	self:InitTotalTable()
end

function CTerraWarServerRewardPage.InitTotalTable(self)
	self:InitServerBox()
	
	self.m_TotalTable:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CTerraWarServerRewardPage.InitServerBox(self)
	local list = data.terrawardata.SERVERREWARD

	local titlelabel = self.m_TitleLabelClone:Clone()
	titlelabel:SetActive(true)
	titlelabel:SetText("全服奖励")
	self.m_TotalTable:AddChild(titlelabel)

	for i,v in ipairs(list) do
		local oBox = self.m_RewardClone:Clone()
		oBox:SetActive(true)
		oBox.m_RankLabel = oBox:NewUI(1, CLabel)
		oBox.m_ItemGrid = oBox:NewUI(2, CGrid)
		oBox.m_ItemClone = oBox:NewUI(3, CItemTipsBox)
		oBox.m_ItemClone:SetActive(false)
		oBox.m_RankLabel:SetText(v.desc)
		for j,reward in ipairs(v.rewardlist) do
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
		self.m_TotalTable:AddChild(oBox)
	end
end

return CTerraWarServerRewardPage