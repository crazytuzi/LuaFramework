
local tbItem = Item:GetClass("PlatinumEvoMaterialMap");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUseSetting = {szFirstName = "使用"};
	tbUseSetting.fnFirst = function ()
		Ui:CloseWindow("ItemTips")

		local nTarItem = Item.GoldEquip:GetCosumeItemToTarItem(nTemplateId)
		local tbItemBase = KItem.GetItemBaseProp(nTarItem)
		local nEquipPos = KItem.GetEquipPos(nTarItem) 
		local pItemCur = me.GetEquipByPos(nEquipPos)
		if pItemCur and pItemCur.nDetailType == Item.DetailType_Gold then
			nTarItem = pItemCur.dwId
		else
			nTarItem = nil
		end
		Ui:OpenWindow("EquipmentEvolutionPanel", "Type_EvolutionPlatinum", nTarItem)
	end
	
	if Shop:CanSellWare(me, nItemId, 1) then
		tbUseSetting.fnSecond = "SellItem";
		tbUseSetting.szSecondName = "出售";
	end

	return tbUseSetting;		
end

