
local tbUi = Ui:CreateClass("HorsePanel");

tbUi.tbOnDrag =
{
    ShowRole = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
    end,
}

tbUi.tbOnClick =
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnUnload = function (self)
    	local pItem = me.GetEquipByPos(Item.EQUIPPOS_HORSE)
		if pItem then
			--RemoteServer.UnuseEquip(Item.EQUIPPOS_HORSE)
			Player:ClientUnUseEquip(Item.EQUIPPOS_HORSE )
			Ui:CloseWindow(self.UI_NAME);
		end
    end,
    BtnAdvanced = function (self)
    	Ui:OpenWindow("EquipmentEvolutionPanel", "Type_EvolutionHorse")
		--Ui:CloseWindow(self.UI_NAME);
    end
}

function tbUi:OnOpen(tbEquip)
	if tbEquip then
		local nItemId = tbEquip[Item.EQUIPPOS_HORSE]
	    if not nItemId then
	    	me.CenterMsg("尚未装备坐骑")
	        return 0
	    end
	else
		local pItem = me.GetEquipByPos(Item.EQUIPPOS_HORSE)
		if not pItem then
			me.CenterMsg("尚未装备坐骑")
			return 0
		end
	end

	self.szRideActionName = "hst"
	self.pPanel:NpcView_Open("ShowRole");
	self.tbEquip = tbEquip;
	self:UpdateNpcView();
	self:UpdateAttrib();
	self:UpdateHorseEquip()
end

function tbUi:OnClose()
	self.pPanel:NpcView_Close("ShowRole");
end

function tbUi:UpdateNpcView()
	local nNpcRes;
	local pItem;

	if self.tbEquip then
		pItem = KItem.GetItemObj(self.tbEquip[Item.EQUIPPOS_HORSE]);
	else
		pItem = me.GetEquipByPos(Item.EQUIPPOS_HORSE)
	end

	if pItem then
		nNpcRes = Item:GetHorseShoNpc(pItem.dwTemplateId);
	end
	if nNpcRes then
		self.pPanel:SetActive("ModelTexture", true);
		self.pPanel:NpcView_ShowNpc("ShowRole", nNpcRes);
		self.pPanel:NpcView_SetScale("ShowRole", 0.75);
		self.szRideActionName = KNpc.GetRideActionName(nNpcRes) or "hst";
	else
		self.pPanel:SetActive("ModelTexture", false);
	end
end

