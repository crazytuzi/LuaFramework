--[[
    区域战，用户移动

    检测：
        所属军团是否参加了区域战
        当前时间进行的区域战赛是否包含该军团
        TODO 检测当前组参赛的军团是否轮空，如果轮空其实是直接胜利，不让移动，这个让前端直接判断，不开板子，应该进不来
    
    如果当前区域战已经结束，不走其它逻辑，直接给前端一个战斗结束的状态码
]]
function api_areawar_move(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver = {},
        },
    }

    local uid = request.uid
    local aid = request.params.aid
    local target = request.params.target

    if uid == nil or aid == nil or target == nil then
        response.ret = -102
        return response
    end
    
    local ts = getClientTs()
    aid = tostring(aid)

    local mAreaWar = require "model.areawar"
    mAreaWar.construct()
    local bid = mAreaWar.getAreaWarId()

    -- 如果游戏结束，将结束标识返给前端
    local overFlag = mAreaWar.getOverBattleFlag(bid)
    if overFlag then    
        response.data.areaWarserver.over = {winner=overFlag}
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 军团已被消灭
    if mAreaWar.getAllianceDieFlag(bid,aid) then
        response.ret = -4202
        return response
    end

    local userActionInfo  = mAreaWar.getUserActionInfo(bid,uid,aid)
    if not userActionInfo then
        response.ret = -4202
        return response
    end

    -- 如果新目标与原目标一致，直接返回成功
    if userActionInfo.target == target then
        response.ret = 0
        response.msg = 'Success'
        return response
    end
    
    -- 正在行动中
    if userActionInfo.dist > ts then
        response.ret = -21101
        return response
    end

    local prevTarget = userActionInfo.target
    local sevbattleCfg = getConfig("areaWarCfg")
    local mapCfg = getConfig("localWarMapCfg")
    mapCfg = mapCfg.cityCfg[prevTarget]

    local canReach=false
    local distSec = 100

    for k,v in pairs(mapCfg.adjoin) do
        if(v==target)then
            canReach=true
            distSec = mapCfg.distance[k]
            break
        end
    end

    -- -21106 路线不通，无法行走
    if not canReach then
        response.ret = -21106
        return response
    end

    -- -- 不能直接通过不属于我方的据点
    local placesInfo =  mAreaWar.getPlacesInfo(bid)
    if tostring(placesInfo[prevTarget][1]) ~= aid and  tostring(placesInfo[target][1]) ~= aid then
        response.ret = -4201
        return response
    end

    if userActionInfo.dist < ts then
        local battlePlaces = mAreaWar.getPlacesUserList(bid)
        local placeBattlelist = mAreaWar.getPlaceBattleList(prevTarget,placesInfo[prevTarget][1],battlePlaces[prevTarget])
        
        if #placeBattlelist.attacker > 0 then
            -- 处于攻击方战斗队列
            local inQueue = mAreaWar.userInBattleQueue(uid,placeBattlelist.attacker)
            if inQueue then
                response.ret = -21102
                return response
            end
        end

        if #placeBattlelist.attacker > 0 and #placeBattlelist.defenser > 0 then
            -- 处于防守方攻击队列
            local inQueue = mAreaWar.userInBattleQueue(uid,placeBattlelist.defenser)
            if inQueue then
                response.ret = -21102
                return response
            end
        end

        if #placeBattlelist.attacker <= 0 and #placeBattlelist.defenser <= 1 then
            mAreaWar.resetPlaceTroops(prevTarget)
            mAreaWar.setPlaceInfo(bid,prevTarget)
        end
    end
    
    if distSec <= 0 then
        distSec = 10
    end

    userActionInfo.prev = prevTarget
    userActionInfo.target = target
    userActionInfo.st = ts
    userActionInfo.dist = ts + distSec

    -- push
    local setret,setdata = mAreaWar.setUserActionInfo(bid,userActionInfo,true)
    local tmpUserAction = mAreaWar.formatUsersActionDataForClient{setdata}

    -- 挨个推送吧
    local members = mAreaWar.getAllianceMemUids(bid)
    local pushData = {areaWarserver={usersActionInfo=tmpUserAction}}
    for k,v in pairs(members) do
        local mid = tonumber(v)
        if mid then
            regSendMsg(mid,'areawarserver.battle.push',pushData)
        end
    end

    response.data.areaWarserver.usersActionInfo = tmpUserAction
    response.ret = 0
    response.msg = 'Success'

    return response
end