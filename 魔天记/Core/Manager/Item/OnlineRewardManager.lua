OnlineRewardManager = { };



OnlineRewardManager.hasInit = false;
OnlineRewardManager.hasGetServerData = false;

OnlineRewardManager.list = { };

OnlineRewardManager.MESSAGE_ONLINEREWARD_DATA_CHANGE = "MESSAGE_ONLINEREWARD_DATA_CHANGE";
OnlineRewardManager.MESSAGE_ONLINEREWARD_STATE_CHANGE = "MESSAGE_ONLINEREWARD_STATE_CHANGE";
OnlineRewardManager.hasGetOnlineData = false;


function OnlineRewardManager.CheckInit()

    if not OnlineRewardManager.hasInit then
        OnlineRewardManager.config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ONLINE_REWARD);

        local t_num = table.getn(OnlineRewardManager.config);
        for i = 1, t_num do

            local tem = OnlineRewardManager.config[i];

            local obj = { };

            obj.id = tem.id;
            obj.online = tem.online;
            obj.interval = tem.online;
            -- tem.interval;  http://192.168.0.8:3000/issues/2792
            obj.type = OnlineRewardManager.TYPE_CAN_NOT_GET_AWARD;
            obj.rewards = { };
            obj.elseTime = 0;

            local reward = tem.reward;
            local reward_num = table.getn(reward);
            for j = 1, reward_num do
                local str = reward[j];
                local arr = ConfigSplit(str);
                local id = tonumber(arr[1]);
                local num = tonumber(arr[2]);

                obj.rewards[j] = ProductInfo:New();
                obj.rewards[j]:Init( { spId = id, am = num });

            end

            OnlineRewardManager.list[i] = obj;

        end

        OnlineRewardManager.hasInit = true;
    end

end

OnlineRewardManager.TYPE_CAN_NOT_GET_AWARD = 0;
OnlineRewardManager.TYPE_HAS_GET_AWARD = 1;
OnlineRewardManager.TYPE_CAN_GET_AWARD = 2;
OnlineRewardManager.isCanGetInLineAward = false;
--[[
ot:在线时间（秒）
id:在线领取记录(下标)
]]
function OnlineRewardManager.SetServerInfo(ot, id)

    --[[
    local t_num = table.getn(OnlineRewardManager.list);
     OnlineRewardManager.isCanGetInLineAward = false;
    for i = 1, t_num do

        if OnlineRewardManager.list[i].id <= id then

            OnlineRewardManager.list[i].type = OnlineRewardManager.TYPE_HAS_GET_AWARD;
            -- 已经领取 奖励

        elseif OnlineRewardManager.list[i].id ==(id + 1) then

            OnlineRewardManager.list[i].type = OnlineRewardManager.TYPE_CAN_GET_AWARD ;
            -- 未领取，但如果时间到了， 可以领取
            OnlineRewardManager.list[i].elseTime =OnlineRewardManager.list[i].interval*60 - ot;

            if OnlineRewardManager.list[i].elseTime <= 0 then
              OnlineRewardManager.isCanGetInLineAward = true;

            end

        else
            OnlineRewardManager.list[i].type = OnlineRewardManager.TYPE_CAN_NOT_GET_AWARD;
            -- 未领取，不可以领取
        end

    end
    ]]

    local t_num = table.getn(OnlineRewardManager.list);
    OnlineRewardManager.isCanGetInLineAward = false;

    local n_elseTime = 0;

    for i = 1, t_num do


        if OnlineRewardManager.list[i].id <= id then

            OnlineRewardManager.list[i].type = OnlineRewardManager.TYPE_HAS_GET_AWARD;
            -- 已经领取 奖励

        elseif OnlineRewardManager.list[i].id ==(id + 1) then

            OnlineRewardManager.list[i].type = OnlineRewardManager.TYPE_CAN_GET_AWARD;
            -- 未领取，但如果时间到了， 可以领取
            OnlineRewardManager.list[i].elseTime = OnlineRewardManager.list[i].interval * 60 - ot;

            if OnlineRewardManager.list[i].elseTime <= 0 then
                OnlineRewardManager.isCanGetInLineAward = true;
                n_elseTime = - OnlineRewardManager.list[i].elseTime;
            end

        elseif OnlineRewardManager.list[i].id >(id + 1) and n_elseTime > 0 then

            OnlineRewardManager.list[i].type = OnlineRewardManager.TYPE_CAN_GET_AWARD;
            -- 未领取，但如果时间到了， 可以领取

            OnlineRewardManager.list[i].elseTime = OnlineRewardManager.list[i].interval * 60 - ot;

            if OnlineRewardManager.list[i].elseTime <= 0 then
                n_elseTime = - OnlineRewardManager.list[i].elseTime;
            end

        else
            OnlineRewardManager.list[i].type = OnlineRewardManager.TYPE_CAN_NOT_GET_AWARD;
            -- 未领取，不可以领取
        end

    end



    MessageManager.Dispatch(OnlineRewardManager, OnlineRewardManager.MESSAGE_ONLINEREWARD_DATA_CHANGE);
    OnlineRewardManager.hasGetServerData = false;
end


function OnlineRewardManager.GetListDatas()


    OnlineRewardManager.CheckInit();

    return OnlineRewardManager.list;
end

function OnlineRewardManager.ReSet()
    OnlineRewardManager.hasGetOnlineData = false;
end

OnlineRewardManager.old_time = GetTime();

function OnlineRewardManager.IsCanGetInLineAward(notCheckGetInLineAward)

    --[[
    if OnlineRewardManager.hasGetOnlineData then
       return OnlineRewardManager.isCanGetInLineAward;
    end

    OnlineRewardManager.hasGetOnlineData = true;
    if not OnlineRewardManager.hasGetServerData then
         SignInProxy.TryGetInLineInfo();
        OnlineRewardManager.hasGetServerData = true;
    end
    ]]

    

    -- 3秒内不能重复发
    local new_time = GetTime();
    local dt = new_time - OnlineRewardManager.old_time;
    if dt > 3 then
        SignInProxy.TryGetInLineInfo();
        OnlineRewardManager.old_time = new_time;
    end

    return OnlineRewardManager.isCanGetInLineAward;

end



function OnlineRewardManager.GetDataById(id)
    local t_num = table.getn(OnlineRewardManager.list);

    for i = 1, t_num do


        if OnlineRewardManager.list[i].id == tonumber(id) then
            return OnlineRewardManager.list[i];
        end


    end

    return nil;
end