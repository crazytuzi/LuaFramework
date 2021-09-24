--[[
    伟大航线(军团)
    
    外敌入侵据点有锁定期，在锁定期内同步跨服数据
    点击查看外敌入侵或直接攻击时也要做未同步回来数据的情况的检测
]]
local function model_agreatroute(self)
    -- 固定写法 ------------

    self._initPrivate{
        dbData={ -- 初始化的数据
            aid=0,
            bid=0,  -- 大战id
            st=0, -- 大战开启时间
            apply=0, -- 报名标识
            score=0,   -- 分数
            ranking = 0, -- 排名
            f1 = 0,f2 = 0,f3 = 0,f4 = 0,
            f5 = 0,f6 = 0,f7 = 0,f8 = 0,
            f9 = 0,f10 = 0,f11 = 0,f12 = 0,
            f13 = 0,f14 = 0,f15 = 0,f16 = 0,
            f17 = 0,f18 = 0,f19 = 0,f20 = 0,
            f21 = 0,f22 = 0,f23 = 0,f24 = 0,
            f25 = 0,
            pspeed = 0, -- 积分生产速度
            invade_at = 0, -- 下次入侵时间
            produce_at=0, -- 上次生产时间
            rebel={}, -- 据点叛军
            invadertroops={}, -- 入侵部队
            updated_at=0,   -- 更新时间
        },
        pkName = "aid", -- 主键名
        tableName = "agreatroute", -- 表名
    }

    -- ----------------
    -- 数据格式说明：
    --[[]]

    local consts = {
    }

    -- 记录待同步至跨服的数据
    local syncData = {}

    -- 重置数据(大战结束后)
    local function reset()
        self.bid=0
        self.st=0
        self.apply=0
        self.score=0
        self.ranking=0
        self.rebel={}
        self.pspeed=0
        self.invade_at=0
        self.produce_at=0
        self.invadertroops={}

        for k,v in pairs(getConfig("greatRoute").map) do
            if type(self[k]) == "number" then
                self[k] = 0
            else
                self[k] = {}
            end
        end
    end

    -- 入侵列表的缓存key
    local function getInvaderListCacheKey()
        return string.format("z%d.greatRoute.invaderList.%d.b%d.%d",getZoneId(),self.bid,self.aid,self.invade_at)
    end

    -- 军团生产速度的缓存key
    local function getPSpeedCacheKey(bid)
        return string.format("z%d.greatRoute.productSpeed.score.b%d",getZoneId(),bid)
    end

    local function getEventsCacheKey()
        return string.format("z%d.greatRoute.allianceEvents.score.b%d.%d",getZoneId(),self.bid,self.aid)
    end

    -- 按客户端要求,返回模块数据
    function self.toArray()
        local data = {
            aid=self.aid,
            bid=self.bid,
            st=self.st,
            apply=self.apply,
            score=self.score,
            invade_at = self.invade_at,
            rebel=self.rebel,
            invadertroops=self.invadertroops,
        }

        local map = {}

        for k in pairs(getConfig("greatRoute").map) do
            map[k] = self[k]
        end

        -- 地块数据与其它模块数据分开返
        return map, data
    end

    function self.save()
        if self.aid > 0 then
            return self._save()
        end
    end

    function self.init()
        if self.bid > 0 then
            -- 过期需要重置数据（写死7天后过期）,玩家反馈问题有数据可查
            local totalTime = (getConfig("greatRoute").main.totalTime+7) * 86400
            if (self.st + totalTime) < os.time() then
                reset()
            end

            -- 与策划沟通过先入侵后算分
            self.checkInvadeStatus()
            self.produceScore()
        end
    end

    --[[
        生产积分

        当据点探索达到指定要求时，会切换为已完成的状态，
        已完成的部分据点会在比赛期内根据时间产生军团积分；
        （据点根据时间产出的形式为X点/h，于每个小时的初始进行计算，
        计算的最小单位为小时不足1小时也按照1小时计算。
        即某个据点于7点59分开始产出，则8点整时仍可获得1小时的产出）；
    ]]
    function self.produceScore()
        if self.pspeed > 0 and self.produce_at > self.st then
            local ts = os.time()
            local produceTime = ts - self.produce_at
            local h = math.floor(produceTime / 3600)
            if h > 0 then
                self.score = self.score + h * self.pspeed
                self.produce_at = self.produce_at + h * 3600
            end
        end
    end

    -- 检测入侵状态
    function self.checkInvadeStatus()
        if self.invade_at > 0 then
            local ts = os.time()
            if ts >= self.invade_at then
                local weets = getWeeTs()
                local invadeTime = getConfig("greatRoute").main.invadeTime

                -- 如果当前时间大于当天最后一次入侵时间,下次入侵时间出现在第二天
                if ts > (weets + invadeTime[#invadeTime] * 3600) then
                    weets = weets + 86400
                end

                local nextTs
                for _,hour in pairs(invadeTime) do
                    nextTs = hour * 3600 + weets
                    if ts < nextTs then
                        -- 设置下次入侵时间,并重置入侵标识和生产速度
                        self.invade_at = nextTs
                        self.setInvadeFlag()
                        self.setProduceSpeed()
                        break
                    end
                end
            end
        end
    end

    function self.serverRequest(params)
        local config = getConfig("config.z"..getZoneId()..".worldwar")
        local result = sendGameserver(config.host,config.port,params)

        -- 服务器无返回
        if type(result) ~= "table" then
            writeLog({params=params,serverRequest=result or "no result"},"greatroute")
            return false
        end

        if result.ret == 0 then
            return true, result
        end

        return false, result.ret
    end

    -- 邮件通知军团全体成员
    function self.mailNotify(mailType,members)
        if not members then
            local execRet, code = M_alliance.getMemberList{aid=self.aid}
            if execRet and execRet.data and execRet.data.members then
                members = execRet.data.members
            end
        end

        if members then
            local content = json.encode({type=mailType})
            for k,v in pairs(members) do
                local uid = tonumber(v.uid) or 0
                if uid > 0 then
                    MAIL:mailSent(uid,1,uid,'','',mailType,content,1,0)
                end
            end
        end
    end

    -- 生成地图据点
    function self.createFort()
        local bossCfg = getConfig("alliancebossCfg")
        local greatRouteCfg = getConfig("greatRoute")
        local mRebel = loadModel("model.rebelforces")

        setRandSeed()
        self.rebel = {}

        for fortId,fortCfg in pairs(greatRouteCfg.map) do
            if fortCfg.type == 2 then
                -- 设置据点BOSS的总血量
                self[fortId] = bossCfg.getBossHp(fortCfg.bossLevel)
            elseif fortCfg.type == 3 then
                self.rebel[fortId] = {}
                self[fortId] = fortCfg.completeNeed
                
                local rebelLevels = {}

                -- 设置当前据点叛军列表
                for i=1,fortCfg.completeNeed do
                    table.insert(rebelLevels,rand(fortCfg.rebelLevel[1], fortCfg.rebelLevel[2]))
                end

                -- 等级小的在前面
                table.sort(rebelLevels)

                for _,lv in pairs(rebelLevels) do
                    table.insert(self.rebel[fortId],{mRebel.createForGreatRoute(lv)})
                end

            else
                self[fortId] = fortCfg.completeNeed or fortCfg.passNeed
            end
        end

        -- 入侵时间
        self.invade_at = self.st + greatRouteCfg.main.timeSection[1] * 86400 + greatRouteCfg.main.invadeTime[1] * 3600
    end

    -- 设置据点入侵标识
    function self.setInvadeFlag(killedFlag)
        if killedFlag then killedFlag = os.time() end
        for fortId,fortCfg in pairs(getConfig("greatRoute").map) do
            if fortCfg.type == 6 then
                if self.canInvade(fortId) then
                    self[fortId] = killedFlag or fortCfg.completeNeed * 3
                    self.invadertroops = {}
                end
            end
        end
    end

    -- 设置据点入侵部队
    -- 外敌入侵的部队的战损会被继承，所以存放的是入侵队列中第一个入侵部队的残余部队的数量
    function self.setInvadeTroops(fortId,invalidFleet)
        self.invadertroops[fortId] = {}
        for k,v in pairs(invalidFleet) do
            if v.id and v.num >= 0 then
                table.insert(self.invadertroops[fortId],v.num)
            else
                table.insert(self.invadertroops[fortId],0)
            end
        end
    end

    -- 报名参战
    -- 需要将军团数据同步至跨服
    function self.applyForWar(bid,st,allianceInfo)
        if not self.checkApplyOfWar() then
            reset()

            self.apply = 1
            self.bid = bid
            self.st = st

            local data={
                cmd='greatroute.server.apply',
                params = {
                    bid="b" .. bid,
                    zid=getZoneId(),
                    aid=self.aid,
                    name=allianceInfo.aname,
                    num = allianceInfo.num,
                    level=allianceInfo.level,
                    fc = allianceInfo.fight,
                    apply_at=os.time()
                    -- st=st,
                    -- et=st,
                }
            }

            if not self.serverRequest(data) then
                return false, -27029
            end

            self.createFort()

            return true
        end
    end

    -- 增加积分
    function self.addScore(score)
        if score > 0 then
            self.score = self.score + score
            self.setSyncData({2,self.score})
            return self.score
        end
    end

    -- 检测报名
    function self.checkApplyOfWar()
        return self.apply == 1
    end

    -- 军团是否可操作(退出,解散,加入,踢出,弹劾)
    function self.allianceCanNotOperate()
        return (not self._isEmpty()) and self.getStage() and self.checkApplyOfWar()
    end

    -- 据点是否解锁
    function self.fortIsUnlock(fortId)
        local fortCfg = getConfig("greatRoute").map[fortId]

        if fortCfg.type == 2 or fortCfg.type == 5 then
            return self[fortId] == 0 
        end

        if fortCfg.type == 3 or fortCfg.type == 4 then
            return (fortCfg.completeNeed - self[fortId]) >= fortCfg.passNeed 
        end

        if fortCfg.type == 6 then
            return ( (fortCfg.completeNeed - self[fortId]) >= fortCfg.passNeed ) or ( self[fortId] > fortCfg.completeNeed )
        end

        if fortCfg.type == 1 then
            return true
        end
    end

    -- 检测据点是否可到达
    function self.checkFortCanReach(fortId)
        local mapCfg = getConfig("greatRoute").map[fortId]
        if mapCfg then
            for _,v in pairs(mapCfg.condition) do
                if self.fortIsUnlock(v) then
                    return true
                end
            end
        end
    end

    function self.bossWasKilled(fortId)
        return self[fortId] == 0
    end

    function self.rebelWasKilled(fortId)
        return self[fortId] == 0
    end

    function self.invaderWasKilled(fortId)
        local mapCfg = getConfig("greatRoute").map[fortId]
        return self[fortId] <= 0 or (self[fortId] == mapCfg.completeNeed * 2) or self[fortId] > mapCfg.completeNeed * 10
    end

    -- 据点是否可入侵
    function self.canInvade(fortId)
        local greatCfg = getConfig("greatRoute")
        if self[fortId] > 0 and self[fortId] <= greatCfg.map[fortId].completeNeed then
            return false
        end

        local ts = os.time()
        if self.invade_at == 0 or ts >= self.invade_at then
            return false
        end
        
        local weets = getWeeTs()
        local invadeTime = greatCfg.main.invadeTime

        local lastInvadeAt
        if self.invade_at <= weets + invadeTime[1] * 3600 then
            lastInvadeAt = weets - 86400 + invadeTime[#invadeTime] * 3600
        else
            local lastTs
            for i=#invadeTime,1,-1 do
                lastTs = invadeTime[i] * 3600 + weets
                if self.invade_at > lastTs then
                    lastInvadeAt = lastTs
                    break
                end
            end
        end

        if self[fortId] < lastInvadeAt then
            return true
        end
    end

    -- return bool 减血后是否被击杀
    function self.deBossHp(fortId,hp)
        if self[fortId] > 0 and hp > 0 then
            self[fortId] = self[fortId] - hp
            if self[fortId] <= 0 then
                self[fortId] = 0
                self.setProduceSpeed()
            end

            return self.bossWasKilled(fortId)
        end
    end

    -- 获取BOSS信息
    function self.getBoss(fortId,level)
        -- 策划要求用军团BOSS的配置
        local bossCfg = getConfig("alliancebossCfg")
        local bossHp = bossCfg.getBossHp(level)
        local bossActiveHp = self[fortId] -- boss当前血量

        local baseTroop = {{"a99999",1},{},{},{},{},{}}
        local bossFleetInfo = initTankAttribute(baseTroop)

        bossFleetInfo[1].anticrit = bossCfg.getBossArmor(level)
        bossFleetInfo[1].evade = bossCfg.getBossDodge(level)
        bossFleetInfo[1].armor = bossCfg.getBossDefence(level)
        bossFleetInfo[1].maxhp = bossActiveHp
        bossFleetInfo[1].hp = bossActiveHp
        bossFleetInfo[1].bossHp = bossHp   -- 总血量
        bossFleetInfo[1].boss = 1

        local copyTable = copyTable
        for i=2,6 do
            bossFleetInfo[i] = copyTable(bossFleetInfo[1])
        end

        -- 部队展示信息，战斗数据，总血量，炮头顺序，当前血量
        return baseTroop, bossFleetInfo, bossHp, bossCfg.paotou, bossActiveHp
    end

    -- 获取据点叛军信息
    -- return 展示信息，叛军详细战斗信息
    function self.getRebel(fortId)
        local rebel = self.rebel[fortId] and self.rebel[fortId][1]
        if rebel then
            return rebel, loadModel("model.rebelforces").getGreatRouteRebelInfo(rebel[1],rebel[2],rebel[3])
        end
    end

    function self.getRebelName(rebelInfo)
        return table.concat(rebelInfo,'-')
    end

    -- 击杀叛军
    function self.killRebel(fortId)
        if self.rebel[fortId] and self.rebel[fortId][1] then
            table.remove(self.rebel[fortId] and self.rebel[fortId],1)
            if self[fortId] > 0 then
                self[fortId] = self[fortId] - 1
                self.setProduceSpeed()
            end
        end
    end

    -- 击杀入侵者
    function self.killInvader(fortId,invaderList)
        self[fortId] = self[fortId] - 1
        if self.invaderWasKilled(fortId) then
            self[fortId] = os.time()
        end

        if self.invadertroops[fortId] then
            self.invadertroops[fortId] = nil
        end

        if type(invaderList) == "table" then
            getRedis():hset(getInvaderListCacheKey(),fortId,json.encode(invaderList))
        end

        self.setProduceSpeed()
    end

    -- 探索普通据点
    -- return 本次是否占领了据点
    function self.explore(fortId)
        if self[fortId] > 0 then
            self[fortId] = self[fortId] - 1
            self.setProduceSpeed()

            return self[fortId] == 0
        end
    end

    -- 探索矿点
    function self.explore6(fortId)
        if self[fortId] > 0 then
            self[fortId] = self[fortId] - 1
            self.setProduceSpeed()

            if self[fortId] == 0 then
                self[fortId] = os.time()
                return true
            end
        end
    end

    -- 1-报名期，2-战斗期，3-领奖期
    function self.getStage(st)
        local cfg = getConfig("greatRoute").main
        local ts = os.time()
        local st = st or self.st

        if ts < st then return end

        local i=0
        for k,v in pairs(cfg.timeSection) do
            i=i+v
            if ts < (st + i * 86400) then
                return k
            end
        end
    end

    -- param int st 大战起始时间
    function self.isApplyStage(st)
        return self.getStage(st) == 1
    end

    function self.isBattleStage(st)
        return self.getStage(st) == 2
    end

    function self.isRewardStage()
        return self.getStage() == 3
    end

    function self.hasInvader(fortId)
        return getRedis():exists(getInvaderListCacheKey())
    end

    --[[
        获取据点的入侵列表

        "invaderList": [
            [
                8,                  // 服id
                2000172,            // 用户id
                9483342,            // 战力
                [                   // 部队信息
                    ["a10001", 4], 
                    ["a10001", 4], 
                    ["a10001", 4], 
                    ["a10001", 4], 
                    ["a10001", 4], 
                    ["a10001", 4]
                ], 
                "小喽啰12",          // 昵称
                "jshhg"             // 军团名
            ], 
        ]
    ]]
    function self.getInvaderList(fortId)
        local result = getRedis():hget(getInvaderListCacheKey(),fortId)
        if result then
            return json.decode(result)
        end

        return {}
    end

    -- 获取据点中可攻击的入侵者信息
    function self.getInvader(fortId,invaderList)
        if not invaderList then
            invaderList = self.getInvaderList(fortId)
        end

        -- TODO 是否要缓存入侵者的信息
        if next(invaderList) then
            local invader = table.remove(invaderList,1)

            local ok,result = self.serverRequest({
                cmd='greatroute.server.getInvader',
                params = {
                    bid="b" .. self.bid,
                    zid=invader[1],
                    uid=invader[2],
                }
            })

            if ok then
                if result.data.invader and result.data.invader.binfo then
                    local binfo = result.data.invader.binfo
                    local troops = result.data.invader.troops
                    if type(self.invadertroops[fortId]) == "table" then
                        for k,num in pairs(self.invadertroops[fortId]) do
                            if binfo[k] and binfo[k].num then
                                if num <= 0 then
                                    binfo[k] = {}
                                    troops.troops[k] = {}
                                else
                                    troops.troops[k][2] = num
                                    binfo[k].num = num
                                    binfo[k].hp = num * binfo[k].maxhp
                                end
                            end
                        end
                    end

                    -- 入侵者展示信息, 入侵者等级，入侵者部队，入侵者战斗数据
                    return invader, result.data.invader.level, troops, binfo
                end
            end 
        end
    end

    -- 入侵逻辑
    -- 排行榜中排名的+2，-2之间随机一个军团的玩家部队。敌方部队入侵不能为本军团玩家的阵容；
    -- 即以入侵的军团的所有部队作为随机池子，每个入侵据点的每一只入侵部队都是从该池子里纯随机出来的。
    function self.invade()
        local data={
            cmd='greatroute.server.getInvaderList',
            params = {
                bid="b" .. self.bid,
                zid=getZoneId(),
                aid=self.aid,
            }
        }

        local ok,result = self.serverRequest(data) 
        if ok then
            -- 未获取到入侵部队
            if not next (result.data.invaderKeys) then
                self.setInvadeFlag(true)
                return
            end

            local invaderData = {}

            -- 排序方法(战力小的排前面)
            local sortByFc = function(a,b) return a[3] < b[3] end

            for fortId,troopKeys in pairs(result.data.invaderKeys) do
                invaderData[fortId] = {}

                for _,v in ipairs(troopKeys) do
                    table.insert(invaderData[fortId],result.data.invaders[v])
                    table.sort(invaderData[fortId],sortByFc)
                end

                invaderData[fortId] = json.encode(invaderData[fortId])
            end

            if next(invaderData) then
                local redis = getRedis()
                local cacheKey = getInvaderListCacheKey()
                redis:hmset(cacheKey,invaderData)
                redis:expire(cacheKey,86400)
            end
        end
    end

    -- 增加战报
    function self.addBattleReport(report)
        report.bid = self.bid
        report.updated_at = os.time()
        return getDbo():insert("ugreatroute_log",report)
    end

    -- 增加战斗事件
    function self.addBattleEvent(report)
        local cacheKey = getEventsCacheKey()
        local redis = getRedis()
        local len = redis:lpush(cacheKey,json.encode(report))

        if len > 20 then
            redis:ltrim(cacheKey,0,19)
        end

        redis:expireat(cacheKey,self.st + getConfig("greatRoute").main.totalTime * 86400)
    end

    -- 设置积分生产速度
    function self.setProduceSpeed()
        local tMap = getConfig("greatRoute").map
        local iSpeed = 0
        for fid,fort in pairs(tMap) do
            if fort.aliScore > 0 then
                if self[fid] == 0 then
                    iSpeed = iSpeed + fort.aliScore
                else
                    if fort.type == 6 then
                        if self.invaderWasKilled(fid) then
                            iSpeed = iSpeed + fort.aliScore
                        else
                            local leftInvader = self[fid] - fort.completeNeed * 2
                            if leftInvader > 0 and leftInvader < fort.completeNeed then
                                local n = (1 - fort.invadeDecrease * leftInvader) * fort.aliScore
                                if n > 0 then
                                    iSpeed = iSpeed + n
                                end
                            end
                        end
                    end
                end
            end
        end

        self.pspeed = iSpeed

        if self.pspeed > 0 and self.produce_at == 0 then
            local ts = os.time()
            self.produce_at = ts - (ts % 3600)
        end
    end

    -- 获取所有军团的数据
    function self.getAgData(bid)
        local cacheKey = getPSpeedCacheKey(bid)
        local redis = getRedis()
        local result = redis:smembers(cacheKey)

        if not next(result) then
            local db = getDbo()
            local sql = string.format("select aid from agreatroute where aid > 0 and bid = %d",bid)
            local data = db:getAllRows(sql)
            local aids = {}
            for k,v in pairs(data) do
                table.insert(aids,v.aid)
            end

            if next(aids) then
                result = aids

                -- 缓存，过期时间以活动设置为活动结束
                local expireTs = getConfig("greatRoute").main.totalTime * 3600
                redis:tk_sadd(cacheKey,aids)
                redis:expire(cacheKey,expireTs)
            end
        end

        return result
    end

    -- 设置军团排名
    function self.setRanking(ranking)
        self.ranking = ranking
    end

    -- 获取军团排行(结算期)
    function self.getRankingList()
        local cacheKey = string.format("z%d.greatRoute.ranking.alliance.%d",getZoneId(),self.bid)
        local redis = getRedis()
        local rankingList = redis:hgetall(cacheKey)

        if not next(rankingList) then
            local ok, result = self.serverRequest{
                cmd='greatroute.server.getAllianceRankingList',
                params = {
                    bid = "b" .. self.bid,
                }
            }

            if ok then
                if next(result.data) then
                    redis:hmset(cacheKey,result.data)
                    redis:expire(cacheKey,86400*2)
                    rankingList = result.data
                end
            end
        end

        return rankingList
    end

    -- 设置同步数据
    function self.setSyncData(data)
        table.insert(data,self.aid)
        table.insert(syncData,data)
    end

    -- 同步数据至跨服
    function self.syncAllData()
        if next(syncData) then
             local data={
                cmd='greatroute.server.syncScore',
                params = {
                    bid="b" .. self.bid,
                    zid=getZoneId(),
                    data = syncData,
                }
            }

            if not self.serverRequest(data) then
                return false, -27029
            end
        end
    end

    return self
end

return model_agreatroute