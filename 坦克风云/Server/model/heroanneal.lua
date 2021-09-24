--[[
    将领试炼 刷新地图坐标任务
]]
local Anneal = {}

-- 缓存key
local cacheKeys = {
    annealForcesMap="z%.AnnealForcesMap.%s"
}

local AnnealMapData = {}
local originalMapData = {}

-- 将领试炼地图类型
local AnnealMapType = 8

-- 部队槽位对应的血量key
local slot2HpKey = { "hp1", "hp2", "hp3", "hp4", "hp5", "hp6" }


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

-- 获取试炼任务的配置
local function getAnnealCfg()
    if not annealCfg then
        annealCfg = getConfig("heroAnnealCfg")
    end

    return annealCfg
end

-- 获取本次刷新试炼任务的大区域
-- 刷新区域划为9大块,每次刷新时随机出一个大地块
local function getAnnealArea()
    setRandSeed()
    return rand(1, 9)
end

-- 获取刷新地块的实际边界值
-- param int area 地块id(1-9)
-- local function getRangeByArea(area)
--     -- 5*5 * 1600 * 9 = 360000
--     local size = 5
--     local landBlock = 1600

--     local maxLandBlock = size*size * 1600 * area

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

-- 获取刷新地块的实际边界值
-- param int area 地块id(1-9)
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

-- 获取可被刷新试炼任务的所有的空地图ID,一个区块的空地大约在25000个左右
local function getVacancyArea()
    local area = getAnnealArea()
    for i=1,10 do
        local x, y, minx, miny = getRangeByArea(area)

        local sql = "select id,x,y from map where type=0 and x>=:minx and x<=:x and y>=:miny and y<=:y"
        local result = getDbo():getAllRows(sql, { x = x, y = y, minx = minx, miny = miny })

        if next(result) then
            return result
        end
    end
end

-- 获取单个坦克的血量
-- param string tankId 坦克
local function getSingleTankHp(tankId, AnnealLv, tankCfg, AnnealCfg)
    return math.floor(tankCfg[tankId].life * AnnealCfg.troops[AnnealLv].attributeUp.life * AnnealCfg.troops[AnnealLv].modulusAtt[Anneal.quality] )
end

-- 按剩余血量计算出当前剩余的部队数
-- param int tankId
-- param int AnnealLv 试炼任务等级
-- param int hp 剩余血量
-- return int 坦克数量
local function getTankNumByHp(tankId, AnnealLv, hp)
    local num = 0

    if hp > 0 then
        local AnnealCfg = getAnnealCfg()
        local tankCfg = getConfig("tank")
        local tankHp = getSingleTankHp(tankId, AnnealLv, tankCfg, AnnealCfg)

        num = math.ceil(hp / tankHp)
    end

    return num
end

local function initAnnealData()
    if not Anneal.quality then
        local uid = Anneal.uid
        local tid = Anneal.tid
        local uobjs = getUserObjs(uid)
        local mHero = uobjs.getModel('hero')
        local mUserinfo = uobjs.getModel('userinfo')
        local task = nil
        if type(mHero.anneal.l) == 'table' and tid then
            task = string.split(mHero.anneal.l[tid], "_")
            Anneal.task = mHero.anneal.l[tid]
        else
            task = string.split(mHero.anneal.t.task, "_")
            Anneal.task = mHero.anneal.t.task
        end

        if type(task) == 'table' and task[2] then
            Anneal.quality = tonumber(task[2])
        end

        Anneal.name = mUserinfo.nickname
        Anneal.aid = mUserinfo.alliance
        Anneal.level = mUserinfo.level
    end
end

-- 获取战斗用的实际部队
-- return table
local function getTroopsCfg()
    initAnnealData()
    local AnnealCfg = getAnnealCfg()
    local level = Anneal.level
    local troops = {}
    local rateNum = AnnealCfg.troops[level].modulusTank[Anneal.quality]
    for k, v in pairs( AnnealCfg.troops[level].tank ) do
        troops[k] = {v[1], math.ceil(v[2] * rateNum)}
    end  
    --writeLog({troops=troops, rateNum=rateNum, quality=Anneal.quality, level=level}, 'hanneal')
    return troops
end

-- 获取血量信息
-- return table 血量信息 maxHp:总血量,hp1-hp6分别对应6个部位的坦克血量,hp:当前血量
local function getHpInfo(force)
    local hpInfo = {
        maxHp = 0
    }
    local AnnealLv = Anneal.level
    local AnnealCfg = getAnnealCfg()
    local tankCfg = getConfig("tank")
    for k, v in pairs(force) do
        hpInfo[slot2HpKey[k]] = getSingleTankHp(v[1], AnnealLv, tankCfg, AnnealCfg) * v[2]
        hpInfo.maxHp = hpInfo.maxHp + hpInfo[slot2HpKey[k]]
    end

    hpInfo.hp = hpInfo.maxHp

    return hpInfo
