--[[
    跨服区域战
]]
local areawar = {
    TROOP_COUNT=3,
}

----------------------------

-- 存放bid信息
local hashBidData =  'areaTeamWar.biddata.%s'
-- 存放所有用户的行动信息
local hashUsersAction = 'areaTeamWar.UsersAction.%s.%s' -- bid
-- 军团数据
local stringBidAlliance = 'areaTeamWar.alliance.%s.%s' -- bid
-- 成员数据
local hashBidMember = 'areaTeamWar.members.%s' -- bid
-- 区域战结束标识，提前结束，定时会继续扫描，如果有此标识，程序直接停止
local stringBattleOverFlag = "areaTeamWar.overFlags.%s.%s" -- bid
-- 存放用户的行动信息
local hashBidActions = 'areaTeamWar.actions.%s.%s' -- bid
-- 记录战场据点信息
local hashBidPlaces = "areaTeamWar.places.%s.%s" -- bid
-- 记录军团长发出的军团指令
local hashAllianceCommandMsg = "areaTeamWar.commandmsg.%s.%s"
-- 按军团记录加入战场的用户id，按此队列推送消息
local setAllianceMemId = "areaTeamWar.members.uids.%s.%s.%s" -- group,bid,zidAid
-- 用户贡献值
local stringBidUsersDonate = "areaTeamWar.donate.%s.%s" -- bid
-- 军团在战斗中获取到的奴隶
local stringAllianceSlaves = "areaTeamWar.slaves.%s.%s" -- bid
-- 军团的积分
local hashAlliancePointInfo = "areaTeamWar.pointInfo.%s.%s" -- bid
-- 军团任务
local stringAllianceTasks = "areaTeamWar.tasks.%s.%s" -- bid
-- 报名信息
local stringApplyInfo="areaTeamWar.applytInfo.%s" -- bid

----------------------------

-- 每轮(按胜败组)基础位置
local groupName2SortNum = {a=1,b=2}
local SortNum2GroupName = {'a','b'}

----------------------------

-- buff对应的战斗属性
local buffAttribute = {
    b1 = {'dmg','maxhp'},
    b2 = {'armor','arp'},
    b3 = {'accuracy','evade','crit','anticrit'},
}

----------------------------

-- 当前时间戳
local ts
-- 区域战配置
local areaWarCfg
-- 区域战地图配置
local localWarMapCfg
-- 地形配置
local worldGroundCfg
-- 数据库连接
local db
-- redis 连接
local redis
-- 缓存过期时间(秒),默认20小时
local expireTs = 72000
-- 凌晨时间戳
local weets
-- 本次战场所属组
local group

----------------------------

-- 参战军团信息列表
local areawarAllianceList = {}
-- 地图据点的详细信息
local mapPlacesInfo = nil
-- 回合开始前的据点信息,只读,用来获取战斗中的BUFF
local originalPlacesInfo = nil
-- 用户行动数据
local usersActionData = nil
-- 用户数据
local usersData = {}
-- 存放用户的贡献
local usersDonate = {}
-- 战报
local battleReports = {}
-- 记录玩家本回合的战斗次数
local userBattleCount = {}
-- 战斗任务
local battleTaskList = {}
-- 计算战斗分数的标识,保证不会多次结算
local countWarPointFlag = false

----------------------------

-- Npc兵力配置
local baseNpc = {
    uid = 0,
    aid = 0,
    zid = 0,
    sn = 1,
    nickname='-1',
    level=60,
    fc=1000000,
    pic=1,
    rank=9,
    aname='',
    binfo = '[["maxhp","buffvalue","dmg","crit","accuracy","buff_value","hp","evade","armor","salvo","isSpecial","weaponType","double_hit","id","abilityInfo","arp","abilityLv","type","landform","anticrit","num","hero","decritDmg","abilityID","critDmg","dmg_reduce","evade_reduce","buffType"],[[[2385,0.2,198,0.5,0.5,0,1612260,0.5,0,3,0,1,0,"a10004",{"debuff":{},"buff":{}},0,"",1,0,0.7,676,{},0,"",0,1,0,1],[2385,0.2,198,0.5,0.5,0,1612260,0.5,0,3,0,1,0,"a10004",{"debuff":{},"buff":{}},0,"",1,0,0.7,676,{},0,"",0,1,0,1],[2385,0.2,198,0.5,0.5,0,1612260,0.5,0,3,0,1,0,"a10004",{"debuff":{},"buff":{}},0,"",1,0,0.7,676,{},0,"",0,1,0,1],[2160,0.2,301.5,0.7,0.5,0,1460160,0.5,0,6,0,8,0,"a10034",{"debuff":{},"buff":{}},0,"",8,0,0.5,676,{},0,"",0,1,0,8],[2115,0.2,585,0.5,0.7,0,1429740,0.5,0,2,0,4,0,"a10024",{"debuff":{},"buff":{}},0,"",4,0,0.5,676,{},0,"",0,1,0,4],[1395,0.2,945,0.5,0.5,0,943020,0.7,0,1,0,2,0,"a10014",{"debuff":{},"buff":{}},0,"",2,0,0.5,676,{},0,"",0,1,0,2]]],{}]'
}

local bossBinfo = '[["buffType","evade","hero","isSpecial","buff_value","armor","critDmg","id","accuracy","wp","dmg_reduce","abilityInfo","crit","weaponType","num","abilityID","salvo","abilityLv","hp","decritDmg","anticrit","evade_reduce","arp","dmg","double_hit","anticrit_reduce","landform","buffvalue","maxhp","type"],[[[1,0.8,{},0,0,0,0,"a10007",0.8,"0",1,{"debuff":{},"buff":{}},0.8,1,1200,"a",3,2,20736000000,0,1.5,0,0,36000,0,0,0,0.25,17280000,1],[1,0.8,{},0,0,0,0,"a10007",0.8,"0",1,{"debuff":{},"buff":{}},0.8,1,1200,"a",3,2,20736000000,0,1.5,0,0,36000,0,0,0,0.25,17280000,1],[1,0.8,{},0,0,0,0,"a10007",0.8,"0",1,{"debuff":{},"buff":{}},0.8,1,1200,"a",3,2,20736000000,0,1.5,0,0,36000,0,0,0,0.25,17280000,1],[8,0.8,{},0,0,0,0,"a10037",0.8,"0",1,{"debuff":{},"buff":{}},1.5,8,1200,"d",6,2,12960000000,0,0.8,0,0,36000,0,0,0,0.25,10800000,8],[4,0.8,{},0,0,0,0,"a10027",1.5,"0",1,{"debuff":{},"buff":{}},0.8,4,1200,"c",2,2,14256000000,0,0.8,0,0,75600,0,0,0,0.25,11880000,4],[2,1.5,{},0,0,0,0,"a10017",0.8,"0",1,{"debuff":{},"buff":{}},0.8,2,1200,"b",1,2,10368000000,0,0.8,0,0,144000,0,0,0,0.25,8640000,2]]],{}]'

-- 所有待推送信息
local pushData = {}
-- 所有推送用户
local pushUsers = {}

----------------------------

-- 生成带组名缓存key
local function mkCacheKeyByGroup(groupName,cacheKey,...)
    assert(groupName2SortNum[groupName],'group error')
    local key = string.format(cacheKey,groupName,...)
    return key .. "." .. weets
end

--[[
    生成默认组名的缓存key
    兼容大部分原服内区域战的代码
]] 
local function mkCacheKey(cacheKey,...)
    return mkCacheKeyByGroup(group,cacheKey,...)
end

--[[
    生成没有组名的缓存key
    如：玩家的数据，直接拿bid,zid,uid就能区分
]] 
local function mkNotGroupCacheKey(cacheKey,...)
    local key = string.format(cacheKey,...)
    return key .. "." .. weets
end

--[[
    生成标识key
    全服所有需要连接两个元素得到的标识都通过此方法生成
]]
local function mkKey(...)
    return table.concat({...},'-')
end

--[[
    重置所有与战场关联的数据
    处理完一个战场逻辑后,会进行下一个战场的逻辑,上一场的相关数据必需清除掉
]]
function areawar.reset()
    mapPlacesInfo = nil
    originalPlacesInfo = nil
    usersActionData = nil
    usersData = {}
    usersDonate = {}
    pushData = {}
    pushUsers = {}
    battleReports = {}
    areawarAllianceList = {}
    userBattleCount = {}
    group = nil
    battleTaskList = {}
    countWarPointFlag = false
end

-- 初始化
function areawar.construct(groupName,bid)
    ts = os.time()
    weets = getWeeTs()
    areaWarCfg = getConfig('serverWarLocalCfg')
    localWarMapCfg = getConfig('serverWarLocalMapCfg1')
    worldGroundCfg = getConfig('worldGroundCfg')

    db = getCrossDbo("areacrossserver")

    setRandSeed()
    areawar.reset()

    if groupName then
        areawar.setWarGroup(groupName)
    end

    if bid then
        areawar.setRedis(bid)
    end
end

function areawar.destruct()
    areaWarCfg = nil
    localWarMapCfg = nil
    worldGroundCfg = nil
    redis = nil
    db = nil
end

function areawar.setRedis(bid,areaServerId)
    local cfg = areawar.gate(bid,areaServerId)
    redis = getRedisByCfg({host=cfg.redis.host,port=cfg.redis.port})
end

-- 设置当前战场组名
function areawar.setWarGroup(groupName)
    assert(groupName2SortNum[groupName],"group invalid")
    group = groupName
end

-- 获取当前战场组名
function areawar.getWarGroup()
    return group
end

-- 获取所有的组名
function areawar.getWarGroups()
    return SortNum2GroupName
end

-- 设置本场区域战需要推送的用户
local function addPushUser(uid)
    pushUsers[tostring(uid)] = uid
end

-- 设置战斗中需要推送的数据
function areawar.setBattlePushData(data)
    if type(data) == 'table' and next(data) then
        table.insert(pushData,data)
    end
end

-- 重复设置只会记录最后一次的数据
function areawar.setSinglePushData(key,data)
    pushData[key] = data
end

