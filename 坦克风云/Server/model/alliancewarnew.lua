local allianceWar = {}

local cacheKeys = {
    -- 存放所有用户的行动信息
    hashUsersAction = 'areawar.UsersAction.%s', -- bid
    -- 存放用户的行动信息
    hashBidActions = 'allianceWar.actions.%s', -- bid
    -- 据点信息
    hashPlaceInfo = "allianceWar.placeInfo.%s", -- warId
    -- 据点积分信息
    hashPointInfo = "allianceWar.pointInfo.%s", -- warId
    -- 结束标识
    stringBattleOverFlag = "allianceWar.overFlag.%s",
    -- 军团战中的用户
    setAllianceWarUsers = "allianceWar.users.%s", -- warId
    -- 军团战已经开始标志
    stringStartFlag = "allianceWar.warStartFlag.%s", -- warId
    -- 击毁坦克获得的总贡献
    hashUsersTankDonate = "allianceWar.userTankDonate.%s",
}

-- 区域战配置
local allianceWarCfg = getConfig('allianceWar2Cfg')    

-- 缓存过期时间(秒),默认一周
local expireTs = 604800

local function mkKey(...)
    local tmp = {...}
    return table.concat(tmp,'-')
end

-- 生成缓存key
local function mkCacheKey(cacheKey,...)
    if cacheKeys[cacheKey] then
        return "z"..tostring(getZoneId())..".".. string.format(cacheKeys[cacheKey],...)
    end
end

local function getDay()
    local zone = getConfig('base.TIMEZONE')
    local weets = getWeeTs()
    weets = weets + zone * 3600
    local day = weets / 86400

    return day
end

-- 获取战争id
-- params positionId 阵地编号
-- return int
function allianceWar.getWarId(positionId)
    local day = getDay()
    return tonumber(positionId .. day)
end

-- 军团战隔天开启
function allianceWar.isEnable()
    return (getDay()%2) == allianceWarCfg.openDate
end

-- 获取战场打开状态
-- params int positionId 战场
-- return int 0 开启 其它为状态码
function allianceWar.getWarOpenStatus(positionId,warId)
    if not allianceWar.isEnable() then
        return -4002
    end

    local ts = getClientTs()
    local opents = allianceWar.getWarOpenTs(positionId)

    if ts < opents.st then
        return -4010
    end

    -- 战场已关闭
    if ts >= opents.et then
        return -4011
    end

    return 0
end

function allianceWar.isStart(warId)
    local redis = getRedis()
    local cacheKey = mkCacheKey("stringStartFlag",warId)
    return tonumber(redis:getset(cacheKey,1))
end

function allianceWar.delStartFlag(warId)
    local redis = getRedis()
    local cacheKey = mkCacheKey("stringStartFlag",warId)
    redis:del(cacheKey)
end

-- 获取战场开放时间
-- params int positionId 战场
-- params int warId 战争标识
-- return int | table
function allianceWar.getWarOpenTs(positionId,warId)
    local open = {}
    local weets = getWeeTs()
    
    -- if warId then        
    --     local zone = getConfig('base.TIMEZONE')
    --     local day = tonumber(string.sub(warId,2))       
    --     ptb:e(warId) 
    --     weets = day * 86400 - (3600 * zone)
    -- end

    if allianceWarCfg.startWarTime[positionId] then
        open.st = weets + allianceWarCfg.startWarTime[positionId][1] * 3600 + allianceWarCfg.startWarTime[positionId][2] * 60
        open.et = open.st + allianceWarCfg.maxBattleTime

        return open
    end
end

-- 设置战斗结束标识
function allianceWar.setOverBattleFlag(warId,winner)
    winner = winner or 0
    local overKey = mkCacheKey("stringBattleOverFlag",warId)
    local redis = getRedis()
    local ret = redis:set(overKey,winner) or redis:set(overKey,winner)
    redis:expire(overKey,expireTs)
end

