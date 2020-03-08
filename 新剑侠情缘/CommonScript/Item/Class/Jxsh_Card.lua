local tbItem = Item:GetClass("Jxsh_Card")
function tbItem:OnUse(pItem)
    local nRet = CollectionSystem:OnUseCard(pItem.dwTemplateId)
    return nRet
end