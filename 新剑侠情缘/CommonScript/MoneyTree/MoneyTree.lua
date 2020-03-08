MoneyTree.Def = {
    SAVE_GROUP  = 14;
    LOGIN_DAY   = 1;
    FREE_SHAKE  = 2;
    SHAKE_TIMES = 3;
    DISCOUNT_TIMES = 4;

    REFRESH_TIME   = 4*3600;

    BONUSES_VIPLEVEL = 10;  --Vip等级
    BONUSES_RATE = 1.2;  --Vip摇钱树加成
    LAUNCH_PRIVILEGE_RATE = 0.05; -- 手Q, 微信启动特权

    MULTI_TIMES = 10;

    PRICE = {
        {1, 10, 20},
        {11, 9999, 20},
    };

    DISCOUNT_PRICE = 0.6;
}

local tbMoneyTreeSetting = LoadTabFile(
        "Setting/WelfareActivity/MoneyTree.tab",
        "dds", nil,
        {"Prob", "Coin", "Achievement"});
function MoneyTree:Init()
    local nTotal = 0;
    local nMaxCoin = 0;
    self.tbCoinBySort = {}
    self.tbAchievement = {}
    for i, v in ipairs(tbMoneyTreeSetting) do
        nTotal = nTotal + v.Prob;
        if v.Coin > nMaxCoin then
            nMaxCoin = v.Coin;
            table.insert(self.tbCoinBySort, v.Coin)
        end
        if not Lib:IsEmptyStr(v.Achievement) then
            self.tbAchievement[v.Coin] = v.Achievement
        end
    end
    self.nTotal = nTotal;
    self.nMaxCoin = nMaxCoin;
    table.sort(self.tbCoinBySort)
end

function MoneyTree:RandomReward()
    local nTotal = self.nTotal;
    local nRan = MathRandom(0, nTotal - 1);
    for i,v in ipairs(tbMoneyTreeSetting) do
        nRan = nRan - v.Prob;
        if nRan < 0 then
            return v.Coin;
        end
    end

    return 0;
end

function MoneyTree:GetShakePrice(bMulti, bNoDiscount)
    local nFreeTimes = me.GetUserValue(self.Def.SAVE_GROUP, self.Def.FREE_SHAKE)
    if not bMulti and nFreeTimes == 0 then
        return 0
    end

    local nShakeTimes = me.GetUserValue(self.Def.SAVE_GROUP, self.Def.SHAKE_TIMES)
    local nTotalPrice = 0
    local nTimes = bMulti and self.Def.MULTI_TIMES or 1
    for i = 1, nTimes do
        local nCurShake = nShakeTimes + i
        local nCurPrice
        for _, tbPriceInfo in ipairs(self.Def.PRICE) do
            if nCurShake >= tbPriceInfo[1] and nCurShake <= tbPriceInfo[2] then
                nCurPrice = tbPriceInfo[3]
                break
            end
        end
        nCurPrice = nCurPrice or self.Def.PRICE[#self.Def.PRICE][3]
        nTotalPrice = nTotalPrice + nCurPrice
    end
    if nTotalPrice > 0 and bMulti and not bNoDiscount then
        if me.GetUserValue(self.Def.SAVE_GROUP, self.Def.DISCOUNT_TIMES) > 0 then
            nTotalPrice = nTotalPrice*self.Def.DISCOUNT_PRICE
        end
    end
    return nTotalPrice
end

MoneyTree:Init();