-- 获取战斗结束标识
function allianceWar.getOverBattleFlag(warId)
    local overKey = mkCacheKey("stringBattleOverFlag",warId)
    local redis = getRedis()
    local flag = redis:get(overKey)

    return flag
end

-- 玩家进入战场
-- params int uid 玩家id
function allianceWar.joinAllianceWar(warId,uid)
    local acKey = mkCacheKey("setAllianceWarUsers",warId)
    local redis = getRedis()
    redis:sadd(acKey,uid)
    redis:expire(acKey,expireTs)
end

-- 获取进入战场的成员
-- params int aid 军团id,有就查军团的成员,没有则查所有的成员
function allianceWar.getAllianceWarUsers(warId)
    local acKey = mkCacheKey("setAllianceWarUsers",warId)
    local redis = getRedis()
    return redis:smembers(acKey)
end

function allianceWar.placeLock(warId,placeId)
    local lockFlag = mkKey(warId,placeId)
    return commonLock(lockFlag,"alliancewarlock")
end

function allianceWar.placeUnlock(warId,placeId)
    local lockFlag = mkKey(warId,placeId)
    return commonUnlock(lockFlag,"alliancewarlock")
end

-- 从格式化的部队数据中获取设置的部队数据{{'a10001',5},{'a10002',5},}
-- 存的数据是属性加成算好的，需要换成动画能播的格式
local function getTroopsByInitTroopsInfo(initTroopsInfo)
    local troops = {}
    local totalnum = 0

    for k,v in pairs(initTroopsInfo) do
        if (tonumber(v.num) or 0) > 0 then
            table.insert(troops,{v.id,v.num})
            totalnum = totalnum + v.num
        else
            table.insert(troops,{})
        end
    end

    if totalnum <= 0 then
        troops = {}
    end

    return troops
end

-- 从战斗后的部队数据中获取胜余的坦克数量
-- return table, table
local function getDieTroopsByInavlidFleet(fleetinfo,invalidFleet)
    local troops = {}

    for k,v in pairs(fleetinfo) do
        if (v[2] or 0) > 0 then
            local dienum = v[2] - (invalidFleet[k] and invalidFleet[k][2] or 0)

            if dienum > 0 then
                troops[v[1]] = (troops[v[1]] or 0) + dienum
            end
        end
    end

    return troops
end

-- 地形对坦克的加成
-- params table tank
-- params table attributeType 属性类型
local function  landformAdd(tank,landformInfo,landformCfg,attributeType)
    local addAttributeValue = {}
    
    if type(landformCfg[landformInfo]) == 'table' then
        for k,v in ipairs(landformCfg[landformInfo].attType) do
            local attrName = attributeType[v]
            local rate = landformCfg[landformInfo].attValue[k]

            if attrName == 'maxhp' or attrName == 'dmg' then
                addAttributeValue[attrName] = tank[attrName] * rate 
            elseif attrName == 'dmg_reduce' then
                addAttributeValue[attrName] = 1 - rate
            else
                addAttributeValue[attrName] = rate
            end
        end            
    end
    
    return addAttributeValue
end

