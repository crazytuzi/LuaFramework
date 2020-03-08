local PartnerCardItem = Ui:CreateClass("PartnerCardItem");
PartnerCardItem.szHalfStart = "GuestStar2"
PartnerCardItem.szFullStart = "GuestStar1"
PartnerCardItem.MAX_STAR_IDX = 5
function PartnerCardItem:SetHeadByCardInfo(nPartnerTempleteId, nLevel, szCardName, nCardPos, nFighting)
	if nPartnerTempleteId then
		self["EntourageHead"].pPanel:SetActive("Main", true)
		local _, nQualityLevel = GetOnePartnerBaseInfo(nPartnerTempleteId);
		local nCardId = PartnerCard:GetCardIdByPartnerTempleteId(nPartnerTempleteId)
		local tbCacheInfo = PartnerCard:GetCardInfo(nCardId) or {}
		local nNpcTemplateId = tbCacheInfo.nNpcTempleteId or 0
		local nFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId);
		local szAtlas, szSprite = Npc:GetFace(nFaceId);
		self["EntourageHead"].pPanel:Sprite_SetSprite("Face", szSprite, szAtlas);
		local szQualitySprite = Partner.tbQualityLevelToSpr[nQualityLevel]
		self["EntourageHead"].pPanel:SetActive("QualityLevel", szQualitySprite and true or false);
		if szQualitySprite then
			self["EntourageHead"].pPanel:Sprite_SetSprite("QualityLevel", szQualitySprite);
		end
	else
		self["EntourageHead"].pPanel:SetActive("Main", false)
	end

	for i = 1, self.MAX_STAR_IDX do
		self.pPanel:SetActive(string.format("SprStar%d", i), false);
	end
	if nLevel then
		self:SetLevel(self, nLevel)
	end
	if self.pPanel:FindChildTransform("Name") then
		if szCardName then
			self.pPanel:SetActive("Name", true);
			self.pPanel:Label_SetText("Name", szCardName)
		else
			self.pPanel:SetActive("Name", false);
		end
	end
	if self.pPanel:FindChildTransform("Mark") then
		self.pPanel:SetActive("Mark", false)
	end
	if self.pPanel:FindChildTransform("RedPoint") then
		self.pPanel:SetActive("RedPoint", false)
	end
	if self.pPanel:FindChildTransform("Toggle") then
		self.pPanel:SetActive("Toggle", false)
	end
	if self.pPanel:FindChildTransform("Fighting") then
		self.pPanel:SetActive("Fighting", false)
		if nFighting then
			self.pPanel:SetActive("Fighting", true)
			self.pPanel:Label_SetText("Fighting", string.format("战力：%d", nFighting))
		end
	end
end

function PartnerCardItem:SetLevel(itemObj, nLevel)
	for i = 1, self.MAX_STAR_IDX do
		itemObj.pPanel:SetActive(string.format("SprStar%d", i), false);
	end
	for j = 1, nLevel do
		local nStartIdx = math.ceil(j/2)
		if nStartIdx > 0 and nStartIdx <= self.MAX_STAR_IDX then
			local szStarName = string.format("SprStar%d", nStartIdx)
			itemObj.pPanel:SetActive(szStarName, true);
			local szStarSprite = self.szHalfStart
			if j % 2 == 0 then
				szStarSprite = self.szFullStart
			end
			itemObj.pPanel:Sprite_SetSprite(szStarName, szStarSprite);
		end
	end
end

function PartnerCardItem:Clear()
	self.nCardId = nil
	self:SetHeadByCardInfo()
end
