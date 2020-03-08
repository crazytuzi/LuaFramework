local tbItem = Item:GetClass("LevelUpGift")

function tbItem:GetUseSetting(nItemTID)
    local fnSong = function()
        Ui:OpenWindow("GiftSystem",nil,{nGiftType = Gift.GiftType.MailGift,nItemId = nItemTID})
        Ui:CloseWindow("ItemTips")
    end

    return {szFirstName = "赠送", fnFirst = fnSong}
end

function tbItem:GetIntrol(nItemTID)
    local tbBase = KItem.GetItemBaseProp(nItemTID)
    local szBaseTip = tbBase.szIntro
    local nTID = DirectLevelUp:GetCanBuyItem()
    if nTID then
        local tbAppend = KItem.GetItemBaseProp(nTID)
        local szAppend = tbAppend.szIntro

        szBaseTip = string.format("%s\n%s", szBaseTip, szAppend)
    end

    return szBaseTip
end