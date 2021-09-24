--[[
    击杀赛
]]
local seaWar = {
    -- 更新的玩家列表
    updatedList = {},
    -- 存放战场信息
    groundStorage = {},
}

-- 防守方标识
local DEFENDER_FLAG = 2

-- 进攻方标识
local ATTACKER_FLAG = 1

-- 缓存key
local cacheKeys = {
    -- 战场信息
    hashBattleGround = "z%s.seawar.battleground.%s", -- zid,bid
    -- 警告信息
    hashAlertNotice = "z%s.seawar.alertnotice.%s", -- zid,aid
    -- 军团成员
    setAllianceMembers = "z%s.seawar.alliancemembers.%s", -- zid,aid
    -- 玩家的防守分信息(防守分有上限)
    hashEnterScore = "z%s.seawar.enterscore.%s", -- zid,uid
    -- 玩家积分排列
    zsetUserRankList = "z%s.seawar.userranklist", -- zid
    -- 军团积分排名
    stringAllianceRankList = "z%s.seawar.allianceranklist", -- zid
    -- 战场状态
    hashGroundStatus = "z%s.seawar.groundsstatus", -- zid
    -- 军团状态
    hashAllianceStatus = "z%s.seawar.alliancestatus", -- zid
    -- 加入战斗的军团列表
    stringJoinBattleList = "z%s.seawar.joinbattlelist" -- zid
}

-- 所有战场的建筑ID
local bidsCfg = {"b1","b2","b3","b6","b7","b8","b9"}

-- 玩家
local _player = {
    uid = 0, -- 角色id
    aid = 0, -- 所属军团
    cronId = 0, -- 部队ID
    enterAt = 0, -- 进入掉耐久的队列的时间
    arriveAt = 0, -- 抵达时间
    deduraAt = 0, -- 上次减耐久的时间(用来算占领分和占领掉耐久用的)
    scoreAt = 0, -- 上次积分的结算时间
    score = 0, -- 对建筑造成的伤害
    eScore = 0, -- 防守分
    role = 0, -- 进攻或驻守
    tScore = 0, -- 船提供的驻守分
    showScore = 0, -- 显示总获得积分
    wins = 0, -- 剩利次数
}

-- 战场
local _battleGround = {
    mid = 0, -- 地图id
    bid = "", -- 战场标识
    btype = 0, -- 建筑类型
    ownerAid = 0, -- 占有者军团
    level = 0, -- 等级
    deduraAt = 0, -- 上次减耐久的时间(用来算占领分和占领掉耐久用的)
    ownAt = 0, -- 首次变更占领者的时间
    dura = 0, -- 已掉耐久度 
    baseDura = 0, -- 基础耐久度
    aid = 0, -- 战场所属军团ID
    duraCronId = 0, -- 扣耐久的定时ID
    status = 0, -- 状态 0正常 1被摧毁
    cronDealy = 0, -- 耐久定时延时时间
    isDestroyed = false, -- 是否损毁
    players = {}, -- 战场所有玩家列表
}

local warTime = nil
local function getWarTime()
    if not warTime then
        warTime = getModelObjs("aterritory").getWarTime()
    end
    return warTime
end

--[[
    生成标识key
]]
local function mkKey(...)
    return table.concat({ ... }, '-')
end

local cacheKeyFlag = nil
local function setCacheKeyFlag()
    cacheKeyFlag = string.format( "%s.%s",tostring(getZoneId()), tostring( getDateByTimeZone(getWarTime().warEt,"%j") ))
end

-- 生成缓存key
local function mkCacheKey(cacheKey, ...)
    if cacheKeys[cacheKey] then
        return string.format(cacheKeys[cacheKey], cacheKeyFlag, ...)
    end
end

local function firstElement(tb)
    return tb[1]
end

-- 会发生多次战斗
local mBattle = nil
local function getBattleModel()
    if not mBattle then
        require "model.battle"
        mBattle = model_battle()
    end
    return mBattle
end

--[[
    按占领者军团ID把玩家分为进攻和防守组,放进战场
    param table battleGround 战场
    param table players 玩家列表
]]
local function groupByOwnerAid(battleGround,players)
    local attackerList = {}
    local defenderList = {}
    for k,v in pairs(players) do
        if v.aid == battleGround.ownerAid then
            table.insert(defenderList,v)
        else
            table.insert(attackerList,v)
        end
    end

    battleGround.attackerList = attackerList
    battleGround.defenderList = defenderList

    return attackerList,defenderList
end

-- 获取战场的基础耐久度
local function getBattleGroundBaseDuraPoint(bid)
    local allianceBuidCfg = getConfig("allianceBuid")
    return allianceBuidCfg.buildValue[allianceBuidCfg.btype[bid]].Durable[1]
end

--[[
    检测炮塔是否开火
        战场类型为炮塔,并且该战场是防守方的,会开火
    param table battleGround 战场
    param table defender 防守者
    return false|int 如果开火则返回伤害率
]]
local function checkTurretFire(battleGround,defender)
    if defender.aid == battleGround.aid and battleGround.btype == 6 then
        local lv = battleGround.level or 1
        local allianceBuidCfg = getConfig("allianceBuid")
        return allianceBuidCfg.buildValue[battleGround.btype].dam[lv] or allianceBuidCfg.buildValue[battleGround.btype].dam[1]
    end
end

-- t为占据时间点,t'为当前时间点,Num为当前占据数量(最大有效占据数为5),WinNum为战斗胜利次数当前伤害总和为Sdot=dotDem*Num*Σ(t'-t)/dotTime+winOne*WinNum
-- 计算占领方对战场造成的持久值
-- local function calDuraPoint(battleGround,currTime)
--     local point = 0
--     if currTime > deduraAt then
--         local cfg = getConfig('allianceDomainWar')