-- 推送数据
-- 会将20秒内，所有变化数据集中处理后，一并发给前端
function areawar.battlePush()
    local pushCmd = 'areateamwarserver.battle.push'

    if next(pushData)  then
        local pData = {}

        for k,v in pairs(pushData) do
            if type(k) == 'string' then
                pData[k] = v
            else
                for k1,v1 in pairs(v) do
                    if not pData[k1] then pData[k1] = {} end

                    if k1 == 'placesInfo' and not next(pData['placesInfo']) then
                        pData['placesInfo'] = areawar.formatPlacesDataForClient(mapPlacesInfo)
                    elseif k1 == 'over' then
                        pData[k1] = v1
                    elseif k1 == 'battlePointInfo' then
                        pData['battlePointInfo'] = v1
                    else
                        table.insert(pData[k1],v1)
                    end
                end
            end
        end

        -- 战斗任务列表
        if battleTaskList and next(battleTaskList) then
            pData.battleTasks = battleTaskList
        end

        pData.bts = ts
        local sec = (pData.bts % 60)
        if sec >= 17 and sec <= 36 then
            pData.bts = pData.bts - sec + 20
        elseif sec >= 37 and sec <= 56 then
            pData.bts = pData.bts - sec + 40
        elseif sec >= 57 then
            pData.bts = pData.bts - sec + 60
        elseif sec <= 16 then
            pData.bts = pData.bts - sec
        end

        local uid
        local response = {
            data={areaWarserver=pData},
            ret=0,
            cmd=pushCmd,
            ts = ts,
        }
        local sendMessage = json.encode(response)

        for _,v in pairs(pushUsers) do
            uid = tonumber(v)
            if uid then
                sendMsgByUid(uid,sendMessage)
            end
        end

        uid,pData,sendMessage = nil,nil,nil
    end

    pushData = nil
    pushUsers = nil
end

-- 获取每轮战斗的起始与结束详细时间
local function getBattleRoundTs(st)
    local sevCfg = areaWarCfg
    local battleTime = {
        {
            st + sevCfg.startWarTime.a[1] * 3600 + sevCfg.startWarTime.a[2] * 60,
            st + sevCfg.startWarTime.b[1] * 3600 + sevCfg.startWarTime.b[2] * 60,
        },
        {
            st + 24 * 3600 + sevCfg.startWarTime.a[1] * 3600 + sevCfg.startWarTime.a[2] * 60,
            st + 24 * 3600 + sevCfg.startWarTime.b[1] * 3600 + sevCfg.startWarTime.b[2] * 60,
        }
    }

    -- 结束时间延迟180秒,这个时间会用来检测数据是否正常结束,自动修复结果
    local overDelayTs = 180 
    local battleEndTime = {
        battleTime[1][2] + sevCfg.maxBattleTime + overDelayTs,
        battleTime[2][2] + sevCfg.maxBattleTime + overDelayTs,
    }

    return battleTime,battleEndTime
end

-- 获取当前正在进行的轮数,对阵列表,修复数据都需要用到
function areawar.getCurrentRound(st)
    local battleTime,battleTs = getBattleRoundTs (st)
    local maxRound = #battleTime

    for i=1,maxRound do
        if i == 1 and ts <= battleTs[i] then
            return i
        end

        if i == maxRound then
            if ts > battleTs[i] then
                return i + 1
            end
            return i
        end

        if ts > battleTs[i] and ts <= battleTs[i+1] then
            return i + 1
        end
    end
end

-- 获取当前所有正在生效的跨服数据
function areawar.getBidData(areaServerId)
    local bidDatas = {}
    -- local acKey = mkCacheKey(hashBidData)
    -- local data = redis:hgetall(acKey)
    local data = db:getAllRows("select id,bid,round_a,round_b,st,et from areawar_bid where st <= :ts and et > :lts",{ts=ts,lts=ts-86400})

    local config = getConfig("config")
    local areaCount = #config.areacrossserver.connector

    for k,v in pairs(data) do
        local bid = tonumber(string.sub(v.bid, 2))
        local n = bid % areaCount
        if n == 0 then n = areaCount end
        if n == areaServerId then
            table.insert(bidDatas,v)
        end
    end

    return bidDatas
end

-- 按bid获取战斗数据
function areawar.getBidDataByBid(bid)
    return db:getRow("select bid,round_a,round_b,st,et,servers from areawar_bid where bid = :bid",{bid=bid})
end

-- 更新跨服区域战的信息(只能更新轮次和修改时间)
function areawar.updateBidData(bid,data)
    local updateData = {
        round_a=data.round_a,
        round_b=data.round_b,
        updated_at = ts,
    }
    return db:update("areawar_bid",updateData,string.format("bid = '%s'",bid))
end
 
--[[
    增加一条跨服区域战的信息
    数据是从报名表中的数据提取出来的
]]
function areawar.addBidData(bidData)
    bidData.updated_at = ts
    return db:insert("areawar_bid",bidData)
end

--[[
    处理客户端需要的用户数据
]]
function areawar.formatUserDataForClient(data)
    local userdata = {}
    local field = {"carrygems","donate","gems","role","b1","b2","b3","b4"}

    for _,v in pairs(field) do
        if data[v] then
            userdata[v] = data[v]
        end
    end

    unField = nil

    return userdata
end

-- 将用户行动数据处理为前端所需的格式
function areawar.formatUserActionDataForClient(data)
    if type(data) == 'table' then
        return {
            -- v.bid,  -- 区域战唯一标识
            data.uid or 0,  -- 用户uid
            -- data.basePlace,    -- 用户主基地
            -- data.pos,  -- 当前所在的据点，只有用户发生 `占领据点行为` 才会被重新赋值，
            data.target or 0,   -- 目标点
            -- data.st,   -- 向目标出发的起始时间戳
            data.bplace or 0,   -- 用户上次发生战斗的地点
            data.battle_at or 0,    -- 用户上次发生战斗的时间戳
            -- v.ts,   -- 用户行动数据上次发生变化的时间戳
            data.dist or 0, -- 用户到达目标点的时间
            -- v.troops,   -- 用户当前实际的部队情况
            data.revive or 0,  -- 复活时间戳
            data.prev or 0, -- 上次所在城市
            data.enemy or 0,    -- 最近的对手
            tonumber(data.zid) or 0,    -- 服id
            tonumber(data.sn) or 0,     -- 部队编号
            data.heroFlag or "",    -- 英雄标识
            data.HPRate or 100,   -- 部队血值比
            data.winStreak or 0, -- 连胜次数
            data.nickname or '', -- 用户昵称
            data.aid or 0,  -- 用户军团Id
        }
    end
end

--[[
    处理所有用户的行动数据为前端所需格式
]]
function areawar.formatUsersActionDataForClient(actionData)
    local data = {}
    for k,v in pairs(actionData) do
        local tmp = areawar.formatUserActionDataForClient(v)
        if #tmp >= 10 then
            table.insert(data,tmp)
        end
    end

    return data
end

--[[
    处理据点数据为前端所需格式
    1是据点归属,2是NPC部队数据(0是无,1是有),boss要展示血条
]]
function areawar.formatPlaceDataForClient(placeinfo)
    local data = {(placeinfo[1] or 0),(placeinfo[2] == '-NPC' and 0 or 1)}
    if placeinfo[3] then
        data[3] = placeinfo[3]
    end

    return data
end

-- 处理所有据点数据为前端所需格式
function areawar.formatPlacesDataForClient(placesInfo)
    local data = {}

    for k,v in pairs(placesInfo) do 
        data[k] = areawar.formatPlaceDataForClient(v)
    end

    return data
end

-- 处理所有军团的数据为前端所需格式
function areawar.formatAlliancesDataForClient(alliancesData)
    local data = {}

    for k,v in pairs(alliancesData or {}) do 
        data[k] = {
            v.aid,
            v.zid,
            v.name,
            v.commander,    -- 军团长名
            v.ladderpoint,  -- 天梯榜积分
            v.fight,    -- 军团战力
        }
    end

    return data
end

--[[
    玩家进入战场,按aid存储玩家集合,并且按all存一份所有玩家的uid,
    按军团推送或全地图推送数据时用到此集合

    param int uid 玩家id
    param int aid 玩家军团id
    param int zid 玩家的服id
]]
function areawar.joinAreaWar(bid,uid,aid,zid)
    local aidKey = mkKey(zid,aid)
    local acKey1 = mkCacheKey(setAllianceMemId,bid,aidKey)
    local acKey2 = mkCacheKey(setAllianceMemId,bid,'all')

    redis:sadd(acKey1,uid)
    redis:sadd(acKey2,uid)
    redis:expire(acKey1,expireTs)
    redis:expire(acKey2,expireTs)
end

--[[
    获取进入战场的成员
    有军团id就查军团的成员,否则查战场上的所有成员

    params int aid 军团id
]]
function areawar.getAllianceMemUids(bid,aid,zid)
    local aidKey = aid and mkKey(zid,aid) or 'all'
    return redis:smembers(mkCacheKey(setAllianceMemId,bid,aidKey))
end

--[[
    获取以uid的字符串为key标识的所有用户的行动数据所
    会顺带将所有用户id加入到推送列表
]]
function areawar.getUsersActionInfo(bid)
    if not usersActionData then
        usersActionData = {}

        local acKey = mkCacheKey(hashBidActions,bid)
        local data = redis:hgetall(acKey)

        if type(data) == 'table' and next(data) then
            for k,v in pairs(data) do
                local userActionData = json.decode(v)
                if type(userActionData) == 'table' and userActionData.uid and type(userActionData.binfo) == 'table' and userActionData.binfo[2][userActionData.sn] and next(userActionData.binfo[2][userActionData.sn]) then
                    usersActionData[tostring(k)] = userActionData
                    addPushUser(userActionData.uid)
                end
            end
        end
    end

    return usersActionData
end

--[[
    设置一组所有参战军团的详细信息数据到缓存
    组名需要传进来,首次获取军团信息时会以数据库实际数据分组后,分别按组存进缓存
    因此取当前战场的默认组会有问题
    
    param string groupName 组名
    param table alliancesData 该组所有军团的数据
]]
local function setAllianceDataToCache(bid,groupName,alliancesData)
    local stringBidAllianceKey = mkCacheKeyByGroup(groupName,stringBidAlliance,bid)

    if type(alliancesData) == 'table' and next(alliancesData) then
        redis:set(stringBidAllianceKey,json.encode(alliancesData))
        redis:expire(stringBidAllianceKey,expireTs)
    end
end

-- 按bid从缓存获取本次参战的所有军团数据
local function getAlliancesDataFromCache(bid)
    local stringBidAllianceKey = mkCacheKey(stringBidAlliance,bid)
    local cacheData =  redis:get(stringBidAllianceKey)
    if type(cacheData) == 'string' then
        return json.decode(cacheData)
    end
end

--[[
    按bid从数据库获取所有的参战军团数据
    获取的数据是按zid,fight倒序排好后的
]]
local function getAlliancesDataFromDb(bid)
    return db:getAllRows("select logo,zid,aid,name,fight,pos,point,round,apply_at,battle_at,servers,log,commander,ladderpoint from areawar_alliance where bid=:bid order by zid,fight desc",{bid=bid})
end

