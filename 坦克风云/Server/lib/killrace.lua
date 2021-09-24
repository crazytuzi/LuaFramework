--[[
    击杀赛
]]
local killraceStatus = {
    CLOSE=0, --关闭
    BATTLE=1, -- 战斗期
    OFF=2, -- 休赛期
    RESET=3, -- 重置期
}

local killrace = {
    -- 开始时间
    st = 0,
    -- 结束时间
    et = 0,
    -- 当前赛季信息,重新设置赛季init时，判断是否跨天了，否则，没必要
    season = 0,
    sinfo = {
        st=0, -- 起始时间
        et=0, -- 结束时间
        status = killraceStatus.CLOSE, -- 赛季状态
        season_offset = 0, -- 偏移
    },
    -- 段位镜像库中镜像的数量
    grade2ImageNums = {},
}

-- 缓存key
local cacheKeys = {
    -- 赛季信息
    hashkillraceInfo = "z%s.killrace.info", -- zid
    -- 镜像key
    hashImageData = "z%s.killrace.image.%s.%s.%s", -- zid,season,season_st,grade
    -- 镜像用户标识
    setImageUid = "z%s.killrace.imageUid.%s.%s.%s", -- zid,season,season_st,grade
    -- 段位排行
    zsetGradeRankList = "z%s.killrace.ranking.grade.%s.%s.%s.%s", -- zid,season,season_st,grade,queue
    -- 总击杀排行
    zsetTotalKilledRankList = "z%s.killrace.ranking.totalkilled.%s.%s", -- zid,season,season_st
    -- 战损率排行榜
    zsetDmgRateKilledRankList = "z%s.killrace.ranking.dmgrate.%s.%s", -- zid,season,season_st
}

-- 所有表名
local tbNames = {
    -- 镜像表
    image = "killrace_image",
    -- 赛季信息
    season = "killrace_season",
    -- 战报
    battlelog = "killrace_battlelog",
    -- 兑换日志
    changelog = "killrace_changelog",
    -- 用户表
    user = "userkillrace",
}

-- 排行榜长度
local rankingListLength = 100

-- 击杀榜上榜分数
local killedRankingScoreLimit = 1000

-- 击杀赛配置文件
local killRaceCfg = nil
local killRaceVerCfg = nil

-- 赛季分钟数(这个用来作排行用),分一样，按时间排序
local sMinute = 40320 -- 28*24*3600/60 

--[[
    生成标识key
]]
local function mkKey(...)
    return table.concat({ ... }, '-')
end

-- 生成缓存key
local function mkCacheKey(cacheKey, ...)
    if cacheKeys[cacheKey] then
        return string.format(cacheKeys[cacheKey], getZoneId(), killrace.season,killrace.sinfo.st, ...)
    end
end

-- 获取当前距离开赛起始时间的分钟数
local function getCurMin(ts)
    ts = ts or os.time()
    local minute = (ts - killrace.sinfo.st) / 60
    if minute > sMinute then
        return sMinute
    end

    return minute
end

--[[
    生成排行用的分数(分数.分钟)
        分数一样时，分钟
]]
local function mkRankingScore(score)
    local minute = getCurMin()
    return tonumber(string.format("%d.%d",score,sMinute-minute))
end

-- 获取击杀赛的配置
local function getRaceCfg()
    if not killRaceCfg then
        killRaceCfg = getConfig("killRaceCfg")
    end

    return killRaceCfg
end

--[[
    获取赛季配置
    前几赛季取简单配置,以后取复杂配置
    配置文件以killRaceVer拼上赛季数命名
]]
local function getRaceVerCfg()
    if not killRaceVerCfg then
        local ver = 1
        local killRaceCfg = getRaceCfg()
        for i=#killRaceCfg.seasonCfg,1,-1 do
            if killrace.season >= killRaceCfg.seasonCfg[i] then 
                ver = killRaceCfg.seasonCfg[i]
                break
            end
        end

        killRaceVerCfg = getConfig(string.format("killRaceVer%dCfg",ver))
    end

    return killRaceVerCfg
end

