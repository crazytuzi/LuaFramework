--
-- 团队跨服站数据
-- User: luoning
-- Date: 2014/12/3
-- Time: 0:56
--

function model_amatches()

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
        --比赛军团信息
        ainfo={},
        --错误码
        errorCode = -1,
        --修复数据flag
        repairFlag = false
    }

    self.setBaseData = function(baseinfo, flag)
        local battleinfo = baseinfo
        if battleinfo.info then
            battleinfo.info = json.decode(battleinfo.info)
        end
        if type(battleinfo.info) ~= "table" then
            battleinfo.info = {}
        end
        self.base = battleinfo
        local battlelist = {}
        if not flag then
            battlelist = self.getAllInfo()
        end
        if battlelist and type(battlelist) == 'table' and next(battlelist) and type(battlelist.data.schedule) == "table" then
            self.battlelist = battlelist.data.schedule
            self.ainfo = battlelist.data.ainfo
        end
        return true
    end

    --得到比赛的场次信息
    --
    --params ref 是否强制刷新数据
    --
    --return table
    self.getAllInfo = function(ref)

        ref = tonumber(ref) or 0

        --多次调用
        if not self.base.st then
            require "model.serverbattle"
            local mServerbattle = model_serverbattle()
            local mMatchinfo= mServerbattle.getAcrossBattleInfo()
            if not next(mMatchinfo)  then
                return response
            end
            self.setBaseData(mMatchinfo, true)
        end

        local redis=getRedis()
        local redisKeys = self.getRedisKey()
        local battleKey = redisKeys["battle"]
        local matchinfo = redis:get(battleKey)
        matchinfo = json.decode(matchinfo)
        if type(matchinfo) ~= "table" then
            matchinfo = {}
        end

        --初始化数据
        local serverCfg = getConfig("serverWarTeamCfg")
        local battleBaseinfo = self.getDetailBattleTime(self.base.st)
        local battleTimes = battleBaseinfo["battleTime"]
        --判断是否刷新数据 是否在战斗时间内 1（是否有可能提前完成比赛,强制刷新用）2是否比赛结束后还没有结果
        --分为三个时间端
        --第一天  中午12点报名截止之后，[开战前--赛程表], [战斗中--(提前结束)], [场次间隔,上一场战斗有结果,],[战斗结束-23:99]
        --第二天  黑夜十二点的时间，[开战前--赛程表], [战斗中--(提前结束)], [场次间隔,上一场战斗有结果,],[战斗结束-23:99]
        --第三天  黑夜十二点的时间，[开战前--赛程表], [战斗中--(提前结束)], [场次间隔,上一场战斗有结果,],[战斗结束-整轮比赛结束]
        --得到开战时间和结束时间
        local getStEtTime = function(timeTable)
            local result = {}
            for i,v in pairs(timeTable) do
                --st,et
                result[i] = {v, v+serverCfg.warTime}
            end
            return result
        end

        --得到间隔时间
        local getGapTime = function(timeTable)
            local result = {}
            for i,v in pairs(timeTable) do
                if result[i+1] then
                    result[i] = {v+serverCfg.warTime, result[i+1]}
                end
            end
            return result
        end

        local nowTime = getClientTs()
        --得到该场比赛是否有结果
        local getWinnerResult = function(today, i)
            today = today < 1 and 1 or today
            local result = false
            if not matchinfo["data"] or not matchinfo["data"]["schedule"]
                    or not matchinfo["data"]["schedule"][today] then
                return result
            end
            local mapIndex = {"a","b","c","d" }
            local tmpSche = {}
            for _,v in pairs(mapIndex) do
                if matchinfo["data"]["schedule"][today][v] then
                    table.insert(tmpSche, matchinfo["data"]["schedule"][today][v])
                end
            end
            if not i then
                i = #tmpSche
            end
            --轮空
            if tmpSche[i][1] == "" and tmpSche[i][2] == "" then
                result = true
            end
            --有胜利者
            if #tmpSche[i] > 2 then
                result = true
            end
            return result
        end

        --检测是否正在比赛进行的时间，ref等于1时，表示提前完成 nowDay第几天
        local getNowMatchFlag = function(stetTime, nowDay)
            local result = false
            for i,v in pairs(stetTime) do
                --强制刷新
                if v[1] <= nowTime and v[2] >= nowTime and tonumber(ref)==1 then
                    local winFlag = getWinnerResult(nowDay, i)
                    if not winFlag then
                        result = true
                        break
                    end
                end
                --正常为上一场比赛的数据 i==1
                if v[1] <= nowTime and v[2] >= nowTime
                        and i==1 and nowDay > 1 then
                    local winFlag = getWinnerResult(nowDay-1)
                    if not winFlag then
                        result = true
                        break
                    end
                end
                --正常为上一场比赛的数据
                if v[1] <= nowTime and v[2] >= nowTime
                        and i>=2 then
                    local winFlag = getWinnerResult(nowDay, i-1)
                    if not winFlag then
                        result = true
                        break
                    end
                end
            end
            return result
        end

        --间隔时间得到上一场的比赛结果
        local getGapFlag = function(gapTimes, nowDay)
            local result = false
            for i,v in pairs(gapTimes) do
                if v[1] <= nowTime and v[2] >= nowTime then
                    local winFlag = getWinnerResult(nowDay, i)
                    if not winFlag then
                        result = true
                        break
                    end
                end
            end
            return result
        end

        --是否需要刷新数据
        local getCrossFlag = false
        for i,v in pairs(battleTimes) do
            local weelTs = getWeeTs(v[1])
            --报名截止-开战前
            local prefixTime = {battleBaseinfo["signupTime"],v[1] }
            if i>=2 then
                prefixTime = {weelTs, v[1]}
            end
            --整体检查有无数据
            if nowTime >= prefixTime[1] and (not matchinfo["data"]  or not matchinfo["data"]["schedule"]) then
                getCrossFlag = true
                break
            end
            if nowTime>=prefixTime[1] and nowTime<=prefixTime[2] then
                if not matchinfo["data"] or not matchinfo["data"]["schedule"]
                        or not matchinfo["data"]["schedule"][i] then
                    getCrossFlag = true
                end
                break
            end
            --比赛进行中检查
            local stetTimes = getStEtTime(v)
            getCrossFlag = getNowMatchFlag(stetTimes, i)
            if getCrossFlag then
                break
            end
            --比赛间隔时间端检查
            local gapTimes = getGapTime(v)
            getCrossFlag = getGapFlag(gapTimes, i)
            if getCrossFlag then
                break
            end
            --比赛结束到第二天开战前
            local lastTime = {stetTimes[#v][2], weelTs + 24 * 3600 }
            if lastTime[1] <= nowTime and nowTime <= lastTime[2] and i < #battleTimes then
                if not matchinfo["data"] or not matchinfo["data"]["schedule"]
                        or not matchinfo["data"]["schedule"][i+1] then
                    getCrossFlag = true
                    break
                end
            end
            --比赛最后一天
            if lastTime[1] <= nowTime and nowTime <= self.base.et and i == #battleTimes then
                if not matchinfo["data"] or not matchinfo["data"]["schedule"]
                        or not matchinfo["data"]["schedule"][i]
                then
                    getCrossFlag = true
                    break
                end
                if type(matchinfo["data"]["schedule"][i]) ~= "table"  then
                    getCrossFlag = true
                    break
                end
                for round,detail in pairs(matchinfo["data"]["schedule"][i]) do
                    if type(detail) ~= "table" or #detail <= 2 then
                        getCrossFlag = true
                        break
                    end
                end
                break
            end
        end

        if getCrossFlag then
            matchinfo = self.fetchInfo('acrossserver.battlelist',{bid=self.base.bid})
            if type(matchinfo)== "table"
                    and matchinfo["ret"] == 0
                    and type(matchinfo["data"]) == "table"
                    and type(matchinfo["data"]["schedule"]) == "table"
            then
                redis:set(battleKey, json.encode(matchinfo))
                redis:expireat(battleKey, self.base.et)
            else
                matchinfo = {}
            end
        end

        return matchinfo
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

    --获取个人的信息
    self.getaMatchUserInfo=function (bid,zid,uid,aid)
        local  info = self.fetchInfo('acrossserver.getuser',{bid=bid,uid=uid,zid=zid,aid=aid})
        return info
    end

    --得到所有的信息
    --
    --return table
    self.getMatchInfo = function(zid,aid,ref)
        local ref =ref  or 0
        -- local redis  = getRedis()
        -- local memkey = ''..  
        -- local data = redis.get()
        local myround = 0
        local info =self.getAllInfo(ref)
        local key = zid.."-"..aid
        local round={a=1,b=2,c=3,d=4}
        local myalliance =nil
        if type(info)=='table' and next(info) and info.data.ainfo[key]  then
            if tonumber(info.data.ainfo[key].status)~=3 then
                local dayround = tonumber(info.data.ainfo[key].round)
                myalliance=info.data.ainfo[key]
                if info.data.schedule[dayround] then
                    for k,v in pairs(info.data.schedule[dayround]) do

                        for k1,v1 in pairs(v) do
                            if v1==key then
                                -- myround 也要按着今天存一下我的军团今天机电厂缓存
                                myround=round[k]
                                break
                            end
                        end
                    end
                end
            end
        end
        local ts = getClientTs()
        local sevCfg=getConfig("serverWarTeamCfg")
        if  myround>0 then
            local weets      = getWeeTs()
            local battle_endts=weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60+sevCfg.warTime
            --ptb:p(info.data.ainfo[key])
            if (ts >battle_endts and tonumber(info.data.ainfo[key].battle_at)<weets) or (ref==1 and tonumber(info.data.ainfo[key].battle_at)<weets) then
                info =self.getAllInfo(ref)
                -- 按今天凌晨时间存一下缓存自己军团的信息
            end


        end
        return info.data,myround,myalliance

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

    --得到跨服战进行到第几轮
    --
    --return int
    self.getNowRound = function()

        local weelTs = getWeeTs()
        local nowTime = getClientTs()
        local timeInfo = self.getDetailBattleTime(self.base.st)
        if timeInfo['signupTime'] > nowTime then
            return false
        end
        local configWeelTS = getWeeTs(timeInfo['signupTime'])
        local num = ((weelTs - configWeelTS) / (24*3600)) + 1
        local betInfo = timeInfo['flowerlimit'][num]
        if not betInfo then
            return false
        end

        if nowTime < betInfo[1] then
            return num
        end

        if nowTime > betInfo[2] then
            return num + 1
        end

        return false
    end

    self.fetchInfo = function(cmd, params, uid)

        local data={cmd=cmd,params=params }
        local config = getConfig("config.z"..getZoneId()..".across")
        if uid then
            data["uid"] = tonumber(uid)
        end
        local zoneid = getZoneId()
        data["zoneid"] = zoneid
        local ret = {data={}}
        for i=1,5 do
            ret=sendGameserver(config.host,config.port,data)
            if type(ret) == 'table' and type(ret.ret) == 'number' and ret.ret==0 then
                break
            end
        end
        if type(ret) ~= 'table' or ret.ret ~= 0 then
            writeLog("host and port error", "across")
            return false
        end
        return ret
    end

    --增加上阵积分
    --
    --params int uid
    --params int aid
    --params table hasAddRound
    --
    self.addJoinUserPoint = function(uid, aid, hasAddRound)

        local checkAid = function(aid)
            if not next(self.base.info) then
                return boolean
            end
            for _,v in pairs(self.base.info) do
                if tonumber(aid) == tonumber(v[1]) then
                    return true
                end
            end
            return false
        end

        --获取aid "a,b,c,d"
        local getSmallRoundByList = function(roundinfo, aid)
            local tmpAid = getZoneId() .. "-" .. aid
            for i,v in pairs(roundinfo) do
                if (v[1] == tmpAid or v[2] == tmpAid) and #(v) > 2 then
                    --"a,b,c,d" , 对方军团id, 1胜利 0失败
                    return i, (v[1] == tmpAid) and v[2] or v[1], (v[3] == tmpAid) and 1 or 0
                end
            end
            return false
        end

        --跨服获取用户的战斗积分数据
        local getAcrossUinfo = function(bid, round, smallRound, aid)
            local params = {action=2, bid=bid, aid=tonumber(aid), group=smallRound, round=tonumber(round),}
            local roundinfo = self.fetchInfo('acrossserver.roundinfo',params, uid)
            if not roundinfo then
                return false
            end
            if roundinfo["ret"] == 0 then
                if roundinfo["data"] and roundinfo["data"]["point"] then
                    return tonumber(roundinfo["data"]["point"]), 0
                end
                return 0, -1
            end
            return false
        end

        --军团是否参战
        if not checkAid(aid) then
            return false
        end

        --hasAddRound{1,2,3}
        if type(hasAddRound) ~= "table" then
            hasAddRound = {}
        end
        local shopScore = 0
        local nowTime = getClientTs()
        local record = {}
        if type(self.battlelist) ~= "table" then
            return false
        end

        for i,v in pairs(self.battlelist) do
            --这场战斗的数据没有加过 teaminfo 每轮比赛各个服的上阵名单
            if (not table.contains(hasAddRound, i)) then
                local smallRound, fuckAid, isWin = getSmallRoundByList(v, aid)
                if smallRound then
                    local tmpScore, status = getAcrossUinfo(self.base.bid, i, smallRound, aid)
                    --积分有数据
                    if tmpScore then
                        --改用户已上阵
                        if status == 0 then
                            shopScore = shopScore + tmpScore
                            local tmpDid = self.base.bid .. "_2_" ..i.."_"..smallRound
                            local tmpFuck = {}
                            if self.ainfo[fuckAid] then
                                table.insert(tmpFuck, self.ainfo[fuckAid]["name"])
                                table.insert(tmpFuck, isWin)
                            end
                            --todo 战斗结束时间判断，替换nowTime
                            table.insert(record, {tmpScore, 1, tmpDid, nowTime, tmpFuck})
                            table.insert(hasAddRound, i)
                            --改用户未上阵
                        else
                            table.insert(hasAddRound, i)
                        end
                        --未请求到任何数据
                    else
                        writeLog("get uinfo failed".. uid, "across")
                    end
                end
            end
        end
        return shopScore, record, hasAddRound
    end

    --缓存key
    --
    --return string
    self.getRedisKey = function()

        --多次调用
        if not self.base.st then
            require "model.serverbattle"
            local mServerbattle = model_serverbattle()
            local mMatchinfo= mServerbattle.getAcrossBattleInfo()
            if not next(mMatchinfo)  then
                return response
            end
            self.setBaseData(mMatchinfo, true)
        end

        local zoneid = getZoneId()
        local keyTable = {}
        --赛程key
        keyTable["battle"] = "z" .. zoneid ..".acrossbattle.matchinfo"..self.base.et.."."..self.base.bid
        --排名key
        keyTable["rank"] = "z" .. zoneid ..".acrossranking.matchinfo"..self.base.et.."."..self.base.bid
        --比赛详情
        keyTable["report"] = "z" .. zoneid ..".acrossreport.matchinfo"..self.base.et.."."..self.base.bid
        --坦克损失
        keyTable["troops"] = "z" .. zoneid ..".acrosstroops.matchinfo"..self.base.et.."."..self.base.bid
        --详情战报Id
        keyTable["dReport"] = "z" .. zoneid ..".acrossdetailreport.matchinfo"..self.base.et.."."..self.base.bid

        return keyTable
    end


    --验证用户是否在某个军团
    --
    --params string uid
    --params string aid
    --
    --return boolean
    self.checkJoinUser = function(uid, aid)

        if not next(self.base.info) or aid == 0 then
            self.errorCode = -1981
            return false
        end

        local Flag = false
        for _,v in pairs(self.base.info) do
            if tonumber(v[1]) == tonumber(aid) then
                Flag = true
                break
            end
        end
        if not Flag then
            self.errorCode = -1981
            return false
        end
        local joinAtData = M_alliance.getuseralliance{uid=uid,aid=aid}
        local joinAt = 0
        if type(joinAtData) == 'table' and joinAtData['ret'] == 0 then
            joinAt = tonumber(joinAtData['data']['join_at']) or 0
        end

        local prepareTime = getConfig('serverWarTeamCfg.preparetime')
        if joinAt == 0 or joinAt > (self.base.st + prepareTime * 24 * 3600) then
            self.errorCode = -1981
            return false
        end
        return true
    end


    --是否可以押注
    --
    --params string dId bid_type_round_detail
    --
    --return boolean
    self.allowBet = function(dId, aid)
        local betTable = self.formatBetId(dId)
        local round = self.getNowRound()
        if not round then
            self.errorCode = -1981
            return false
        end
        if round ~= betTable[3] then
            self.errorCode = -1981
            return false
        end
        if not self.battlelist[betTable[3]]
                or not self.battlelist[betTable[3]][betTable[4]]
                or (self.battlelist[betTable[3]][betTable[4]][1] ~= aid and self.battlelist[betTable[3]][betTable[4]][2] ~= aid)
                or (self.battlelist[betTable[3]][betTable[4]][3])
        then
            self.errorCode = -1981
            return false
        end

        return true
    end

    --验证用户押注是胜利还是失败
    --
    --params uid aid
    --params detailId 详情Id
    --
    --return boolean
    self.isWinMatch = function(aid, dId)
        local didTable = self.formatBetId(dId)
        local betInfo = self.battlelist
        local round = didTable[3]
        local detail = didTable[4]

        if not betInfo[round]
                or not betInfo[round][detail]
                or not betInfo[round][detail][3] then
            return false
        end

        if aid ~= betInfo[round][detail][3] then
            return 1
        end
        return 2
    end

    --得到排名信息
    --
    --return table
    self.getRankInfo = function()

        if type(self.battlelist) ~= "table"
                or not next(self.battlelist)
                or type(self.battlelist[3]) ~= "table"
        then
            return {}
        end

        for i,v in pairs(self.battlelist[3]) do
            if #v <= 2 then
                return {}
            end
        end

        --获取排名信息
        local checkRankinfo = function()
            local tmpresult = {}
            if type(self.ainfo) ~= "table" or not next(self.ainfo) then
                return false
            end
            local randNumTable = {1,2,4,8}
            for i,v in pairs(self.ainfo) do

                if not table.contains(randNumTable, tonumber(v["ranking"])) then
                    return false
                else
                    table.insert(tmpresult, {i, tonumber(v["ranking"]), tonumber(v["point"]), tonumber(v["fight"])})
                end
            end
            table.sort(tmpresult,function(a,b)
                if type(a) == 'table' and type(b) == 'table' then
                    if tonumber(a[2]) < tonumber(b[2]) then
                        return true
                    elseif tonumber(a[2]) == tonumber(b[2]) then
                        if tonumber(a[4]) > tonumber(b[4]) then
                            return true
                        end
                    end
                    return false
                end
            end)
            local result = {}
            local randMap = {1,2,4,4,8,8,8,8 }
            for i,v in pairs(tmpresult) do
                result[v[1]] = {randMap[i],v[3]}
            end
            return result
        end
        --不知道该写点啥 吐槽
        local redis = getRedis()
        local redisKeys = self.getRedisKey()
        local ranking = {}
        local tmpRanking = redis:get(redisKeys["rank"])
        if tmpRanking then
            ranking = json.decode(tmpRanking)
            if type(ranking) == "table" then
                return ranking
            end
        end
        --取缓存数据
        if self.ainfo then
            ranking = checkRankinfo()
            if ranking then
                redis:set(redisKeys["rank"], json.encode(ranking))
                redis:expireat(redisKeys["rank"], self.base.et)
            end
        end
        return type(ranking) == "table" and ranking or {}
    end

    --得到战报信息
    --
    --params string bid 战斗Id
    --params int round 轮数
    --params int did 第几场 abcd
    --params int page  第几页
    --
    --return table
    self.getReportInfo = function(bid, round, did, page, uid, dtype, noCache)

        local reportKey = bid.."_2_"..round.."_"..did
        if dtype == 0 then
            reportKey = reportKey .. "_" .. page
        else
            reportKey = reportKey .. "_" .. page .. "_" .. uid
        end

        local redis = getRedis()
        local redisKeys = self.getRedisKey()
        local pageReportKey = redisKeys["report"] .. "-" .. reportKey

        local testReport
        if noCache == 0 then
            testReport = redis:get(pageReportKey)
            testReport = json.decode(testReport)
        end

        if type(testReport) ~= "table" then
            local params = {bid=bid,round=round,group=did,dtype=dtype,page=page,uid=uid}
            local tmpReport = self.fetchInfo('acrossserver.report',params)
            if not tmpReport then
                writeLog("get across report failed "..reportKey, "across")
                return {}, 0
            end
            if tmpReport["ret"] == 0 and tmpReport["data"] and tmpReport["data"]["report"] then
                testReport = tmpReport["data"]

                if noCache == 0 then
                    for i=1,3 do
                        if redis:set(pageReportKey, json.encode(testReport)) then break end
                    end
                    --设置缓存时间50秒
                    for i=1,3 do
                        if redis:expire(pageReportKey, 120) then break end
                    end
                end
            end
        end

        if type(testReport) ~= "table" or (not next(testReport)) then
            return {}, 0
        end

        return testReport["report"], testReport["nextPage"]
    end


    --格式化押注Id
    --
    --params string betId
    --
    --return table  bid_服内赛1or服外赛2_round_"a,b,c,d"
    self.formatBetId = function(betId)

        local betTable = betId:split("_")
        if #betTable ~= 4 then
            return false
        end
        for i,v in pairs(betTable) do
            betTable[i] = tonumber(v) or v
        end
        return betTable
    end



    --各种时间点
    --
    --params int st 开战时间
    --
    --return table signupTime 报名截止时间  battleTime 每场比赛时间 flowerlimit 禁止献花的时间段
    self.getDetailBattleTime = function(st)

        local sevCfg = getConfig("serverWarTeamCfg")
        local res = {}
        res['signupTime'] = st + (sevCfg.preparetime + sevCfg.signuptime) * 24 * 3600 + sevCfg.applyedtime[1]*3600 + sevCfg.applyedtime[2]*60
        res.battleTime = {}
        for i,v in pairs(sevCfg.startBattleIndex) do
            res.battleTime[i] = {}
            for ii,vv in pairs(v) do
                table.insert(res.battleTime[i], st + (sevCfg.preparetime + sevCfg.signuptime + (i-1)) * 24 * 3600 + sevCfg.startBattleTs[vv][1] * 3600 + sevCfg.startBattleTs[vv][2] * 60)
            end
        end
        res['flowerlimit'] = {}
        for i,v in pairs(sevCfg.flowerLimit) do
            res['flowerlimit'][i] = {
                v[1][1] * 3600 + v[1][2] * 60 + (sevCfg.preparetime + sevCfg.signuptime + (i-1)) * 24 * 3600 + st,
                v[2][1] * 3600 + v[2][2] * 60 + (sevCfg.preparetime + sevCfg.signuptime + (i-1)) * 24 * 3600 + st,
            }
        end
        return res
    end

    --获取详情战报
    self.getDetailReportInfo = function(rId)

        local redis = getRedis()
        local redisKeys = self.getRedisKey()
        local reportKey = redisKeys["dReport"].."-rid-"..rId
        local reportInfo = redis:get(reportKey)
        if reportInfo then
            reportInfo = json.decode(reportInfo)
        end

        if type(reportInfo) ~= "table" or not next(reportInfo) then

            local params = {rId = rId}
            local tmpReport = self.fetchInfo('acrossserver.detailreport',params)
            if tmpReport and tmpReport["data"] and tmpReport["data"]["detailreport"] then
                reportInfo = tmpReport["data"]["detailreport"]
                for i=1,3 do
                    if redis:set(reportKey, json.encode(reportInfo)) then break end
                end
                for i=1,3 do
                    if redis:expire(reportKey, 90) then break end
                end
            end
        end

        return reportInfo
    end

    --得到军团信息
    self.getArmReport = function(bid, round, detailId)

        --跨服获取军团的战斗积分数据
        local getAcrossAinfo = function(bid, round, smallRound, aid)

            aid = aid:split("-")
            aid = tonumber(aid[2])
            local params = {action=1, bid=bid, aid=tonumber(aid), group=smallRound, round=tonumber(round),}
            local roundinfo = self.fetchInfo('acrossserver.roundinfo',params, uid)
            if not roundinfo then
                return false
            end
            if roundinfo["ret"] == 0 then
                if roundinfo["data"] then
                    return roundinfo["data"], 0
                end
                return 0, -1
            end
            return false
        end
        --生成id
        local createId = function(bid, round, group)
            return bid .. "-2-" .. round .. "-" .. group
        end

        local battlelist = self.battlelist
        if (not battlelist[round])
                or (not battlelist[round][detailId])
                or (#battlelist[round][detailId] <= 2) then
            return false
        end

        --轮空的没有战报
        if battlelist[round][detailId][1] == ""
                or battlelist[round][detailId][2] == "" then
            return false
        end

        local redis = getRedis()
        local redisKeys = self.getRedisKey()
        local roundKey = createId(bid,round,detailId)
        local data = redis:hget(redisKeys["troops"], roundKey)
        if data then
            data = json.decode(data)
            return data
        end

        --获取战斗数据
        local tmpData = {}
        if type(data) ~= "table" then
            local status
            local tmpSche, status = getAcrossAinfo(bid, round, detailId, battlelist[round][detailId][1])
            if not status then
                return false
            end
            if type(tmpSche) ~= "table" then
                tmpSche = {}
            end
            for i, v in pairs(tmpSche) do
                v["kills"] = json.decode(v["kills"])
                if v["zid"] .. "-" .. v["aid"] == battlelist[round][detailId][2] then
                    tmpData[v["zid"] .. "-" .. v["aid"]] = v
                end
                if v["zid"] .. "-" .. v["aid"] == battlelist[round][detailId][1] then
                    tmpData[v["zid"] .. "-" .. v["aid"]] = v
                end
            end
            if type(tmpData[battlelist[round][detailId][2]]) ~= "table" then
                tmpData[battlelist[round][detailId][2]] = {}
            end
            if type(tmpData[battlelist[round][detailId][1]]) ~= "table" then
                tmpData[battlelist[round][detailId][1]] = {}
            end
            if battlelist[round][detailId][2] == battlelist[round][detailId][3] then
                tmpData[battlelist[round][detailId][2]]["isWin"] = 1
                tmpData[battlelist[round][detailId][1]]["isWin"] = 0
            else
                tmpData[battlelist[round][detailId][2]]["isWin"] = 0
                tmpData[battlelist[round][detailId][1]]["isWin"] = 1
            end
            redis:hset(redisKeys["troops"], roundKey, json.encode(tmpData))
            redis:expireat(redisKeys["troops"], self.base.et)
        end

        return tmpData
    end

    --获取击毁战斗坦克
    self.getTroopsReportInfo = function(bid, round, detailId)

        local troopsinfo = self.getArmReport(bid, round, detailId)
        if not troopsinfo or not next(troopsinfo) then
            return {}
        end
        local result = {}
        for i,v in pairs(troopsinfo) do
            result[i] = type(v["kills"]) == "table" and v["kills"] or {}
        end
        return result
    end
    -- 获取军团的名字
    function self.getNameByAid(aid)
        if self.ainfo[aid] then
            return self.ainfo[aid]["name"]
        end
        return ""
    end

    return self
end

