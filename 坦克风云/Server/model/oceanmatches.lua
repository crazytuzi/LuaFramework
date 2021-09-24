-- 远洋征战(跨服战)
local function model_oceanmatches(self)
    local consts = {
        BATTLE_TYPE=6, -- 大战类型ID
        WIN=1, -- 胜者标识
    }

    -- 固定写法 ------------
    local private = {
        dbData={ -- 初始化的数据
            id=0,     
            st=0,     
            bid=0,
            et=0,   
            type=consts.BATTLE_TYPE,     
            servers={},   
            round=0,
            ext1=0,     -- 士气值
            gap=0,   
            info={},    
            reward={},  
            updated_at=0,
        },
        pkName = "bid", -- 主键名
        tableName = "serverbattlecfg", -- 表名
    }

    self._initPrivate(private)

    -- ----------------

    local matchSchedule = nil

    function self.init()
    end

    function self.toArray()
        return self._getData()
    end

    -- 是否是空(没有加载到数据)
    function self.isEmpty()
        return self._isEmpty()
    end

    function self.serverRequest(params)
        local config = getConfig("config.z"..getZoneId()..".worldwar")
        local result = sendGameserver(config.host,config.port,params)

        -- 服务器无返回
        if type(result) ~= "table" then
            writeLog({params=params,serverRequest=result or "no result"},"ocean")
            return false
        end

        if result.ret == 0 then
            return result
        end

        return false, result.ret
    end

    -- 开启大战
    function self.startWar(bid,st,et,servers)
        local data={
            cmd='oceanexpedition.server.startWar',
        }

        
        local zid = getZoneId()
        local key = 'z'..zid..'.rank.fc'
        local redis = getRedis()
        local result = redis:zrevrange(key,0,0,'withscores')
        local fc = 0  
        if type(result)=='table' and next(result) then
            fc = type(result[1])=='table' and result[1][2] or zid
        end

        bid = "b"..bid
        data.params = {
            bid=bid,
            st=self.getBattleSt(st),
            et=et,
            servers=servers,
            fc = fc,
            zid = zid,
        }
        
        if not self.serverRequest(data) then
            return false, -27029
        end

        return true
    end

    -- 停止大战
    function self.stopWar(bid)
        local data={
            cmd='oceanexpedition.server.stopWar',
        }

        data.params = {
            bid="b"..bid
        }
        
        if not self.serverRequest(data) then
            return false, -27029
        end

        return true
    end

    function self.writeLog(log)
        writeLog(log, "ocean")
    end

    local overSaveUids = {

    }

    local function getRankingBySchedule()
        local zranking = {}
        local schedule = self.schedule()

        self.writeLog({"schedule",schedule})

        if type(schedule) == "table" then
            local zoneid = getZoneId()
            local OceanExpedition = loadModel("model.oceanexpeditionserver")
            local maxRound = OceanExpedition:getMaxRoundByServers(self.servers)
            self.writeLog({"maxRound",maxRound})

            if table.length(schedule[maxRound]) == 1 then
                local winFlag = consts.WIN
                local rankingCfg = {
                    [1]={1,2},
                    [2]=3,
                    [3]=5,
                }

                local ranking = {}
                for round,data in pairs(schedule) do
                    ranking[round] = {}
                    for group,teamData in pairs(data) do
                        for _,zoneData in pairs(teamData) do
                            if zoneData[1] and zoneData[1] > 0 then
                                ranking[round][zoneData[1]] = zoneData[2]
                            end
                        end
                    end
                end

                local j = 1
                for i=maxRound,1,-1 do
                    for k,v in pairs(ranking[i]) do
                        if j==1 then
                            zranking[k] = v == winFlag and 1 or 2
                        else
                            if v ~= winFlag then
                                zranking[k] = rankingCfg[j]
                            end
                        end
                    end
                    j = j + 1
                end
            end
        end

        return zranking
    end

    local function sendBuffMail(uid,marshalName)
        local content = json.encode{type=85,master=marshalName}
        MAIL:mailSent(uid,1,uid,'','',85,content,1,0)
    end

    -- 胜利军团发送BUFF邮件
    -- param int aid 军团id
    local function setWinnerBuff(aid,buffEt,marshalName)
        local mems = M_alliance.getMemberList{aid=aid}
        if mems and mems.data and mems.data.members then
            for _, v in pairs( mems.data.members) do
                local mid = tonumber(v.uid)
                if mid > 0 then
                    local get,uobjs = pcall(getUserObjs,mid)
                    if get then
                        uobjs.getModel('userinfo').setOceanExpeditionBuff(buffEt)
                        overSaveUids[mid] = uobjs
                        sendBuffMail(mid,marshalName)
                    end
                end
            end
        end

        return mems
    end

    -- 给胜利服全体成员发胜利邮件
    local function sendWinMail(myRanking)
        if myRanking == 1 then
            local st = os.time()
            local et = getWeeTs(st + 2*86400)
            local mailType = 1
            local gift = 13
            local subject = 30  -- 远洋征战定为30
            local oceanExpCfg = getConfig("oceanExpedition")
            local item = copyTable(oceanExpCfg.winSeverReward)
            local content = '{}'
            local sender = 1 -- 系统发送

            MAIL:sentSysMail(st,et,subject,content,mailType,gift,item,sender)
        end
    end

    -- 排行榜奖励
    local function rankingReward(ranking)
        local rwLog = {}

        if ranking and ranking > 0 then
            local oceanExpCfg = getConfig("oceanExpedition")
            local rankingReward
            local sn = #self.servers
            if sn<=2 then
                rankingReward = oceanExpCfg.serverReward2
            elseif sn<=4 then
                rankingReward = oceanExpCfg.serverReward4
            else
                rankingReward = oceanExpCfg.serverReward8
            end

            rwLog.sn = sn
            rwLog.mems1 = {}

            if rankingReward[ranking] then
                local teams = self.getTeams()
                for k,v in pairs( teams ) do
                    if type(v[2]) == "table" then
                        for _,mid in pairs(v[2]) do
                            table.insert(rwLog.mems1,mid)

                            if mid > 0 then
                                local get,uobjs = pcall(getUserObjs,mid)
                                if get then
                                    uobjs.getModel('oceanexpedition').addscore(rankingReward[ranking].point)
                                    overSaveUids[mid] = uobjs
                                    -- uobjs.save()
                                end
                            end
                        end
                    end
                end
            end
        end

        self.writeLog({"rwLog",rwLog})
    end

    local function getOverFlagCacheKey()
        return string.format("z%d.oceanmatches.over.%s",getZoneId(),self.bid)
    end

    function self.setOverFlag()
        self.info.over = 1
        local redis = getRedis()
        local key = getOverFlagCacheKey()
        local ret = redis:set(key,os.time())
        redis:expire(key,604800)
        return ret
    end

    function self.getOverFlag()
        if self.info.over == 1 then return true end

        return getRedis():get(getOverFlagCacheKey())
    end

    -- 大战结束
    -- 23点半的时候跑定时
    function self.over()
        if self.getOverFlag() then
            self.writeLog({"over info:",self.bid,self.info.over})
            return 
        end

        if not self.setOverFlag() then
            self.writeLog({"set over flag failed",self.bid,self.over})
        end

        local zranking = getRankingBySchedule()
        local zoneId = getZoneId()
        local myRanking = zranking[zoneId]

        local overLog = {
            bid = self.bid,
            myRanking = myRanking or 0,
        }

        if myRanking == 1 then
            -- 元帅成为第1
            local marshalUid = self.getMarshalUidFromInfo()
            overLog.marshalUid = marshalUid

            if marshalUid then
                local uobjs = getUserObjs(marshalUid)
                local mUserinfo = uobjs.getModel('userinfo')
                local oceanExpeditionCfg = getConfig("oceanExpedition")
                local buffEt = oceanExpeditionCfg.winnerBuffTime + os.time()

                overLog.marshalAid = mUserinfo.alliance
                if mUserinfo.alliance > 0 then
                    overLog.mems = setWinnerBuff(mUserinfo.alliance,buffEt,mUserinfo.nickname)
                else
                    sendBuffMail(marshalUid,mUserinfo.nickname)
                end

                mUserinfo.setOceanExpeditionBuff(buffEt,1)
                overSaveUids[marshalUid] = uobjs

                local content = {type=86}
                local rewards = oceanExpeditionCfg.marMailReward
                overLog.marshalMail = MAIL:mailSent(marshalUid,1,marshalUid,'',mUserinfo.nickname, 1,content,1,0,12,rewards)
            end
        end

        sendWinMail(myRanking)
        rankingReward(myRanking)

        overLog.save = {}
        for k,v in pairs(overSaveUids) do
            if v.save() then
                table.insert(overLog.save,k)
            end
        end

        self.writeLog({"overLog",overLog})
    end


    -- 核对serverbattlecfg表中的队伍数据跟 oceanexpedition表中的数据是否一致
    function self.checkTeam(bid)
        local db = getDbo()
        local res = db:getAllRows("select uid,job,tid,fc from oceanexpedition where tid>0 and tid<=5 and bid="..bid)
        if type(res)=='table' and next(res) then
            for k,v in pairs(res) do
                local uid = tonumber(v.uid)
                local tid = tonumber(v.tid)
                local job = tonumber(v.job)
                local fc = tonumber(v.fc)
                if not self.checkUidExists(uid,tid+1) then
                    self.joinTeam(tid+1,uid,job,fc)
                    self.save()
                    writeLog("核对队伍数据时添加的玩家uid="..uid..'job='..job..'tid='..tid,"ocean")
                end
            end
        end

        return self.info.teams or {}
    end

    -- 设置队伍成员
    function self.setTeams(bid)
        -- 核对数据
        local teams = self.checkTeam(bid)
        for i=1, getConfig("oceanExpedition").teamNum do
            if not teams[i] then
                teams[i] = {}
            end
        end

        local data={
            cmd='oceanexpedition.server.setTeam',
            params={
                zoneid=getZoneId(),
                bid="b"..bid,
                teams=teams,
            }
        }

        if not self.serverRequest(data) then
            return false, -27029
        end
        
        return true
    end

    -- 获取战斗的起始时间(前期准备和报名等时间不算)
    function self.getBattleSt(matchSt)
        local oceanExpCfg = getConfig("oceanExpedition")
        return getWeeTs(matchSt + (oceanExpCfg.matchTime1-1) * 86400)
    end

    -- 返回当前轮次
    function self.getCurrentRound(st,servers,ts)
        return loadModel("model.oceanexpeditionserver"):getCurrentRound(self.getBattleSt(st),servers,ts)
    end

    function self.checkSchedule(schedule)
        for k,v in pairs(schedule) do
            for m,n in pairs(v) do
                if n[2] then return true end
            end
        end
    end

    function self.winOfRound(roundSchedule,zid)
        for k,v in pairs(roundSchedule) do
            for m,n in pairs(v) do
                if n[1] and n[1] == zid and n[2] == consts.WIN then 
                    return true
                end
            end
        end
    end

    function self.schedule()
        if matchSchedule then return matchSchedule end

        local schedule = {}
        if self.isEmpty() then
            return schedule
        end

        local st = self.st
        local ts = getClientTs()
        
        -- 未开始
        if ts<st then return schedule end

        local currRound = self.getCurrentRound(self.st,self.servers,ts)

        local redis = getRedis()
        local keys  = string.format("z%d.serverOcean.matchinfo.stats-%s-%d",getZoneId(),self.bid,currRound)
        local battlelist=json.decode(redis:get(keys))

        -- 缓存有数据直接返回
        if type(battlelist)=='table' and next(battlelist) then
            schedule = battlelist
        end

        if not next(schedule) or ( (#schedule < (currRound + 1) ) and not self.checkSchedule(schedule[currRound]) ) then
            local data={
                cmd='oceanexpedition.server.schedule',
                params={
                    bid = "b"..self.bid
                }
            }

            local ret, code = self.serverRequest(data)
            if not ret then
                return false, code
            end

            schedule = ret.data.schedule
            redis:set(keys,json.encode(schedule))
            redis:expire(keys,86400)
        end
        
        matchSchedule = schedule
        return schedule
    end

    function self.getMorale()
        return self.ext1
    end

    function self.getBAttrByTeam(tid)
        if self.info.teams and self.info.teams[tid] and self.info.teams[tid][1] then
            return getUserObjs(self.info.teams[tid][1],true).getModel('oceanexpedition').getBAttr()
        end
    end

    -- 添加士气
    function self.addMorale(morale)
        if morale <= 0 then return end

        local expCfg = getConfig("oceanExpedition").morale.moralereward.exp
        local maxMorale = expCfg[#expCfg]

        -- 达到上限了就不涨了
        if self.ext1 >= maxMorale then return true end

        local oldMorale = self.ext1

        self.ext1 = math.floor(self.ext1 + morale)
        if self.ext1 < expCfg[1] then
            return true
        end

        local level
        if self.ext1 >= maxMorale then
            self.ext1 = maxMorale
            level = #expCfg
        else
            local function binarySerach(val, tb)
                local beginIdx = 1
                local endIdx = #tb
                local maxIdx = endIdx
                
                while beginIdx <= endIdx do
                    local midIdx = math.floor((beginIdx + endIdx)/2)
                    if val > tb[midIdx] then
                        if maxIdx < midIdx+1 or val < tb[midIdx+1] then
                            return midIdx
                        end
                        beginIdx = midIdx + 1
                    elseif val < tb[midIdx] then
                        endIdx = midIdx - 1
                    elseif val == tb[midIdx] then
                        return midIdx
                    end
                end
            end

            level = binarySerach(self.ext1, expCfg)
        end

        if level and oldMorale < expCfg[level] then
            local data={
                cmd='oceanexpedition.server.setMorale',
                params={
                    bid = "b"..self.bid,
                    zoneid = getZoneId(),
                    morale = level,
                }
            }

            return self.serverRequest(data)
        end

        return true
    end

    -- 获取队伍数据
    function self.getTeams()
        return self.info.teams or {}
    end

    function self.getFlags()
        return self.info.flag or {}
    end

    function self.setInfo(info)
        self.info = info
    end

    function self.getMarshalUidFromInfo()
        local tid = 1
        if self.info.teams and self.info.teams[tid] then
            return self.info.teams[tid][1]
        end
    end

    function self.joinTeam(tid,uid,job,fc)
        if not self.info.teams then
            local teamNum = getConfig("oceanExpedition").teamNum
            self.info.teams = {}
            for i=1, teamNum do
                table.insert(self.info.teams,{})
            end
        end

        local mUserOceanExp = getUserObjs(uid,true).getModel('oceanexpedition')
        local leader = nil
        if mUserOceanExp.isCaptain(job) or mUserOceanExp.isMarshal(job) then
            if not self.info.teams[tid][1] or self.info.teams[tid][1] == 0 then
                self.info.teams[tid][1] = uid
                leader = true
            end
        end

        if not self.info.teams[tid][2] then
            self.info.teams[tid][2] = {uid}
        elseif not table.contains(self.info.teams[tid][2], uid) then
            if leader then
                table.insert(self.info.teams[tid][2],1,uid)
            else
                table.insert(self.info.teams[tid][2],uid)
            end
        end

        if next(self.info.teams[tid][2]) and not self.info.teams[tid][1] then
            self.info.teams[tid][1] = 0
        end

        -- 设置战力
        self.teamfc(1,fc,tid)
    end

    -- 离开队伍
    function self.quitTeam(tid,uid,fc)
        if self.info.teams and self.info.teams[tid] then
            -- 小队长不能离开
            if self.info.teams[tid][1] == uid then
                return false
            end

            if self.info.teams[tid][2] then
                for k,v in pairs(self.info.teams[tid][2]) do
                    if v == uid then
                        table.remove(self.info.teams[tid][2],k)
                        -- 减少战力
                        self.teamfc(2,fc,tid)
                        return true
                    end
                end
            end
            
        end
    end

    -- 队伍增加或者减少战力 五支队伍战力 不算元帅 展示队伍排名用
    -- act 1加 2减
    function self.teamfc(act,fc,tid)
        if not self.info.trank then
            self.info.trank = {}
            for i=1,5 do
                table.insert(self.info.trank,{i,0})--队伍Id 队伍累计战力
            end
        end

        -- 这里面tid都加1处理过 需要减1 才是除元帅外 五支队伍的
        if tid>1 then
            if act==1 then
                self.info.trank[tid-1][2] = self.info.trank[tid-1][2] + fc
            elseif act==2 then
                if self.info.trank[tid-1][2]>fc then
                    self.info.trank[tid-1][2] = self.info.trank[tid-1][2] - fc
                else
                    self.info.trank[tid-1][2] = 0
                end
            end
        end

        return self.info.trank
    end

    -- 获取队伍战力排行 除元帅
    function self.getteamrank(tid)
        local rank = 0
        local trank = copyTable(self.teamfc(3,0,0))
        -- 排序
        table.sort(trank,function ( a,b )  
            return a[2] > b[2]  
        end ) 
 
        for k,v in pairs(trank) do
            if (tid-1)==tonumber(v[1]) then
                rank = k
                break
            end
        end

        return rank
    end


    function self.save()
        if not self.isEmpty() then
            return self._save()
        end
    end

    -- 判断队伍中是否有队长
    function self.captainExits(bid,st,et,tid)
        local db = getDbo()
        local result = db:getRow("select * from oceanexpedition where job=2 and tid=:tid and bid= :bid and apply_at>= :st and apply_at<=:et",{bid=bid,st=st,et=et,tid=tid})

        if type(result)=='table' and next(result) then
            return true
        end
        return false
    end

    -- 队伍中的成员数量
    function self.checkMems(bid,st,et,tid)
        local db = getDbo()
        local result = db:getRow("select count(*) as total from oceanexpedition where tid=:tid and bid= :bid and apply_at>= :st and apply_at<=:et",{bid=bid,st=st,et=et,tid=tid})

        return tonumber(result['total']) or 0
    end

    -- 队伍申请的人数
    function self.applynum(bid,st,et,tid)
        local db = getDbo()
        local result = db:getRow("select appteam from oceanexpedition where job=3 and tid=0 and bid= :bid and apply_at>= :st and apply_at<=:et",{bid=bid,st=st,et=et})
        local apnum = 0
        if type(result)=='table' and next(result) then
            for k,v in pairs(result) do
                local appteam = json.decode(v.appteam)
                if tonumber(appteam[tid])==1 then
                    apnum = apnum + 1
                end
            end
        end
        return  apnum
    end


    -- 生成全服战力排行榜快照
    function self.ranksnap(st,et)
        local list = {}
        local redis = getRedis()
        local key = "z"..getZoneId()..".oceanexpedition.fcrank"..st
       
        if redis:exists(key) then
            return false
        else
            local db = getDbo()
            local result = db:getAllRows(string.format("select uid,fc from userinfo order by fc desc limit 50"))
            if type(result)=='table' and next(result) then
                for k,v in pairs(result) do
                     redis:zadd(key,tonumber(v.fc), tonumber(v.uid))
                end
                redis:expireat(key,et+86400)
            end      
        end

    end

    -- 队伍申请列表
    function self.applist(bid,st,et,tid)
        local db = getDbo()
        local result = db:getAllRows("select uid,nickname,level,fc,appteam from oceanexpedition where job=3 and tid=100 and bid= :bid and apply_at>= :st and apply_at<=:et",{bid=bid,st=st,et=et})
        local list = {}
        if type(result)=='table' and next(result) then
            for k,v in pairs(result) do
                local appteam = json.decode(v.appteam)
                if tonumber(appteam[tid])==1 then
                    table.insert(list,{tonumber(v.uid),v.nickname,tonumber(v.level),tonumber(v.fc)})
                end     
            end
        end
      
        return  list
    end

    -- function getBattleRoundTs(st)
    --     st = getWeeTs(st)
    --     local oceanExpCfg = oceanExpCfg
    --     local baseinfo = {
    --         -- [1] = 0, -- 参赛报名/元帅选拔
    --         -- [2] = 0, -- 队长选拔
    --         -- [3] = 0, -- 队伍调整
    --         -- [4] = 0, -- 比赛期
    --         -- [5] = 0, -- 领奖期
    --     }

    --     baseinfo[1] = {st + (oceanExpCfg.marTime-1) * 86400, st + oceanExpCfg.marTime * 86400 - oceanExpCfg.diffTime * 60}
    --     baseinfo[2] = {st + (oceanExpCfg.tlTime-1) * 86400, st + oceanExpCfg.tlTime * 86400 - oceanExpCfg.diffTime * 60}
    --     baseinfo[3] = {st + (oceanExpCfg.tpTime-1) * 86400, st + oceanExpCfg.tpTime * 86400 - oceanExpCfg.diffTime * 60}

    --     -- 战斗期
    --     baseinfo[4] = {
    --         {   
    --             st + (oceanExpCfg.matchTime1-1) * 86400 + oceanExpCfg.matchTime[1][1]*3600 + oceanExpCfg.matchTime[1][2]*60,
    --             st + (oceanExpCfg.matchTime1-1) * 86400 + oceanExpCfg.matchTime[2][1]*3600 + oceanExpCfg.matchTime[2][2]*60
    --         },
    --         {   
    --             st + (oceanExpCfg.matchTime2-1) * 86400 + oceanExpCfg.matchTime[1][1]*3600 + oceanExpCfg.matchTime[1][2]*60,
    --             st + (oceanExpCfg.matchTime2-1) * 86400 + oceanExpCfg.matchTime[2][1]*3600 + oceanExpCfg.matchTime[2][2]*60
    --         },
    --         {   
    --             st + (oceanExpCfg.matchTime3-1) * 86400 + oceanExpCfg.matchTime[1][1]*3600 + oceanExpCfg.matchTime[1][2]*60,
    --             st + (oceanExpCfg.matchTime3-1) * 86400 + oceanExpCfg.matchTime[2][1]*3600 + oceanExpCfg.matchTime[2][2]*60
    --         },
    --     }

    --     baseinfo[5] = {baseinfo[4][#baseinfo[4]][2] + 1800,st + (oceanExpCfg.rewardTime+1) * 86400}

    --     return baseinfo
    -- end
 
    --[[
       各阶段 判断
       stage0 -- 预热期
       stage1 -- 参赛报名/元帅选拔
       stage2 -- 队长选拔
       stage3 -- 队伍调整
       stage4 -- 比赛期
       stage5 -- 领奖期
    ]]

    function self.isstage0(ts,st,cfg,oceancfg)
        st = getWeeTs(st)
        local bst = st
        local bet = st + cfg.proTime * 86400
        
        if ts>=bst and ts<=bet then
            return true
        end
        return false
    end


    function self.isstage1(ts,st,cfg,oceancfg)
        st = getWeeTs(st)
        local bst = st + (cfg.marTime-1) * 86400
        local bet = st + cfg.marTime * 86400

        if ts>=bst and ts<=bet then
            return true
        end
        return false
    end

    function self.isstage2(ts,st,cfg,oceancfg)
        st = getWeeTs(st)
        local bst = st + (cfg.tlTime-1) * 86400
        local bet = st + cfg.tlTime * 86400
        if ts>=bst and ts<=bet then
            return true
        end
        return false
    end

    function self.isstage3(ts,st,cfg,oceancfg)
        st = getWeeTs(st)
        local bst = st + (cfg.tpTime-1) * 86400
        local bet = st + cfg.tpTime * 86400
        if ts>=bst and ts<=bet then
            return true
        end
        return false
    end

    -- 战斗期
    function self.isstage4(ts,st,cfg,oceancfg)

        local bdays = 0
        local sn = #oceancfg.servers
        if sn<=2 then
            bdays = 1
        elseif sn<=4 then
            bdays = 2
        else
            bdays = 3
        end
     
        st = getWeeTs(st)
        local bst = st + cfg.tpTime * 86400
        local bet = getWeeTs(bst + bdays*86400-1) + cfg.matchTime[1][1]*3600+cfg.matchTime[1][2]*60
        if ts>=bst and ts<=bet then
            return true
        end
        return false
    end

    -- 判断领奖期  商店
    function self.isstage5(ts,st,cfg,oceancfg)
        local bdays = 0
        local sn = #oceancfg.servers
        if sn<=2 then
            bdays = 1
        elseif sn<=4 then
            bdays = 2
        else
            bdays = 3
        end
        st = getWeeTs(st)
        local bst = st + (cfg.tpTime+bdays-1)*86400+cfg.matchTime[2][1]*3600+cfg.matchTime[2][2]*60
        local bet = tonumber(oceancfg.et)
        if ts>=bst and ts<=bet then
            return true
        end

        return false
    end

    -- 判断结算期  大战结束当前的11:25 到 11:35
    function self.isstage6(ts,st,cfg,oceancfg)
        local bdays = 0
        local sn = #oceancfg.servers
        if sn<=2 then
            bdays = 1
        elseif sn<=4 then
            bdays = 2
        else
            bdays = 3
        end
        st = getWeeTs(st)
        local bst = st + (cfg.tpTime+bdays-1)*86400+ 23*3600 +25*60
        local bet = bst + 10 * 60
        if ts>=bst and ts<=bet then
            return true
        end

        return false
    end


    -- 是否有竞选元帅或者队长资格
    function self.qualification(uid,st,ranklimit)
        self.ranksnap(st,self.et)
        local  redis = getRedis()
        local key = "z"..getZoneId()..".oceanexpedition.fcrank"..st
        local rank = redis:zrevrank(key,uid)

        if rank then
            rank = rank+1
        else
            rank = 0
        end

        if rank>0 and rank<=ranklimit then
           return true
        end

        return false
    end

    -- 设置增加士气的活动
    function self.setactive(st,bid)
        local ret = false
        local active = {}
        local proTime = getConfig("oceanExpedition.proTime")
        local matchTime1 = getConfig("oceanExpedition.matchTime1")
        local matchTime = getConfig("oceanExpedition.matchTime")
        if proTime==0 then
            active.st = st
        else
            active.st = st + 86400*proTime
        end
     
        active.et = st+ 86400*(matchTime1-1)
        active.name = 'oceanmorale'
        active.cfg = 1
        active.type = 1
        active.status = 1
        active.selfcfg = {bid=bid}

        require "model.active"
        local mActive = model_active()
        local actives = mActive.getActives(active.name)
     
        if type(actives)=='table' and next(actives) then
            local activeId = tonumber(actives[1].id)
            ret = mActive.setActive(tonumber(activeId),active)
        else
            ret = mActive.createActive(active)
        end

        return ret
    end

    -- 获取元帅数据 战力  昵称  头像框 挂件
    function self.getmarshal(bid)
        local db = getDbo()
        local result = db:getRow("select uid,fc,nickname from oceanexpedition where job=1 and tid=0 and bid= :bid",{bid=bid})
        local minfo = {}

        if type(result)=='table' and next(result) then
            local uid = tonumber(result.uid)
            local uobjs = getUserObjs(uid)
            uobjs.load({'userinfo'})
            local mUserinfo = uobjs.getModel('userinfo')

            minfo.nickname = result.nickname
            minfo.fc = result.fc
            minfo.pic = mUserinfo.pic
            minfo.bic = mUserinfo.bpic
            minfo.aic = mUserinfo.apic
            minfo.uid = mUserinfo.uid
        end

        return minfo
    end

    function self.getMatchDays(servers)
        if not servers then servers = self.servers end

        local sn = #servers
        local bdays = 0
        if sn<=2 then
            bdays = 1
        elseif sn<=4 then
            bdays = 2
        else
            bdays = 3
        end
        return bdays
    end

    function self.scheduleForClient()
        local schedule = self.schedule()

        if not schedule then
            return nil
        end

        -- local schedule = {
            -- {
            --     ["3"]=
            --     {
            --         -- {2,1},{6,2}
            --     },
            --     ["4"]={
            --         -- {4,2},{7,1}
            --         {4,1}
            --     },
            --     ["1"]={
            --         {1,2},{8,1}
            --     },
            --     ["2"]={
            --         {3,1},{5,2}
            --     }
            -- },

            -- {
            --  ["3"]=
            --  {
            --      {2},{6}
            --  },
            --  ["4"]={
            --      -- {4,2},{7,1}
            --      {4}
            --  },
            --  -- ["1"]={
            --  --  {1,2},{8,1}
            --  -- },
            --  ["2"]={
            --      {3},{5}
            --  }
            -- },

            -- {
            --  ["1"]={{3,1},{8,2}},
            --  ["2"]={{2,1},{7,2}}
            -- },
            -- {
            --  ["1"]={
            --      {2},{3}
            --  }
            -- }
        -- }

        local function len(dayInfo)
            local len = 0
            for k,v in pairs(dayInfo) do
                if tonumber(k) > len then
                    len = tonumber(k)
                end
            end
            return len
        end

        -- 客户端要求的格式
        local forClient = {}

        for day,dayInfo in pairs(schedule) do
            local n = len(dayInfo)
            local nextFlag=false
            local nextData = {}
            local roundData = {}

            roundData = {}

            local group,groupInfo
            local ins = {}
            for i=1,n do 
                group = tostring(i)
                groupInfo = dayInfo[group]

                ins[1] = i*2-1
                ins[2] = i*2

                roundData[ins[1]] = 0
                roundData[ins[2]] = 0

                if type(groupInfo) == "table" and next(groupInfo) then
                    for j=1,len(groupInfo) do
                        local zoneInfo = groupInfo[j]
                        roundData[ins[j]] = zoneInfo[1]

                        -- 下一轮数据
                        if zoneInfo[2] then
                            if zoneInfo[2] == consts.WIN then
                                table.insert(nextData,zoneInfo[1])
                            end
                            nextFlag = true
                        end
                    end
                else
                    table.insert(nextData,0)
                end
            end

            if not forClient[day] then
                forClient[day] = roundData
            end

            if nextFlag then
                forClient[day+1] = nextData
            end

        end

        return forClient
    end

    -- 判断玩家是否存在队伍当中
    function self.checkUidExists(uid,tid)
        if not self.info.teams or type(self.info.teams)~='table' then
            return false
        end

        if not self.info.teams[tid] or type(self.info.teams[tid])~='table' then
            return false
        end
       
        if table.contains(self.info.teams[tid][2] or {},uid) then
            return true
        end

        return false
    end

    return self
end

return model_oceanmatches