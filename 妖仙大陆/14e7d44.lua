local ServerTime = require "Zeus.Logic.ServerTime"
local FubenRollUI = require "Zeus.UI.XmasterFuben.FubenRollUI"
local Util = require "Zeus.Logic.Util"
local CACHE_TIME = 15
local MIJING_TAG = 4

local Model = {}


local fubenList = {}
local limitFubenList = {}

local cacheFunctions = {}
local friendListRequestCache = nil

local resFubenList = {}

local ResFubenTime = 0
local ResFubenWave = 0

function Model.getAllFubenList()
    return fubenList
end

function Model.getAllResFubenList()
    return resFubenList
end

function Model.getAllLimitFubenList()
    return limitFubenList
end

function Model.getResFubenInfoById(id)
    for i,v in ipairs(resFubenList) do
        if v.MapID == id then
            return v
        end
    end
    return nil
end

function Model.reqResFubenInfo(cb)
    Pomelo.ResourceDungeonHandler.queryResourceDugeonInfoRequest(function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data.dungeons)
    end)
end

function Model.reqEnterResFubenTime(id)
    Pomelo.ResourceDungeonHandler.enterResourceDugeonInfoRequest(id,function(ex, sjson)
    end)
end

function Model.reqBuyResFubenTime(id,cb)
    Pomelo.ResourceDungeonHandler.buyTimesRequest(id,function(ex, sjson)
        if ex then return end
        cb()
    end)
end

function Model.reqDoubleRewardResFuben(id,cb)
    Pomelo.ResourceDungeonHandler.receiveDoubleRewardRequest(id,function(ex, sjson)
        if ex then return end
        cb()
    end)
end

function Model.getStaticFubenVo(fubenId)
    return GlobalHooks.DB.Find("DungeonMap", fubenId)
end

function Model.getFubenModesByName(fubenName)
    local list = GlobalHooks.DB.Find("DungeonMap", {Name=fubenName,DungeonShow=1})
    local modes = {}
    for _,v in ipairs(list) do
        table.insert(modes, v)
    end
    return modes
end


function Model.requestFubenInfo(MapID,type, cb)
    
    Pomelo.FightLevelHandler.fubenListRequest(MapID, type,function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data.s2c_list)
    end)
end


function Model.getHighestHardByLv(mapTag, lv, upLv)
    for hard = 3, 1, -1 do
        local fubens = GlobalHooks.DB.Find("DungeonMap", {DungeonTab=mapTag, HardModel=hard,DungeonShow=1})
        for i,v in ipairs(fubens) do
            if v.ReqUpLevel > 0 then
                if upLv >= v.ReqUpLevel then return hard end
            elseif lv >= v.ReqLevel then
                return hard
            end
        end
    end
    return 1
end

function Model.getStaticFubenVoByHard(fubenName, hard)
    local t = GlobalHooks.DB.Find("DungeonMap", {Name=fubenName, HardModel=hard,DungeonShow=1})
    return t[1]
end

function Model.getStaticFubenVosByHard(mapTag, hard)
    return GlobalHooks.DB.Find("DungeonMap", {DungeonTab=mapTag, HardModel=hard,DungeonShow=1})
end

function Model.clearCache()
    fubenList = {}
    limitFubenList = {}
    cacheFunctions = {}
    friendListRequestCache = nil
end

function Model.setRemainTimesBuyTimes(fubenId, remainTimes, buyTimes)
    local mapTypeID = Model.getStaticFubenVo(fubenId).MapTypeID
    for tag, hardList in pairs(fubenList) do
        for hard, maps in pairs(hardList) do
            for _,v in ipairs(maps) do
                if (tag ~= MIJING_TAG or fubenId == v.static.MapID) and 
                        v.static.MapTypeID == mapTypeID then
                    v.remainTimes = remainTimes
                    v.buyTimes = v.buyTimes
                end
            end
        end
    end
end


function Model.requestFubenList(mapTag, hard, cb, failCb)
    local cacheKey = string.format("fubenList_%d_%d", mapTag, hard)
    if cacheFunctions[cacheKey] and cacheFunctions[cacheKey] > os.clock() then
        cb(fubenList[mapTag][hard])
        return
    end

    Pomelo.FightLevelHandler.fubenListRequest(mapTag, hard, function(ex, sjson)
        if ex then
            failCb()
            return
        end

        local data = sjson:ToData()
        
        cacheFunctions[cacheKey] = os.clock() + CACHE_TIME
        
        if not fubenList[mapTag] then
            fubenList[mapTag] = {}
        end

        
        if data.s2c_list and #data.s2c_list > 0 then
            for _,v in ipairs(data.s2c_list) do
                local remainTimes = v.remainTimes
                local buyTimes = v.buyTimes
                v.static = Model.getStaticFubenVo(v.fubenId)
                Model.setRemainTimesBuyTimes(v.fubenId, remainTimes, buyTimes)
            end
        end

        fubenList[mapTag][hard] = data.s2c_list

        
        cb(data.s2c_list)
    end, XmdsNetManage.PackExtData.New(true, true, failCb))
