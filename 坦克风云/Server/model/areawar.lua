local areawar = {}

----------------------------

-- 存放所有用户的行动信息
local hashUsersAction = 'areawar.UsersAction.%s' -- bid
-- 军团数据
local stringBidAlliance = 'areawar.alliance.%s' -- bid
-- 成员数据
local hashBidMember = 'areawar.members.%s' -- bid
-- 区域战结束标识，提前结束，定时会继续扫描，如果有此标识，程序直接停止
local stringBattleOverFlag = "areawar.overFlags.%s" -- bid
-- 存放用户的行动信息
local hashBidActions = 'areawar.actions.%s' -- bid
-- 记录战场据点信息
local hashBidPlaces = "areawar.places.%s" -- bid
-- 记录所有军团当前的击破敌军的城防值
local stringAllienceDeBlood = "areawar.deblood.%s" -- bid
-- 记录军团长发出的军团指令
local hashAllianceCommandMsg = "areawar.commandmsg.%s"
-- 按军团记录加入战场的用户id，按此队列推送消息
local setAllianceMemId = "areawar.members.uids.%s.%s" -- bid,aid
-- 用户贡献值
local stringBidUsersDonate = "areawar.donate.%s" -- bid
-- 军团在战斗中获取到的奴隶
local stringAllianceSlaves = "areawar.slaves.%s" -- bid
-- 统计玩家任务
local hashUsersTask = "areawar.UsersTask.%s" -- bid

----------------------------

-- 当前时间戳
local ts
-- 区域战配置
local areaWarCfg
-- 区域战地图配置
local localWarMapCfg
-- 地形配置
local worldGroundCfg
-- redis 连接
local redis
-- 缓存过期时间(秒),默认一周
local expireTs = 604800

----------------------------

-- 参战军团信息列表
local areawarAllianceList = {}
-- 军团在每个据点攻破的城防值
local alliancesDeBloodValue = nil
-- 地图据点的详细信息
local mapPlacesInfo = nil
-- 回合开始前的据点信息,只读,用来获取战斗中的BUFF
local originalPlacesInfo = nil
-- 用户行动数据
local usersActionData = nil
-- 存放用户的贡献
local usersDonate = {}
-- 军团的奴隶
local allianceSlaves = {}
-- 战报
local battleReports = {}
-- 记录玩家本回合的战斗次数、
local userBattleCount = {}
-- 记录所有玩家的任务
local usersTask = nil

----------------------------

-- NPC详细配置
local baseNpc = {
    uid = -1,
    aid = -1,
    nickname='-1',
    level=60,
    fc=1000000,
    pic=1,
    rank=9,
    alliancename='',
    binfo = '[["maxhp","buffvalue","dmg","crit","accuracy","buff_value","hp","evade","armor","salvo","isSpecial","weaponType","double_hit","id","abilityInfo","arp","abilityLv","type","landform","anticrit","num","hero","decritDmg","abilityID","critDmg","dmg_reduce","evade_reduce","buffType"],[[[2385,0.2,198,0.5,0.5,0,1612260,0.5,0,3,0,1,0,"a10004",{"debuff":{},"buff":{}},0,"",1,0,0.7,676,{},0,"",0,1,0,1],[2385,0.2,198,0.5,0.5,0,1612260,0.5,0,3,0,1,0,"a10004",{"debuff":{},"buff":{}},0,"",1,0,0.7,676,{},0,"",0,1,0,1],[2385,0.2,198,0.5,0.5,0,1612260,0.5,0,3,0,1,0,"a10004",{"debuff":{},"buff":{}},0,"",1,0,0.7,676,{},0,"",0,1,0,1],[2160,0.2,301.5,0.7,0.5,0,1460160,0.5,0,6,0,8,0,"a10034",{"debuff":{},"buff":{}},0,"",8,0,0.5,676,{},0,"",0,1,0,8],[2115,0.2,585,0.5,0.7,0,1429740,0.5,0,2,0,4,0,"a10024",{"debuff":{},"buff":{}},0,"",4,0,0.5,676,{},0,"",0,1,0,4],[1395,0.2,945,0.5,0.5,0,943020,0.7,0,1,0,2,0,"a10014",{"debuff":{},"buff":{}},0,"",2,0,0.5,676,{},0,"",0,1,0,2]]],{}]'
}

-- 所有待推送信息
local pushData = {}
-- 所有推送用户
local pushUsers = {}

----------------------------

-- 生成缓存key
local function mkCacheKey(cacheKey,...)
    return string.format(cacheKey,...)
end

local function reset()
    alliancesDeBloodValue = nil
    mapPlacesInfo = nil
    originalPlacesInfo = nil
    usersActionData = nil
    usersDonate = {}
    pushData = {}
    pushUsers = {}
    allianceSlaves = {}
    battleReports = {}
    areawarAllianceList = {}
    userBattleCount = {}
    usersTask = nil
end

-- 设置本场区域战需要推送的用户
local function addPushUser(uid)
    pushUsers[tostring(uid)] = uid
end

-- 初始化
function areawar.construct()
    ts = os.time()
    areaWarCfg = getConfig('areaWarCfg')
    localWarMapCfg = getConfig('localWarMapCfg')
    worldGroundCfg = getConfig('worldGroundCfg')
    redis = getRedis()

    setRandSeed()
    reset()
end

function areawar.destruct()
    areaWarCfg = nil
    localWarMapCfg = nil
    worldGroundCfg = nil
    redis = nil
end

