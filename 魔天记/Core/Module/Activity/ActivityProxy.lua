require "Core.Module.Pattern.Proxy"
require "Core.Manager.Item.ActivityDataManager"


ActivityProxy = Proxy:New();
function ActivityProxy:OnRegister()

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ActivityDataChange, ActivityProxy.ActivityDataChange_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ActivityNotify, ActivityProxy.ActivityNotify);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetActivityData, ActivityProxy.GetActivityData_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetActivityAv, ActivityProxy.GetActivityAv_Result);

end

function ActivityProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ActivityDataChange, ActivityProxy.ActivityDataChange_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ActivityNotify, ActivityProxy.ActivityNotify);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetActivityData, ActivityProxy.GetActivityData_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetActivityAv, ActivityProxy.GetActivityAv_Result);


end

--[[
t：1 螟族入侵，2，古魔来袭，3 魔主之影，4 vip古魔，5 仙盟聚会，6 仙盟boss，7 心机大冒险
]]
function ActivityProxy.ActivityNotify(cmd, data)
    local map = GameSceneManager.map;
    local hero = PlayerManager.hero;
    if (hero) then
        if (map == nil or(map ~= nil and(map.info.type == InstanceDataManager.MapType.Field or map.info.type == InstanceDataManager.MapType.Main or map.info.type == InstanceDataManager.MapType.Guild))) then
            if (data.t == 1) then
                if (GuildDataManager.InGuild() and(map == nil or(map ~= nil and map.info.type ~= InstanceDataManager.MapType.Guild))) then
                    ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYNOTIFY, data)
                end
            elseif (data.t == 2 or data.t == 4) then
                if (SystemManager.IsOpen(SystemConst.Id.WildBoss) and WildBossManager.IsBossFocus(data.para)) then
                    ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYNOTIFY, data)
                end
            elseif (data.t == 3) then
                local ad = ActivityDataManager.GetCfByInterface_id(ActivityDataManager.interface_id_10);
                if (ad and hero.info.level >= ad.min_lev) then
                    ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYNOTIFY, data)
                end

            elseif (data.t == 5) then
                -- 仙盟聚会
                ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYNOTIFY, data)

            elseif (data.t == 6) then
                -- 仙盟boss
               --  if SystemManager.IsOpen(SystemConst.Id.XJDMX) then
                    ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYNOTIFY, data)
               -- end
            elseif (data.t == 7) then
                -- 心机大冒险
                
                if SystemManager.IsOpen(SystemConst.Id.XJDMX) then
                    ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYNOTIFY, data)
                end
            elseif (data.t == 8) then
                --上古妖兽
                if SystemManager.IsOpen(SystemConst.Id.YaoShou) then
                    ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYNOTIFY, data)
                end
            end
        end
    end
end


function ActivityProxy.TryGetActivityData()

    SocketClientLua.Get_ins():SendMessage(CmdType.GetActivityData, { });
end

function ActivityProxy.GetActivityData_Result(cmd, data)

    if data.errCode == nil then
        ActivityDataManager.SetServerData(data)
    end

end

function ActivityProxy.ActivityDataChange_Result(cmd, data)

    if data.errCode == nil then
        ActivityProxy.TryGetActivityData();
    end
end


function ActivityProxy.TryGetActivityAv(av)
    ActivityProxy.set_av = av;

    SocketClientLua.Get_ins():SendMessage(CmdType.GetActivityAv, { av = av });
end

function ActivityProxy.GetActivityAv_Result(cmd, data)

    if data.errCode == nil then

        ActivityDataManager.GethasSetrr(ActivityProxy.set_av)

    end

end 