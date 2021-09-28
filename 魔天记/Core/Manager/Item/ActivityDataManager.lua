
ActivityDataManager = { };
ActivityDataManager.config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ACTIVITY); -- require "Core.Config.activity";
ActivityDataManager.activity_reward = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ACTIVITY_REWARD); -- require "Core.Config.activity_reward";

ActivityDataManager.has_init = false;

ActivityDataManager.TYPE_DAY_ACTIVITY = 1; -- 每日活动
ActivityDataManager.TYPE_DAY_FB = 2;      -- 日常副本
ActivityDataManager.TYPE_TIME_ACTIVITY = 3;  -- 限时活动

ActivityDataManager.interface_id_1 = 1; -- 悬赏任务
ActivityDataManager.interface_id_2 = 2; -- 循环任务
ActivityDataManager.interface_id_3 = 3; -- 竞技场
ActivityDataManager.interface_id_4 = 4; -- 仙盟任务
ActivityDataManager.interface_id_6 = 6; -- 仙盟聚饮
ActivityDataManager.interface_id_7 = 7; -- 奇花苑
ActivityDataManager.interface_id_8 = 8; -- 虚灵塔
ActivityDataManager.interface_id_9 = 9; -- 古魔来袭
ActivityDataManager.interface_id_10 = 10; -- 世界Boss

ActivityDataManager.interface_id_14 = 14; -- 螟族入侵
ActivityDataManager.interface_id_15 = 15; -- 上界争霸
ActivityDataManager.interface_id_16 = 16; -- 仙盟气运战
ActivityDataManager.interface_id_17 = 17; -- 仙盟首领活动
ActivityDataManager.interface_id_18 = 18; -- 无尽试练

ActivityDataManager.interface_id_25 = 25; -- 宗门历练
ActivityDataManager.interface_id_26 = 26; -- 剧情副本
ActivityDataManager.interface_id_27 = 27; -- 海皇宫
ActivityDataManager.interface_id_28 = 28; -- 小炎界
ActivityDataManager.interface_id_29 = 29;-- 伏蛟山
ActivityDataManager.interface_id_30 = 30;-- 九幽王座
ActivityDataManager.interface_id_31 = 31;-- 仙盟聚会
ActivityDataManager.interface_id_32 = 32;-- 禁忌之地
ActivityDataManager.interface_id_33 = 33;-- 野外挂机
ActivityDataManager.interface_id_34 = 34;-- 心机大冒险
ActivityDataManager.interface_id_35 = 35;-- 鬼王赐宝
ActivityDataManager.interface_id_36 = 36;-- 上古妖兽


ActivityDataManager.day_activity_bf_cf = nil;
ActivityDataManager.day_bf_cf = nil;
ActivityDataManager.time_activity_bf_cf = nil;

ActivityDataManager.MESSAGE_SERVERDATA_CHANGE = "MESSAGE_SERVERDATA_CHANGE";
ActivityDataManager.MESSAGE_SERVERDATA_AV_CHANGE = "MESSAGE_SERVERDATA_AV_CHANGE";


ActivityDataManager.serverData = { };

function ActivityDataManager.ReInit()

    ActivityDataManager.has_init = false;
    ActivityDataManager.Init();

end

function ActivityDataManager.Init()

    if not ActivityDataManager.has_init then

        ActivityDataManager.day_activity_bf_cf = { };
        ActivityDataManager.day_bf_cf = { };
        ActivityDataManager.time_activity_bf_cf = { };

        for key, v in pairs(ActivityDataManager.config) do

            local activity_type = v.activity_type;
            local order = v.order;

            if activity_type == ActivityDataManager.TYPE_DAY_ACTIVITY then
                -- ActivityDataManager.day_activity_bf_cf[order] = v;
                table.insert(ActivityDataManager.day_activity_bf_cf, v);
            elseif activity_type == ActivityDataManager.TYPE_DAY_FB then
                -- ActivityDataManager.day_bf_cf[order] = v;
                table.insert(ActivityDataManager.day_bf_cf, v);
            elseif activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY then
                -- ActivityDataManager.time_activity_bf_cf[order] = v;
                table.insert(ActivityDataManager.time_activity_bf_cf, v);
            end
        end


        table.sort(ActivityDataManager.day_activity_bf_cf, function(a, b) return a.order < b.order end)
        table.sort(ActivityDataManager.day_bf_cf, function(a, b) return a.order < b.order end)
        table.sort(ActivityDataManager.time_activity_bf_cf, function(a, b) return a.order < b.order end)


        ActivityDataManager.has_init = true;
    end

