local tbItem = Item:GetClass("ShengDianKeyItem")
function tbItem:OnUse(pItem)
    ShengDianAct:TryEnter(me)
end

function tbItem:OnClientUse()
    Ui:CloseWindow("ItemBox")
    return 0
end