end

-- 保存试炼任务地图数据
local function setAnnealMap(mapId, mapx, mapy, level, hpInfo, expireTs)
    local data = {
        oid = Anneal.uid,
        level = level,
        expireTs = expireTs,
        x = mapx,
        y = mapy,
        task = Anneal.task,
        aid = Anneal.aid,
        name = Anneal.name, 
    }

    for k, v in pairs(hpInfo) do
        data[k] = v
    end

    data = json.encode(data)

    local sql = string.format("update map set type='%d',level='%d',data='%s',protect='%d' where type=0 and id = %d limit 1", AnnealMapType, level, data, expireTs, mapId)

    local ret = getDbo():query(sql)

    return ret and tonumber(ret) > 0
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

-- 转换一下试炼任务属性值的类型
local function convInfoValType(AnnealInfo)
    for k, v in pairs(AnnealInfo) do
        AnnealInfo[k] = tonumber(v) or v
        if type(AnnealInfo[k]) == 'number' and AnnealInfo[k] < 0 then
            AnnealInfo[k] = 0
        end
    end
end

-- 从地图数据库中获取指定试炼任务的信息
local function getAnnealInfoFromDb(mid)
    local mMap = require 'lib.map'
    local data = mMap:getMapById(mid)

    -- 判断地图类型和过期时间,protect在试炼任务中指过期时间
    if type(data) == "table" and tonumber(data.protect) > getClientTs() and tonumber(data.type) == AnnealMapType then
        return data
    end
end

-- 从缓存中获取指定试炼任务的信息
local function getAnnealInfoFromRedis(mid)
    local key = mkCacheKey("annealForcesMap", mid)
    return getRedis():hgetall(key)
end

-- 保存指定试炼任务信息到缓存
local function setAnnealInfoToRedis(mid, info)
    if next(info) then
        local redis = getRedis()
        local key = mkCacheKey("annealForcesMap", mid)
        redis:hmset(key, info)
        redis:expire(key, info.expireTs - getClientTs() )
    end
end

-- 保存指定试炼信息到map地图数据库
local function setAnnealInfoToDb(mid, data)
    local params = { data = data }
    local mMap = require 'lib.map'

    -- 如果任务已经完成,清除地图
    if (tonumber(data.hp) or 0) <= 0 then
        return mMap:format(mid, true)
    end

    return mMap:update(mid, params)
end

--[[
    获取试炼任务信息
    param int mid 地图id
    return table :
        ["hp"] = 770, 当前血量
        ["maxHp"] = 770, 总血量
        ["hp1"] = 110,(hp1-hp6分别对应6个部位的血量)
        ["level"] = 2, 等级
        ["expireTs"] = 1484575158, 过期时间
        ["x"] 坐标x
        ["y"] 坐标y
        [isDie] 是否已经死亡,有此属性表示已经死亡
            1.不存在
            2.已过期
            3.血量为0
        (map.data内容)
]]
function Anneal.getAnnealInfo(mid)
    if not AnnealMapData[mid] then
        local AnnealInfo = getAnnealInfoFromRedis(mid)
        if not next(AnnealInfo) then
            local mapData = getAnnealInfoFromDb(mid)
            if mapData then
                AnnealInfo = copyTable(mapData.data)
                setAnnealInfoToRedis(mid, AnnealInfo)
            end
        end

        convInfoValType(AnnealInfo)
        originalMapData[mid] = copyTable(AnnealInfo)

        -- 按血量转换实际部队
        if next(AnnealInfo) then
            AnnealInfo.troops = getTroopsCfg()

            --刷新当前数量
            for k, v in pairs(slot2HpKey) do
                AnnealInfo.troops[k][2] = getTankNumByHp(AnnealInfo.troops[k][1], AnnealInfo.level, AnnealInfo[v])
            end
        end

        if not AnnealInfo.hp or tonumber(AnnealInfo.hp) <= 0 or AnnealInfo.expireTs <= getClientTs() then
            AnnealInfo.isDie = AnnealInfo.isDie or 1
        else
            AnnealInfo.isDie = nil
        end

        AnnealInfo.mapType = AnnealMapType

        AnnealMapData[mid] = AnnealInfo
    end

    return AnnealMapData[mid]
end

-- 更新血量信息
local function setAnnealHp(mid,currentHp)
    local hpName = nil
    for k,v in pairs(currentHp) do
        hpName = slot2HpKey[k] or k

        AnnealMapData[mid][hpName] = tonumber(v) or 0
        originalMapData[mid][hpName] = tonumber(v) or 0
    end
end