end


-- 检测主界面的 活动按钮是否需要显示 红点
function ActivityDataManager.CheckMainMemuShowPoint()
    ActivityDataManager.Init();

    for key, v in pairs(ActivityDataManager.config) do
        local b = ActivityDataManager.CheckShowPoint(v);
        if b then
            return true;
        end
    end

    return false;
end


function ActivityDataManager.Check_activity_type_ShowPoint(activity_type)
    ActivityDataManager.Init();

    if activity_type == ActivityDataManager.TYPE_DAY_ACTIVITY then

        return ActivityDataManager.CheckShowPointByList(ActivityDataManager.day_activity_bf_cf)
    elseif activity_type == ActivityDataManager.TYPE_DAY_FB then

        return ActivityDataManager.CheckShowPointByList(ActivityDataManager.day_bf_cf)
    elseif activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY then

        return ActivityDataManager.CheckShowPointByList(ActivityDataManager.time_activity_bf_cf)
    end

    return false;
end


function ActivityDataManager.CheckShowPointByList(list)

    for key, v in pairs(list) do
        local b = ActivityDataManager.CheckShowPoint(v);
        if b then
            return true;
        end
    end

    return false;

end

function ActivityDataManager.CheckShowPoint(cf)

    if cf == nil then
        return false;
    end

    local activity_type = cf.activity_type;


    if activity_type == ActivityDataManager.TYPE_DAY_ACTIVITY then
        -- 日常活动
        return ActivityDataManager.CheckDayActivityPoint(cf);

    elseif activity_type == ActivityDataManager.TYPE_DAY_FB then
        -- 多人副本
        -- http://192.168.0.8:3000/issues/3976
        -- 多人副本标签页下面的活动有次数时
        return ActivityDataManager.CheckFBPoint(cf);


    elseif activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY then
        -- 限时副本
        return ActivityDataManager.CheckXianShiActivity(cf)

    end



    return false;
end

--[[http://192.168.0.8:3000/issues/3977
1.不在活动时间内，不显示红点
2.没有活动次数不显示红点
3.其他条件不足时，不显示红点（例如有些需要对应仙盟等级的活动）

]]
function ActivityDataManager.CheckXianShiActivity(cf)

    local show_lev = cf.show_lev;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv < show_lev then
        return false;
    end

    ------------------------------------------------------------
    local interface_data = cf.interface_data;
    local interface_param = cf.interface_param;

    local a_arr = string.split(interface_data, "_");

    local t_num = table.getn(a_arr);
    for i = 1, t_num do
        local tp = a_arr[i] + 0;
        if tp == RCActivityItem.CT_TYPE_1 then
            -- 指是否加入仙盟
            local inGuild = GuildDataManager.InGuild();
            if not inGuild then
                return false;
            end

        elseif tp == RCActivityItem.CT_TYPE_2 then
            -- 指仙盟等级条件 tong_extend  表的   id==5  level
            local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUILDEXTEND);
            local index = tonumber(interface_param[i]);
            local cfdata = config[index];

            local g = GuildDataManager.GetMyGuildData()

            if g.level < cfdata.level then
                return false;

            end

        elseif tp == RCActivityItem.CT_TYPE_3 then

            -- 最后判断 最近的等级
            local min_lev = cf.min_lev;
            if my_lv < min_lev then

                return false;
            end

        end

    end

    -------------------------------------------------------------------------
    local timeInfo = ActivityDataManager.GetActive_time_label(cf.active_time, cf.active_date);

    if timeInfo.type == ActivityDataManager.TIME_TYPE_UNOPEN then

        return false;

    elseif timeInfo.type == ActivityDataManager.TIME_TYPE_HASPASS then

        return false;

    elseif timeInfo.type == ActivityDataManager.TIME_TYPE_IN_ACTIVITY then

    end


    local ft_data = ActivityDataManager.GetFtById(cf.id);
    if ft_data ~= nil then

        if cf.activity_times > 0 and cf.activity_times > ft_data.ft then
            return true;
        end

    else
        return true;
    end

    return false;

