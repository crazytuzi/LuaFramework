local tbItem = Item:GetClass("DrinkToDreamItem")
function tbItem:OnClientUse()
	Ui:OpenWindow("DrinkToDream_MainPanel")
	Ui:CloseWindow("ItemTips");
end 