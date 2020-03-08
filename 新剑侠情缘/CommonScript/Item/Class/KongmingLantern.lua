local tbItem = Item:GetClass("KongmingLantern")
function tbItem:OnUse(pItem)
	Activity:OnPlayerEvent(me, "Act_OnUse_KongmingLantern", pItem.dwTemplateId)
end