--[[
    修改军团数据,每天只会进行一场战斗,加上了battle_at的判断
]]
function areawar.updateAllianceData(bid,data)
    data.updated_at = ts
    return db:update("areawar_alliance",data,string.format("bid = '%s' and zid = '%s' and aid = '%s' and battle_at <  '%s'",bid,data.zid,data.aid,weets))
end

--[[
    增加军团数据到数据库
    从报名表读取到本次跨服战报名成功的所有数据后一起设置
]]
function areawar.addAllinaceDataToDb(bid,data)
    for k,v in pairs(data) do
        v.updated_at = getClientTs()
        db:insert("areawar_alliance",v)
    end
end

--[[
    获取军团已占领的据点的BUFF效果
    本次占领的据点不提供buff,所以计算BUFF时要用上一轮据点信息

    param mixed placeId 有据点标识,表示获取要塞对防守部队提供的buff
]]
local function getAllianceBuff(zid,aid,placeId)
    local buff = {}

    local function tmpSetBuff(buffValue)
        for bfKey,bfVal in pairs(buffValue) do
            if not buff[bfKey] then
                buff[bfKey] = bfVal 
            else
                buff[bfKey] = buff[bfKey] + bfVal
            end
        end
    end

    if type(originalPlacesInfo) == 'table' then
        local aidKey = mkKey(zid,aid)
        for k,v in pairs(originalPlacesInfo) do
            if aidKey == v[1] then
                if localWarMapCfg.cityCfg[k].buff then
                    tmpSetBuff(localWarMapCfg.cityCfg[k].buff)
                end

                -- 如果是当前战斗的据点,并且当前据点有要塞buff(buff2字段)
                if placeId and k == placeId and localWarMapCfg.cityCfg[k].buff2 then
                    tmpSetBuff(localWarMapCfg.cityCfg[k].buff2)
                end
            end
        end

        -- 首杀BOSS的BUFF效果
        -- 需要判断生效时间是否过期
        if originalPlacesInfo[localWarMapCfg.bossCity][4] == aidKey and ((originalPlacesInfo[localWarMapCfg.bossCity][5] or 0) + areaWarCfg.nest.time ) > ts then
            tmpSetBuff(areaWarCfg.nest.buff)
        end
    end

    return buff
end

-- 判断给定的uid是否是一个npc
local function isNpc(uid)
    return tonumber(uid) == tonumber(baseNpc.uid)
end

-- 是否是BOSS
local function isBoss(placeId)
    return localWarMapCfg.bossCity == placeId
end

--[[
    增加玩家部队在一轮据点争夺中的战斗次数,用来计算围攻(npc不会被围攻)

    param int uid 玩家id
    param int sn 玩家部队编号
]]
local function incrUserBattleCount(zid,uid,sn)
    if not isNpc(uid) then 
        local key = mkKey(zid,uid,sn)
        userBattleCount[key] = (userBattleCount[key] or 0) + 1
    end
end

--[[
    为军团增加指定的战场分

    param string bid 战场标识
    param string aidkey 军团唯一标识
    param int point 战场分(据点/任务/击杀BOSS产生)
    return int 本次增加后的军团总积分
]]
local function incrAllianceWarPoint(bid,aidkey,point)
    if point >= 0 then
        local cacheKey = mkCacheKey(hashAlliancePointInfo,bid)
        local p = redis:hincrby(cacheKey,aidkey,math.floor(point))
        redis:expire(cacheKey,expireTs)

        return p
    end
end

--[[
    增加用户的贡献分
    会按照用户的军团进行保存,只有最终结算的时候数据才会入库
    数据格式:{
                aidKey1={
                    uid1=donate1,
                    uid2=donate2,
                },
                aidKey2={
                    uid1=donate1,
                    uid2=donate2,
                },
            }
]]
local function addUserDonate(zid,uid,aid,donate)
    if not isNpc(uid) and donate > 0 then
        local aidKey = mkKey(zid,aid)
        if not usersDonate[aidKey] then 
            usersDonate[aidKey] = {} 
        end

        uid = tostring(uid)
        usersDonate[aidKey][uid] = (usersDonate[aidKey][uid] or 0) + donate
    end
end

-- 增加用户的连胜次数(连败会被清除)
function areawar.incrUserWinStreak(userActionInfo)
    userActionInfo.winStreak = (userActionInfo.winStreak or 0) + 1
    areawar.clearUserDeathCount(userActionInfo)
end

-- 清除用户的连胜次数
function areawar.clearUserWinStreak(userActionInfo)
    userActionInfo.winStreak = nil
end

-- 增加用户的失败次数(连胜会被清除)
function areawar.incrUserDeathCount(userActionInfo)
    userActionInfo.death = (userActionInfo.death or 0) + 1
    areawar.clearUserWinStreak(userActionInfo)
end

-- 清除用户的失败次数
function areawar.clearUserDeathCount(userActionInfo)
    userActionInfo.death = nil
end

-- 获取用户连续死亡BUFF
local function getUserDeathBuff(userActionInfo)
    local deathCount = tonumber(userActionInfo.death) or 0
    if deathCount > 0 then
        if deathCount > areaWarCfg.deathBuff.times then
            deathCount = areaWarCfg.deathBuff.times
        end

        local buff = copyTab(areaWarCfg.deathBuff.buff)
        for k,v in pairs(buff) do
            buff[k] = v*deathCount
        end

        return buff
    end
end

--[[
    获取用户连续战斗的debuff(围攻)

    param int zid 
    param int uid
    param int sn 用户部队编号
    return table
]] 
local function getDebuffByBattleCount(zid,uid,sn)
    if not isNpc(uid) then 
        local key = mkKey(zid,uid,sn)
        local battleCount = userBattleCount[key] or 0

        if battleCount > 0 then
            local rate = math.pow((1 - areaWarCfg.reducePercentage),battleCount)
            return {
                [100]=rate,
                [108]=rate,
            }
        end
    end
end

-- 获取军团报名的排行信息(按报名时间),供分配主基地时使用
local function getAllianceApplyRankInfo(allianceData)
    local applyTsForRank = {}

    if type(allianceData) == 'table' then
        local tmpTable = {}
        for k,v in pairs(allianceData) do
            table.insert(tmpTable,{mkKey(v.zid,v.aid),tonumber(v.apply_at),tonumber(v.aid),tonumber(v.zid)})
        end

        table.sort(tmpTable,function(a,b) 
            if a[2]==b[2] then
                if a[3]==b[3] then
                    return a[4]<b[4] 
                else
                    return a[3]<b[3]
                end
            else
                return a[2]<b[2] 
            end
        end
        )

        for k,v in pairs(tmpTable) do
            applyTsForRank[v[1]] = k
        end

        tmpTable = nil
    end

    return applyTsForRank
end

--[[
    按报名时间的排名获取军团的主基地标识

    param int ranking 报名时间的排名
    return string
]]
local function getBasePlaceByRanking( ranking )
    local basePlace = localWarMapCfg.baseCityID[tonumber(ranking)]
    assert(basePlace ~= nil,'base place error')

    return basePlace
end

--[[
    按用户的binfo获取当前血量值信息
    返回血量比的百分比部分数值(80%->80),满血量,当前血量

    param int sn 部队编号
    param table binfo 部队详细数据
    param table currTroops 当前剩余部队数
    return int,int,int
]]
local function getHPInfoByBinfo(sn,binfo,currTroops)
    local fullHP = 0
    local currHP = 0
    local HPRate = 100

    if type(binfo) == 'table' and next(binfo) then
        local hpIndex
        local numIndex
        for k,v in pairs(binfo[1]) do
            if v == 'maxhp' then
                hpIndex = k
            elseif v == 'num' then
                numIndex = k
            end

            if hpIndex and numIndex then 
                break 
            end
        end

        sn = tonumber(sn)
        if type(binfo[2]) == 'table' and binfo[2][sn] then
            for k,v in pairs(binfo[2][sn]) do
                if next(v) then
                    fullHP = fullHP + (tonumber(v[hpIndex]) or 0) * (tonumber(v[numIndex]) or 0)
                end
            end

            if type(currTroops) == 'table' then
                for k,v in pairs(binfo[2][sn]) do
                    if next(v) and currTroops[k] then
                        currHP = currHP + (tonumber(v[hpIndex]) or 0) * (tonumber(currTroops[k][2]) or 0)
                    end
                end
            end
        end
    end

    if not currTroops then
        currHP = fullHP
    end

    if fullHP > 0 and currHP > 0 then
        HPRate = math.floor((currHP / fullHP * 100) * 100) / 100
    end

    return HPRate,fullHP,currHP
end

-- 获取部队的英雄标识(前端以此作为部队的显示头像)
local function getHeroFlagByBinfo(sn,binfo)
    if type(binfo) == 'string' then
        binfo = json.decode(binfo)
    end

    sn = tonumber(sn)
    if type(binfo) == 'table' and type(binfo[3]) == 'table' and type(binfo[3][sn]) == 'table' then
        for k,v in pairs(binfo[3][sn]) do
            if type(v) == 'string' and v ~= "" then
                local heroIndexInfo = string.split(v,'-')
                return heroIndexInfo[1]
            end
        end
    end
end

function areawar.getHeroFlagByBinfo(sn,binfo)
    return getHeroFlagByBinfo(sn,binfo)
end

------------------------------------------------------------------------

-- 用户是否是一个NPC
function areawar.isNpc(uid)
    return isNpc(uid)
end

-- 生成标识key
function areawar.mkKey(...)
    return mkKey(...)
end

-- 从数据库获取所有参战军团的信息
function areawar.getAlliancesDataFromDb(bid)
    return getAlliancesDataFromDb(bid)
end

-- 从数据库获取所有报名的军团数据
function areawar.getApplyDataFromDb(bid)
    return db:getAllRows("select logo,bid,zid,aid,name,fight,apply_at,commander,score as ladderpoint,st,et,servers from areawar_apply where bid=:bid  ORDER BY fight DESC , apply_at ASC",{bid=bid})
end

-- 将军团数据格式化为以zidAid为标识key的table
local function formatAllianceData(alliancesData)
    if type(alliancesData) == 'table' then
        areawarAllianceList = {}
        for k,v in pairs(alliancesData) do
            if v.zid and v.aid then
                areawarAllianceList[mkKey(v.zid,v.aid)] = v
            end
        end
    end

    alliancesData = nil

    return areawarAllianceList
end

