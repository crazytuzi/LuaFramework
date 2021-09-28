local Util = require "Zeus.Logic.Util"
local cjson = require "cjson"
local Player = require"Zeus.Model.Player"

local mt = getmetatable(GameSetting)
setmetatable(GameSetting, {})
GameSetting.MAIL    = "gs_mail"         
GameSetting.TEAM    = "gs_team"         
GameSetting.STRANGER= "gs_stranger"     
GameSetting.FRIEND  = "gs_friend"       
GameSetting.NOTIFICATION_BOSS = "gs_boss"
GameSetting.NOTIFICATION_UNION= "gs_notification_union"
GameSetting.ALL_MUTE= "gs_all_mute"
GameSetting.GUILD= "gs_guild"
GameSetting.NAME= "gs_name"
setmetatable(GameSetting, mt)


local diskKeys = {
    GameSetting.MUSIC,
    GameSetting.SOUND,
    GameSetting.ALL_MUTE,
    GameSetting.FX,
    GameSetting.SKILL_FX,
    
    
    
    
    GameSetting.TITLE_SELF,
    GameSetting.TITLE_OTHERS,
    GameSetting.BLOOD,
    GameSetting.VISUAL_RANGE,
    GameSetting.ROLE_NUM,
    GameSetting.NAME,
    GameSetting.GUILD,
    GameSetting.QUALITY,
}

local remoteKeyMap = {
    [GameSetting.MAIL] = "recvMailSet",
    [GameSetting.TEAM] = "teamInviteSet",
    [GameSetting.STRANGER] = "recvStrangerMsgSet",
    [GameSetting.FRIEND] = "recvAddFriendSet",
}

local allKeys = {
    GameSetting.MUSIC,
    GameSetting.SOUND,
    GameSetting.ALL_MUTE,
    GameSetting.FX,
    GameSetting.SKILL_FX,
    
    
    
    

    GameSetting.MAIL,
    GameSetting.TEAM,
    GameSetting.STRANGER,
    GameSetting.FRIEND,

    GameSetting.TITLE_SELF,
    GameSetting.TITLE_OTHERS,
    GameSetting.BLOOD,
    GameSetting.VISUAL_RANGE,
    GameSetting.ROLE_NUM,
    GameSetting.NAME,
    GameSetting.GUILD,
}


local uiConfigs = nil
local flatUIConfigs = nil

local GS = {}

function GS.getSetingKey(funcId)
    return GlobalHooks.DB.Find("SystemConfig", {ConfigID=funcId})[1].Key
end

function GS.getUIConfig()
    if not uiConfigs then
        local datas = GlobalHooks.DB.GetFullTable("SystemConfig")
        uiConfigs = {}
        flatUIConfigs = {}
        for _,v in ipairs(datas) do
            if not uiConfigs[v.TabID] then
                uiConfigs[v.TabID] = { id = v.TabID, name = v.TabName, groups = {}, items = {}}
            end
            local page = uiConfigs[v.TabID]
            local items = nil
            if v.TypeID > 0 then
                local _, group = table.indexOfKey(page.groups, "typeId", v.TypeID)
                if not group then
                    group = {id = v.TypeID, typeId = v.TypeID, name = v.TypeName, items = {}, style=v.Style}
                    table.insert(page.groups, group)
                    table.sort(page.groups, function(a, b) return a.typeId < b.typeId end)
                end
                items = group.items
            else
                items = page.items
            end
            local config = {
                name = v.Config,
                default = v.Default,
                funcId = v.ConfigID,
                mutexId = v.Relation > 0 and v.Relation or nil,
                value = v.Value,
                maxValue = v.Max,
                style = v.Style,
                key = v.Key,
            }
            table.insert(items, config)
            flatUIConfigs[config.funcId] = config
        end
    end
    return uiConfigs, flatUIConfigs
end

function GS.saveSetting(settingKey)
    if not remoteKeyMap[settingKey] then return end

    local data = {}
    for k,v in pairs(remoteKeyMap) do
        data[v] = GameSetting.GetValue(k)
    end

    Pomelo.SysSetHandler.changeSysSetRequest(data, function(ex, sjson)
        if ex then return end

    end, XmdsNetManage.PackExtData.New(false, false))
end

function GS.loadData()
    local PlayerPrefs = UnityEngine.PlayerPrefs

    for _,key in ipairs(diskKeys) do
        GameSetting.AddDiskKey(key)
    end
    for _,key in ipairs(allKeys) do
        local v = 1
        if not PlayerPrefs.HasKey(key) then
            local vo = GlobalHooks.DB.Find("SystemConfig", {Key = key})[1]
            v = vo and vo.Default or 1
        else
            v = PlayerPrefs.GetInt(key, 1)
        end
        GameSetting.SetValue(key, v)
    end
    
    local setData = Player.GetBindPlayerData().setData;
    
    if setData then
        for k,v in pairs(remoteKeyMap) do
            if setData[v] ~= nil then
               GameSetting.SetValue(k, setData[v])     
            end
        end
    end

    BattleInfoBarManager.HideMyTitle(GameSetting.GetValue(GameSetting.TITLE_SELF) ~= 1)
    BattleInfoBarManager.HideAllTitleButMy(GameSetting.GetValue(GameSetting.TITLE_OTHERS) ~= 1)
    BattleInfoBarManager.ChangeShowHpCtrl(GameSetting.GetValue(GameSetting.BLOOD) == 1)
    DataMgr.Instance.UserData.ShowUnitNum = GameSetting.GetValue(GameSetting.ROLE_NUM)
end


function GS.initial()
    EventManager.Subscribe("Event.Scene.FirstInitFinish", GS.loadData)
end

function GS.fin(relogin)
    
    
    
    
end

function GS.InitNetWork()
    
    
    
    
end

return GS
