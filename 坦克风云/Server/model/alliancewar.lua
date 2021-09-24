local allianceWar = {
}

-- 获取战争id
-- params positionId 阵地编号
-- return int
function allianceWar:getWarId(positionId,ts)
    ts = ts or getClientTs()        
    local openPosition,day = self:getOpenPosition(ts)

    if openPosition[positionId] and day then
        return tonumber(openPosition[positionId] .. day)
    end
end

-- 获取今日开放的阵地
-- 单日开放东区/双日开放西区
    -- 东区 1-4 西区 5-8
-- return table
function allianceWar:getOpenPosition(ts)
    local openPosition = {}

    local zone = getConfig('base.TIMEZONE')
    local weets = getWeeTs(ts)
    weets = weets + zone * 3600
    local day = weets / 86400

    if day % 2 == 1 then   
        openPosition = {[5]=5,[6]=6,[7]=7,[8]=8}
    else
        openPosition = {[1]=1,[2]=2,[3]=3,[4]=4}
    end
    
    return openPosition,day
end

-- 获取阵地的占有者和兵力
-- params placeId 阵地
-- params warId 战争标识
function allianceWar:getPlaceInfo(positionId,placeId,warId)
    local troopsInfo = {}

    local cacheKey = self:getCacheKey(positionId,placeId,warId)

    if cacheKey then
        local redis = getRedis()
        
        redis:watch(cacheKey)
        local result = redis:get(cacheKey)

        if result then
            local tmpInfo = json.decode(result) or {}
            
            if warId == tonumber(tmpInfo.warId) then
                troopsInfo = tmpInfo
            end
        end
    end

    return troopsInfo
end

--[[ 
    设置阵地的占有者和兵力
    params int st 占领此地的起始时间
    params int placeId 小地块标识 1-9 
    params int positionId 战场标识 1-8 单日只开放4个
    params warId 战争标识【唯一】,战报等计算会以此为基准
    params int oid 当前地块的占领者
    params table troops 当前地块的兵力信息
    params table label 红蓝标识 1红，2蓝
    params table buff 占领者的buff信息
    params st 占领的起始时间
    params int attackStatus 进攻胜利是1，防守胜利是2
        需要重新设置updated_at字段，计算积分的时候会以此值为起始时间计算
        记录占领者的军团名，军团id，用户昵称，在结算出战报时用
    return bool
]]
function allianceWar:setPositionTroops(st,positionId,placeId,warId,oid,troops,mUserinfo,label,buff,attackStatus)
    local troopsInfo = {}

    if not warId or not oid or type(troops) ~= 'table' then
        return false,-102
    end

    local cacheKey = self:getCacheKey(positionId,placeId,warId)
    
    troopsInfo.placeId = placeId
    troopsInfo.positionId = positionId
    troopsInfo.st = st
    -- troopsInfo.buff = buff
    troopsInfo.oid = oid
    troopsInfo.aid = mUserinfo.alliance
    troopsInfo.aname = mUserinfo.alliancename
    troopsInfo.nickname = mUserinfo.nickname
    troopsInfo.label = label
    troopsInfo.troops = troops
    troopsInfo.warId = warId
    troopsInfo.updated_at = getClientTs()
    troopsInfo.atts = attackStatus

    local troopsInfo4Str = json.encode(troopsInfo)
    if not troopsInfo4Str then
        return false
    end

    local redis = getRedis()
    redis:multi()
    redis:set(cacheKey,troopsInfo4Str)
    redis:expire(cacheKey,86400)   
    local result = redis:exec()

    -- 数据发生变化
    if not result then
        return false
    end

    -- 缓存写入失败
    if type(result) == "table" and not result[1] then
        return false
    end

    return troopsInfo
end

-- 重置阵地兵力,走事务
function allianceWar:resetPosition(positionId,placeId,warId) 
    local cacheKey = self:getCacheKey(positionId,placeId,warId)

    local redis = getRedis()
    redis:multi()
    redis:del(cacheKey)
    local result = redis:exec()

     -- 数据发生变化
    if not result then
        return false
    end

    if type(result) == "table" and not result[1] then
        return false
    end

    return true
end

-- 获取缓存key
-- params 
-- params placeId int 阵地标识
-- return string (z1.allianceWar.4)
function allianceWar:getCacheKey(positionId,placeId,warId)
    warId = warId or self:getWarId(positionId)

    if placeId and warId then
        return "z"..getZoneId()..".allianceWar.place." .. positionId .. "." .. placeId .. '.' .. warId
    end

    return false
end

