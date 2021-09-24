--[[
    跨服军团战，用户移动

    检测：
        所属军团是否参加了军团战
        用户所在军团是否被团长设置了上阵状态
        当前时间进行的跨服战赛是否包含该军团
        TODO 检测当前组参赛的军团是否轮空，如果轮空其实是直接胜利，不让移动，这个让前端直接判断，不开板子，应该进不来
    
    如果当前跨服战已经结束，不走其它逻辑，直接给前端一个战斗结束的状态码
]]
function api_acrossserver_move(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            acrossserver = {},
        },
    }

    -- 战斗标识
    local bid = request.params.bid
    local zid = request.zoneid
    local uid = request.uid
    local group = request.params.group
    local aid = request.params.aid
    local target = request.params.target
    local round = request.params.round

    if bid == nil or uid == nil or aid == nil or group == nil or target == nil then
        response.ret = -102
        return response
    end
    
    local ts = getClientTs()

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(bid)

    -- 如果游戏结束，将结束标识返给前端
    if across:getAllianceEndBattleFlag(bid,group) then        
        response.data.acrossserver.over =across:getOverData(bid,group,zid,aid,uid,round)
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local zidAidKey = across.mkKey(zid,aid)
    local allianceBattleInfo = across:getAllianceData(bid,group)

    -- -21100 本赛区未匹配到你所在的军团信息
    if not allianceBattleInfo or not allianceBattleInfo[zidAidKey] then
        response.ret = -21100
        return response
    end

    -- 不在上阵列表中
    -- if not allianceBattleInfo[zidAidKey] or not table.contains(allianceBattleInfo[zidAidKey].teams,uid) then
    --     response.ret = -21105
    --     return response
    -- end

    local userActionInfo  = across:getUserActionInfo(bid,group,zid,aid,uid)
    if not userActionInfo then
        response.ret = -21100
        return response
    end

    -- 如果新目标与原目标一致，直接返回成功
    if userActionInfo.target == target then
        response.ret = 0
        response.msg = 'Success'
        return response
    end
    
    -- 正在行动中
    if userActionInfo.target ~= userActionInfo.basePlace then
        if userActionInfo.dist >= ts then
            response.ret = -21101
            return response
        end
    end

    local prevTarget = userActionInfo.target
    local sevbattleCfg = getConfig("serverWarTeamCfg")
    local mapsCfg = getConfig("serverWarTeamMapCfg1")
    mapCfg = mapsCfg.cityCfg[prevTarget]
    
    local canReach=false
    local distSec = 100
    for k,v in pairs(mapCfg.adjoin) do
        if(v==target and mapCfg.distance[k]>0)then
            if (mapCfg.roadType[k]==1 or (mapCfg.roadType[k]==2 and across.checkShowCountryRoad(group,sevbattleCfg,ts))) then
                canReach=true
                distSec = mapCfg.distance[k]
                break
            end
        end
    end

    -- -21106 路线不通，无法行走(如果是小路，有可能还没显示出来)
    if not canReach then
        response.ret = -21106
        return response
    end

    if userActionInfo.dist <= ts then
        local battlePlaces = across:getPlacesUsersList(bid,group)
        -- if battlePlaces[prevTarget][zidAidKey] and table.length(battlePlaces[prevTarget]) then

        if battlePlaces[prevTarget] and battlePlaces[prevTarget][zidAidKey] then
            local placeUserlist = across.getPlaceBattleUser(battlePlaces[prevTarget])
            local tnum = #placeUserlist

            -- 如果有两支军团或者这个据点不是我方的,需要进行是否处于战斗队列的检查
            local placeOid = across:getPlaceInfo(bid,group,prevTarget)
            if prevTarget == userActionInfo.basePlace then
                placeOid = across.mkKey(userActionInfo.zid,userActionInfo.aid)
            end

            if tnum == 2 or ( placeOid ~= zidAidKey) then
                for k,v in pairs(placeUserlist or {}) do
                    if tonumber(v.zid) == tonumber(zid) and tonumber(v.aid) == tonumber(aid) and tonumber(v.uid) == tonumber(uid) then
                        response.ret = -21102
                        return response
                    end
                end
            end

            -- if tonumber(battlePlaces[prevTarget][zidAidKey][1].uid) == uid then
            --     response.ret = -21102
            --     return response
            -- end
        end
    end

    local userinfo = across:getUserData(bid,zid,aid,uid)
    local userBuffs = across.getUserBuffs(userinfo)    
    local buffLv = userBuffs.b4
    if buffLv > 0 then
        distSec = distSec / (1 + buffLv * sevbattleCfg.buffSkill.b4.per)
    end

    if distSec <= 0 then
        distSec = 10
    end

    userActionInfo.prev = prevTarget
    userActionInfo.target = target
    userActionInfo.st = ts
    userActionInfo.dist = ts + distSec
    userActionInfo.speedUpNum = 0

    -- push
    local setret,setdata,setkey = across:setUserActionInfo(bid,group,zid,aid,uid,userActionInfo)
    across.setBattlePushData(bid,group,{
        usersActionInfo={[setkey] = setdata},
    })
    across:getUsersActionInfo(bid,group)
    across.battlePush(bid,group)

    response.data.acrossserver.usersActionInfo = userActionInfo
    response.ret = 0
    response.msg = 'Success'

    return response
end