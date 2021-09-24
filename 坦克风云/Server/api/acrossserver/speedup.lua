--[[
    跨服军团战，行军加速
        
    检测：
        用户是否参加了当前的跨服战
        用户是否在行进过程中
        用户到达目标点剩余时间是否还需要购买加速
        用户的金币是否足够

        本场比赛是否正在进行（有可能结束，暂时不做这个检测，前端拦住就行了）

    消息推送：TODO
]]
function api_acrossserver_speedup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            acrossserver = {},
        },
    }

    local uid = tonumber(request.uid)
    local zid = request.zoneid
    local bid = request.params.bid
    local aid = request.params.aid
    local group = request.params.group
    local round = request.params.round

    if bid == nil or aid == nil or uid == nil or group == nil then
        response.ret = -102
        return response
    end

    local weets = getWeeTs()
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

    -- 本赛区未匹配到你所在的军团信息
    local userinfo = across:getUserData(bid,zid,aid,uid)
    local userActionInfo  = across:getUserActionInfo(bid,group,zid,aid,uid)

    if not userinfo or not userActionInfo then
        response.ret = -21100
        return response
    end

    userActionInfo.speedUpNum = tonumber(userActionInfo.speedUpNum) or 0
    userinfo.gems = tonumber(userinfo.gems) or 0

    -- 没有目标无法购买
    if not userActionInfo.target then
        response.ret = -21107
        return response
    end

    local serverWarTeamCfg = getConfig('serverWarTeamCfg')
    local minsec = serverWarTeamCfg.speedBuff.minsec
    local speedRate = serverWarTeamCfg.speedBuff.per
    local upNum = userActionInfo.speedUpNum + 1
    if upNum >= #serverWarTeamCfg.speedBuff.cost then upNum = #serverWarTeamCfg.speedBuff.cost end
    local gemCost = serverWarTeamCfg.speedBuff.cost[upNum]
    
    -- 已经到达目的地，无需购买
    local tmpDiffSec = userActionInfo.dist - ts
    if tmpDiffSec <= minsec then
        response.ret = -21103
        return response
    end
    
    -- 金币不够
    if userinfo.gems < gemCost then
        response.ret = -109
        return response
    end

    local deSec = tmpDiffSec * speedRate

    userActionInfo.speedUpNum = userActionInfo.speedUpNum + 1
    userActionInfo.dist = userActionInfo.dist - deSec
    userinfo.gems = userinfo.gems - gemCost
        
    if across:updateUserBattleData(userinfo) then
        local setret,setdata,setkey = across:setUserActionInfo(bid,group,zid,aid,uid,userActionInfo)        
        across.setBattlePushData(bid,group,{
            usersActionInfo={[setkey] = setdata},
        })
        across:getUsersActionInfo(bid,group)
        across.battlePush(bid,group)
        
        response.data.acrossserver = {userinfo = userinfo}
        response.data.acrossserver.usersActionInfo = userActionInfo
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
