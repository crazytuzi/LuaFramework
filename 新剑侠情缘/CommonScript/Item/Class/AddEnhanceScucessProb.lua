
local tbItem = Item:GetClass("AddEnhanceScucessProb");

function tbItem:GetUseSetting( nTemplateId, nItemId )
	local fnFirst = function ( )
		local nEquipPos = KItem.GetItemExtParam(nTemplateId, 1);
		local pEquip = me.GetEquipByPos(nEquipPos)
		local nEquipId = pEquip and pEquip.dwId
		Ui:OpenWindow("StrengthenPanel", "Strengthen", nEquipId)
		Ui:CloseWindow("ItemTips")
	end
	return {szFirstName = "使用", fnFirst = fnFirst};
end