local tbItem = Item:GetClass("GrassBox");

function tbItem:OnUse(it)
	me.CallClientScript("Ui:OpenWindow","GiftSystem");
	me.CallClientScript("Ui:CloseWindow","ItemTips");
end