--         local n = math.floor( (currTime-battleGround.deduraAt)/cfg.dotTime )
--         local n1 = math.floor( (currTime-battleGround.ownAt)/cfg.dotTime )

--         local n2 = n1-n
--         if n2 < 0 then n2 = 0 end
--         for i=1,n do
--             point = point + cfg.DotDem * (n2+i)
--         end

--         if n > 0 then
--             deduraAt = deduraAt + cfg.dotTime * n
--         end
--     end

--     return point,deduraAt
-- end

--[[
    检测参与耐久计算的用户的时间属性
        因为计算耐久是以XX(20)秒为一个回合，检测时要对记录的时间属性进行修正
        参与计算的时间范围应该在大战期间
]]
local function checkCalTime(player)
    if player.deduraAt < warTime.battleSt then
        player.deduraAt = warTime.battleSt
    end

    if player.deduraAt > warTime.battleEt then
        player.deduraAt = warTime.battleEt
    end

    local dotTime = getConfig('allianceDomainWar').dotTime

    if player.deduraAt % dotTime > 0 then
        player.deduraAt = player.deduraAt - (player.deduraAt % dotTime) + dotTime
    end

    if player.enterAt % dotTime > 0 then
        player.enterAt = player.enterAt - (player.enterAt % dotTime) + dotTime
    end
end

--[[
    按时间计算战场掉的耐久度
        战场被敌方占领后,每个占领部队每占领XX秒会对战场造成伤害掉耐久度,玩家获得相对应的积分
        每个占领部队单独计算自己
    return int 本次掉的耐久值
]]
local function calDuraPoint(battleGround,currTime)
    local point = 0
    if type(battleGround.defenderList) == "table" then
        local duraPoint = battleGround.baseDura - battleGround.dura
        if duraPoint > 0 then
            local cfg = getConfig('allianceDomainWar')

            local deDuraNums = {}
            for i=1, cfg.captureTroopLimit do
                -- 敌方占领战场后会成为防守方,所以直接拿防守方来计算
                local player = battleGround.defenderList[i]
                if not player or player.enterAt == 0 or player.role ~= ATTACKER_FLAG then
                    break
                end

                local n = math.floor( (currTime-player.deduraAt)/cfg.dotTime )
                local n1 = math.floor( (player.deduraAt-player.enterAt)/cfg.dotTime )

                if n < 0 then n = 0 end
                if n1 < 0 then n1 = 0 end

                deDuraNums[i] = {n,n1}
            end

            for i=1,math.ceil(duraPoint/cfg.DotDem) do
                local breakFlag = true

                for j,v in pairs(deDuraNums) do
                    if v[1] >= i then
                        breakFlag = false
                        local player = battleGround.players[j]
                        local p = cfg.DotDem * (v[2]+i)
                        point = point + p
                        player.deduraAt = player.deduraAt + cfg.dotTime

                        if point >= duraPoint then
                            p = p - (point - duraPoint)
                            point = duraPoint

                            seaWar.addPlayerScore(player,p)

                            return point
                        else
                            seaWar.addPlayerScore(player,p)
                        end
                    end
                end

                if breakFlag then break end
            end
        end
    end

    return point
end

-- 计算减耐久所需要的时间
-- 按当前战场当前占领者的总人数计算耐久掉为0时的总消耗时长
-- return int 时长(秒)
-- local function calDecrDuraTime(battleGround,currTime)
--     local cfg = getConfig('allianceDomainWar')
--     local duraPoint = battleGround.baseDura - battleGround.dura
--     local playerNum = #battleGround.defenderList

--     -- 只有指定人数会让战场持续掉耐久
--     if playerNum > cfg.captureTroopLimit then
--         playerNum = cfg.captureTroopLimit
--     end
    
--     local n = math.floor( (currTime-battleGround.deduraAt)/cfg.dotTime )
--     local n1 = math.floor( (currTime-battleGround.ownAt)/cfg.dotTime )

--     local n2 = n1-n
--     if n2 < 0 then n2 = 0 end

--     local sec = 0
--     if playerNum > 0 then
--         local point = 0
--         for i=1,math.ceil(duraPoint/cfg.DotDem) do
--             point = point + cfg.DotDem * (n2+i) * playerNum
--             if point >= duraPoint then
--                 sec = i * cfg.dotTime
--                 break
--             end
--         end
--     end

--     return sec
-- end

local function calDecrDuraTime(battleGround,currTime)
    local cfg = getConfig('allianceDomainWar')
    local duraPoint = battleGround.baseDura - battleGround.dura

    local deDuraNums = {}
    for i=1, cfg.captureTroopLimit do
        local player = battleGround.defenderList[i]
        if player and player.enterAt > 0 and player.role == ATTACKER_FLAG then
            checkCalTime(player)
            local n = math.floor( (player.deduraAt-player.enterAt)/cfg.dotTime )
            deDuraNums[i] = n < 0 and 0 or n
        else
            break
        end
    end

    local point = 0
    for i=1,math.ceil(duraPoint/cfg.DotDem) do
        for _,n in pairs(deDuraNums) do
            point = point + cfg.DotDem * (n+i)
            if point >= duraPoint then
                sec = i * cfg.dotTime
                return sec
            end
        end
    end

    return sec
end

-- 计算驻守积分
local function calEnterScore(player,currTime)
    local score = 0
    if currTime > player.scoreAt then
        local cfg = getConfig('allianceDomainWar')
        local n = math.floor( (currTime-player.scoreAt)/ (cfg.enterIntervalTime * 60) )
        if n > 0 then
            score = math.floor( (player.tScore or 0) *  n )
        end
    end

    return score
end

local function newBattleGround(aid,bid,mid,level)
    local ground = copyTable(_battleGround)
    ground.aid = aid
    ground.bid = bid
    ground.btype = getConfig("allianceBuid").btype[bid]
    ground.ownerAid = aid
    ground.baseDura = getBattleGroundBaseDuraPoint(bid)
    ground.mid = mid
    ground.level = level

    return ground