--[[
    获取参战军团的详细数据
    首次获取时会为每个军团分配主基地,并且数据进缓存
    主基地所在的据点信息会分配给军团,据点信息保存至缓存
    key是zidAid的字符串类型
]]
function areawar.getAlliancesData(bid)
    if next(areawarAllianceList) then 
        return areawarAllianceList
    end

    local alliancesData = getAlliancesDataFromCache(bid)
    if type(alliancesData) == 'table' and next(alliancesData) then
        return formatAllianceData(alliancesData)
    end

    alliancesData = getAlliancesDataFromDb(bid)
    local matchList = areawar.mkMatchList(alliancesData)

    for gname,gdata in pairs(matchList) do
        if type(gdata) == 'table' and next(gdata) then
            -- 该组内的军团按报名时间排出名次
            local applyTsForRank = getAllianceApplyRankInfo(gdata)

            -- 记录主基地据点信息
            local basePlacesInfo = {}
            for k,v in pairs(applyTsForRank) do
                local basePlace = getBasePlaceByRanking(v)
                basePlacesInfo[basePlace] = {k,"NPC"}
            end 

            -- 按组设置据点信息到缓存
            if next(basePlacesInfo) then
                local acKey = mkCacheKeyByGroup(gname,hashBidPlaces,bid)

                local tmp = {}
                for k,v in pairs(basePlacesInfo) do
                    tmp[k] = json.encode(v)
                end

                if next(tmp) then
                    redis:hmset(acKey,tmp)
                    redis:expire(acKey,expireTs)
                end

                tmp = nil
            end

            -- 按组设置军团信息到缓存
            setAllianceDataToCache(bid,gname,gdata)

            basePlacesInfo = nil
        end
    end

    if type(matchList) == 'table' and matchList[group] then
        return formatAllianceData(matchList[group])
    end

    alliancesData = {}

    return alliancesData
end

--[[
    获取主基地信息(有军团标识时,返回该军团的主基地id)

    param int bid 区域战标识
    param string aidKey 军团标识
    return string|table
]] 
function areawar.getAllianceBasePlace(bid,aidKey)
    local aidForBase = {}

    local allianceData = areawar.getAlliancesData(bid)
    local applyTsForRank = getAllianceApplyRankInfo(allianceData)

    for k,v in pairs(applyTsForRank) do
        aidForBase[k] = getBasePlaceByRanking(v)
    end

    if aidKey then
        return aidForBase[aidKey]
    end

    return aidForBase
end

-- 获取NPC的初始数据
local function getNpcInfo()
    local npc = copyTab(baseNpc)
    npc.binfo = json.decode(npc.binfo)
    return npc
end

-- 从数据库获取单个用户的数据
local function getUserDataFromDb(bid,uid,aid,zid)
    return db:getRow("select * from areawar_members where bid=:bid and uid=:uid and aid=:aid and zid=:zid",{bid=bid,uid=uid,aid=aid,zid=zid})
end

-- 从数据库获取军团用户列表
function areawar.getUserListFromDb(bid,zid,aid)
    return db:getAllRows("select * from areawar_members where bid=:bid and aid=:aid and zid=:zid",{bid=bid,aid=aid,zid=zid})
end

function areawar.getUserInFo(battleid,zid,uid,aid)
   return  db:getRow("select gems,point from areawar_members where bid=:bid and uid=:uid and aid=:aid and zid=:zid",{bid=battleid,uid=uid,aid=aid,zid=zid})
end

--[[
    设置用户的数据到缓存
    用户是唯一的,无需按组区分,取用户缓存数据时也不要按组取
]]
local function setUserDataToCache(bid,data)
    local memKey = mkNotGroupCacheKey(hashBidMember,bid)
    local uidKey = mkKey(data.zid,data.uid)
    redis:hset(memKey,uidKey,json.encode(data))
    redis:expire(memKey,expireTs)
end

--[[
    删除用户缓存数据
    战斗过程中,玩家可能带军饷或者另外增加部队(可带3只),数据是差量传过来的,修改麻烦
    直接删掉,读的时候重新设置进缓存
]]
local function delUserDataFromCache(bid,zid,uid)
    local memKey = mkNotGroupCacheKey(hashBidMember,bid)
    local uidKey = mkKey(zid,uid)
    redis:hdel(memKey,uidKey)
end

-- 插入跨服战用户数据
function areawar.setUserBattleData(data)
    local ret, err

    data.updated_at = getClientTs()
    ret = db:insert("areawar_members",data)

    if ret then 
        setUserDataToCache(data.bid,data)
    else
        err = db:getError()
    end

    return ret, err
end

function areawar.getUserDataFromDb(bid,zid,aid,uid)
    return getUserDataFromDb(bid,uid,aid,zid)
end

--[[
    初始化玩家新带进战场的部队
    玩家一共可以带3只部队开战前不一定带齐,战斗的过程中带进来需要初始化一下

    param table data 玩家数据
    param int sn 新增的部队编号
]]
local function initUserNewTroop(data,sn)
    sn = tonumber(sn) or 0
    if sn > 0 then 
        local binfo = data.binfo
        if type(binfo) == 'string' then
           binfo = json.decode(binfo)
        end

        if type(binfo) == 'table' and binfo[2] and binfo[2][sn] and next(binfo[2][sn]) then
            local uidKey = mkKey(data.zid,data.uid,sn)
            local acKey = mkCacheKey(hashBidActions,data.bid)

            -- 判断在战场上是否已经有此只部队数据存在
            if not redis:hexists(acKey,uidKey) then
                areawar.resetUserActionInfo({bid=data.bid,uid=data.uid,sn=sn},data,true)
            end
        end

        binfo = nil
    end
end

--[[
    修改跨服战用户数据
    如果用户分次带部队进来,需要分别对每只部队的行动数据初始化

    param int addTroopSN 新增的部队编号
]]
function areawar.updateUserBattleData(data,addTroopSN)
    local ret, err

    data.updated_at = getClientTs()
    ret = db:update("areawar_members",data,string.format("bid = '%s' and zid = '%s' and aid = '%s' and uid = '%s'",data.bid,data.zid,data.aid,data.uid))
    
    if not ret or ret <= 0 then
        err = db:getError()
        ret = false
    else
        delUserDataFromCache(data.bid,data.zid,data.uid)
        if addTroopSN then
            initUserNewTroop(data,addTroopSN)
        end
    end

    return ret, err
end

--[[
    增加用户的商店积分和功绩分
    因为分数都是累加,在程序里做需要先取出再相加,所以直接用数据库来做了
]]
function areawar.addUserPointAndDonateToDb(data)
    if data.bid and data.zid and data.uid and data.point and data.donate then
        local sql = "update areawar_members set point=point+%d,donate=donate+%d where bid='%s' and zid='%s' and uid='%s' limit 1"
        sql = string.format(sql,tonumber(data.point),tonumber(data.donate),data.bid,data.zid,data.uid)
        db:query(sql)
    end
end

--[[
    获取参战玩家的数据
    如果是NPC直接返回npc的标准数据
    先取缓存,缓存没有读数据库后添加到缓存
]]
function areawar.getUserData(bid,uid,aid,zid)
    if isNpc(uid) then 
        return getNpcInfo()
    end

    local uidKey = mkKey(zid,uid)

    if type(usersData) == 'table' and usersData[uidKey] then
        return usersData[uidKey]
    end

    local memKey = mkNotGroupCacheKey(hashBidMember,bid)
    local data = redis:hget(memKey,uidKey)
    if type(data) == 'string' then
        data = json.decode(data)
    end

    local setCache = false
    if not data or not data.binfo then
        data = getUserDataFromDb(bid,uid,aid,zid)
        setCache = true
    end

    if type(data) == 'table' and data.binfo then
        if type(data.binfo) ~= 'table' then
            data.binfo = json.decode(data.binfo)
        end

        if setCache then
            setUserDataToCache(bid,data)
        end

        usersData[uidKey] = data
    end

    return data
end

-- 设置战斗结束标识
function areawar.setOverBattleFlag(bid,winner)
    winner = winner or 0
    local overKey = mkCacheKey(stringBattleOverFlag,bid)
    local ret = redis:set(overKey,winner) or redis:set(overKey,winner)
    redis:expire(overKey,expireTs)
end

-- 获取战斗结束标识
function areawar.getOverBattleFlag(bid)
    local overKey = mkCacheKey(stringBattleOverFlag,bid)
    local flag = redis:get(overKey)

    return flag
end

--[[
    设置玩家每只部队的行动信息

    param string bid 跨服区域战标识
    param table data 玩家完整数据
    param bool saveFlag 是否立即保存到缓存
    return bool,table
]]
function areawar.setUserActionInfo(bid,data,saveFlag)
    assert(data.sn,'setAction need serial number')

    local ts = os.time()
    local aidKey = mkKey(data.zid,data.aid)
    local uidKey = mkKey(data.zid,data.uid,data.sn)

    -- 没有主基地时,分配主基地
    if not data.basePlace or data.basePlace == 0 then
        data.basePlace = areawar.getAllianceBasePlace(bid,aidKey)
    end

    -- 没有目标以自己的主基地为目标,抵达时间为当前时间
    if not data.target or data.target == 0 then
        data.target = data.basePlace
        data.dist = ts
    end

    -- 战斗时间为当前
    if not data.battle_at then 
        data.battle_at = ts
    end

    data.ts = ts

    if type(usersActionData) == 'table' then
        usersActionData[uidKey] = data
    end

    -- 需要立即保存
    local ret
    if saveFlag then
        local acKey = mkCacheKey(hashBidActions,bid)
        ret = redis:hset(acKey,uidKey,json.encode(data))
        redis:expire(acKey,expireTs)
    end

    return ret,data
end

--[[
    重置玩家部队的行动信息
]]
function areawar.resetUserActionInfo(data,userinfo,saveFlag)
    if type(userinfo.binfo) ~= 'table' then
        userinfo.binfo = json.decode(userinfo.binfo)
    end

    if not data then 
        data = {} 
    end

    data.basePlace = data.basePlace or 0
    data.st=ts
    data.dist=ts
    data.binfo=userinfo.binfo
    data.aid=userinfo.aid
    data.level=userinfo.level
    data.nickname=userinfo.nickname
    data.aname=userinfo.aname or ''
    data.zid = userinfo.zid
    data.uid = userinfo.uid
    data.troops=nil
    data.target=nil
    data.death = userinfo.death

    -- 每个部队都需要一个英雄标识
    data.heroFlag = getHeroFlagByBinfo(data.sn,userinfo.binfo)
    
    return areawar.setUserActionInfo(data.bid,data,saveFlag)
end

