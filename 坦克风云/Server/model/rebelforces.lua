--[[
    地图的protect字段表示叛军的有效时间,如果叛军被击杀,直接把过期时间设为当前
]]
local rebel = {}

-- 缓存key
local cacheKeys = {
    -- 叛军经验
    rebelForcesExp = "z%s.rebelForcesExp",
    -- 叛军信息
    rebelForcesMap = "z%s.rebelForcesMap.%s", -- zid,mid
    -- 上次刷新时间
    rebelForcesRefreshAt = "z%s.rebelForcesRefreshAt", -- zid
}

-- 存放相关数据
local rebelMapData = {}
local originalMapData = {}

-- 叛军地图类型
local rebelMapType = 7

-- 部队槽位对应的血量key
local slot2HpKey = { "hp1", "hp2", "hp3", "hp4", "hp5", "hp6" }

-- 叛军配置文件
local rebelCfg = nil

--[[
    生成标识key
]]
local function mkKey(...)
    return table.concat({ ... }, '-')
end

-- 生成缓存key
local function mkCacheKey(cacheKey, ...)
    if cacheKeys[cacheKey] then
        return string.format(cacheKeys[cacheKey], getZoneId(), ...)
    end
end

-- 获取叛军的配置
local function getRebelCfg()
    if not rebelCfg then
        rebelCfg = getConfig("rebelCfg")
    end

    return rebelCfg
end

-- 上次叛军刷新时间,防止多刷
local function getLastRefreshTs()
    local key = mkCacheKey("rebelForcesRefreshAt")
    local lastTs = getRedis():getset(key,getClientTs())

    return tonumber(lastTs) or 0
end

-- 从数据库读取世界叛军的经验
local function getExpFromDb(key)
    local exp = 0
    local freeData = getFreeData(key)

    if not freeData then
        setFreeData(key, json.encode({ exp = 0 }), true)
    end

    if type(freeData) == "table" and type(freeData.info) == "table" then
        exp = tonumber(freeData.info.exp) or exp
    end

    return exp
end

-- 保存经验到数据库中,缓存丢失后可从库中恢复
local function saveExpToDb(key)
    key = key or mkCacheKey("rebelForcesExp")
    local exp = getRedis():get(key)
    if exp then
        exp = tonumber(exp) or 0
        if exp < 0 then exp = 0 end
        setFreeData(key, json.encode({ exp = exp }), true)
    end
end

-- 从缓存获取当前的叛军世界经验
-- 如果缓存丢失要从数据库读取修复
local function getExpFromRedis(key)
    key = key or mkCacheKey("rebelForcesExp")

    local redis = getRedis()
    local exp = redis:get(key)
    if not exp then
        exp = getExpFromDb(key)
        redis:setnx(key, exp)
    end

    exp = tonumber(exp) or 0

    return exp
end

-- 从地图数据库中获取指定叛军的信息
local function getRebelInfoFromDb(mid)
    local mMap = require 'lib.map'
    local data = mMap:getMapById(mid)

    -- 判断地图类型和过期时间,protect在叛军中指过期时间
    if type(data) == "table" and tonumber(data.protect) > getClientTs() and tonumber(data.type) == rebelMapType then
        return data
    end
end