end

-- 获取军团成员列表
local function getAllianceMembersId(aid)
    local cacheKey = mkCacheKey("setAllianceMembers",aid)
    local redis = getRedis()
    local data = redis:smembers(cacheKey)
    if #data < 1 then
        local execRet = M_alliance.getMemberList{aid=aid}
        if execRet and execRet.data and execRet.data.members then
            local uids = {}
            for k,v in pairs(execRet.data.members) do
                table.insert(uids,v.uid)
            end

            if next(uids) then
                redis:tk_sadd(cacheKey,uids)
                redis:expire(cacheKey,86400)
                data = uids
            end
        end
    end

    for k,v in pairs(data) do
        data[k] = tonumber(v)
    end

    return data    
end

local function addPlayerToUpdateList(player)
    if type(player) == "table" and player.uid then
        if not seaWar.updatedList[player.uid] then
            seaWar.updatedList[player.uid] = {}
        end
        seaWar.updatedList[player.uid][player.cronId] = player
    end
end

-- 检查用户的防守分(有上限)
local function checkPlayerEnterScore(uid,score)
    local cacheKey = mkCacheKey("hashEnterScore",uid)
    local redis = getRedis()
    local hScore = redis:hincrby(cacheKey,uid,score)
    redis:expire(cacheKey,86400)

    local cfg = getConfig('allianceDomainWar')
    if hScore > cfg.enterLimitPoint then
        if (hScore - score) > cfg.enterLimitPoint then
            score = 0
        else
            score = cfg.enterLimitPoint - (hScore - score)
        end
    end

    return score
end

-- 改变定时任务
function seaWar.changeCronDealy(id,delay_time)
    local zoneid = getZoneId()
    local scheduleJob = getConfig("config.z".. zoneid ..".scheduleJob")

    local haricot = require "lib.haricot"
    local bs = haricot.new(scheduleJob.host, scheduleJob.port)
    bs:use('battle')
    
    local newWorkId
    id = tonumber(id)
    if ( (type(id) == "number") and (math.floor(id) == id) and (id >= 0) ) then
        local ret,cronData = bs:peek(id)
        if ret and type(cronData) == "table" and cronData.data then
            local res,workId = bs:put(0, delay_time, 2, cronData.data)
            if res then
                newWorkId = workId
                bs:delete(id)
            end
        end
    end

    bs:disconnect()
    return newWorkId
end

--[[
    param string bid 战场标识(一个建筑就是一个战场)
    param int aid 战场所在领地的军团id
]]
function seaWar.getBattleGround(aid,bid,mid,level)
    if not aid or not bid then return end
    local cacheKey = mkCacheKey("hashBattleGround",mkKey(aid,bid))

    if seaWar.groundStorage[cacheKey] then
        return seaWar.groundStorage[cacheKey]
    end

    local data = getRedis():hgetall(cacheKey)

    if not next(data) or tonumber(data.aid) == 0 then
        if mid and level then
            data = newBattleGround(aid,bid,mid,level)
        else
            return {}
        end
    end

    for k,v in pairs(_battleGround) do
        if type(v) == "number" then
            data[k] = tonumber(data[k])
        end
    end

    data.isDestroyed = data.isDestroyed == 1 and true or false

    if data.players then
        data.players = json.decode(data.players)
    end

    if type(data.players) ~= "table" then
        data.players = {}
    end

    data.defenderList = {}
    data.attackerList = {}

    if next(data.players) then
        -- 按进入战场的时间排序
        table.sort(data.players,function(a,b) return (tonumber(a.arriveAt) or 0) < (tonumber(b.arriveAt) or 0) end)

        -- 分组
        groupByOwnerAid(data,data.players)

        -- 刷新占领分
        for k,v in pairs(data.players) do
            seaWar.refPlayerEnterScore(v)
        end
    end

    -- 如果此战场被其它军团占领,需要扣耐久
    if data.ownerAid ~= data.aid then
        seaWar.checkBattleGroundDura(data)
    else
        seaWar.battleGroundIsDestroyed(data)
    end

    seaWar.groundStorage[cacheKey] = data

    return data
end

-- 获取领地的所有战场(除了两个矿点不能攻击，其它的建筑都会成为战场)
function seaWar.getTerritoryBattleGround(aid)
    local battleGrounds = {}
    for k,v in pairs(bidsCfg) do
        battleGrounds[v] = seaWar.getBattleGround(aid,v)
    end
    return battleGrounds
end

-- 是否被摧毁
function seaWar.battleGroundIsDestroyed(battleGround)
    if battleGround.dura >= battleGround.baseDura then
        battleGround.isDestroyed = true
    end
    return battleGround.isDestroyed
end

-- 检测战场耐久
function seaWar.checkBattleGroundDura(battleGround,ts)
    local ts = ts or os.time()
    if ts > warTime.battleEt then
        ts = warTime.battleEt
    end

    if ts > battleGround.deduraAt then
        local point = calDuraPoint(battleGround,ts)
        if point > 0 then
            battleGround.deduraAt = ts
            return seaWar.decrDura(battleGround,point)
        end
    end

    return seaWar.battleGroundIsDestroyed(battleGround)
end

-- 消息广播
function seaWar.broadcast(data,msgType)
    local msg = {
        content = {
            params=data,
            ts = getClientTs(),
            contentType = 4,
            type=msgType or 154,
        },
        type = "chat",
    }
    sendMessage(msg)
end

function seaWar.getAllGroundStatus()
    local cacheKey = mkCacheKey("hashGroundStatus")
    local redis = getRedis()
    return redis:hgetall(cacheKey)
end

