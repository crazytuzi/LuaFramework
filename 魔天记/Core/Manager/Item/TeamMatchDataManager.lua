TeamMatchDataManager = { };

TeamMatchDataManager.hasInit = false;

-- 1: 宗门历练 2：小炎界 3：海皇宫）
TeamMatchDataManager.type_err = 0; -- 错误指令
TeamMatchDataManager.type_1 = 1;-- 宗门历练
TeamMatchDataManager.type_2 = 2; -- 小炎界
TeamMatchDataManager.type_3 = 3; -- 海皇宫
TeamMatchDataManager.type_4 = 4; -- 伏蛟山

TeamMatchDataManager.type_15 = 15;-- 螟族入侵
TeamMatchDataManager.type_13 = 13;-- 九幽王座
TeamMatchDataManager.type_12 = 12;-- 无尽试练

TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_ING = "MESSAGE_TEAMMATCH_PIPEI_ING";
TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS = "MESSAGE_TEAMMATCH_PIPEI_SUCCESS";
TeamMatchDataManager.MESSAGE_TEAMMATCH_RECPIPEIINFOS_CHANGE = "MESSAGE_TEAMMATCH_RECPIPEIINFOS_CHANGE";




TeamMatchDataManager.currPiPeiIng_data = nil;

function TeamMatchDataManager.checkInit()

    if not TeamMatchDataManager.hasInit then

        TeamMatchDataManager.typeLists = { };
        TeamMatchDataManager.typeLists[TeamMatchDataManager.type_1] = { };
        TeamMatchDataManager.typeLists[TeamMatchDataManager.type_2] = { };
        TeamMatchDataManager.typeLists[TeamMatchDataManager.type_3] = { };
        TeamMatchDataManager.typeLists[TeamMatchDataManager.type_4] = { };

        local cf = ConfigManager.Get_experience_lev();


        for key, value in pairs(cf) do
            local v = value;
            --Warning(v.type .. v.type_name)
            if TeamMatchDataManager.typeLists[v.type] == nil then
                TeamMatchDataManager.typeLists[v.type] = { };
            end

            local t_num = table.getn(TeamMatchDataManager.typeLists[v.type]);
            TeamMatchDataManager.typeLists[v.type][t_num + 1] = v;
        end

        TeamMatchDataManager.hasInit = true;
    end



end

-- 宗门历练是否正在匹配中
function TeamMatchDataManager.ZongMengLiLian_is_pipei_ing()
    if TeamMatchDataManager.currPiPeiIng_data ~= nil and TeamMatchDataManager.currPiPeiIng_data.type == TeamMatchDataManager.type_1 then
        return true;
    end
    return false;
end

function TeamMatchDataManager.GetList(type)
    TeamMatchDataManager.checkInit();

    local t = tonumber(type);
    local list = TeamMatchDataManager.typeLists[t];



    if list == nil then

        --  添加未知类型的数据
        TeamMatchDataManager.typeLists[t] = { };
        local cf = ConfigManager.Get_experience_lev();

        for key, value in pairs(cf) do
            local v = value;
            if v.type == t then
                local t_num = table.getn(TeamMatchDataManager.typeLists[t]);
                TeamMatchDataManager.typeLists[t][t_num + 1] = v;
            end
        end
    end
    --Warning(t .. tostring(#list))

     table.sort(list, function(x, y) return x.order < y.order end)

    return list;

end

function TeamMatchDataManager.GetCfById(id)

    local cf = ConfigManager.Get_experience_lev();

   for key, value in pairs(cf) do
       
        if value.id == id then
            return value;
        end
    end

    return nil;
end

function TeamMatchDataManager.GetCfByTypeAndmin_level(type, min_level)

    local cf = ConfigManager.Get_experience_lev();

   for key, value in pairs(cf) do
        if value.type == type and value.min_level == min_level then
            return value;
        end
    end

    return nil;
end

------------------------------------------------ 监听匹配数据 ------------------------------------------------------------------------------------------


function TeamMatchDataManager.OnRegister()
    -- TeamMatchDataManager.OnRemove();

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ZongMenLiLianPiPeiSuccess, TeamMatchDataManager.TeamMatchPiPeiSuccessResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ZongMenLiLianQuXianPiPei, TeamMatchDataManager.TeamMatchQuXianPiPeiResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RecPipeiInfos, TeamMatchDataManager.RecPipeiInfosResult);

    MessageManager.AddListener(Reconnect, Reconnect.MESSAGE_CONNECTSUCCEED, TeamMatchDataManager.ConnectSuccess);
end


function TeamMatchDataManager.OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ZongMenLiLianPiPeiSuccess, TeamMatchDataManager.TeamMatchPiPeiSuccessResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ZongMenLiLianQuXianPiPei, TeamMatchDataManager.TeamMatchQuXianPiPeiResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RecPipeiInfos, TeamMatchDataManager.RecPipeiInfosResult);

    MessageManager.RemoveDataPacketListener(Reconnect, Reconnect.MESSAGE_CONNECTSUCCEED, TeamMatchDataManager.ConnectSuccess);
end


