ActivityGiftsDataManager = { }

local recharge_gift = nil;
local limitBuyInfo = nil
local insert = table.insert
function ActivityGiftsDataManager.Init()
    recharge_gift = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RECHARGE_GIFT)

end

function ActivityGiftsDataManager.InitLimitBuyInfo()
    limitBuyInfo = ConfigManager.Clone(VIPManager.GetChargeConfigs(2))
    for k, v in ipairs(limitBuyInfo) do
        local temp = ConfigSplit(v.show)
        v.rewardInfo = ProductManager.GetProductById(tonumber(temp[1]))
        v.rewardNum = tonumber(temp[2])
    end
end

function ActivityGiftsDataManager.GetWealTypeData()

    if recharge_gift == nil then
        ActivityGiftsDataManager.Init();
    end

    local temp = { }
    local info = PlayerManager.GetPlayerInfo()
    for k, v in ipairs(recharge_gift) do
        if ((info.level >= v.openVal) and v.isOpen) then

            if v.code_id == 4 then
                -- 累计充值  需要在获得时间内才显示
                local ls = RechargRewardDataManager.GetInActivityItems(RechargRewardDataManager.TYPE_TOTAL_RECHARGE);
                local t_num = table.getn(ls);

                if t_num > 0 then
                    insert(temp, v);
                end

            elseif v.code_id == 5 then
                -- 成长基金

                --[[
            1、标签显示规则：
a)角色未购买成长基金或角色购买成长基金，但没有全部领取所有档次的成长基金时，界面内显示成长基金标签
b)角色购买成长基金并且全部领取成长基金界面中的奖励后，隐藏界面中的“成长基金”页签
            ]]

                if ActivityGiftsProxy._0x1a08Data ~= nil then
                    -- s : Int 0 ：表示未购买 1 ：已购买

                    local hasGetAllAward = ActivityGiftsProxy.CheckHasGetAllChengZhangJiJin(ActivityGiftsProxy._0x1a08Data.l);
                    local s = ActivityGiftsProxy._0x1a08Data.s;
                    if s == nil then
                        s = 0;
                    end

                    local me = HeroController:GetInstance();
                    local heroInfo = me.info;
                    local my_lv = heroInfo.level;


                    if s == 1 and not hasGetAllAward then

                        insert(temp, v);

                        -- 1.玩家未购买，等级大于等于61级时，页面消失
                    elseif s == 0 and my_lv < 301 then

                        insert(temp, v);

                    end

                end

            else
                insert(temp, v);
            end

        end
    end

    return temp
end

function ActivityGiftsDataManager.SetLimitBuyInfo(data)
    if (limitBuyInfo == nil) then
        ActivityGiftsDataManager.InitLimitBuyInfo()
    end

    if (data) then
        for k, v in ipairs(data) do
            for k1, v1 in ipairs(limitBuyInfo) do
                if (v.id == v1.id) then
                    v1.num = v.num
                end
            end
        end
    end
end


function ActivityGiftsDataManager.GetLimitBuyInfo()
    if (limitBuyInfo == nil) then
        ActivityGiftsDataManager.InitLimitBuyInfo()
    end

    return limitBuyInfo
end

function ActivityGiftsDataManager.GetBuyNum(id)
    if limitBuyInfo then
        for k, v in pairs(limitBuyInfo) do
            if (v.id == id) then
                return v.num
            end
        end
    end
    return 0
end