-- 获取存放积分值的缓存key
-- 更新数据后的积分（比如战斗）
function allianceWar:getWarPointCacheKey(positionId,warId)
    warId = warId or self:getWarId(positionId)
    return "z"..getZoneId()..".allianceWar.position.point." .. positionId .. '.' .. warId
end

-- 当前积分的缓存key
-- 存放当前计算出的最新的积分（积分计算后不会修改原据点数据）
function allianceWar:getWarCurrentrPointCacheKey(positionId,warId)
    warId = warId or self:getWarId(positionId)
    return "z"..getZoneId()..".allianceWar.position.currentPoint." .. positionId .. '.' .. warId
end

-- 增加积分
-- params int warId 战斗id
-- params int label 标识（1是红方，2是蓝方）
-- params int point 积分
function allianceWar:addPoint(positionId,label,point,warId)
    point = math.floor(math.floor(point))

    if point > 0 and label then
        local pointKey = self:getWarPointCacheKey(positionId,warId)

        local redis = getRedis()

        local ret = redis:hincrby(pointKey,label,point)
        redis:hset(pointKey,'updated_at',getClientTs())
        redis:expire(pointKey,86400)

        return ret
    end

    return true
end

-- 获取积分
-- params int positionId 战场id 
-- return table
function allianceWar:getPositionPoints(positionId,warId)
    local point = {0,0}

    local pointKey = self:getWarPointCacheKey(positionId,warId)
    local redis = getRedis()
    local result = redis:hgetall(pointKey) or {}

    if result.updated_at then
        local weets = getWeeTs()
        local lastUpdateWeets = getWeeTs(result.updated_at)
        if  weets ~= lastUpdateWeets and (weets - 86400) ~= lastUpdateWeets then
            redis:del(pointKey)
            result = {}
        end
    end

    for k,v in pairs(point) do 
        point[k] = (result[tostring(k)] or 0) + v
    end

    return point
end

-- 根据地块id得到战场id
function allianceWar:getpositionIdByPlaceId(placeId)
    return math.ceil(placeId / 9)
end

-- 根据地块id获取此地块在阵地中的编号
function allianceWar:getPlaceNoInposition(placeId)
    local No = placeId % 9 
    No = No == 0 and 9 or No
    return No
end

--[[ 按占领时间计算分数
    params int ts 占领的时间
    params placeId 地址Id
    params table buff ["b3"] = {
        [1] = 1403319575,
        [2] = 1403319578,
        [3] = 1403319580,
    },
    params int st 结算起始
    params int et 结算截至
    return int 
]]
function allianceWar:getPointByOccupiedTime(positionId,placeId,buffInfo,st,et)
    local point = 0

    if et > st then
        local allianceWarCfg = getConfig('allianceWarCfg')        
        local stronghold = 'h'..placeId
        local winPoint = allianceWarCfg.stronghold[stronghold].winPoint

        local ts = et - st
        point = point + (ts * winPoint)
        
        -- 将buff作用时间分段
        if type(buffInfo) == 'table' and type(buffInfo.b3) == 'table' then
            local buff = buffInfo.b3
            local maxLv = #buff

            local tmpBuffTs = {}
            for level,levelat in pairs(buff) do   

                if levelat > st then                     
                    local plv = level - 1
                    if buff[plv] and et > buff[plv] then
                        tmpBuffTs[plv] = (levelat > et and et or levelat) - (buff[plv] < st and st or buff[plv])
                    end
                end

                if level == maxLv then
                    if et > levelat then                     
                        tmpBuffTs[level] = et - (levelat < st and st or levelat)
                    end
                end
            end
            
            for level,inLvTs in pairs(tmpBuffTs) do                
                point = point + inLvTs * winPoint * allianceWarCfg.buffSkill.b3.per * level
                -- print(point,inLvTs,winPoint,level,allianceWarCfg.buffSkill.b3.per,inLvTs * winPoint * allianceWarCfg.buffSkill.b3.per * level)
            end
        end
    end
    
    return point
end

-- 按占领时间计算贡献
-- params table troops 死亡的部队信息
-- params int ts 占领的时间
-- params int point 积分
-- params table buff buff加成
-- return int 
function allianceWar:getDonateByOccupiedTime(troops,point,buff)
    local donate = 0    
    local allianceWarCfg = getConfig('allianceWarCfg')
    local tankCfg = getConfig('tank')
    if type(troops) == 'table' then
        for k,v in pairs(troops) do
            donate = donate + tankCfg[k].tankDonate * v * (1 + (buff.b4 * allianceWarCfg.buffSkill.b4.per))
        end
    end

    donate = donate + allianceWarCfg.winPointToDonate * point
    donate = math.ceil(donate)

    -- 最低为1
    if donate == 0 then donate = 1 end
    
    return donate
