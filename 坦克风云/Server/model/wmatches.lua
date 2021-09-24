--
-- 世界大战开战时间数据
-- User: lmh
-- Date: 15-3-25
-- Time: 下午4:38
--

function model_wmatches()

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
        -- 淘汰赛的地形
        landform={},
        --错误码
        errorCode = -1,
        --修复数据flag
        repairFlag = false
    }

    --得到比赛的场次信息
    --
    --return table
    self.getAllInfo = function()
         --根据sevbattleCfg计算比赛的id
        require "model.serverbattle"
        local mServerbattle = model_serverbattle()
        --1 个人战
        --缓存跨服战的基本信息
        local mMatchinfo, code = mServerbattle.getWorldWarBattleInfo()
        --记录错误信息
        if code < 0 then
            self.errorCode = code
            self.clearCache()
        end
        local matchinfo = self.getMatchInfo()
        if not next(self.base) then
            self.base=mMatchinfo
            self.base.matchId=mMatchinfo.bid
        end
        --缓存有数据
        if not next(matchinfo) then
          return {}
        end
        
         --三天积分后取赛程信息
        return true
    end

    --检查是否发送全服邮件
    --
    --return void
    self.checkAllUser = function(jointype)
        self.base.reward =self.base.reward or {}
        local reward=self.base.reward[self.base.matchId] or {}
        local p="p"..jointype
        if reward[p] then
            return true
        end
        local cfg = getConfig('worldWarCfg')
        local getTime = self.getEliminateCurrentRoundEt(6)+cfg.battleTime*3
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
    self.cacheRewardResult = function()
        self.cacheinfo('base', self.base)
    end

    --全服发邮件
    --
    --return boolean
    self.getAllUserReward = function(jointype,zoneid)
        local redis = getRedis()
        local key="z" .. zoneid ..".worldwar.sendRank."..jointype.."bid"..self.base.bid
        local winkey="z" .. zoneid ..".worldwar.winer."..jointype
        local ret =redis:incr(key)
        -- 防止缓存丢失, 记录到数据库
        local freekey = "worldwar.sendRank"
        local freedata = {}
        if ret == 1 then
            freedata = getFreeData(freekey)
            if type(freedata) == 'table' then
                freedata = freedata.info
            else
                freedata = {}
            end
            if not freedata[tostring(self.base.bid)] then
                freedata = {[tostring(self.base.bid)] = {} } --只记录本次的标记
            end
            local reflag = tonumber(freedata[self.base.bid][key]) or 0
            if reflag == 1 then
                writeLog({ 'getAllUserReward err, redis nil but mysql had flag', key=key, }, 'error')
                return false    
            end
            freedata[self.base.bid][key]=1
        end
        if ret==1 then
            local set=false
            local  config = getConfig('worldWarCfg')
            local  cfg    = config["rankReward"..jointype]
            if self.userinfo[jointype] then
                if jointype==2 then
                    self.addnews(zoneid)
                end
                for k,v in pairs(self.userinfo[jointype]) do
                    local zid =tonumber(v[1])
                    local rank=tonumber(v[8]) or 0
                    if rank==1 and  jointype ==1 then
                        local ret=redis:set(winkey,json.encode(v))
                        redis:expireat(winkey,tonumber(self.base.et)+96*3600)
                    end
                    if zid ==zoneid then
                        local uid =tonumber(v[2])
                        if rank>0 then
                            local point =0
                            for rk,rv in pairs(cfg) do
                                if rank>=rv["range"][1] and rank<=rv["range"][2] then
                                    point=rv["point"]
                                    break
                                end
                            end
                            if point>0 then
                                local content = json.encode({jointype=jointype,ranking=rank})
                                local ret = MAIL:mailSent(uid,0,uid,'','','',content,1,0,3,point)
                                if not ret then
                                    writeLog({'wcross send mail fail ...', 
                                        uid=uid, content=content, point=point}, 'wcross')
                                end
                                if ret and not set then
                                    set=true
                                end
                            end
                        end
                    end
                end
            else
                redis:del(key)  
            end

            if set then
                self.base.reward =self.base.reward or {}
                self.base.reward[self.base.matchId] =self.base.reward[self.base.matchId] or {}
                self.base.reward[self.base.matchId]["p"..jointype]=1
                self.cacheRewardResult()
                redis:expireat(key,tonumber(self.base.et))
                setFreeData(freekey, freedata )
            -- else
            --     redis:del(key)
            end
            
        end
    end

    --每日捷报 发送：世界争霸结果
    function self.addnews(zoneid)
        local newsdata={}
        local send=false
        local names={}
        for k,v in pairs (self.userinfo) do
            for uk,uv in pairs (v) do
                local zid =tonumber(uv[1])
                local rank=tonumber(uv[8]) or 0
                local uid =tonumber(uv[2])
                if rank==1 then
                    if zid ==zoneid  then
                        send=true
                        local uobjs = getUserObjs(uid)
                        local mUserinfo = uobjs.getModel('userinfo')
                        local tmp={mUserinfo.pic,mUserinfo.nickname,mUserinfo.level,mUserinfo.fc,mUserinfo.alliancename,uid,mUserinfo.bpic,mUserinfo.apic}
                        table.insert(newsdata,tmp)
                        table.insert(names,mUserinfo.nickname)
                    else -- 不是一个服的要拿0占位
                        table.insert(newsdata,0)
                        table.insert(names,0)
                        
                    end
                    break
                end
            end
            
        end

        if send then
            local news={title="d22",content={
                    userinfo=newsdata,
                    username=names,
                }}
                setDayNews(news)
        end
        
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
        -- 淘汰赛的地形
        self.landform={}
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
            if tonumber(self.base.et) < getClientTs() then
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
                -- 淘汰赛的地形
                self.landform={}
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

