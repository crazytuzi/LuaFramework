--锦绣山河卡
local tbItem = Item:GetClass("Jxsh_Item")
function tbItem:OnUse(pItem)
    Activity:OnPlayerEvent(me, "Act_TryUseJxshItem", pItem)
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    if Shop:CanSellWare(me, nItemId, 1) then
        return {szFirstName = "出售", fnFirst = "SellItem", szSecondName = "鉴定", fnSecond = "UseItem"}
    end
    return {szFirstName = "鉴定", fnFirst = "UseItem"}
end