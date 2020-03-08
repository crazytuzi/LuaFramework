local tbUi = Ui:CreateClass("CardPickingItem");

function tbUi:Init(szType, nItemId, fnCardBackTouch, nShowBackLevel, nPartnerId, nCount)
	self.fnCardBackTouch = fnCardBackTouch;
	self.pPanel:SetActive("CardBack", false);
	self.pPanel:Sprite_SetSprite("Card2", "card3");
	self.pPanel:Sprite_SetSprite("CardBack1", "cardback");
	self.pPanel:SetActive("Mark", false);
	self.nItemId = nItemId;
	self.IsItemFlop = false;
	self.Item.fnClick = nil;
	self.nCardId = nil
	local bHadPartnerCardItem = self.pPanel:FindChildTransform("EntourageItem")
	if bHadPartnerCardItem then
		self.pPanel:SetActive("EntourageItem", false);
	end
	if szType == "item" then
		self.pPanel:SetActive("Item", true);
		self.pPanel:SetActive("PartnerHead", false);
		self.Item:SetItemByTemplate(nItemId, 1, me.nFaction);
		self.Item.fnClick = self.Item.DefaultClick;
		nCount = nCount or 1
		local szName = Item:GetItemTemplateShowInfo(nItemId);
		local szItemName = nCount > 1 and string.format("%s*%s", szName, nCount) or szName
		self.pPanel:Label_SetText("TxtResultName", szItemName);
	elseif szType == "Partner" then
		self.pPanel:SetActive("Item", false);
		self.pPanel:SetActive("PartnerHead", true);
		self:InitPartner(nItemId, nShowBackLevel, nPartnerId);
	elseif szType == "PartnerCard" then
		self.pPanel:SetActive("Item", false);
		self.pPanel:SetActive("PartnerHead", false);
		self.pPanel:Sprite_SetSprite("Card2", "NewCard");
		self.pPanel:Sprite_SetSprite("CardBack1", "NewCardBack");
		if bHadPartnerCardItem then
			self.pPanel:SetActive("EntourageItem", true);
			self:InitPartnerCard(nItemId, nShowBackLevel, nCount);
		end
	else
		assert(false);
	end

	self.pPanel:SetActive("Effect", false);
	Timer:Register(3, function ()
		self.pPanel:SetActive("Effect", true);
		if CardPicker:IsItemFlop(szType, nItemId, nShowBackLevel) then
			self.pPanel:SetActive("texiao", false);

			local bIsSEffect = CardPicker:IsItemFlop(szType, nItemId, Partner.tbDes2QualityLevel.S);
			self.pPanel:SetActive("texiao3", bIsSEffect);
			self.pPanel:SetActive("texiao2", not bIsSEffect);
			self.pPanel:PlayParticleSystem("Particle System");
		else
			self.pPanel:SetActive("texiao", true);
			self.pPanel:SetActive("texiao2", false);
			self.pPanel:SetActive("texiao3", false);
			self.pPanel:PlayParticleSystem("shanguang");
		end
	end);
end

function tbUi:InitPartner(nPartnerTemplateId, nShowBackLevel, nPartnerId)
	self.PartnerHead:SetPartnerById(nPartnerTemplateId);
	local szName = GetOnePartnerBaseInfo(nPartnerTemplateId);
	self.pPanel:Label_SetText("TxtResultName", szName);

	if nPartnerId then
		local tbPartnerInfo = me.GetPartnerInfo(nPartnerId);
		local bIsBY = tbPartnerInfo.nIsNormal == 0;
		self.pPanel:SetActive("Mark", bIsBY);
	end

	if CardPicker:IsItemFlop("Partner", nPartnerTemplateId, nShowBackLevel) then
		self.pPanel:SetActive("CardBack", true);
		self.pPanel:SetBoxColliderEnable("CardBack", true);
		self.pPanel:SetActive("PartnerHead", false);

		self.IsItemFlop = true;

		self.nPartnerTemplateId = nPartnerTemplateId;
	end
end

function tbUi:InitPartnerCard(nCardId, nShowBackLevel, nCount)
	nCount = nCount or 1
	local tbCardInfo = PartnerCard:GetCardInfo(nCardId) or {}
	local nPartnerTempleteId = tbCardInfo.nPartnerTempleteId
	if nPartnerTempleteId then
		self["EntourageItem"]:SetHeadByCardInfo(tbCardInfo.nPartnerTempleteId)
		local szName = nCount > 1 and string.format("%s*%s", tbCardInfo.szName, nCount) or tbCardInfo.szName
		self.pPanel:Label_SetText("TxtResultName", szName);
	end
	if CardPicker:IsItemFlop("PartnerCard", nCardId, nShowBackLevel) then
		self.pPanel:SetActive("CardBack", true);
		self.pPanel:SetBoxColliderEnable("CardBack", true);
		self.pPanel:SetActive("EntourageItem", false);

		self.IsItemFlop = true;

		self.nCardId = nCardId;
	end
end


tbUi.tbOnClick = {}

function tbUi.tbOnClick:CardBack(szClickType)
	if not self.IsItemFlop then
		return;
	end
	local bShowBigEffect = false;
	if self.nCardId then
		if PartnerCard:IsHaveCard(me, self.nCardId) then
			if szClickType ~= "FlopAll" then 
				Ui:OpenWindow("CompanionShow", nil, 3, self.nCardId)
				bShowBigEffect = true
			end
		end
	else
		for nKey, nId in pairs(Ui:GetClass("CompanionShow").tbShowCompanion) do
			local pPartner = me.GetPartnerObj(nId);
			if pPartner and pPartner.nTemplateId == self.nPartnerTemplateId then
				if szClickType ~= "FlopAll" then
					bShowBigEffect = true;
					Ui:OpenWindow("CompanionShow",nId,2);
					table.remove(Ui:GetClass("CompanionShow").tbShowCompanion,nKey);
				end
				break;
			end
		end
	end

	self.IsItemFlop = false;
	self.pPanel:PlayUiAnimation("TurnoverCard", false, false, {tostring(self.pPanel)});
	self.pPanel:SetBoxColliderEnable("CardBack", false);

	if self.fnCardBackTouch then
		self.fnCardBackTouch();
	end

	if bShowBigEffect then
		self.pPanel:SetActive("texiao2", false);
		self.pPanel:SetActive("texiao3", false);
		self.pPanel:SetActive("texiao", false);
		if self.nCardId then
			self.pPanel:SetActive("EntourageItem", true);
		else
			self.pPanel:SetActive("PartnerHead", true);
		end
		
	else
		Timer:Register(7, function (nCardId)
			self.pPanel:SetActive("texiao3", false);
			self.pPanel:SetActive("texiao2", false);
			self.pPanel:SetActive("texiao", true);
			self.pPanel:PlayParticleSystem("shanguang");
			if nCardId then
				self.pPanel:SetActive("EntourageItem", true);
			else
				self.pPanel:SetActive("PartnerHead", true);
			end
		end, self.nCardId);
	end
end