end


function Model.requestSweepFuben(fubenId, cb)
    Pomelo.FightLevelHandler.enterDungeonFastRequest(fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()

        cb(data.s2c_remainTimes, data.s2c_awardItems)
    end)
end


function Model.requestInviteAllTeam(fubenId, msg, cb)
    Pomelo.FightLevelHandler.joinDungeonBroadcastRequest(fubenId, msg, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb()
    end)
end



function Model.requestJoinFubenTeam(teamId, playerId)
    Pomelo.FightLevelHandler.joinDungeonRequest(playerId, teamId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
    end)
end


function Model.requestOnlineFriendList(cb)
    local data = friendListRequestCache
    if data then
        cb(data.s2c_data, data.s2c_wait_time, data.s2c_friends_num)
        return
    end
    Pomelo.FightLevelHandler.inviteFriendListRequest(function(ex, sjson)
        if ex then return end
        data = sjson:ToData()
        friendListRequestCache = data
        cb(data.s2c_data, data.s2c_wait_time, data.s2c_friends_num)
    end)
end


function Model.requestInviteFriendTeam(friendId, fubenId, cb)
    Pomelo.FightLevelHandler.inviteFriendRequest(friendId, fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb()
    end)
end


function Model.requestEnterFuben(fubenId)
    Pomelo.FightLevelHandler.enterDungeonRequest(fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
    end)
end


function Model.requestReplyEnterFuben(isReady, fubenId)
    Pomelo.FightLevelHandler.replyEnterDungeonRequest((isReady and 1) or 2, fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
    end)
end


function Model.AddProfitRequest(fubenId, cb)
    Pomelo.FightLevelHandler.addProfitRequest(fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb()
    end)
end

function Model.requestBuyEnterTimes(fubenId, cb)
    Pomelo.FightLevelHandler.buyEnterTimesRequest(fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data.s2c_leftTime)
    end)
end

function Model.requestLeaveFuben()
    Pomelo.FightLevelHandler.leaveDungeonRequest(function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
    end)
end


function Model.requestFubenAutoMatch(fubenId, cb)
Pomelo.FightLevelHandler.enterWaitDungeonRequest(fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb(data.s2c_averageTime, data.s2c_lockLeftTime)
    end)
end

function Model.requestCancelFubenAutoMath(fubenId)
    Pomelo.FightLevelHandler.quitWaitDungeonRequest(fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
    end)
end


function Model.requestReplyEnterFubenAutoMatch(fubenId)
    Pomelo.FightLevelHandler.replyEnterWaitDungeonRequest(fubenId, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
    end)
end


function Model.onConfirmEnterFubenPush(ex, sjson)
    if GameSceneMgr.Instance.BattleRun.InitSceneOk then
        local data = sjson:ToData()
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIFubenWaitEnter)
        local _, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFubenWaitEnter, 0)
        ui:setInfo(data.s2c_fubenId, data.s2c_over_time, data.s2c_leaderId, data.s2c_memberData)
    end
end


function Model.onMemberEnterFubenStateChangePush(ex, sjson)
    local data = sjson:ToData()
    data = {playerId = data.s2c_playerId, isReady = data.s2c_isReady == 1}
    EventManager.Fire("Event.Fuben.MemeberEnterStateChange", data)
end

function Model.onInviteFriendReplyPush(ex, sjson)
    local data = sjson:ToData()
    local isReject = data.s2c_state == 3
    if isReject and friendListRequestCache then
        
        
        local list = friendListRequestCache.s2c_data
        local _, v = table.indexOfKey(list, "id", data.s2c_invite_id)
        if v then
            v.state = 3
            v.invalidTime = data.s2c_CD_time + ServerTime.GetServerUnixTime()
            EventManager.Fire("Event.Fuben.FriendReject", {playerId = v.id})
        end
    end
end

function Model.onAutoMatchSuccessPush(ex, sjson)
    local data = sjson:ToData()
    EventManager.Fire("Event.Fuben.AutoMatchSuccess", {
        fubenId = data.s2c_fubenId,
        cd = data.s2c_over_time,
        players = data.s2c_players,
    })
end

function Model.onAutoMatchMemberReadyPush(ex, sjson)
    local data = sjson:ToData()
    EventManager.Fire("Event.Fuben.AutoMatchMemberReady", {
        fubenId = data.s2c_fubenId,
        playerId = data.s2c_playerId,
    })
end

function Model.onFubenClosePush(ex, sjson)
    local data = sjson:ToData()
    EventManager.Fire("Event.Fuben.WillClose", {
        cd = data.s2c_over_time,
        format = data.s2c_msg,
    })
end

function Model.onCloseHandUpPush(ex, sjson)
    local data = sjson:ToData()
    EventManager.Fire("Event.Fuben.HandUpClose", {msg = data.msg})
end

function Model.throwPointItemListPush(ex, sjson)
    local data = sjson:ToData()
    
    
    for i=1,#data.items do
        local params = {
            rollType = "rolling",
            time = data.time,
            id = data.items[i].id,
            itemcode = data.items[i].itemCode,
            num = data.items[i].num or 1,
        }
        FubenRollUI.Show(params)
    end
