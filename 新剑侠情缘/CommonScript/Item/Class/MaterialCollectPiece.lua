local tbItem = Item:GetClass("MaterialCollectPiece");

function tbItem:OnUse(it)
	Activity:OnPlayerEvent(me, "Act_MaterialCollectClientCall", "FindEnterNpc");
end