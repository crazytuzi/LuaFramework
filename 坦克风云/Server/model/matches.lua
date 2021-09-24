--
-- 跨服战开战时间数据
-- User: luoning
-- Date: 14-9-28
-- Time: 下午4:38
--

function model_matches(flag)

    local self = {
        --跨服基本信息，开战时间，开展结束时间，战斗Id
        base={},
        --baseinfo 开战时间，押注时间等
        baseinfo={},
        --参赛用户信息
        joinUser={},
        --比赛结果
        battleList={},
        --比赛结束后排名信息{'fu.uid','fu.uid','fu.uid'}
        ranking={},
        --参赛用户信息
        userinfo={},
        --错误码
        errorCode = -1,
        --修复数据flag
        repairFlag = false
    }

    --得到比赛的场次信息
    --
    --return table
    self.getAllInfo = function()

        local matchinfo = self.getMatchInfo()
        --缓存有数据
        if type(matchinfo) == 'table' and next(matchinfo) and matchinfo.base then
            if not flag then
                self.getMultInfo()
            end
            return true
        end

        --根据sevbattleCfg计算比赛的id
        require "model.serverbattle"
        local mServerbattle = model_serverbattle()
        --1 个人战
        --缓存跨服战的基本信息
        local mMatchinfo, code = mServerbattle.getRoundInfo(1)
        --记录错误信息
        if code < 0 then
            self.errorCode = code
        end
        if not next(mMatchinfo) then
            return {}
        end
        mMatchinfo['matchId'] = self.createMatchId(mMatchinfo['bid'], mMatchinfo['round'])
	    self['base'] = mMatchinfo
        self.clearCache()
        if self.cacheinfo('base', mMatchinfo, mMatchinfo.et) then
            if not flag then
                self.getMultInfo()
            end
        end
        return true
    end

    --检查是否发送全服邮件
    --
    --return void
    self.checkAllUser = function()

        if self.base.reward[self.base.matchId] then
            return true
        end
        local crossCfg = getConfig('serverWarPersonalCfg')
        local getTime = self.baseinfo[2][#(self.baseinfo[2])][1] + crossCfg.battleTime * 3
        if getTime > getClientTs() then
            return true
        end
        return false
    end

    --设置已经领取奖励标识
    --
    --params info
    --
    --return void
    self.cacheRewardResult = function(info)
        self.base.reward = info
        self.cacheinfo('base', self.base)
    end

    --全服发邮件
    --
    --return boolean
    self.getAllUserReward = function()

        local apiFile = "api.cross.winmail"
        require (apiFile)
        api_cross_winmail({params={}})
    end

    --清除缓存
    --
    --return boolean
    self.clearCache = function()

        if not self.base.matchId then
            return true
        end
        local redisKey =self.getRedisKey()
        local redis = getRedis()
        --baseinfo 开战时间，押注时间等
        self.baseinfo={}
        --参赛用户信息
        self.joinUser={}
        --比赛结果
        self.battleList={}
        --比赛结束后排名信息{'fu.uid','fu.uid','fu.uid'}
        self.ranking={}
        --参赛用户信息
        self.userinfo={}
        if redis:del(redisKey) then
            return true
        end
        return false
    end


    --得到所有的信息
    --
    --return table
    self.getMatchInfo = function()
	    local data = {}
        local matchKey = self.getRedisKey()
        local redis = getRedis()
        local tmpData = redis:hgetall(matchKey)
        if type(tmpData) == 'table' then
            for item, info in pairs(tmpData) do
                self[item] = json.decode(info)
            end
            data = tmpData
        end
        if self.base.et then
            --初始化信息
            if self.base.et < getClientTs() then
                --跨服基本信息，开战时间，开展结束时间，战斗Id
                self.base={}
                --baseinfo 开战时间，押注时间等
                self.baseinfo={}
                --参赛用户信息
                self.joinUser={}
                --比赛结果
                self.battleList={}
                --比赛结束后排名信息{'fu.uid','fu.uid','fu.uid'}
                self.ranking={}
                --参赛用户信息
                self.userinfo={}
                return {}
            end
        end
        return data
    end

    --得到轮数Id
    --
    --params bid 跨服id
    --params round 第几轮
    --
    --return string
    self.createMatchId = function(bid, round)
        return bid .. '_' .. round
    end

    -- 某回合的对阵列表信息是否是旧的
    -- 原来是直接用长度小于4来判断的,后面优化扩展出了一个地形字段,是旧数据的时候长度也是5,只不过第3,4位是空字串""
    --  if vv["a"] and #vv["a"] < 4 
    local function roundBattleListIsOld(info)
        return (info[3] == "" and info[4] == "")
    end

    --格式化信息
    --
    --return table
    self.getMultInfo = function()

        local config = getConfig('serverWarPersonalCfg')
        local startCfg = config.startBattleTs
        local preTime = config.preparetime
        local betCfg = {config.betTs_a, config.betTs_b }

        --转换为时间戳
        local getStartTime = function(matchst, startTime, vate, pretime, eightTime)
            local st = getWeeTs(matchst)
            local diffTime = matchst - st
            local plusTime = 0
            if diffTime > (eightTime[1] * 3600 + eightTime[2] * 60) then
                plusTime = 24 * 3600
            end
            local vSt = st + (vate - 1) * 24 * 3600
            return vSt + startTime[1] * 3600 + startTime[2] * 60 + pretime * 24 * 3600 + plusTime
        end
        -- 返回回合产生的事件
        -- table['产生季军轮次','产生冠军轮次']
        local function getRoundEvents(num)
            return {math.logn(num,2) * 2 -2,math.logn(num,2) * 2 -1}
        end
        local needDay = getRoundEvents(config.sevbattlePlayer)
        local baseinfo = {
            [1] = {[1]={getStartTime(self.base.st, startCfg[1], 1, preTime, startCfg[1]), getStartTime(self.base.st, betCfg[1], 1, preTime, startCfg[1])} },
            [2] = {},
        }
        for i = 1, needDay[2] do
            local index = math.ceil(i/2) + 1
            local cfgIndex = ((i+1)%2) + 1
            table.insert(baseinfo[2], {getStartTime(self.base.st, startCfg[cfgIndex], index, preTime, startCfg[1]), getStartTime(self.base.st, betCfg[cfgIndex], index, preTime, startCfg[1])})
        end

        local nowTime = getClientTs()
        local crossinfo = self.battleList
        local userinfo = self.userinfo
        local getFlag = false
        if next(crossinfo) then
            
            for i,v in pairs(crossinfo[1]) do
               for _,vv in pairs(v) do
                  if vv["a"] and roundBattleListIsOld(vv["a"]) and nowTime >= baseinfo[1][i][1] then
                       getFlag = true
                  end
               end
            end
            for i,v in pairs(crossinfo[2]) do
                for _,vv in pairs(v) do
                    if vv["a"] and roundBattleListIsOld(vv["a"]) and nowTime >= baseinfo[2][i][1] then
                        getFlag = true
                    end
                end
            end
            --bug处理
            if not next(crossinfo[1]) or not next(crossinfo[2]) then
                getFlag = true
            end
            if getFlag then
                crossinfo, userinfo = self.getCrossInfo()
            end
        else
			--三天后取赛程信息
            if (getWeeTs(self.base.st) + preTime*24*3600) <= nowTime then
                crossinfo, userinfo = self.getCrossInfo()
            end
        end

        --重新设置战队 抓取排行榜
        if (getWeeTs(self.base.st) + preTime*24*3600 + 30 * 60) <= nowTime
            and (not next(crossinfo) or type(crossinfo[1]) ~= 'table' or
                type(crossinfo[2]) ~= 'table' or
                not next(crossinfo[1] or not next(crossinfo[2])))
        then
            self.repairFlag = true
        end

	    --参赛用户信息
        if next(crossinfo)
                and crossinfo[1]
                and crossinfo[1][1]
                and crossinfo[1][1][1]
        then
            self.joinUser = {}
            for _,v in pairs(crossinfo[1][1][1]) do
                table.insert(self.joinUser, v[1])
                table.insert(self.joinUser, v[2])
            end
        end
        --检查赛程是否完整
        local Group = 0
        local Step = 0
        local Stime = 0
        for group,detail in pairs(baseinfo) do
            for step, index in pairs(detail) do
                if nowTime >= index[1] then
                    Group = group
                    Step = step
                    Stime = index[1]
                end
            end
        end

        if Group ~= 0 then
            --胜者组
            local winFlag = next(crossinfo)
                    and crossinfo[Group]
                    and crossinfo[Group][Step]
                    and crossinfo[Group][Step][1]
                    and crossinfo[Group][Step][1]["a"]
                    and crossinfo[Group][Step][1]["a"][3]
            --败者组
            local failFlag = next(crossinfo)
                    and crossinfo[Group]
                    and crossinfo[Group][Step]
                    and crossinfo[Group][Step][2]
                    and crossinfo[Group][Step][2]["a"]
                    and crossinfo[Group][Step][2]["a"][3]
            if not winFlag and not failFlag then
                writeLog("get battle info failed bid "..self.base.matchId.." Group "..Group .. " Step "..Step .. " Stime " .. Stime, "cross")
            end
        end


        --触发获取排名信息
        if next(crossinfo)
            and crossinfo[2]
            and crossinfo[2][needDay[2]]
            and crossinfo[2][needDay[2]][1]
            and crossinfo[2][needDay[2]][1]["a"]
            and crossinfo[2][needDay[2]][1]["a"][3]
        then
            self.getRankInfo()
        end

        self.baseinfo = baseinfo
        self.userinfo = userinfo
        self.battleList = crossinfo
        -- 更新献花数据
        self.updateBet2CacheFromCrossserver(getFlag)
        return true
    end

    --得到跨服战进行到第几轮
    --
    --return int
    self.getNowRound = function()

        local round = 0
        for i,v in pairs(self.battleList) do
            if next(v) then
                round = round + #v
            end
        end
        return round
    end

    self.fetchInfo = function(cmd, params)

        local data={cmd=cmd,params=params }
        local config = getConfig("config.z"..getZoneId()..".cross")
        local ret = {data={}}
        for i=1,5 do
            ret=sendGameserver(config.host,config.port,data)
            if type(ret) == 'table' and type(ret.ret) == 'number' and ret.ret==0 then
                break
            end
        end
        if type(ret) ~= 'table' or ret.ret ~= 0 then
            writeLog("host and port error", "cross")
            return false
        end
        return ret
    end

    --得到跨服信息
    --
    --return table
    self.getCrossInfo = function()

        local serverinfo = self.fetchInfo('crossserver.battlelist', {bid=self.base.matchId})
        if not serverinfo then
            return {}, {}
        end
        local crossinfo = {}
        local userinfo = {}
        local cacheFlag = true
        if type(serverinfo.data.repair) == 'table' and next(serverinfo.data.repair) then
            cacheFlag = false
            if table.contains(serverinfo.data.repair, getZoneId()) then
                self.repairFlag = true
            end
        end
        if serverinfo.data.d then
            userinfo = serverinfo.data.d
            if type(userinfo) ~= 'table' or not next(userinfo) then
                writeLog("get userinfo failed bid " .. self.base.matchId, "cross")
            end
            --缓存数据
            if cacheFlag and type(userinfo) == 'table' then
                self.cacheinfo('userinfo', userinfo)
            end
        end
        if serverinfo.data.l then
            crossinfo = serverinfo.data.l
            if type(crossinfo) ~= 'table' or not next(crossinfo) then
                writeLog("get battleList failed bid " .. self.base.matchId, "cross")
            end
            --缓存数据
            if cacheFlag and type(crossinfo) == 'table' then
                self.cacheinfo('battleList', crossinfo)
            end
        end
        return crossinfo, userinfo
    end

    --修复参战数据
    --
    --return void
    self.reparisUserData = function()
        local apiFile = "api.cross.finalist"
        require (apiFile)
        api_cross_finalist({params={}})
        writeLog("repair battle bid" .. self.base.matchId, "cross")
    end

    --缓存key
    --
    --return string
    self.getRedisKey = function()
        local matchKey = "z" .. getZoneId() ..".mch.matchinfo"
        return matchKey
    end

    --缓存比赛中的数据
    --
    --params item hash二层key
    --params table info 缓存的信息
    --params et 缓存结束时间
    --
    --return boolean
    self.cacheinfo = function(item, info, et)

        local matchKey = self.getRedisKey()
        local redis = getRedis()
        redis:hset(matchKey, item, json.encode(info))
        if self.base.et  then
            redis:expireat(matchKey, tonumber(self.base.et))
        end
        return true
    end

    --验证比赛是否在进行中
    --
    --params string matchId
    --
    --return boolean
    self.isMatch = function(matchId)

        if matchId ~= self.base.matchId then
            self.errorCode = -20003
            return false
        end
        return true
    end

    --验证用户是否参赛
    --
    --params string uid
    --
    --return boolean
    self.checkJoinUser = function(uid)

        for _,tmpUid in pairs(self.joinUser) do
            if uid == tmpUid then
                return true
            end
        end
        return false
    end

    --验证用户是否参加了某场比赛
    --
    --params string uid fu.uid
    --params string dId 跨服详情Id bid_round_type_smallRound_otype_aid
    --
    --return boolean
    self.checkJoinUserByDid = function(uid, dId)

        local dIdTable = dId:split('_')
        for i, v in pairs(dIdTable) do
            dIdTable[i] = tonumber(v) or v
        end
        if self.createMatchId(dIdTable[1], dIdTable[2]) ~= self.base.matchId then
            self.errorCode = -20003
            return false
        end
        if not self.battleList[dIdTable[3]] 
            or not self.battleList[dIdTable[3]][dIdTable[4]]
            or not self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]]
            or not self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]]
        then
            self.errorCode = -20004
            return false
        end

        if uid ~= self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][1]
                and uid ~= self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][2] then
            self.errorCode = -20005
            return false
        end
        return true
    end

    --是否可以押注
    --
    --params string dId bid_round_type_smallRound_otype_aid
    --
    --return boolean
    self.allowBet = function(dId)

        local dIdTable = dId:split('_')
        for i, v in pairs(dIdTable) do
            dIdTable[i] = tonumber(v) or v
        end

        if self.createMatchId(dIdTable[1], dIdTable[2]) ~= self.base.matchId then
            self.errorCode = -20003
            return false
        end

        if not self.battleList[dIdTable[3]] 
            or not self.battleList[dIdTable[3]][dIdTable[4]]
            or not self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]]
            or not self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]]
        then
            self.errorCode = -20004
            return false
        end
        --比赛已经有结果
        if self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][3] and self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][3] ~= "" then
            self.errorCode = -20006
            return false
        end

        --验证押注时间限制
        if self.baseinfo[dIdTable[3]][dIdTable[4]][2] < getClientTs() then
            self.errorCode = -20007
            return false
        end
        return true
    end

    --是否可以领取积分奖励
    --
    --params matchId 比赛Id bid_round
    --
    --return boolean
    self.allowGetReward = function(matchId)

        local dIdTable = matchId:split('_')
        for i, v in pairs(dIdTable) do
            dIdTable[i] = tonumber(v) or v
        end

        if self.createMatchId(dIdTable[1], dIdTable[2]) ~= self.base.matchId then
            self.errorCode = -20003
            return false
        end
        return true
    end

    --验证用户押注是胜利还是失败
    --
    --params uid 参赛用户id
    --params detailId 详情Id
    --
    --return boolean
    self.isWinMatch = function(uid, dId)

        local dIdTable = dId:split('_')
        for i, v in pairs(dIdTable) do
            dIdTable[i] = tonumber(v) or v
        end
        if self.createMatchId(dIdTable[1], dIdTable[2]) ~= self.base.matchId then
            return -1
        end

        if not self.battleList[dIdTable[3]]
            or not self.battleList[dIdTable[3]][dIdTable[4]]
            or not self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]]
            or not self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]]
        then
            return -1
        end

        --比赛没有结果
        if not self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][3] or self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][3] == "" then
            return -1
        end

        if self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][3]
                and uid == self.battleList[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][3] then
            return 1
        end
        return 0
    end

    --增加参赛用户积分 bid_round_type_smallRound_otype_aid
    self.addJoinUserPoint = function(uid, dIds)

        local point = 0
        local joinUid = self.createJoinUserId(uid)
        local nowTime = getClientTs()
        if not self.checkJoinUser(joinUid) then
            return point
        end
        --是否已经领取过奖励
        local isGet = function(did, dids)
            for _,v in pairs(dids) do
                if did == v then
                    return false
                end
            end
            return true
        end
        local cfg = getConfig('serverWarPersonalCfg')
        local pCfg = {
            {cfg.winTeam_win, cfg.winTeam_lose},
            {cfg.loseTeam_win, cfg.loseTeam_lose},
        }
        local tmpAddDid = {}
        for mtype,v1 in pairs(self.battleList) do
            for round, v2 in pairs(v1) do
		        for otype, v3 in pairs(v2) do
		            for aid, v4 in pairs(v3) do
			            local tmpDid = self.base.matchId ..'_'..mtype..'_'..round..'_'..otype..'_'..aid
			            local rewardType = pCfg[otype]
			            if isGet(tmpDid, dIds) and v4[3]
                                and (v4[1] == joinUid or v4[2] == joinUid)
                                and nowTime >= self.baseinfo[mtype][round][1] + cfg.battleTime * 3 then
				            local reward = rewardType[2]
                            local win = 0
				            if v4[3] == joinUid then
					            reward = rewardType[1]
                                win = 1
				            end
				            point = point + reward
				            table.insert(dIds, tmpDid)
                            table.insert(tmpAddDid, {reward, 1, tmpDid, self.baseinfo[mtype][round][1] + cfg.battleTime * 3, win})
			            end
		            end
		        end
            end
        end
	    return point, dIds, tmpAddDid
    end
    
    --得到排名信息
    --
    --return table
    self.getRankInfo = function() 
        ----{"cmd":"crossserver.get","params":{"bid":"4278","info":["ranking","point"]},"rnum":2,"ts":1381392586,"zoneid":1}
        local checkranking = function(rank)
            for i,v in pairs(rank) do
                if tonumber(v["ranking"]) == 0 then
                    return false
                end
            end
            return true
        end
        if next(self.ranking) then
            return true
        end
        local info = self.fetchInfo('crossserver.get', {bid=self.base.matchId,info={"ranking", "point", "zid", "nickname"}})
        if not info then
            self.errorCode = -20016
            return false
        end
        if info.data and info.data.d and next(info.data.d) then
              if not checkranking(info.data.d) then
                   writeLog("get ranking failed", "cross")
                   self.errorCode = -20016
                   return false
              end
              self.ranking = info.data.d
              self.cacheinfo('ranking', info.data.d)
              return true
        end
        writeLog("get ranking failed", "cross")
        self.errorCode = -20016
        return false
    end

    --格式化排名信息
    self.formatRanking = function()
        local result = {}
        if next(self.ranking) then
            for _,v in pairs(self.ranking) do
                result[v["uid"]..'-'..v["zid"]] = tonumber(v["ranking"])
            end
        end
        return result
    end

    --得到冠军信息
    self.getWinnerInfo = function()
        local result = {}
        if next(self.ranking) then
            for _,v in pairs(self.ranking) do
                if tonumber(v["ranking"]) == 1 then
                    result.name = v["nickname"]
                    result.server = v["zid"]
                    break
                end
            end
        end

        return result        
    end

    --得到录像信息
    --
    --return table 
    self.getReportInfo = function(params) 
        --{"bid":"1-4-b","round":2,"group":2,"pos":"d","inning":1}
        --params = json.decode('{"round":0,"group":1,"inning":1,"bid":"22","pos":"d"}')
        local index = {"bid", "round", "group", "pos", "inning"}
        local reportRedisKey =  "z" .. getZoneId() ..".mch.reportinfo"
        local key = ''
        for i,v in pairs(index) do
             key = key .. params[v]
        end
        local redis = getRedis()
        local info = redis:hget(reportRedisKey,key)
        if info then
              return json.decode(info)
        end
        local info = self.fetchInfo('crossserver.report', params)
        if not info then
            return {}
        end
        if info.data.report and info.data.report.info then
            redis:hset(reportRedisKey, key, json.encode(info.data.report))
            if self.base.et  then
                redis:expireat(reportRedisKey, tonumber(self.base.et))
            end
            return info.data.report
        end
        writeLog("get report failed " .. json.encode(params), "cross")
        return {}
    end

    -- 本服的献花数据立即同步
    self.updateBet2Cache = function(params)
        local battlelist = self.battleList

        local dIdTable = params.detailId:split('_')
        for i, v in pairs(dIdTable) do
            dIdTable[i] = tonumber(v) or v
        end
        -- 在 6 7号位置追加 [1] [2]号位置 玩家的鲜花数
        if battlelist[dIdTable[3]] 
            and battlelist[dIdTable[3]][dIdTable[4]]
            and battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]]
            and battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]]
        then
            local tmp = self.mkBattleUidKey(params.uid, params.zid)
            if battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][1] == tmp then
                battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][6] = (tonumber(params.flowerNum) or 1) + (tonumber(battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][6]) or 0) 
            elseif battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][2] == tmp then
                battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][7] = (tonumber(params.flowerNum) or 1) + (tonumber(battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][7]) or 0) 
            end
        end

        self.cacheinfo('battleList', battlelist)
        self.battleList = battlelist

    end

    --跨服的献花数每分钟同步一次
    self.updateBet2CacheFromCrossserver = function(flag)
        local redis = getRedis()
        local ts = getClientTs()
        local betRedisKey =  "z" .. getZoneId() ..".warperbet.ts"
        local betTs = redis:get(betRedisKey)
        if not betTs then
            redis:set(betRedisKey, ts)
            redis:expireat(betRedisKey, tonumber(self.base.et))
            betTs = 0
        end
        -- 1分钟之内不同步数据
        if not flag and (ts - betTs) < 60 then
            return false
        end

        local betinfo = self.fetchInfo('crossserver.getuserbet', {bid=self.base.matchId})
        if not betinfo then
            return false
        end

        local battlelist = self.battleList
        for k, v in pairs(betinfo.data.bet) do 
            if v.bet and v.uid and v.zid then
                -- 每个场次
                tmpbet = json.decode(v.bet) or {}
                for kid, vvbet in pairs(tmpbet) do
                    local dIdTable = kid:split('_')
                    for i, vv in pairs(dIdTable) do
                        dIdTable[i] = tonumber(vv) or vv
                    end
                    -- 在 6 7号位置追加 [1] [2]号位置 玩家的鲜花数
                    if battlelist[dIdTable[3]] 
                        and battlelist[dIdTable[3]][dIdTable[4]]
                        and battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]]
                        and battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]]
                    then
                        local tmp = self.mkBattleUidKey(v.uid, v.zid)
                        if battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][1] == tmp then
                            battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][6] = vvbet 
                        elseif battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][2] == tmp then
                            battlelist[dIdTable[3]][dIdTable[4]][dIdTable[5]][dIdTable[6]][7] = vvbet 
                        end
                    end

                end
            end
        end

        self.cacheinfo('battleList', battlelist)
        self.battleList = battlelist

        redis:set(betRedisKey, ts)
        redis:expireat(betRedisKey, tonumber(self.base.et))

        return true
    end

    --生成跨服uid
    --
    --params uid
    --
    --return string
    self.createJoinUserId = function(uid)
        return uid .. '-' .. getZoneId()
    end

    self.mkBattleUidKey = function (uid, zid)
        return uid .. '-' .. zid
    end

    --初始化跨服战信息
    self.getAllInfo()

    return self
end