end

-- 获取阵地的占有者和兵力
-- params int positionId 战场
-- return table
function allianceWar:getPositionInfo(positionId,warId)
    local info = {}
    local allianceWarCfg = getConfig('allianceWarCfg')

    local redis = getRedis()
    redis:multi()

    local placeId = 1
    local tmpTab = {}
    for k,v in pairs(allianceWarCfg.stronghold) do
        local cacheKey = self:getCacheKey(positionId,placeId,warId) 

        if cacheKey then        
            redis:get(cacheKey)
        end

        tmpTab[placeId] = cacheKey
        placeId = placeId + 1
    end

    local result = redis:exec()        

    if type(result) == 'table' then
        for k,v in pairs(tmpTab) do
            local hk = 'h'..k
            info[hk] = nil

            local tmpData = json.decode(result[k])            
            if type(tmpData) == 'table' and tmpData.oid then                
                local uobjs = getUserObjs(tmpData.oid,true)
                local mTroops = uobjs.getModel('troops')

                if type(mTroops.alliancewar) == 'table' and mTroops.alliancewar.warId == tmpData.warId then
                    info[hk] = tmpData
                else
                    writeLog(tmpData,'delAllianceWarCache')
                    redis:del(v)
                end                
            end

            if not info[hk] then
                info[hk] = {}
            end
        end
    end

    return info
end

-- 获取战场开放时间
-- params int positionId 战场
-- params int warId 战争标识
-- return int | table
function allianceWar:getWarOpenTs(positionId,warId)
    local open = {}
    local weets
    
    if warId then        
        local zone = getConfig('base.TIMEZONE')
        local day = tonumber(string.sub(warId,2))        
        weets = day * 86400 - (3600 * zone)
    else
        weets = getWeeTs()
    end

    local allianceWarCfg = getConfig('allianceWarCfg')    
    if allianceWarCfg.startWarTime[positionId] then
        open.st = weets + allianceWarCfg.startWarTime[positionId][1] * 3600 + allianceWarCfg.startWarTime[positionId][2] * 60
        open.et = open.st + allianceWarCfg.warTime

        return open
    end
end

-- 获取战场打开状态
-- params int positionId 战场
-- return int 0 开启 其它为状态码
function allianceWar:getWarOpenStatus(positionId,warId)
    ts = getClientTs()
    local opents = self:getWarOpenTs(positionId,warId)

    if ts < opents.st then
        return -4010
    end

    -- 战场已关闭
    if ts > opents.et then
        return -4011
    end

    return 0
end

-- 获取当前所有据点的总分数（会计算所有据点）
-- params int positionId 战场P
-- params int recount 是否重新计算 
-- return table 1 红方分数 2 蓝方分数 
function allianceWar:getAllPlacePoint(positionId,recount,warId)
    local point = {0,0}
    local cacheKey = self:getWarCurrentrPointCacheKey(positionId)
    local positionInfo
    local redis = getRedis()    
    local placePoint = {}
    
    -- 重新计算
    if recount then
        positionInfo = self:getPositionInfo(positionId,warId)   

        --[[
            10/s结算一次，是按后台时间计算的，如果这里取clientTs很有可能会比后台慢一点
            这会导致计算的时候值往回回退，前台显示玩家体验不好，
            所以这里直接取系统时间进行计算
        ]]
        local ts = os.time()

        -- 如果时间超过了本场战斗的结束时间，则按结束时间计算
        local openTs = allianceWar:getWarOpenTs(positionId,warId)    
        if ts > openTs.et then
            ts = openTs.et
        end         

        if type(positionInfo) == 'table' then
            for k,v in pairs(positionInfo) do
                local uid = tonumber(v.oid)
                if v.updated_at and v.label and v.placeId and v.positionId  and uid then              
                    local uobjs = getUserObjs(uid,true)
                    local mUserAllianceWar = uobjs.getModel('useralliancewar')
                    local userBuff = mUserAllianceWar.getBattleBuff()  
                    
                    local score = self:getPointByOccupiedTime(v.positionId,v.placeId,mUserAllianceWar.upgradeinfo,v.updated_at,ts)
                    if score < 0 then score = 0 end

                    point[v.label] = (point[v.label] or 0) + score
                    v.point = score
                end
            end
        end

        redis:set(cacheKey,json.encode(point))
        redis:expire(cacheKey,86400)   
    else
        local result = redis:get(cacheKey)
        if result then
            result = json.decode(result)
        end

        if not result then
            writeLog('error get result','testpoint')
        end

        point = result or point
    end
    
    return point,positionInfo
end

