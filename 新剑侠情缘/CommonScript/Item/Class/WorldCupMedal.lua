local tbItem = Item:GetClass("WorldCupMedal")

function tbItem:OnUse(it)
    Activity:OnPlayerEvent(me, "Act_WorldCupReq", "CollectMedal", it.dwId)
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	return {szFirstName = "收集", fnFirst = "UseItem"}
end