local tbItem = Item:GetClass("AnniversaryJiYuActThumbsUp")

function tbItem:OnClientUse(pItem)
	Ui:CloseWindow("ItemTips")
	Ui:CloseWindow("ItemBox")
	Ui:OpenWindow("AnniversaryJiYuMainPanel")
end