function seaWar.getGroundStatus(mid)
    return tonumber(getRedis():hget(mkCacheKey("hashGroundStatus"),mid))
end

-- status 1是耐久降低，2是被摧毁
function seaWar.setGroundStatus(battleGround,status)
    if type(battleGround) == "table" and battleGround.mid then
        local cacheKey = mkCacheKey("hashGroundStatus")
        local redis = getRedis()
        if redis:hset(cacheKey,battleGround.mid,status) then
            if status == 1 then
                seaWar.broadcast({battleGround.mid,status,battleGround.bid})
            end
        end

        if battleGround.bid == "b1" and status == 2 then
            seaWar.setAllianceStatus(battleGround.aid,status)
            local mAterritory = getModelObjs("aterritory",battleGround.aid,false,true)
            if mAterritory then
                mAterritory.setWarStatus(2)
                mAterritory.saveData()
            end
        end

        redis:expire(cacheKey,18000)
    end
end

function seaWar.setAllianceStatus(aid,status)
    local cacheKey = mkCacheKey("hashAllianceStatus")
    local redis = getRedis()
    redis:hset(cacheKey,aid,status) 
    redis:expire(cacheKey,18000)
end

function seaWar.getAllianceStatus(aid)
    local cacheKey = mkCacheKey("hashAllianceStatus")
    local redis = getRedis()
    if type(aid) == "table" then
        local data = {}
        local result = redis:hmget(cacheKey,aid)
        for k,v in pairs(aid) do
            data[v] = tonumber(result[k])
        end
        return data
    else
        return tonumber(redis:hget(cacheKey,aid))
    end
end

-- 扣耐久
function seaWar.decrDura(battleGround,dura)
    if battleGround.dura <= 100 then
        seaWar.setGroundStatus(battleGround,1)
    end
    battleGround.dura = battleGround.dura + dura
    return seaWar.battleGroundIsDestroyed(battleGround)
end

function seaWar.newPlayer(uid,aid,cronId,role)
    local ts = os.time()
    local player = copyTable(_player)
    player.uid=uid
    player.aid=aid
    player.cronId=cronId
    player.role = role
    player.scoreAt = ts
    player.arriveAt = ts
    return player
end

function seaWar.addPlayer(battleGround,player)
    if type(battleGround.players) ~= "table" then
        battleGround.players = {}
    end

    if player.aid == battleGround.ownerAid then
        table.insert(battleGround.defenderList,player)
    else
        table.insert(battleGround.attackerList,player)
    end

    addPlayerToUpdateList(player)
    table.insert(battleGround.players,player)
end

-- 增加玩家对建筑造成的伤害
function seaWar.addPlayerScore(player,score)
    player.score = (player.score or 0) + score
end

-- 增加防守分
function seaWar.addPlayerEnterScore(player,score)
    player.eScore = math.floor( (player.eScore or 0) + score )
    local enterLimitPoint = getConfig('allianceDomainWar').enterLimitPoint
    if player.eScore >= enterLimitPoint then
        player.eScore = enterLimitPoint
    end
end

-- 刷新驻守积分
-- 别的军团的进攻方是不会有驻守积分的
function seaWar.refPlayerEnterScore(player)
    if player.role == DEFENDER_FLAG and player.scoreAt > 0 then
        local ts = os.time()

        if player.scoreAt < warTime.battleSt then
            player.scoreAt = warTime.battleSt
        end

        if player.scoreAt > warTime.battleEt then
            player.scoreAt = warTime.battleEt
        end

        if ts > warTime.battleEt then
            ts = warTime.battleEt
        end

        local score = calEnterScore(player,ts)
        if score > 0 then
            seaWar.addPlayerEnterScore(player,score)
            player.scoreAt = ts
        end
    end
end

-- tScore是驻守部队提供的基础积分,只有前往驻守的玩家才会大于0
function seaWar.setPlayerTroopScore(player,troops)
    if player.role == DEFENDER_FLAG then
        local warCfg = getConfig('allianceDomainWar')
        local tankCfg = getConfig("tank")

        player.tScore = 0
        if type(troops) == "table" then
            for k,v in pairs(troops) do
                if v[1] and v[2] then
                    player.tScore = player.tScore + (warCfg.troopPoint[tankCfg[v[1]].level] or 0) * v[2]
                end
            end
            player.tScore = math.floor(player.tScore)
        end
    end
end

-- todo 缓存丢失怎么办
function seaWar.setUserRanking(uid,score)
    local cacheKey = mkCacheKey("zsetUserRankList")
    local redis = getRedis()
    redis:zadd(cacheKey,score,uid)
    redis:expire(cacheKey,518400)
end

-- {"name",fc,score}
function seaWar.getUserRankList()
    local redis = getRedis()
    local cacheKey = mkCacheKey("zsetUserRankList")
    
    local list = {}
    local result = redis:zrevrange(cacheKey,0,19,'withscores')
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            table.insert(list,{v[1],v[2]})
        end
    end
    return list
end

function seaWar.setAllianceRanking(result,expireAt)
    local list= {}
    
    if type(result) == "table" and next(result) then
        local cfg = getConfig('allianceDomainWar')
        local data = {}

        for k,v in pairs(result) do
            if (tonumber(v.ws) or 0) >= cfg.everyAllianceL then
                table.insert(data,v)
                if #data > 20 then break end
            end
        end

        if next(data) then
            local aidlist = {}
            for k,v in pairs(data) do
                table.insert(aidlist,v.aid)
            end

            local setRet,code=M_alliance.getalliancesname{aids=json.encode(aidlist)}
            if type(setRet['data'])=='table' and next(setRet['data']) then
                local tmp = {}
                for k,v in pairs(setRet['data']) do
                    tmp[v.aid] = {v.name,v.fight}
                end

                for k,v in pairs(data) do
                     table.insert(list,{tmp[v.aid][1] or "",tonumber(tmp[v.aid][2]) or 0,tonumber(v.ws) or 0,tonumber(v.aid)})
                end     
            end
        end
    end

    local cacheKey = mkCacheKey("stringAllianceRankList")
    local redis = getRedis()
    redis:set(cacheKey,json.encode(list))
    redis:expireat(cacheKey,expireAt)

    return list
