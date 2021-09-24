--[[
    军团跨服战，立即复活
        
    检测：
        用户是否参加了当前的跨服战
        用户复活时间是否还需要额外购买
        用户的金币是否足够
    
    消息推送：TODO
]]
function api_acrossserver_revive(request)
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

    local userinfo = across:getUserData(bid,zid,aid,uid)

    -- 本赛区未匹配到你所在的军团信息
    if not userinfo then
        response.ret = -21100
        return response
    end

    local serverWarTeamCfg = getConfig('serverWarTeamCfg')
    local gemCost =  serverWarTeamCfg.reviveCost

    -- 参数无效
    if not gemCost or gemCost < 1 then
        response.ret = -102
        return response
    end

    -- 金币验证
    if tonumber(userinfo.gems) < gemCost then
        response.ret = -109
        return response
    end

    local userActionInfo  = across:getUserActionInfo(bid,group,zid,aid,uid)
    if not userActionInfo then
        response.ret = -21100
        return response
    end

    if (userActionInfo.revive or 0) > ts then
        userinfo.gems = userinfo.gems - gemCost
        userActionInfo.revive = ts
        if across:updateUserBattleData(userinfo) then
            local setret,setdata,setkey = across:setUserActionInfo(bid,group,zid,aid,uid,userActionInfo)
            across.setBattlePushData(bid,group,{
                usersActionInfo={[setkey] = setdata},
            })
            across:getUsersActionInfo(bid,group)
            across.battlePush(bid,group)
            writeLog('uid='..uid..'--revive --'..gemCost,'gemsacross'..zid)
            response.data.acrossserver.userinfo = userinfo
            response.data.acrossserver.usersActionInfo = usersActionInfo
            response.ret = 0
            response.msg = 'Success'
        end
    else
        response.ret = 0
        response.msg = 'Success'
    end

    -- 29 军团战购买buff
    -- regActionLogs(uid,1,{action=29,item=buff,value=gemCost,params={old=upLevel-1,new=mUserAllianceWar[buff]}})

    return response
end