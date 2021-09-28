RechargRewardDataManager = { }

RechargRewardDataManager.MESSAGE_RECHARGREWARDDATA_CHANGE = "MESSAGE_RECHARGREWARDDATA_CHANGE";


RechargRewardDataManager.hasInit = false;

-- 1：首充，2：累计充值，3：单笔充值 , 4:中秋节

RechargRewardDataManager.TYPE_FIRST_RECHARGE = 1;
RechargRewardDataManager.TYPE_TOTAL_RECHARGE = 2;
RechargRewardDataManager.TYPE_SINGLE_RECHARGE = 3;
RechargRewardDataManager.TYPE_MID_AUTUMN = 4;

RechargRewardDataManager.GET_REWARD_STAT_IN_EMAIL = 2;  -- 邮件发送
RechargRewardDataManager.GET_REWARD_STAT_HAS_GET = 1;  -- 已经领取
RechargRewardDataManager.GET_REWARD_STAT_NOT_GET = 0; -- 可领取但为领取 未领取

RechargRewardDataManager.hasInit = false;

RechargRewardDataManager.rechargeTypeLists = { };

RechargRewardDataManager.rechargeTypeLists[RechargRewardDataManager.TYPE_FIRST_RECHARGE] = { };
RechargRewardDataManager.rechargeTypeLists[RechargRewardDataManager.TYPE_TOTAL_RECHARGE] = { };
RechargRewardDataManager.rechargeTypeLists[RechargRewardDataManager.TYPE_SINGLE_RECHARGE] = { };
RechargRewardDataManager.rechargeTypeLists[RechargRewardDataManager.TYPE_MID_AUTUMN] = { };

RechargRewardDataManager.hasGetRechageAwardLog = false;
function RechargRewardDataManager.Init()
    RechargRewardDataManager.hasGetRechageAwardLog = false;
    RechargRewardDataManager.hasInit = false;
end


function RechargRewardDataManager.CheckHasInit()

    if not RechargRewardDataManager.hasInit then
        local cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RECHARGE_REWARD);

        RechargRewardDataManager.rechargeTypeLists[RechargRewardDataManager.TYPE_FIRST_RECHARGE] = { };
        RechargRewardDataManager.rechargeTypeLists[RechargRewardDataManager.TYPE_TOTAL_RECHARGE] = { };
        RechargRewardDataManager.rechargeTypeLists[RechargRewardDataManager.TYPE_SINGLE_RECHARGE] = { };
        RechargRewardDataManager.rechargeTypeLists[RechargRewardDataManager.TYPE_MID_AUTUMN] = { };
        for k, v in pairs(cf) do
            local obj = { };

            obj.hasGetAward = false;
            obj.canGetAward = false;

            obj.id = v.id;
            obj.type = v.type;

            obj.param1 = v.param1;
            obj.param2 = v.param2;
            obj.totalcountlimit = v.totalcountlimit;

            obj.endtime = v.endtime;
            obj.starttime = v.starttime;

            if obj.endtime ~= "" then
                obj.endtime_os = tonumber(GetTimestamp(obj.endtime)) * 1000;
            else
                obj.endtime_os = 0;
            end

            if obj.starttime ~= "" then

                obj.starttime_os = tonumber(GetTimestamp(obj.starttime)) * 1000;
            else
                obj.starttime_os = 0;
            end


            obj.reward = { };
            local reward_str = v.reward;
            local reward_num = table.getn(reward_str);


            for j = 1, reward_num do
                arr = ConfigSplit(reward_str[j]);
                id = tonumber(arr[1]);
                num = tonumber(arr[2]);


                obj.reward[j] = ProductInfo:New();
                obj.reward[j]:Init( { spId = id, am = num });
            end

            obj.career_award = v.career_award;

            local tem_num = table.getn(RechargRewardDataManager.rechargeTypeLists[obj.type]);
            tem_num = tem_num + 1;
            RechargRewardDataManager.rechargeTypeLists[obj.type][tem_num] = obj;

        end

        RechargRewardDataManager.hasInit = true;
    end

end

function RechargRewardDataManager.GetHasRechgeByid(in_rrl, id)

    if in_rrl ~= nil then
        local l_num = table.getn(in_rrl);
        for i = 1, l_num do
            if tonumber(in_rrl[i].id) == tonumber(id) then


                local st = in_rrl[i].s;

                if RechargRewardDataManager.GET_REWARD_STAT_HAS_GET == st or RechargRewardDataManager.GET_REWARD_STAT_IN_EMAIL == st then
                    return true;
                else
                    return false;
                end


            end
        end
    end

    return false;
