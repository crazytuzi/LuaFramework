--[[
    伟大航线 跨服逻辑
]]
-- 缓存key
local cacheKeys = {
    -- 玩家排行
    zsetUserRankList = "greatRoute.ranking.user.%s", -- bid
    -- 军团排行
    zsetAllianceRankList = "greatRoute.ranking.alliance.%s", -- bid
}

--[[
    生成标识key
]]
local function mkKey(...)
    return table.concat({ ... }, '-')
end

-- 生成缓存key
local function mkCacheKey(cacheKey, ...)
    if cacheKeys[cacheKey] then
        return string.format(cacheKeys[cacheKey], ...)
    end
end

-- 这儿直接用了世界大战的数据库配置，省得再加一份要维护
local function DB()
    return getCrossDbo("worldwarserver")
end

-- 用世界大战的缓存
local function RDS()
    return getWorldWarRedis()
end

local GreatRoute = {}

--[[
    新增军团数据
    服内军团长报名时会将军团信息同步至跨服
]]
function GreatRoute:addAllianceDataToDb(bid,data)
    data.score = 0
    data.updated_at = os.time()
    return DB():insert("greatroute_alliance",data)
end

function GreatRoute:getAllianceDataFromDb(bid,zid,aid)
    return DB():getRow("select bid,zid,aid,level,fc,num,name,score from greatroute_alliance where bid=:bid and zid=:zid and aid=:aid limit 1",{bid=bid,zid=zid,aid=aid})
end

--[[
    获取指定服军团全体成员信息
]]
local function getAllianceMembersFromDb(bid,zid,aid)
    local sql = string.format("select zid,uid,pic,apic,bpic,nickname,aname,level,fc from greatroute_user where bid = '%s' and zid = '%d' and aid = '%d'",bid,zid,aid)
    return DB():getAllRows(sql)
end

local memberFields = {
    "bid","zid","aid","uid",
    "pic","bpic","apic","nickname",
    "aname","fc","level","troops","binfo"
}

function GreatRoute:getMemberDataFromDb(bid,uid)
    return DB():getRow("select id,bid,uid from greatroute_user where bid = :bid and uid = :uid",{bid=bid,uid=uid})
end

-- 添加成员数据
function GreatRoute:addMemberDataToDb(bid,data)
    local member = {}
    for k,v in pairs(memberFields) do
        member[v] = data[v]
    end

    member.updated_at = os.time()
    return DB():insert("greatroute_user",member)
end

-- 修改成员
function GreatRoute:updateMemberData(bid,uid,data)
    local member = {}
    for k,v in pairs(memberFields) do
        member[v] = data[v]
    end

    member.updated_at = os.time()

    local db = DB()
    local ret, err = db:update("greatroute_user",member,{"uid","bid"})
    if not ret or ret <= 0 then
        ret = false
        err = db:getError()
    end

    return ret, err
end

--[[
    获取入侵者详细信息
    服内只拉取了入侵列表，战斗时需要来跨服获取入侵者的战斗数据进行战斗

    return troops 战报中需要有原始部队(英雄、飞机 etc) 展示
    return level 是因为入侵列表中没有返回等级，战斗场景中需要有等级显示
]]
function GreatRoute:getInvader(bid,uid)
    local sql = "select troops,binfo,level from greatroute_user where bid = :bid and uid = :uid limit 1"
    local result = DB():getRow(sql,{bid=bid,uid=uid})
    if result then
        result.binfo = json.decode(result.binfo)
        result.troops = json.decode(result.troops)
        result.level = tonumber(result.level)
    end
    return result
end

--[[
    获取军团排行榜
    大战结算期每个游戏服会获取一次最终的前100排行榜，供领奖用

    return zid与aid为key, 排名为值的table
]]
function GreatRoute:getAllianceRankingList(bid)
    local sql = "select zid,aid from greatroute_alliance where bid = :bid and score > 0 order by score desc,fc desc limit 100";
    local data = DB():getAllRows(sql,{bid=bid})

    local list = {}
    for k,v in pairs(data) do
        list[mkKey(v.zid,v.aid)] = k
    end

    return list
end

