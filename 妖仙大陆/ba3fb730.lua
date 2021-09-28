local ServerTime = require "Zeus.Logic.ServerTime"
local CACHE_TIME = 15

local Model = {}

local inited = false
local hasReward = false
local cacheMap = {}


local remainTimes = 0
local timeList = {}
local passTime = 0

local ignoreTimeIdx = 0

local vsPlayInfo = nil
function Model.getTimeList()
    return timeList
end

function Model.hasReward()
    return hasReward
end

function Model.clearCache()
    cacheMap = {}
end





function Model.getVsPlayInfo()
    return vsPlayInfo
end

function Model.requestNewsInfo(cb)
    Pomelo.SoloHandler.newsInfoRequest(function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        data.s2c_soloMessages = data.s2c_soloMessages or {}
        cb(data.s2c_soloMessages)
    end)
end

function Model.requestSoloInfo(cb)
    local data = cacheMap["soloInfo"]
    if data then
        cb(data.s2c_myInfo, data.s2c_soloMessages)
        return
    end
    Pomelo.SoloHandler.soloInfoRequest(function (ex, sjson)
        if ex then return end
        data = sjson:ToData()
        cacheMap["soloInfo"] = data
        
        data.s2c_soloMessages = data.s2c_soloMessages or {}
        cb(data.s2c_myInfo, data.s2c_soloMessages)
    end)
end

function Model.requsetBattleRecord(cb)
    local data = cacheMap["recordList"]
    if data then
        cb(data)
        return
    end
    Pomelo.SoloHandler.battleRecordRequest(function (ex, sjson)
        if ex then return end
        data = sjson:ToData()
        cacheMap["recordList"] = data
        cb(data)
    end)
end

local function requestRank(cacheKey, handlerName, cb,failcb)
    local data = cacheMap[cacheKey]
    if data then
        cb(data.s2c_rankItems, data.s2c_myRankItem)
        return
    end
    Pomelo.SoloHandler[handlerName](function (ex, sjson)
        if ex then 
            failcb()
            return 
        end
        data = sjson:ToData()
        cacheMap[cacheKey] = data
        
        if cacheKey == "friendRank" then
            data.s2c_rankItems = data.s2c_rankItems or {}
            if data.s2c_myRankItem.rank == 0 then
                table.insert(data.s2c_rankItems, data.s2c_myRankItem)
                data.s2c_myRankItem.rank = #data.s2c_rankItems
            end
        end
        cb(data.s2c_rankItems, data.s2c_myRankItem)
    end)
end

function Model.requestFriendRank(cb)
    requestRank("friendRank", "friendRankRequest", cb)
end
function Model.requestServerRank(cb)
    requestRank("serverRank", "serverRankRequest", cb)
end
function Model.requestAreaRank(cb)
    requestRank("areaRank", "areaRankRequest", cb)
end

function Model.requestRewardInfo(cb)
    local data = cacheMap["rewardInfo"]
    if data then
        cb(data)
        return
    end
    Pomelo.SoloHandler.rewardInfoRequest(function (ex, sjson)
        if ex then return end
        data = sjson:ToData()
        cacheMap["rewardInfo"] = data
        print("requestRewardInfo", PrintTable(data))
        cb(data)
    end)
end

local function checkReward()
    
    cacheMap["soloInfo"] = nil

    local nowHasReward = false

    local rewardInfo = cacheMap["rewardInfo"]
    if not rewardInfo then return end
    
    if rewardInfo.s2c_rankRewards then
        for _,v in ipairs(rewardInfo.s2c_rankRewards) do
            if v.status == 1 then
                nowHasReward = true
                break
            end
        end
    end
    
    if not nowHasReward and rewardInfo.s2c_dailyRewardRankIds and #rewardInfo.s2c_dailyRewardRankIds > 0 then
        nowHasReward = true
    end
    
    if not nowHasReward and rewardInfo.s2c_dailyRewardRankIds and rewardInfo.s2c_weeklyReward.status == 1 then
        nowHasReward = true
    end

    if hasReward ~= nowHasReward then
        hasReward = nowHasReward
        EventManager.Fire("Event.Solo.RedPointChange", {})
    end
