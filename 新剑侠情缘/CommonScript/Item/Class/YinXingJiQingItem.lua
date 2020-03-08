local tbItem = Item:GetClass("YinXingJiQingItem")
function tbItem:OnClientUse()
	Ui:OpenWindow("YXJQ_MainPanel")
	Ui:CloseWindow("ItemTips");
end