end

function seaWar.getMembersScoreFromDb(limit)
    local sql = string.format("select aid,sum(warscore) as ws from atmember where warscore > 0 and war_at > %d group by aid order by ws desc",warTime.battleSt)
    if limit then
        sql = sql .. " limit " .. tonumber(limit)
    end
    return getDbo():getAllRows(sql)
end

-- TODO 如果缓存丢失
function seaWar.refAllianceRanking()
    local ts = os.time()
    local warTime = getWarTime()
    local list = {}

    if ts >= warTime.battleSt then
        local result = seaWar.getMembersScoreFromDb(20)
        if ts <= warTime.battleEt then
            list = seaWar.setAllianceRanking(result,ts+600)
        elseif ts <= warTime.warEt then
            list = seaWar.setAllianceRanking(result,warTime.warEt)
        end
    end

    return list
end

function seaWar.getAllianceRankList()
    local redis = getRedis()
    local cacheKey = mkCacheKey("stringAllianceRankList")

    local list = {}
    local result = redis:get(cacheKey)
    if type(result) == "string" then
        list = json.decode(result) or {}
    else
        list = seaWar.refAllianceRanking()
    end
    return list
end

-- 删除用户
function seaWar.delPlayer(battleGround,player)
    local data

    if battleGround.players then
        if player then
            for k,v in pairs(battleGround.players) do
                if v.uid == player.uid and v.cronId == player.cronId then
                    data = table.remove(battleGround.players,k)
                    break
                end
            end
        else
            data = table.remove(battleGround.players)
        end

        if #battleGround.players == 0 then
            seaWar.changeBattleGroundOwner(battleGround.aid,battleGround)
        end

        addPlayerToUpdateList(data)

        -- 删除进攻方的警报
        if data and data.role == 1 then
            seaWar.delAlert(battleGround.aid,data.cronId)
        end
    end

    return data
end

function seaWar.changeBattleGroundOwner(ownerAid,battleGround)
    if ownerAid ~= battleGround.ownerAid then
        local ts = os.time()
        battleGround.ownerAid = ownerAid
        battleGround.deduraAt = ts
        battleGround.ownAt = ts

        return true
    end
end

function seaWar.clearDestroyCron(battleGround)
    if battleGround.duraCronId then
        local zoneid = getZoneId()
        local scheduleJob = getConfig("config.z".. zoneid ..".scheduleJob")
        local haricot = require "lib.haricot"
        local bs = haricot.new(scheduleJob.host, scheduleJob.port)
        bs:use('battle')
        
        id = tonumber(battleGround.duraCronId)
        if ( (type(id) == "number") and (math.floor(id) == id) and (id >= 0) ) then
            local ret,cronData = bs:peek(id)
            if ret and type(cronData) == "table" and cronData.data then
                bs:delete(id)
            end
        end

        bs:disconnect()
        battleGround.duraCronId = 0
    end
end

-- 设置摧毁战场的定时
function seaWar.setDestroyCron(battleGround)
    if battleGround.isDestroyed then
        local cronParams = {cmd ="territory.seawar.decrDura",params={bid=battleGround.bid,aid=battleGround.aid,mid=battleGround.mid,dpAddFlag=1}}
        local ret,cronId = setGameCron(cronParams,5)
        if ret then
            battleGround.duraCronId = cronId
        end
    end
end

-- 设置耐久掉为0时的定时
-- 被其它军团占领每X秒会掉一点耐久
function seaWar.setDecrDuraCron(battleGround)
    if battleGround.ownerAid ~= battleGround.aid then 
        local ts = os.time()
        local second = calDecrDuraTime(battleGround,ts)
        if second > 0 then
            local dotTime = getConfig('allianceDomainWar').dotTime
            if second >= dotTime then
                second = second - ts % dotTime
            end

            if battleGround.duraCronId == 0 then
                local cronParams = {cmd ="territory.seawar.decrDura",params={bid=battleGround.bid,aid=battleGround.aid,mid=battleGround.mid}}
                local ret,cronId = setGameCron(cronParams,second)
                if ret then
                    battleGround.duraCronId = cronId
                end

                battleGround.cronDealy = ts + second
            else
                if battleGround.cronDealy ~= (ts + second) then
                    battleGround.duraCronId = seaWar.changeCronDealy(battleGround.duraCronId,second+5)
                end

                battleGround.cronDealy = ts + second
            end

            return true
        end
    end
end

