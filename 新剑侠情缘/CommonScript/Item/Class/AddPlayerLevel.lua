local tbItem = Item:GetClass("AddPlayerLevel")
tbItem.nExtLevel = 1
tbItem.nExtPrice = 2
tbItem.tbVipExtLevel = {
--vip等级，对应给玩家加的等级，从大到小排序
    {18, 4},
    {15, 3},
    {12, 2},
    {9, 1},
}

function tbItem:OnUse(it)
    local nLevel = KItem.GetItemExtParam(it.dwTemplateId, self.nExtLevel)
    local nMaxLevel = GetMaxLevel()
    if nLevel > nMaxLevel then
        me.CenterMsg("该等级未开放")
        return
    end

    local nFinalLevel = self:GetFinalLevel(me.GetVipLevel(), it.dwTemplateId)
    if me.nLevel >= nFinalLevel then
        me.CenterMsg("你已到达该等级")
        return 1
    end

    nFinalLevel = nFinalLevel - me.nLevel
    me.AddLevel(nFinalLevel)
    Log("AddPlayerLevel Item AddLevel Success", me.dwID, me.nLevel, nLevel, nFinalLevel + me.nLevel)
    return 1
end

function tbItem:GetFinalLevel(nVipLevel, nItemTID)
    local nLevel = KItem.GetItemExtParam(nItemTID, self.nExtLevel)
    local nExtLevel = 0
    for _, tbInfo in ipairs(self.tbVipExtLevel) do
        if nVipLevel >= tbInfo[1] then
            nExtLevel = tbInfo[2]
            break
        end
    end

    local nDayExt = DirectLevelUp:GetItemDayExtLv(nItemTID)
    return nLevel + nExtLevel + nDayExt
end

function tbItem:GetIntrol(dwTemplateId)
    local tbBase = KItem.GetItemBaseProp(dwTemplateId)
    local szBaseTip = tbBase.szIntro
    local nFinalLevel = self:GetFinalLevel(me.GetVipLevel(), dwTemplateId)
    szBaseTip = string.format(szBaseTip, nFinalLevel)

    local nVipLevel = me.GetVipLevel()
    local nCurLevelUp = 0
    for _, tbInfo in ipairs(self.tbVipExtLevel) do
        if nVipLevel >= tbInfo[1] then
            -- szBaseTip = string.format("%s\n\n当前剑侠尊享等级可额外提升[FFFE0D]%d[-]级", szBaseTip, tbInfo[2])
            nCurLevelUp = tbInfo[2]
            break
        end
    end
    for i = #self.tbVipExtLevel, 1, -1 do
        if nVipLevel < self.tbVipExtLevel[i][1] then
            szBaseTip = string.format("%s%s成为剑侠尊享%d可再额外提升[FFFE0D]%d[-]级", szBaseTip, nCurLevelUp > 0 and "\n" or "\n\n", self.tbVipExtLevel[i][1], self.tbVipExtLevel[i][2] - nCurLevelUp)
            break
        end
    end
    -- local _, nNextAppLv = DirectLevelUp:GetItemDayExtLv(dwTemplateId, true)
    -- if nNextAppLv then
    --     szBaseTip = string.format("%s\n还有[FFFE0D]%d[-]天可额外提升[FFFE0D]1[-]级", szBaseTip, nNextAppLv)
    -- end
    return szBaseTip
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
    return {szFirstName = "使用", fnFirst = "UseItem"};
end

function tbItem:OnClientUse(it)
    local fnUse = function ()
        RemoteServer.UseItem(it.dwId)
    end
    me.MsgBox("使用后该直升丹将消失，是否确认使用？", {{"使用", fnUse}, {"取消"}})
    return 1
end