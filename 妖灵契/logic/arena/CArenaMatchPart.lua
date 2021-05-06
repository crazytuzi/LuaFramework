local CArenaMatchPart = class("CArenaMatchPart", CBox)

function CArenaMatchPart.ctor(self, cb)
	CBox.ctor(self, cb)
	self.m_MatchingPart = self:NewUI(1, CBox)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_ResultPart = self:NewUI(3, CBox)
	self.m_AvatarSprite = self:NewUI(4, CSprite)
	self.m_NameLabel = self:NewUI(5, CLabel)
	self.m_PointLabel = self:NewUI(6, CLabel)

	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))
end

function CArenaMatchPart.ShowMatching(self, isArena)
	self.m_IsArena = isArena
	self:SetActive(true)
	self.m_MatchingPart:SetActive(true)
	self.m_ResultPart:SetActive(false)
end

function CArenaMatchPart.ShowResult(self, data)
	self:SetActive(true)
	self.m_MatchingPart:SetActive(false)
	self.m_ResultPart:SetActive(true)
	self.m_AvatarSprite:SetSpriteName(tostring(data.shape))
	self.m_NameLabel:SetText(data.name)
	self.m_PointLabel:SetText(data.point)
end

function CArenaMatchPart.OnClickCancel(self)
	--发送取消请求
	if self.m_IsArena then
		netarena.C2GSArenaCancelMatch()
	else
		netarena.C2GSEqualArenaCancelMatch()
	end
	-- self:SetActive(false)
end

return CArenaMatchPart