-- 获取区域战标识
-- params ts 进行战斗时的时间戳
-- return string example:b116670
areawar.getAreaWarId = getAreaWarId

-- 设置战斗中需要推送的数据
function areawar.setBattlePushData(data)
    if type(data) == 'table' and next(data) then
        table.insert(pushData,data)
    end
end

-- 推送数据
-- 会将5秒内，所有变化数据集中处理后，一并发给前端
function areawar.battlePush()
    local pushCmd = 'areawarserver.battle.push'

    if next(pushData)  then
        local pData = {}

        for k,v in pairs(pushData) do
            for k1,v1 in pairs(v) do
                if not pData[k1] then pData[k1] = {} end
                if k1 == 'placesInfo' then
                    pData['placesInfo'] = areawar.formatPlacesDataForClient(mapPlacesInfo)
                elseif k1 == 'over' then
                    pData[k1] = v1
                else
                    table.insert(pData[k1],v1)
                end
            end
        end

        if pData['allActionInfo'] then
            pData.userActionInfo = areawar.formatUsersActionDataForClient(usersActionData)
            pData['allActionInfo'] = nil
        end

        if pData['placesInfo'] and alliancesDeBloodValue then
            pData.allianceDeHp = alliancesDeBloodValue
        end

        pData.bts = ts
        if pData.bts % 20 ~= 0 then
            pData.bts = pData.bts - pData.bts % 20
        end 

        local data = {areaWarserver=pData}

        local uid
        for _,v in pairs(pushUsers) do
            uid = tonumber(v)
            if uid then
                regSendMsg(uid,pushCmd,data)
            end
        end

        uid,pData,data = nil,nil,nil
    end

end

-- 将用户行动数据处理为前端所需的格式
function areawar.formatUserActionDataForClient(data)
    if type(data) == 'table' then
        return {
            -- v.bid,  -- 区域战唯一标识
            data.uid,  -- 用户uid
            data.nickname, -- 用户昵称
            data.aid,  -- 用户军团Id
            -- data.basePlace,    -- 用户主基地
            -- data.pos,  -- 当前所在的据点，只有用户发生 `占领据点行为` 才会被重新赋值，
            data.target,   -- 目标点
            -- data.st,   -- 向目标出发的起始时间戳
            data.bplace or 0,   -- 用户上次发生战斗的地点
            data.battle_at,    -- 用户上次发生战斗的时间戳
            -- v.ts,   -- 用户行动数据上次发生变化的时间戳
            data.dist, -- 用户到达目标点的时间
            -- v.troops,   -- 用户当前实际的部队情况
            data.revive or 0,  -- 复活时间戳
            data.prev or 0, -- 上次所在城市
            data.enemy or 0,
        }
    end
end

-- 处理所有用户的行动数据为前端所需格式
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

-- 处理据点数据为前端所需格式
-- 1是据点归属,2是当前城防值,3是NPC部队数据(0是无,1是有)
function areawar.formatPlaceDataForClient(placeinfo)
    return {placeinfo[1],placeinfo[2],(placeinfo[3] == '-NPC' and 0 or 1)}
end

-- 处理所有据点数据为前端所需格式
function areawar.formatPlacesDataForClient(placesInfo)
    local data = {}

    for k,v in pairs(placesInfo) do 
        data[k] = areawar.formatPlaceDataForClient(v)
    end

    return data
end

-- 玩家进入战场,按aid存储玩家集合,并且按all存一份所有玩家的uid,
-- 按军团推送或全地图推送数据时用到此集合
-- params int uid 玩家id
-- params int aid 玩家军团id
function areawar.joinAreaWar(bid,uid,aid)
    local acKey1 = mkCacheKey(setAllianceMemId,bid,aid)
    local acKey2 = mkCacheKey(setAllianceMemId,bid,'all')

    redis:sadd(acKey1,uid)
    redis:sadd(acKey2,uid)
    redis:expire(acKey1,expireTs)
    redis:expire(acKey2,expireTs)
end

-- 获取进入战场的成员
-- params int aid 军团id,有就查军团的成员,没有则查所有的成员
function areawar.getAllianceMemUids(bid,aid)
    aid = aid or "all"
    local acKey = mkCacheKey(setAllianceMemId,bid,aid)
    return redis:smembers(acKey)
end

-- 获取所有用户行动信息
-- 以uid的字符串为key标识所有行动数据
-- 这里会顺带将所有用户id加入到推送列表
function areawar.getUsersActionInfo(bid)
    if not usersActionData then
        usersActionData = {}
        
        local acKey = mkCacheKey(hashBidActions,bid)
        local data = redis:hgetall(acKey)

        if type(data) == 'table' and next(data) then
            for k,v in pairs(data) do
                usersActionData[tostring(k)] = json.decode(v)
                addPushUser(k)
            end
        end
    end

    return usersActionData
end

-- 设置参战军团的数据到缓存
-- 军团数据:
    -- aid,name,ranking,commander军团长
local function setAllianceDataToCache(bid,stringBidAllianceKey,alliancesData)
    if not stringBidAllianceKey then
        stringBidAllianceKey = mkCacheKey(stringBidAlliance,bid)
    end

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

-- 按bid从军团处获取参战军团数据
local function getAlliancesDataFromDb(bid)
    local allianceDatas = {}

    local result = M_alliance.getAreaBattleAlliance()
    if type(result) == 'table' and result.data then
        for k,v in pairs(result.data.alliances) do
            table.insert(allianceDatas,{aid=v.aid,name=v.name,ranking=v.rank,commander=v.kingname})
        end
    end

    return allianceDatas