--[[
    产生入侵者

    矿点中的敌方部队取自于同次活动的其它军团中的玩家部队，
    根据当前军团积分的排行榜中排名的+2，-2之间随机一个军团的玩家部队。
    敌方部队入侵不能为本军团玩家的阵容
]]
function GreatRoute:genInvaders(bid,zid,aid)
    local cacheKey = mkCacheKey("zsetAllianceRankList",bid)
    local aidKey = mkKey(zid,aid)
    local redis = RDS()

    -- 获取该服军团的排名
    local rank = redis:zrank(cacheKey,aidKey)

    local start, stop
    if rank then
        start = rank - 2
        stop = rank + 2
    else
        -- 无排名时,取排名最低的4个
        start = 0
        stop = 4
    end

    if start < 0 then start = 0 end

    -- 入侵军团(zid-aid)
    local invasionAlliance = nil
    local result = redis:zrange(cacheKey,start,stop)

    setRandSeed()
    if type(result) == "table" then
        -- 排除本服自己的军团
        for _,v in pairs(result) do
            if v == aidKey then
                table.remove(result,k)
                break
            end
        end

        if next(result) then
            invasionAlliance = result[rand(1,#result)]
        end
    end

    -- 以入侵的军团的所有部队作为随机池子，
    -- 每个入侵据点的每一只入侵部队都是从该池子里纯随机出来的
    -- invaders只记录被随机出来的入侵者,被选中多次也只记一次
    local invaders = {}

    -- 以据点为key,记录据点内的入侵者对应在invaders里的键值
    local invaderKeys = {}

    if invasionAlliance then
        local t = string.split(invasionAlliance,"-")
        local iZid, iAid = t[1], t[2]
        local members = getAllianceMembersFromDb(bid, iZid, iAid)

        local len = #members
        if len > 0 then
            local randKeys = {}
            for fortId,fortCfg in pairs(getConfig("greatRoute").map) do
                if fortCfg.type == 6 then
                    invaderKeys[fortId] = {}
                    for i=1,fortCfg.completeNeed do
                        local r = rand(1,len)
                        if not randKeys[r] then
                            local user = members[r]
                            table.insert(invaders,{
                                tonumber(user.zid),
                                tonumber(user.uid),
                                tonumber(user.fc),
                                user.nickname,
                                user.aname,
                                user.pic,
                                user.bpic,
                                user.apic,
                            })
                            randKeys[r] = #invaders
                        end
                        
                        table.insert(invaderKeys[fortId],randKeys[r])
                    end
                end
            end
            randKeys = nil
        end
    end

    return invaders,invaderKeys
end

-- 更新玩家积分
local function updateUserScore(bid,zid,aid,uid,score)
    -- local cacheKey = mkCacheKey("zsetUserRankList",bid)
    -- local redis = RDS()
    -- redis:zadd(cacheKey, score, uid)

    local data = {
        bid=bid,
        zid=zid,
        aid=aid,
        uid=uid,
        score=score,
    }

    DB():update("greatroute_user",data,{"bid","zid","aid","uid"})
end

-- 更新军团积分
local function updateAllianceScore(bid,zid,aid,score)
    local data = {
        bid=bid,
        zid=zid,
        aid=aid,
        score=score,
    }

    DB():update("greatroute_alliance",data,{"bid","zid","aid"})
end

function GreatRoute:setAidToCache(bid,zid,aid)
    local cacheKey = mkCacheKey("zsetAllianceRankList",bid)
    local redis = RDS()
    local zaid = mkKey(zid,aid)
    if not redis:zrank(cacheKey,zaid) then
        redis:zadd(cacheKey, 0, zaid)
        redis:expire(cacheKey,10*86400)
    end
end

-- 同步积分
function GreatRoute:syncScore(bid,zid,data)
    if type(data) == "table" then
        local ZAScores = {}
        for k,v in pairs(data) do
            if v[1] == 1 then
                -- 同步玩家
                updateUserScore(bid,zid,v[4],v[2],v[3])
            else
                -- 同步军团
                updateAllianceScore(bid,zid,v[3],v[2])
                ZAScores[mkKey(zid,v[3])] = v[2]
            end
        end

        if next(ZAScores) then
            local cacheKey = mkCacheKey("zsetAllianceRankList",bid)
            local redis = RDS()
            redis:tk_zadd(cacheKey, ZAScores)
            redis:expire(cacheKey,10*86400)
        end
    end
end

return GreatRoute
