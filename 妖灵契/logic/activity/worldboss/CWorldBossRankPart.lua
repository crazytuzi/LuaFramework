local CWorldBossRankPart = class("CWorldBossRankPart", CBox)

function CWorldBossRankPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_RankBox = self:NewUI(1, CBox)
	self.m_WrapContent = self:NewUI(2, CWrapContent)
	self.m_CurRank = self:NewUI(3, CBox)
	self:InitValue()
end

function CWorldBossRankPart.InitValue(self)
	self.m_RankBox:SetActive(false)
	self.m_WrapContent:SetCloneChild(self.m_RankBox, 
		function(oChild)
			oChild.m_NameLabel = oChild:NewUI(1, CLabel)
			oChild.m_Avatar = oChild:NewUI(2, CSprite)
			oChild.m_ScoreLabel = oChild:NewUI(3, CLabel)
			oChild.m_RankLabel = oChild:NewUI(4, CLabel)
			oChild.m_RankSprite = oChild:NewUI(5, CSprite)
			oChild.m_BgSprite = oChild:NewUI(6, CSprite)
			oChild.m_RankLabel:SetActive(false)
			oChild.m_RankSprite:SetActive(false)
			return oChild
		end)
	self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
		if dData then
			oChild:SetActive(true)
			oChild.m_Pid = dData.pid
			if dData.rank == 1 then
				oChild.m_BgSprite:SetSpriteName("pic_paimingditeshu")
			else
				oChild.m_BgSprite:SetSpriteName("pic_paimingdiputong")
			end
			local bSprite = dData.rank < 4
			oChild.m_RankSprite:SetActive(bSprite)
			oChild.m_RankLabel:SetActive(not bSprite)
			if bSprite then
				oChild.m_RankSprite:SetSpriteName("pic_rank_0" .. dData.rank)
			else
				oChild.m_RankLabel:SetText(tostring(dData.rank))
			end
			oChild.m_Avatar:SpriteAvatar(dData.shape)
			oChild.m_NameLabel:SetText(tostring(dData.name))
			oChild.m_ScoreLabel:SetText(tostring(dData.hit or 0))
		else
			oChild:SetActive(false)
		end
	end)
end

function CWorldBossRankPart.SetRankData(self, lData, dMyRank)
	self.m_WrapContent:SetData(lData, true)
	self:RefreshMyRank(dMyRank)
end

function CWorldBossRankPart.RefreshMyRank(self, dMyRank)
	self.m_CurRank.m_NameLabel = self.m_CurRank:NewUI(1, CLabel)
	self.m_CurRank.m_Avatar = self.m_CurRank:NewUI(2, CSprite)
	self.m_CurRank.m_ScoreLabel = self.m_CurRank:NewUI(3, CLabel)
	self.m_CurRank.m_RankLabel = self.m_CurRank:NewUI(4, CLabel)
	self.m_CurRank.m_RankSprite = self.m_CurRank:NewUI(5, CSprite)
	self.m_CurRank.m_RankLabel:SetActive(false)
	self.m_CurRank.m_RankSprite:SetActive(false)
	if dMyRank.rank == 0 then
		self.m_CurRank.m_RankLabel:SetFontSize(21)
		self.m_CurRank.m_RankLabel:SetText("无")
		self.m_CurRank.m_RankLabel:SetActive(true)
	elseif dMyRank.rank < 4 then
		self.m_CurRank.m_RankSprite:SetSpriteName("pic_rank_0" .. dMyRank.rank)
		self.m_CurRank.m_RankSprite:SetActive(true)
	else
		self.m_CurRank.m_RankLabel:SetFontSize(28)
		self.m_CurRank.m_RankLabel:SetText(dMyRank.rank)
		self.m_CurRank.m_RankLabel:SetActive(true)
	end
	self.m_CurRank.m_Avatar:SpriteAvatar(dMyRank.shape)
	self.m_CurRank.m_NameLabel:SetText(tostring(dMyRank.name))
	self.m_CurRank.m_ScoreLabel:SetText(tostring(dMyRank.hit or 0))
end

return CWorldBossRankPart