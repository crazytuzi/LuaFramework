--[[
    服内区域战，登入战场时获取相关的所有数据
    
    说明：
        只要调接口就走正常逻辑

    所需数据：
        我方军团所有人的信息：
            uid，
            公会ID，
            名字，
            所在城市ID，
            到达城市时间戳，
            复活的时间戳，
            上次发生战斗的时间戳，
            上次发生战斗的城市ID
        所有城市的信息：
            属于哪个军团（0或者不传为未占领过）
        参战军团的信息：
            军团名，军团id

    检测：
        所属军团是否参加了今日的区域战
    
    状态：
        如果当前区域战已经结束，不走其它逻辑，直接给前端一个战斗结束的状态码
]]
function api_areateamwarserver_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver={},
        },
    }

    -- bid 当日区域战的标识，由后端分配，所有的数据靠bid来关联
    -- aid 军团id
    local uid = tonumber(request.uid)
    local aid = tostring(request.params.aid)
    local init = request.params.init
    local bid = request.params.bid
    local group = request.params.group
    local init = request.params.init

    if aid == nil or uid == nil or bid == nil or group == nil then
        response.ret = -102
        return response
    end

    local weets = getWeeTs()
    local ts = getClientTs()
    local zid = getZoneId()
    
    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(group,bid)

    local aidKey = mAreaWar.mkKey(zid,aid)
    local startBattleTs,endBattleTs = mAreaWar.getBattleTs()

    if ts >= startBattleTs and ts <= (endBattleTs+300) then
        -- 游戏结束,结束标识返给前端
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
    end

    -- 如果时间大于当天结束时间的话,只给前端返用户信息就行了
    if ts > endBattleTs then
        local userinfo = mAreaWar.getUserData(bid,uid,aid,zid)
        if userinfo then
            response.data.areaWarserver.userinfo = mAreaWar.formatUserDataForClient(userinfo)
        else
            response.data.areaWarserver.userinfo = {}
        end
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- -4200 所属军团没有报名区参加区域战
    local allianceBattleInfo = mAreaWar.getAlliancesData(bid)
    if not allianceBattleInfo or not allianceBattleInfo[aidKey] then
        response.ret = -23202
        return response
    end

    -- 检测用户主基地是否还存在
    local pushFlag = false
    -- 据点信息
    local placesInfo = mAreaWar.getPlacesInfo(bid)
    -- 该军团的主基地id
    local basePlace = mAreaWar.getAllianceBasePlace(bid,aidKey)
    
    if placesInfo[basePlace] and (placesInfo[basePlace][1] == aidKey or tonumber(placesInfo[basePlace][1]) == 0) then
        local userinfo = mAreaWar.getUserData(bid,uid,aid,zid)
        if userinfo and userinfo.binfo then
            -- 初始化用户在地图中的信息,为用户分配主基地
            local userActionInfo,firstGet=mAreaWar.getUserActionInfo(bid,uid,aid,zid)
            if not next(userActionInfo) then
                return response
            end

            pushFlag = firstGet

            -- response.data.areaWarserver.troops = {}
            -- for k,v in pairs(userActionInfo) do
            --     if v.troops then
            --         response.data.areaWarserver.troops[tostring(v.sn)] = v.troops
            --     end
            -- end

            response.data.areaWarserver.userinfo = mAreaWar.formatUserDataForClient(userinfo)
        end
    end

    -- 加入后才会推消息
    if init or pushFlag then
        mAreaWar.joinAreaWar(bid,uid,aid,zid)
    end

    local usersActionInfo = mAreaWar.getUsersActionInfo(bid)

    response.data.areaWarserver.placesInfo =  mAreaWar.formatPlacesDataForClient(placesInfo)
    response.data.areaWarserver.usersActionInfo = mAreaWar.formatUsersActionDataForClient(usersActionInfo)
    response.data.areaWarserver.command = mAreaWar.getAllianceCommand(bid,zid,aid)
    response.data.areaWarserver.alliancesInfo = mAreaWar.formatAlliancesDataForClient(allianceBattleInfo) 
    response.data.areaWarserver.battleTasks = mAreaWar.getBattleTasks(bid)
    response.data.areaWarserver.battlePointInfo = mAreaWar.getWarPointInfo(bid)

    -- TODO 如果当前有任务,需要把任务带过去

    -- if pushFlag then
    --     -- 挨个推送吧
    --     local members = mAreaWar.getAllianceMemUids(bid)
    --     for k,v in pairs(members) do
    --         local mid = tonumber(v)
    --         if mid then
    --             regSendMsg(mid,'areateamwarserver.battle.push',{areaWarserver={usersActionInfo=response.data.areaWarserver.usersActionInfo}})
    --         end
    --     end
    -- end

    response.ret = 0
    response.msg = 'Success'
    return response
end
