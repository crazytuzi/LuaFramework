SummerGift.GROUP         = 58
SummerGift.DATA_DAY      = 1
SummerGift.COMPLETE_FLAG = 2
SummerGift.AWARD_FLAG    = 3
SummerGift.BEGIN_FLAG    = 4
SummerGift.END_FLAG      = 10
SummerGift.szBeginDay    = "2016/7/23" --开始时间
SummerGift.nActAltDay    = 7 --活动持续时间
SummerGift.nGetGiftDay   = 0 --额外领奖时间
SummerGift.tbAward       = { --条件奖励
    {3, {{"item", 788, 1}}},
    {5, {{"item", 223, 5}}},
    {7, {{"item", 2164, 1}}},
}
SummerGift.tbDayAward = { --每天奖励
    {"item", 222, 5},
    {"Contrib", 1000},
    {"Gold", 100},
    {"item", 2163, 1},
    {"item", 223, 2},
    {"Contrib", 1500},
    {"Gold", 150},
}

function SummerGift:LoadSetting()
    local tbTabFile = Lib:LoadTabFile("Setting/WelfareActivity/SummerGift.tab")
    assert(tbTabFile, "SummerGift LoadTabFile Fail")

    self.tbAct = {}
    self.tbActInfo = {}
    for _, tbInfo in ipairs(tbTabFile) do
        for i = 1, 15 do
            if not tbInfo["nDay" .. i] then
                break
            end

            local nTimes = tbInfo["nDay" .. i]
            nTimes = tonumber(nTimes)
            if nTimes then
                self.tbAct[i] = self.tbAct[i] or {}
                table.insert(self.tbAct[i], {tbInfo.szKey, nTimes})
            end
        end
        self.tbActInfo[tbInfo.szKey] = {szName = tbInfo.szName, szAltas = tbInfo.szAltas, szSprite = tbInfo.szSprite}
    end
end
SummerGift:LoadSetting()

function SummerGift:GetCurDayIndex()
    local nToday     = Lib:GetLocalDay(GetTime() - 4*60*60)
    local nBeginTime = Lib:ParseDateTime(self.szBeginDay)
    local nBeginDay  = Lib:GetLocalDay(nBeginTime)
    local nActDay    = nToday - nBeginDay + 1
    return nActDay
end

function SummerGift:GetActPos(szAct)
    local nCurDay    = self:GetCurDayIndex()
    local tbTodayAct = self.tbAct[nCurDay]
    for i, tbInfo in ipairs(tbTodayAct or {}) do
        if szAct == tbInfo[1] then
            return i, tbInfo[2], tbTodayAct
        end
    end
end

function SummerGift:CheckCanGainGift(pPlayer, nIdx)
    local nCurIdx = self:GetCurDayIndex()
    if nCurIdx <= 0 or nCurIdx > (self.nActAltDay + self.nGetGiftDay) then
        return false
    end

    if not nIdx or nIdx <= 0 or nIdx > #self.tbAward then
        return false
    end

    local nGainFlag = pPlayer.GetUserValue(self.GROUP, self.AWARD_FLAG)
    local nIdxFlag = KLib.GetBit(nGainFlag, nIdx)
    if nIdxFlag ~= 0 then
        return false
    end

    local tbInfo = self.tbAward[nIdx]
    local nNeed = tbInfo[1]
    local nCompleteFlag = pPlayer.GetUserValue(self.GROUP, self.COMPLETE_FLAG)
    local nCompleteDays = 0
    for i = 1, self.nActAltDay do
        if KLib.GetBit(nCompleteFlag, i) == 1 then
            nCompleteDays = nCompleteDays + 1
        end
    end
    if nCompleteDays < nNeed then
        return false
    end

    return true
end