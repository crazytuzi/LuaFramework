local Util = require "Zeus.Logic.Util"
local ServerTime = require "Zeus.Logic.ServerTime"

local Limit = {}

local passTime = 0
local lastIdx = nil
local limitOriginList = nil
local limitNowList = nil

function Limit.getLastCD()
    if not lastIdx then return 0 end

    local t = os.date("*t", ServerTime.GetServerUnixTime())
    local time = t.hour * 3600 + t.min * 60 + t.sec
    local cd = limitNowList[lastIdx].openTime - time
    if cd < 0 then cd = 0 end
    return cd
end

function Limit.getLimitList()
    return limitNowList, limitOriginList
end

function Limit.sortNow()
    local t = os.date("*t", ServerTime.GetServerUnixTime())
    local time = t.hour * 3600 + t.min * 60 + t.sec
    table.sort(limitNowList, function(a, b)
        local closeA = time > a.closeTime
        local closeB = time > b.closeTime
        if closeA ~= closeB then
            return closeB
        end
        if a.openTime ~= b.openTime then
            return a.openTime < b.openTime
        end
        return a.id < b.id
    end)

    lastIdx = nil
    passTime = 9
end

function onTime(dt)
    passTime = passTime + dt
    if passTime < 10 then return end
    passTime = 0

    local idx = nil
    local t = os.date("*t", ServerTime.GetServerUnixTime())
    local time = t.hour * 3600 + t.min * 60 + t.sec
    for i,v in ipairs(limitNowList) do
        if time < v.closeTime then
            idx = i
            break
        end
    end

    if lastIdx ~= idx then
        lastIdx = idx
        EventManager.Fire("Event.Limit.ChangeCD", {})
    end
end

local function getTime(timeStr)
    local arr = string.split(timeStr, '-')
    return tonumber(arr[1]) * 3600 + tonumber(arr[2]) * 60 + tonumber(arr[3]) 
end

function Limit.onLimitPush(ex, sjson)
    local data = sjson:ToData()
    print ("requestLimitList", PrintTable(data))
    limitOriginList = data.s2c_ltActivity or {}
    limitNowList = table.filterList(limitOriginList, function(i, v) return v.isOpen == 1 end)
    for i,v in ipairs(limitOriginList) do
        v.static = GlobalHooks.DB.Find("Limit", {ID = v.id})[1]
        print("v.static.BonusViewCode ", v.static.BonusViewCode)
        v.static.items = Util.rewards2items(v.static.BonusViewCode, ',')
        v.openTime = getTime(v.static.BeginTime)
        v.closeTime = getTime(v.static.EndTime)
    end
    RemoveUpdateEvent("LimitUpdate", true)
    Limit.sortNow()

    passTime = 25
    RemoveUpdateEvent("LimitUpdate", true)
    AddUpdateEvent("LimitUpdate", onTime)
end

function Limit.fin(relogin)
    if relogin then
        passTime = 0
        lastIdx = nil
        RemoveUpdateEvent("LimitUpdate", true)
    end
end

function Limit.InitNetWork()
    Pomelo.GameSocket.ltActivityInfoPush(Limit.onLimitPush)
end

return Limit
