

PartData = { };
PartData.MESSAGE_PARTY_DATA_CHANGE = "MESSAGE_PARTY_DATA_CHANGE";
PartData.MESSAGE_PARTY_MENBER_DATA_CHANGE = "MESSAGE_PARTY_MENBER_DATA_CHANGE";
PartData.MESSAGE_PARTY_MENBER_ACCEPT_CHANGE = "MESSAGE_PARTY_MENBER_ACCEPT_CHANGE";

PartData.MESSAGE_PARTY_MENBER_SCENE_ID_CHANGE = "MESSAGE_PARTY_MENBER_SCENE_ID_CHANGE";


PartData.PARTY_DATA_CHANGE_TYPE_SETMYTEAM = 1;
PartData.PARTY_DATA_CHANGE_TYPE_UPMENBERS = 2;

PartData.PARTY_DATA_CHANGE_TYPE_SETNEW_TEAMLEADER_NAME = 3;
PartData.PARTY_DATA_CHANGE_TYPE_MENBERLEAVETEAM = 4;
PartData.PARTY_DATA_CHANGE_TYPE_ADDMENBER = 5;

PartData.TEAM_MAX_NUM = 4; -- 最大人数

PartData.myTeam = nil;

-- 申请列表
PartData.applyTearmList = { };
local _sortfunc = table.sort 

function PartData.GetMyTeam()
    return PartData.myTeam;
end


--[[
id:队伍ID
n:队伍名字
m:队员[pid:玩家id，n:玩家昵称,k：玩家kind,l:等级,p:状态（0:正常1:死亡,2:距离太远,3:离线） ,s:身份(0:队员1:队长),hp:血量,mp:法术,f:战斗力]


 S <-- 20:34:41.648, 0x0B17, 9, {"m":[{"n":"\u9F9A\u73EE","pid":"20100368","k":103000,"hp":3211,"p":0,"mp":3583,"l":41,"f":26393},{"n":"\u8D56\u9704\u5DDD","pid":"20100796","k":101000,"hp":5490,"p":1,"mp":4079,"l":47,"f":47036}],"id":1}


]]
function PartData.SetMyTeam(data)

    if PartData.myTeam == nil and data ~= nil then
        ZongMenLiLianProxy.GetZongMenLiLianPreInfo()
    end

    if data ~= nil then
        if data.id == -1 then
            data = nil;
        end
    end

    PartData.myTeam = data;
    PartData.UpTeamList();

    if PartData.myTeam == nil then
        -- ZongMenLiLianDataManager.SetZongMenLiLianPreInfo( { mid = - 1 });
        TeamMatchDataManager.DisSetNone();
    end



    MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartData.PARTY_DATA_CHANGE_TYPE_SETMYTEAM);
end


--[[
  获取 在队伍里并 不是 自己 好友的 列表
  过滤掉不在先的， 只获取 在线的 玩家
]]
function PartData.TryGetNotMyFriendInTeam()

    local res = { };
    local res_index = 1;


    local myHero = HeroController.GetInstance();
    local mydata = myHero.info;
    local my_id = tonumber(mydata.id);

    if PartData.myTeam ~= nil then
        for key, value in pairs(PartData.myTeam.m) do


            local tpid = value.pid;
            -- 而且 在线的

            if tonumber(tpid) ~= my_id and value.s ~= 3 then

                local friendInfo = FriendDataManager.GetFriend(tpid);
                local enemyInfo = FriendDataManager.GetEnemy(tpid);


                if friendInfo == nil and enemyInfo == nil then
                    -- 不是自己的好友， 需要添加

                    res[res_index] = value;
                    res_index = res_index + 1;
                end

            end

        end
    end


    return res;
end


function PartData.SetNumberInScene(pid, scene_id)

    pid = pid + 0;
    local tm = PartData.GetMyTeam();
    if tm ~= nil then

        for key, value in pairs(tm.m) do
            local tpid = value.pid + 0;
            if tpid == pid then
                value.sId = scene_id;
            end
        end
    end

    MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_MENBER_SCENE_ID_CHANGE);

end

function PartData.GetNumberInScene(pid)
    pid = pid + 0;
    local tm = PartData.GetMyTeam();
    if tm ~= nil then

        for key, value in pairs(tm.m) do
            local tpid = value.pid + 0;
            if tpid == pid then
                return value.sId;
            end
        end
    end
    return 0;
end

