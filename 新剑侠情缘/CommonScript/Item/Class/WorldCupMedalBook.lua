local tbItem = Item:GetClass("WorldCupMedalBook")

function tbItem:OnUse(it)
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:OpenWindow", "WorldCupPanel")
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	return {szFirstName = "查看", fnFirst = "UseItem"}
end