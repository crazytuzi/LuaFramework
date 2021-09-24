--[[
    TODO 需要检查矿点刷多出来的情况
]]

local goldMine = {}

local cacheKeys = {
    -- 所有的金矿信息
    hashGoldMineId = "z%s.goldMineMapId",

    -- 所有金矿定时任务信息
    hashGoldMineCron = "z%s.goldMineCronId",
}

--[[
    生成标识key
    全服所有需要连接两个元素得到的标识都通过此方法生成
]]
local function mkKey(...)
    return table.concat({...},'-')
end

-- 生成缓存key
local function mkCacheKey(cacheKey)
    if cacheKeys[cacheKey] then
        return string.format(cacheKeys[cacheKey],getZoneId())
    end
end

-- 创建金矿矿点
-- return string
function goldMine.createGoldMine()
    local boxid,x,y

    setRandSeed()
    boxid = rand(1,36)

    x = boxid%6
    x = (x == 0 and 6 or x) * 100
    y =  math.ceil(boxid/6) * 100

    local xmin=x-99
    local ymin=y-99

    x = rand(xmin,x)
    y = rand(ymin,y)     

    local x1 = x - 5
    local x2 = x + 5
    local y1 = y - 5
    local y2 = y + 5

    if x1 < xmin then x1 = xmin end
    if y1 < ymin then y1 = ymin end
    if x2 > x then x2 = x end
    if y2 > y then y2 =y   end

    if x1 < 5 then x1 = 5 end
    if y1 < 5 then y1 = 5 end
    if x2 > 595 then x2 = 595 end
    if y2 > 595 then y2 = 595 end

    -- 需要排除掉现有的金矿
    local goldMineInfo = goldMine.getGoldMineInfo()
    local goldMineMapId = {0}
    for k,v in pairs(goldMineInfo) do
        table.insert(goldMineMapId,k)
    end

    local goldMineMapIdStr = table.concat(goldMineMapId,",")
    goldMineInfo,goldMineMapId = nil,nil

    local db = getDbo()
    local sql = "select id,type,oid from map where x>:x1 and x<:x2 and y>:y1 and y<:y2 and oid=0 and type in (1,2,3,4,5) and id not in (".. goldMineMapIdStr ..")"

    local result = db:getAllRows(sql,{x1=x1,y1=y1,x2=x2,y2=y2})

    if not result or #result < 1 then
        return goldMine.createGoldMine()
    else
        for i=1,#result do
            local k = rand(1,#result)
            local pos = result[k]

            if tonumber(pos.oid) == 0 and commonLock(tostring(pos.id),"maplock") then
                return tostring(pos.id) 
            else
                table.remove(result,k)
            end
        end
    end
end

-- 清理过期的金矿信息
-- param table allGoldMineInfo 所有的金矿信息
function goldMine.clearExpireGoldMineId(allGoldMineInfo)
    if type(allGoldMineInfo) == 'table' then
        local ts = getClientTs()
        local redis = getRedis()
        local key = mkCacheKey("hashGoldMineId")

        for mid,minfo in pairs(allGoldMineInfo) do
            if type(minfo) == 'table' then
                local expireat = tonumber(minfo[2]) or 0
                if expireat < ts then
                    redis:hdel(key,mid)
                    writeLog({
                        msg="log.goldMine.cleargoldmine",
                        minfo=minfo,
                    })
                end
            end
        end
    end
end

-- param int delay 在这个过期的时间基础上后延一定的时间再出金矿
-- param int goldMineId 触发下一次金矿任务的当前金矿id
function goldMine.setNextGoldMineCron(delay,goldMineId)
    local goldMineCfg = getConfig("goldMineCfg")

    setRandSeed()
    local randTs = rand(goldMineCfg.refreshTime[1],goldMineCfg.refreshTime[2])
    randTs = randTs - randTs % 10

    delay = randTs * 60 + delay

    local nextInfo = mkKey(goldMineId,getClientTs()+delay)

    local params = {cmd ="map.goldmine",params={nextInfo=nextInfo,action=1}}
    local ret,cronid = setGameCron(params,delay)

    if ret and type(cronid) == 'number' then
        goldMine.saveGoldMineCronId(cronid,nextInfo)
    else
        writeLog({
            msg='log.goldMine.setNextGoldMineCron',
            ret=ret,
            cronid=cronid,
        })
    end
end

-- 设置到期后清理该矿的定时
function goldMine.expireCron(delay,goldMineId)
    local params = {cmd ="map.goldmine",params={mid=goldMineId,action=3}}
    setGameCron(params,delay)
end

-- 保存触发金矿的任务信息
-- param int cronId 任务id
-- param int goldMineId 上一个金矿id
function goldMine.saveGoldMineCronId(cronId,goldMineId)
    local redis = getRedis()
    local key = mkCacheKey("hashGoldMineCron")

    redis:hset(key,cronId,goldMineId)
    local allCronId = redis:hgetall(key)

    if type(allCronId) == 'table' then
        setFreeData(key,json.encode(allCronId),true)
    end
end

-- 获取所有的任务信息
function goldMine.getGoldMineCronInfo()
    local redis = getRedis()
    local key = mkCacheKey("hashGoldMineCron")
    local allCronId = redis:hgetall(key)

    -- 缓存不存在从数据库取
    if type(allCronId) == 'table' and not next(allCronId) then
        local allCronIdFromDb = getFreeData(key)
        if type(allCronIdFromDb) == 'table' and type(allCronIdFromDb.info) == 'table' and next(allCronIdFromDb.info) then
            redis:hmset(key,allCronIdFromDb.info)
            allCronId = allCronIdFromDb.info
        end
    end

    return allCronId
end

-- 清除已经执行的任务
function goldMine.delGoldMineCronId(id)
    local redis = getRedis()
    local key = mkCacheKey("hashGoldMineCron")
    redis:hdel(key,id)

    writeLog({
        msg="log.goldMine.delGoldMineCronId",
        id=id,
    })
end

local function sendGoldMineMessage(mid,disappearTime,level)
    local pos = getPosByMid(tonumber(mid))
    local msg = {
        content={
            contentType=4,
            type=37,
            params={
                newGoldMine={getMineDirection(pos.x,pos.y)}
            }  
        },
        channel=1,
        type="chat",
    }

    sendMessage(msg)
end

-- 世界等级有奇数,矿的配置只有偶数的，需要处理一下
local function getGoldMineLvByWorldLv()
    local minLv = 2
    local wlv = tonumber(getWorldLevel()) or 0
    if wlv < minLv then wlv = minLv end
    wlv = wlv - (wlv % 2)

    return wlv
end

-- 设置金矿ID
function goldMine.saveGoldMineId(id)
    local ts = getClientTs()
    local redis = getRedis()
    local key = mkCacheKey("hashGoldMineId")
    local goldMineCfg = getConfig("goldMineCfg")
    
    -- 用当前已经有的金矿数量对金矿的生成时间作一个时间偏移,防止生成时间一模一样的金矿
    local goldMineNum = tonumber(redis:hlen(key)) or 1
    local goldMineSt = ts + goldMineNum * 10

    local expireat = goldMineSt+goldMineCfg.exploitTime
    local level = getGoldMineLvByWorldLv()
    local goldMineInfo = {id,expireat,level}

    writeLog({
        msg="log.saveGoldMineId",
        goldMineInfo=goldMineInfo
    })

    redis:hset(key,id,json.encode(goldMineInfo))
    sendGoldMineMessage(id,expireat,level)

    -- 所有金矿信息入库
    local allMineInfo = redis:hgetall(key)
    if type(allMineInfo) == 'table' and next(allMineInfo) then
        for k,v in pairs(allMineInfo) do
            allMineInfo[k] = json.decode(v)
        end

        -- 这个是占位数据，不要入库
        if allMineInfo['a'] then allMineInfo['a'] = nil end

        setFreeData(key,json.encode(allMineInfo),true)
    end

    -- 设置下次生成金矿的任务
    goldMine.setNextGoldMineCron(expireat-ts,id)
    goldMine.expireCron(expireat-ts,id)

    commonUnlock(tostring(id),"maplock")

    return allMineInfo
end

-- cron是否过期
local function cronIsExpire(cron)
    local ts = getClientTs()
    local info = string.split(tostring(cron),'-')
    if type(info) == "table" then
        return (info[2] + 3600) < ts
    end

    return true
end

-- 获取有效的任务id
function goldMine.getvalidCronId(cronInfo)
    local cronIds = table.keys(cronInfo)
    local serverCronInfo = getGameCron(cronIds)

    -- 记录有效的cronId
    local validId = {}
    for k,v in pairs(serverCronInfo) do
        if type(v) == 'table' and v.params and v.params.nextInfo == cronInfo[k] then
            validId[k] = cronInfo[k]
        end
    end

    return validId
end

-- TODO修复并检测任务是否正常
function goldMine.repair()
    local goldMineCfg = getConfig("goldMineCfg")
    local cronInfo = goldMine.getGoldMineCronInfo()

    local waitCronNum = 0
    if type(cronInfo) == "table" then
        local validId = goldMine.getvalidCronId(cronInfo)
        waitCronNum = table.length(validId)

        -- 删除无效的cronId
        for k,v in pairs(cronInfo) do
            if not validId[k] and cronIsExpire(v) then
                goldMine.delGoldMineCronId(k)
            end
        end

        validId = nil
    end
    
    if waitCronNum < goldMineCfg.maxGoldMineCount then
        for i=waitCronNum+1,goldMineCfg.maxGoldMineCount do
            local mid = goldMine.createGoldMine()
            local allGoldMineInfo = goldMine.saveGoldMineId(mid)

            -- 清理过期的金矿数据
            goldMine.clearExpireGoldMineId(allGoldMineInfo)
        end
    end

    writeLog({
        msg="log.goldMine.repair",
        waitCronNum=waitCronNum,
        maxGoldMineCount=goldMineCfg.maxGoldMineCount,
    })
end

-- 获取金矿数据
function goldMine.getGoldMineInfo()
    local goldMineInfo = {}

    local redis = getRedis()
    local key = mkCacheKey("hashGoldMineId")
    local allMineInfo = redis:hgetall(key)

    if type(allMineInfo) == 'table' and not next(allMineInfo) then
        local allMineInfoFromDb = getFreeData(key)
        
        -- 补一个临时数据存入缓存,可以防止在正常逻辑下没有金矿的时候一直读数据库（redis的hashtable在没有数据的时候会被删掉）
        if type(allMineInfoFromDb) ~= "table" or type(allMineInfoFromDb.info) ~= 'table' or not next(allMineInfoFromDb.info) then
            allMineInfoFromDb = {
                info = {["a"] = {0,0,0}}
            }
        end

        local tmpMineInfo = {}
        for k,v in pairs(allMineInfoFromDb.info) do
            tmpMineInfo[k] = json.encode(v)
        end

        if next(tmpMineInfo) then
            redis:hmset(key,tmpMineInfo)
        end

        allMineInfo = allMineInfoFromDb.info
    end

    if type(allMineInfo) == "table" then
        local ts = getClientTs()
        for mid,minfo in pairs(allMineInfo) do
            minfo = json.decode(minfo)
            if type(minfo) == 'table' then
                local expireat = tonumber(minfo[2]) or 0
                if expireat > ts then
                    goldMineInfo[mid] = minfo
                end
            end
        end
    end

    allMineInfo = nil

    -- goldMineInfo = {
    --     ["61591"]={61591,1463731980,40},
    --     ["62192"]={62192,1463123520,40},
    --     ["62791"]={62791,1463123520,40},
    -- }

    return goldMineInfo
end

-- 获取金矿部队
function goldMine.getGoldMineTroops(level,islandData)
    local n = 1
    local islandCfg = getConfig('island')
    if type(islandData) == 'table' then
        n = islandData.troops or 1
    end

    -- 金矿部队数量减半
    local goldMineTroops = copyTable(islandCfg[level].troops[n])
    for k,v in pairs(goldMineTroops) do
        if type(v) == "table" and v[2] then
            v[2] = math.ceil(v[2]/2)
        end
    end

    return goldMineTroops
end

return goldMine