--获取积分赛当前的轮次
function self.getPointCurrentRound(st,time)
    local ts = getClientTs()
    local battleTs = self.getBattleRoundTs (st,time)
    local currentRound = 0
    for k,v in ipairs(battleTs[1]) do
        if ts >= v[2] then 
            currentRound = k
        else
            break
        end
    end

    return currentRound
end
-- 获取积分赛最大轮数
function self.getPointBattleMaxRound()
    local config = getConfig('worldWarCfg')
    return config.pmatchdays * (config.pmatchendtime1[1] - config.pmatchstarttime1[1]) * 4
end

-- 积分and淘汰的规则    
function self.getBattleRoundTs(st,time)
    -- ptb:p(os.date('%Y%m%d %X',st))
    local pRoundTsInfo = {}
    local time =time or 300
    local config = getConfig('worldWarCfg')
    local dailyStCfg = config.pmatchstarttime1
    local dailyEtCfg = config.pmatchendtime1

    local dailySt = dailyStCfg[1] * 3600 + dailyStCfg[2] * 60
    local dailyEt = dailyEtCfg[1] * 3600 + dailyEtCfg[2] * 60 
    local st=st+config.signuptime*24*3600
    local battleStWeets = getWeeTs(st)
    local dayRoundNum = math.floor( (dailyEt - dailySt) / config.breaktime)

    for i=1,config.pmatchdays do
        local dayTs = (i-1)*24*3600
        for j=1,dayRoundNum do
            -- 这里减300是把开始时间往前提前了300秒
            local tmpDayRoundSt = battleStWeets + dailySt + dayTs + config.breaktime * (j-1)-time
            table.insert(pRoundTsInfo,{tmpDayRoundSt,tmpDayRoundSt+config.breaktime})
            -- table.insert(pRoundTsInfo,{os.date('%Y%m%d %X',tmpDayRoundSt),os.date('%Y%m%d %X',tmpDayRoundSt+config.breaktime-60)})
        end
    end

    local tRoundTsInfo = {}

    -- 淘汰赛起始当天的凌晨时间戳
    local tBattleStWeets = battleStWeets + config.pmatchdays * 24 * 3600
    local tDailySt1 = config.tmatch1starttime1[1] * 3600 + config.tmatch1starttime1[2] * 60
    local tDailySt2 = config.tmatch2starttime1[1] * 3600 + config.tmatch2starttime1[2] * 60 
    for i=1,3 do
        local dayTs = (i-1) * 24 * 3600
        table.insert(tRoundTsInfo,tBattleStWeets+dayTs+tDailySt1)
        table.insert(tRoundTsInfo,tBattleStWeets+dayTs+tDailySt2)
    end

    return {pRoundTsInfo,tRoundTsInfo}
