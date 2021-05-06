local CWorldBossRewardView = class("CWorldBossRewardView", CViewBase)

function CWorldBossRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/worldboss/WorldBossRewardView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CWorldBossRewardView.OnCreateView(self)
	self.m_RewardBox = self:NewUI(1, CWorldBossRewardBox)
	self.m_Table = self:NewUI(2, CTable)
	self.m_CloseBtn = self:NewUI(3, CButton)
	--self.m_BehindBlack = self:NewUI(4, CTexture)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	--self.m_BehindBlack:AddUIEvent("click", callback(self, "OnClose"))
end

function CWorldBossRewardView.SetBoss(self, bigboss)
	self:RefreshGrid(bigboss)
	self.m_RewardBox:SetRewardIdx(0)
	self.m_RewardBox:SetBGSprite("pic_xinxiziji")
	self.m_RewardBox:SetRewardSpr("pic_paimingditeshu")
end

function CWorldBossRewardView.RefreshGrid(self, bigboss)
	local i = 1
	while (data.worldbossdata.REWARD[i] ~= nil) do
		local oBox = self.m_RewardBox:Clone()
		oBox:SetRewardIdx(i, bigboss)
		self.m_Table:AddChild(oBox)
		i = i + 1
	end
end

return CWorldBossRewardView