end

-- 获取军团已占领的据点的BUFF效果
-- 战斗过程中,会改变mapPlacesInfo的值,所以算BUFF时要取上一轮据点信息
local function getAllianceBuff(aid)
    local buff = {}

    if type(originalPlacesInfo) == 'table' then
        for k,v in pairs(originalPlacesInfo) do
            if tonumber(aid) == tonumber(v[1]) then
                for bfKey,bfVal in pairs(localWarMapCfg.cityCfg[k].buff) do
                    if not buff[bfKey] then
                        buff[bfKey] = bfVal 
                    else
                        buff[bfKey] = buff[bfKey] + bfVal
                    end
                end
            end
        end
    end

    return buff
end

-- 增加用户战斗次数
local function incrUserBattleCount(uid)
    uid = tonumber(uid)
    userBattleCount[uid] = (userBattleCount[uid] or 0) + 1
end

-- 获取用户连续战斗的debuff
local function getDebuffByBattleCount(uid)
    uid = tonumber(uid)
    local battleCount = userBattleCount[uid] or 0

    if battleCount > 0 then
        local rate = math.pow((1 - areaWarCfg.reducePercentage),battleCount)
        return {
            [100]=rate,
            [108]=rate,
        }
    end
end

-- 按报名资金排名获取军团的主基地
-- 王城ranking=5所属军团分配到王城
local function getBasePlaceByRanking( ranking )
    local basePlace

    ranking = tonumber(ranking)
    if ranking == 5 then
        basePlace = localWarMapCfg.capitalID
    else
        basePlace = localWarMapCfg.baseCityID[ranking]
    end

    assert(basePlace ~= nil)

    return basePlace
end

-- 获取参战军团的详细数据,第一次会附带分配主基地
-- 注意key为军团id的字符串类型
function areawar.getAlliancesData(bid)
    if next(areawarAllianceList) then 
        return areawarAllianceList
    end

    local alliancesData = getAlliancesDataFromCache(bid)
    if type(alliancesData) ~= 'table' or not next(alliancesData) then
        alliancesData = getAlliancesDataFromDb(bid)
        if type(alliancesData) == 'table' and next(alliancesData) then
            for k,v in pairs(alliancesData) do
                local basePlace = getBasePlaceByRanking(v.ranking)

                if localWarMapCfg.cityCfg[basePlace].type == 1 then
                    areawar.changePlaceOwner( bid,basePlace,v.aid,localWarMapCfg.baseCityHp )
                else
                    areawar.changePlaceOwner( bid,basePlace,v.aid )
                end
                
                -- 新加了一个出生据点也要变
                areawar.changePlaceOwner( bid,localWarMapCfg.homeID[basePlace],v.aid )
            end
            -- todo 考虑一下设置地图失败
            areawar.resetPlaceInfo(bid)
            setAllianceDataToCache(bid,stringBidAllianceKey,alliancesData)
        end
    end

    if type(alliancesData) == 'table' then
        areawarAllianceList = {}
        for k,v in pairs(alliancesData) do
            areawarAllianceList[tostring(v.aid)] = v
        end
    end

    return areawarAllianceList
end

-- 获取主基地信息
-- params int aid 军团id
-- return string|table
function areawar.getAllianceBasePlace(bid,aid)
    local aidForBase = {}

    local allianceData = areawar.getAlliancesData(bid)

    if type(allianceData) == 'table' then
        for k,v in pairs(allianceData) do
            if k~='nil' then
                aidForBase[v.aid] = getBasePlaceByRanking(v.ranking)
            end
           
        end
    end

    if aid then
        return aidForBase[aid]
    end

    return aidForBase
end

-- 获取参战成员数据
function areawar.getUserData(bid,uid,aid)
    -- -1 是NPC
    if uid == -1 then
        local npc = copyTab(baseNpc)
        npc.binfo = json.decode(npc.binfo)
        return npc
    end

    local memKey = mkCacheKey(hashBidMember,bid)
    local data = redis:hget(memKey,uid)

    if type(data) == 'string' then
        data = json.decode(data)
    end

    if type(data) == 'table' and data.binfo then
        if type(data.binfo) ~= 'table' then
            data.binfo = json.decode(data.binfo)
        end
    end

    return data
end

-- 获取参战成员数据
function areawar.getUsersData(bid,uids)
    local memKey = mkCacheKey(hashBidMember,bid)
    local datas = redis:hmget(memKey,uids)

    if type(datas) == 'table' then
        for k,v in pairs(datas) do
            datas[k] = json.decode(v)
        end
    end

    return datas
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

-- 获取军团死亡标识
function areawar.getAllianceDieFlag(bid,aid)
    aid = tostring(aid)
    local allianceBattleInfo = areawar.getAlliancesData(bid)
    return allianceBattleInfo[aid].die
end

-- 设置玩家行动信息
function areawar.setUserActionInfo(bid,data,saveFlag)
    local ts = os.time()
    local uid = data.uid

    if not data.basePlace or data.basePlace == 0 then
        local basePlaceInfo = areawar.getAllianceBasePlace(bid)
        data.basePlace = basePlaceInfo[tostring(data.aid)]
    end

    if not data.target or data.target == 0 then
        data.target = localWarMapCfg.homeID[data.basePlace]
        data.dist = ts
    end

    if not data.battle_at then 
        data.battle_at = ts
    end

    data.ts = ts

    if type(usersActionData) ~= 'table' then
        usersActionData = {}
    end

    usersActionData[tostring(uid)] = data
    
    -- 需要立即保存
    local ret
    if saveFlag then
        local acKey = mkCacheKey(hashBidActions,bid)
        ret = redis:hset(acKey,uid,json.encode(data))
        redis:expire(acKey,expireTs)
    end

    return ret,data