function PartData.UpMenberS(id, s)

    id = id + 0;
    local tm = PartData.GetMyTeam();
    if tm ~= nil then

        for key, value in pairs(tm.m) do
            local pid = value.pid + 0;
            if pid == id then
                value.s = s;
            end
        end
    end

    MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartData.PARTY_DATA_CHANGE_TYPE_UPMENBERS);
end

function PartData.GetMyTeamNunberNum()

    local num = 0;
    if PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;
        for key, value in pairs(m) do
            num = num + 1;
        end
    end
    return num;
end

-- 获取 队伍人数对应的加成
function PartData.GetMyTeamExpAddition()
    local n = PartData.GetMyTeamNunberNum();
    if n == 1 then
        return 0;
    elseif n == 2 then
        return 10;
    elseif n == 3 then
        return 20;
    elseif n == 4 then
        return 30;
    end
    return 0;
end



--[[
对队列进行排序
]]
function PartData.UpTeamList()

    if PartData.myTeam ~= nil then

        local m = PartData.myTeam.m;

        local myHero = HeroController.GetInstance();
        local mydata = myHero.info;
        local my_id = mydata.id + 0;

        local res = { };
        local res_index = 1;

        for key, value in pairs(m) do


            if value.p == 1 then
                value.pt = 10000;
            elseif (value.pid + 0) == my_id then
                value.pt = 1000;
            else
                value.pt = 1;
            end

            res[res_index] = value;
            res_index = res_index + 1;
        end

        _sortfunc(res, function(a, b)
            return a.pt > b.pt;
        end );

        PartData.myTeam.m = res;

    end


end



--[[
设置 新队长的名字
]]
function PartData.SetNew_TeamLeader_name(pid, name)

    for key, value in pairs(PartData.myTeam.m) do
        if (value.pid + 0) ==(pid + 0) then

            PartData.myTeam.m[key].p = 1;
        else
            PartData.myTeam.m[key].p = 0;
        end
    end

    PartData.myTeam.n = name;

    PartData.UpTeamList();

    ChatManager.SystemMsg(name .. LanguageMgr.Get("Friend/PartData/tipLabel2"), ChatTag.team)

    TeamMatchDataManager.DisSetNone();

    MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartData.PARTY_DATA_CHANGE_TYPE_SETNEW_TEAMLEADER_NAME);
end


function PartData.ReSetAllAccept()
    if PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;
        for key, value in pairs(m) do
            m[key].accept = nil;
        end
    end
end

--[[
 S <-- 14:49:52.368, 0x0B15, 0, {"s":1,"id":"10100372","n":"姑苏墨"}

]]
function PartData.Setready(pid, accept)

    if PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;
        for key, value in pairs(m) do
            if (value.pid + 0) ==(pid + 0) then
                m[key].accept = accept;

                MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_MENBER_ACCEPT_CHANGE);
                return;
            end
        end
    end

end

--[[
m:队员[pid:玩家id，n:玩家昵称,k：玩家kind,l:等级,p:状态（0:正常1:死亡,2:距离太远,3:离线） ,s:身份(0:队员1:队长),hp:血量,mp:法术,f:战斗力]


18 队员升级，战斗力改变通知（服务端发出）
输出：
m:队员[id:玩家id，l:等级,hp:血量,max_hp:最大血量,f:战斗力]
0x0B18

]]
function PartData.TeamMenberDataChange(minfo)


    if PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;

        for key, value in pairs(m) do
            if value.pid == minfo.id then
                if minfo.hp ~= nil then
                    value.hp_max = minfo.hp_max;
                    value.hp = minfo.hp;
                end

                if minfo.f ~= nil then
                    value.f = minfo.f;
                end

                if minfo.l ~= nil then
                    value.l = minfo.l;
                end

                MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_MENBER_DATA_CHANGE, minfo);
                return;
            end
        end
    end

end

function PartData.MeIsTeamLeader()

    if PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;
        local myHero = HeroController.GetInstance();
        local mydata = myHero.info;

        for key, value in pairs(m) do
            if value.pid == mydata.id and value.p == 1 then
                return true;
            end
        end
    end
    return false;
end

function PartData.FindTeamLeader()
    if PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;
        for key, value in pairs(m) do
            if value.p == 1 then
                return value;
            end
        end
    end
    return nil;
end