-- 格式化镜像数据
-- return [昵称,等级,头像,大段位,小段位,战损率,战力,部队]
local function formatImageData(data)
    return {
        data.nickname or "",
        tonumber(data.level) or 1,
        tonumber(data.pic) or 0,
        tonumber(data.grade) or 1,
        tonumber(data.queue) or 1,
        tonumber(data.dmgrate) or 0,
        tonumber(data.fight) or 1,
        data.troops,
        tostring(data.bpic or ""),
        tostring(data.apic or ""),
    }
end

-- 从数据库获取赛季信息
local function getRaceInfoFromDb()
    local sql = string.format("select id,st,et,season,season_st,season_et,season_reset,season_offset from %s where st > 0 and st <= :ts and et > :ts limit 1",tbNames.season)
    local result = getDbo():getRow(sql, { ts = os.time() })
    return result
end

--[[
    从缓存获取赛季数据
        缓存没有,读库,塞进缓存
]]
local function getRaceData()
    local ckey = mkCacheKey("hashkillraceInfo")
    local redis = getRedis()
    local data = redis:hgetall(ckey)
    if not next(data) then
        data = getRaceInfoFromDb()
        if data then
            redis:hmset(ckey,data)
        else
            -- 数据库也无数据时占位,防止一直查库
            redis:hmset(ckey,{et=0})
        end
    end

    if data then 
        for k,v in pairs(data) do 
            data[k] = tonumber(v) 
        end 
    end

    return data
end

-- 从数据库读取镜像
local function getImageFromDb(grade,uid)
    local sql = string.format("select uid,level,grade,queue,pic,dmgrate,nickname,fight,troops from %s where grade = :grade and uid = :uid limit 1",tbNames.image)
    local data = getDbo():getRow(sql, { uid = uid,grade = grade })

    if data then 
        data.troops = json.decode(data.troops) 
    end

    return data
end

-- 从库读取对应大段位的所有镜像
local function getImagesByGrade(grade)
    local sql = string.format("select uid,level,grade,queue,pic,dmgrate,nickname,fight,troops from %s where grade = :grade order by fight desc limit 200",tbNames.image)
    local data = getDbo():getAllRows(sql, { grade = grade })
    return data
end

local function updateImageToDb(image)
    getDbo():update(tbNames.image,image,{"uid","grade"})
end

-- 新增镜像到数据库
function killrace.addImage(data)
    data.updated_at = os.time()
    getDbo():insert(tbNames.image, data)
    killrace.updateImage(data.uid,data)
end

-- 设置所有镜像到缓存
local function setImagesToCache(ckey,grade)
    -- 初始1占位,防止一直读库
    local data = {["1"]=1}
    local uids = {1}
    local num = 1

    local images = getImagesByGrade(grade)

    if type(images) == "table" then
        for k,v in pairs(images) do
            v.troops = json.decode(v.troops)
            data[tonumber(v.uid)] = json.encode(formatImageData(v))
            table.insert(uids,tonumber(v.uid))
            num = num + 1
            v = nil
        end

        images = nil
        local redis = getRedis()

        -- 镜像uidkey设置到set里,方便随机返回
        redis:tk_sadd(mkCacheKey("setImageUid",grade),uids)

        -- 镜像数据
        redis:hmset(ckey,data)
    end

    return num
end

-- 获取镜像数
function killrace.getImageNum(gradeLevel)
    local isFull = false
    if killrace.grade2ImageNums[gradeLevel] then 
        return killrace.grade2ImageNums[gradeLevel],true
    end

    local ckey = mkCacheKey("hashImageData",gradeLevel)
    local redis = getRedis()
    local num = redis:hlen(ckey)
    if num == 0 then
        num = setImagesToCache(ckey,gradeLevel)
    end

    -- 因为缓存中有个key为1的占位数据,所以这里对数量减1
    num = num - 1

    local killRaceCfg = getRaceCfg()
    if num >= killRaceCfg.imageNum[1][gradeLevel] then
        killrace.grade2ImageNums[gradeLevel] = num
        isFull = true
    end

    return num,isFull
end

