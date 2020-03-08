local tbItem = Item:GetClass("RoseBox");

function tbItem:OnUse(it)
	me.CallClientScript("Ui:OpenWindow","GiftSystem");
	me.CallClientScript("Ui:CloseWindow","ItemTips");
end