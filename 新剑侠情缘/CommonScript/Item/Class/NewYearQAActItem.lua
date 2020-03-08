local tbItem = Item:GetClass("NewYearQAActItem")
function tbItem:OnClientUse(pItem)
	Ui:CloseWindow("ItemTips")
	Ui:CloseWindow("ItemBox")
	self:OpenActUi()
end

function tbItem:OpenActUi(nTab)
	Ui:OpenWindow("NewYearQAMainPanel", nTab)
end