local tbItem = Item:GetClass("RegressionGift")

--等级对应的返还元宝比例
tbItem.LEVEL_GOLD_PERCENT = {
                            {1, 5},
                            {30, 5},
                            {50, 5},
                            {60, 5},
                            {65, 10},
                            {70, 10},
                            {75, 10},
                            {80, 10},
                            {85, 10},
                            {90, 10},
                            {95, 15},
                            {100, 15},
                            {105, 15},
                            {110, 15},
                            {115, 20},
                            {120, 20},
                            {125, 20},
                            }

function tbItem:OnUse(pItem)
    return self:TryGainNewServerGift(me)
end

function tbItem:GetTip()
    local nGainLevel = me.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.GAINED_MAXLEVEL)
    for i, tbInfo in ipairs(self.LEVEL_GOLD_PERCENT) do
        if tbInfo[1] > nGainLevel then
            if me.nLevel >= tbInfo[1] then
                return string.format("开启可获得%d%%的元宝返还", tbInfo[2])
            else
                return string.format("开启等级：%d级", tbInfo[1])
            end
        end
    end
    return "尚未开放"
end

function tbItem:TryGainNewServerGift(pPlayer)
    local nTotalRecharge = pPlayer.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.TOTAL_RECHARGE)
    if nTotalRecharge <= 0 then
        Log("RegressionGift Err", pPlayer.dwID)
        return
    end

    local nGainLevel = pPlayer.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.GAINED_MAXLEVEL)
    for i, tbInfo in ipairs(self.LEVEL_GOLD_PERCENT) do
        local nLevel = tbInfo[1]
        if nLevel > nGainLevel then
            if pPlayer.nLevel < nLevel then
                pPlayer.CenterMsg(string.format("需%d才能领取", nLevel))
                return 0
            else
                local nPercent = tbInfo[2]
                local nGold = math.floor(nTotalRecharge * nPercent / 100)
                pPlayer.SetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.GAINED_MAXLEVEL, nLevel)
                pPlayer.SendAward({{"Gold", nGold}}, true, nil, Env.LogWay_RegressionPrivilege_O2N)
                Log("RegressionGift TryGainNewServerGift", pPlayer.dwID, nLevel, nPercent)
                return i == #self.LEVEL_GOLD_PERCENT and 1 or 0
            end
        end
    end
end