end

-- 初始化玩家行动信息
-- 重置用户的行动信息，需要从用户身上重新读取部队数据
function areawar.resetUserActionInfo(data,saveFlag,userData)
    if not data then data = {} end
    local userinfo = userData or areawar.getUserData(data.bid,data.uid)
    local ts = os.time()
    data.basePlace = data.basePlace or 0
    data.troops=userinfo.troops or {}
    data.st=ts
    data.dist=ts
    data.target=nil
    data.binfo=userinfo.binfo
    data.aid=userinfo.aid or aid
    data.level=userinfo.level
    data.nickname=userinfo.nickname
    data.alliancename=userinfo.alliancename or ''
    data.role=userinfo.role or 0
    
    return areawar.setUserActionInfo(data.bid,data,saveFlag)
end

-- 从缓存获取用户当前行动信息
function areawar.getUserActionInfoFromCache(bid,uid,aid)
    local acKey = mkCacheKey(hashBidActions,bid)
    local data = redis:hget(acKey,uid)
    data = data and json.decode(data)

    return data
end

-- 设置用户出战部队
function areawar.setUserActionTroops(bid,uid,binfo,fleetInfo)
    if type(binfo) == 'table' then
        local userAction = areawar.getUserActionInfoFromCache(bid,uid)
        if type(userAction) == 'table' then
            userAction.binfo = binfo
            userAction.troops = fleetInfo
            areawar.setUserActionInfo(bid,userAction,true)
        end
    end
end

-- 获取用户当前行动信息
function areawar.getUserActionInfo(bid,uid,aid,saveFlag)
    if type(usersActionData) == 'table' and usersActionData[tostring(uid)] then
        return usersActionData[tostring(uid)]
    end

    local acKey = mkCacheKey(hashBidActions,bid)
    local data = redis:hget(acKey,uid)

    if not data then
        local userinfo = areawar.getUserData(bid,uid)
        if userinfo then
            local setret, setdata = areawar.resetUserActionInfo({bid=bid,uid=uid},saveFlag,userinfo)
            if setret then
                return setdata,true
            end
        end
    end

    data = data and json.decode(data)

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
        aid2attacker={},
        aid2defenser={},

        -- 记录当前军团是否有预备队
        aHasReserve={},
        dHasReserve={},
    }

    local queueNum = areaWarCfg.battleQueue

    if type(userList) == 'table' then
        table.sort(userList,function(a,b)
            if a.dist == b.dist then                    
                return tonumber(a.uid) < tonumber(b.uid)
            else
                return tonumber(a.dist) < tonumber(b.dist)
            end
        end)

        for k,v in pairs(userList) do
            local aid = tostring(v.aid)
            if v.aid and aid == tostring(ownerAid) then
                if #battleList.defenser < queueNum then
                    table.insert(battleList.defenser,v)
                    if not battleList.aid2defenser[aid] then
                        battleList.aid2defenser[aid] = {}
                    end
                    table.insert(battleList.aid2defenser[aid],v.uid)
                else
                    battleList.dHasReserve[aid] = true
                end
            else
                if #battleList.attacker < queueNum then
                    table.insert(battleList.attacker,v)
                    if not battleList.aid2attacker[aid] then
                        battleList.aid2attacker[aid] = {}
                    end
                    table.insert(battleList.aid2attacker[aid],v.uid)
                else
                    battleList.aHasReserve[aid] = true
                end
            end
        end
    end

    if checkNpc then
        local defenserNpc = areawar.getPlaceNpc(placeId)

        -- 中立城市
        if tonumber(ownerAid) == 0 then
            table.insert(battleList.defenser,defenserNpc)
        else
            if #battleList.defenser < queueNum then
                if defenserNpc then
                    table.insert(battleList.defenser,defenserNpc)
                end
            else
                if defenserNpc then
                    battleList.dHasReserve[tostring(defenserNpc.aid)] = true
                end
            end
        end
    end
    
    return battleList
end

-- 军团id是否在战斗队列中
function areawar.aidInBattleQueue(aid,queue)
    for k,v in pairs(queue) do
        if v.aid and tostring(v.aid) == tostring(aid) then
            return true
        end
    end
end

-- 用户是否在战斗队列中
function areawar.userInBattleQueue(uid,queue)
    for k,v in pairs(queue) do
        if v.uid and tostring(v.uid) == tostring(uid) then
            return true
        end
    end
end

-- 获取用户的据点分布列表
function areawar.getPlacesUserList(bid)
    local battlePlaces = {}
    local ts = os.time()

    -- 所有用户行动信息
    local usersActionInfo = areawar.getUsersActionInfo(bid)
    if type(usersActionInfo) ~= 'table' then
        return battlePlaces
    end

    for _,userActionInfo in pairs(usersActionInfo) do
        -- 抵达目标并且已经复活
        if userActionInfo.dist <= ts and userActionInfo.target and (userActionInfo.revive or 0) <= ts then
            if not battlePlaces[userActionInfo.target] then
                battlePlaces[userActionInfo.target] = {}
            end

            table.insert(battlePlaces[userActionInfo.target],userActionInfo)
        end
    end

    return battlePlaces