-- 获取用户当前行动信息
function areawar.getUserActionInfo(bid,uid,aid,zid)
    local userActionData = {}

    local acKey = mkCacheKey(hashBidActions,bid)
    local uidActionKeys = {}
    for sn=1,areawar.TROOP_COUNT do
        table.insert(uidActionKeys,mkKey(zid,uid,sn))
    end

    local data = redis:hmget(acKey,uidActionKeys)
    
    if type(data) == 'table' and next(data) then
        for _,v in pairs(data) do
            v = json.decode(v)
            if type(v) == 'table' then
                userActionData[mkKey(v.zid,v.uid,v.sn)] = v
            end
        end
    end

    if not next(userActionData) then
        local userinfo = areawar.getUserData(bid,uid,aid,zid)
        if userinfo and type(userinfo.binfo) =='table' then
            local tmpUserActionDataJson = {}

            for sn,snInfo in pairs(userinfo.binfo[2]) do
                if type(snInfo) == 'table' and next(snInfo) then
                    local uidActionKey = mkKey(zid,uid,sn)
                    local setret, setdata = areawar.resetUserActionInfo({bid=bid,uid=uid,sn=sn},userinfo)
                    tmpUserActionDataJson[uidActionKey] = json.encode(setdata)
                    userActionData[uidActionKey] = setdata
                end
            end

            if next(tmpUserActionDataJson) then
                local acKey = mkCacheKey(hashBidActions,bid)
                local ret = redis:hmset(acKey,tmpUserActionDataJson)
                redis:expire(acKey,expireTs)

                tmpUserActionDataJson = nil

                if ret then
                    return userActionData,true
                end
            end
        end
    end
    
    return userActionData
end

-- 获取玩家单只部队的行动信息
function areawar.getUserTroopActionInfo(bid,uid,aid,zid,sn)
    local snKey = mkKey(zid,uid,sn)
    if type(usersActionData) == 'table' and usersActionData[snKey] then
        return usersActionData[snKey]
    end

    local acKey = mkCacheKey(hashBidActions,bid)
    local data = redis:hget(acKey,snKey)

    if data then
        data = json.decode(data)
    end

    return data
end

-- 如果据点不是野怪，并且没有人防守，补一个NPC,
-- 如果据点是野怪直接放NPC战斗
-- params userList table 据点当前的人员列表
-- params boolean checkNpc 是否检测NPC
-- return 队列中的第一个用户和队列总用户数（如果攻打主基地，需要攻城部队数*基础掉血量来计算）
function areawar.getPlaceBattleList(placeId,ownerAid,userList,checkNpc)
    local battleList =  {
        -- 攻击方与防守方的战斗队列
        defenser={},    
        attacker={},

        -- 按aid分组记录当前占斗队列中的攻击方与防守方
        -- aid2attacker={},
        -- aid2defenser={},

        -- 记录当前军团是否有预备队
        aHasReserve={},
        dHasReserve={},
    }

    local queueNum = areaWarCfg.battleQueue

    if type(userList) == 'table' then
        table.sort(userList,function(a,b)
            if a.dist == b.dist then                    
                if a.uid == b.uid then
                    return tonumber(a.sn) < tonumber(b.sn)
                else
                    return tonumber(a.uid) < tonumber(b.uid)
                end
            else
                return tonumber(a.dist) < tonumber(b.dist)
            end
        end)

        for k,v in pairs(userList) do
            local aidKey = mkKey(v.zid,v.aid)
            -- local uidKey = mkKey(v.zid,v.uid,v.sn)
            if aidKey == tostring(ownerAid) then
                if #battleList.defenser < queueNum then
                    table.insert(battleList.defenser,v)
                    -- if not battleList.aid2defenser[aidKey] then
                    --     battleList.aid2defenser[aidKey] = {}
                    -- end
                    -- table.insert(battleList.aid2defenser[aidKey],uidKey)
                else
                    battleList.dHasReserve[aidKey] = true
                end
            else
                if #battleList.attacker < queueNum then
                    table.insert(battleList.attacker,v)
                    -- if not battleList.aid2attacker[aidKey] then
                    --     battleList.aid2attacker[aidKey] = {}
                    -- end
                    -- table.insert(battleList.aid2attacker[aidKey],uidKey)
                else
                    battleList.aHasReserve[aidKey] = true
                end
            end
        end
    end

    if checkNpc then
        local defenserNpc = areawar.getPlaceNpc(placeId)
        if defenserNpc then
            -- 中立城市
            if tonumber(ownerAid) == 0 then
                table.insert(battleList.defenser,defenserNpc)
            else
                -- 战斗队列是否已满,决定塞到战斗队列还是预备队列
                if #battleList.defenser < queueNum then
                    table.insert(battleList.defenser,defenserNpc)
                else
                    local npcAidKey = mkKey(defenserNpc.zid,defenserNpc.aid)
                    battleList.dHasReserve[npcAidKey] = true
                end
            end
        end
    end
    
    return battleList
end

--[[
    部队是否在战斗队列中

    param int zid 
    param int uid 
    param int sn 
    param table queue
    return bool
]]
function areawar.troopInBattleQueue(zid,uid,sn,queue)
    for k,v in pairs(queue) do
        if tonumber(v.uid) == tonumber(uid) and tonumber(v.sn) == tonumber(sn) and tonumber(v.zid) == tonumber(zid) then
            return true
        end
    end
end

--[[
    获取所有的以据点为单元的玩家部队列表
    example:
        {
            a1={
                userActionInfo1,
                userActionInfo2,
            },
            a2={
                userActionInfo3,
                userActionInfo4,
            },
        }
]]
function areawar.getPlacesUserList(bid)
    local battlePlaces = {}
    local ts = os.time()

    -- 所有用户行动信息
    local usersActionInfo = areawar.getUsersActionInfo(bid)
    if type(usersActionInfo) ~= 'table' then
        return battlePlaces
    end

    -- 抵达目标并且已经复活的玩家部队添加至对应的目标据点部队列表中
    for _,userActionInfo in pairs(usersActionInfo) do
        if userActionInfo.binfo[2][userActionInfo.sn] and next(userActionInfo.binfo[2][userActionInfo.sn]) and userActionInfo.dist <= ts and userActionInfo.target and (userActionInfo.revive or 0) <= ts then
            if not battlePlaces[userActionInfo.target] then
                battlePlaces[userActionInfo.target] = {}
            end

            table.insert(battlePlaces[userActionInfo.target],userActionInfo)
        end
    end

    return battlePlaces
end

----------------------------------------------------------------------------

--[[
    战斗在当天的起始与结束时间
    战场开启/到时结算/任务周期刷新都会用到此

    return int,int
]]
function areawar.getBattleTs()
    local group = areawar.getWarGroup()
    local startTs = getWeeTs() + areaWarCfg.startWarTime[group][1] * 3600 + areaWarCfg.startWarTime[group][2] * 60
    local endTs = startTs + areaWarCfg.maxBattleTime
    return startTs,endTs
end

-- 设置军团指令
function areawar.setAllianceCommand(bid,zid,aid,command)
    if type(command) == 'table' then
        local aidKey = mkKey(zid,aid)
        local acKey = mkCacheKey(hashAllianceCommandMsg,bid)
        local commandMsgs = redis:hset(acKey,aidKey,json.encode(command))
        redis:expire(acKey,expireTs)
    end
end

-- 获取军团指令
function areawar.getAllianceCommand(bid,zid,aid)
    local acKey = mkCacheKey(hashAllianceCommandMsg,bid)
    local commandMsgs = redis:hget(acKey,mkKey(zid,aid))
    commandMsgs = json.decode(commandMsgs)

    if type(commandMsgs) ~= 'table' then
        commandMsgs = {}
    end

    return commandMsgs
end

--[[
    保证一个周期内只执行一次战斗
    
    param string runId 执行请求的标识,跨服战的所有数据比较多,会同时让多个请求来处理
]]
function areawar.battleRunFlag(runId)
    local key = "areateamwarserver.battleAt." .. tostring(runId)
    local ts = os.time()
    redis:watch(key)
    local lastAt = redis:get(key)
    lastAt = tonumber(lastAt) or 0
    local diffBattleAt = ts - lastAt
    -- 这里减2是因为linux定时是每分钟的第1秒才开始走,第二次用sleep定在了20
    if diffBattleAt < areaWarCfg.cdTime-2 then
        return false
    end

    redis:multi()
    redis:set(key,ts)       
    redis:expire(key,areaWarCfg.cdTime-2)
    return redis:exec()
end

-- 按上次出战位置获取本次战斗队列中的出战位置
function areawar.getBattleSlot( lastSlot,queue )
    if not lastSlot then return nil end

    local queueNum = #queue

    if queueNum == 1 and queue[1] then 
        return 1 
    end

    local slot = lastSlot + 1
    if slot > queueNum then
        slot = 1
    end

    for i=slot,queueNum do
        if queue[i] then
            return i
        end
    end
end

--[[
    获取所有据点信息
    缓存中没有的据点数据取配置文件
]]
function areawar.getPlacesInfo(bid)
    if not mapPlacesInfo then
        local acKey = mkCacheKey(hashBidPlaces,bid)
        local data = redis:hgetall(acKey)

        mapPlacesInfo = {}
        if type(data) == 'table' and next(data) then
            for k,v in pairs(data) do
                mapPlacesInfo[k] = json.decode(v)
            end
        end

        -- 1是归属(服id_军团id的标识)
        -- 2是NPC部队，如果是字串'NPC'表示是一个完整的部队，额外取一下NPC配置
        -- 3是血量比(boss)
        -- 4是首次击杀此据点的军团(boss)
        -- 5是首次击杀此据点的时间(boss)
        for k,v in pairs(localWarMapCfg.cityCfg) do
            if not mapPlacesInfo[k] then
                mapPlacesInfo[k] = {
                    0,'NPC',
                }

                -- 初始化的BOSS血量百分比是100
                if isBoss(k) then
                    mapPlacesInfo[k][3] = 100
                end
            end
        end

        -- 战斗过程中，会实时改变mapPlacesInfo的值,计算战斗中据点BUFF时只能取上一轮的
        originalPlacesInfo = copyTab(mapPlacesInfo)
    end
    
    return mapPlacesInfo
end

--[[
    获取据点的NPC数据
    如果缓存中没有Npc的部队,表示NPC部队是满编的,用配置文件配的部队
]]
function areawar.getPlaceNpc(placeId)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] and mapPlacesInfo[placeId][2] ~= '-NPC' then
        local npc = getNpcInfo()

        -- 如果据点是BOSS并且没有击杀,需要读取boss兵力配置
        if isBoss(placeId) and not mapPlacesInfo[placeId][4] then
            npc.binfo = json.decode(bossBinfo)
        end

        if type(mapPlacesInfo[placeId][2]) == 'table' then
            npc.troops = mapPlacesInfo[placeId][2]
        end

        return npc
    end
end

-- 设置据点部队(没有此部队的时候NPC部队用配置文件的)
function areawar.setPlaceNpcTroops(placeId,troops,HPRate)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][2] = troops
        if isBoss(placeId) and not mapPlacesInfo[placeId][4] then
            mapPlacesInfo[placeId][3] = HPRate
        end
    end
end