-- 格式化部队（处理成能战斗的格式，保存的时候是简化了的数据）
-- attField 属性字段
-- troops 部队数据
-- currTroops 当前存活下来的部队，如果有此值，需要将部队的数量和血量按当前数据重新计算
local function formatTroops(attField,troops,currTroops,buff,landform)
    local worldGroundCfg = getConfig('worldGroundCfg')
    local attTroops = {}
    local attrNumForAttrStr = getConfig("common.attrNumForAttrStr")

    for m,n in pairs(troops) do
        attTroops[m] = {}
        if n[1] then
            for k,v in pairs(attField) do
                if v == 'abilityInfo' then
                    attTroops[m][v] = {    
                        debuff={},  
                        buff={},
                    }
                else
                    attTroops[m][v] = n[k]
                end
            end

            if landform then
                local landformAddValue = landformAdd(attTroops[m],landform,worldGroundCfg,attrNumForAttrStr)
                if type(landformAddValue) == 'table' and next(landformAddValue) then
                    attTroops[m].landform = landform
                    for landBuffKey,landBuffValue in pairs(landformAddValue) do
                        if landBuffKey == 'dmg_reduce' then
                            attTroops[m][landBuffKey] = attTroops[m][landBuffKey] * (landBuffValue or 1)
                        else
                            attTroops[m][landBuffKey] = attTroops[m][landBuffKey] + (landBuffValue or 0)
                        end
                    end
                end
            end
        end
    end
    

    -- 军团据点战
    if type(buff) == 'table' then
        local buffAttrKey = {
            b1 = {"maxhp","dmg","armor","arp","hp"},
            b2 = {"accuracy","evade","crit","anticrit"},
        }
        
        for warBuffKey,warBuffLv in pairs(buff) do
            if warBuffLv > 0 and buffAttrKey[warBuffKey] then
                for k,v in pairs(attTroops) do
                    if next(v) then
                        for _,attribute in ipairs(buffAttrKey[warBuffKey]) do 
                            if warBuffKey == 'b2' then                                    
                                attTroops[k][attribute] = attTroops[k][attribute] + allianceWarCfg.buffSkill[warBuffKey].per * warBuffLv
                            else
                                attTroops[k][attribute] = attTroops[k][attribute] + attTroops[k][attribute] * allianceWarCfg.buffSkill[warBuffKey].per * warBuffLv
                            end
                        end
                    end
                end
            end
        end
    end
    
    if type(currTroops) == 'table' and #currTroops > 0 then
        for k,v in ipairs(currTroops) do
            if not next(v) or (v[2] or 0) <= 0 then
                attTroops[k] = {}
            else
                attTroops[k].num = v[2]
                attTroops[k].hp = v[2] * attTroops[k].maxhp
            end
        end
    end

    return  attTroops
end

-- 战斗
function allianceWar.placeBattle(attackerBinfo,defenderBinfo,defenderTroops,attBuff,defBuff,landform)
    local fleetInfo1 = copyTab(attackerBinfo)
    local fleetInfo2 = copyTab(defenderBinfo)

    local aFleetInfo = formatTroops(fleetInfo1[1],fleetInfo1[2][1],nil,attBuff,landform)
    local defFleetInfo = formatTroops(fleetInfo2[1],fleetInfo2[2][1],defenderTroops,defBuff,landform)

    local aTroops = getTroopsByInitTroopsInfo(aFleetInfo)
    local dTroops = getTroopsByInitTroopsInfo(defFleetInfo)

    require "lib.battle"

    local report, aInvalidFleet, dInvalidFleet, attSeq, setPoint = {}
    report.d, report.r, aInvalidFleet, dInvalidFleet, attSeq, setPoint = battle(aFleetInfo,defFleetInfo,1)

    local aAliveTroops = getTroopsByInitTroopsInfo(aInvalidFleet)
    local dAliveTroops = getTroopsByInitTroopsInfo(dInvalidFleet)

    local aDieTroops = getDieTroopsByInavlidFleet(aTroops,aAliveTroops)
    local dDieTroops = getDieTroopsByInavlidFleet(dTroops,dAliveTroops)

    report.t = {dTroops,aTroops}
    report.h = {{},{}}

    if fleetInfo1[3] and fleetInfo1[3][1] then
        report.h[2] = fleetInfo1[3][1]
    end

    if fleetInfo2[3] and fleetInfo2[3][1] then
        report.h[1] = fleetInfo2[3][1]
    end

    report.se = {fleetInfo2[4] or 0, fleetInfo1[4] or 0}
    return report, aAliveTroops, dAliveTroops, attSeq, setPoint,aDieTroops,dDieTroops
end

-- 获取阵地的占有者和兵力
-- params placeId 阵地
-- params warId 战争标识
function allianceWar.getPlaceInfo(warId,placeId)
    local cacheKey = mkCacheKey("hashPlaceInfo",warId)
    local redis = getRedis()
    local data = redis:hget(cacheKey,placeId)

    if data then
        data = json.decode(data)
    end

    if type(data) ~= 'table' then
        data = {}
    end

    if type(data.binfo) ~= 'table' or not next(data.binfo) then
        data = {}
    end

    return data