end

function Model.requestRankReward(rankId, cb)
    Pomelo.SoloHandler.drawRankRewardRequest(rankId, function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        local rewardInfo = cacheMap["rewardInfo"]
        if rewardInfo and rewardInfo.s2c_rankRewards then
            local _, rank = table.indexOfKey(rewardInfo.s2c_rankRewards, "rankId", rankId)
            rank.status = 2
        end
        cb()
        
    end)
end

function Model.requestDailyReward(index, cb)
    local data = cacheMap["dailyReward"]
    if data then
        cb(data)
        return
    end
    Pomelo.SoloHandler.drawDailyRewardRequest(index,function (ex, sjson)
        if ex then return end
        data = sjson:ToData()
        cacheMap["dailyReward"] = data
        cb(data)
    end)
end

function Model.requestWeeklyReward(cb)
    Pomelo.SoloHandler.drawWeeklyRewardRequest(function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        local rewardInfo = cacheMap["rewardInfo"]
        if rewardInfo and rewardInfo.s2c_weeklyReward then
            rewardInfo.s2c_weeklyReward.status = 2
        end
        cb()
        checkReward()
    end)
end


function Model.requestBuySoloTimes(cb)
    Pomelo.SoloHandler.buySoloTimesRequest(function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        local soloInfo = cacheMap["soloInfo"]
        if soloInfo and soloInfo.s2c_myInfo then
            soloInfo.s2c_myInfo.leftTimes = 1
            soloInfo.s2c_myInfo.boughtTimes = soloInfo.s2c_myInfo.boughtTimes + 1
        end
        cb()
    end)
end


function Model.requestRestSoloCD(cb)
    Pomelo.SoloHandler.resetCoolDownRequest(function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        local soloInfo = cacheMap["soloInfo"]
        if soloInfo and soloInfo.s2c_myInfo then
            soloInfo.s2c_myInfo.coolDownTime = 0
        end
        cb()
    end)
end

function Model.requestJoinSolo(cb,failcb)
    Pomelo.SoloHandler.joinSoloRequest(function (ex, sjson)
        if ex then 
            failcb()
            return 
        end
        local data = sjson:ToData()
        
        cb(data.s2c_avgMatchTime, data.s2c_startJoinTime)
    end)
end

function Model.requestQuitSolo(cb)
    
    Pomelo.SoloHandler.quitSoloRequest(function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb()
    end)
end

function Model.requestJoinSoloBattle(cb)
    Pomelo.SoloHandler.joinSoloBattleRequest(function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb()
    end)
end

function Model.requestHasReward()
    Pomelo.SoloHandler.queryRewardRequest(function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        local nowHasReward = data.s2c_hasReward == 1
        if hasReward ~= nowHasReward then
            hasReward = nowHasReward
            EventManager.Fire("Event.Solo.RedPointChange", {})
        end
    end, XmdsNetManage.PackExtData.New(false,false))
end

function Model.requestLeaveScene(cb)
    Pomelo.SoloHandler.leaveSoloAreaRequest(function(ex, sjson)
        if ex then return end
        cb()
    end)
end

function Model.requestBattleRecord(cb)
    Pomelo.SoloHandler.battleRecordRequest(function (ex, sjson)
        if ex then return end
        cb()
    end)
end

function Model.requestRivalInfo()
    Pomelo.SoloHandler.getRivalInfoRequest(function ( ex,sjson )
        if ex then return end
        local data = sjson:ToData()
        vsPlayInfo = data
    end)
end


function Model.onNewRewardPush(ex, sjson)
    if not hasReward then
        hasReward = true
        EventManager.Fire("Event.Solo.RedPointChange", {})
    end
end






