-- 战争结束
-- 如果分数达到结算值，需要结算数据
-- 发送结算战报
-- 清除所有据点的缓存数据
-- 返还所有用户据守在据点的部队
    -- 有可能总分数超过50万（10秒一次结算，其实结束时间应往前推）
-- params int positionId 战场id
-- params table positionInfo 每个据点的兵力 
function allianceWar:getAllPlaceLog(positionId,positionInfo,warId)
    if not positionInfo then
        positionInfo = self:getPositionInfo(positionId,warId)
    end

    local data = {}
    local report = {}
    local ts = getClientTs()

    warId = warId or self:getWarId(positionId)

    -- 如果时间超过了本场战斗的结束时间，则按结束时间计算
    local openTs = allianceWar:getWarOpenTs(positionId,warId)    
    if ts > openTs.et then
        ts = openTs.et
    end

    for k,v in pairs(positionInfo) do 
        local uid = tonumber(v.oid)

        if tonumber(v.warId) == warId and uid then     
            local uobjs = getUserObjs(uid,true)
            local mUserAllianceWar = uobjs.getModel('useralliancewar')
            local userBuff = mUserAllianceWar.getBattleBuff()

            local defPoint = v.point
            if not defPoint then
                defPoint = self:getPointByOccupiedTime(v.positionId,v.placeId,mUserAllianceWar.upgradeinfo,v.updated_at,ts)
            end

            local defRaising = self:getDonateByOccupiedTime(nil,defPoint,userBuff)
            
            local battlelog = {
                warId = warId,
                attacker = 0,
                defender = v.oid,
                attackerName = '',
                defenderName = v.nickname,
                attackerAllianceId = 0,
                defenderAllianceId = v.aid,
                attAllianceName = '',
                defAllianceName = v.aname,
                attBuff = {},
                defBuff = v.buff,
                attPoint = 0,
                defPoint = defPoint,
                victor = v.oid,
                report = report,
                attRaising = 0,
                defRaising = defRaising,
                position = positionId,
                placeid = placeId,
            }

            table.insert(data,battlelog)            
        end        
    end
    
    return data
end

function allianceWar:clearPosition(positionId,warId)
    local info = {}
    local allianceWarCfg = getConfig('allianceWarCfg')

    local redis = getRedis()
    -- redis:multi()

    local placeId = 1    
    for k,v in pairs(allianceWarCfg.stronghold) do
        local cacheKey = self:getCacheKey(positionId,placeId,warId) 

        if cacheKey then        
            local cacheData = redis:get(cacheKey)
            if cacheData then
                local tmpLog = {
                    action = 'clearPosition',
                    cacheKey = cacheKey,
                    cacheData = cacheData,
                }
                writeLog(tmpLog,'delAllianceWarCache')

                redis:del(cacheKey)
            end
        end

        placeId = placeId + 1
    end

    -- local pointKey = self:getWarPointCacheKey(positionId,warId)
    -- redis:del(pointKey)

    -- local result = redis:exec()

    -- return result
end

-- log
function allianceWar:writeLog(log)
    writeLog(log,'allianceWar')
end

-- 调用聊天发送
 --[[
    1.chatSystemMessage8="%s与%s即将在%s开始对战。",
    每场战斗开始的时候发送
    2.chatSystemMessage9="%s与%s在%s的战斗结束，%s取得了胜利，开始享受为期%s小时的资源增产Buff。",
    每场战斗胜利的时候发送
    3.chatSystemMessage10="今晚%s，%s与%s将在%s展开残酷的对决。",
    每场军团战报名成功的时候发送
]]
function allianceWar:sendMsg(msgType,params)

    local ts = getClientTs()
    local msg

    if msgType == 1 then
        -- "param":["红色军团名字","蓝色军团名字","战场索引"]}
        msg = {
            sender=0,
            reciver=0,
            channel=1,            
            sendername="",
            recivername="",
            type="chat",
            content={
                isSystem=1,
                message={
                    key="chatSystemMessage8",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    elseif msgType == 2 then
        -- "param":["红色军团名字","蓝色军团名字","战场索引","获胜军团名字","资源增产Buff持续时间"]
        msg = {
            sender=0,
            reciver=0,
            channel=1,            
            sendername="",
            recivername="",
            type="chat",
            content={
                isSystem=1,
                message={
                    key="chatSystemMessage9",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    else
        -- "param":["战场开战时间","红色军团名字","蓝色军团名字","战场索引"]
        msg = {
            sender=0,
            reciver=0,
            channel=1,            
            sendername="",
            recivername="",
            type="chat",
            content={
                isSystem=1,
                message={
                    key="chatSystemMessage10",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    end

    return sendMessage(msg)

end

return allianceWar