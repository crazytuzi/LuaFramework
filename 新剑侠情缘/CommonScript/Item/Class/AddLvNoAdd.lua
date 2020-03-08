--加等级道具，没有任何加成
local tbItem = Item:GetClass("AddLvNoAdd")
tbItem.nExtLevel = 1
function tbItem:OnUse(it)
    local nLevel = KItem.GetItemExtParam(it.dwTemplateId, self.nExtLevel)
    local nMaxLevel = GetMaxLevel()
    if nLevel > nMaxLevel then
        me.CenterMsg("该等级未开放")
        return
    end

    local nAddLv = nLevel - me.nLevel
    if nAddLv <= 0 then
        me.CenterMsg("由于侠士等级过高，服下丹药后只感觉丹田微热，并无效果")
        Log("AddLvNoAdd Item Forbid Use", me.dwID, me.nLevel, nLevel, nAddLv)
        return 1
    end

    me.AddLevel(nAddLv)
    Log("AddLvNoAdd Item AddLevel Success", me.dwID, me.nLevel, nLevel, nAddLv)
    return 1
end