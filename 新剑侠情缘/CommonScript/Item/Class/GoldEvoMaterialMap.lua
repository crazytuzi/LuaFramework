
local tbItem = Item:GetClass("GoldEvoMaterialMap");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUseSetting = {};
	local fnUse = function ()
		Ui:CloseWindow("ItemTips")
		local nTarItem = Item.GoldEquip:GetCosumeItemToTarItem(nTemplateId)
		Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Evolution", nTarItem)
	end
	if Shop:CanSellWare(me, nItemId, 1) then
		tbUseSetting = {
			szFirstName = "出售"; 
			szSecondName = "使用";
			fnFirst = "SellItem";
			fnSecond = fnUse;
		}
	else
		tbUseSetting = {
			szFirstName = "使用";
			fnFirst = fnUse;
		}
	end

	return tbUseSetting;		
end

function tbItem:GetIntrol(nTemplateId, nItemId)
	local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
	if nItemId then
		local pItem = me.GetItemInBag(nItemId)
		if pItem then
			local nSumPrice, szMoneyType = Shop:GetSellSumPrice(me, nTemplateId, 1, pItem)	
			if nSumPrice then
				local _, szMoneyEmotion = Shop:GetMoneyName(szMoneyType)
				return  string.format("%s\n\n\n[73cbd5]出售可获得：%s%d[-]", tbItemBase.szIntro, szMoneyEmotion, nSumPrice)
			end
		end
	end
	return tbItemBase.szIntro
end