end

function Model.throwPointResultPush(ex, sjson)
    local data = sjson:ToData()
    
    
    local params = {
        rollType = "rollResult",
        id = data.id,
        point = data.point,
        name = data.name,
        itemcode = data.itemCode,
        num = data.itemCode.num or 1,
    }
    FubenRollUI.Show(params)
end

function Model.resFubenOverPush(ex, sjson)
    local menu = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIDeadCommon)
    if menu ~= nil then
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIDeadCommon)
    end
    
    local data = sjson:ToData()
    
    
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIResFubenOverUI, 0)
    if data ~= nil and lua_obj ~= nil then
        lua_obj.SetResFubenOverInfo(data)
    end
end

function Model.illusionExpPush(ex, sjson)
    EventManager.Fire("Event.fightLevelHandler.illusionPush", sjson:ToData())
end

function Model.illusion2Push(ex, sjson)
    EventManager.Fire("Event.fightLevelHandler.illusion2Push", sjson:ToData())
end

function Model.LimitTimeGiftPush(ex, sjson)
    EventManager.Fire("Event.ActivityFavorHandler.LimitTimeGiftInfoPush", sjson:ToData())
end


function Model.resourceCountDownRequest(cb)
    Pomelo.ResourceDungeonHandler.resourceCountDownRequest(0,function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        local time = math.floor(data.countDown/1000)
        cb(time)
    end)
end


function Model.reqRemainTipsRequest()
    Pomelo.FightLevelHandler.getBenifitableRequest(function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        if data and not data.benifitable then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.FUBEN, "dungeonnoidea"))
        end
    end)
end


function Model.resourceSweepRequest(id,cb)
    Pomelo.ResourceDungeonHandler.resourceSweepRequest(id,function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data.awardItems or {})
    end)
end

function Model.initAllFubenList()

    fubenList = GlobalHooks.DB.Find("DungeonMap", {HardModel=1, DungeonShow=1, AllowedPlayersMix=1,Type=2})
    table.sort(fubenList, function (aa,bb) 
        if  aa.ReqLevel < bb.ReqLevel then
            return true
        end
        return false
    end)

    resFubenList = GlobalHooks.DB.Find("DungeonMap", {Type=12})

    limitFubenList = GlobalHooks.DB.Find("DungeonMap", {HardModel=1, DungeonShow=1, AllowedPlayersMix=1,Type=16})
    
    table.sort(limitFubenList, function (aa,bb) 
        if  aa.ReqLevel < bb.ReqLevel then
            return true
        end
        return false
    end)

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end

function Model.GetFubenInfoById(id)
    for i,v in ipairs(fubenList) do
        if v.MapID == id then
            return v
        end
    end
    return nil
end

function Model.GetLimitFubenInfoById(id)
    for i,v in ipairs(limitFubenList) do
        if v.MapID == id then
            return v
        end
    end
    return nil
end

function Model.OpenFubenEnterUI(eventname,params)
    
    if params.id == "53001" then
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMiJing)
        return
    end  
    local id = tonumber(params.id) + 1000
    local info = Model.GetFubenInfoById(id) or Model.GetLimitFubenInfoById(id)
    local ui = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIFubenSecond, 0)
    if info and ui == nil then
        local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFubenSecond, 0)
        lua_obj.SetFubenInfo(info)
    end
end

function Model.GetResFubenTime()
    return ResFubenTime
end
function Model.SetResFubenTime(time)
    ResFubenTime = time
end
function Model.GetResFubenWave()
    return ResFubenWave
end
function Model.SetResFubenWave(wave)
    ResFubenWave = wave
end

function Model.initial()
    ResFubenTime = 0
    ResFubenWave = 0
end

function Model.InitNetWork()
    Model.initAllFubenList()

    EventManager.Subscribe("Event.OpenFubenEnterUI", Model.OpenFubenEnterUI)

    Pomelo.FightLevelHandler.onConfirmEnterFubenPush(Model.onConfirmEnterFubenPush)
    Pomelo.FightLevelHandler.onMemberEnterFubenStateChangePush(Model.onMemberEnterFubenStateChangePush)
    
    
    
    Pomelo.FightLevelHandler.onFubenClosePush(Model.onFubenClosePush)
    Pomelo.FightLevelHandler.closeHandUpPush(Model.onCloseHandUpPush)
    Pomelo.BattleHandler.throwPointItemListPush(Model.throwPointItemListPush)
    Pomelo.BattleHandler.throwPointResultPush(Model.throwPointResultPush)

    Pomelo.BattleHandler.resourceDungeonResultPush(Model.resFubenOverPush)

    Pomelo.FightLevelHandler.illusionPush(Model.illusionExpPush)

    Pomelo.FightLevelHandler.illusion2Push(Model.illusion2Push)

    Pomelo.ActivityFavorHandler.limitTimeGiftInfoPush(Model.LimitTimeGiftPush)

end


return Model
