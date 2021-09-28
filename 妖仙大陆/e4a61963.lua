local CrossServer = {}
local ServerTime = require "Zeus.Logic.ServerTime"

local timeList = nil
local passTime = 0

function CrossServer.getTimeList()
    return timeList
end

function CrossServer.onTime(dt)
    passTime = passTime + dt
    if passTime < 10 then return end
    passTime = 0

    local isOpen = GlobalHooks.CheckFuncOpenByTag(GlobalHooks.UITAG.GameUICrossServer)
    if isOpen then
        local t = os.date("*t", ServerTime.GetServerUnixTime())
        local time = t.hour * 3600 + t.min * 60 + t.sec
        isOpen = false
        for _,v in ipairs(timeList) do
            if time > v.openTime and time < v.closeTime then
                isOpen = true
                break
            end
        end
    end
    
    local flagOpen = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_CROSS_SERVER) > 0
    if isOpen ~= flagOpen then
        DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_CROSS_SERVER, isOpen and 1 or 0, true)
    end
end

function CrossServer.onCrossServerTimePush(ex, sjson)
    local data = sjson:ToData()
    
    timeList = data.s2c_openList
    passTime = 25
    RemoveUpdateEvent("CrossServerUpdate", true)
    AddUpdateEvent("CrossServerUpdate", CrossServer.onTime)
end

function CrossServer.fin(relogin)
    if relogin then
        passTime = 0
        RemoveUpdateEvent("CrossServerUpdate", true)
    end
end

function CrossServer.InitNetWork()
    Pomelo.CrossServerHandler.treasureOpenPush(CrossServer.onCrossServerTimePush)
end

return CrossServer
