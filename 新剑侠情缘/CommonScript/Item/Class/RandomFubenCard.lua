local tbItem = Item:GetClass("RandomFubenCard")
function tbItem:OnUse(pItem)
    local nRet = CollectionSystem:OnUseCard(pItem.dwTemplateId)
    return nRet
end

local tbDayNum = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
function tbItem:GetIntrol(nTemplateId, nItemId)
    local tbInfo = KItem.GetItemBaseProp(nTemplateId)
    local szIntro = string.format("%s\n\n", tbInfo.szIntro)

    local nRare = CollectionSystem:GetCardRare(nTemplateId)
    szIntro = string.format("%s珍 稀 度 ：[00ffff]%d\n", szIntro, nRare or 0)

    local nCollectionId = CollectionSystem:GetCollectionByCard(nTemplateId)
    local nPos = CollectionSystem:GetCardPosition(nCollectionId, nTemplateId)
    local szName = CollectionSystem:GetCardName(nCollectionId, nPos)
    szIntro = string.format("%s[-]完成条目：[00ffff]%s\n", szIntro, szName)

    local bActivate = CollectionSystem:IsPosActivate(nCollectionId, nPos)
    local szState = string.format("[-]收集状态：%s\n", bActivate and "[00ffff]已收集" or "[969696]未收集")
    szIntro = string.format("%s%s", szIntro, szState)
    return szIntro .. "[-]"
end