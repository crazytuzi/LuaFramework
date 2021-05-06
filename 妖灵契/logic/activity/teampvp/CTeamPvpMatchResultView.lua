local CTeamPvpMatchResultView = class("CTeamPvpMatchResultView", CViewBase)

function CTeamPvpMatchResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/TeamPvp/TeamPvpMatchResultView.prefab", cb)
end

function CTeamPvpMatchResultView.OnCreateView(self)
	self.m_PlayerGrid = self:NewUI(1, CGrid)
	self.m_EmeryGrid = self:NewUI(2, CGrid)
	self:InitContent()
end

function CTeamPvpMatchResultView.InitContent(self)
	self.m_PlayerTeamBoxArr = {}
	self.m_OtherTeamBoxArr = {}
	self.m_PlayerGrid:InitChild(function (obj, idx)
		self.m_PlayerTeamBoxArr[idx] = self:CreateInfoBox(obj, idx)
		return self.m_PlayerTeamBoxArr[idx]
	end)
	self.m_EmeryGrid:InitChild(function (obj, idx)
		self.m_OtherTeamBoxArr[idx] = self:CreateInfoBox(obj, idx)
		return self.m_OtherTeamBoxArr[idx]
	end)
	self:SetData()
end

function CTeamPvpMatchResultView.CreateInfoBox(self, obj, idx)
	local oInfoBox = CBox.New(obj)
	oInfoBox.m_PointLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_AvatarSprite = oInfoBox:NewUI(3, CSprite)
	oInfoBox.m_GradeLabel = oInfoBox:NewUI(4, CLabel)

	function oInfoBox.SetData(self, oData)
		oInfoBox.m_PointLabel:SetText(string.format("积分:%s", oData.score))
		oInfoBox.m_NameLabel:SetText(oData.name)
		oInfoBox.m_AvatarSprite:SpriteAvatar(oData.shape)
		oInfoBox.m_GradeLabel:SetText(oData.grade)
	end

	return oInfoBox
end

function CTeamPvpMatchResultView.SetData(self)
	local ownInfo = g_TeamPvpCtrl:GetOwnTeamMatchInfo()
	local otherInfo = g_TeamPvpCtrl:GetOtherTeamMatchInfo()
	for i,v in ipairs(self.m_PlayerTeamBoxArr) do
		if ownInfo[i] then
			v:SetData(ownInfo[i])
		else
			v:SetActive(false)
		end
	end
	for i,v in ipairs(self.m_OtherTeamBoxArr) do
		if otherInfo[i] then
			v:SetData(otherInfo[i])
		else
			v:SetActive(false)
		end
	end
end

return CTeamPvpMatchResultView