-- 更新镜像数据缓存
function killrace.updateImage(uid,data)
    local grade = data.grade
    updateImageToDb(data)

    data = formatImageData(data)
    if type(data) == "table" then
        data = json.encode(data)
    end

    local ckey = mkCacheKey("hashImageData",grade)
    local redis = getRedis()
    local ret = redis:hset(ckey,uid,data)
    if ret then
        redis:sadd(mkCacheKey("setImageUid",grade),uid)
    end

    return data
end

-- 按weight配置获取key
-- weight={100,190,290,380}
-- return 1-4
local function getKeyByWight(weight)
    local randnum = rand(1,weight[#weight])
    for i=#weight,1,-1 do
        if randnum > weight[i] then return i+1 end
    end

    return 1
end

-- NPC段位镜像等级配置
local npcLevelCfg = {
    {20,50},
    {30,60},
    {40,70},
    {70,90},
    {80,90},
}

--[[
    获取npc镜像
    npc镜像只按大段位来生成

    param int grade 大段位
    return table 统一格式化好的镜像信息
]]
local function getNpcImage(grade)
    local imageInfo = {
        nickname = '',
        pic = -1,
        level = 1,
        grade = grade,
        queue = 1,
        dmgrate = 0,
        fight = 0,
        troops = {},
    }

    local killRaceCfg = getRaceCfg()
    local killRaceVerCfg = getRaceVerCfg()
    local tankCfg = getConfig("tank")

    -- 昵称生成npc_n的方式,前端自己解析出昵称和图片
    imageInfo.nickname = string.format("npc_%d",os.time() - killrace.sinfo.st)

    setRandSeed()

    -- 随机出小段位和等级
    imageInfo.queue = rand(1,#killRaceVerCfg.groupMsg[grade])
    if npcLevelCfg[grade] then
        imageInfo.level = rand(npcLevelCfg[grade][1],npcLevelCfg[grade][2])
    end

    -- i记录低等船的组数
    local i=1

    for j=1,6 do
        local randnum = rand(1,killRaceVerCfg.npc[grade][1][1] + killRaceVerCfg.npc[grade][1][2])
        local troopsLv
        if randnum <= killRaceVerCfg.npc[grade][1][1] then
            troopsLv = killRaceVerCfg.groupMsg[grade][1].boatLimit[1]
            i = i + 1
        else
            troopsLv = killRaceVerCfg.groupMsg[grade][1].boatLimit[2]
        end

        local wightKey = getKeyByWight(killRaceCfg.troopsMsg[troopsLv].weight)
        local troopId = killRaceCfg.troopsMsg[troopsLv].servertroops[wightKey]
        table.insert(imageInfo.troops,troopId)
        imageInfo.fight = imageInfo.fight + tankCfg[troopId].Fighting * math.pow(killRaceCfg.troopsNum,0.7)
    end
    
    -- 按低等船的组数从配置得到镜像的战损率
    imageInfo.dmgrate = killRaceVerCfg.npc[grade][2][i]
    
    return formatImageData(imageInfo)
end

-- 获取镜像
local function getImage(grade,uid)
    local redis = getRedis()
    local ckey = mkCacheKey("hashImageData",grade)
    local data = redis:hget(ckey,uid)

    if not data then
        data = getImageFromDb(grade,uid)
        if data then
            data = killrace.updateImage(uid,data)
        end
    end

    return data
end

-- 匹配
function killrace.match(uid,grade)
    local imageInfo
    local killRaceCfg = getRaceCfg()
    local imageNum = killrace.getImageNum(grade)

    setRandSeed()
    local rate = 100
    -- 如果镜像数量少于配置数,按配置概率率决定本次是随到NPC还是人的镜像
    if imageNum <= killRaceCfg.imageCutNpc[1][grade] then
        rate = rand(1,100)
    end

    -- 选取玩家镜像
    if rate > killRaceCfg.imageCutNpc[2] then
        local redis = getRedis()
        local ckey = mkCacheKey("setImageUid",grade)

        -- 随机取出3个(1个占位,1个可能是自己)
        local imageIds = redis:srandmember(ckey,3)
        if type(imageIds) == "table" then
            if #imageIds > 0 then
                local t = {}
                for k,v in pairs(imageIds) do
                    if tonumber(v) ~= uid and tonumber(v) > 1 then
                        table.insert(t,v)
                    end
                end

                if #t > 0 then
                    -- 镜像是按uid顺序排列的,需要随机获取
                    imageInfo = getImage(grade,t[rand(1,#t)])
                end
            else
                -- 缓存无镜像(连占位的都没有),重新设置一下
                setImagesToCache(mkCacheKey("hashImageData",grade),grade)
            end
        end
    end

    -- 未取到镜像时获取NPC镜像
    if not imageInfo then
        imageInfo = getNpcImage(grade)
    end

    if type(imageInfo) ~= "table" then
        imageInfo = json.decode(imageInfo)
    end

    if type(imageInfo) == "table" and #imageInfo == 10 then
        return imageInfo
    end
end

--[[
    获取战斗天气和地形
        获取的结果要跟上一次配置的不一样
]]
function killrace.getWeatherAndOcean(weatherId,oceanId)
    setRandSeed()
    local killRaceCfg = getRaceCfg()
    local randWeatherId = rand(1,#killRaceCfg.weather)
    if randWeatherId == weatherId then
        randWeatherId = randWeatherId+1
        if randWeatherId > #killRaceCfg.weather then 
            randWeatherId = 1 
        end
    end

    local randOceanIdId = rand(1,#killRaceCfg.ocean)
    if randOceanIdId == oceanId then
        randOceanIdId = randOceanIdId+1
        if randOceanIdId > #killRaceCfg.ocean then
            randOceanIdId = 1
        end
    end

    return randWeatherId, randOceanIdId
end

-- 获取排行榜的长度
function killrace.getRankingListLen(grade,queue)
    local redis = getRedis()
    local ckey = mkCacheKey("zsetGradeRankList",grade,queue)
    return tonumber(redis:zcard(ckey))
end

--[[
    升阶检测
    如果排行榜数据丢了导致用户进榜数据错误,需要重新刷一下排行榜来修复这个问题
]]
function killrace.upgradeCheck(uid,grade,queue,nextGrade,nextQueue,score)
    local killRaceVerCfg = getRaceVerCfg()
    -- 下段的人数限制数
    local numLimit = killRaceVerCfg.groupMsg[nextGrade][nextQueue].numLimit
    -- 当前段位人数限制数
    local curNumLimit = killRaceVerCfg.groupMsg[grade][queue].numLimit
    -- 下一段位key
    local ckey = mkCacheKey("zsetGradeRankList",nextGrade,nextQueue)
    -- 当前段位key
    local ckey1 = mkCacheKey("zsetGradeRankList",grade,queue)
    
    local upgrade,dropUid
    local redis = getRedis()

    -- 无人数限制的榜
    if numLimit == -1 then
        redis:zadd(ckey,score,uid)
        -- local count = redis:zcard(ckey)
        -- if count > rankingListLength then
        --     redis:zremrangebyrank(key,0,count-(rankingListLength+1))
        -- end

        -- 段位大于青铜时,需要删除自己在上一段位的排行信息(青铜没有排行榜,不必要做删除的操作)
        if grade > 1 then
            redis:zrem(ckey1,uid)
        end

        upgrade = true

        return upgrade,dropUid
    end

    -- 最多尝试5次
    for i=1,5 do
        -- 当前榜没有人数限制时,不需要监控
        -- 对两个榜做监控是为了防止本次升阶的用户并发的在自己的排行榜中被别人顶掉
        -- 比如该用户排在了当前榜的最后一位,但加上本次获得的积分后能升阶,此时自己也可能会被顶掉
        if curNumLimit == -1 then
            redis:watch(ckey)
        else
            redis:watch(ckey,ckey1)
        end

        local listLen = tonumber(redis:zcard(ckey))
        
        -- 排行榜人数未到上限
        if listLen < numLimit then
            redis:multi()
            redis:zadd(ckey,score,uid)
            redis:zrem(ckey1,uid)

            if redis:exec() then
                upgrade = true
                break
            end
        else
            local lastNum = numLimit - 1
            local lastRankingInfo = redis:zrevrange(ckey,lastNum,lastNum,"withscores")

            -- 如果未取到数据直接抛错
            if #lastRankingInfo == 0 then
                error({numLimit=numLimit,listLen=listLen,code=-2103})
                break 
            end

            local info = lastRankingInfo[1]

            -- 积分未超过最后一位榜上用户
            if score <= tonumber(info[2]) then
                break
            end

            redis:multi()
            -- 自己上榜
            redis:zadd(ckey,score,uid)
            redis:zrem(ckey,info[1])

            -- 未榜的人掉到下一榜
            redis:zadd(ckey1,info[2],info[1])
            redis:zrem(ckey1,uid)

            if redis:exec() then
                upgrade = true
                dropUid = info[1]
                break 
            end
        end
    end

    return upgrade,dropUid
end

-- 获取每日部队兑换所需消耗量
function killrace.getChangeConsum(day_change)
    local killRaceCfg = getRaceCfg() 
    local changeNum = math.ceil((day_change+1) / killRaceCfg.changeLimit)
    local consume = killRaceCfg.changeRate[changeNum] or killRaceCfg.changeRate[#killRaceCfg.changeRate]
    if consume < killRaceCfg.changeRate[1] then
        consume = killRaceCfg.changeRate[1]
    end

    return consume
end

-- 按天气和地形设置部队属性
-- param Table troops 部队信息
-- param int weather 天气
-- param ocean int 地形
function killrace.setTroopsAttributeByWeatherAndOcean(troops,weather,ocean)
    local killRaceCfg = getRaceCfg()
    local attributeType = getConfig("common.attrNumForAttrStr")
    local weatherCfg = killRaceCfg.weather[weather]
    -- local oceanCfg = killRaceCfg.ocean[ocean]
    for k,v in pairs(troops) do
        if bit32.band(v.type,weatherCfg.effectType) == v.type then
            if v[attributeType[weatherCfg.attType]] > 0 then
                v[attributeType[weatherCfg.attType]] = v[attributeType[weatherCfg.attType]] * (1 + weatherCfg.attValue)
            end
        end

        -- if bit32.band(v.type,oceanCfg.effectType) == v.type then
        --     if v[attributeType[oceanCfg.attType]] > 0 then
        --         v[attributeType[oceanCfg.attType]] = v[attributeType[oceanCfg.attType]] * (1 + oceanCfg.attValue)
        --     end
        -- end

        -- 重算血量
        v.maxhp = math.floor(v.maxhp)
        v.hp   = v.maxhp * v.num
    end
end

--[[
    按给定的时间点生成下一个开启的赛季信息

    param int st 全局开赛时间
    param int season_offset 赛季偏移值,按时间算出的赛季加上此值才是真正的赛季
    param int ts 生成赛季时的时间,默认为当前时间
]]
function killrace.mkSeason(st,season_offset,ts)
    local season = 0
    local seasonSt = 0  
    local seasonEt = 0
    local ts = ts or os.time()
    local killRaceCfg = getRaceCfg()

    -- 起始时间开始需要有一个等于休赛期的等待时间
    st = st + killRaceCfg.offSeason * 3600 * 24
    -- 赛季持续时间    
    local sTime = ( killRaceCfg.season + killRaceCfg.offSeason ) * 3600 * 24
    -- 休赛期持续时间
    local offTime = killRaceCfg.offSeason * 3600 * 24
    -- 时间差
    local t = ts - st

    while(true) do
        if t > 0 then
            season = math.floor(t / sTime) + 1
            if season + season_offset > 0 then
                seasonSt = st + (season-1) * sTime
                -- 结束时间减1秒,否则最后的时间点与下一赛季开赛时间点完全重合了(et 11 23:59:59 st 12 00:00:00)
                seasonEt = seasonSt + sTime-1
            end
        end

        if seasonSt > 0 then break end

        t = t + offTime
    end

    -- 实际赛季数需要处理赛季的偏移值
    season = season + season_offset
    if season < 0 then 
        season = 0
    end

    return {
        season = season,
        st = seasonSt,
        et = seasonEt,
    }

    -- test
    -- return {
    --     season = season,
    --     -- season_offset = season_offset,
    --     st = os.date("%Y%m%d",st),
    --     seasonSt1 = os.date("%Y-%m-%d %H:%M:%S",seasonSt),
    --     seasonEt1 = os.date("%Y-%m-%d %H:%M:%S",seasonEt),
    --     -- date = os.date("%Y-%m-%d %H:%M:%S",os.time()),
    -- }
end

-- 获取当前赛季的状态
local function getSeasonStatus(seasonSt)
    local status = killraceStatus.CLOSE
    local rt = os.time() - seasonSt

    if rt > 0 then
        local killRaceCfg = getRaceCfg()
        local battleTime = killRaceCfg.season * 3600 * 24
        local offTime = (killRaceCfg.offSeason - 0.5) * 3600 * 24
        local resetTime = 0.5 * 3600 * 24

        if rt < battleTime then
            status = killraceStatus.BATTLE
        elseif rt < (battleTime+offTime) then
            status = killraceStatus.OFF
        elseif rt < (battleTime+offTime+resetTime) then
            status = killraceStatus.RESET
        end
    end

    return status
end

-- 初始化击杀赛
function killrace.init(params)
    local ts = os.time()
    local raceData = getRaceData()
    if type(raceData) == "table" and raceData.et > 0 then
        killrace.st = raceData.st
        killrace.et = raceData.et
        killrace.season = raceData.season
        killrace.sinfo.season_offset = raceData.season_offset
        killrace.sinfo.st = raceData.season_st
        killrace.sinfo.et = raceData.season_et
        killrace.sinfo.status = getSeasonStatus(raceData.season_st)
    end
end

function killrace.toArray(format)
    if format then
        return {
            st = killrace.st,
            et = killrace.et,
            offset = killrace.sinfo.season_offset,
        }
    else
        return {
            st = killrace.st,
            et = killrace.et,
            season = killrace.season,
            sinfo = killrace.sinfo,
            status = killrace.status,
        }
    end
end

function killrace.getRaceVerCfg()
    return getRaceVerCfg()
end

function killrace.getRaceInfoFromDb()
    return getRaceInfoFromDb()
end

-- 是否可重置
function killrace.isResetable()
    return killrace.sinfo.status == killraceStatus.RESET
end

-- 是否休赛期
function killrace.isOff()
    return killrace.sinfo.status == killraceStatus.OFF
end

-- 是否战斗期
function killrace.isBattle()
    return killrace.sinfo.status == killraceStatus.BATTLE
end

-- 是否开启
function killrace.isOpen()
    return killrace.sinfo.status == killraceStatus.BATTLE or killrace.sinfo.status == killraceStatus.OFF
end

function killrace.getCacheKey(key,...)
    return mkCacheKey(key, ...)
end

-- 增加战报
function killrace.addBattleReport(report)
    return getDbo():insert(tbNames.battlelog,report)
end

-- 增加兑换日志
function killrace.addChangeLog(uid,ctype,changelog)
    return getDbo():insert(tbNames.changelog,{
        uid = uid,
        type=ctype,
        content = changelog,
        updated_at = os.time()
    })
end

-- 用户报名,累计报名人数,管理工具需要查看
function killrace.userApply()
    local ckey = mkCacheKey("hashkillraceInfo")
    local redis = getRedis()
    killrace.getApplyNum()
    redis:hincrby(ckey,"apply_num",1)
end

-- 获取报名人数(缓存没有数据查一下库)
function killrace.getApplyNum()
    local ckey = mkCacheKey("hashkillraceInfo")
    local redis = getRedis()
    local num = redis:hget(ckey,"apply_num")
    if not num then
        local res = getDbo():getRow(string.format("select count(*) as n from %s where entry = 1",tbNames.user))
        if res then
            num = tonumber(res.n) or 0
            redis:hset(ckey,"apply_num",num)
        end
    end

    return tonumber(num) or 0
end

-- 获取排行榜最低位的分值
local function getMinRankingScore(redis,ckey)
    -- 排行榜大部分时间的长度是超过rankingListLength的,这里没必要判断长度,直接取值做判断就好
    -- local len = redis:zcard(ckey)
    -- if len < rankingListLength then return 0 end
    local result = redis:zrevrange(ckey,rankingListLength,rankingListLength,"withscores")
    if next(result) then
        return tonumber(result[1][2])
    end
    return 0
end

-- 段位榜
function killrace.setGradeRanking(uid,grade,queue,score)
    if grade > 1 then
        local ckey = mkCacheKey("zsetGradeRankList",grade,queue)
        local redis = getRedis()
        redis:zadd(ckey,score,uid)
        -- redis:expire(ckey,259200)
    end
end

-- 总击杀榜
-- 排行榜有可能会超过rankingListLength的值,这里不做删除操作,放到定时的操作里检测
function killrace.setTotalKilledRanking(uid,killed)
    if killed >= killedRankingScoreLimit then
        killed = mkRankingScore(killed)
        local ckey = mkCacheKey("zsetTotalKilledRankList")
        local redis = getRedis()
        local minScore = getMinRankingScore(redis,ckey)
        if killed > minScore then
            redis:zadd(ckey,killed,uid)
            -- redis:expire(ckey,259200)
        end
    end
end

-- 战损率排行榜
-- 排行榜有可能会超过rankingListLength的值,这里不做删除操作,放到定时的操作里检测
function killrace.setDmgRateRanking(uid,dmgrate)
    if dmgrate > 0 then
        -- dmgrate = mkRankingScore(dmgrate)
        local ckey = mkCacheKey("zsetDmgRateKilledRankList")
        local redis = getRedis()
        local minScore = getMinRankingScore(redis,ckey)
        if dmgrate > minScore then
            redis:zadd(ckey,dmgrate,uid)
            -- redis:expire(ckey,259200)
        end
    end
end

-- 系统赠送给到玩家(段位相关)的部队
-- param int grade 大段位
-- param int queue 小优位
-- return 部队信息
function killrace.troopsGive(grade,queue)
    local killRaceCfg = getRaceCfg()
    local killRaceVerCfg = getRaceVerCfg()
    local giveCfg = killRaceVerCfg.troopsGive[grade][queue]

    setRandSeed()
    local troops = {}

    for i=1,giveCfg[2] do
        local randnum = rand(1,giveCfg[1][1] + giveCfg[1][2])
        local troopsLv
        if randnum <= giveCfg[1][1] then
            troopsLv = killRaceVerCfg.groupMsg[grade][queue].boatLimit[1]
        else
            troopsLv = killRaceVerCfg.groupMsg[grade][queue].boatLimit[2]
        end

        local wightKey = getKeyByWight(killRaceCfg.troopsMsg[troopsLv].weight)
        local troopId = killRaceCfg.troopsMsg[troopsLv].servertroops[wightKey]

        troops[troopId] = (troops[troopId] or 0) + killRaceCfg.troopsNum
    end

    return troops
end

--[[
    刷新排行榜[总击杀榜,战损榜]
    取前100名
]]
function killrace.refreshRanking()
    local redis = getRedis()
    local db = getDbo()

    -- 总击杀榜
    local result = db:getAllRows(string.format("select uid,total_killed from userkillrace where total_killed >= %d order by total_killed desc limit %s",killedRankingScoreLimit,rankingListLength))

    local ckey = mkCacheKey("zsetTotalKilledRankList")
    for k,v in pairs(result) do
        redis:zadd(ckey,v.total_killed,v.uid)
    end

    -- 战损榜
    result = db:getAllRows(string.format("select uid,max_dmg_rate from userkillrace where max_dmg_rate >= 1 order by max_dmg_rate desc limit %s",rankingListLength))

    ckey = mkCacheKey("zsetDmgRateKilledRankList")
    for k,v in pairs(result) do
        redis:zadd(ckey,v.max_dmg_rate,v.uid)
    end
end

--[[
    刷新低段位(无人数限制)的排行榜
    取前200名
]]
local function refreshLowGradeRanking(grade,queue)
    local db = getDbo()
    local result = db:getAllRows(string.format("select uid,score from userkillrace where grade = %d and queue = %d order by score desc limit %d",grade,queue,rankingListLength))
    for k,v in pairs(result) do
        killrace.setGradeRanking(v.uid,grade,queue,v.score)
    end
end

--[[
    刷新段位排行榜
]]
function killrace.refreshGradeRanking()
    local rankingList = {}
    local killRaceVerCfg = getRaceVerCfg()

    -- 开始限制人数的段位所需的分数
    local scoreRequire = nil

    -- 开始限制人数的段位
    local gradeLimit = nil

    -- 低段位(最后一个没有人数限制的段位),如果查出的数据有超过容量的,把排名末尾的用户塞到低段中去
    local lowGrade,lowQueue

    for i=#killRaceVerCfg.groupMsg,1,-1 do
        rankingList[i] = {}

        for j=#killRaceVerCfg.groupMsg[i],1,-1 do
            if killRaceVerCfg.groupMsg[i][j].numLimit > 0 then
                scoreRequire = killRaceVerCfg.groupMsg[i][j].scoreRequire
                gradeLimit = i
                rankingList[i][j] = {}
            else
                refreshLowGradeRanking(i,j)
                if not lowGrade then 
                    lowGrade = i
                    lowQueue = j
                end
            end
        end
    end
    
    -- 获取所有的在有人数限制段位的用户数据,按段位、积分排序。
    -- 人数限制的段位总人数有控制,这里按200条来取,正常情况下,应该只能取到配置规定的总人数条数据
    -- 如果多取了,一定是异常的数据,需要处理
    local db = getDbo()
    local result = db:getAllRows(string.format("select uid,score,grade,queue from userkillrace where score >= %d and grade >= %d order by grade desc,queue desc,score desc limit %d",scoreRequire,gradeLimit,100))

    -- 用户大段位,小段位,积分
    local userGrade,userQueue,score

    -- 从高段到低段处理所有数据
    for grade=#killRaceVerCfg.groupMsg,gradeLimit,-1 do
        for queue=#killRaceVerCfg.groupMsg[grade],1,-1 do
            for key,user in pairs(result) do
                score = tonumber(user.score)
                userGrade = tonumber(user.grade)
                userQueue = tonumber(user.queue)

                -- 用户积分满足该段位积分要求,并且用户的段位符合
                if score >= killRaceVerCfg.groupMsg[grade][queue].scoreRequire and ((userGrade == grade and userQueue >= queue ) or (userGrade > grade)) then
                    -- 记录该段位的用户
                    table.insert(rankingList[grade][queue],{user.uid,score,userGrade,userQueue})
                    
                    -- 已经处理进榜的用户置空
                    result[key] = nil

                    -- 如果该段位人数已满,进行下一段位检测
                    if #rankingList[grade][queue] >= killRaceVerCfg.groupMsg[grade][queue].numLimit then
                        break
                    end
                end
            end
        end
    end

    local redis = getRedis()
    local zoneid = getZoneId()
    for gradeKey,gradeInfo in pairs(rankingList) do
        for queueKey,queueInfo in pairs(gradeInfo) do
            for k,v in pairs(queueInfo) do
                -- 榜中的用户的段位与按规则分配后的段位不符合的,需要按当前分配到的段位更正数据
                if v[3] ~= gradeKey or v[4] ~= queueKey then
                    db:update("userkillrace",{uid=v[1],grade=gradeKey,queue=queueKey},{"uid"})
                    redis:del("z"..zoneid..".udata."..v[1])
                end

                -- 进榜
                killrace.setGradeRanking(v[1],gradeKey,queueKey,v[2])
            end
        end
    end

    -- 如果有未处理完的数据,直接塞进无人数限制的低榜
    -- 用户的段位信息需要更新为低段
    for k,v in pairs(result) do
        db:update("userkillrace",{uid=v.uid,grade=lowGrade,queue=lowQueue},{"uid"})
        killrace.setGradeRanking(v.uid,lowGrade,lowQueue,v.score)
        redis:del("z"..zoneid..".udata."..v.uid)
    end
end

return killrace
