--剧情数据管理
DramaProxy = class("DramaProxy");

function DramaProxy._GetDramaConfig()
    return ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PLOT_EVENTS)
end
--返回副本结束时的剧情配置,iid副本id,返回剧情id
function DramaProxy.GetInstanceEndDramaConfig(iid)
    iid = tostring(iid)
    local config = DramaProxy._GetDramaConfig()
    for i,v in pairs(config) do
        local tp = v.triggerParam
        if tp[1] == DramaTriggerType.InstanceEnd and tp[2] == iid then return v.plotId end
    end
    return nil
end
--返回指定剧情配置
function DramaProxy.GetDramaConfig(did)
    local config = DramaProxy._GetDramaConfig()
    local dramas = {}
    for i,v in pairs(config) do
        if v.plotId == did then table.insert(dramas, v) end
    end
    return dramas
end


-- 返回场景坐标信息
function DramaProxy.GetScenePosByID(id,ind)
    local ScenePosCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SCENES_POS);
    return string.split(ScenePosCfg[id].coordinate1[ind], "|")
end
-- 发送同场景跳转信息
function DramaProxy.SendTransLate(idd, xx, zz)
    local data = {t = 1,id = (idd), x = tonumber(xx),y = 0,z = tonumber(zz),a=0 }
    SocketClientLua.Get_ins():SendMessage(CmdType.TransLateInScene,data)
end