-- exp为正是增加,为负是减
local function setExp(exp)
    local key = mkCacheKey("rebelForcesExp")
    local totalExp = getExpFromRedis(key)

    local rebelCfg = getRebelCfg()
    if exp > 0 and totalExp > rebelCfg.levelExp[#rebelCfg.levelExp] then
        return totalExp
    end

    totalExp = totalExp + exp

    -- 经验值最小为0
    if totalExp >= 0 then
        return getRedis():incrby(key, exp)
    end
end

-- 保存指定叛军信息到map地图数据库
local function setRebelInfoToDb(mid, data)
    local params = { data = data }
    local mMap = require 'lib.map'

    -- 如果叛军已经死亡,清除地图
    if (tonumber(data.hp) or 0) <= 0 then
        return mMap:format(mid, true)
    end

    return mMap:update(mid, params)
end

-- 从缓存中获取指定叛军的信息
local function getRebelInfoFromRedis(mid)
    local key = mkCacheKey("rebelForcesMap", mid)
    return getRedis():hgetall(key)
end

-- 保存指定叛军信息到缓存
local function setRebelInfoToRedis(mid, info)
    if next(info) then
        local redis = getRedis()
        local key = mkCacheKey("rebelForcesMap", mid)
        redis:hmset(key, info)
        local rebelCfg = getRebelCfg()
        redis:expire(key,rebelCfg.expireTs)
    end
end

-- 清除指定叛军的缓存数据
local function deleteCache(mid)
    local key = mkCacheKey("rebelForcesMap", mid)
    getRedis():del(key)
end

-- 获取本次刷新叛军的大区域
-- 刷新区域划为9大块,每次刷新时随机出一个大地块(策划需要每次叛军必需出现在同一个区块内)
local function getRebelArea()
    setRandSeed()
    return rand(1, 9)
end

-- 获取刷新地块的实际边界值
-- param int area 地块id(1-9)
-- local function getRangeByArea(area)
--     local size = 199
--     local box = {
--         [1] = { x = 200, y = 200 },
--         [2] = { x = 400, y = 200 },
--         [3] = { x = 600, y = 200 },
--         [4] = { x = 200, y = 400 },
--         [5] = { x = 400, y = 400 },
--         [6] = { x = 600, y = 400 },
--         [7] = { x = 200, y = 600 },
--         [8] = { x = 400, y = 600 },
--         [9] = { x = 600, y = 600 },
--     }

--     local x = box[area].x
--     local y = box[area].y

--     local minx = x - size
--     local miny = y - size

--     return x, y, minx, miny
-- end
local function getRangeByArea(area)
    -- 5*5 * 1600 * 9 = 360000
    -- 一块地的大小（面积为5*5）
    local blockSize = 5
    -- 一个区域的地块数（划为9个区域）
    local blockOfArea = 1600 
    
    setRandSeed()
    local randBlock = rand(1, blockOfArea)

    --- 一行的地块数（把1600个格子划为40*40的块）
    local lineBlock = 40
    local xBlock = randBlock%lineBlock
    if xBlock == 0 then xBlock = lineBlock end
    local yBlock = math.ceil(randBlock/lineBlock)

    -- 一行的区域数（3*3）
    local lineArea = 3
    local xArea = area%lineArea
    if xArea == 0 then xArea = lineArea end 
    local yArea = math.ceil(area/lineArea)

    local x2 = xBlock * blockSize + lineBlock*blockSize*(xArea-1)
    local x1 = x2-blockSize+1
    local y2 = yBlock * blockSize + lineBlock*blockSize*(yArea-1)
    local y1 = y2-blockSize+1

    return x2,y2,x1,y1
end

-- 获取可被刷新叛军的所有的空地图ID,一个区块的空地大约在25000个左右
local function getVacancyArea(area)
    for i=1,10 do
        local x, y, minx, miny = getRangeByArea(area)

        local sql = "select id,x,y from map where type=0 and x>=:minx and x<=:x and y>=:miny and y<=:y"
        local result = getDbo():getAllRows(sql, { x = x, y = y, minx = minx, miny = miny })

        if next(result) then
            return result
        end
    end
end

-- 按判军世界经验获取本次刷新的叛军等级分布区间
-- param int exp 叛军世界经验
-- return int,int 最小等级,最大等级
local function getLevelRangeByExp(exp)
    local level = 0

    local rebelCfg = getRebelCfg()
    for k, v in pairs(rebelCfg.levelExp) do
        if exp >= v then
            level = k
        else
            break
        end
    end

    local minLv = level + rebelCfg.levelRange[1]
    local maxLv = level + rebelCfg.levelRange[2]

    if minLv < 1 then minLv = 1 end
    if maxLv > #rebelCfg.levelExp then maxLv = #rebelCfg.levelExp end

    return {minLv, maxLv}
end

-- 按叛军等级获取分配方案key
-- param int level 叛军等级
-- return int forceKey 配置中的随机叛军部队库标识
local function getForceByLevel(level)
    local rebelCfg = getRebelCfg()
    local forceKey = 1

    for k, v in pairs(rebelCfg.troops.tanklv) do
        if level >= v then
            forceKey = k
        else
            break
        end
    end

    return forceKey
end

-- 获取叛军坦克部队的随机范围
-- param int forceKey 生成坦克部队的配置方案库的标识,这个库下面会有一堆坦克配置,需要随机出一个
local function getTankRange(forceKey)
    local rebelCfg = getRebelCfg()
    return 1, #rebelCfg.troops.tank[forceKey]
end

-- 获取单个坦克的血量
-- param string tankId 坦克
local function getSingleTankHp(tankId, rebelLv, tankCfg, rebelCfg)
    return math.ceil((tankCfg[tankId].life + rebelCfg.troops.attributeUp2[rebelLv].life) * rebelCfg.troops.attributeUp[rebelLv].life)
end

-- 按剩余血量计算出当前剩余的部队数
-- param int tankId
-- param int rebelLv 叛军等级
-- param int hp 剩余血量
-- return int 坦克数量
local function getTankNumByHp(tankId, rebelLv, hp)
    local num = 0

    if hp > 0 then
        local rebelCfg = getRebelCfg()
        local tankCfg = getConfig("tank")
        local tankHp = getSingleTankHp(tankId, rebelLv, tankCfg, rebelCfg)

        num = math.ceil(hp / tankHp)
    end

    return num
end

-- 获取战斗用的实际部队
-- param int rebelLv 叛军等级
-- param int force 部队标识
-- return table
local function getTroops(rebelLv, force)
    local troops = {}

    local rebelCfg = getRebelCfg()
    local forceKey = getForceByLevel(rebelLv)

    for k, v in pairs(rebelCfg.troops.tank[forceKey][force][2]) do
        troops[k] = { v, rebelCfg.troops.nums[rebelLv][k] }
    end

    return troops
end

-- 获取血量信息
-- param int rebelLv 叛军等级
-- param int forceKey 部队库标识
-- param int force 实际部队标识
-- return table 血量信息 maxHp:总血量,hp1-hp6分别对应6个部位的坦克血量,hp:当前血量
local function getHpInfo(rebelLv, forceKey, force)
    local hpInfo = {
        maxHp = 0
    }

    local rebelCfg = getRebelCfg()
    local tankCfg = getConfig("tank")
    for k, v in pairs(rebelCfg.troops.tank[forceKey][force][2]) do
        hpInfo[slot2HpKey[k]] = getSingleTankHp(v, rebelLv, tankCfg, rebelCfg) * rebelCfg.troops.nums[rebelLv][k]
        hpInfo.maxHp = hpInfo.maxHp + hpInfo[slot2HpKey[k]]
    end

    hpInfo.hp = hpInfo.maxHp

    return hpInfo
end

-- 按世界经验随机获取叛军的等级,部队标识,血量信息
-- 不同等级段对应的部队库不一样
-- param table levelRange 等级范围
local function randRebelInfo(levelRange)
    local rebelCfg = getRebelCfg()

    local level = rand(levelRange[1],levelRange[2])
    local forceKey = getForceByLevel(level)
    local force = rand(getTankRange(forceKey))
    local hpInfo = getHpInfo(level, forceKey, force)

    return level, force, hpInfo
end

-- 保存叛军地图数据
local function setRebelMap(mapId, mapx, mapy, level, force, hpInfo, expireTs)
    local data = {
        troops = force,
        level = level,
        expireTs = expireTs,
        x = mapx,
        y = mapy,
    }

    for k, v in pairs(hpInfo) do
        data[k] = v
    end

    data = json.encode(data)

    local sql = string.format("update map set type='%d',level='%d',data='%s',protect='%d',oid=0 where type=0 and id = %d limit 1", rebelMapType, level, data, expireTs, mapId)

    return getDbo():query(sql)
end

-- 按实际部队替换掉奖励中待定的部分
local function replaceReward(level, force, reward)
    local forceKey = getForceByLevel(level)
    for k, v in pairs(rebelCfg.troops.tank[forceKey][force][1]) do
        local repKey = "tank" .. k
        if reward[repKey] then
            reward[v] = reward[repKey]
            reward[repKey] = nil
        end
    end

    return reward
end

--[[
    获取击杀标识

    param int deHp 本次减的血量
    param int currHp 后完血后的当前血量
    return int 0是未被击杀,1是被自己击杀,2是已被别人击杀
]]
local function getKillFlag(deHp, currHp)
    local flag = 0
    if currHp <= 0 then
        if currHp + deHp > 0 then
            flag = 1
        else
            flag = 2
        end
    end

    return flag
end

-- 转换一下叛军属性值的类型
-- 目前所有value都是number类型的,以后有别的类型的话,再额外处理
local function convInfoValType(rebelInfo)
    for k, v in pairs(rebelInfo) do
        rebelInfo[k] = tonumber(v) or 0
        if rebelInfo[k] < 0 then
            rebelInfo[k] = 0
        end
    end
end

-- 击杀叛军时增加世界叛军经验
function rebel.addKillExp(expireTs)
    local rebelCfg = getRebelCfg()
    local exp = math.ceil(rebelCfg.maxAddExp * (expireTs - getClientTs()) / rebelCfg.expireTs)
    if exp <= 0 then exp = 1 end

    setExp(exp)
end

--[[
    获取叛军信息
    param int mid 地图id
    return table :
        ["force"] = 2, 部队标识
        ["hp"] = 770, 当前血量
        ["maxHp"] = 770, 总血量
        ["hp1"] = 110,(hp1-hp6分别对应6个部位的血量)
        ["level"] = 2, 等级
        ["expireTs"] = 1484575158, 过期时间
        ["troops"] = {...}, 部队数
        ["x"] 坐标x
        ["y"] 坐标y
        [isDie] 是否已经死亡,有此属性表示已经死亡
            1.不存在
            2.已过期
            3.血量为0
]]
function rebel.getRebelInfo(mid)
    if not rebelMapData[mid] then
        local rebelInfo = getRebelInfoFromRedis(mid)
        if not next(rebelInfo) then
            local mapData = getRebelInfoFromDb(mid)
            if mapData then
                rebelInfo = copyTable(mapData.data)
                setRebelInfoToRedis(mid, rebelInfo)
            end
        end

        convInfoValType(rebelInfo)
        originalMapData[mid] = copyTable(rebelInfo)

        -- 按血量转换实际部队
        if next(rebelInfo) then
            local force = rebelInfo.troops
            rebelInfo.force = force
            rebelInfo.troops = getTroops(rebelInfo.level, force)

            for k, v in pairs(slot2HpKey) do
                rebelInfo.troops[k][2] = getTankNumByHp(rebelInfo.troops[k][1], rebelInfo.level, rebelInfo[v])
            end
        end

        if not rebelInfo.hp or tonumber(rebelInfo.hp) <= 0 or rebelInfo.expireTs <= getClientTs() then
            rebelInfo.isDie = rebelInfo.isDie or 1
        else
            rebelInfo.isDie = nil
        end

        rebelInfo.mapType = rebelMapType

        rebelMapData[mid] = rebelInfo
    end

    return rebelMapData[mid]
end

-- 更新血量信息
local function setRebelHp(mid,currentHp)
    local hpName = nil
    for k,v in pairs(currentHp) do
        hpName = slot2HpKey[k] or k

        rebelMapData[mid][hpName] = tonumber(v) or 0
        originalMapData[mid][hpName] = tonumber(v) or 0
    end
end

--[[
    扣除叛军的血量,并将当前叛军(血量)信息入库

    param mid 地图id(叛军标识id)
    param table hpInfo 本次每个部位的扣血信息,6个坦克部位,总扣血量hp
        example : {[1]=10,[2]=10,...,[6]=10,hp=60}
    param int alliance 攻击的军团id

    return int,table 击杀标识(参见getKillFlag),剩余血量,扣血后各部位的当前血量
]]
function rebel.deHp(mid, hpInfo, alliance)
    local currHpInfo = {}
    hpInfo.hp = 0

    local redis = getRedis()
    local cacheKey = mkCacheKey("rebelForcesMap", mid)

    -- 扣除每个部位的伤害血量
    for k, v in pairs(slot2HpKey) do
        if hpInfo[k] and hpInfo[k] > 0 then
            hpInfo[k] = math.ceil(hpInfo[k])
            currHpInfo[k] = redis:hincrby(cacheKey, v, -hpInfo[k])
    
            -- 单个部位扣的血量会算到总扣血量,这个时候要注意并发
            -- 比如本次合法扣除1000的血,实际这个部位的坦克血量只有100,扣完后的血量就会是-900,即多扣了900
            -- 伤害值应该减去多扣的900,就是1000-900 -> 1000 + (-900)
            local num = hpInfo[k]
            if currHpInfo[k] < 0 then
                num = num + currHpInfo[k]
                if num < 0 then num = 0 end
            end

            -- 每个部位的伤害血量之和为本次伤害的总血量
            hpInfo.hp = hpInfo.hp + num
        end
    end
    
    -- 扣除本次总伤害血量,得到当前剩余血量
    currHpInfo.hp = tonumber(redis:hincrby(cacheKey, "hp", -hpInfo.hp))

    local killFlag = getKillFlag(hpInfo.hp, currHpInfo.hp)

    -- 更新击杀标识
    if killFlag == 1 then
        rebelMapData[mid].isDie = 1
        redis:hset(cacheKey, "isDie", alliance)
    end

    -- 更新血量信息
    setRebelHp(mid,currHpInfo)

    -- 更新数据库,这里用原数据来更新,因为本地缓步的mapData信息格式有变化
    setRebelInfoToDb(mid, originalMapData[mid])

    return killFlag, hpInfo.hp, currHpInfo.hp
end

-- 获取攻击的相关配置
function rebel.getAttackCfg(attackType)
    local cfg = {}
    local rebelCfg = getRebelCfg()

    -- 普通攻击
    if attackType == 1 then
        cfg.attackConsume = rebelCfg.attackConsume1
        cfg.dmgUp = 1
        -- 高级攻击
    elseif attackType == 2 then
        cfg.attackConsume = rebelCfg.attackConsume2
        cfg.dmgUp = rebelCfg.highAttack
    end

    return cfg
end

-- 初始化攻击属性
function rebel.initDefFleetAttribute(tanks, level, landform, rebelInfo)
    local rebelCfg = getRebelCfg()
    local attributeUp = rebelCfg.troops.attributeUp[level]
    local attributeUp2 = rebelCfg.troops.attributeUp2[level]

    local inittanks = initTankAttribute(tanks, nil, nil, nil, nil, 0, { landform = landform, acAttributeUp = attributeUp, acAttributeUp2 = attributeUp2, attrUpFlag = true })

    -- local force = 1
    -- local forceKey = getForceByLevel(level)
    -- local hpinfo = getHpInfo(level, forceKey, force)

    -- 这里的血量用叛军中剩余的血量替换一下,
    -- init属性时,总血量是直接拿当前单体血量*数量算出来的,叛军的单体血量减少之后会存下来,
    -- 如果这里不替换的话单体受伤后相当于血又满了
    for k,v in pairs(inittanks) do
        if next(v) then
            if v.hp - rebelInfo[slot2HpKey[k]] <= v.maxhp then
                v.hp = rebelInfo[slot2HpKey[k]]
            end
        end
    end

    return inittanks
end

-- 获取击杀奖励
function rebel.getKillReward(level, force)
    local rebelCfg = getRebelCfg()
    local reward = copyTable(rebelCfg.troops.reward3[level])

    return replaceReward(level, force, reward)
end

-- 获取战斗奖励
-- 1.固定得到一个奖励
-- 2.按伤害值造成的百分比评级,按级别数作为随机次数得到实际奖励
function rebel.getBattleReward(dmgHp, rebelHp, level, force)
    local rebelCfg = getRebelCfg()
    local reward = getRewardByPool(rebelCfg.troops.reward1[level])

    local per = dmgHp / rebelHp * 100
    local grade = 0

    for k, v in pairs(rebelCfg.troops.needDamage[level]) do
        if per >= v then
            grade = k
        else
            break
        end
    end

    for i = 1, grade do
        local rd = getRewardByPool(rebelCfg.troops.reward2[level])
        for k, v in pairs(rd) do
            reward[k] = (reward[k] or 0) + v
        end
    end

    reward = replaceReward(level, force, reward)

    return reward
end

-- 能否刷新
function rebel.canRefresh()
    local rebelCfg = getConfig("rebelCfg")
    local lastTs = getLastRefreshTs()
    local admissible = 60

    if getClientTs() - lastTs >= (rebelCfg.refreshTime - admissible) then
        return true
    end
end

--[[
    刷新叛军
]]
function rebel.refreshRebelForces()
    -- 世界经验保存到数据库中
    saveExpToDb()

    local rebelCfg = getConfig("rebelCfg")
    local area = getRebelArea()
    
    -- 过期时间
    local expireTs = getClientTs() + rebelCfg.expireTs

    local exp = getExpFromRedis()
    local levelRange = getLevelRangeByExp(exp)

    local newRebels = {}
    for i = 1, rebelCfg.rebelNum do
        -- 获取空区域
        local vacancyArea = getVacancyArea(area)
        if vacancyArea then
            for j=1,10 do
                local flag
                local rd = rand(1, #vacancyArea)
                if commonLock(tostring(vacancyArea[rd]['id']),"maplock") then
                    local lv, force, hpInfo = randRebelInfo(levelRange)
                    setRebelMap(tonumber(vacancyArea[rd]['id']), vacancyArea[rd]['x'], vacancyArea[rd]['y'], lv, force, hpInfo, expireTs)
                    deleteCache(vacancyArea[rd]['id'])
                    table.insert(newRebels, vacancyArea[rd])
                    commonUnlock(tostring(vacancyArea[rd]['id']),"maplock")
                    flag = true
                end

                -- 移除已被处理过的区域
                vacancyArea[rd] = vacancyArea[#vacancyArea]
                table.remove(vacancyArea)

                if flag then break end
            end
        end
    end
    
    vacancyArea = nil

    return newRebels
end

-- 清除过期的叛军
-- 叛军被击杀后地图数据会被清掉,因此这里可以获取到未击杀的叛军数量,然后降低世界经验
function rebel.cleanExpireRebeForces()
    local db = getDbo()
    local ts = getClientTs() + 60
    local query = string.format("update map set type=0,protect=0,data='',level=0 where oid=0 and type = '%s' and protect <= '%s'", rebelMapType, ts)
    -- local query = string.format("update map set type=0,protect=0,data='',level=0 where type = '%s'", rebelMapType, getClientTs())
    local count = db:query(query)

    count = tonumber(count) or 0
    if count > 0 then
        local rebelCfg = getConfig("rebelCfg")
        local reduceExp = rebelCfg.reduceExp * count

        -- 世界经验降低
        local cExp = setExp(-reduceExp)

        return count,cExp,reduceExp
    end

    return count
end

-- 格式化map数据给前端
function rebel.formatMapData(mapData)
    mapData.name = mapData.data.troops
    mapData.power = mapData.data.maxHp
    mapData.rank = mapData.data.hp
end

-- 获取叛军的世界经验
function rebel.getWorldExp()
    return getExpFromRedis()
end

-- 设置叛军的世界经验
function rebel.setWorldExp(exp)
    return setExp(exp)
end

-- 为伟大航线创建NPC
-- return 叛军等级，叛军库编号，叛军编号
function rebel.createForGreatRoute(level)
    local rebelCfg = getRebelCfg()
    local forceKey = getForceByLevel(level)
    local force = rand(getTankRange(forceKey))

    return level, forceKey, force
end

function rebel.getGreatRouteRebelInfo(level,forceKey,force)
    local rebelCfg = getRebelCfg()

    local troops = {}
    for k, v in pairs(rebelCfg.troops.tank[forceKey][force][2]) do
        troops[k] = { v, rebelCfg.troops.nums[level][k] }
    end

    local attributeUp = rebelCfg.troops.attributeUp[level]
    local attributeUp2 = rebelCfg.troops.attributeUp2[level]

    local inittanks = initTankAttribute(troops, nil, nil, nil, nil, 0, { acAttributeUp = attributeUp, acAttributeUp2 = attributeUp2, attrUpFlag = true })

    return troops, inittanks, rebelCfg.startDamage
end

function rebel.init()
    rebelMapData = {}
    originalMapData = {}
end

return rebel