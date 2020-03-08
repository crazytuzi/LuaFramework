local tbItem = Item:GetClass("AwardBySexItem")
tbItem.EXT_TIME = 3
function tbItem:OnUse(pItem)
    local nSex    = Player:Faction2Sex(me.nFaction, me.nSex)
    local nItemId = KItem.GetItemExtParam(pItem.dwTemplateId, nSex)
    if nItemId <= 0 then
        return
    end

    local nTime = KItem.GetItemExtParam(pItem.dwTemplateId, self.EXT_TIME)
    local tbAward = {"Item", nItemId, 1}
    if nTime > 0 then
        tbAward[4] = GetTime() + nTime
    end
    me.SendAward({tbAward}, false, true, Env.LogWay_AwardBySexItem)
    return 1
end