end

----------------------------------------------------------------------------

-- 战斗在当天的起始与结束时间,这里没有处理周几
function areawar.getBattleTs()
    local startTs = getWeeTs() + areaWarCfg.startWarTime[1] * 3600 + areaWarCfg.startWarTime[2] * 60
    local endTs = startTs + areaWarCfg.maxBattleTime
    return startTs,endTs
end

-- 增加军团指令
function areawar.setAllianceCommand(bid,aid,command)
    if type(command) == 'table' then
        local acKey = mkCacheKey(hashAllianceCommandMsg,bid)
        local commandMsgs = redis:hset(acKey,aid,json.encode(command))
        redis:expire(acKey,expireTs)
    end
end

-- 获取军团指令
function areawar.getAllianceCommand(bid,aid)
    local acKey = mkCacheKey(hashAllianceCommandMsg,bid)
    local commandMsgs = redis:hget(acKey,aid)
    commandMsgs = json.decode(commandMsgs)

    if type(commandMsgs) ~= 'table' then
        commandMsgs = {}
    end

    return commandMsgs
end

-- 上次执行战斗的时间
-- 保证一个周期内只执行一次战斗，防止堆叠
function areawar.battleRunFlag()
    local key = "areawar.battleAt"
    local ts = os.time()
    redis:watch(key)
    local lastAt = redis:get(key)
    lastAt = tonumber(lastAt) or 0
    local diffBattleAt = ts - lastAt
    if diffBattleAt < 20 then
        return false
    end

    redis:multi()
    redis:set(key,ts)       
    redis:expire(key,18)
    return redis:exec()
end

-- 获取据点类型，1是王城，2是主基地，3是野区
function areawar.getPlaceType(placeId)
    return localWarMapCfg.cityCfg[placeId].type
end

-- 据点掉耐久
function areawar.dePlaceBlood(bid,placeId,blood)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][2] = mapPlacesInfo[placeId][2] - blood

        if mapPlacesInfo[placeId][2] <= 0 then
            mapPlacesInfo[placeId][2] = 0
        end

        areawar.setBattlePushData({placesInfo=true})

        return mapPlacesInfo[placeId][2]
    end

    return 1000
end

-- 获取军团奴隶
function areawar.getAllianceSlaves(bid)
    local acKey = mkCacheKey(stringAllianceSlaves,bid)
    local slaves = redis:get(acKey)
    local slaves = json.decode(slaves)

    if type(slaves) ~= 'table' then
        slaves = {}
    end

    return slaves
end

-- 按结算所需的信息格式化奴隶数据
-- 需要奴隶的职位，军团名，在区域战中获得的贡献
function areawar.formatAllianceSlavesForOver(bid,slaves,usersDonate)
    if type(slaves) == 'table' and next(slaves) then
        local tmp = {}
        local usersData = areawar.getUsersData(bid,slaves)
        
        for k,uid in pairs(slaves) do
            local user = usersData[k]
            if user then
                table.insert(tmp,{
                    uid,
                    user.level,
                    user.role or 0,
                    user.alliancename or '',
                    usersDonate and usersDonate[tostring(uid)] or 0
                })
            end
        end

        table.sort(tmp,function(a,b)
            return a[2] > b[2]
        end)

        slaves = {}
        for i=1,40 do
            if tmp[i] then
                table.remove(tmp[i],2)
                table.insert(slaves,tmp[i])
            else
                break
            end
        end

        return slaves
    end
end

-- 捕获奴隶
-- params int loserUid 失败者uid
-- params int winAid 获胜方军团id
function areawar.captureSlave(bid,loserUid,winAlliance)
    if rand(1,100) < (areaWarCfg.slaveRate * 100) then
        loserUid = tonumber(loserUid)
        winAlliance = tostring(winAlliance)

        if not allianceSlaves[winAlliance] then
            allianceSlaves[winAlliance] = {}
        end

        allianceSlaves[winAlliance][loserUid] = true
    end
end

-- 设置军团奴隶数据
function areawar.setAllianceSlaves(bid)
    if type(allianceSlaves) == 'table' then
        local slavesData = areawar.getAllianceSlaves(bid)
        local saveFlag = false
        for aid,slaves in pairs(allianceSlaves) do
            if not slavesData[aid] then slavesData[aid] = {} end
            for uid,_ in pairs(slaves) do
                if not table.contains(slavesData[aid],uid) then
                    table.insert(slavesData[aid],uid)
                    saveFlag = true
                end
            end
        end

        if saveFlag then
            local acKey = mkCacheKey(stringAllianceSlaves,bid)
            redis:set(acKey,json.encode(slavesData))
            redis:expire(acKey,expireTs)
        end

        return slavesData
    end
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

-- 获取所有据点信息
-- 需要做较验战斗时据点发生变化后不再从缓存获取
function areawar.getPlacesInfo(bid)
    if not mapPlacesInfo then
        mapPlacesInfo = {}
        local acKey = mkCacheKey(hashBidPlaces,bid)
        local data = redis:hgetall(acKey)

        if type(data) == 'table' and next(data) then
            for k,v in pairs(data) do
                mapPlacesInfo[k] = json.decode(v)
            end
        end

        if type(mapPlacesInfo) ~= 'table' then
            mapPlacesInfo = {}
        end

        -- 1是归属，2是耐久，3是NPC部队，如果是字串'NPC'表示是一个完整的部队，额外取一下NPC配置
        for k,v in pairs(localWarMapCfg.cityCfg) do
            if not mapPlacesInfo[k] then
                mapPlacesInfo[k] = {
                    0,v.hp,'NPC',
                }
            end
        end

        -- 战斗过程中，会实时改变mapPlacesInfo的值,计算战斗中据点BUFF时只能取上一轮的
        originalPlacesInfo = copyTab(mapPlacesInfo)
    end
    
    return mapPlacesInfo