end

--[[ 
    设置阵地的占有者和兵力
    需要重新设置updated_at字段，计算积分的时候会以此值为起始时间计算
    记录占领者的军团名，军团id，用户昵称，在结算出战报时用
    
    params int placeId 小地块标识 1-9 
    params int warId 战争标识【唯一】,战报等计算会以此为基准
    params int oid 当前地块的占领者
    params table troops 当前地块的兵力信息
    params table label 红蓝标识 1红，2蓝
    params int attackStatus 进攻胜利是1，防守胜利是2,直接占领是3
        
    return bool
]]
function allianceWar.setPlaceInfo(warId,placeId,oid,troops,userinfo,label,attackStatus,occupyTs,binfo)
    local info = {}
    info.placeId = placeId
    info.st = occupyTs
    info.oid = oid
    info.pic = userinfo.pic
    info.aid = userinfo.alliance
    info.aname = userinfo.alliancename
    info.nickname = userinfo.nickname
    info.label = label
    info.troops = troops
    info.binfo = binfo
    info.warId = warId
    info.updated_at = getClientTs()
    info.atts = attackStatus

    local infoJsonString = json.encode(info)

    local cacheKey = mkCacheKey("hashPlaceInfo",warId)
    local redis = getRedis()
    redis:hset(cacheKey,placeId,infoJsonString)
    redis:expire(cacheKey,expireTs)

    return info
end

-- 重置阵地兵力,走事务
function allianceWar.resetPosition(warId,placeId) 
    local cacheKey = mkCacheKey("hashPlaceInfo",warId)
    local redis = getRedis()
    redis:hdel(cacheKey,placeId)
end

-- 增加积分
-- params int warId 战斗id
-- params int label 标识（1是红方，2是蓝方）
-- params int point 积分
function allianceWar.addPoint(warId,label,point)
    point = math.floor(point)

    if point > 0 and label then
        local pointKey = mkCacheKey("hashPointInfo",warId)
        local redis = getRedis()
        local ret = redis:hincrby(pointKey,label,point)
        redis:expire(pointKey,expireTs)
    end
end

-- 获取积分
-- params int positionId 战场id 
-- return table
function allianceWar.getPositionPoints(warId)
    local point = {0,0}

    local pointKey = mkCacheKey("hashPointInfo",warId)
    local redis = getRedis()
    local result = redis:hgetall(pointKey)

    if type(result) == 'table' then
        for k,v in pairs(point) do 
            point[k] = (result[tostring(k)] or 0) + v
        end
    end

    return point
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
function allianceWar.getPointByOccupiedTime(placeId,buffInfo,st,et)
    local point = 0
    local occupiedTs = et-st

    if occupiedTs >= 1 then
        local stronghold = placeId
        local winPoint = allianceWarCfg.stronghold[stronghold].winPoint
        point = point + (occupiedTs * winPoint)
        
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
    
    point = math.floor(point)

    return point
end