--[[
    扣除试炼任务的血量,并将当前试炼任务(血量)信息入库

    param mid 地图id(试炼任务标识id)
    param table hpInfo 本次每个部位的扣血信息,6个坦克部位,总扣血量hp
        example : {[1]=10,[2]=10,...,[6]=10,hp=60}
    param int alliance 攻击的军团id

    return int,table 击杀标识(参见getKillFlag),剩余血量,扣血后各部位的当前血量
]]
function Anneal.deHp(mid, hpInfo, alliance)
    local currHpInfo = {}
    hpInfo.hp = 0

    local redis = getRedis()
    local cacheKey = mkCacheKey("annealForcesMap", mid)

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
        AnnealMapData[mid].isDie = 1
        redis:hset(cacheKey, "isDie", alliance)
    end

    -- 更新血量信息
    setAnnealHp(mid,currHpInfo)

    -- 更新数据库,这里用原数据来更新,因为本地缓步的mapData信息格式有变化
    setAnnealInfoToDb(mid, originalMapData[mid])

    return killFlag, hpInfo.hp, currHpInfo.hp
end

-- 初始化攻击属性
function Anneal.initDefFleetAttribute(tanks, level, landform, AnnealInfo)
    initAnnealData()
    local AnnealCfg = getAnnealCfg()
    local attributeUp = copyTable(AnnealCfg.troops[level].attributeUp)   
    for k, v in pairs(attributeUp) do
        attributeUp[k] = v * AnnealCfg.troops[level].modulusAtt[Anneal.quality]
    end

    local skills =  copyTable(AnnealCfg.troops[level].skill)
    for k, v in pairs(skills) do
        skills[k] = v * AnnealCfg.troops[level].modulusSkill[Anneal.quality]
    end

    local inittanks = initTankAttribute(tanks, nil, skills, nil, nil, 0, {landform = landform, acAttributeUp = attributeUp, attrUpFlag = true })

    -- 这里的血量用试炼任务中剩余的血量替换一下,
    -- init属性时,总血量是直接拿当前单体血量*数量算出来的,试炼任务的单体血量减少之后会存下来,
    -- 如果这里不替换的话单体受伤后相当于血又满了
    for k,v in pairs(inittanks) do
        if next(v) then
            if v.hp - AnnealInfo[slot2HpKey[k]] <= v.maxhp then
                v.hp = AnnealInfo[slot2HpKey[k]]
            end
        end
    end

    return inittanks
end

--[[
    刷新试炼任务
]]
function Anneal.refreshAnneal()
    local AnnealCfg = getAnnealCfg()
    local expireTs = getClientTs() + AnnealCfg.survivalTime -- 过期时间
    -- 全地图随机
    local vacancyArea = getVacancyArea()
    if not vacancyArea then return false end

    for j=1,10 do
        local rd = rand(1, #vacancyArea)
        local hpInfo = getHpInfo( getTroopsCfg() )
        if not hpInfo then
            return false
        end

        if commonLock(tostring(vacancyArea[rd]['id']),"maplock") then
            local ret = setAnnealMap(tonumber(vacancyArea[rd]['id']), vacancyArea[rd]['x'], vacancyArea[rd]['y'], Anneal.level, hpInfo, expireTs)
            commonUnlock(tostring(vacancyArea[rd]['id']),"maplock")
            
            if ret then
                return {vacancyArea[rd]['x'], vacancyArea[rd]['y'], expireTs, hpInfo.hp, hpInfo.maxHp, Anneal.level}
            end
        end

        -- 移除已被处理过的区域
        vacancyArea[rd] = vacancyArea[#vacancyArea]
        table.remove(vacancyArea)
    end
end

-- 格式化map数据给前端
function Anneal.formatMapData(mapData)
    -- 军团id会变动
    local uobjs = getUserObjs(tonumber(mapData.data.oid) or 0, true)
    if uobjs then
        mUserinfo = uobjs.getModel('userinfo')
        mapData.data.aid = mUserinfo.alliance or 0
    end

    mapData.oid = mapData.data.oid
    mapData.power = mapData.data.maxHp
    mapData.rank = mapData.data.hp
    mapData.pic = mapData.data.aid  
    mapData.name = mapData.data.name
    mapData.alliance = mapData.data.task
end

-- 清除过期数据
function Anneal.clearAnnealData()
    local ts = getClientTs()
    local db = getDbo()
    local query = string.format("update map set type=0,protect=0,data='',level=0 where oid=0 and type = '%s' and protect <= '%s' ", AnnealMapType, ts)
    local count = db:query(query)
    if count > 0 then
        print('clean anneal data :', count)
    end
    return count
end

function Anneal.init(params)
    Anneal.uid=params.uid -- 该玩家的试炼任务
    Anneal.tid=params.tid -- taskid 接受任务的时候用(获取任务品质)

    --全局变量
    AnnealMapData = {}
    originalMapData = {}
    Anneal.quality = nil 
    Anneal.name = nil
    Anneal.aid = nil
    Anneal.level = nil
    Anneal.task = nil
end

return Anneal
