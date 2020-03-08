local tbItem = Item:GetClass("ImpressionBook");
-- 印象手册
tbItem.nImpressionBookItemID = 3911

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local fnUse = function ()
		Ui:OpenWindow("FriendImpressionPanel")
		Ui:CloseWindow("ItemTips")
		Ui:CloseWindow("ItemBox")
	end
	return {szFirstName = "使用", fnFirst = fnUse};
end