end


-- 淘汰赛当前轮次
function self.getEliminateCurrentRound(st)
    local ts = getClientTs()
    st =tonumber(self.base.st)
    local battleTs = self.getBattleRoundTs (st,0)
    local currentRound = 0
    for k,v in ipairs(battleTs[2]) do
        -- print(os.date('%Y%m%d %X',ts),os.date('%Y%m%d %X',v),k)
        if ts >= v then 
            currentRound = k
        else
            break
        end
    end

    return currentRound
end


function self.getEliminateCurrentRoundEt(round)

    local ts = getClientTs()
    st =tonumber(self.base.st)
    local battleTs = self.getBattleRoundTs (st,0)
     for k,v in ipairs(battleTs[2]) do
        -- print(os.date('%Y%m%d %X',ts),os.date('%Y%m%d %X',v),k)
       if k==round then
            return v
       end
    end

    return ts
end




-- 拉去个人的数据
function self.getUserPoingInfo(uid,round,zid,jointype)
    local point=0
    local pointround =self.getPointCurrentRound(tonumber(self.base.st),0)
    local userinfo ={}
    if pointround> round   then
        local userinfodata = self.fetchInfo('worldserver.getuser', {bid=self.base.bid,uid=uid,zid=zid,jointype=jointype,round=pointround})
        if not userinfodata then
            return {}, round
        end
        userinfo=userinfodata.data.userinfo
        if  userinfo.pointlog~=nil and  userinfo.pointlog~='' then
            local log =userinfo.pointlog:split(',') 
            local len=#log
            if len>pointround then
                for i=len,pointround+1,-1 do
                    local delpoint=tonumber(log[i])
                    userinfo.point=tonumber(userinfo.point)-delpoint
                end
            end
            if len<pointround then
                pointround=round
            end
        end
        
        local ret=self.cacheinfo(uid..'myuserinfo'..jointype, userinfo)
    else
        if round>0 then
            userinfo =json.decode(self.cacheget(uid..'myuserinfo'..jointype))
            if userinfo==nil or not next(userinfo) then
                local userinfodata = self.fetchInfo('worldserver.getuser', {bid=self.base.bid,uid=uid,zid=zid,jointype=jointype,round=pointround})
                if not userinfodata then
                    return {}, pointround
                end
                userinfo=userinfodata.data.userinfo
                local ret=self.cacheinfo(uid..'myuserinfo'..jointype, userinfo)
            end
        end
        
    end 
    return userinfo,pointround
