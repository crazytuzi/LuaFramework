local AD = {}

local function getKey()
    local roleId = DataMgr.Instance.UserData.RoleID
    return "lastshowadtime_" .. roleId
end

local function createTimeList()
    local timelist = GlobalHooks.DB.GetGlobalConfig("Bombbox.Time")
    
    timelist = string.split(timelist, ',')
    for i,v in ipairs(timelist) do
        local arr = string.split(v, '-')
        timelist[i] = {openTime = tonumber(arr[1]), closeTime = tonumber(arr[2])}
    end
    return timelist
end

local function indexTime(timelist, time)
    
    for i,v in ipairs(timelist) do
        if v.openTime <= time and v.closeTime > time then
            return i
        end
    end
    return nil
end

local function checkShowAD()
    EventManager.Unsubscribe("Drama.Stop", checkShowAD)
    local timelist = createTimeList()
    local now = os.date("*t")
    local nowTimeIdx = indexTime(timelist, now.hour)
    
    if not nowTimeIdx then
        return
    end

    local PlayerPrefs = UnityEngine.PlayerPrefs
    local key = getKey()
    local oldTimeIdx = nil
    local old = os.date("*t", PlayerPrefs.GetInt(key, 0))
    if now.year == old.year and now.month == old.month and now.day == old.day then
        oldTimeIdx = indexTime(timelist, old.hour)
    end

    






end

local function checkMovie()
    local closed = DataMgr.Instance.UserData:GetClientConfig("guide_closed")
    local first_drama = DataMgr.Instance.UserData:GetClientConfig("drama_hello,world")
    
    
    if string.empty(closed) and string.empty(first_drama) and GlobalHooks.Drama and GlobalHooks.Drama.Start then
        EventManager.Subscribe("Drama.Stop.guide_move", checkShowAD)
    else
        checkShowAD()
    end
end

function AD.initial()
    EventManager.Subscribe("Event.Scene.FirstInitFinish", checkMovie)
end

return AD
