local tbItem = Item:GetClass("AddWaiyiColor");

function tbItem:OnUse(it)
	local nTargetLimitColorItemId = KItem.GetItemExtParam(it.dwTemplateId, 1);
	if Item.tbChangeColor:AddShowColor(me, nTargetLimitColorItemId) then
		return 1;
	end
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbResult = {};
	tbResult.szFirstName = "使用";
	tbResult.szSecondName = "预览";

	tbResult.fnFirst = "UseItem";
	tbResult.fnSecond = function ()
		local nTargetLimitColorItemId = KItem.GetItemExtParam(nTemplateId, 1);
		Ui:OpenWindow("WaiyiPreview", nTargetLimitColorItemId);
		Ui:CloseWindow("ItemTips");
	end

	return tbResult;
end