local function getUserTroopsDonate(warId,uid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("hashUsersTankDonate",warId)
    local donate = tonumber(redis:hget(cacheKey,uid)) or 0
    return donate
end

local function addUserTroopsDonate(warId,uid,donate)
    if donate > 0 then
        local redis = getRedis()
        local cacheKey = mkCacheKey("hashUsersTankDonate",warId)
        redis:hincrby(cacheKey,uid,donate)
    end
end

function allianceWar.checkUserTroopsDonate(warId,uid,donate,tankToDonate)
    local userTroopsDonate = getUserTroopsDonate(warId,uid)
    local userAddDonate = allianceWarCfg.maxTankDonate  - userTroopsDonate

    if userAddDonate <= 0 then
        donate = 0
        tankToDonate = {}
    elseif userAddDonate < donate then
        local deDonate = donate - userAddDonate
        for k,v in pairs(tankToDonate) do
            if deDonate > 0 then
                tankToDonate[k] = v - deDonate
                if tankToDonate[k] < 0 then
                    tankToDonate[k] = nil
                end

                deDonate = deDonate - v
            end
        end

        donate = userAddDonate
    end

    addUserTroopsDonate(warId,uid,donate)

    return donate,tankToDonate
end

function allianceWar.getDonateByTroops(troops,buff)
    local donate = 0    
    local tankToDonate = {}
    local allianceWarCfg = getConfig('allianceWar2Cfg')
    local tankCfg = getConfig('tank')
    if type(troops) == 'table' then
        for k,v in pairs(troops) do
            local donateVal = math.ceil(tankCfg[k].tankDonate * allianceWarCfg.tankeDonateFix * v * (1 + (buff.b4 * allianceWarCfg.buffSkill.b4.per)))
            donate = donate + donateVal
            tankToDonate[k] = (tankToDonate[k] or 0) + donateVal
        end
    end

    donate = math.ceil(donate)

    return donate,tankToDonate
end

function allianceWar.getDonateByOccupiedPoint(point)
    local allianceWarCfg = getConfig('allianceWar2Cfg')
    local donate = allianceWarCfg.winPointToDonate * point
    donate = math.ceil(donate)
    return donate
end

-- 获取阵地的占有者和兵力
-- params int positionId 战场
-- return table
function allianceWar.getPositionInfo(warId)
    local redis = getRedis()
    local cacheKey = mkCacheKey("hashPlaceInfo",warId)
    local data = redis:hgetall(cacheKey)

    local info = {}
    if type(data) == 'table' then
        for k,v in pairs(data) do
            info[k] = json.decode(v)
        end
    end

    return info
end


-- 获取当前所有据点的总分数（会计算所有据点）
-- params int warId 战场P
-- params int recount 是否重新计算 
-- return table 1 红方分数 2 蓝方分数 
function allianceWar.getAllPlacePoint(positionId,warId)
    local point = {0,0}
    local redis = getRedis()    
    local placePoint = {}
    local positionInfo = allianceWar.getPositionInfo(warId)

    --[[
        10/s结算一次，是按后台时间计算的，如果这里取clientTs很有可能会比后台慢一点
        这会导致计算的时候值往回回退，前台显示玩家体验不好，
        所以这里直接取系统时间进行计算
        结算时间不能超过战场结束时间
    ]]
    local ts = os.time()
    local openTs = allianceWar.getWarOpenTs(positionId,warId)    
    local offsetAt = ts%10
    if offsetAt <= 2 and offsetAt > 0 then
        ts = ts - offsetAt
    end
    if ts > openTs.et then
        ts = openTs.et
    end

    if type(positionInfo) == 'table' then
        for k,v in pairs(positionInfo) do
            local uid = tonumber(v.oid)
            if v.updated_at and v.label and v.placeId and uid then              
                local uobjs = getUserObjs(uid,true)
                local mUserAllianceWar = uobjs.getModel('useralliancewar')
                
                local score = allianceWar.getPointByOccupiedTime(v.placeId,mUserAllianceWar.upgradeinfo,v.updated_at,ts)
                if score > 0 then 
                    point[v.label] = (point[v.label] or 0) + score
                end
            end
        end
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
function allianceWar.getAllPlaceLog(positionId,positionInfo,warId)
    if not positionInfo then
        positionInfo = allianceWar.getPositionInfo(warId)
    end

    local data = {}
    local report = {}
    local ts = getClientTs()

    -- 如果时间超过了本场战斗的结束时间，则按结束时间计算
    local openTs = allianceWar.getWarOpenTs(positionId,warId)    
    if ts > openTs.et then
        ts = openTs.et
    end

    for k,v in pairs(positionInfo) do 
        local uid = tonumber(v.oid)

        if tonumber(v.warId) == warId and uid then     
            local uobjs = getUserObjs(uid,true)
            local mUserAllianceWar = uobjs.getModel('useralliancewar')
            local userBuff = mUserAllianceWar.getBattleBuff()

            local defPoint = allianceWar.getPointByOccupiedTime(v.placeId,mUserAllianceWar.upgradeinfo,v.updated_at,ts)
            local defRaising = allianceWar.getDonateByOccupiedPoint(defPoint)
            
            local battlelog = {
                warId = warId,
                attacker = 1,
                defender = v.oid,
                attackerName = '',
                defenderName = v.nickname,
                attackerAllianceId = 0,
                defenderAllianceId = v.aid,
                attAllianceName = '',
                defAllianceName = v.aname,
                attBuff = {},
                defBuff = userBuff,
                attPoint = 0,
                defPoint = defPoint,
                victor = v.oid,
                report = report,
                attRaising = 0,
                defRaising = defRaising,
                position = positionId,
                placeid = v.placeId,
            }

            table.insert(data,battlelog)            
        end        
    end
    
    return data
end

-- 按binfo获取三只部队的信息包含英雄
function allianceWar.getTroopsByBinfo(binfo)
    local troops = {
        {}
    }
    
    local heros = {
        {0,0,0,0,0,0},
    }
    local plane=nil
    local equip = 0
    if type(binfo) == 'table' and next(binfo) then
        local idIndex
        local numIndex
        for k,v in pairs(binfo[1]) do
            if v == 'id' then
                idIndex = k
            elseif v == 'num' then
                numIndex = k
            end

            if idIndex and numIndex then 
                break 
            end
        end

        local emptyTroop = {}
        if type(binfo[2]) == 'table' then
            for sn,snVal in pairs(binfo[2]) do
                if  type(binfo[2][sn]) == 'table' and next(binfo[2][sn]) then
                    for k,v in pairs(snVal) do
                        if next(v) then
                            troops[sn][k] = {v[idIndex], (tonumber(v[numIndex]) or 0)}
                        else
                            troops[sn][k] = emptyTroop
                        end
                    end
                end
            end
        end

        if type(binfo[3]) == 'table' then
            for sn,snVal in pairs(binfo[3]) do
                if  type(binfo[3][sn]) == 'table' and next(binfo[3][sn]) then
                    for k,v in pairs(snVal) do
                        if type(v) == 'string' and v ~= "" then
                            local heroIndexInfo = string.split(v,'-')
                            heros[sn][k] = heroIndexInfo[1]
                        end
                    end
                end
            end
        end

        if binfo[4] then
            equip = binfo[4]
        end
        if type(binfo[5])=='table' and binfo[5][1]~=nil  then
            plane = binfo[5][1]
        end
    end

    return troops,heros,equip,plane
end

-- 处理据点数据为前端所需格式
-- 1是据点归属,2是当前城防值,3是NPC部队数据(0是无,1是有)
function allianceWar.formatPlaceDataForClient(placeinfo)
    local data = copyTab(placeinfo)
    data.binfo = nil
    --     label = placeinfo.label,
    --     atts = placeinfo.atts,
    --     -- troops = placeinfo.troops,
    -- }

    local troops,heros, equip,plane = allianceWar.getTroopsByBinfo(placeinfo.binfo)
    data.heros = heros[1]
    data.equip=equip
    data.plane=plane
    if not data.troops then
        data.troops = troops[1]
    end

    return data
