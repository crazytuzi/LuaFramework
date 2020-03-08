local tbItem = Item:GetClass("MonkeyAchiItem");
function tbItem:OnUse(it)
	Achievement:AddCount(me, "FactionBattleBrother_2", 1)
	return 1
end