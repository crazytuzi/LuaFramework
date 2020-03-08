local tbItem = Item:GetClass("MaterialCollectItem");

function tbItem:OnUse(it)
	Activity:OnPlayerEvent(me, "Act_RandomMaterial", it);
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	return {szFirstName = "启封", fnFirst = "UseItem"};
end