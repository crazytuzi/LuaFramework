local tbUi = Ui:CreateClass("RefinePanel");

function tbUi:OnOpen(nItemId)
	local pEquip = me.GetItemInBag(nItemId)
	if not pEquip then
		return 0;
	end

	local GoldEquip = Item.GoldEquip
	local dwTemplateId = pEquip.dwTemplateId
	local tbSetting = GoldEquip:GetTrainAttriSetting(dwTemplateId)
	if not tbSetting then
		return 0;
	end

	self.nItemId = nItemId
	self.EquipmentItem:SetItem(nItemId)
	self.EquipmentItem.fnClick = self.EquipmentItem.DefaultClick

	local nNowLevel = pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL)
	local nNextLevel = nNowLevel + 1

	local tbExtAttrib = GoldEquip:GetTrainAttrib(dwTemplateId, nNowLevel)
	local tbNextExtAttrib = GoldEquip:GetTrainAttrib(dwTemplateId, nNextLevel)

	self.pPanel:Label_SetText("Txt1", string.format("当前属性:\n%s", self:GetFormatTip(tbExtAttrib)))

	if not tbNextExtAttrib then
		self.pPanel:SetActive("Txt2", false)
		self.pPanel:SetActive("DemandGroup", false)
		self.pPanel:Button_SetEnabled("BtnRefine", false)
	else
		self.pPanel:SetActive("Txt2", true)
		self.pPanel:SetActive("DemandGroup", true)
		self.pPanel:Button_SetEnabled("BtnRefine", true)
		self.pPanel:Label_SetText("Txt2", string.format("下一级属性:\n%s", self:GetFormatTip(tbNextExtAttrib)))

		local nConsumeCount = tbSetting["CostItemCount" .. nNextLevel]
		self.Item:SetItemByTemplate(tbSetting.CostItemId)
		local nExistCount = me.GetItemCountInAllPos(tbSetting.CostItemId)
        self.pPanel:Label_SetText("ItemNumber", string.format("%d/%d", nExistCount, nConsumeCount));
		self.pPanel:Label_SetColorByName("ItemNumber" ,  nConsumeCount > nExistCount and "Red" or "White");

		local nConsumeCount = tbSetting["CostCoin" .. nNextLevel]
		self.pPanel:Label_SetText("Cost", nConsumeCount)
		self.pPanel:Label_SetColorByName("Cost", nConsumeCount > me.GetMoney("Coin") and "Red" or "White");
	end
end

function tbUi:GetFormatTip(tbExtAttrib)
	local szAttr = ""
	for i,v in ipairs(tbExtAttrib) do
		local _,_,_,_, szColor = Item:GetQualityColor(v[2])
		szAttr = szAttr .. string.format("[%s]%s[-]", szColor, v[1])
		if i ~= #tbExtAttrib then
			szAttr = szAttr .. "\n"
		end
	end
	return szAttr
end

function tbUi:OnResponse()
	self:OnOpen(self.nItemId)
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnCancel = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnRefine = function (self)
	local bRet, szMsg = Item.GoldEquip:CanEquipTrainAttris(me, self.nItemId)
	if not bRet then
		if szMsg then
			me.CenterMsg(szMsg)
		end
		return
	end

	RemoteServer.DoUpgradeEquipTrainLevel(self.nItemId)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_EQUIP_TRAIN_ATTRIB,           self.OnResponse},
    };

    return tbRegEvent;
end


