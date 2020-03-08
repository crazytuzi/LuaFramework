local tbUi = Ui:CreateClass("PartnerExpUse");

tbUi.tbExpItemInfo = {601, 1016, 1342};
tbUi.nSpeed = 20;	-- 每秒吃多少经验书

function tbUi:OnOpen(nPartnerId)
	local nCount = 0;
	for _, nItemId in pairs(self.tbExpItemInfo) do
		nCount = me.GetItemCountInAllPos(nItemId);
		if nCount > 0 then
			break;
		end
	end

	if nCount <= 0 then
		me.MsgBox("[FFFE0D]同伴经验药水[-]不足，是否前往商城购买？",
		{
			{"前往", function () Shop:AutoChooseItem(1016) end },
			{"取消"}
		});
		return 0;
	end

	self.nPartnerId = nPartnerId;
	self.tbPartner = me.GetPartnerInfo(nPartnerId or 0);

	self:Update();
	if not self.tbPartner then
		return 0;
	end

	if self.tbPartner.nLevel >= Partner.MAX_LEVEL then
		me.CenterMsg("此同伴已满级");
		return 0;
	end
end

function tbUi:CheckPartnerUiOK()
	if Ui:WindowVisible("Partner") ~= 1 then
		return false;
	end

	local tbUiPartner = Ui("Partner");
	local tbPMain = tbUiPartner.PartnerMainPanel;
	if not tbPMain or not tbUiPartner.pPanel:IsActive(tbUiPartner.MAIN_PANEL) then
		return false;
	end

	if not tbPMain.nCurPartnerId or not self.nPartnerId or self.nPartnerId ~= tbPMain.nCurPartnerId then
		return false;
	end

	return true, tbPMain.pPanel;
end

function tbUi:SetExpInfo()
	local bRet, pPanel = self:CheckPartnerUiOK();
	if not bRet then
		return false;
	end

	pPanel:Sprite_SetFillPercent("ExpBar", self.nLevelUpExp and self.nExp / self.nLevelUpExp or 0);
	pPanel:Label_SetText("ExpPercent", self.nLevelUpExp and string.format("%s / %s", self.nExp, self.nLevelUpExp) or "- / -");
	if version_tx then
		pPanel:Label_SetText("Level", string.format("%d级", self.nLevel));
	else
		pPanel:Label_SetText("Level", string.format("Lv.%d", self.nLevel));
	end
	return true;
end

function tbUi:Update()
	self.tbAllItemInfo = {};
	for i = 1, 3 do
		local nItemTemplateId = self.tbExpItemInfo[i] or 0;
		local nItemCount = me.GetItemCountInAllPos(nItemTemplateId);
		local szName, nIcon = Item:GetItemTemplateShowInfo(nItemTemplateId);
		local nExpInfo = Partner:GetExpItemExp(me, nItemTemplateId, self.tbPartner.nQualityLevel, self.tbPartner.nLevel);
		local szAtlas, szSprite = Item:GetIcon(nIcon);
		self.tbAllItemInfo[i] = { nItemTemplateId = nItemTemplateId, nExpInfo = nExpInfo, nItemCount = nItemCount, szName = szName};
		self.pPanel:Label_SetText("ItemCount" .. i, nItemCount > 0 and nItemCount or "[FF0000FF]0[-]");
		self.pPanel:Label_SetText("ItemName" .. i, szName);
		self.pPanel:Label_SetText("ItemInfo" .. i, string.format("+%s同伴经验", nExpInfo));
		self.pPanel:Sprite_SetSprite("ItemIcon" .. i, szSprite, szAtlas);
	end
end

