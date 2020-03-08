
local tbUi = Ui:CreateClass("PartnerSelectCoverSkill");

function tbUi:OnOpen(nPartnerId, nItemId)
	local bRet, _, tbParam, nMustPos, tbAllowInfo = Partner:CheckCanUseSkillBook(me, nPartnerId, nItemId);
	if not bRet or (nMustPos and nMustPos > 0) or Lib:CountTB(tbAllowInfo) <= 0 then
		return 0;
	end

	self.tbPosList = {};
	for nPos in pairs(tbAllowInfo) do
		table.insert(self.tbPosList, nPos);
	end

	table.sort(self.tbPosList);

	self.nPartnerId = nPartnerId;
	self.nItemId = nItemId;
	self.tbSkillInfo = tbParam.tbSkillInfo;
	for i = 1, 5 do
		local nPos = self.tbPosList[i];
		local nSkillId = (self.tbSkillInfo[nPos or -1] or {}).nSkillId;
		local bShow = false;
		if nSkillId and nSkillId > 0 then
			bShow = true;

			local tbValue, szSkillName = FightSkill:GetSkillShowInfo(nSkillId);
			self.pPanel:Sprite_SetSprite("Skill" .. i, tbValue.szIconSprite, tbValue.szIconAtlas);
			self.pPanel:Label_SetText("SkillName" .. i, szSkillName);

			local tbInfo = Partner:GetSkillInfoBySkillId(nSkillId) or {};
			local szFrameColor = Partner.tbSkillColor[tbInfo.nQuality or 1] or "";
			self.pPanel:Sprite_SetSprite("Color" .. i, szFrameColor);
		end

		self.pPanel:SetActive("SkillItem" .. i, bShow);
	end
end

function tbUi:OnClickItem(nIndex)
	if Ui:WindowVisible("Partner") == 1 then
		local tbUiPartner = Ui("Partner");
		local tbPMain = tbUiPartner.PartnerMainPanel.PartnerMainInfo;
		if tbPMain and tbUiPartner.pPanel:IsActive(tbUiPartner.MAIN_PANEL) and tbPMain.nPartnerId == self.nPartnerId then
			tbPMain:OnSelectCoverSkill(self.nPartnerId, self.nItemId, self.tbPosList[nIndex]);
		end
	end

	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClickSkill(nIndex)
	local nPos = self.tbPosList[nIndex];
	local nSkillId = self.tbSkillInfo[nPos].nSkillId;
	Partner:ShowSkillTips(nSkillId, nSkillLevel);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
for i = 1, 5 do
	tbUi.tbOnClick["SkillItem" .. i] = function (self)
		self:OnClickItem(i);
	end

	tbUi.tbOnClick["Skill" .. i] = function (self)
		self:OnClickSkill(i);
	end
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end