--[[
 队员离开
]]
function PartData.MenberLeaveTeam(id)

    local myHero = HeroController.GetInstance();
    local mydata = myHero.info;

    if mydata.id == id then
        PartData.SetMyTeam(nil);
    elseif PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;
        local l_name = nil;

        for key, value in pairs(m) do

            local mpid = value.pid + 0;
            local vpid = id + 0;
            if mpid == vpid then
                l_name = m[key].n;
                m[key] = nil;
            end
        end
        PartData.UpTeamList();

        ChatManager.SystemMsg(l_name .. LanguageMgr.Get("Friend/PartData/tipLabel3"), ChatTag.team)

        MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartData.PARTY_DATA_CHANGE_TYPE_MENBERLEAVETEAM);
    end

end

--[[
5 队伍成员添加通知（服务端发出）
输出：
id:队伍ID
n:队伍名字
m:队员[pid:玩家id，n:玩家昵称,k：玩家kind,l:等级,p:状态(0:正常1:死亡,2:距离太远,3:离线),s:身份(0:队员1:队长),hp:血量,mp:法术,f:战斗力]
0x0B05


]]
function PartData.AddMenber(data)

    if PartData.myTeam == nil then
        PartData.myTeam = data;

        local myHero = HeroController.GetInstance();
        local mydata = myHero.info;

        local md = PartData.FindMyTeammateData(mydata.id);

        if md ~= nil and md.p == 0 then
            MsgUtils.ShowTips(nil, nil, nil, md.n .. LanguageMgr.Get("Friend/PartData/tipLabel1"));
            ChatManager.SystemMsg(md.n .. LanguageMgr.Get("Friend/PartData/tipLabel1"), ChatTag.team)
        end


        ZongMenLiLianProxy.GetZongMenLiLianPreInfo()

    else
        local m = PartData.myTeam.m;
        local len = table.getn(m);

        local dm = data.m;
        local dlen = table.getn(dm);

        for i = 1, dlen do
            m[i + len] = dm[i];

            -- 提示  其他人 加入队伍
            MsgUtils.ShowTips(nil, nil, nil, dm[i].n .. LanguageMgr.Get("Friend/PartData/tipLabel1"));
            ChatManager.SystemMsg(dm[i].n .. LanguageMgr.Get("Friend/PartData/tipLabel1"), ChatTag.team)
        end
    end

    PartData.UpTeamList();
    MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartData.PARTY_DATA_CHANGE_TYPE_ADDMENBER);


    PartData.CheckAutoStarFb();


end

-- http://192.168.0.8:3000/issues/8561
function PartData.CheckAutoStarFb()

    local num = PartData.GetMyTeamNunberNum();
    local isLd = PartData.MeIsTeamLeader();
    local obj = TeamMatchDataManager.currPiPeiIng_data;

    if obj ~= nil and isLd and num >= 4 then
        local t = obj.type;
        local lv = obj.min_level;
        PrintTable(obj);
        local cf = TeamMatchDataManager.GetCfByTypeAndmin_level(t, lv)

        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("Friend/PartData/tipLabel4"),
            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = function()
                GameSceneManager.GoToFB(cf.instance_id)
            end,
            ok_time = 10;
            target = nil,
            data = nil
        } );

    end


end

function PartData.FindMyTeammateData(pid)


    if PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;
        for key, value in pairs(m) do
            if value.pid == pid or tonumber(value.pid) == tonumber(pid) then
                return value;
            end
        end
    end

    return nil;
end
function PartData.SetTeamNumberName(pid, name)
    local nb = PartData.FindMyTeammateData(pid)
    if nb then
        nb.n = name
        MessageManager.Dispatch(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartData.PARTY_DATA_CHANGE_TYPE_SETNEW_TEAMLEADER_NAME);
    end
end

-- 检测 两个 队员是否 是在 同一个 仙盟
function PartData.CheckIsSameGuild(pid1, pid2)


    local p1 = PartData.FindMyTeammateData(pid1);
    local p2 = PartData.FindMyTeammateData(pid2);

    if (p1 ~= nil and p1.tId ~= nil and p1.tId ~= "") and(p2 ~= nil and p2.tId ~= nil and p2.tId ~= "") then

        if p1.tId == p2.tId then
            return true;
        end
    end
    return false;
end


function PartData.SetTeamPlLv(pid, lv)

    if PartData.myTeam ~= nil then
        local m = PartData.myTeam.m;
        for key, value in pairs(m) do
            if (value.pid + 0) == pid then
                value.l = lv;
            end
        end
    end

end

function PartData.IsMyTeammate(pid)

    -- pid = tonumber(pid);
    local d = PartData.FindMyTeammateData(pid);
    if d == nil then
        return false;
    end
    return true;
end