local tbItem = Item:GetClass("DongRiJiItem")
function tbItem:OnClientUse()
	Ui:OpenWindow("DRJ_MainPanel")
	Ui:CloseWindow("ItemTips");
end