--[[
    攻击分为进攻方和防守方
    玩家依次对战，胜利继续，失败换人，直至一方胜利
        队列1有：A、B、C三名玩家，队列2有：D、E、F三名玩家；
        队列1vs队列2时，按照上面排序内容出战：
        首先，分别由A和D出战，
        若A胜，则D退出战斗，A以剩余部队直接与队列2的E战斗，
        若A败，则队列1中由B出战与队列2中D的剩余部队战斗；
        以此类推直至一方部队耗尽；

    防守方全部战败后，需要检测进攻方队列中是否有不同军团的攻击者，如果有则重新分组后再次战斗
    
    param table battleGround 战场信息
    param table attackerList 进攻方列表
    param table defenderList 防守方列表
    param place 战场坐标
]]
function seaWar.attack(battleGround,attackerList,defenderList,place)
    battleGround.battleFlag = true
    if #attackerList > 0 and #defenderList > 0 then
        local mBattle = getBattleModel()
        while(#attackerList > 0 and #defenderList > 0) do
            local attacker = firstElement(attackerList)
            local defender = firstElement(defenderList)

            -- 记录进攻方与防守方,战斗后统一处理相关积分和对数据进行保存
            addPlayerToUpdateList(attacker)
            addPlayerToUpdateList(defender)

            -- 检测炮台是否开火
            local turretFire = checkTurretFire(battleGround,defender)

            -- 进攻者与防守者进行战斗，返回胜利标识与双方剩余的部队
            local isVictory, aSurviveTroops, dSurviveTroops = mBattle.battleSeaWar(seaWar,attacker,defender,place,turretFire,battleGround)
            
            local loser

            if isVictory == -2 then
                -- 进攻方未取到部队,把攻击者移出队列
                loser = table.remove(attackerList,1)
            elseif isVictory == -3 then
                -- 防守方未取到部队，把防守者移出队列
                loser = table.remove(defenderList,1)
            elseif isVictory == 1 then
                -- 进攻方胜利，移除防守者
                print("attacker win")
                loser = table.remove(defenderList,1)
                -- 刷新进攻者的驻守部队分(战斗后有变化),进攻者可能就是该战场的驻守者,是来夺回该战场的
                seaWar.setPlayerTroopScore(attacker,aSurviveTroops)
                attacker.wins = attacker.wins + 1

                -- 如果防守方是该战场的驻守者,需要扣除战场耐久
                if defender.aid == battleGround.aid then
                    local cfg = getConfig('allianceDomainWar')
                    seaWar.decrDura(battleGround,cfg.winOne)
                    seaWar.addPlayerScore(attacker,cfg.winOne)

                    -- 如果战场被摧毁,设置摧毁的定时
                    -- 进攻者直接返回,移除进攻者
                    if battleGround.isDestroyed then
                        seaWar.addPlayerScore(attacker,cfg.destroyPoint)
                        seaWar.changeBattleGroundOwner(attacker.aid,battleGround)
                        seaWar.setDestroyCron(battleGround)
                        getUserObjs(attacker.uid).getModel('troops').fleetBack(attacker.cronId)

                        table.remove(attackerList,1)
                        return
                    end
                end
            else
                -- 防守方胜利
                print("defender win")

                loser = table.remove(attackerList,1)
                seaWar.setPlayerTroopScore(defender,dSurviveTroops)
                defender.wins = defender.wins + 1
            end

            if loser and loser.role == ATTACKER_FLAG then
                seaWar.delAlert(battleGround.aid,loser.cronId)
            end
        end

        -- 进攻方胜利,队列中有可能存在多个军团,重新分组并战斗
        if #attackerList > 0 and not battleGround.isDestroyed then
            seaWar.changeBattleGroundOwner(firstElement(attackerList).aid,battleGround)
            local newAttackerList,newDefenderList = groupByOwnerAid(battleGround,table.values(attackerList))
            
            if #newAttackerList > 0 and #newDefenderList > 0 then
                return seaWar.attack(battleGround,newAttackerList,newDefenderList,place)
            else
                -- seaWar.setDecrDuraCron(battleGround)
            end
        end
    elseif #attackerList == 1 and #defenderList == 0 then
        seaWar.changeBattleGroundOwner(firstElement(attackerList).aid,battleGround)
        groupByOwnerAid(battleGround,table.values(attackerList))
        -- seaWar.setDecrDuraCron(battleGround)
    elseif #attackerList > 1 and #defenderList == 0 then
        seaWar.changeBattleGroundOwner(firstElement(attackerList).aid,battleGround)
        local newAttackerList,newDefenderList = groupByOwnerAid(battleGround,table.values(attackerList))
        if #newAttackerList > 0 and #newDefenderList > 0 then
            return seaWar.attack(battleGround,newAttackerList,newDefenderList,place)
        else
            -- seaWar.setDecrDuraCron(battleGround)
        end
    end 

    -- 检查下掉耐久的队列
    seaWar.checkDeDuraQueue(battleGround)

    if seaWar.setDecrDuraCron(battleGround) then
        -- 首次占领，直接扣一点耐久
        if battleGround.dura == 0 then
            seaWar.decrDura(battleGround,1)
            if battleGround.defenderList and battleGround.defenderList[1] then
                seaWar.addPlayerScore(battleGround.defenderList[1],1)
            end
        end
    end
end

-- TODO 没有拿到用户怎么办
function seaWar.savePlayers()
    local warCfg = getConfig('allianceDomainWar')
    local pushData = {event={f=1,m=2}}
    for uid,data in pairs(seaWar.updatedList) do
        local uobjs = getUserObjs(uid)

        local userScore
        local getScore = 0
        local mAtmember

        for cid,v in pairs(data) do
            if v.score and v.score > 0 then
                mAtmember = uobjs.getModel('atmember')
                userScore = mAtmember.addSeaWarScore(v.score)
                getScore = getScore + v.score
                print(v.showScore ,v.score)
                v.showScore = v.showScore + v.score
                v.score = 0
            end

            if v.eScore and v.eScore > 0 then
                v.showScore = v.showScore + v.eScore
                v.eScore = checkPlayerEnterScore(v.uid,v.eScore)
                if v.eScore > 0 then
                    mAtmember = uobjs.getModel('atmember')
                    userScore = mAtmember.addSeaWarScore(v.eScore)
                    getScore = getScore + v.eScore
                end
                v.eScore = 0
            end
        end

        if uobjs.save() then
            if userScore and userScore > warCfg.rankLimit then
                seaWar.setUserRanking(uid,userScore)
            end

            -- if mAtmember and mAtmember.aid and getScore > 0 then
            --     seaWar.setAllianceRanking(mAtmember.aid,getScore)
            -- end

            regSendMsg(uid,"msg.event",pushData)
        end
    end

    seaWar.updatedList = {}
end

-- 检测掉耐久的队列
function seaWar.checkDeDuraQueue(battleGround)
    if battleGround.aid ~= battleGround.ownerAid then
        if next(battleGround.defenderList) then
            local cfg = getConfig('allianceDomainWar')
            for i=1,cfg.captureTroopLimit do
                local player = battleGround.defenderList[i]
                if player and player.enterAt == 0 then
                    local ts = os.time()
                    if ts % cfg.dotTime  > 0 then
                        ts = ts - (ts % cfg.dotTime) + cfg.dotTime
                    end

                    if ts < warTime.battleSt then
                        ts = warTime.battleSt
                    end

                    if ts > warTime.battleEt then
                        ts = warTime.battleEt
                    end

                    player.enterAt = ts
                    player.deduraAt = ts
                end
            end
        end
    end
end

function seaWar.reGroup(battleGround)
    groupByOwnerAid(battleGround,battleGround.players)
end

function seaWar.saveBattleGround(battleGround)
    if not battleGround or not battleGround.aid then
        return false
    end

    if battleGround.battleFlag then
        battleGround.players = {}
        for k,v in pairs(battleGround.attackerList) do
            table.insert(battleGround.players ,v)
        end

        for k,v in pairs(battleGround.defenderList) do
            table.insert(battleGround.players ,v)
        end
    end

    --TODO 会被调多次
    if battleGround.isDestroyed then
        if battleGround.duraCronId == 0 then
            seaWar.setDestroyCron(battleGround)
        elseif battleGround.status == 0 and (battleGround.cronDealy + 20) < os.time() then
            battleGround.cronDealy = os.time()
            seaWar.setDestroyCron(battleGround)
        end
    elseif battleGround.aid == battleGround.ownerAid then
        if battleGround.duraCronId ~= 0 then
            seaWar.clearDestroyCron(battleGround)
        end
    end

    local cacheKey = mkCacheKey("hashBattleGround",mkKey(battleGround.aid,battleGround.bid))
    local redis = getRedis()
    local data = {}

    for k,v in pairs(_battleGround) do
        if type(v) == "table" then
            data[k] = json.encode(battleGround[k])
        else
            data[k] = battleGround[k]
        end
    end

    data.isDestroyed = data.isDestroyed and 1 or 0

    redis:hmset(cacheKey,data)
    redis:expire(cacheKey,259200)
end

-- 删除警告
function seaWar.delAlert(aid,enemyCid)
    local cacheKey = mkCacheKey("hashAlertNotice",aid)
    local redis = getRedis()
    local n = redis:hdel(cacheKey,enemyCid)

    if n > 0 and redis:hlen(cacheKey) == 0 then
        local pushCmd = 'push.territory.seawar'
        local pushData = {dwEnemyFlag=0}
        for _,uid in pairs(getAllianceMembersId(aid)) do
            regSendMsg(uid,pushCmd,pushData)
        end
    end
end

function seaWar.delAlertByBid(aid,bid)
    local cacheKey = mkCacheKey("hashAlertNotice",aid)
    local redis = getRedis()
    if bid == "b1" then
        redis:del(cacheKey)
    else
        local data = redis:hgetall(cacheKey)
        local rmKeys = {}
        for k,v in pairs(data) do
            if string.find(v, bid) == 1 then
                table.insert(rmKeys,k)
            end 
        end

        if #rmKeys > 0 then
            redis:tk_hmdel(cacheKey,rmKeys)
        end
    end
end

function seaWar.getAlertList(aid)
    local cacheKey = mkCacheKey("hashAlertNotice",aid)
    return getRedis():hvals(cacheKey)
end

function seaWar.addAlert(aid,bid,enemyCid,enemyAname,enemyUname)
    local cacheKey = mkCacheKey("hashAlertNotice",aid)
    local redis = getRedis()
    redis:hset(cacheKey,enemyCid,mkKey(bid,enemyAname,enemyUname))

    if redis:hlen(cacheKey) == 1 then
        local pushCmd = 'push.territory.seawar'
        local pushData = {dwEnemyFlag=1}
        for _,uid in pairs(getAllianceMembersId(aid)) do
            regSendMsg(uid,pushCmd,pushData)
        end
    end

    -- 3小时过期
    redis:expire(cacheKey,10800)
end

function seaWar.winDebuff(wins,fleet)
    local cfg = getConfig('allianceDomainWar')
    if wins > cfg.downValue then
        wins = wins - cfg.downValue
        local val = cfg.winDebuff * wins
        if val > cfg.winDebuffMax then
            val = cfg.winDebuffMax
        end

        for k,v in pairs(fleet) do
            if v.dmg and v.maxhp then
                v.dmg = math.ceil(v.dmg * (1-val))
                v.maxhp = math.ceil(v.maxhp * (1-val))
                v.hp = v.maxhp * v.num
            end
        end
    end
end

-- 获取参战列表
function seaWar.getJoinBattleList()
    local cacheKey = mkCacheKey("stringJoinBattleList")
    local redis = getRedis()
    local data = redis:get(cacheKey)

    if data then
        data = json.decode(data)
    end

    if type(data) ~= "table" then
        local warTime = getWarTime()
        local list = {}
        local db = getDbo()
        local applySt = warTime.warSt - ( (7-2) * 86400) -- 周6开始新一期,周1开始报名
        local applyEt = warTime.beginSt
        local result = db:getAllRows(string.format("select aid,level,mapx,mapy from territory where mapx > 0 and mapy > 0 and apply = 1 and apply_at < %d and apply_at > %d",applyEt,applySt))

        local aidlist = {}
        for k,v in pairs(result) do
            table.insert(aidlist,tonumber(v.aid))
        end

        local allianceNames = {}
        local setRet,code=M_alliance.getalliancesname{aids=json.encode(aidlist)}
        if type(setRet['data'])=='table' and next(setRet['data']) then
            for k,v in pairs(setRet['data']) do
                allianceNames[v.aid] = v.name
            end 
        end

        for k,v in pairs(result) do
            table.insert(list,{tonumber(v.mapx),tonumber(v.mapy),tonumber(v.level),(allianceNames[tonumber(v.aid)] or ""),tonumber(v.aid),getMidByPos(tonumber(v.mapx),tonumber(v.mapy))})
        end

        redis:setex(cacheKey,86400,json.encode(list))

        data = list
    end

    return data
end

-- 战场建筑是否可攻击
-- 如果攻击的建筑不是炮塔,需要检测4个炮塔(有可能没有建造)是否都已经被摧毁
function seaWar.isAssaultable(aid,bid,pos)
    local allianceBuidCfg = getConfig("allianceBuid")
    if allianceBuidCfg.btype[bid] ~= 6 then
        local mTerritory = getModelObjs("aterritory",aid,true)
        local turretMap = mTerritory.getTurretMapByBidPos(bid,pos)
        if next(turretMap) then
            local cacheKey = mkCacheKey("hashGroundStatus")
            local data = getRedis():hmget(cacheKey,turretMap)

            for k in pairs(turretMap) do
                if tonumber(data[k]) ~= 2 then
                    return false
                end
            end
        end
    end

    return true
end

function seaWar.getAllianceMembersId(aid)
    return getAllianceMembersId(aid)
end

local function inRange(x,y,mainX,mainY,rangeVal)
    if rangeVal then
        rangeVal = rangeVal / 2
        return (math.abs(x-mainX) < rangeVal) and (math.abs(y-mainY) < rangeVal)
    end
end

local function inSeawarRange(x,y,aid)
    local ts = getClientTs()
    if ts > warTime.battleSt and ts < warTime.battleEt then
        local allianceBuildCfg = getConfig("allianceBuid")
        local buildType = allianceBuildCfg.btype.b1

        local applyList = seaWar.getJoinBattleList()
        local groundStatus = seaWar.getAllGroundStatus()
        for k,v in pairs(applyList) do
            if tonumber(groundStatus[tostring(v[6])]) ~= 2 then
                if inRange(x,y,v[1],v[2],allianceBuildCfg.buildValue[buildType].range[v[3]]) then
                    return true,{v[1],v[2]}
                end
            end
        end
    end
end

function seaWar.checkBaseFly(x,y,aid,baseLevel)
    local blowFlyFlag = false
    local flag,territoryPos = inSeawarRange(x,y,aid)
    if flag then
        -- 已报名可以被击飞
        if aid and aid > 0 and getModelObjs("aterritory",aid,true).checkApplyOfWar() then
            blowFlyFlag = 1
        -- 未报名的小号可以被击飞
        elseif (getVersionCfg().roleMaxLevel - baseLevel) >= getConfig('allianceDomainWar').flyLevel then
            blowFlyFlag = 2
        end
    end

    return blowFlyFlag, territoryPos
end

function seaWar.userBaseMoveOutWarRange(mUserinfo,territoryPos,allianceLogo)
    if type(territoryPos) ~= "table" then
        return false
    end

    local mapX = territoryPos[1]
    local mapY = territoryPos[2]
    local cfg = getConfig('allianceDomainWar')
    local minR = cfg.minFly
    local maxR = cfg.maxFly

    setRandSeed()
    for search=1,10 do
        local angle = rand(1,360)
        local r = rand(minR,maxR)

        x = math.ceil( r * math.cos(math.rad(angle)) + mapX )
        y = math.ceil( r * math.sin(math.rad(angle)) + mapY )

        local x1 = x - 2
        local x2 = x + 2
        local y1 = y - 2
        local y2 = y + 2

        if x1 < 5 then x1 = 5 end
        if y1 < 5 then y1 = 5 end
        if x2 > 595 then x2 = 595 end
        if y2 > 595 then y2 = 595 end

        local db = getDbo()
        local sql = "select id,x,y,type from map where type=0 and x>:x1 and x<:x2 and y>:y1 and y<:y2"
        local result = db:getAllRows(sql,{x1=x1,y1=y1,x2=x2,y2=y2})

        if not result or #result < 1 then
            -- return randRange(mapX,mapY,minR,maxR)
        else
            for i=1,#result do
                local k = rand(1,#result)
                local pos = result[k]

                if commonLock(tostring(pos.id),"maplock") then
                    local ret = db:update('map',{
                            name=mUserinfo.nickname,
                            oid=mUserinfo.uid,
                            type=6,
                            level=mUserinfo.level,
                            power=mUserinfo.fc,
                            rank=mUserinfo.rank,
                            alliance=mUserinfo.alliancename,
                            protect=mUserinfo.protect,
                            pic=mUserinfo.pic,
                            allianceLogo=allianceLogo,
                        },
                        string.format("id=%d and type=0",pos.id)
                    )

                    commonUnlock(tostring(pos.id),"maplock")
                    
                    if ret and ret > 0 then
                        local oldMapPos = {mUserinfo.mapx,mUserinfo.mapy}
                        local oldMapid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
                        require("lib.map"):format(oldMapid,true)

                        -- 广播消息
                        seaWar.broadcast({{mUserinfo.mapx,mUserinfo.mapy},{pos.x,pos.y}},155)

                        mUserinfo.mapx = tonumber(pos.x)
                        mUserinfo.mapy = tonumber(pos.y)

                        setGameCron({cmd ="admin.setusermap",params={uid=mUserinfo.uid,blow=1,action="checkUserMap"}},30)

                        return true, {oldMapPos,{pos.x,pos.y}}
                    end
                else
                    table.remove(result,k)
                end
            end    
        end
    end
end

function seaWar.init()
    warTime = nil
    setCacheKeyFlag()
    seaWar.updatedList = {}
    seaWar.groundStorage = {}
end

return seaWar
