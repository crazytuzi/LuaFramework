local tbItem = Item:GetClass("QingRenJieGift")

function tbItem:OnCreate(pItem)
    print("fefefe", type(pItem))
end

function tbItem:OnUse(pItem)
    Activity:OnPlayerEvent(me, "Act_TryUseQingRenJieGift", pItem)
end