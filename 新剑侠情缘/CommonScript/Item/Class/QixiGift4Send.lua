local tbItem = Item:GetClass("QixiGift4Send")

function tbItem:OnClientUse(it)
    Ui:CloseWindow("ItemTips")
    Ui:CloseWindow("ItemBox")
    Ui:OpenWindow("QixiSendGiftPanel", it.dwTemplateId)
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    if Activity.Qixi:IsInActivityTime() then
        return {szFirstName = "出售", fnFirst = "SellItem", szSecondName = "使用", fnSecond = "UseItem"}
    else
        return {szFirstName = "出售", fnFirst = "SellItem"}
    end
end