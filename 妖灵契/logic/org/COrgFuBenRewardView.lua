local COrgFuBenRewardView = class("COrgFuBenRewardView", CViewBase)

function COrgFuBenRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgFuBenRewardView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function COrgFuBenRewardView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_BossScrollView = self:NewUI(2, CScrollView)
	self.m_BossGrid = self:NewUI(3, CGrid)
	self.m_BossBox = self:NewUI(4, CBox)
	self:InitContent()
end

function COrgFuBenRewardView.InitContent(self)
	self.m_BossBox:SetActive(false)
	self:InitBossGrid()
end

function COrgFuBenRewardView.InitBossGrid(self)
	local orgfuben = data.orgdata.OrgFuBen
	local bosslist = {}
	for i,v in pairs(orgfuben) do
		table.insert(bosslist, v)
	end
	table.sort(bosslist, function (a, b)
		return a.id < b.id
	end)

	for i,v in ipairs(bosslist) do
		local oBox = self:InitBossBox(v)
		oBox:SetActive(true)
		self.m_BossGrid:AddChild(oBox)
	end
	self.m_BossGrid:Reposition()
end

function COrgFuBenRewardView.InitBossBox(self, dBoss)
	local oBox = self.m_BossBox:Clone()
	oBox.m_BossSprite = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_RewardGrid = oBox:NewUI(3, CGrid)
	oBox.m_RewardBox = oBox:NewUI(4, CItemTipsBox)
	oBox.m_RewardBox:SetActive(false)

	oBox.m_BossSprite:SpriteAvatar(dBoss.shape)
	oBox.m_NameLabel:SetText(dBoss.name)
	local killRewards = dBoss.kill_reward --orgdata数据
	local rewardlist = data.rewarddata.ORGFUBEN --rewarddata数据
	local rewards
	for i,killReward in ipairs(killRewards) do
		rewards = rewardlist[killReward].reward
		for i,v in ipairs(rewards) do
			local box = oBox.m_RewardBox:Clone()
			box:SetActive(true)
			local sid = v.sid
			local amount = v.amount
			if string.find(sid, "value") then
				sid, amount = g_ItemCtrl:SplitSidAndValue(sid)
			end
			box:SetItemData(tonumber(sid), amount, nil, {isLocal=true})
			oBox.m_RewardGrid:AddChild(box)
		end
	end
	local org_reward = dBoss.org_reward
	for i,v in ipairs(org_reward) do
		local box = oBox.m_RewardBox:Clone()
		box:SetActive(true)
		local sid = v.sid
		local amount = v.amount
		if string.find(sid, "value") then
			sid, amount = g_ItemCtrl:SplitSidAndValue(sid)
		end
		box:SetItemData(tonumber(sid), amount, nil, {isLocal=true})
		oBox.m_RewardGrid:AddChild(box)		
	end
	oBox.m_RewardGrid:Reposition()
	return oBox
end

return COrgFuBenRewardView