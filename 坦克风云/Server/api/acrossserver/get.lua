--[[
    跨服军团战，登入战场时获取相关的所有数据
    
    所需数据：
        所有人的信息：
            uid，
            服ID，
            公会ID，
            名字，
            所在城市ID，
            到达城市时间戳，
            复活的时间戳，
            属于红方还是蓝方（1是红，2是蓝），
            上次发生战斗的时间戳，
            上次发生战斗的城市ID
        所有城市的信息：
            属于红方还是蓝方（1是红，2是蓝，0或者不传是还没被占领过）
        双方军团的信息

    检测：
        所属军团是否参加了军团战
        ??? 用户所在军团是否被团长设置了上阵状态
        当前时间进行的跨服战赛是否包含该军团
    
    如果当前跨服战已经结束，不走其它逻辑，直接给前端一个战斗结束的状态码
]]
function api_acrossserver_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            acrossserver={},
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

    local allianceBattleInfo = across:getAllianceData(bid,group) 
    local zidAidKey = across.mkKey(zid,aid)

    -- -21100 本赛区未匹配到你所在的军团信息
    if not allianceBattleInfo or not allianceBattleInfo[zidAidKey] then
        response.ret = -21100
        return response
    end
    
    -- 如果自己出现在了上阵列表中，需要初始化自己的行动信息，并且返回自己的用户信息给前端
    -- if table.contains(allianceBattleInfo[zidAidKey].teams,uid) then    -- 改版后不要上阵列表了     
        local userinfo = across:getUserData(bid,zid,aid,uid)
        if not userinfo or not next(userinfo.binfo) then
            response.ret = -21108
            return response
        end

        across:getUserActionInfo(bid,group,zid,aid,uid)
        if userinfo then
            response.data.acrossserver.userinfo = across.formatUserDataForClient(userinfo) 
        end
    -- end

    local usersActionInfo = across:getUsersActionInfo(bid,group)     

    for k,v in pairs(allianceBattleInfo) do
        if type(v.basetroops) == 'table' then
            allianceBattleInfo[k].basetroops = #v.basetroops
        end
    end

    local mapCfg = getConfig("serverWarTeamMapCfg1")
    mapCfg = mapCfg.baseCityID
    for _,placeId in ipairs(mapCfg) do
        local baseTroopsDieInfo = across:getBasePlaceTroops(bid,group,placeId)
        if type(baseTroopsDieInfo) == 'table' then
            local dieNum = 0
            for k,v in pairs(baseTroopsDieInfo) do
                dieNum = k
                if next(v) then    
                    dieNum = k - 1   
                    break
                end
            end
            if dieNum > 0 then
                if not response.data.acrossserver.basetroops then response.data.acrossserver.basetroops = {} end
                response.data.acrossserver.basetroops[placeId] = dieNum
            end
        end
    end
    
    -- 设置一下军团成员id
    across:joinBattlefield(bid,uid,aid,zid,group)

    response.data.acrossserver.points = across:getPoint(bid,group)
    response.data.acrossserver.placesBlood = across:getBasePlaceBlood(bid,group)
    response.data.acrossserver.placesInfo =  across:getPlacesInfo(bid,group)
    response.data.acrossserver.command = across:getAllianceCommand(bid,group,zid,aid)
    response.data.acrossserver.usersActionInfo = usersActionInfo
    response.data.acrossserver.alliancesInfo = allianceBattleInfo    
    response.ret = 0
    response.msg = 'Success'

    return response
end