function TeamMatchDataManager.ConnectSuccess()
    TeamMatchDataManager.DisSetNone();

end

function TeamMatchDataManager.DisSetNone()
    TeamMatchDataManager.currPiPeiIng_data = nil;
    MessageManager.Dispatch(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, TeamMatchDataManager.type_err);
end

--[[
1A 取消队伍匹配(服务器通知)
输入：
t：类型
输出：
t:类型

]]
function TeamMatchDataManager.TeamMatchQuXianPiPeiResult(cmd, data)

    TeamMatchDataManager.currPiPeiIng_data = nil;
    if (data.errCode == nil) then

        -- t
        --  TeamMatchDataManager.type_1  宗门历练
        MessageManager.Dispatch(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, data.t);


    end


end

--[[
1F 队伍匹配信息广播（服务端通知）
输出：
t:类型（// 1: 宗门历练 2：小炎界 3：海皇宫）
lv：等级(配置表)
min_lv: 队长设置等级段
max_lv: 队长设置等级段

]]
function TeamMatchDataManager.RecPipeiInfosResult(cmd, data)

    if (data.errCode == nil) then

        TeamMatchDataManager.SetPipeiInfosResult(data)

    end

end

--[[

t:类型（// 1: 宗门历练 2：小炎界 3：海皇宫）
lv：等级(配置表)
min_lv: 队长设置等级段
max_lv: 队长设置等级段

]]
--  {t=1,lv=12,min_lv=1,max_lv=3}
function TeamMatchDataManager.SetPipeiInfosResult(data)
    TeamMatchDataManager.recPipeiInfos = data;
    MessageManager.Dispatch(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_RECPIPEIINFOS_CHANGE);

end


--[[
1A 取消队伍匹配(服务器通知)
输入：
t：类型
输出：
t:类型

]]
function TeamMatchDataManager.QuXianPiPei(t)
    SocketClientLua.Get_ins():SendMessage(CmdType.ZongMenLiLianQuXianPiPei, { t = t });
end

--[[
17 队伍（1: 宗门历练 2：小炎界 3：海皇宫)匹配成功通知（服务端发出）
输出：
t:类型（// 1: 宗门历练 2：小炎界 3：海皇宫）

]]
function TeamMatchDataManager.TeamMatchPiPeiSuccessResult(cmd, data)

    if (data.errCode == nil) then

        TeamMatchDataManager.currPiPeiIng_data = nil;
        MessageManager.Dispatch(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, data.t);
        MsgUtils.ShowTips("ZongMenLiLian/ZongMenLiLianProxy/label1");

    end
end



--[[
16 宗门历练队伍匹配
输入：
t:类型（// 1: 宗门历练 2：小炎界 3：海皇宫）
lv：等级(配置表)
min_lv: 队长设置等级段
max_lv: 队长设置等级段
输出：
t:类型（// 1: 宗门历练 2：小炎界 3：海皇宫
lv：等级



]]
function TeamMatchDataManager.TeamMatchPiPei(fbd, min_lv, max_lv)

    if min_lv == nil or max_lv == nil then

        local me = HeroController:GetInstance();
        local heroInfo = me.info;
        local my_lv = heroInfo.level;

        local up_float = fbd.up_float;
        local down_float = fbd.down_float;

        local left_lv = my_lv - down_float;
        local right_lv = my_lv + up_float;

        if left_lv < fbd.min_level then
            left_lv = fbd.min_level;
        end

        if right_lv > fbd.max_level then
            right_lv = fbd.max_level;
        end

        min_lv = left_lv;
        max_lv = right_lv;

    end


     if min_lv > max_lv then
        local b0 = min_lv;
        local b1 = max_lv;
        min_lv = b1;
        max_lv = b0;
    end

    TeamMatchDataManager.currPiPeiIng_data = fbd;
    MessageManager.Dispatch(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_ING, fbd.type);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ZongMenLiLianPiPei, TeamMatchDataManager.TeamMatchPiPeiResult);
    SocketClientLua.Get_ins():SendMessage(CmdType.ZongMenLiLianPiPei, { t = fbd.type, lv = fbd.min_level, min_lv = min_lv, max_lv = max_lv });

end


--[[
16 宗门历练队伍匹配
输入：
t:类型（// 1: 宗门历练 2：小炎界 3：海皇宫）
lv：等级
输出：
t:类型（// 1: 宗门历练 2：小炎界 3：海皇宫
lv：等级


]]
function TeamMatchDataManager.TeamMatchPiPeiResult(cmd, data)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ZongMenLiLianPiPei, TeamMatchDataManager.TeamMatchPiPeiResult);
    if (data.errCode == nil) then

        -- 看看自己 是否 是队长 如果， 不是队长，那么就 把正在匹配  改 会  匹配

        local mld = PartData.MeIsTeamLeader();
        if not mld then
            MessageManager.Dispatch(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, data.t);
        end

        --
        local num = PartData.GetMyTeamNunberNum();

        if num <= 1 then

            TeamMatchDataManager.RecPipeiInfosResult(cmd, data)
        end

    else
        TeamMatchDataManager.DisSetNone();
    end
end