end

function allianceWar.getPlaceTroopsInfoForClient(placeinfo)
    local data = {
        troops = placeinfo.troops,
    }

    local troops,heros = allianceWar.getTroopsByBinfo(placeinfo.binfo)
    data.heros = heros[1]
    if not data.troops then
        data.troops = troops[1]
    end

    return data
end

-- 处理所有据点数据为前端所需格式
function allianceWar.formatPlacesDataForClient(placesInfo)
    local data = {}

    for k,v in pairs(placesInfo) do 
        data[k] = allianceWar.formatPlaceDataForClient(v)
    end

    return data
end

-- log
function allianceWar.writeLog(log)
    writeLog(log,'allianceWar')
end



-- 发奖胜利调用
-- aid 军团id
-- bid 战斗id
-- areaid  报名那个区域类型
-- method  ＝1 发生过战斗 ＝0 未发生
function allianceWar.sendWinReward(aid,bid,areaid,method)
    local allianceWarCfg = getConfig('allianceWar2Cfg')
    local redis = getRedis()
    local key="z" .. getZoneId() ..".alliancewarnew.".."bid"..bid.."areaid"..areaid
    local ret =redis:incr(key)
    local title=43
    local winreward=allianceWarCfg['reward'..areaid]
    local weet=getWeeTs()
    if ret==1 then
        local users={}
        if method==0 then
            local ret =  M_alliance.getalliance{alliancebattle=1,method=1,aid=aid}
            local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60
            local ents = weet+ents
            if  ret and  ret.data.members then  
                for mk,mv in pairs(ret.data.members) do
                    if tonumber(mv.join_at)<=ents then
                        local tmp={uid=mv.uid}
                        table.insert(users,tmp)
                    end
                end
            end
        else
            local db = getDbo()
            result = db:getAllRows("select uid from  useralliancewar where bid=:bid  and aid=:aid and binfo<>'{}' ", {bid=bid,aid=aid})
            if result then
                users=result
            end
        end
        local item={q=winreward.reward,h=winreward.serverReward}
        for k,v in pairs (users) do
            local uid=tonumber(v.uid)
            if moduleIsEnabled('rewardcenter')==1 then
                local reward = item.h or {1,item.h}
                local ret = sendToRewardCenter(uid,'aw',title,weet,nil,{type=title,bid=bid},reward)
            else
                local ret = MAIL:mailSent(uid,1,uid,'','',title,json.encode{type=title,bid=bid},1,0,2,item)
            end
        end
    end
    redis:expire(key,86400)
