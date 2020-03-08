local tbUi = Ui:CreateClass("DreamlandLevelUpPanel");

function tbUi:OnOpen(szType, nItemId)
	self.nSelectItemId = nil;
	self.szType = szType
	self.nCostnItemId = nItemId

	local tbViewItemIds , szMsg= self:GetViewItemIds()
	if not tbViewItemIds then
		if szMsg then
			me.CenterMsg(szMsg)
		end
		return 0;
	end
	self:UpdateItemList(tbViewItemIds)
end

function tbUi:GetViewItemIds()
	local pItem = me.GetItemInBag(self.nCostnItemId)
	if not pItem then
		return nil, "无效道具1";
	end

	local dwTemplateId = pItem.dwTemplateId
	if self.szType == "Enhance" then
		self.pPanel:Label_SetText("Title", "装备强化")
		local tbCanEnhacne = InDifferBattle.tbDefine.tbEnhanceScroll[dwTemplateId]
		if not tbCanEnhacne then
			return nil, "无效道具"
		end
		local tbEquipPos = tbCanEnhacne.tbEquipPos
		local tbAllEquips = me.GetEquips();
		local tbViewItemIds = {};
		for i,nEquipPos in ipairs(tbEquipPos) do
			local nStrengthLevel = Strengthen:GetStrengthenLevel(me, nEquipPos);
			if nStrengthLevel < tbCanEnhacne.nMaxEnhance then
				if not tbCanEnhacne.nMinEnhance or nStrengthLevel >= tbCanEnhacne.nMinEnhance then
					table.insert(tbViewItemIds, tbAllEquips[nEquipPos])	
				end
			end
		end
		if not next(tbViewItemIds) then
			return nil, (tbCanEnhacne.nMinEnhance and "已有装备强化等级不足" or  "当前无可以强化的装备")
		end
		return tbViewItemIds
	elseif self.szType == "HorseUpgrade" then
		self.pPanel:Label_SetText("Title", "坐骑进阶")
		local tbHorseUpgrade = InDifferBattle.tbDefine.tbHorseUpgrade
		local pCurHorse = me.GetEquipByPos(Item.EQUIPPOS_HORSE)
		if not pCurHorse then
			return nil, "当前无坐骑";
		end
		if pCurHorse.dwTemplateId ~= tbHorseUpgrade[1] then
			return nil, "当前无可进阶的坐骑";
		end
		return { pCurHorse.dwId }
	elseif self.szType == "BookUpgrade" then
		self.pPanel:Label_SetText("Title", "秘籍进阶")
		local tbViewItemIds = {};
		local tbSkillBook = Item:GetClass("SkillBook");
		for nIndex, nNeedLevel in ipairs(tbSkillBook.tbSkillBookHoleLevel) do
			local nCurEquipPos = nIndex + Item.EQUIPPOS_SKILL_BOOK - 1
			local pEquip = me.GetEquipByPos(nCurEquipPos);
			if pEquip then
				--只显示初级的
				local tbBookInfo = tbSkillBook:GetBookInfo(pEquip.dwTemplateId);
				if tbBookInfo.UpgradeItem > 0 and  tbBookInfo.Type < InDifferBattle.tbDefine.nMaxSkillBookType then
					table.insert(tbViewItemIds, pEquip.dwId)
					pEquip.nCurEquipPos = nCurEquipPos
				end
			end
		end
		if not next(tbViewItemIds) then
			return nil, "当前无可以进阶的秘籍"
		end
		return tbViewItemIds
	end
end

function tbUi:UpdateItemList(tbViewItemIds)
	local fnClickItem = function (goodItem)
		self.nSelectItemId = goodItem.nItemId
		goodItem.pPanel:Toggle_SetChecked("Main", true);
	end

	local fnSetItem = function (itemObj, nIndex)
		for i = 1, 2 do
			local nItemId = tbViewItemIds[ (nIndex - 1) * 2 + i]
			local goodItem = itemObj["Item"..i];
			if nItemId then
				goodItem.pPanel:SetActive("Main", true)
				goodItem.pPanel.OnTouchEvent = fnClickItem;
				goodItem.nItemId = nItemId
				goodItem.pPanel:Toggle_SetChecked("Main", self.nSelectItemId == nItemId);
				local pItem = me.GetItemInBag(nItemId)
				local szItemName, nIcon, nView = Item:GetDBItemShowInfo(pItem, me.nFaction, me.nSex);
				if self.szType == "Enhance" then
					goodItem.pPanel:SetActive("StrengthenLevel", true)
					local nStrengthLevel = Strengthen:GetStrengthenLevel(me, pItem.nEquipPos);
					goodItem.pPanel:Label_SetText("StrengthenLevel", "+" .. nStrengthLevel)
				else
					goodItem.pPanel:SetActive("StrengthenLevel", false)
				end
				goodItem.pPanel:Label_SetText("Name", szItemName)
				goodItem.itemframe:SetItem(nItemId)

			else
				goodItem.pPanel:SetActive("Main", false)
			end
		end

	end

	self.ScrollView:Update(math.ceil(#tbViewItemIds / 2),  fnSetItem);
end

function tbUi:OnRefresh(szUi)
	if self.UI_NAME ~= szUi then
		return
	end
	local tbViewItemIds = self:GetViewItemIds()
	if not tbViewItemIds then
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	self:UpdateItemList(tbViewItemIds)
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnSure()
	if not self.nSelectItemId then
		me.CenterMsg("请选择要进阶的秘籍")
		return
	end
	if self.szType == "Enhance" then
		--检查强化上限
		RemoteServer.InDifferBattleRequestInst("EnhanceEquip", self.nSelectItemId, self.nCostnItemId)
	elseif self.szType == "HorseUpgrade" then
		RemoteServer.InDifferBattleRequestInst("HorseUpgrade", self.nSelectItemId, self.nCostnItemId)
	elseif self.szType == "BookUpgrade" then
		local pItem = me.GetItemInBag(self.nSelectItemId)
		if not pItem or not pItem.nCurEquipPos then
			me.CenterMsg("请先装备秘籍")
			return
		end
		RemoteServer.InDifferBattleRequestInst("BookUpgrade", self.nSelectItemId, self.nCostnItemId, pItem.nCurEquipPos)
	end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_INDIFFER_BATTLE_UI,   self.OnRefresh},
    };

    return tbRegEvent;
end