local callback = nil
function Model.onGameEndPush(ex, sjson)
    local data = sjson:ToData()
    
    
    local showType = 0
    if data.dailyBattleTimes~= nil then
        showType = tostring(data.dailyBattleTimes)
    end 

    local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISoloBattleOver, -1 ,showType)
    obj:setData(data.s2c_gameResult, data.s2c_gameOverTime)

    if GameSceneMgr.Instance.BattleRun and GameSceneMgr.Instance.BattleRun.InitSceneOk then
        menu.Visible = true
    else
        menu.Visible = false
        local function cb( )
            print("onGameEndPushonGameEndPushonGameEndPush")
            menu.Visible = true
            EventManager.Unsubscribe("Event.Scene.FirstInitFinish", callback)
            callback = nil
        end
        callback = cb
        EventManager.Subscribe("Event.Scene.FirstInitFinish", callback)
    end
end

function Model.ignoreTimeRedPoint()
    local t = os.date("*t", ServerTime.GetServerUnixTime())
    local time = t.hour * 3600 + t.min * 60 + t.sec
    for i,v in ipairs(timeList) do
        if time > v.openTime and time < v.closeTime then
            ignoreTimeIdx = i
            Model.onTime(10)
            break
        end
    end
end

function Model.onTime(dt)
    passTime = passTime + dt
    if passTime < 10 then return end
    passTime = 0


    local isRedPoint = remainTimes > 0 and GlobalHooks.CheckFuncOpenByTag(GlobalHooks.UITAG.GameUISolo)
    local hitIgnoreTime = false
    if isRedPoint then
        local t = os.date("*t")
        local time = t.hour * 3600 + t.min * 60 + t.sec
        isRedPoint = false
        for i,v in ipairs(timeList) do
            
            if time > v.openTime and time < v.closeTime then
                hitIgnoreTime = i == ignoreTimeIdx
                isRedPoint = not hitIgnoreTime
                
                break
            end
        end
    end

    
    if not hitIgnoreTime then
        ignoreTimeIdx = 0
    end

    local flagRedPoint = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_SOLO_TIME) > 0
    
    if isRedPoint ~= flagRedPoint then
        DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_SOLO_TIME, isRedPoint and 1 or 0, true)
    end
end

function Model.setRemainTimes(times)
    local oldHasTime = remainTimes > 0
    local nowHasTime = times > 0
    remainTimes = times
    if oldHasTime ~= nowHasTime then
        RemoveUpdateEvent("SoloModeUpdate", true)
        ignoreTimeIdx = 0
        if nowHasTime then
            AddUpdateEvent("SoloModeUpdate", Model.onTime)
        else
            DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_SOLO_TIME, 0, true)
        end
    end
end

function Model.onOpenTimePush(ex, sjson)
    local data = sjson:ToData()
    timeList = data.openList or {}
    
end

function Model.onSoloMatchedPush(ex,sjson)
    
    local data = sjson:ToData()
    vsPlayInfo = data
    local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISoloMatchOk, 0)
    obj:setVsPlayInfo(data)
    GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISolo, 0)

    EventManager.Fire("Event.Hud.hide1v1Wait",{})
end

function Model.onCancelMatchPush(ex,sjson)
    local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUISolo)
    if obj then
        obj:setWaitTime(nil,nil)
    end

    EventManager.Fire("Event.Hud.hide1v1Wait",{})
end

function Model.initial()
    
end

function Model.fin(relogin)
    if relogin then
        inited = false
        passTime = 0
        RemoveUpdateEvent("CrossServerUpdate", true)
    end
end

function Model.InitNetWork()
    Pomelo.SoloHandler.onNewRewardPush(Model.onNewRewardPush)
    
    
    Pomelo.SoloHandler.onGameEndPush(Model.onGameEndPush)
    Pomelo.SoloHandler.leftSoloTimePush(Model.onOpenTimePush)
    Pomelo.SoloHandler.onSoloMatchedPush(Model.onSoloMatchedPush)
    Pomelo.SoloHandler.cancelMatchPush(Model.onCancelMatchPush)
    if not inited then
        inited = true
        cacheMap = {}
        hasReward = false
        passTime = 0
        remainTimes = 0
        
    end
end


return Model
