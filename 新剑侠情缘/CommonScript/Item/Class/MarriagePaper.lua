local tbItem = Item:GetClass("MarriagePaper")

function tbItem:OnClientUse(it)
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:CloseWindow", "ItemBox")
	me.CallClientScript("Ui:OpenWindow", "MarriagePaperPanel", it.dwId)
	return 1
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
    return {szFirstName = "查看", fnFirst = "UseItem"}
end