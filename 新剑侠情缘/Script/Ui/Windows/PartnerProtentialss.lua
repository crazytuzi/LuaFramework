Require("CommonScript/Partner/PartnerDef.lua");

local tbUi = Ui:CreateClass("PartnerProtential");

tbUi.tbType = {
	Partner.POTENTIAL_TYPE_VITALITY,
	Partner.POTENTIAL_TYPE_DEXTERITY,
	Partner.POTENTIAL_TYPE_STRENGTH,
	Partner.POTENTIAL_TYPE_ENERGY,
}

function tbUi:OnOpen(nPartnerId, szType)
	self.nPartnerId = nPartnerId;
	local tbPartnerInfo = me.GetPartnerInfo(self.nPartnerId or -1);
	if not tbPartnerInfo then
		return 0;
	end

	local nProtentialType = Partner.tbAllProtentialTypeStr2Id[szType];
	if nProtentialType then
		for nIdx, nType in pairs(self.tbType) do
			if nType == nProtentialType then
				self.nIdx = nIdx
				break;
			end
		end
	end

	local pPartner = me.GetPartnerObj(self.nPartnerId);
	local tbPAttribInfo = pPartner.GetAttribInfo();
	self.pPanel:Toggle_SetChecked("Toggle1", true);
	self.pPanel:Toggle_SetChecked("Toggle2", false);
	self:Update(tbPartnerInfo, tbPAttribInfo);
end

function tbUi:OnClose()
	self.nIdx = nil;
end

function tbUi:Update(tbPartnerInfo, tbPAttribInfo)
	self.PartnerHead:SetPartnerInfo(tbPartnerInfo);
	self.pPanel:Label_SetText("PartnerName", tbPartnerInfo.szName);
	if version_tx then
		self.pPanel:Label_SetText("Level", string.format("%s级", tbPartnerInfo.nLevel));
	else
		self.pPanel:Label_SetText("Level", string.format("Lv.%s", tbPartnerInfo.nLevel));
	end

	self:UpdateItemInfo();

	for i = 1, 4 do
		local nType = self.tbType[i];
		local szType = Partner.tbAllProtentialType[nType];
		local nProtential = tbPAttribInfo["n" .. szType];
		local nLimitLevel = tbPartnerInfo["nLimitProtential" .. szType];
		local nLimitProtential, bIsMaxGrade = Partner:GetLimitProtentialValue(tbPartnerInfo.nQualityLevel,
														tbPartnerInfo.nGrowthType,
														Partner.tbAllProtentialTypeStr2Id[szType],
														nLimitLevel,
														tbPartnerInfo.nGradeLevel + 1,
														Partner:GetPartnerAwareness(me, tbPartnerInfo.nTemplateId));
		local nMaxProtential = tbPAttribInfo["n" .. szType] + math.max(nLimitProtential - math.floor(tbPartnerInfo["nProtential" .. szType] / Partner.tbProtentialToValue[tbPartnerInfo.nQualityLevel]), 0);
		nProtential = bIsMaxGrade and math.min(nProtential, nMaxProtential) or nProtential;
		self.pPanel:Label_SetText("QualityPercent" .. i, string.format("%s / %s", nProtential, nMaxProtential));
		self.pPanel:Sprite_SetFillPercent("QualityBar" .. i, nProtential / nMaxProtential);
		self.pPanel:Label_SetText("Character" .. i, Partner.tbPartnerLimitLevelDesc[nLimitLevel] or "--");
	end

	for i = 1, 4 do
		local bRet, szMsg = Partner:CheckCanUseProtentialItem(me, self.nPartnerId, self.tbType[i]);
		self.pPanel:Toggle_SetChecked("Quality" .. i, false);

		if self.nIdx and self.nIdx == i then
			self.pPanel:Toggle_SetChecked("Quality" .. i, bRet);
			self.nIdx = bRet and self.nIdx or nil;
		end
	end
	self.pPanel:Button_SetEnabled("BtnSure", true);
end

function tbUi:UpdateItemInfo()
	local nCount = me.GetItemCountInAllPos(Partner.nPartnerProtentialItem);
	self.itemframe:SetGenericItemTemplate(Partner.nPartnerProtentialItem, 0);
	self.itemframe.fnClick = self.itemframe.DefaultClick;

	self.itemframe.pPanel:SetActive("LabelSuffix", true);

	local szInfo = string.format("%s/1", nCount);
	if nCount < 1 then
		szInfo = "[FF0000FF]".. szInfo .. "[-]";
	end
	self.itemframe.pPanel:Label_SetText("LabelSuffix", szInfo);
end

function tbUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnSelectProtential(nIdx, nProtentialType)
	local nCount = me.GetItemCountInAllPos(Partner.nPartnerProtentialItem);
	if not nCount or nCount <= 0 then
		MarketStall:TipBuyItemFromShop(me, Partner.nPartnerProtentialItem);

		self.pPanel:Toggle_SetChecked("Quality" .. nIdx, false);
		if self.nIdx then
			self.pPanel:Toggle_SetChecked("Quality" .. self.nIdx, true);
		end
		return;
	end

	local bRet, szMsg = Partner:CheckCanUseProtentialItem(me, self.nPartnerId, nProtentialType);
	if not bRet then
		me.CenterMsg(szMsg);

		self.pPanel:Toggle_SetChecked("Quality" .. nIdx, false);
		if self.nIdx then
			self.pPanel:Toggle_SetChecked("Quality" .. self.nIdx, true);
		end
		return;
	end

	self.nIdx = nIdx;
end

function tbUi:OnUpdatePartner(nPartnerId)
	if nPartnerId ~= self.nPartnerId then
		return;
	end

	local tbPartnerInfo = me.GetPartnerInfo(nPartnerId);
	if not tbPartnerInfo then
		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	local pPartner = me.GetPartnerObj(nPartnerId);
	local tbPAttribInfo = pPartner.GetAttribInfo();

	self:Update(tbPartnerInfo, tbPAttribInfo);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_PARTNER_UPDATE,	self.OnUpdatePartner},
		{ UiNotify.emNOTIFY_SYNC_ITEM,				self.UpdateItemInfo},
		{ UiNotify.emNOTIFY_DEL_ITEM,				self.UpdateItemInfo},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
for nIdx, nType in pairs(tbUi.tbType) do
	tbUi.tbOnClick["Quality" .. nIdx] = function (self)
		self:OnSelectProtential(nIdx, self.tbType[nIdx]);
	end
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnSure = function (self)
	local nCount = me.GetItemCountInAllPos(Partner.nPartnerProtentialItem);
	if not nCount or nCount <= 0 then
		MarketStall:TipBuyItemFromShop(me, Partner.nPartnerProtentialItem);
		if self.nIdx then
			self.pPanel:Toggle_SetChecked("Quality" .. self.nIdx, false);
			self.nIdx = nil;
		end
		return;
	end

	local bRet, szMsg = Partner:CheckCanUseProtentialItem(me, self.nPartnerId, self.tbType[self.nIdx] or -1);
	if not bRet then
		if self.nIdx then
			self.pPanel:Toggle_SetChecked("Quality" .. self.nIdx, false);
			self.nIdx = nil;
		end

		me.CenterMsg(szMsg);
		return;
	end

	local nUseCount = self.pPanel:Toggle_GetChecked("Toggle2") and 10 or 1;
	RemoteServer.CallPartnerFunc("BatchUseProtentialItem", self.nPartnerId, self.tbType[self.nIdx], nUseCount);
	self.pPanel:Button_SetEnabled("BtnSure", false);
end
