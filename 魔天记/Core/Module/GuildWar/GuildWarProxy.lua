require "Core.Module.Pattern.Proxy"
require "net/CmdType"
require "net/SocketClientLua"
local insert = table.insert

GuildWarProxy = Proxy:New();
function GuildWarProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarEnroll, GuildWarProxy.RspEnrollWar);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarRankList, GuildWarProxy.RspRankList);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarEnrollInfo, GuildWarProxy.RspEnrollInfo);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarPreEnter, GuildWarProxy.RspPreEnter);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarInfo, GuildWarProxy.RspInfo);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarReport, GuildWarProxy.RspNotifyReport);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarAllReport, GuildWarProxy.RspNotifyAllReport);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarCenterChg, GuildWarProxy.RspNotifyCenterChg);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarPointChg, GuildWarProxy.RspNotifyPointChg);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarCollect, GuildWarProxy.RspCollect);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarDetail, GuildWarProxy.RspDetail);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarResult, GuildWarProxy.RspOnBattleEnd);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarLeave, GuildWarProxy.RspLeave);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GuildWarStartNotify, GuildWarProxy.RspNotifyWarStart);

end

function GuildWarProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarEnroll, GuildWarProxy.RspEnrollWar);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarRankList, GuildWarProxy.RspRankList);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarEnrollInfo, GuildWarProxy.RspEnrollInfo);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarPreEnter, GuildWarProxy.RspPreEnter);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarInfo, GuildWarProxy.RspInfo);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarReport, GuildWarProxy.RspNotifyReport);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarAllReport, GuildWarProxy.RspNotifyAllReport);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarCenterChg, GuildWarProxy.RspNotifyCenterChg);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarPointChg, GuildWarProxy.RspNotifyPointChg);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarCollect, GuildWarProxy.RspCollect);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarDetail, GuildWarProxy.RspDetail);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarResult, GuildWarProxy.RspOnBattleEnd);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarLeave, GuildWarProxy.RspLeave);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GuildWarStartNotify, GuildWarProxy.RspNotifyWarStart);

end

function GuildWarProxy.ReqEnrollWar()
    SocketClientLua.Get_ins():SendMessage(CmdType.GuildWarEnroll);
end

-- 1D01 报名
function GuildWarProxy.RspEnrollWar(cmd, data)
    if data and data.errCode == nil then
        MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.RSP_ENROLL_INFO, { f = 1 });
    end
end

-- 1D02 获取排名信息
function GuildWarProxy.ReqRankList()
    SocketClientLua.Get_ins():SendMessage(CmdType.GuildWarRankList);
end


function GuildWarProxy.RspRankList(cmd, data)
    if data and data.errCode == nil then
        MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.RSP_RANK_INFO, data);
    end
end

-- 1D03 获取报名信息
function GuildWarProxy.ReqEnrollInfo()
    SocketClientLua.Get_ins():SendMessage(CmdType.GuildWarEnrollInfo);
end

function GuildWarProxy.RspEnrollInfo(cmd, data)
    if data and data.errCode == nil then
        MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.RSP_ENROLL_INFO, data);
    end
end

-- 1D04 请求进入活动
function GuildWarProxy.ReqPreEnter()
    SocketClientLua.Get_ins():SendMessage(CmdType.GuildWarPreEnter);
end

function GuildWarProxy.RspPreEnter(cmd, data)
    if data and data.errCode == nil then

        local hero = PlayerManager.hero;
        hero.info.camp = data.camp;
        GuildDataManager.war.camp = data.camp;
        ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDPANEL)
        ModuleManager.SendNotification(GuildWarNotes.CLOSE_PANEL)
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY)
        GameSceneManager.GotoScene(GuildDataManager.warMapId);
    end
end

-- 1D05 获取战场信息
function GuildWarProxy.ReqInfo()
    SocketClientLua.Get_ins():SendMessage(CmdType.GuildWarInfo);
end

function GuildWarProxy.RspInfo(cmd, data)
    if data and data.errCode == nil then
        GuildDataManager.war.startTime = data.st;
        GuildDataManager.war.endTime = data.et;
        GuildDataManager.war.wp1 = data.wp1;
        GuildDataManager.war.wp2 = data.wp2;
        GuildDataManager.war.m = data.m;
        GuildDataManager.war.num = data.c;
        GuildDataManager.war.mp = data.mypt;
        GuildDataManager.war.mr = data.myid;
        GuildDataManager.war.etgn = data.etgn;

        GuildDataManager.war.camp = PlayerManager.hero.info.camp;

        local map = GameSceneManager.map;
        if (map and data.l) then
            for i, v in ipairs(data.l) do
                map:SetBattlefieldPointBuff(v.id, v.f);
                -- map:SetBattlefieldPointBuff(v.id, 1);
            end
        end

        MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.RSP_INFO);
    end
