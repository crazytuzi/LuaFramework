ZhenFa.GROUP = 76
ZhenFa.tbJueYao = {
    {szCheckFn = "CheckFriend",         nStrengthLv = 1,  nCurExp = 2,  nCurItemTID = 3,  nAttribIdx = 4,  nCurLevel = 5,  tbDesc = {"队内有1个好友数量时激活：", "队内有2个好友数量时激活：", "队内有3个好友数量时激活："}},
    {szCheckFn = "CheckTeacherStudent", nStrengthLv = 11, nCurExp = 12, nCurItemTID = 13, nAttribIdx = 14, nCurLevel = 15, tbDesc = {"队内有1个自身的师傅或徒弟时激活：", "队内有2个自身的师傅或徒弟时激活：", "队内有3个自身的师傅或徒弟时激活："}},
    {szCheckFn = "CheckSwornFriends",   nStrengthLv = 21, nCurExp = 22, nCurItemTID = 23, nAttribIdx = 24, nCurLevel = 25, tbDesc = {"队内有自身结拜兄弟时激活："}},
    {szCheckFn = "CheckBiWuZhaoQin",    nStrengthLv = 31, nCurExp = 32, nCurItemTID = 33, nAttribIdx = 34, nCurLevel = 35, tbDesc = {"队内有自身情缘时激活："}},
    {szCheckFn = "CheckKin",            nStrengthLv = 41, nCurExp = 42, nCurItemTID = 43, nAttribIdx = 44, nCurLevel = 45, tbDesc = {"队内有1个本家族成员时激活：", "队内有2个本家族成员时激活：", "队内有3个本家族成员时激活："}},
    {szCheckFn = "CheckMarriage",       nStrengthLv = 51, nCurExp = 52, nCurItemTID = 53, nAttribIdx = 54, nCurLevel = 55, tbDesc = {"队内有自身侠侣时激活："}},
}

ZhenFa.tbDecomposeInfo = {
    {nItemTID = 7288, nDecomposeParam = 0.5, nDecomposePercent = 0.5},
    {nItemTID = 7289, nDecomposeParam = 0.5, nDecomposePercent = 0.5},
    {nItemTID = 7290, nDecomposeParam = 0,   nDecomposePercent = 0},
}
ZhenFa.tbDecomposeRate = {
    {600000, 0.5},
    {200000, 1},
    {200000, 2.5},
}

ZhenFa.OPEN_TF = "OpenLevel89"

ZhenFa.MAX_ACTIVE_LEVEL = 3

ZhenFa.JUEYAO_TYPE_LEN = #ZhenFa.tbJueYao
ZhenFa.JUEYAO_ATT_INDEX = 1
ZhenFa.JUEYAO_EQUIP_FLAG = 2

function ZhenFa:LoadSetting()
    local tbFile = Lib:LoadTabFile("Setting/Item/ZhenFa/AttribGroup.tab", {DetailType = 1, Index = 1, Weight = 1, AttribGroupId1 = 1, AttribGroupId2 = 1, AttribGroupId3 = 1})
    self.tbAttribs = {}
    for _, tbInfo in ipairs(tbFile) do
        self.tbAttribs[tbInfo.DetailType] = self.tbAttribs[tbInfo.DetailType] or {nTotalWeight = 0, tbRandomAttrib = {}}

        assert(not self.tbAttribs[tbInfo.DetailType].tbRandomAttrib[tbInfo.Index], string.format("JueYao tbRandomAttrib Repeat:", tbInfo.Index))
        self.tbAttribs[tbInfo.DetailType].nTotalWeight = self.tbAttribs[tbInfo.DetailType].nTotalWeight + tbInfo.Weight
        self.tbAttribs[tbInfo.DetailType].tbRandomAttrib[tbInfo.Index] = {nWeigth = tbInfo.Weight, tbAttribGroupId = {tbInfo.AttribGroupId1, tbInfo.AttribGroupId2, tbInfo.AttribGroupId3}}
    end

    tbFile = Lib:LoadTabFile("Setting/Item/ZhenFa/JueYao.tab", {TemplateId = 1, DetailType = 1, FightPower = 1, ExtParam1 = 1, ExtParam2 = 1, ExtParam3 = 1})
    self.tbRealLevel = {}
    for _, tbInfo in ipairs(tbFile) do
        if tbInfo.ClassName == "JueYao" then
            assert(self.tbAttribs[tbInfo.DetailType], string.format("JueYao tbRealLevel No Such Attrib:", tbInfo.DetailType))
            self.tbRealLevel[tbInfo.TemplateId] = {nDetailType = tbInfo.DetailType, nFightPower = tbInfo.FightPower, tbLevel = {tbInfo.ExtParam1, tbInfo.ExtParam2, tbInfo.ExtParam3}}
        end
    end

    tbFile = Lib:LoadTabFile("Setting/Item/ZhenFa/XiuLianLevel.tab", {Level = 1, Exp = 1, FightPower = 1})
    self.tbLevelExp = {}
    for _, tbInfo in ipairs(tbFile) do
        self.tbLevelExp[tbInfo.Level] = {nExp = tbInfo.Exp, nFightPower = tbInfo.FightPower}
    end
