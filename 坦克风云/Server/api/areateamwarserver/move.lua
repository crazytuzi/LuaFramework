--[[
    跨服区域战，用户移动

    检测：
        所属军团是否参加了区域战
        当前时间进行的区域战赛是否包含该军团
    
    如果当前区域战已经结束，不走其它逻辑，直接给前端一个战斗结束的状态码
]]
function api_areateamwarserver_move(request)
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
    local bid = request.params.bid
    local sn = request.params.sn
    local group = request.params.group

    if uid == nil or aid == nil or target == nil or bid == nil or sn == nil or group == nil then
        response.ret = -102
        return response
    end
    
    local ts = os.time()
    local zid = getZoneId()

    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(group,bid)

    local aidKey = mAreaWar.mkKey(zid,aid)

    -- 如果游戏结束，将结束标识返给前端
    local overFlag = mAreaWar.getOverBattleFlag(bid)
    if overFlag then    
        response.data.areaWarserver.over = {
                winner=overFlag,
                battlePointInfo=mAreaWar.getWarPointInfo(bid),
            }
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local sevbattleCfg = getConfig("serverWarLocalCfg")
    local mapCfg = getConfig("serverWarLocalMapCfg1")

    local userActionInfo  = mAreaWar.getUserTroopActionInfo(bid,uid,aid,zid,sn)
    if not userActionInfo then
        response.ret = -23203
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

    -- 还没有复活
    if (userActionInfo.revive or 0) > ts then
        response.ret = -21101
        return response
    end

    local prevTarget = userActionInfo.target
    mapCfg = mapCfg.cityCfg[prevTarget]
    -- 如果是从主基地出去,需要重新设置用户的行动信息,读取最新的兵力设置
    if tonumber(mapCfg.type) == 2 then
        local userinfo = mAreaWar.getUserData(bid,uid,aid,zid)
        if not userinfo then
            response.ret = -23201
            return response
        end

        userActionInfo.binfo = userinfo.binfo
        userActionInfo.heroFlag = mAreaWar.getHeroFlagByBinfo(sn,userinfo.binfo)
        -- mAreaWar.resetUserActionInfo({bid=bid,sn=sn},userinfo,true)
    end

    if type(userActionInfo.binfo) ~= 'table' or not userActionInfo.binfo[2][userActionInfo.sn] or not next(userActionInfo.binfo[2][userActionInfo.sn]) then
        response.ret = -23203
        return response
    end

    local canReach=false
    local distSec = 100
    local pushData = {}

    local startBattleTs = mAreaWar.getBattleTs()

    for k,v in pairs(mapCfg.adjoin) do
        if(v==target)then
            if(mapCfg.distance[k]>0)then
                canReach=true
                distSec = mapCfg.distance[k]
                break
            elseif(mapCfg.roadType[k]==2)then
                if ts >= (startBattleTs + sevbattleCfg.countryRoadTime) then
                    canReach=true
                    distSec = mapCfg.distance[k]
                    break
                end
            end
        end
    end

    -- -21106 路线不通，无法行走
    if not canReach then
        response.ret = -21106
        return response
    end

    -- 不能直接通过不属于我方的据点
    local placesInfo =  mAreaWar.getPlacesInfo(bid)
    if tostring(placesInfo[prevTarget][1]) ~= aidKey and  tostring(placesInfo[target][1]) ~= aidKey then
        response.ret = -4201
        return response
    end

    if userActionInfo.dist < ts then
        local battlePlaces = mAreaWar.getPlacesUserList(bid)
        local placeBattlelist = mAreaWar.getPlaceBattleList(prevTarget,placesInfo[prevTarget][1],battlePlaces[prevTarget])
        
        if #placeBattlelist.attacker > 0 then
            -- 处于攻击方战斗队列
            local inQueue = mAreaWar.troopInBattleQueue(zid,uid,sn,placeBattlelist.attacker)
            if inQueue then
                response.ret = -21102
                return response
            end
        end

        if #placeBattlelist.attacker > 0 and #placeBattlelist.defenser > 0 then
            -- 处于防守方攻击队列
            local inQueue = mAreaWar.troopInBattleQueue(zid,uid,sn,placeBattlelist.defenser)
            if inQueue then
                response.ret = -21102
                return response
            end
        end

        if #placeBattlelist.attacker <= 0 and #placeBattlelist.defenser <= 1 then
            mAreaWar.resetPlaceTroops(prevTarget)
            mAreaWar.setPlaceInfo(bid,prevTarget)
            pushData.placesInfo = {[prevTarget]=mAreaWar.formatPlaceDataForClient(placesInfo[prevTarget])}
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
    local members = mAreaWar.getAllianceMemUids(bid,nil,zid)
    pushData.areaWarserver={usersActionInfo=tmpUserAction}

    local sendMessage = json.encode({
        data=pushData,
        ret=0,
        cmd='areateamwarserver.battle.push',
        ts = ts,
    })

    for k,v in pairs(members) do
        local mid = tonumber(v)
        if mid then
            sendMsgByUid(mid,sendMessage)
            -- regSendMsg(mid,'areateamwarserver.battle.push',pushData)
        end
    end
    
    response.data.areaWarserver.usersActionInfo = tmpUserAction
    response.ret = 0
    response.msg = 'Success'

    return response
end