end

-- 1D06 个人数据更新
function GuildWarProxy.RspNotifyReport(cmd, data)
    GuildDataManager.war.mp = data.mypt;
    MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.ENV_REFRESH_WARINFO);
end

-- 1D07 双方气运更新
function GuildWarProxy.RspNotifyAllReport(cmd, data)
    GuildDataManager.war.wp1 = data.wp1;
    GuildDataManager.war.wp2 = data.wp2;
    GuildDataManager.war.mr = data.myid;
    GuildDataManager.war.num = data.c;
    MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.ENV_REFRESH_WARINFO);
end

-- 1D08 中央归属更新
function GuildWarProxy.RspNotifyCenterChg(cmd, data)
    GuildDataManager.war.m = data.m;
    MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.ENV_WARINFO_CENTER_CHG);
end

-- 1D09 气运点更新
function GuildWarProxy.RspNotifyPointChg(cmd, data)
    local map = GameSceneManager.map;
    if (map) then
        map:SetBattlefieldPointBuff(data.id, data.f);
    end
end

-- 1D0A 采集气运点
function GuildWarProxy.ReqCollect(id, st)
    SocketClientLua.Get_ins():SendMessage(CmdType.GuildWarCollect, { id = id, t = st });
end

function GuildWarProxy.RspCollect(cmd, data)
    if data and data.errCode == nil then
        if data.t == 0 then
            MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.ENV_START_COLLECT, data);
        end
    end
end

-- 1D0B 详细战报
function GuildWarProxy.ReqDetail()
    SocketClientLua.Get_ins():SendMessage(CmdType.GuildWarDetail);
end

function GuildWarProxy.RspDetail(cmd, data)
    if data and data.errCode == nil then
        MessageManager.Dispatch(GuildWarNotes, GuildWarNotes.RSP_DETAIL_INFO, data);
    end
end

-- 1D0C 战斗结束
function GuildWarProxy.RspOnBattleEnd(cmd, data)
    ModuleManager.SendNotification(GuildWarNotes.OPEN_RESULT_PANEL, data);
end

-- 1D0D 俩开战场
function GuildWarProxy.ReqLeave()
    -- SocketClientLua.Get_ins():SendMessage(CmdType.GuildWarLeave);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLastSceneId, GuildWarProxy.RspLeave);
    SocketClientLua.Get_ins():SendMessage(CmdType.GetLastSceneId);
end

function GuildWarProxy.RspLeave(cmd, data)
    ModuleManager.SendNotification(GuildWarNotes.CLOSE_RESULT_PANEL);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLastSceneId, GuildWarProxy.RspLeave);
    local info = data.scene;
    local sid = tonumber(info.sid);
    local toScene = { };
    toScene.sid = sid;
    toScene.position = Convert.PointFromServer(info.x, info.y, info.z);
    -- GameSceneManager.to = toScene;
    GameSceneManager.GotoScene(sid, nil, to);
end

-- 1D0E 活动开始通知
function GuildWarProxy.RspNotifyWarStart(cmd, data)
    if data and data.errCode == nil and SystemManager.IsOpen(SystemConst.Id.XIANMENG) then
        local map = GameSceneManager.map
        if (map == nil or(map ~= nil and map.info.type ~= InstanceDataManager.MapType.Novice)) then
            ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYNOTIFY, { t = 99 })
        end
    end
end


function GuildWarProxy.ReqExitWar()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLastSceneId, GuildWarProxy._OnGetLastSceneId);
    SocketClientLua.Get_ins():SendMessage(CmdType.GetLastSceneId);
end

function GuildWarProxy._OnGetLastSceneId(cmd, data)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLastSceneId, GuildWarProxy._OnGetLastSceneId);
    ModuleManager.SendNotification(GuildWarNotes.CLOSE_ALL_PANEL);
    local info = data.scene;
    local sid = tonumber(info.sid);
    local toScene = { };
    toScene.sid = sid;
    toScene.position = Convert.PointFromServer(info.x, info.y, info.z);
    -- GameSceneManager.to = toScene;
    GameSceneManager.GotoScene(sid, nil, toScene);
end

