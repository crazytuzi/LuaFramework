local tbItem = Item:GetClass("AnniversaryJiYuActDrink")
function tbItem:OnUse(pItem)
	Activity:OnPlayerEvent(me, "Act_OnUse_Drink", pItem.dwTemplateId)
end