end


-- 发送活跃奖励完成任务
-- bid 战斗id
-- areaid  报名那个区域类型

function allianceWar.sendTaskReward(bid,areaid)
    local redis = getRedis()
    local key="z" .. getZoneId() ..".alliancewarnew.".."bid"..bid.."taskreward"
    local ret =redis:incr(key)
    local weet=getWeeTs()
    if ret==1 then
        local title=45
        local db = getDbo()
        result = db:getAllRows("select uid,task from  useralliancewar where bid=:bid and task<>'{}' ", {bid=bid})
        local allianceWarCfg = getConfig('allianceWar2Cfg')
        local taskcfg=allianceWarCfg.task
        local taskreward=allianceWarCfg.taskreward
        if result then
            for k,v in pairs (result) do
                local task=json.decode(v.task)
                local reward={}
                if type(task)=='table' then
                    local uid=tonumber(v.uid)
                    for tk ,tv in pairs(task) do
                        if type(taskcfg[tk])=="table" and taskcfg[tk][1]<=tv then
                           if type(taskreward[areaid][tk][2])=='table' then
                                for ad,av in pairs (taskreward[areaid][tk][2]) do
                                    reward[ad]=(reward[ad] or 0)+av
                                end
                           end
                        end
                    end

                    if next(reward) then
                        if moduleIsEnabled('rewardcenter')==1 then
                            local ret = sendToRewardCenter(uid,'aw',title,weet,nil,{type=title,bid=bid},reward)
                        else
                            local item={h=reward,q=formatReward(reward)}
                            local ret = MAIL:mailSent(uid,1,uid,'','',title,json.encode{type=title,bid=bid},1,0,2,item)
                        end

                    end


                end
            end
        end
    end
    redis:expire(key,86400)
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
function allianceWar.sendMsg(msgType,params)
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
    elseif msgType == 5 then
        -- 有一个军团报名军团战的时候
        -- 报名截止的时候
        -- "param":["战场索引","战场开战时间"]
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
                    key="chatSystemMessage26",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    elseif msgType == 4 then
        -- 战斗开始即结束的时候
        -- "param":["战场索引","获胜军团名字","资源增产Buff持续时间"]
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
                    key="chatSystemMessage27",
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
