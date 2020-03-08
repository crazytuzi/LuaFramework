local tbUi = Ui:CreateClass("BossRobResult");

function tbUi:OnOpenEnd(tbResult)
	self.pPanel:SetActive("Success", tbResult.bSuccess);
	self.pPanel:SetActive("Failure", not tbResult.bSuccess);

	local tbTarget = tbResult.tbEnemyData;
	local tbBeated = tbResult.tbBeated or {};
	local szResult = "未能重伤目标侠士及同伴，本次没有抢到积分";
	if tbResult.bMainBeated and next(tbBeated) then
		local szFormat = "战斗胜利！重伤目标侠士[FFFE0D]%s[-]，且重伤[FFFE0D]同伴x%d[-]，获得大量积分，本次共夺得[FFFE0D]%d[-]点积分";
		szResult = string.format(szFormat, tbTarget.szName, Lib:CountTB(tbBeated), tbResult.nRobScore);
	elseif tbResult.bMainBeated then
		local szFormat = "战斗胜利！重伤目标侠士[FFFE0D]%s[-]，获得较多积分，本次共夺得[FFFE0D]%d[-]点积分";
		szResult = string.format(szFormat, tbTarget.szName, tbResult.nRobScore);
	elseif next(tbBeated) then
		local szFormat = "战斗胜利！重伤同伴[FFFE0D]%d个[-]，获得少量积分，本次共夺得[FFFE0D]%d[-]点积分";
		szResult = string.format(szFormat, Lib:CountTB(tbBeated), tbResult.nRobScore);
	end
	self.pPanel:Label_SetText("TxtRobScore", szResult);

	local pAsyncData =  KPlayer.GetAsyncData(tbTarget.nPlayerId);
	self.pPanel:Label_SetText("TxtName", tbTarget.szName);
	local szIcon, szIconAtlas = PlayerPortrait:GetPortraitIcon(tbTarget.nPortrait);
	self.RoleContainer:InitHead(szIcon, szIconAtlas, tbTarget.nLevel, tbTarget.nFaction, tbResult.bMainBeated or false);

	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbTarget.nHonorLevel)
	self.pPanel:SetActive("PlayerTitle", ImgPrefix and true);
	self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix or "", Atlas or "");

	local tbPartners = tbResult.tbEnemyPartners or {};
	self.pPanel:SetActive("Partner", next(tbPartners) and true or false);
	for i = 1, Partner.MAX_PARTNER_POS_COUNT do
		local tbPartnerInfo = tbPartners[i];
		if tbPartnerInfo then
			local nPartnerTemplateId, nLevel = unpack(tbPartnerInfo);
			local _, nQualityLevel, nNpcTemplateId = GetOnePartnerBaseInfo(nPartnerTemplateId);
			local _, _, nNpcTemplateId2 = GetOnePartnerBaseInfo(nPartnerTemplateId, 1);
			self["Partner" .. i]:InitPartner(nNpcTemplateId, nQualityLevel, nLevel, tbBeated[nNpcTemplateId] or tbBeated[nNpcTemplateId2] or false);
		end

		self.pPanel:SetActive("Partner" .. i, tbPartnerInfo and true);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnConfirm()
	Ui:CloseWindow("BossRobResult");
end

local tbItemUi = Ui:CreateClass("BossRobResultItem");

function tbItemUi:InitHead(szHead, szAtlas, nLevel, nFaction, bMainBeated)
	self.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas);
	self.pPanel:Label_SetText("lbLevel", nLevel);
	self.pPanel:SetActive("SpFaction", nFaction and true);
	if nFaction then
		self.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(nFaction));
	end

	self.pPanel:SetActive("DyingMark", bMainBeated);
end

function tbItemUi:InitPartner(nNpcTemplateId, nQualityLevel, nLevel, bBeated)
		self["PartnerBg"]:SetPartnerFace(nNpcTemplateId, nQualityLevel, nLevel);
		self.pPanel:SetActive("DyingMark", bBeated);
end