end

-- 获取据点NPC
-- 如果缓存中没有Npc兵力,表示刷新了此据点兵力，此时直接报配置
function areawar.getPlaceNpc(placeId)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] and mapPlacesInfo[placeId][3] ~= '-NPC' then
        local npc = copyTab(baseNpc)
        npc.binfo = json.decode(npc.binfo)
        npc.troops = mapPlacesInfo[placeId][3]
        return npc
    end
end

-- 设置据点兵力
-- 如果刷新了据点兵力，可以直接删除缓存中的数据，取的时候直接读配置取
function areawar.setPlaceNpcTroops(placeId,troops)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][3] = troops
    end
end

-- 重置据点NPC兵力
-- 'NPC'字串表示一个完整的NPC兵力
function areawar.resetPlaceTroops(placeId)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][3] = 'NPC'
    end
end

-- 清空据点NPC兵力
-- '-NPC'字串表示NPC是死亡的，即此城没有NPC防守
function areawar.clearPlaceTroops(placeId)
    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][3] = '-NPC'
    end
end

function areawar.allAllianceDie()
    for k,v in pairs(areawarAllianceList) do
        if tonumber(v.ranking) ~= 5 and tonumber(v.die) ~= 1 then
            return false
        end
    end
    return true
end

-- 主基地被打爆了,军团阵亡
-- 判断被打掉的主基地是否是该军团的原始主基地
-- 是原始主基地则此军团所有据点消失，所有成员退出战场，所有据点的城防值清空，军团设一个死忘标识
-- 清空此城市的所有已打掉的城防值
function areawar.allianceDestroy(bid,aid,placeId)
    if not aid or aid == 0 then return end

    local allianceBasePlace = areawar.getAllianceBasePlace(bid,aid)

    if tostring(placeId) == tostring(allianceBasePlace) then
        -- 清除该军团的所有据点,当前据点会在此操作之前被攻击军团占领
        local placesInfo = areawar.getPlacesInfo(bid)
        for k,v in pairs(placesInfo) do
            if tostring(v[1]) == aid then
                placesInfo[k] = {0,localWarMapCfg.cityCfg[k].hp,"NPC"}
            end
        end

        -- 清除该军团成员的行动信息
        local usersActionData = areawar.getUsersActionInfo(bid)
        local acKey = mkCacheKey(hashBidActions,bid)
        for k,v in pairs(usersActionData) do
            if tostring(v.aid) == aid then
                redis:hdel(acKey,v.uid)
                usersActionData[k] = nil
            end
        end

        -- 清除该军团的击溃城防值信息
        areawar.clearAllianceDeBloodValue(bid,aid)

        -- 死一个基地存一次没关系，一共也就4个主基地，同时被爆的概率太低了
        areawarAllianceList[aid].die = 1
        setAllianceDataToCache(bid,nil,areawarAllianceList)
        areawar.setBattlePushData({allActionInfo=true})
    end

    -- 所在据点的所有城防值信息清空
    alliancesDeBloodValue[placeId] = nil

    return areawar.allAllianceDie()
end

-- 占领据点
-- 野外据点直接按aid占领
-- 主基地和王城的归属需要取打掉城防值最多的攻击方
function areawar.occupyPlace(bid,placeId,aid)
    local placeType = areawar.getPlaceType(placeId)

    if placeType == 1 or placeType == 3 then
        local deBloodValue = areawar.getAlliancesDeBloodValue(bid)
        local occupyValue = 0
        local occupyAid = {}

        for k,v in pairs(deBloodValue[placeId]) do
            if tonumber(v) >= tonumber(occupyValue) then
                occupyValue = v
                table.insert(occupyAid,{k,v})
            end
        end
        
        if #occupyAid > 1 then
            local allianceData = areawar.getAlliancesData(bid)
            table.sort(occupyAid,function(a,b)
                if a[2] == b[2] then 
                    return tonumber(allianceData[a[1]].ranking) < tonumber(allianceData[b[1]].ranking)
                else
                    return a[2] > b[2]
                end
            end)
        end

        if occupyAid[1] and occupyAid[1][1] then
            aid = occupyAid[1][1]
        end
    end

    if aid then
        areawar.changePlaceOwner( bid,placeId,aid )
        areawar.clearPlaceTroops(placeId)
        areawar.setBattlePushData({placesInfo=true})
    end

    return aid
end

-- 改变据点所属
-- 城防值直接刷满
function areawar.changePlaceOwner( bid,placeId,aid,hp )
    if not mapPlacesInfo then
        areawar.getPlacesInfo(bid)
    end

    if type(mapPlacesInfo) == 'table' and mapPlacesInfo[placeId] then
        mapPlacesInfo[placeId][1] = aid
        mapPlacesInfo[placeId][2] = hp or localWarMapCfg.cityCfg[placeId].hp
    end
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