function tbUi:UpdateAttrib()
	local tbNormal = {};
	local tbRider = {};
	local bCanEvolution = false;
	local bEvolutionable = false;
	local pItem;
	if self.tbEquip then
		pItem = KItem.GetItemObj(self.tbEquip[Item.EQUIPPOS_HORSE]);
	else
		pItem = me.GetEquipByPos(Item.EQUIPPOS_HORSE);
	end

	if pItem then
		self.pPanel:SetActive("MountsName", true)
		self.pPanel:Label_SetText("MountsName", pItem.szName)

		local szTips = Item:GetClass("horse"):GetHorseEnhanceTips(pItem.dwTemplateId)
		if szTips then
			self.pPanel:SetActive("Tip", true);
			self.pPanel:Label_SetText("Tip", szTips);
		else
			self.pPanel:SetActive("Tip", false);
		end

		local tbAttrib = pItem.GetBaseAttrib()
		for i, tbMA in ipairs(tbAttrib) do
			local szName, szValue = FightSkill:GetMagicDescSplit(tbMA.szName, tbMA.tbValue)
			-- local szDesc = tbEquip:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue, 0);
			if (szName and szName ~= "") then
				if tbMA.nActiveReq == Item.emEquipActiveReq_Ride then
					table.insert(tbRider, {szName, szValue})

				else
					table.insert(tbNormal, {szName, szValue})
				end
			end
		end



	else
		self.pPanel:SetActive("MountsName", false)
	end

	if self.tbEquip then
		self.pPanel:SetActive("BtnUnload", false);
		self.pPanel:SetActive("BtnAdvanced", false)
	else
		self.pPanel:SetActive("BtnUnload", true);
		bEvolutionable = Item.GoldEquip:IsHaveHorseUpgradeItem(me)
		bCanEvolution = Item.GoldEquip:IsShowHorseUpgradeRed(me)

		self.pPanel:SetActive("UpgradeFlag", bCanEvolution);
		self.pPanel:SetActive("BtnAdvanced", bEvolutionable);
	end

	local tbAttribs = {}
	if next(tbNormal) then
		table.insert(tbAttribs, "基础属性")
		Lib:MergeTable(tbAttribs, tbNormal)
	end

	if next(tbRider) then
		table.insert(tbAttribs, "骑乘后激活")
		Lib:MergeTable(tbAttribs, tbRider)
	end

	local fnSetItem = function (itemObj, nIndex)
		local varDesc = tbAttribs[nIndex];
		if type(varDesc) == "string" then
			itemObj.pPanel:SetActive("AttribInfo", false)
			itemObj.pPanel:SetActive("Title", true)
			itemObj.pPanel:Label_SetText("Title", varDesc);
		else
			local szName, szValue = unpack(varDesc)
			itemObj.pPanel:SetActive("AttribInfo", true)
			itemObj.pPanel:SetActive("Title", false)
			itemObj.pPanel:Label_SetText("AttribName", szName);
			itemObj.pPanel:Label_SetText("AttribValue", szValue);
		end
	end

	self.ScrollViewMounts:Update(#tbAttribs, fnSetItem);
end

function tbUi:UpdateHorseEquip()
	local tbEquip = self.tbEquip or me.GetEquips(1);

	for nPos = Item.EQUIPPOS_REIN, Item.EQUIPPOS_PEDAL do
		local tbEqiptGrid = self["Equip"..(nPos - Item.EQUIPPOS_REIN + 1)]

		if tbEquip[nPos] then
			tbEqiptGrid.nEquipPos = nPos;
			tbEqiptGrid.szItemOpt = "PlayerEquip";
			tbEqiptGrid.fnClick = tbEqiptGrid.DefaultClick;
			tbEqiptGrid:SetItem(tbEquip[nPos])
			tbEqiptGrid.pPanel:SetActive("Main", true)
		else
			tbEqiptGrid.pPanel:SetActive("Main", false)
		end
    end
    local pItemHorseWaiyi = tbEquip[Item.EQUIPPOS_WAI_HORSE]
    local tbEqiptGrid = self["Equip"]
    if pItemHorseWaiyi then
    	tbEqiptGrid.szItemOpt = "PlayerEquip";
    	tbEqiptGrid.fnClick = tbEqiptGrid.DefaultClick;
    	tbEqiptGrid.nEquipPos = Item.EQUIPPOS_WAI_HORSE;
		tbEqiptGrid:SetItem(pItemHorseWaiyi)
		tbEqiptGrid.pPanel:SetActive("Main", true)
		self.pPanel:SetActive("FashionTitle",false)
    else
    	tbEqiptGrid:Clear()
    	self.pPanel:SetActive("FashionTitle",true)
    end
end

function tbUi:OnSyncItem()
	self:UpdateNpcView();
	self:UpdateAttrib();
	self:UpdateHorseEquip()
end

function tbUi:OnDelItem()
	self:UpdateNpcView();
	self:UpdateAttrib();
	self:UpdateHorseEquip()
end

function tbUi:OnLoadResFinish()
	self.pPanel:NpcView_ChangeDir("ShowRole", 220, false);
	self.pPanel:NpcView_PlayAnimation("ShowRole", self.szRideActionName, 0.0, true);
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
		{ UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.OnDelItem },
		{ UiNotify.emNOTIFY_LOAD_RES_FINISH,    self.OnLoadResFinish, self},
    };

    return tbRegEvent;
end