end

    -- 淘汰赛期间发邮件提醒设兵
    function self.checkEliminateTroops(uid, params)
        local eliminateTroopsKey = "z"..getZoneId()..".worldwar.eliminateMailFlag"
        local redis = getRedis()
        local mailflag = redis:hget(eliminateTroopsKey, uid)
        if not mailflag then
            -- 世界争霸邮件 type=100 淘汰赛提醒设兵
            local content = json.encode({type=100, ranking=params.ranking, jointype=params.jointype})
            local ret = MAIL:mailSent(uid, 1, uid, '', '', 100, content, 1)
            if ret then
                redis:hset(eliminateTroopsKey, uid, 1)
                redis:expireat(eliminateTroopsKey, params.et)
                return true
            end
        end

        return false
    end

    --格式化信息
    --
    --return table
    self.getMultInfo = function(jointype)
        local pointround =self.getPointCurrentRound(tonumber(self.base.st),0)
        local maxpointround =self.getPointBattleMaxRound(tonumber(self.base.st),0)
        -- 拉个人的数据
        local ts=getClientTs()
        local sevCfg = getConfig('worldWarCfg')
        local endts=tonumber(self.base.st)+sevCfg.signuptime*24*3600+sevCfg.pmatchdays*24*3600
        endts=endts-(24*3600-(sevCfg["pmatchendtime"..jointype][1]*3600+sevCfg["pmatchendtime"..jointype][2]*3600))
        if maxpointround>pointround and ts<endts then
            return true 
        else -- 拉对阵列表
            local nowTime = getClientTs()
            local eround  =self.getEliminateCurrentRound(tonumber(self.base.st),0)
            local matchinfo =json.decode(self.cacheget('battlelist'..jointype))
            if matchinfo==nil or not next(matchinfo)  or matchinfo.round<eround  then
                local matchinfodata = self.fetchInfo('worldserver.battlelist',{bid=self.base.bid,jointype=jointype,round=eround})
                if not matchinfodata then
                    return {}
                end 
                if matchinfodata.data.round~=nil and tonumber(matchinfodata.data.round)>0 then
                    if matchinfodata.data.round>eround then
                        local setdata=matchinfodata.data
                        setdata.round=eround
                        local ret =self.cacheinfo('battlelist'..jointype,setdata)
                        matchinfo=setdata
                    end
                end
            end 
            if type(self.battleList[jointype])~="table" then self.battleList[jointype]={}  end
            if type(self.userinfo[jointype])~="table" then self.userinfo[jointype]={}  end
            if type(self.landform[jointype])~="table" then self.landform[jointype]={}  end
            if  matchinfo~=nil and next(matchinfo)  then
                self.battleList[jointype] =matchinfo.schedule
                self.userinfo[jointype]   =matchinfo.info
                self.landform[jointype]   =matchinfo.landform
            end
        end
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
        local config = getConfig("config.z"..getZoneId()..".worldwar")
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
    self.getCrossInfo = function(jointype)
        local serverinfo = self.fetchInfo('worldserver.battlelist', {bid=self.base.matchId,jointype=jointype})
        if not serverinfo then
            return {}, {}
        end
        local crossinfo = {}
        local userinfo = {}
        local cacheFlag = true
        --if type(serverinfo.data.repair) == 'table' and next(serverinfo.data.repair) then
           -- cacheFlag = false
            --if table.contains(serverinfo.data.repair, getZoneId()) then
                --self.repairFlag = true
            --end
        --end
        if serverinfo.data.d then
            userinfo = serverinfo.data.d
            if type(userinfo) ~= 'table' or not next(userinfo) then
                writeLog("get userinfo failed bid " .. self.base.matchId, "worldwar")
            end
            --缓存数据
            if cacheFlag and type(userinfo) == 'table' then
                self.cacheinfo('userinfo'..jointype, userinfo)
            end
        end
        if serverinfo.data.l then
            crossinfo = serverinfo.data.l
            if type(crossinfo) ~= 'table' or not next(crossinfo) then
                writeLog("get battleList failed bid " .. self.base.matchId, "worldwar")
            end
            --缓存数据
            if cacheFlag and type(crossinfo) == 'table' then
                self.cacheinfo('battleList'..jointype, crossinfo)
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
        local matchKey = "z" .. getZoneId() ..".worldwar.matchinfo"
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
        local ret=redis:hset(matchKey, item, json.encode(info))
        if self.base.et  then
            redis:expireat(matchKey, tonumber(self.base.et))
        end
        return true
    end

    -- 获取缓存数据
    function self.cacheget(item)

        local matchKey = self.getRedisKey()
        local redis = getRedis()
        local data =redis:hget(matchKey,item)
        return data
    end
    -- 获取自己是否参赛
    function self.getMyRoundTmatch(uid,zid,jointype)
        local tmatch=0
        local round=self.getEliminateCurrentRound(tonumber(self.base.st),0)
        if round==0 then
            round=1
        end
        local List =self.battleList[jointype] or {}
        for i=round-1,round do
            if  List[i] then
                for k,v in pairs(List[i]) do
                    if (v[1]==uid.."-"..zid or v[2]==uid.."-"..zid ) then
                        tmatch=i
                    end
                end

            end
        end

        return tmatch
    end
    --验证比赛是否在进行中
    --
    --params string matchId
    --
    --return boolean
    self.isMatch = function(matchId)

        if matchId ~= self.base.matchId then
            self.errorCode = -22007
            return false
        end
        return true
    end

    --验证用户是否参赛
    --
    --params string uid
    --
    --return boolean
    self.checkJoinUser = function(uid,jointype)
        local userinfo =self.userinfo[jointype] or {}
        for _,tmpUid in pairs(userinfo) do
            if tonumber(tmpUid[2])==uid or tonumber(tmpUid[3])==uid  then
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
    self.checkJoinUserByDid = function(uid, dId,jointype)

        local dIdTable = dId:split('_')
        for i, v in pairs(dIdTable) do
            dIdTable[i] = tonumber(v) or v
        end
      
        local eround =self.getEliminateCurrentRound(tonumber(self.base.st),0)

        if  dIdTable[2] <= eround then
            self.errorCode = -22007
            return false
        end

        if not self.battleList[jointype][dIdTable[2]] 
            or not self.battleList[jointype][dIdTable[2]][dIdTable[3]]
            
        then
            self.errorCode = -22008
            return false
        end

        if uid ~= self.battleList[jointype][dIdTable[2]][dIdTable[3]][1]
                and uid ~= self.battleList[jointype][dIdTable[2]][dIdTable[3]][2] then
            self.errorCode =-22009
            return false
        end
        return true
    end

    --是否可以押注
    --
    --params string dId bid_round_type_smallRound_otype_aid
    --
    --return boolean
    self.allowBet = function(dId,jointype)

        local dIdTable = dId:split('_')
        for i, v in pairs(dIdTable) do
            dIdTable[i] = tonumber(v) or v
        end
        local eround =self.getEliminateCurrentRound(tonumber(self.base.st),0)
        if self.createMatchId(dIdTable[1], dIdTable[2]) ~= self.base.matchId.."_"..eround  then
            self.errorCode = -22007
            return true
        end

        if not self.battleList[jointype][dIdTable[2]] 
            or not self.battleList[jointype][dIdTable[2]][dIdTable[3]]
        then
            self.errorCode = -22008
            return false
        end
        --比赛已经有结果
        --ptb:e(self.battleList[jointype][dIdTable[2]][dIdTable[3]][3])
        if self.battleList[jointype][dIdTable[2]][dIdTable[3]][3] then
            self.errorCode = -22010
            return false
        end

        return true
    end


    function self.getjoincount(zoneid,jointype,start)
        local redis = getRedis()
        local key="z" .. zoneid ..".worldwar.joinmember."..jointype
        local count=0
        local ts = getClientTs()
        count =redis:get(key)
        local exptime=tonumber(self.base.et)
        if count==nil then
            count=0
            local appdata=self.fetchInfo('worldserver.applynum',{bid=self.base.bid,jointype=jointype})
            if appdata then
                count=tonumber(appdata.data.applynum)
                if ts<=start then
                    exptime=ts+1800
                    if exptime>start then
                        exptime=start
                    end
                end
                redis:set(key,count)
                redis:expireat(key,exptime)
            end
        end

        return count
        
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
            self.errorCode = -22008
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
    self.isWinMatch = function(uid, dId,jointype)

        local dIdTable = dId:split('_')
        for i, v in pairs(dIdTable) do
            dIdTable[i] = tonumber(v) or v
        end
        if not self.battleList[jointype][dIdTable[2]]
            or not self.battleList[jointype][dIdTable[2]][dIdTable[3]]
        then
            return false
        end

        if self.battleList[jointype][dIdTable[2]][dIdTable[3]][3]
                and uid == self.battleList[jointype][dIdTable[2]][dIdTable[3]][3] then
            return true
        end
        
        return false
    end

    --增加参赛用户积分 bid_round_type_smallRound_otype_aid
    self.addJoinUserPoint = function(uid, dIds,jointype)

        local point = 0
        local joinUid = self.createJoinUserId(uid)
        local nowTime = getClientTs()
        if not self.checkJoinUser(uid,jointype) then
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
        local cfg = getConfig('worldWarCfg')
        local pCfg = cfg['tmatchPoint'..jointype]
        local tmpAddDid = {}
        for mtype,v1 in pairs(self.battleList[jointype]) do
            for round, v2 in pairs(v1) do
                local v4=v2[4] or {}
                local tmpDid = self.base.matchId ..'_'..mtype..'_'..round
                local roundEt=self.getEliminateCurrentRoundEt(tonumber(mtype))
                if not next(v4)  then
                    if nowTime >=tonumber(roundEt) and isGet(tmpDid, dIds) and (v2[1]==joinUid or v2[2]==joinUid) then
                        point = point+pCfg[3]*3
                        table.insert(dIds, tmpDid)
                        table.insert(tmpAddDid, {pCfg[3]*3, 1, tmpDid, roundEt, 1})
                    end
                else
                    if isGet(tmpDid, dIds) and nowTime >=tonumber(roundEt)  and (v2[1]==joinUid or v2[2]==joinUid) then
                        local akcount=0
                        local win=0
                        for ak,auid  in pairs(v4) do
                            if auid==joinUid then
                                akcount=akcount+1
                            end
                        end
                        local reward =pCfg[akcount]
                        point = point + reward
                        if akcount>=2 then
                            win=1
                        end
                        table.insert(dIds, tmpDid)
                        table.insert(tmpAddDid, {reward, 1, tmpDid, roundEt, win})
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
        local info = self.fetchInfo('worldserver.get', {bid=self.base.matchId,info={"ranking", "point", "zid"}})
        if not info then
            self.errorCode = -20016
            return false
        end
        if info.data and info.data.d and next(info.data.d) then
              if not checkranking(info.data.d) then
                   writeLog("get ranking failed", "worldwar")
                   self.errorCode = -20016
                   return false
              end
              self.ranking = info.data.d
              self.cacheinfo('ranking', info.data.d)
              return true
        end
        writeLog("get ranking failed", "worldwar")
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

    --得到录像信息
    --
    --return table 
    self.getReportInfo = function(params) 
        --{"bid":"1-4-b","round":2,"group":2,"pos":"d","inning":1}
        --params = json.decode('{"round":0,"group":1,"inning":1,"bid":"22","pos":"d"}')
        local index = {"bid","matchType","round", "pos", "inning"}
        local reportRedisKey =  "z" .. getZoneId() ..".worldwar.reportinfo"
        local key = ''
        for i,v in pairs(index) do
             key = key .. params[v]
        end
        local redis = getRedis()
        local info = redis:hget(reportRedisKey,key)
        if info then
              return json.decode(info)
        end
        local info = self.fetchInfo('worldserver.report', params)
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
        writeLog("get report failed " .. json.encode(params), "worldwar")
        return {}
    end

    --生成跨服uid
    --
    --params uid
    --
    --return string
    self.createJoinUserId = function(uid)
        return uid .. '-' .. getZoneId()
    end

    --初始化跨服战信息
    self.getAllInfo(jointype)

    -- 拉去个人积分赛的数据
    function self.getusepoint(uid)
        local serverinfo = self.fetchInfo('worldserver.getuser', {bid=self.base.matchId})
        if not serverinfo then
            return {}, {}
        end
    end




    return self
end