-- 重置据点NPC兵力
-- 'NPC'字串表示一个完整的NPC兵力
function areawar.resetPlaceTroops(placeId)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][2] = 'NPC'
    end
end

-- 清空据点NPC兵力
-- '-NPC'字串表示NPC是死亡的，即此城没有NPC防守
function areawar.clearPlaceTroops(placeId)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][2] = '-NPC'
    end
end

-- 占领据点
-- 野外据点直接按aid占领
-- 主基地和王城的归属需要取打掉城防值最多的攻击方
function areawar.occupyPlace(bid,placeId,aid,zid,uid,allianceName,nickname)
    local aidKey = mkKey(zid,aid)
    local bossKilled = areawar.changePlaceOwner( bid,placeId,aidKey)

    -- boss被击杀,额外获得奖励,并广播消息
    if bossKilled then
        incrAllianceWarPoint(bid,aidKey,areaWarCfg.nest.point)
        addUserDonate(zid,uid,aid,areaWarCfg.nest.devote)
        areawar.setSinglePushData("bossKilled",{nickname,allianceName})
    end

    areawar.clearPlaceTroops(placeId)
    areawar.setBattlePushData({placesInfo=true})
    areawar.checkBattleTask(bid,aidKey,placeId)

    return aidKey
end

--[[
    改变据点的所属军团
    boss据点首次变更需要特殊处理
]]
function areawar.changePlaceOwner( bid,placeId,aidKey )
    local bossKilled = false

    if not mapPlacesInfo then
        areawar.getPlacesInfo(bid)
    end

    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][1] = aidKey

        -- 标记boss基地首次被占领的时间和军团(有一定时间的BUFF加成),清空boss的血量
        if isBoss(placeId) and not mapPlacesInfo[placeId][4] then
            mapPlacesInfo[placeId][3] = 0
            mapPlacesInfo[placeId][4] = aidKey
            mapPlacesInfo[placeId][5] = ts
            
            bossKilled = true
        end
    end

    return bossKilled
end

-- 设置所有据点信息
function areawar.setPlaceInfo(bid,placeId)
    if type(mapPlacesInfo) == 'table' then
        local acKey = mkCacheKey(hashBidPlaces,bid)
        if placeId then
            if mapPlacesInfo[placeId] then
                redis:hset(acKey,placeId,json.encode(mapPlacesInfo[placeId]))
                redis:expire(acKey,expireTs)
            end
        else
            local tmp = {}
            for k,v in pairs(mapPlacesInfo) do
                tmp[k] = json.encode(v)
            end
            redis:hmset(acKey,tmp)
            redis:expire(acKey,expireTs)
        end
    end
end

--------------------------------------------------------------------
-- 任务相关

-- 获取战斗任务
-- 这里要检查是否过期时间
local function getBattleTasks(bid)
    if not next(battleTaskList) then
        local cacheKey = mkCacheKey(stringAllianceTasks,bid)
        local tasks = json.decode(redis:get(cacheKey))
        if type(tasks) == 'table' and tasks.et >= ts then
            battleTaskList = tasks
        end
    end

    return battleTaskList
end

-- 保存任务到缓存 
local function setBattleTasks(bid)
    if type(battleTaskList) == 'table' and next(battleTaskList) then
        local cacheKey = mkCacheKey(stringAllianceTasks,bid)
        redis:set(cacheKey,json.encode(battleTaskList))
        redis:expire(cacheKey,areaWarCfg.quest.CD)
    end
end

-- 产生单个军团的突袭任务
-- aidKey 是zid-aid标识
local function createAllianceRaidTask(aidKey,placesInfo,selectedPlaces)
    if type(placesInfo) ~= 'table' then return end

    -- 备选的任务(已经被另一军团选中,也可以成为我方军团的据点)
    -- 没有找到可以成为任务的据点后,从备用的据点中找一个
    local tmpAlternativePlaces = {}

    local localWarMapCfg = localWarMapCfg
    for k,v in pairs(placesInfo) do
        -- 据点是我方的
        if v[1] == aidKey then
            -- 循环检测当前据点可抵达的据点
            for m,n in pairs(localWarMapCfg.cityCfg[k].adjoin) do
                -- 不是该军团的普通据点会出现在任务中队列中
                if localWarMapCfg.cityCfg[n].type == 1 and placesInfo[n][1] ~= aidKey then
                    if not selectedPlaces[k] then
                        return n
                    else
                        tmpAlternativePlaces[n] = true
                    end
                end
            end
        end
    end

    -- 从备选(已经成为别的军团的任务目标的据点中寻找一个,本身就是乱序的,直接用了next取)
    return (next(tmpAlternativePlaces))
end

--[[
    产生新的突袭任务
    原来的所有突袭任务必定失效
]]
function createBattleTasks(bid)
    local tasks = {}
    local placesInfo =  areawar.getPlacesInfo(bid)
    local allianceDatas = areawar.getAlliancesData(bid)
    
    if type(allianceDatas) == 'table' then
        -- 已被选中的据点
        local tmpSelectedPlaces = {}

        for aidKey in pairs(allianceDatas) do
            local taskPlace = createAllianceRaidTask(aidKey,placesInfo,tmpSelectedPlaces)
            if taskPlace then
                tasks[aidKey] = {taskPlace}
                tmpSelectedPlaces[taskPlace] = true
            end
        end

        tmpSelectedPlaces = nil
    end

    if next(tasks) then
        tasks.et = ts + areaWarCfg.quest.last
    end

    battleTaskList = tasks
end

--[[
    触发战斗任务
    按战斗进行时间计算是否到了刷任务的周期时间
    定时执行时时间可能稍有误差,需要做兼容
]]
function areawar.triggerBattleTask(bid,startBattleTs)
    if not startBattleTs then
        startBattleTs = areawar.getBattleTs()
    end

    -- 加3是因为以前是20秒时跑，现在是17跑了
    local warUptime = ts - startBattleTs + 3
    if warUptime >= areaWarCfg.quest.CD then
        local n = warUptime % areaWarCfg.quest.CD
        -- 容差10秒,在此期间都刷任务
        if n>=0 and n<=10 then
            createBattleTasks(bid)
        end
    end
end

-- 任务完成,第二个位置记录完成时间算任务buff
-- +5是为了保证buff效果会持续到最后一轮(每轮间隔20秒)
local function finishBattleTask(bid,aidkey,task)
    incrAllianceWarPoint(bid,aidkey,areaWarCfg.quest.point)
    task[2] = ts+5
end

-- 检测战斗任务
function areawar.checkBattleTask(bid,aidKey,placeId)
    local tasks = getBattleTasks(bid)
    if tasks[aidKey] and tasks[aidKey][1] == placeId then
        finishBattleTask(bid,aidKey,tasks[aidKey])
    end
end

-- 获取任务提供的buff
local function getTaskBuff(bid,zid,aid)
    local aidKey = mkKey(zid,aid)
    local tasks = getBattleTasks(bid)
    if type(tasks) == 'table' and tasks[aidKey] then
        -- 任务的完成时间+持续时间大于当前时间时,buff效果有效
        if tasks[aidKey][2] and (tonumber(tasks[aidKey][2]) + areaWarCfg.quest.time) > ts then
            return areaWarCfg.quest.buff
        end
    end
end

-- 获取战斗任务
function areawar.getBattleTasks(bid)
    return getBattleTasks(bid)
end

--------------------------------------------------------------------

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
-- buffs 军团占领据点获取的buff加成
-- battleCountDebuff 玩家连续作战的debuff
-- landform 地形
-- deathBuff 玩家死亡buff
-- userBuffs 用户购买的buff
-- taskBuff 任务的buff
local function formatTroops(attField,troops,currTroops,buffs,battleCountDebuff,landform,deathBuff,userBuffs,taskBuff)
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

    local function tmpSetBuff(troop,attribute,bfVal)
        if attribute == "dmg" then
            troop[attribute] = math.ceil(troop[attribute] * (1+bfVal))
        elseif attribute == "maxhp" then
            troop[attribute] = math.ceil(troop[attribute] * (1+bfVal))
            troop.hp = math.ceil(troop.num * troop[attribute])
        elseif attribute == "dmg_reduce" then
            troop[attribute] = troop[attribute] * (1-bfVal)
        else
            troop[attribute] =  troop[attribute] + bfVal
        end
    end

    if type(buffs) == 'table' and next(buffs) then
        for bfKey,bfVal in pairs(buffs) do
            local attribute = attrNumForAttrStr[bfKey]
            for k,v in pairs(attTroops) do
                if v[attribute] then
                    tmpSetBuff(attTroops[k],attribute,bfVal)
                end
            end
        end
    end

    -- 用户购买buff
    if userBuffs then
        local sevbattleCfg = areaWarCfg
        for buff,lv in pairs(userBuffs) do
            lv = tonumber(lv) or 0
            if lv > 0 and buffAttribute[buff] then
                for _,attribute in ipairs(buffAttribute[buff]) do
                    for k,v in pairs(attTroops) do
                        if v[attribute] then
                            if buff == 'b1' then
                                attTroops[k][attribute] =  attTroops[k][attribute] * (1 + sevbattleCfg.buffSkill[buff].per * lv)
                                if attribute == 'maxhp' then
                                    attTroops[k].hp = attTroops[k].num * attTroops[k][attribute]
                                end
                            elseif buff == 'b2' or buff == 'b3' then
                                attTroops[k][attribute] =  attTroops[k][attribute] + (sevbattleCfg.buffSkill[buff].per * lv)
                            end
                        end
                    end
                end
            end
        end
    end

    -- 军团任务buff
    if type(taskBuff) == 'table' then
        for bfKey,bfVal in pairs(taskBuff) do
            local attribute = attrNumForAttrStr[bfKey]
            for k,v in pairs(attTroops) do
                if v[attribute] then
                    tmpSetBuff(attTroops[k],attribute,bfVal)
                end
            end
        end
    end

    -- 玩家的死亡buff
    if type(deathBuff) == 'table' then
        for bfKey,bfVal in pairs(deathBuff) do
            local attribute = attrNumForAttrStr[bfKey]
            for k,v in pairs(attTroops) do
                if v[attribute] then
                    tmpSetBuff(attTroops[k],attribute,bfVal)
                end
            end
        end
    end

    -- 围攻的debuff
    if type(battleCountDebuff) == 'table' then
        for bfKey,bfVal in pairs(battleCountDebuff) do
            local attribute = attrNumForAttrStr[bfKey]
            for k,v in pairs(attTroops) do
                if v[attribute] then
                    if attribute == "dmg" then
                        attTroops[k][attribute] = math.ceil(attTroops[k][attribute] * bfVal)
                    elseif attribute == "maxhp" then
                        attTroops[k][attribute] = math.ceil(attTroops[k][attribute] * bfVal)
                        attTroops[k].hp = math.ceil(attTroops[k].num * attTroops[k][attribute])
                    end
                end
            end
        end
    end

    return  attTroops
