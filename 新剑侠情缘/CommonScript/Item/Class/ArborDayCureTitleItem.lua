local szActingTip = "活动尚未结束"
--copy from ArborDayCure and FathersDay
local tbScoreGroup = {
    69,
    74,
}
local nScoreKey = 3

local tbActivtiyKey = {
    "ArborDayCure",
    "FathersDay",
}

local tbItem   = Item:GetClass("ArborDayCureTitleItem")
tbItem.tbScore = {
    {{nScore = 30,
          tbTitle = {[5050] = true,
                     [5051] = true,
                     [5052] = true,
                     [5053] = true,
                     [5054] = true,
                     [5055] = true,
                     [5056] = true,
                     [5057] = true,
                     [5058] = true,
                     [5059] = true}},
        {nScore  = 20,
         tbTitle = {[5050] = true,
                    [5051] = true,
                    [5052] = true,
                    [5053] = true,
                    [5054] = true}
        }},

    {{nScore = 30,
          tbTitle = {[5069] = true,
                     [5070] = true,
                     [5071] = true,
                     [5072] = true,
                     [5073] = true,
                     [5074] = true,
                     [5075] = true,
                     [5076] = true,
                     [5077] = true,
                     [5078] = true}},
        {nScore  = 20,
         tbTitle = {[5069] = true,
                    [5070] = true,
                    [5071] = true,
                    [5072] = true,
                    [5073] = true}
        }},
}

function tbItem:GetCanChooseTitle(pPlayer, nType)
    local nGroup = tbScoreGroup[nType]
    if not nGroup then
        Log("ArborDayCure GetCanChooseTitle", nType)
        return
    end

    local nScore = pPlayer.GetUserValue(nGroup, nScoreKey)
    if nScore == 0 then
        return
    end

    local tbTScore = self.tbScore[nType]
    for _, tbInfo in ipairs(tbTScore or {}) do
        if nScore >= tbInfo.nScore then
            return tbInfo.tbTitle
        end
    end
end

function tbItem:OnClientUse(pItem)
    local szActKey = tbActivtiyKey[pItem.dwTemplateId]
    if Activity:__IsActInProcessByType(szActKey) then
        me.CenterMsg(szActingTip)
        return 1
    end

    local nType = KItem.GetItemExtParam(pItem.dwTemplateId, 1)
    local tbTitle = self:GetCanChooseTitle(me, nType)
    if not tbTitle then
        me.CenterMsg("活动积分不存在")
        return 1
    end
    Ui:OpenWindow("QingRenJieTitlePanel", pItem.dwId, "ArborDayCure", tbTitle)
    Ui:CloseWindow("ItemTips")
    return 1
end

function tbItem:OnRequestUse(pPlayer, nTitleId, nItemID)
    local pItem = KItem.GetItemObj(nItemID)
    if not pItem then
        return
    end

    local szActKey = tbActivtiyKey[pItem.dwTemplateId]
    if Activity:__IsActInProcessByType(szActKey) then
        pPlayer.CenterMsg(szActingTip)
        return
    end

    local nType = KItem.GetItemExtParam(pItem.dwTemplateId, 1)
    local tbTitle, nScore = self:GetCanChooseTitle(pPlayer, nType)
    if not tbTitle then
        pPlayer.CenterMsg("活动积分不存在")
        return
    end

    if not tbTitle[nTitleId] then
        pPlayer.CenterMsg("不能选择该称号")
        return
    end

    local nEndTime = pItem.GetIntValue(-9996)
    nEndTime = nEndTime > 0 and nEndTime or GetTime()
    if Item:Consume(pItem, 1) < 1 then
        pPlayer.CenterMsg("道具消耗失败，请重试")
        return
    end

    local nType = KItem.GetItemExtParam(pItem.dwTemplateId, 1)
    local nGroup = tbScoreGroup[nType]
    pPlayer.SetUserValue(nGroup, nScoreKey, 0)
    local tbAward = {{"AddTimeTitle", nTitleId, nEndTime}}
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_ArborDayCure)
    Log("QingRenJieTitleItem OnRequestUse", pPlayer.dwID, nTitleId, nItemID, nScore)
end

local tbOuterItem = Item:GetClass("ArborDayCureTitleOuterItem")
tbOuterItem.tbScore = {
    {1, 10},
    {11, 15},
    {16, 20},
    {21, 25},
    {26, 30},
    {31, 35},
    {36, 40},
}
tbOuterItem.nFruitItemTID = 3953
function tbOuterItem:GetUseSetting(nTemplateId, nItemId)
    local nType    = KItem.GetItemExtParam(nTemplateId, 2)
    local szActKey = tbActivtiyKey[nType]
    if not Activity:__IsActInProcessByType(szActKey) then
        return {szFirstName = "使用", fnFirst = "UseItem"}
    end

    return {}
end

function tbOuterItem:GetFruitCount(pPlayer, pItem)
    local nType = KItem.GetItemExtParam(pItem.dwTemplateId, 2)
    local nGroup = tbScoreGroup[nType]
    local nScore = pPlayer.GetUserValue(nGroup, nScoreKey)
    if nScore == 0 then
        return
    end

    for i, tbInfo in ipairs(self.tbScore) do
        if nScore >= tbInfo[1] and nScore <= tbInfo[2] then
            return MathRandom(tbInfo[1], tbInfo[2])
        end
    end
    local tbMax = self.tbScore[#self.tbScore]
    return MathRandom(tbMax[1], tbMax[2])
end

function tbOuterItem:OnUse(pItem)
    local nType    = KItem.GetItemExtParam(pItem.dwTemplateId, 2)
    local szActKey = tbActivtiyKey[nType]
    if Activity:__IsActInProcessByType(szActKey) then
        me.CenterMsg(szActingTip)
        return 0
    end 
    local tbAllAward = {}
    local tbTitle = tbItem:GetCanChooseTitle(me, nType)
    if tbTitle then
        local nRandomId = KItem.GetItemExtParam(pItem.dwTemplateId, 1)
        local nRet, szMsg, tbAward = Item:GetClass("RandomItem"):RandomItemAward(me, nRandomId, pItem.szName)
        if nRet ~= 1 then
            me.CenterMsg(szMsg)
            return 0
        end

        local nEndTime = pItem.GetIntValue(-9996)
        nEndTime = nEndTime > 0 and nEndTime or GetTime()
        for _, tbInfo in pairs(tbAward) do
            if Player.AwardType[tbInfo[1]] == Player.award_type_item then
                tbInfo[4] = nEndTime
            end
        end

        Lib:MergeTable(tbAllAward, tbAward)
    end
    local nFruitNum = self:GetFruitCount(me, pItem)
    if nFruitNum then
        table.insert(tbAllAward, {"Item", self.nFruitItemTID, nFruitNum})
    end
    if next(tbAllAward) then
        me.SendAward(tbAllAward, true, true, Env.LogWay_ArborDayCure)
    end
    return 1
end