end

ActivityDataManager.CT_TYPE_1 = 1; -- 指是否加入仙盟
ActivityDataManager.CT_TYPE_2 = 2; -- 指仙盟等级条件 tong_extend  表的   id==5  level
ActivityDataManager.CT_TYPE_3 = 3; -- 活动需求等级

--[[ 日常活动
 日常活动、签页下面的活动有次数时 均需要显示红点，红点的位置见截图（标签页上和前往按钮）

]]
function ActivityDataManager.CheckDayActivityPoint(cf)

    local show_lev = cf.show_lev;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv < show_lev then
        return false;
    end

    ------------------------------------------------------------
    local interface_data = cf.interface_data;
    local interface_param = cf.interface_param;

    local a_arr = string.split(interface_data, "_");

    local t_num = table.getn(a_arr);
    for i = 1, t_num do
        local tp = a_arr[i] + 0;
        if tp == RCActivityItem.CT_TYPE_1 then
            -- 指是否加入仙盟
            local inGuild = GuildDataManager.InGuild();
            if not inGuild then
                return false;
            end

        elseif tp == RCActivityItem.CT_TYPE_2 then
            -- 指仙盟等级条件 tong_extend  表的   id==5  level
            local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUILDEXTEND);
            local pindex = tonumber(interface_param[i]);
            local cfdata = config[pindex];

            local g = GuildDataManager.GetMyGuildData()

            if g.level < cfdata.level then
                return false;

            end

        elseif tp == RCActivityItem.CT_TYPE_3 then

            -- 最后判断 最近的等级
            local min_lev = cf.min_lev;
            if my_lv < min_lev then

                return false;
            end

        end

    end

    -------------------------------------------------------------------------
    local timeInfo = ActivityDataManager.GetActive_time_label(cf.active_time, cf.active_date);

    if timeInfo.type == ActivityDataManager.TIME_TYPE_UNOPEN then

        return false;

    elseif timeInfo.type == ActivityDataManager.TIME_TYPE_HASPASS then

        return false;

    elseif timeInfo.type == ActivityDataManager.TIME_TYPE_IN_ACTIVITY then

    end

    local ft_data = ActivityDataManager.GetFtById(cf.id);
    if ft_data ~= nil then

        if cf.activity_times > 0 and cf.activity_times > ft_data.ft then

            return true;
        end

    else
        if cf.active_degree > 0 then
            return true;
        end

    end

    return false;

end

function ActivityDataManager.Get_buy_num(interface_id)
    local buy_num = 0;
    if interface_id == ActivityDataManager.interface_id_27 then
        --  海皇宫
        buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.SpiritStonesInstance);

    elseif interface_id == ActivityDataManager.interface_id_28 then
        --  小炎界
        buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.EquipInstance);
    elseif interface_id == ActivityDataManager.interface_id_29 then
        --  伏蛟山
        buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.MaterialInstance);
    elseif interface_id == ActivityDataManager.interface_id_30 then
        --  九幽王座
        buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.type_jiuyouwangzuo);
    elseif interface_id == ActivityDataManager.interface_id_18 then
        --  无尽试练
        buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.type_endlessTry);
    elseif interface_id == ActivityDataManager.interface_id_14 then
        --  螟族入侵
        buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.type_MingZhuRuQing);
    end

    return buy_num;
end

function ActivityDataManager.CheckFBPoint(cf)

    local interface_id = cf.interface_id;


    local show_lev = cf.min_lev;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv < show_lev then
        return false;
    end


    local buy_num = ActivityDataManager.Get_buy_num(interface_id);

    local temnum = cf.activity_times + buy_num;

    if temnum > 0 then

        local ft_data = ActivityDataManager.GetFtById(cf.id);
        if ft_data ~= nil then

            if ft_data.ft < temnum then

                return true;
            end

        else
            return true;
        end

    end




    return false;
end


-- activity_id 活动配置activity.lua  的 id
function ActivityDataManager.OpenActivityUI(activity_id)

    local cf = ActivityDataManager.GetCfBy_id(activity_id);
    local activity_type = cf.activity_type;

    if activity_type == ActivityDataManager.TYPE_DAY_ACTIVITY then
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY, id = activity_id });
    elseif activity_type == ActivityDataManager.TYPE_DAY_FB then
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGFB, id = activity_id });
    elseif activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY then
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_TIMEACTIVITY, id = activity_id });
    end



