local tbItem = Item:GetClass("QixiGift")

function tbItem:GetTip(pItem)
    if not pItem.dwId then
        return ""
    end

    local szSenderName = pItem.GetStrValue(1) or ""
    local szTips = string.format(Activity.Qixi.Def.ITEM_TIP[pItem.dwTemplateId] or "%s", szSenderName)
    return szTips
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    return {szFirstName = "出售", fnFirst = "SellItem"}
end