end
ZhenFa:LoadSetting()

function ZhenFa:GetStrengthMaxLv()
    return #self.tbLevelExp
end

function ZhenFa:GetStrengthNeedExp(nCurLv)
    local tbInfo = self.tbLevelExp[nCurLv] or {}
    return tbInfo.nExp
end

function ZhenFa:GetStrengthPower(nCurLv)
    local tbInfo = self.tbLevelExp[nCurLv] or {}
    return tbInfo.nFightPower
end

function ZhenFa:GetDecomposeResult(nItemTID, bTips)
    local tbResult = {}
    local nBeDecompose = KItem.GetBaseValue(nItemTID)
    for _, tbInfo in ipairs(self.tbDecomposeInfo) do
        -- local nTotalValue = nBeDecompose * tbInfo.nDecomposeParam
        local nValue = math.floor(nBeDecompose * tbInfo.nDecomposeParam * tbInfo.nDecomposePercent)
        local nThisValue = KItem.GetBaseValue(tbInfo.nItemTID)
        local fValue = nValue/nThisValue

        local nRate = MathRandom(1000000)
        local fNum  = 0
        for _, tbTmp in ipairs(self.tbDecomposeRate) do
            if nRate <= tbTmp[1] then
                fNum = tbTmp[2]
                break
            end
            nRate = nRate - tbTmp[1]
        end

        local nNum, fRatePercent = math.modf(fValue * fNum)
        local nResultNum = nNum
        if (fRatePercent > 0) and (fRatePercent*1000000 >= MathRandom(1000000)) then
            nResultNum = nResultNum + 1
        end
        if bTips and tbInfo.nDecomposeParam > 0 then
            table.insert(tbResult, {tbInfo.nItemTID, nResultNum, math.floor(fValue * self.tbDecomposeRate[1][2]), math.ceil(fValue * self.tbDecomposeRate[#self.tbDecomposeRate][2])})
        elseif nResultNum > 0 then
            table.insert(tbResult, {tbInfo.nItemTID, nResultNum})
        end
    end
    return tbResult
end

function ZhenFa:GetPlayerStrengthMaxLv(pPlayer)
    return (math.floor(pPlayer.nLevel/10 - 7)) * 3
end

function ZhenFa:GetJueYaoCount(pPlayer)
    local tbItemList = pPlayer.GetItemListInBag()
    local nCurCount = 0
    for _, pItem in ipairs(tbItemList) do
        if pItem.szClass == "JueYao" then
            nCurCount = nCurCount + pItem.nCount
        end
    end
    return nCurCount
end

function ZhenFa:GetFreeBagCount(pPlayer)
    local nCurCount = self:GetJueYaoCount(pPlayer)
    return GameSetting.MAX_COUNT_JUEYAO - nCurCount, "诀要空间不足！"
end