-- 重置所有据点信息
-- 缓存是否已经设置过
function areawar.resetPlaceInfo(bid)
    if type(mapPlacesInfo) == 'table' then
        local acKey = mkCacheKey(hashBidPlaces,bid)
        if not redis:exists(acKey) then
            areawar.setPlaceInfo(bid)
        end
    end
end

-- 获取所有军团的当前在所有据点的攻击城防值
function areawar.getAlliancesDeBloodValue(bid)
    if type(alliancesDeBloodValue) ~= 'table' then
        local acKey = mkCacheKey(stringAllienceDeBlood,bid)
        local ret = redis:get(acKey)

        if type(ret) == 'string' then
            alliancesDeBloodValue = json.decode(ret)
        end
    end

    if type(alliancesDeBloodValue) ~= 'table' then
        alliancesDeBloodValue = {}
    end

    return alliancesDeBloodValue
end

-- 增加军团减敌方城防的值
-- 用json串的话，只需要先取，然后把数量叠加上，再存就好了,不会有并发
function areawar.addAllianceDeBloodValue(bid,placeId,aid,blood)
    aid = tostring(aid)

    local alliancesDeBloodValue = areawar.getAlliancesDeBloodValue(bid)

    if not alliancesDeBloodValue[placeId] then
        alliancesDeBloodValue[placeId] = {}
    end

    if not alliancesDeBloodValue[placeId][aid] then
        alliancesDeBloodValue[placeId][aid] = 0
    end

    alliancesDeBloodValue[placeId][aid] = tonumber(alliancesDeBloodValue[placeId][aid]) + blood

    return alliancesDeBloodValue[placeId][aid]
end

-- 清除军团减敌方城防的值
-- 如果有成员进攻主基地失败后，需要检测预备队中是否有此军团的，如果没有，需要清除掉已经取得的城防值
function areawar.clearAllianceDeBloodValue(bid,aid,placeId)
    local alliancesDeBloodValue = areawar.getAlliancesDeBloodValue(bid)
    if type(alliancesDeBloodValue) == 'table' then
        if placeId then
            if alliancesDeBloodValue[placeId] then
                alliancesDeBloodValue[placeId][tostring(aid)] = nil
            end
        else
            for k,v in pairs(alliancesDeBloodValue) do
                if v[tostring(aid)] then
                    alliancesDeBloodValue[k][tostring(aid)] = nil
                end
            end
        end
    end
end

-- 设置军团减敌方城防的值
-- 用json串的话，只需要先取，然后把数量叠加上，再存就好了,不会有并发
function areawar.setAllianceDeBloodValue(bid)
    if type(alliancesDeBloodValue) == 'table' and next(alliancesDeBloodValue) then
        local acKey = mkCacheKey(stringAllienceDeBlood,bid)
        redis:set(acKey,json.encode(alliancesDeBloodValue))
        redis:expire(acKey,expireTs)
        alliancesDeBloodValue = {}
    end
end

-- 主基地向王城开火
function areawar.baseAttackCapital(bid)
    local mapPlacesInfo = areawar.getPlacesInfo(bid)
    local attackForAid = {}

    for k,v in pairs(localWarMapCfg.baseCityID) do
        -- 如果主基地所属军团与王城所属军团不是相同的扣城防,并且不是中立的
        if (tonumber(mapPlacesInfo[v][1]) or 0) > 0 and mapPlacesInfo[v][1] ~= mapPlacesInfo[localWarMapCfg.capitalID][1] then
            attackForAid[mapPlacesInfo[v][1]] = (attackForAid[mapPlacesInfo[v][1]] or 0) + 1
        end
    end

    for k,v in pairs(attackForAid) do
        areawar.dePlaceBlood(bid,localWarMapCfg.capitalID,areaWarCfg.baseAttack[v])
        areawar.addAllianceDeBloodValue(bid,localWarMapCfg.capitalID,k,areaWarCfg.baseAttack[v])
    end

    attackForAid = nil

    return mapPlacesInfo[localWarMapCfg.capitalID][2]
end

-- 结算需要的信息：获胜军团
-- 直接调这个方法简单粗暴
function areawar.getOverData(bid)
    local placesInfo = areawar.getPlacesInfo(bid)
    return {
        winner = placesInfo[localWarMapCfg.capitalID][1]
    }
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
    local troops = 0

    for k,v in pairs(fleetinfo) do
        if (v[2] or 0) > 0 then
            local dienum = v[2] - (invalidFleet[k] and invalidFleet[k][2] or 0)
            troops = troops + dienum
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
local function formatTroops(attField,troops,currTroops,buffs,battleCountDebuff,landform)
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

    if type(buffs) == 'table' and next(buffs) then
        for bfKey,bfVal in pairs(buffs) do
            local attribute = attrNumForAttrStr[bfKey]
            for k,v in pairs(attTroops) do
                if v[attribute] then
                    if attribute == "dmg" then
                        attTroops[k][attribute] = attTroops[k][attribute] * (1+bfVal)
                    elseif attribute == "maxhp" then
                        attTroops[k][attribute] = attTroops[k][attribute] * (1+bfVal)
                        attTroops[k].hp = attTroops[k].num * attTroops[k][attribute]
                    elseif attribute == "dmg_reduce" then
                        attTroops[k][attribute] = attTroops[k][attribute] * (1-bfVal)
                    else
                        attTroops[k][attribute] =  attTroops[k][attribute] + bfVal
                    end
                end
            end
        end
    end

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