end

function RechargRewardDataManager.GetCanRechgeByid(in_rrl, id)

    if in_rrl ~= nil then
        local l_num = table.getn(in_rrl);
        for i = 1, l_num do
            if tonumber(in_rrl[i].id) == tonumber(id) then


                local st = in_rrl[i].s;

                if RechargRewardDataManager.GET_REWARD_STAT_NOT_GET == st then
                    return true;
                else
                    return false;
                end


            end
        end
    end

    return false;
end



function RechargRewardDataManager.SetRMB(rmb)

    ActivityGiftsProxy.GetChengZhangJiJingInfos()
    if not RechargRewardDataManager.hasGetRechageAwardLog then
        ActivityGiftsProxy.GetRechageAwardLog();
        RechargRewardDataManager.hasGetRechageAwardLog = true;
    end

end

--[[
--rmb:累计充值人民币
--rrl:{[id...] 累计充值奖励领取标识}
l:[(id:礼包id recharge_reward的id字段,s：礼包状态（(0：未领取1：已领取2：邮件发送)）)....] 礼包
]]
function RechargRewardDataManager.SetRecharge(rmb, rrl)
    RechargRewardDataManager.CheckHasInit();

    if rmb == nil then
        rmb = 0;
    end
    RechargRewardDataManager.total_recharge = rmb;

    local t = RechargRewardDataManager.TYPE_TOTAL_RECHARGE;

    local list = RechargRewardDataManager.rechargeTypeLists[t];


    local l_num = table.getn(list);
    for i = 1, l_num do
        local needNum = list[i].param2;
        RechargRewardDataManager.rechargeTypeLists[t][i].canGetAward = false;
        RechargRewardDataManager.rechargeTypeLists[t][i].hasGetAward = false;

        -- if RechargRewardDataManager.total_recharge >= needNum then
        --  RechargRewardDataManager.rechargeTypeLists[t][i].canGetAward = true;
        -- end

        local b = RechargRewardDataManager.GetHasRechgeByid(rrl, list[i].id);
        if b then
            RechargRewardDataManager.rechargeTypeLists[t][i].hasGetAward = true;
        end

        b = RechargRewardDataManager.GetCanRechgeByid(rrl, list[i].id);
        if b then
            RechargRewardDataManager.rechargeTypeLists[t][i].canGetAward = true;
        end

    end

    MessageManager.Dispatch(RechargRewardDataManager, RechargRewardDataManager.MESSAGE_RECHARGREWARDDATA_CHANGE);

    MessageManager.Dispatch(ActivityGiftsNotes,ActivityGiftsNotes.UPDATE_ACTIVITY_GIFT_MSGS);
end

function RechargRewardDataManager.GetListByType(type)

    RechargRewardDataManager.CheckHasInit();

    return RechargRewardDataManager.rechargeTypeLists[type];
end

function RechargRewardDataManager.GetListByTypeID(type, id)

    local list = RechargRewardDataManager.GetInActivityItems(type);

    local t_num = table.getn(list);
    for i = 1, t_num do
        if list[i].id == id then
            return list[i];
        end
    end

    return nil;
end

function RechargRewardDataManager.SetListHasGetAwardByTypeId(type, id)

    local list = RechargRewardDataManager.GetListByType(type);

    local t_num = table.getn(list);
    for i = 1, t_num do
        if list[i].id == id then
            RechargRewardDataManager.rechargeTypeLists[type][i].hasGetAward = true;
        end
    end

    MessageManager.Dispatch(RechargRewardDataManager, RechargRewardDataManager.MESSAGE_RECHARGREWARDDATA_CHANGE);

end

--   ActivityGiftsProxy.GetTotalRechageAward(id)
function RechargRewardDataManager.GetIsHasAwardToGet(type)

    local list = RechargRewardDataManager.GetListByType(type);

    local t_num = table.getn(list);
    for i = 1, t_num do
        if list[i].canGetAward and not list[i].hasGetAward then

            return true;

        end
    end

    return false;

end

-- 获取 type 类型的活动 在时间范围内的活动
function RechargRewardDataManager.GetInActivityItems(type)

    local list = RechargRewardDataManager.GetListByType(type);
    local serverTime = GetTimeMillisecond();

    local res_list = { };
    local res_listIndex = 1;

    local t_num = table.getn(list);
    for i = 1, t_num do

        local startTime = list[i].starttime_os;
        local endTime = list[i].endtime_os;

        if serverTime > startTime and serverTime < endTime then
            res_list[res_listIndex] = list[i];
            res_listIndex = res_listIndex + 1;
        end



    end


    return res_list;
end