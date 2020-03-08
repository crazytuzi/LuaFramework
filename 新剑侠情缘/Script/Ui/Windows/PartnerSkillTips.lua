local tbSkillShow = Ui:CreateClass("SkillShow");
local tbUi = Ui:CreateClass("PartnerSkillTips");

tbUi.BG_ITEM_MINI_HEIGHT = 250;
tbUi.BG_ITEM_WEIDHT = 500;
tbUi.LA_ITEM_MINI_HEIGHT = 190;
tbUi.LA_ITEM_WEIDHT = 496;
tbUi.tbPanelPos = {-150, 255};

function tbUi:OnOpen(nPartnerId, nSkillIdx)
	self.nPartnerId = nPartnerId;
	local pPartner = me.GetPartnerObj(nPartnerId);
	if not pPartner then
		return 0;
	end

	self.tbSelectList = {};
	self.nSkillIdx = nSkillIdx;
	self.pPanel:SetActive("ItemList", false);
	self:Update(pPartner);

	self.pPanel:SetActive("BtnChangeSkill", true);
	self.pPanel:SetActive("ItemList", false);
end

function tbUi:Update(pPartner)
	self.nPartnerLevel = pPartner.nLevel;
	self.nSkillId, self.nSkillLevel, self.nSkillExp = pPartner.GetSkillInfo(self.nSkillIdx);
	self.nSkillLevel = math.max(self.nSkillLevel, 1);
	self.tbSkillInfo = Partner:GetSkillShowInfo(self.nSkillId, self.nSkillLevel);
	self.tbSkillInfo.bHasNoBtnLevelUp = true;
	self.nCurItemId = nil;
	local nMaxLevel, nCurMaxLevel, nNextLevel = Partner:GetMaxSkillLevel(self.nSkillId, self.nPartnerLevel);
	tbSkillShow.Update(self, nil, true);
	self.pPanel:Label_SetText("TxtDesc", self.tbSkillInfo.szDesc);
end

function tbUi:UpdateSkillBookList(tbItemList)
	local tbItemList = tbItemList or self:GetSkillBookList();
	if #tbItemList <= 0 then
		self.pPanel:SetActive("BtnChangeSkill", true);
		self.pPanel:SetActive("ItemList", false);
		return;
	end

	local function fnOnSelect(itemObj)
		for i = 0, 1000 do
			local item = self.ScrollViewSkillBook.Grid["Item" .. i];
			if not item then
				break;
			end

			item.pPanel:Sprite_SetSprite("Main", item.nItemId == itemObj.nItemId and "BtnListThirdPress" or "BtnListThirdNormal");
		end

		self.nCurItemId = itemObj.nItemId;
	end

	local function fnSetItem(itemObj, index)
		local nItemId = tbItemList[index];
		local pItem = KItem.GetItemObj(nItemId);

		itemObj.nItemId = nItemId;
		itemObj.pPanel:Sprite_SetSprite("Main", itemObj.nItemId == self.nCurItemId and "BtnListThirdPress" or "BtnListThirdNormal");
		itemObj.itemframe:SetItem(nItemId);
		itemObj.itemframe.fnClick = itemObj.itemframe.DefaultClick;
		itemObj.pPanel:Label_SetText("Name", pItem.szName);
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end

	self.ScrollViewSkillBook:Update(tbItemList, fnSetItem);
end

function tbUi:OnUpdatePartner(nPartnerId)
	if nPartnerId ~= self.nPartnerId then
		return;
	end

	local pPartner = me.GetPartnerObj(nPartnerId);
	self:Update(pPartner);

	if self.pPanel:IsActive("ItemList") then
		self:UpdateSkillBookList();
	end
end

function tbUi:GetSkillBookList()
	local tbItemList = {};
	local tbTmp = {};
	local tbAllBook = me.FindItemInBag("PartnerSkillBook");
	for _, pItem in pairs(tbAllBook) do
		if not tbTmp[pItem.dwTemplateId] then
			local bRet, _, _, nMustPos, tbReplaceInfo = Partner:CheckCanUseSkillBook(me, self.nPartnerId, pItem.dwId);
			if bRet and (nMustPos == self.nSkillIdx or (tbReplaceInfo and tbReplaceInfo[self.nSkillIdx])) then
				table.insert(tbItemList, pItem.dwId);
				tbTmp[pItem.dwTemplateId] = true;
			end
		end
	end

	table.sort(tbItemList);
	return tbItemList;
end

function tbUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_PARTNER_UPDATE,	self.OnUpdatePartner},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnChangeSkill = function (self)
	local pPartner = me.GetPartnerObj(self.nPartnerId);
	for i = 1, 5 do
		local nSkillId = pPartner.GetSkillInfo(i);
		if nSkillId <= 0 then
			me.CenterMsg("当前还有技能空位，无需替换");
			return;
		end
	end

	local tbItemList = self:GetSkillBookList();
	if not tbItemList or #tbItemList <= 0 then
		me.CenterMsg("没有符合替换条件的技能书");
		return;
	end

	self.pPanel:SetActive("BtnChangeSkill", false);
	self.pPanel:SetActive("ItemList", true);
	self:UpdateSkillBookList(tbItemList);
end

tbUi.tbOnClick.BtnLearnSkill = function (self)
	if not self.nCurItemId or self.nCurItemId <= 0 then
		me.CenterMsg("请选择要使用的技能书");
		return;
	end

	local bRet, szMsg, _, nMustPos, tbReplaceInfo = Partner:CheckCanUseSkillBook(me, self.nPartnerId, self.nCurItemId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	if (nMustPos > 0 and nMustPos == self.nSkillIdx) or (tbReplaceInfo and tbReplaceInfo[self.nSkillIdx]) then
		RemoteServer.CallPartnerFunc("UseSkillBook", self.nPartnerId, self.nCurItemId, self.nSkillIdx);
	else
		me.CenterMsg("无法替换当前技能");
	end
end