end

local function getUserBuffs(bid,uid,aid,zid)
    local userinfo = areawar.getUserData(bid,uid,aid,zid) or {}
    return {
        b1 = tonumber(userinfo.b1) or 0,
        b2 = tonumber(userinfo.b2) or 0,
        b3 = tonumber(userinfo.b3) or 0,
        b4 = tonumber(userinfo.b4) or 0,
    }
end

-- 获取军团占领区提供的复活BUFF
function areawar.getAllianceReviveBuff(aidKey)
    local buff = {}
    local placesInfo =  areawar.getPlacesInfo(bid)

    if type(placesInfo) == 'table' then
        -- local aidKey = mkKey(zid,aid)
        for k,v in pairs(placesInfo) do
            if aidKey == v[1] then
                if localWarMapCfg.cityCfg[k].buff1 then
                    for bfKey,bfVal in pairs(localWarMapCfg.cityCfg[k].buff1) do
                        if not buff[bfKey] then
                            buff[bfKey] = bfVal 
                        else
                            buff[bfKey] = buff[bfKey] + bfVal
                        end
                    end
                end
            end
        end
    end

    return buff
end

-- 按binfo获取三只部队的信息包含英雄
function areawar.getTroopsByBinfo(binfo)
    local troops = {
        {},{},{}
    }
    
    local heros = {
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
    }

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
    end

    local superEquip = {}
    if type(binfo[4]) == "table" then
        superEquip = binfo[4]
    end
    local splaine={}
    if type(binfo[5]) == "table" then
        splaine = binfo[5]
    end
    return troops,heros,superEquip,splaine
end

--[[
    战斗
    用户的行动信息中不包括部队信息和当前用户的buff,
    用户的buff信息会跟着用户的操作变化,又要实时生效,如果放在行动信息中,防止数据被复写就要加锁，太麻烦
    所以这里的用户部队信息和buff信息要从用户数据获取
]] 
function areawar.placeBattle(bid,aUserinfo,dUserinfo,landform,placeId)
    local aTroopIndex = tonumber(aUserinfo.sn)
    local dTroopIndex = tonumber(dUserinfo.sn)  

    local fleetInfo1 = copyTab(aUserinfo.binfo)
    local fleetInfo2 = copyTab(dUserinfo.binfo)

    local aUserBuffs = getUserBuffs(bid,aUserinfo.uid,aUserinfo.aid,aUserinfo.zid)
    local dUserBuffs = getUserBuffs(bid,dUserinfo.uid,dUserinfo.aid,dUserinfo.zid)

    local aAllianceBuffs = getAllianceBuff(aUserinfo.zid,aUserinfo.aid)
    local dAllianceBuffs = getAllianceBuff(dUserinfo.zid,dUserinfo.aid,placeId)

    local aDeathBuff = getUserDeathBuff(aUserinfo)
    local dDeathBuff = getUserDeathBuff(dUserinfo)

    local aTaskBuff = getTaskBuff(bid,aUserinfo.zid,aUserinfo.aid)
    local dTaskBuff = getTaskBuff(bid,dUserinfo.zid,dUserinfo.aid)

    local aBattleCountDebuff = getDebuffByBattleCount(aUserinfo.zid,aUserinfo.uid,aTroopIndex)
    local dBattleCountDebuff = getDebuffByBattleCount(dUserinfo.zid,dUserinfo.uid,dTroopIndex)

    local aFleetInfo = formatTroops(fleetInfo1[1],fleetInfo1[2][aTroopIndex],aUserinfo.troops,aAllianceBuffs,aBattleCountDebuff,landform,aDeathBuff,aUserBuffs,aTaskBuff)
    local defFleetInfo = formatTroops(fleetInfo2[1],fleetInfo2[2][dTroopIndex],dUserinfo.troops,dAllianceBuffs,dBattleCountDebuff,landform,dDeathBuff,dUserBuffs,dTaskBuff)

    local aTroops = getTroopsByInitTroopsInfo(aFleetInfo)
    local dTroops = getTroopsByInitTroopsInfo(defFleetInfo)

    require "lib.battle"

    local report, aInvalidFleet, dInvalidFleet, attSeq, setPoint = {}
    report.d, report.r, aInvalidFleet, dInvalidFleet, attSeq, setPoint = battle(aFleetInfo,defFleetInfo,1)

    local aAliveTroops = getTroopsByInitTroopsInfo(aInvalidFleet)
    local dAliveTroops = getTroopsByInitTroopsInfo(dInvalidFleet)

    local aDieTroops = getDieTroopsByInavlidFleet(aTroops,aAliveTroops)
    local dDieTroops = getDieTroopsByInavlidFleet(dTroops,dAliveTroops)

    aUserinfo.HPRate = getHPInfoByBinfo(aTroopIndex,fleetInfo1,aAliveTroops) 
    dUserinfo.HPRate = getHPInfoByBinfo(dTroopIndex,fleetInfo2,dAliveTroops) 

    report.t = {dTroops,aTroops}
    report.h = {{},{}}

    if fleetInfo1[3] and fleetInfo1[3][aTroopIndex] then
        report.h[2] = fleetInfo1[3][aTroopIndex]
    end

    if fleetInfo2[3] and fleetInfo2[3][dTroopIndex] then
        report.h[1] = fleetInfo2[3][dTroopIndex]
    end

    report.se={0, 0}
    if fleetInfo1[4] and fleetInfo1[4][aTroopIndex] then
        report.se[2] = fleetInfo1[4][aTroopIndex] --a
    end    
    if fleetInfo2[4] and fleetInfo2[4][dTroopIndex] then
        report.se[1] = fleetInfo2[4][dTroopIndex] -- d
    end

    incrUserBattleCount(aUserinfo.zid,aUserinfo.uid,aTroopIndex)
    incrUserBattleCount(dUserinfo.zid,dUserinfo.uid,dTroopIndex)

    return report, aAliveTroops, dAliveTroops, attSeq, setPoint,aDieTroops,dDieTroops
end

-- 获取所有用户的贡献度
function areawar.getUserDonate(bid)
    local acKey = mkCacheKey(stringBidUsersDonate,bid)
    local cacheData = redis:get(acKey)
    cacheData = json.decode(cacheData)

    if type(cacheData) ~= 'table' then 
        cacheData = {} 
    end

    return cacheData,acKey
end

-- 按击毁部队取得贡献值
local function getDonateByTroops(troops)
    local donate = 0
    local point = 0
    local tankCfg = getConfig('tank')

    for k,v in pairs(troops or {}) do
        if tankCfg[k] and tankCfg[k].point and (v or 0) > 0 then
            point = point + tankCfg[k].point * v
        end
    end

    if point > 0 then
        donate = donate + math.floor(math.sqrt(point)/20)
    end
    
    return donate
end

function areawar.addUserDonateByTroop(bid,zid,uid,aid,troops,iswin)
    local donate = getDonateByTroops(troops)
    if iswin then
        donate = donate + areaWarCfg.winDonate
    else
        donate = donate + areaWarCfg.loseDonate
    end

    if donate > 0 then
        addUserDonate(zid,uid,aid,donate)
    end
end

-- 增加用户贡献度
function areawar.addUsersDonate(zid,uids,aid,donate)
    if type(uids) == 'table' then
        for _,uid in pairs(uids) do
            addUserDonate(zid,uid,donate)
        end
    else
        addUserDonate(zid,uids,aid,donate)
    end
end

