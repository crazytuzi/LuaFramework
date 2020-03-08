local PartnerHead = Ui:CreateClass("PartnerHead");

function PartnerHead:SetPlayerPartner(nPartnerId)
	local tbPartner = me.GetPartnerInfo(nPartnerId);
	if not tbPartner then
		self:Clear();
		return;
	end

	self:SetPartnerFace(tbPartner.nNpcTemplateId, tbPartner.nQualityLevel, tbPartner.nLevel, tbPartner.nFightPower);
end

function PartnerHead:SetPlayerPartnerWhithoutLevel(nPartnerId)
	local tbPartner = me.GetPartnerInfo(nPartnerId);
	if not tbPartner then
		self:Clear();
		return;
	end

	self:SetPartnerFace(tbPartner.nNpcTemplateId, tbPartner.nQualityLevel, nil, tbPartner.nFightPower);
end

function PartnerHead:SetPartnerById(nPartnerTemplateId, nLevel, nFightPower, bHideEffect)
	 local szName, nQualityLevel, nNpcTemplateId = GetOnePartnerBaseInfo(nPartnerTemplateId);
	 self:SetPartnerFace(nNpcTemplateId, nQualityLevel, nLevel, nFightPower, bHideEffect);
end

function PartnerHead:SetPartnerInfo(tbPartner)
	self:SetPartnerFace(tbPartner.nNpcTemplateId, tbPartner.nQualityLevel, tbPartner.nLevel, tbPartner.nFightPower);
end

function PartnerHead:SetPartnerFace(nNpcTemplateId, nQualityLevel, nLevel, nFightPower, bHideEffect)
	self.pPanel:SetActive("Face", nNpcTemplateId and true or false);
	if nNpcTemplateId then
		local nFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId);
		local szAtlas, szSprite = Npc:GetFace(nFaceId);
		self.pPanel:Sprite_SetSprite("Face", szSprite, szAtlas);
	end

	self.pPanel:SetActive("QualityLevel", nQualityLevel and true or false);
	if nQualityLevel then
		self.pPanel:Sprite_SetSprite("QualityLevel", Partner.tbQualityLevelToSpr[nQualityLevel]);
	end

	self.pPanel:SetActive("Number", nLevel and true or false);
	if nLevel then
		self.pPanel:Label_SetText("Number", nLevel);
	end

	nFightPower = nFightPower or 1;
	local tbShowInfo = Partner:GetFightPowerShowInfo(nFightPower);
	self.pPanel:SetActive("GrowthBg", true);
	self.pPanel:Sprite_SetSprite("GrowthBg", tbShowInfo[1]);

	self.pPanel:SetActive("GrowthLevel", true);
	self.pPanel:Sprite_SetSprite("GrowthLevel", tbShowInfo[2]);
	local bShowEffect = (not bHideEffect and tbShowInfo[3]) and true or false
	self.pPanel:SetActive("LightAnimation", bShowEffect);

	if bShowEffect then
		self.pPanel:Sprite_Animation("LightAnimation", tbShowInfo[3], Partner.szEffectPrefabPath, 6);
	end
end

function PartnerHead:Clear()
	self:SetPartnerFace();
end