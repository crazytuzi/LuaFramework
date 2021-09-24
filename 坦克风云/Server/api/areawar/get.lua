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
function api_areawar_get(request)
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

    if  aid == nil or uid == nil then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops","userareawar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 
    local mUserareawar=uobjs.getModel('userareawar') 
    local weets = getWeeTs()
    local ts = getClientTs()

    if init then
        local sevbattleCfg = getConfig('areaWarCfg')
        local weekday = tonumber(getDateByTimeZone(ts,"%w"))
        if weekday ~= sevbattleCfg.prepareTime+sevbattleCfg.battleTime then
            response.ret=-4204
            response.weekday = weekday
            return response
        end
    end
    
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

    -- -4200 所属军团没有报名区参加区域战
    local allianceBattleInfo = mAreaWar.getAlliancesData(bid)
    if not allianceBattleInfo or not allianceBattleInfo[aid] then
        response.ret = -4200
        return response
    end

    -- 检测用户主基地是否还存在
    local pushFlag = false
    local placesInfo = mAreaWar.getPlacesInfo(bid)
    local basePlace = mAreaWar.getAllianceBasePlace(bid,aid)
    if placesInfo[basePlace] and (placesInfo[basePlace][1] == aid or placesInfo[basePlace][1] == 0) then
        local userinfo = mAreaWar.getUserData(bid,uid,aid)
        if userinfo and userinfo.binfo and tostring(userinfo.aid) == aid then
            -- 初始化用户在地图中的信息,为用户分配主基地
            local userActionInfo,firstGet=mAreaWar.getUserActionInfo(bid,uid,aid,true)
            if not userActionInfo then
                return response
            end
            pushFlag = firstGet
            response.data.areaWarserver.troops = userActionInfo.troops
        end
    end

    -- 加入后才会推消息
    if init or pushFlag then

        if tostring(mUserareawar.bid)~=tostring(bid) or aid~=mUserinfo.alliance then
           mAreaWar.joinAreaWar(bid,uid,nil)
        else
           mAreaWar.joinAreaWar(bid,uid,aid)
        end
        
    end

    local usersActionInfo = mAreaWar.getUsersActionInfo(bid)
    
    response.data.areaWarserver.placesInfo =  mAreaWar.formatPlacesDataForClient(placesInfo)
    response.data.areaWarserver.usersActionInfo = mAreaWar.formatUsersActionDataForClient(usersActionInfo)
    response.data.areaWarserver.command = mAreaWar.getAllianceCommand(bid,aid)
    response.data.areaWarserver.alliancesInfo = allianceBattleInfo   
    response.data.areaWarserver.allianceDeHp=mAreaWar.getAlliancesDeBloodValue(bid) 

    if pushFlag then
        -- 挨个推送吧
        local members = mAreaWar.getAllianceMemUids(bid)
        for k,v in pairs(members) do
            local mid = tonumber(v)
            if mid then
                regSendMsg(mid,'areawarserver.battle.push',{areaWarserver={usersActionInfo=response.data.areaWarserver.usersActionInfo}})
            end
        end
    end

    response.ret = 0
    response.msg = 'Success'
    return response
end
