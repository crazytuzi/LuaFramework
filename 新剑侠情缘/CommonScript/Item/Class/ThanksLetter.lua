local tbItem = Item:GetClass("ThanksLetter")

function tbItem:OnUse(it)
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:CloseWindow", "ItemBox")
    me.CallClientScript("Ui:OpenWindow", "ThanksLetterPanel")
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    return {szFirstName = "查看", fnFirst = "UseItem"}
end