end

function ActivityDataManager.GetCfByInterface_id(interface_id)
    for key, v in pairs(ActivityDataManager.config) do

        if v.interface_id == interface_id then
            return v;
        end
    end
    return nil;
end


function ActivityDataManager.GetCfBy_id(id)
    for key, v in pairs(ActivityDataManager.config) do

        if v.id == id then
            return v;
        end
    end
    return nil;
end

--[[05 获取活跃数据
输入：
输出：
pa：av:活跃总值active_value，rr：活动奖励领取记录 活跃值1_活跃值2_活跃值3...（reward_record）
ar：[id：活动ID ，ft：完成次数（finish_times）]

S <-- 20:41:29.600, 0x1105, 16, {"ar":[{"id":3,"ft":1}],"pa":{"rr":["1_20"],"av":80}


hezhi

]]
function ActivityDataManager.SetServerData(data)


    ActivityDataManager.serverData.pa = data.pa;
    if data.pa.av then SDKHelper.liveness = data.pa.av >= 100 end
    local ar = data.ar;
    local list = { };

    for key, value in pairs(ar) do
        list[value.id .. ""] = value;
    end

    ActivityDataManager.serverData.ar = list;

    MessageManager.Dispatch(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_CHANGE);

end

function ActivityDataManager.GetTotalActivity()

    if ActivityDataManager.serverData.pa == nil then
        return 0;
    else
        return ActivityDataManager.serverData.pa.av;
    end

end

function ActivityDataManager.GethasSetrr(av)

    local id = ActivityDataManager.Get_activity_reward_id();

    if ActivityDataManager.serverData.pa == nil then
        ActivityDataManager.serverData.pa = { };
    end

    if ActivityDataManager.serverData.pa.rr == nil then
        ActivityDataManager.serverData.pa.rr = { };
    end

    local t_num = table.getn(ActivityDataManager.serverData.pa.rr);

    ActivityDataManager.serverData.pa.rr[t_num + 1] = id .. "_" .. av;

    MessageManager.Dispatch(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_CHANGE);
end

function ActivityDataManager.GethasGetrr(id, av)

    if ActivityDataManager.serverData.pa == nil then
        ActivityDataManager.serverData.pa = { };
    end

    if ActivityDataManager.serverData.pa.rr == nil then
        ActivityDataManager.serverData.pa.rr = { };
    end

    for key, value in pairs(ActivityDataManager.serverData.pa.rr) do

        local arr = string.split(value, "_");
        local t_id = arr[1] + 0;
        local t_av = arr[2] + 0;

        if id == t_id and av == t_av then
            return true;
        end
    end

    return false;

end

-- 获取当前的活跃度
function ActivityDataManager.GetAv()

    if ActivityDataManager.serverData.pa == nil then
        ActivityDataManager.serverData.pa = { };
    end

    if ActivityDataManager.serverData.pa.av == nil then
        ActivityDataManager.serverData.pa.av = 0;
    end

    return ActivityDataManager.serverData.pa.av;

end

function ActivityDataManager.GetAvt()

    if ActivityDataManager.serverData.pa == nil then
        ActivityDataManager.serverData.pa = { };
    end

    if ActivityDataManager.serverData.pa.avt == nil then
        ActivityDataManager.serverData.pa.avt = 0;
    end

    return ActivityDataManager.serverData.pa.avt;

end

-- 设置当前的活跃度
function ActivityDataManager.SetAv(v)
    if ActivityDataManager.serverData.pa == nil then
        ActivityDataManager.serverData.pa = { };
    end
    ActivityDataManager.serverData.pa.av = v;
    MessageManager.Dispatch(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_AV_CHANGE);
    SDKHelper.liveness = v >= 100
end



function ActivityDataManager.Get_activity_reward_id()

    local myData = HeroController:GetInstance().info
    local mylv = myData.level;

    for key, value in pairs(ActivityDataManager.activity_reward) do
        local min_lev = value.min_lev;
        local max_lev = value.max_lev;

        if min_lev <= mylv and max_lev >= mylv then
            return value.id;
        end

    end
    return nil;

end

function ActivityDataManager.Get_activity_reward_lvs()

    local myData = HeroController:GetInstance().info
    local mylv = myData.level;

    for key, value in pairs(ActivityDataManager.activity_reward) do
        local min_lev = value.min_lev;
        local max_lev = value.max_lev;

        if min_lev <= mylv and max_lev >= mylv then
            return value.active_condition;
        end

    end
    return nil;

end


function ActivityDataManager.Get_activity_reward(av_index)
    local myData = HeroController:GetInstance().info
    local mylv = myData.level;

    for key, value in pairs(ActivityDataManager.activity_reward) do
        local min_lev = value.min_lev;
        local max_lev = value.max_lev;

        if min_lev <= mylv and max_lev >= mylv then
            return value.active_reward[av_index];
        end

    end
    return nil;
end

function ActivityDataManager.GetFtById(id)

    if ActivityDataManager.serverData.ar == nil then
        ActivityDataManager.serverData.ar = { };
    end

    local key = id .. "";
    return ActivityDataManager.serverData.ar[key];
end

-- 获取限时活动数据 
function ActivityDataManager.GetLTAList()

    local list = { };

    local t_num = table.getn(ActivityDataManager.time_activity_bf_cf);
    local pag_num = math.ceil(t_num / 8);
    local index = 1;

    for i = 1, pag_num do
        local pitem = { };
        for j = 1, 8 do
            pitem[j] = ActivityDataManager.time_activity_bf_cf[index];
            index = index + 1;
        end
        list[i] = pitem;
    end


    return list;

end

-- 获取日常活动数据 
function ActivityDataManager.GetRCAList()

    local list = { };

    local actBFCf = { }
    local actIndex = 1;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;


    local t_num = table.getn(ActivityDataManager.day_activity_bf_cf);
    for i = 1, t_num do
        local obj = ActivityDataManager.day_activity_bf_cf[i];
        -- 过滤掉不可显示的
        if my_lv >= obj.show_lev then
            actBFCf[actIndex] = obj;
            actIndex = actIndex + 1;
        end

    end

    t_num = table.getn(actBFCf);
    local pag_num = math.ceil(t_num / 8);


    local index = 1;

    for i = 1, pag_num do
        local pitem = { };
        for j = 1, 8 do
            pitem[j] = actBFCf[index];
            index = index + 1;
        end
        list[i] = pitem;
    end

    return list;

end

function ActivityDataManager.GetFBList()

    local list = { };

    local t_num = table.getn(ActivityDataManager.day_bf_cf);
    local pag_num = math.ceil(t_num / 6);
    local index = 1;

    for i = 1, pag_num do
        local pitem = { };
        for j = 1, 6 do
            pitem[j] = ActivityDataManager.day_bf_cf[index];
            index = index + 1;
        end
        list[i] = pitem;
    end

    return list;

end

-- '12:00-12:30'
function ActivityDataManager.CpTime(a, b)


    local a_arr = string.split(a, ":");
    local b_arr = string.split(b, ":");

    local a_h = a_arr[1] + 0;
    local a_m = a_arr[2] + 0;

    local b_h = b_arr[1] + 0;
    local b_m = b_arr[2] + 0;

    if a_h > b_h then
        return true;
    elseif a_h == b_h then
        if a_m >= b_m then
            return true;
        end
    end

    return false;

end

--  a 现在时间
--  b 开始时间
function ActivityDataManager.GetElseTime(a, b)

    local a_arr = string.split(a, ":");
    local b_arr = string.split(b, ":");

    local a_h = a_arr[1] + 0;
    local a_m = a_arr[2] + 0;
    local a_sec = a_arr[3] + 0;

    local b_h = b_arr[1] + 0;
    local b_m = b_arr[2] + 0;

    local at = a_h * 3600 + a_m * 60 + a_sec;
    local bt = b_h * 3600 + b_m * 60;

    return bt - at;

end

-- ['active_time'] = {'12:00-12:30','16:00-18:30','20:00-20:30'},
ActivityDataManager.TIME_TYPE_UNOPEN = 1;-- 还没开始
ActivityDataManager.TIME_TYPE_HASPASS = 2;-- 已经结束
ActivityDataManager.TIME_TYPE_IN_ACTIVITY = 3;-- 在活动时间内




--[[
active_date  星期 几
['active_date'] = {1,2,3,4,5,6,7},	--活动日期
]]
function ActivityDataManager.GetActive_time_label(active_time, active_date)
    local t_num = table.getn(active_time);

    local time = GetOffsetTime();
    local curr_sysT = os.date("%H:%M", time);
    local wfd = os.date("*t", time);
    local wd = wfd.wday;

    local result = { };

    --  检测 星期几
    local inData = false;
    local d_num = table.getn(active_date);

    for j = 1, d_num do
        local td = active_date[j] + 0;

        if td == wd then
            inData = true;

        end
    end

    result.isInData = inData;
    result.active_time = active_time;

    if not result.isInData then

        result.label = active_time[1];
        result.type = ActivityDataManager.TIME_TYPE_UNOPEN;
        return result;
    end

    -- 检测是否在时间范围内
    for i = 1, t_num do

        local currtime = active_time[i];
        local timeArr = string.split(currtime, "-");
        local starTime = timeArr[1];
        local endTime = timeArr[2];

        local t1 = ActivityDataManager.CpTime(curr_sysT, starTime);
        local t2 = ActivityDataManager.CpTime(endTime, curr_sysT);

        --[[
        log("starTime  " .. starTime);
        log("curr_sysT  " .. curr_sysT);
        log("endTime  " .. endTime);
        ]]
        if t1 and t2 then
            result.label = currtime;
            result.type = ActivityDataManager.TIME_TYPE_IN_ACTIVITY;
            -- 在活动时间内
            return result;
        end


        if not t1 then
            result.label = currtime;
            -- 显示开始时间
            result.type = ActivityDataManager.TIME_TYPE_UNOPEN;
            -- 剩余时间
            local curr_sysTsec = os.date("%H:%M:%S", time);

            result.elseTime = ActivityDataManager.GetElseTime(curr_sysTsec, starTime);

            -- 还没开始
            return result;
        end

        if i == t_num and not t2 then
            result.label = currtime;
            result.type = ActivityDataManager.TIME_TYPE_HASPASS;
            -- 已经结束
            return result;
        end
    end



    return result;

end 



function ActivityDataManager.ActiveDo(active_id)

    local data = ActivityDataManager.GetCfBy_id(active_id);

    if data.minipack_open == 0 and not AppSplitDownProxy.SysCheckLoad(nil, PlayerManager.GetPlayerLevel()) then return end

    local interface_id = data.interface_id;
    local activity_type = data.activity_type;

    -- log(" activity_type " .. activity_type);
    -- log(" interface_id " .. interface_id);

    local timeInfo = ActivityDataManager.GetActive_time_label(data.active_time, data.active_date);

    -- if self.timeInfo.type == ActivityDataManager.TIME_TYPE_IN_ACTIVITY or(self.timeInfo.type == ActivityDataManager.TIME_TYPE_UNOPEN and activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY) then
    if timeInfo.type == ActivityDataManager.TIME_TYPE_IN_ACTIVITY or(activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY) then
        -- 限时活动没限制
        SequenceManager.TriggerEvent(SequenceEventType.Guide.ACTIVITY_SELECTED, interface_id);
        --  ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
        if interface_id == ActivityDataManager.interface_id_1 then
            ModuleManager.SendNotification(TaskNotes.OPEN_REWARDTASKPANEL);
        elseif interface_id == ActivityDataManager.interface_id_26 then
            -- 剧情副本
            -- ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
            ModuleManager.SendNotification(InstancePanelNotes.OPEN_INSTANCEPANEL);
        elseif interface_id == ActivityDataManager.interface_id_2 then
            if not TaskManager.HasDailyTask() then
                TaskProxy.ReqAccDailyTask();
            end
            ModuleManager.SendNotification(TaskNotes.OPEN_TASKPANEL, TaskConst.Type.DAILY);
        elseif interface_id == ActivityDataManager.interface_id_3 then
            PVPProxy.SendGetPVPPlayer()

        elseif interface_id == ActivityDataManager.interface_id_4 then
            ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.TASK);

        elseif interface_id == ActivityDataManager.interface_id_6 then
            -- 聚饮删除
            -- ModuleManager.SendNotification(GuildJuYingNotes.OPEN_GUILDJUYINGPANEL);


        elseif interface_id == ActivityDataManager.interface_id_8 then
            ModuleManager.SendNotification(XLTInstanceNotes.OPEN_XLTINSTANCE_PANEL);

        elseif interface_id == ActivityDataManager.interface_id_9 then
            ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSPANEL);

        elseif interface_id == ActivityDataManager.interface_id_10 then
            ModuleManager.SendNotification(WorldBossNotes.OPEN_WORLDBOSSPANEL);

            --[[
            elseif interface_id == ActivityDataManager.interface_id_14 then

                -- 直接跳场景， 所以需要关闭 活动界面
                ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                    title = LanguageMgr.Get("common/notice"),
                    msg = LanguageMgr.Get("Activity/RCActivityItem/label8"),
                    ok_Label = LanguageMgr.Get("common/ok"),
                    cance_lLabel = LanguageMgr.Get("common/cancle"),
                    hander = RCActivityItem.TryReqEnterZone
                } );
               ]]

        elseif interface_id == ActivityDataManager.interface_id_15 then
            ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIPANEL);

        elseif interface_id == ActivityDataManager.interface_id_16 then

            ModuleManager.SendNotification(GuildWarNotes.OPEN_PANEL);

        elseif interface_id == ActivityDataManager.interface_id_7 then
            ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANROOTPANEL);
        elseif interface_id == ActivityDataManager.interface_id_17 then
            ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSPANEL);

        elseif interface_id == ActivityDataManager.interface_id_31 then
            RCActivityItem.TryReqEnterZone();
        elseif interface_id == ActivityDataManager.interface_id_32 then
            ModuleManager.SendNotification(TabooNotes.OPEN_TABOO_PANEL, data)
        elseif interface_id == ActivityDataManager.interface_id_33 then
            ModuleManager.SendNotification(MapNotes.OPEN_FIELD_MAP_PANEL);

        elseif interface_id == ActivityDataManager.interface_id_34 then
            -- 如果不在活动时间内 ， 提示
            timeInfo = ActivityDataManager.GetActive_time_label(data.active_time, data.active_date);

            if timeInfo.type == ActivityDataManager.TIME_TYPE_IN_ACTIVITY then
                ModuleManager.SendNotification(XinJiRisksNotes.OPEN_XINJIRISKSPANEL);
            else
                local elseTime = timeInfo.elseTime;
                if elseTime ~= nil then
                    -- log("result.elseTime " .. elseTime);

                    if elseTime <= 60 and elseTime > 1 then
                        ModuleManager.SendNotification(XinJiRisksNotes.OPEN_XINJIRISKSPANEL, { elseTime = elseTime });
                    end


                else
                    MsgUtils.ShowTips("Activity/RCActivityItem/label11");
                end



            end


        elseif interface_id == ActivityDataManager.interface_id_28 or interface_id == ActivityDataManager.interface_id_30 or interface_id == ActivityDataManager.interface_id_14 then

            local instance_type = data.instance_type;

            local args = { name = data.activity_name, interface_id = interface_id, interface_data = data.interface_data, type = instance_type, kind = InstanceDataManager.kind_0 };
            ModuleManager.SendNotification(LSInstanceNotes.OPEN_LSINSTANCEPANEL, args);
        elseif interface_id == ActivityDataManager.interface_id_35 then

            SceneEntityMgr.SetActiveData(data)
            SceneEntityMgr.GameStart()
            ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
        elseif interface_id == ActivityDataManager.interface_id_36 then
            ModuleManager.SendNotification(YaoShouNotes.OPEN_YAOSHOUPANEL);
            ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
        end

    else

        --[[            if interface_id == ActivityDataManager.interface_id_14 then

                MsgUtils.ShowTips("Activity/RCActivityItem/label7");


            elseif interface_id == ActivityDataManager.interface_id_15 then
                -- http://192.168.0.8:3000/issues/2153
                ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIPANEL);

            end
            ]]

        if interface_id == ActivityDataManager.interface_id_35 then

            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                title = LanguageMgr.Get("common/notice"),
                msg = LanguageMgr.Get("Activity/RCActivityItem/label13"),
                ok_Label = LanguageMgr.Get("common/ok"),
                cance_lLabel = LanguageMgr.Get("common/cancle"),
                hander = function()

                    SceneEntityMgr.SetActiveData(data)
                    SceneEntityMgr.GameStart()
                    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

                end
            } );

        end


    end


end