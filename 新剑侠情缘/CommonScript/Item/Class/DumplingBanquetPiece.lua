local tbItem = Item:GetClass("DumplingBanquetPiece");

function tbItem:OnClientUse(it)
	Ui.HyperTextHandle:Handle("[url=npc:家族总管, 266, 1004]");
	Ui:CloseWindow("ItemBox")
	Ui:CloseWindow("ItemTips")
end