-- 获取结束时的军团和个人贡献值
-- return 军团总贡献和用户的
function areawar.getEndDonates(bid,zid,aid,iswin)
    local sevbattleCfg = areaWarCfg
    local cfgPoint = iswin and sevbattleCfg.winPoint or sevbattleCfg.losePoint
    local cfgPersonalPoint = iswin and sevbattleCfg.personalWinPoint or sevbattleCfg.personalLosePoint
    local usersDonate = areawar.getUserDonate(bid)

    local zidAid = mkKey(zid,aid)
    local tmpDonate = {}
    local adonates = {}

    if usersDonate[zidAid] then
        adonates[zidAid] = 0

        for uid,donate in pairs(usersDonate[zidAid]) do
            if donate > 0 then
                local uinfo = areawar.getUserData(bid,uid,aid,zid)
                local uBuffs = getUserBuffs(bid,uid,aid,zid)

                if uBuffs.b4 > 0 then
                    donate = donate + donate * uBuffs.b4 * sevbattleCfg.buffSkill.b4.per
                end

                local tDonate = math.sqrt(donate)
                tmpDonate[uid] = tDonate
                adonates[zidAid] = adonates[zidAid] + tDonate
            end
        end
    end
    
    -- 军团上阵的队员
    local teams = areawar.getAllianceMemUids(bid,aid,zid)
    local shopPointInfo = {}
    
    if type(teams) == 'table' then
        shopPointInfo[zidAid] = {}
        local totalDonate = adonates[zidAid] or 0
        totalDonate = totalDonate + (#teams-table.length(tmpDonate)) * 1

        for _,uid in ipairs(teams) do
            uid = tostring(uid)
            local donate = tmpDonate[uid] or 1
            if totalDonate > 0 then
                local rate = donate / totalDonate
                if rate > 0.1 then rate = 0.1 end
                shopPointInfo[zidAid][uid] = math.floor(rate * cfgPoint + cfgPersonalPoint)
            else
                shopPointInfo[zidAid][uid] = cfgPersonalPoint
            end
        end
    end

    return shopPointInfo,usersDonate
end

-- 保存用户的贡献度
function areawar.setUsersDonate(bid)
    if next(usersDonate) then
        local setFlag = false
        local cacheData,acKey = areawar.getUserDonate(bid)

        for aidKey,donateData in pairs(usersDonate) do
            if not cacheData[aidKey] then cacheData[aidKey] = {} end
            for uidKey,donate in pairs(donateData) do
                if donate > 0 then
                    cacheData[aidKey][uidKey] = (cacheData[aidKey][uidKey] or 0) + donate
                    setFlag = true
                end
            end
        end

        if setFlag then
            redis:set(acKey,json.encode(cacheData))
            redis:expire(acKey,expireTs)
        end

        setFlag = nil
        usersDonate = {}

        return cacheData
    end
end

-- 计算军团的战争积分
function areawar.countAllianceWarPoint(bid)
    if not countWarPointFlag then
        local prevRoundPoint = {}
        
        if type(originalPlacesInfo) == 'table' then
            for k,v in pairs(originalPlacesInfo) do
                if v[1] ~= 0 then
                    prevRoundPoint[v[1]] = (prevRoundPoint[v[1]] or 0) + localWarMapCfg.cityCfg[k].winPoint
                end
            end
        end

        local alliancePointInfo = {}
        for k,v in pairs(prevRoundPoint) do
            alliancePointInfo[k] = incrAllianceWarPoint(bid,k,v)
        end

        countWarPointFlag = true
        prevRoundPoint = nil

        return alliancePointInfo
    end
end

-- 获取战场的积分信息
function areawar.getWarPointInfo(bid)
    local cacheKey = mkCacheKey(hashAlliancePointInfo,bid)
    return redis:hgetall(cacheKey)
end

-- 增加区域战战报
function areawar.addBattleReport(data)
    -- table.insert(battleReports,data)
    data.updated_at = ts
    db:insert("areawar_battlelog",data)
end

-- 设置区域战战报
local function setBattleReport()
    -- for k,v in pairs(battleReports) do
    --     v.updated_at = ts
    --     db:insert("areawar_battlelog",v)
    --     battleReports[k] = nil
    -- end
end


-- 报名
function areawar.apply(data)
    data.updated_at=getClientTs()
    local ret = db:insert('areawar_apply',data)
    if ret and ret>=1 then
        local applykey=string.format(stringApplyInfo,data.bid)
        redis:del(applykey)
    end
    return ret
end

-- 
function areawar.getApplyRank(bid)
    local applykey=string.format(stringApplyInfo,bid)
    local cacheData =  redis:get(applykey)

    if cacheData ~=nil and type(cacheData) == 'string'  then
        return json.decode(cacheData)
    else
        local result= db:getAllRows("select zid,aid,name,fight,apply_at,commander,score from areawar_apply where bid=:bid  ORDER BY fight DESC , apply_at ASC",{bid=bid})
        if result==nil then
            result={}
        end
        redis:set(applykey,json.encode(result))
        redis:expire(applykey,expireTs)
        return result
    end
end

------------------------------------------------------------

local function setRepairDataToDb(bid,allianceDatas,bidData)
    areawar.setautocommit(false)

    for k,v in pairs(allianceDatas) do
        areawar.updateAllianceData(bid,v)
    end
    
    redis:del(mkCacheKeyByGroup("a",stringBidAlliance,bid))
    redis:del(mkCacheKeyByGroup("b",stringBidAlliance,bid))
    areawar.updateBidData(bid,bidData)

    areawar.commit()
end

local function getBidDataMinRound(bidData)
    local round_a = tonumber(bidData.round_a)
    local round_b = tonumber(bidData.round_b)
    return round_a > round_b and round_a or round_b
end

local function repairRoundData(bid,round,allianceDatas,bidData)
    if not allianceDatas then
        allianceDatas = getAlliancesDataFromDb(bid)
    end

    local dataRound = 10
    if type(allianceDatas) == 'table' then
        for k,v in pairs(allianceDatas) do
            if tonumber(v.round) < dataRound then
                dataRound = tonumber(v.round)
            end
        end
    end

    dataRound = dataRound + 1

    local reapirFlag
    if dataRound < round then
        for i=dataRound,round-1 do
            -- TODO 最多进行的场次,有配置取配置
            if i > 2 then break end

            local matchListData = areawar.mkMatchList(allianceDatas)
            if type(matchListData) == 'table' then
                for gname,gdata in pairs(matchListData) do
                    for _,allianceData in pairs(gdata) do
                        allianceData.pos = gname
                        allianceData.round = i

                        local log = json.decode(allianceData.log) or {}
                        log[i] = {i,gname,allianceData.point}
                        allianceData.log = json.encode(log)
                    end
                end

                bidData.round_a = i
                bidData.round_b = i

                reapirFlag = true
            end
        end
    end

    if reapirFlag then
        setRepairDataToDb(bid,allianceDatas,bidData)
    end
end

function areawar.checkRoundData(bid,round,allianceDatas,bidData)
    local warRound = getBidDataMinRound(bidData) + 1
    if round > warRound then
        repairRoundData(bid,round,allianceDatas,bidData)
    end
end

-- round1的对阵列表
local function getMatchListOfRound1(data)
    local list = {}

    -- 按服存放的数据
    local serverData = {}
    -- 服数
    local serversCount = 0
    -- 本组所有的服
    local servers = nil
    -- 临时数据,服内报名不足时,会从其它服取
    local tmpData = {}

    local matchList = areaWarCfg.matchList
    local allianceNum = areaWarCfg.sevbattleAlliance

    for k,v in pairs(data) do
        local zid = tonumber(v.zid)
        if not serverData[zid] then
            serverData[zid] = {}
        end

        if not servers then
            servers = json.decode(v.servers)
            if type(servers) ~= 'table' then
                servers = {}
            end

            serversCount = table.length(servers)
            assert(serversCount > 0,"serversCount error")
        end
        
        if #serverData[zid] < (allianceNum/serversCount) then
            table.insert(serverData[zid],v)
        else
            table.insert(tmpData,v)
        end
    end

    table.sort(servers,function (a,b) return tonumber(a) < tonumber(b) end)
    table.sort(tmpData,function (a,b) return tonumber(a.fight) > tonumber(b.fight) end)
    
    for _,zid in pairs(servers) do
        local zid = tonumber(zid)
        if not serverData[zid] then
            serverData[zid] = {}
        end

        local n = #serverData[zid]
        local m = allianceNum/serversCount

        if n < m then
            for i=m-1,n,-1 do
                table.insert(serverData[zid],tmpData[1])
                table.remove(tmpData,1)
            end
        end
    end

    local groupAlliancNum = allianceNum/#matchList[serversCount]
    for group,listCfg in pairs(matchList[serversCount]) do
        group = SortNum2GroupName[group]
        list[group] = {}

        for k,v in pairs(listCfg) do
            for zrank,zid in pairs(servers) do
                zid = tonumber(zid)
                local zdata = serverData[zid]
                if type(zdata) == 'table' and tonumber(v[1]) == zrank then
                    for rank,alliance in pairs(zdata) do
                        -- 组人数未满,并且名次相等(8个服开的时候比较特殊,看配置)
                        if #list[group] < groupAlliancNum and v[2] == rank then
                            table.insert(list[group],alliance)
                        end
                    end
                end
            end
        end
    end

    serverData = nil
    serversCount = nil
    servers = nil
    tmpData = nil

    return list
end

-- 淘汰赛的队列(按上次匹配的位置分配队列)
-- 小组赛用config来分配不用这个方法
-- 直接写死成第二轮,跨服区域战一共会打2轮,A,B组的结算时间不一样,会导致pos变化,所以要取log来推算在这个过程中的battleList
local function getMatchListByPos(data)
    local list = {
        a={},
        b={},
    }

    local posData = {}
    for k,v in pairs(data) do
        -- [[1,"a",5490]] 1是场次,2是组,3是分数
        local log = json.decode(v.log)

        if type(log) == 'table' then
            for _,logVal in pairs(log) do
                -- 取第一场的log数据
                if tonumber(logVal[1]) == 1 then
                    if not posData[logVal[2]] then
                        posData[logVal[2]] = {}
                    end

                    -- 把分值添加进去,进行排序后再分下一组
                    table.insert(posData[logVal[2]],{(logVal[3] or 0),v,(tonumber(v.ladderpoint) or 0),(tonumber(v.fight) or 0)})

                    break
                end
            end
        end
    end

    for k,v in pairs(posData) do
        if #v > 0 then
            table.sort(v,function (a,b) 
                if tonumber(a[1]) == tonumber(b[1]) then
                    if tonumber(a[3]) == tonumber(b[3]) then
                        return tonumber(a[4]) > tonumber(b[4])
                    else
                        return tonumber(a[3]) > tonumber(b[3])
                    end
                else
                    return tonumber(a[1]) > tonumber(b[1]) 
                end
            end)
            
            -- 这里前2名分配到A组,直接写死吧
            for m,n in pairs(v) do
                if m <=2 then
                    table.insert(list['a'],n[2])
                else
                    table.insert(list['b'],n[2])
                end
            end
        end
    end

    posData = nil

    return list
end

-- 生成下一轮战斗匹配队列
-- 第一轮(round为0时)是小组赛
-- 其它轮为淘汰赛
-- roundEvents 如果是最后一轮，需要将败者组的人拉入胜者组，决出冠军
function areawar.mkMatchList(data)
    if not data or not next(data) then 
        return {} 
    end

    -- 按所有数据的最小round算下一轮的对阵列表吧,有可能中途A组结算了，B组没有结算
    local round
    for k,v in pairs(data) do
        local dataRound = (tonumber(v.round) or 0) + 1
        if not round then
            round = dataRound
        end

        if dataRound < round then
            round = dataRound
        end
    end
    

    local list
    if round == 1 then
        list = getMatchListOfRound1(data)
    elseif round >= 2 then
        list = getMatchListByPos(data)
    end

    return list
end

----------------------------------------

-- 统一保存本场战斗的所有相关数据
function areawar.save(bid)
    areawar.setPlaceInfo(bid)
    areawar.setUsersDonate(bid)

    if type(usersActionData) == 'table' then
        local tmp,setFlag = {}
        for k,v in pairs(usersActionData) do
            tmp[k] = json.encode(v)
            setFlag = true
        end

        if setFlag then
            local acKey = mkCacheKey(hashBidActions,bid)
            local ret = redis:hmset(acKey,tmp)
            redis:expire(acKey,expireTs)
        end
    end

    setBattleReport()
    setBattleTasks(bid)
end

----------------------------------------

function areawar.setautocommit(value)
    assert(db.conn:setautocommit(value),'mysql transaction set failed')
end

function areawar.commit()
    return db.conn:commit()
end

function areawar.rollback()
    return db.conn:rollback()
end

function areawar.lock(bid,lockKey)
    local key = table.concat({"areaTeamWar",bid,lockKey or "areawarlock"},'.')

    local ret
    local i = 1
    while i<5 do
         ret = redis:getset(key,100)   
         redis:expire(key,3)      
         if ret==nil then
             return true
         else
             local socket = require("socket.core")
             local time = rand(20,60)/100
             socket.select(nil,nil,time)
             i = i + 1
         end
    end

    return false
end

-- 公共解锁
function areawar.unlock(bid,lockKey)
    local key = table.concat({"areaTeamWar",bid,lockKey or "areawarlock"},'.')

    local ret
    ret = redis:del(key)
    if ret==1 then
        return true
    end
    return false
end

function areawar.gate(bid,areaServerId)
    local config = getConfig("config")
    local connector = config.areacrossserver.connector

    if areaServerId then
        return connector[areaServerId] 
    end

    local bid = tonumber(string.sub(bid, 2))
    local n = bid % #connector
    if n == 0 then n = #connector end
    return connector[n]
end

return areawar