-- 战斗
function areawar.placeBattle(aUserinfo,dUserinfo,landform)
    local fleetInfo1 = copyTab(aUserinfo.binfo)
    local fleetInfo2 = copyTab(dUserinfo.binfo)

    local aUserBuffs = getAllianceBuff(aUserinfo.aid)
    local dUserBuffs = getAllianceBuff(dUserinfo.aid)

    local aBattleCountDebuff = getDebuffByBattleCount(aUserinfo.uid)
    local dBattleCountDebuff = getDebuffByBattleCount(dUserinfo.uid)

    local aFleetInfo = formatTroops(fleetInfo1[1],fleetInfo1[2][1],aUserinfo.troops,aUserBuffs,aBattleCountDebuff,landform)
    local defFleetInfo = formatTroops(fleetInfo2[1],fleetInfo2[2][1],dUserinfo.troops,dUserBuffs,dBattleCountDebuff,landform)

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

    report.se={fleetInfo2[4] or 0, fleetInfo1[4] or 0}

    incrUserBattleCount(aUserinfo.uid)
    incrUserBattleCount(dUserinfo.uid)

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

-- 增加用户贡献度
function areawar.addUserDonate(uid,aid,donate)
    if donate > 0 then
        aid = tostring(aid)
        if not usersDonate[aid] then 
            usersDonate[aid] = {}
        end

        if type(uid) == 'table' then
            for _,v in pairs(uid) do
                if (tonumber(v) or 0) > 0 then
                    usersDonate[aid][tostring(v)] = (usersDonate[aid][tostring(v)] or 0) + donate
                end
            end
        elseif (tonumber(uid) or 0) > 0 then
            uid = tostring(uid)
            usersDonate[aid][uid] = (usersDonate[aid][uid] or 0) + donate
        end
    end
end

-- 按积分大小排序贡献列表
-- 结算的时候要按分数排出排行榜发奖
function areawar.sortDonateList(donateList)
    local sortList = {}
    if type(donateList) == 'table' then
        for uid,score in pairs(donateList) do
            if uid and tonumber(uid) > 0 and (tonumber(score) or 0) > 0 then
                table.insert(sortList,{uid,score})
            end
        end
    end

    table.sort(sortList,function(a,b)
        if tonumber(a[2]) == tonumber(b[2]) then
            return tonumber(a[1]) < tonumber(b[1])
        else
            return tonumber(a[2]) > tonumber(b[2])
        end
    end)

    return sortList
end

-- 保存用户的贡献度
function areawar.setUsersDonate(bid)
    if next(usersDonate) then
        local setFlag = false
        local cacheData,acKey = areawar.getUserDonate(bid)

        if not cacheData['all'] then 
            cacheData['all'] = {} 
        end

        for k,v in pairs(usersDonate) do
            if not cacheData[k] then 
                cacheData[k] = {} 
            end

            for uid,donate in pairs(v) do
                if donate > 0 then
                    cacheData[k][uid] = ( cacheData[k][uid] or 0 ) + donate
                    cacheData['all'][uid] = cacheData[k][uid]
                    setFlag = true
                end
            end
        end

        if setFlag then
            redis:set(acKey,json.encode(cacheData))
            redis:expire(acKey,expireTs)
        end

        usersDonate = {}
        return cacheData
    end
end

-- 增加区域战战报
function areawar.addBattleReport(data)
    data.bid = nil
    table.insert(battleReports,data)
end

-- 设置区域战战报
function areawar.setBattleReport()
    local battlelogLib = require "lib.battlelog"
    return battlelogLib:areaLogSend(battleReports)
end

-- 统一保存本场战斗的所有相关数据
function areawar.save(bid)
    areawar.setAllianceDeBloodValue(bid)
    areawar.setPlaceInfo(bid)
    areawar.setUsersDonate(bid)
    areawar.setAllianceSlaves(bid)
    areawar.saveUsersTasks(bid)

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

    areawar.setBattleReport()
end

function areawar.getUsersTasks(bid)
    if not usersTask then
        usersTask = {}
        
        local acKey = mkCacheKey(hashUsersTask,bid)
        local data = redis:hgetall(acKey)

        if type(data) == 'table' and next(data) then
            for k,v in pairs(data) do
                usersTask[tostring(k)] = json.decode(v)
            end
        end
    end

    return usersTask
end

-- 设置用户任务
function areawar.setUserTask(bid,uid,taskInfo)
    if uid <= 0 then return end

    usersTask = areawar.getUsersTasks(bid)

    uid = tostring(uid)
    if not usersTask[uid] then
        usersTask[uid] = {}
    end

    for taskId,num in pairs(taskInfo) do
        if areaWarCfg.task[taskId] and ((usersTask[uid][taskId] or 0) < areaWarCfg.task[taskId][1]) then
            usersTask[uid][taskId] = (usersTask[uid][taskId] or 0) + num
        end
    end
end

-- 获取用户任务
function areawar.getAllUsersTasks(bid)
    return areawar.getUsersTasks(bid)
end

function areawar.saveUsersTasks(bid)
    if type(usersTask) == 'table' and next(usersTask) then
        local tmp,setFlag = {}
        for k,v in pairs(usersTask) do
            tmp[k] = json.encode(v)
            setFlag = true
        end

        if setFlag then
            local acKey = mkCacheKey(hashUsersTask,bid)
            local ret = redis:hmset(acKey,tmp)
            redis:expire(acKey,expireTs)
        end
    end
end

function areawar.getTroopsByBinfo(binfo)
    local troops = {
        {}
    }
    
    local heros = {
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

    return troops,heros
end

return areawar
