local CAchieveRewardView = class("CAchieveRewardView", CViewBase)

function CAchieveRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Achieve/AchieveRewardView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CAchieveRewardView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_RewardGrid = self:NewUI(3, CGrid)
	self.m_RewardBox = self:NewUI(4, CBox)
	self.m_AchievePointLabel = self:NewUI(5, CLabel)
	self:InitContent()
end

function CAchieveRewardView.InitContent(self)
	self.m_RewardBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AchievePointLabel:SetText(string.format("成就点数:%d", g_AchieveCtrl:GetCurPoint()))
	self:InitRewardGrid()
end

function CAchieveRewardView.InitRewardGrid(self)
	self.m_RewardGrid:Clear()
	local lRewardPoint = g_AchieveCtrl:GetCopyAchieveReward()
	for i,v in ipairs(lRewardPoint) do
		local oBox = self:InitRewardBox(v)
		oBox:SetActive(true)
		self.m_RewardGrid:AddChild(oBox)
	end
	self.m_RewardGrid:Reposition()
end

function CAchieveRewardView.InitRewardBox(self, dReward)
	local oBox = self.m_RewardBox:Clone()
	oBox.m_RewardSprite = oBox:NewUI(1, CSprite)
	oBox.m_DescLabel = oBox:NewUI(2, CLabel)
	oBox.m_ItemGrid = oBox:NewUI(3, CGrid)
	oBox.m_ItemBox = oBox:NewUI(4, CItemTipsBox)
	oBox.m_GetBtn = oBox:NewUI(5, CButton)
	oBox.m_StateSprite = oBox:NewUI(6, CSprite)
	oBox.m_ID = dReward.id
	oBox.m_ItemBox:SetActive(false)
	oBox.m_GetBtn:SetActive(false)
	oBox.m_StateSprite:SetActive(false)
	oBox.m_DescLabel:SetText(string.format("%d成就点可领取", dReward.point))

	if dReward.get then
		oBox.m_StateSprite:SetActive(true)
	elseif g_AchieveCtrl:GetCurPoint() >= dReward.point then
		oBox.m_GetBtn:SetActive(true)
		oBox.m_StateSprite:SetActive(false)
	else
		oBox.m_StateSprite:SetActive(false)
	end

	oBox.m_GetBtn:AddUIEvent("click", callback(self, "OnGet", oBox.m_ID))
	local rewardlist = dReward.rewarditem
	for i,v in ipairs(rewardlist) do
		local box = oBox.m_ItemBox:Clone()
		box:SetActive(true)
		if string.find(v.sid, "value") then
			local sid, value = g_ItemCtrl:SplitSidAndValue(v.sid)
			box:SetItemData(sid, value, nil, {isLocal = true})
		elseif string.find(v.sid, "partner") then
			local sid, parId = g_ItemCtrl:SplitSidAndValue(v.sid)
			box:SetItemData(sid, v.num, parId, {isLocal = true})
		else
			box:SetItemData(tonumber(v.sid), v.num, nil, {isLocal = true})
		end
		oBox.m_ItemGrid:AddChild(box)
	end
	oBox.m_ItemGrid:Reposition()
	return oBox
end

function CAchieveRewardView.OnGet(self, id, obj)
	printc("领取成就点数奖励:", id)
	g_AchieveCtrl:C2GSAchievePointReward(id)
end

return CAchieveRewardView