function tbUi:DoPlayAni()
	local nCurTime = os.clock();
	local nDExp = math.floor((nCurTime - self.nLastTime) * self.nCurSpeed);

	self.nExp = self.nExp + nDExp;
	self.nLastTime = nCurTime;

	local nCostCount = math.ceil((nCurTime - self.nStartTime) * self.nSpeed);
	local nCurItemCount = self.tbAllItemInfo[self.nIdx].nItemCount - nCostCount;
	self.pPanel:Label_SetText("ItemCount" .. self.nIdx, nCurItemCount > 0 and nCurItemCount or "[FF0000FF]0[-]");

	if self.nExp > self.nLevelUpExp then
		self.nExp = self.nExp - self.nLevelUpExp;
		self.nLevel = self.nLevel + 1;
		self.nLevelUpExp = Partner:GetLevelupExp(self.tbPartner.nQualityLevel, self.nLevel);
	end

	local nItemTemplateId = self.tbAllItemInfo[self.nIdx].nItemTemplateId;
	self.nCurSpeed = Partner:GetExpItemExp(me, nItemTemplateId, self.tbPartner.nQualityLevel, self.nLevel) * self.nSpeed;

	local bRet = self:SetExpInfo();
	if not bRet or not self.bIsPress or nCostCount >= self.nMaxCount or nCurItemCount <= 0 or self.nLevel >= Partner.MAX_LEVEL then
		self.nPlayAniTimerId = nil;
		self:ClcUseItem(not bRet);
		return;
	end

	self.nPlayAniTimerId = Timer:Register(1, self.DoPlayAni, self);
end

function tbUi:StartTimer(nIdx)
	if not self.bIsPress then
		return;
	end

	local nMaxCount = Partner:GetMaxUseItemCount(me, self.nPartnerId, self.tbAllItemInfo[nIdx].nItemTemplateId);
	if nMaxCount <= 0 then
		me.CenterMsg("同伴等级不允许超过玩家等级");
		return;
	end

	self.nIdx = nIdx;
	self.nCurSpeed = Partner:GetExpItemExp(me, self.tbAllItemInfo[nIdx].nItemTemplateId, self.tbPartner.nQualityLevel, self.tbPartner.nLevel) * self.nSpeed;
	self.nMaxCount = nMaxCount;
	self.nStartTime = os.clock();
	self.nLevel = self.tbPartner.nLevel;
	self.nLastTime = os.clock();
	self.nExp = self.tbPartner.nExp;
	self.nLevelUpExp = Partner:GetLevelupExp(self.tbPartner.nQualityLevel, self.tbPartner.nLevel);
	self:DoPlayAni();
end

function tbUi:ClcUseItem(bClose)
	if self.nPlayAniTimerId then
		Timer:Close(self.nPlayAniTimerId);
		self.nPlayAniTimerId = nil;
	end

	if bClose then
		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	if not self.nIdx then
		return;
	end

	local tbItemInfo = self.tbAllItemInfo[self.nIdx];
	local nItemCount = math.ceil((os.clock() - self.nStartTime) * self.nSpeed);
	if nItemCount <= 0 then
		return;
	end

	RemoteServer.CallPartnerFunc("DoUseExpItem", self.nPartnerId, tbItemInfo.nItemTemplateId, nItemCount);
	self.nIdx = nil;
end

function tbUi:OnPress(bIsPress, nIdx)
	self.bIsPress = bIsPress;

	if not self.bIsPress then
		self:ClcUseItem();
		return;
	end

	local tbItemInfo = self.tbAllItemInfo[nIdx];
	if not tbItemInfo or tbItemInfo.nItemCount <= 0 then
		me.CenterMsg(string.format("道具数量不足"));
		return;
	end

	self.tbPartner = me.GetPartnerInfo(self.nPartnerId);
	if not self.tbPartner then
		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	self:StartTimer(nIdx);
end

function tbUi:OnDeletePartner(nPartnerId)
	if self.nPartnerId and nPartnerId and nPartnerId == self.nPartnerId then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function tbUi:OnSyncItem()
	self.tbPartner = me.GetPartnerInfo(self.nPartnerId);
	self:Update();
end

function tbUi:OnScreenClick(szClickUi)
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_PARTNER_DELETE,	self.OnDeletePartner},
		{ UiNotify.emNOTIFY_SYNC_ITEM,				self.OnSyncItem},
		{ UiNotify.emNOTIFY_DEL_ITEM,				self.OnSyncItem},
		{ UiNotify.emNOTIFY_SYNC_PARTNER_UPDATE,	self.OnSyncItem},
	};

	return tbRegEvent;
end

function tbUi:OnClose()
	self:ClcUseItem()
end

tbUi.tbOnPress = {};
for i = 1, 3 do
	tbUi.tbOnPress["BtnItem" .. i] = function (self, szBtnName, bIsPress)
		self:OnPress(bIsPress, i);
	end
end
