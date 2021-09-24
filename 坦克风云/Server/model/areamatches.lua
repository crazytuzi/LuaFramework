--
-- 跨服区域战时间数据
-- User: lmh
-- Date: 15-8-18
--

function model_areamatches()

    local self = {
        ranking={},
        --参赛用户信息
        userinfo={},
        base={},
        --战场信息
        battlelist={},
        errorCode = -1,

       
    }

    --得到比赛的场次信息
    --
    --return table
    self.getAllInfo = function()
         --根据sevbattleCfg计算比赛的id
        local matchinfo = self.getMatchInfo()
        if type(self.base)=='table'  and  not next(self.base) then
            
            require "model.serverbattle"
            local mServerbattle = model_serverbattle()
            --1 个人战
            --缓存跨服战的基本信息
            local mMatchinfo, code = mServerbattle.getserverareabattlecfg()
            --记录错误信息
            if code < 0 then
                self.errorCode = code
                self.clearCache()
            end
            self.base=mMatchinfo
            self.cacheinfo("base",self.base)
        end
        
    
        return true
    end




    --设置已经领取奖励标识
    --
    --params info
    --
    --return void
    self.cacheRewardResult = function()
        self.cacheinfo('base', self.base)
    end



    --清除缓存
    --
    --return boolean
    self.clearCache = function()
        local redisKey =self.getRedisKey()
        local redis = getRedis()
        --baseinfo 开战时间，押注时间等
        self.base={}
        self.ranking={}
        --参赛用户信息
        self.userinfo={}
        self.battlelist={}
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

        if self.base~=nil and self.base.et then
            --初始化信息
            if tonumber(self.base.et) < getClientTs() then
                self.base={}
                --比赛结束后排名信息{'fu.uid','fu.uid','fu.uid'}
                self.ranking={}
                --参赛用户信息
                self.userinfo={}
                self.battlelist={}
                return {}
            end
        end
        return data
    end


    -- 获取战场数据
    function self.getbattlestats(zid,aid,ref)
        local redis = getRedis()
        local keys  = "z" .. getZoneId() ..".serverArea.matchinfo.stats-"..self.base.bid
        local battlelist=json.decode(redis:get(keys))
        local myround=0
        local myaid=zid..'-'..aid
        local cross=nil
        local sevCfg = getConfig('serverAreaWarCfg')
        local st =tonumber(self.base.st)+sevCfg.signuptime*24*3600
        local ts = getClientTs()
        if ts<st then
            return {}
        end
        if type(battlelist)=='table' and next(battlelist) then
            if battlelist.ainfo[myaid]~=nil then
                myround=1
                cross=battlelist.ainfo[myaid]
            end
            if ref==1 then
                if tonumber(cross[2])> getWeeTs() then
                    return battlelist,myround,cross
                end
            else
                return battlelist,myround,cross
            end
        end

       
        local ts=getClientTs()
        local ret=self.fetchInfo('areateamwarserver.battlelist', {bid=self.base.bid,uid=uid})        
        if ret then
            if ret and ret.data.schedule then
                 -- 第一天结束时间
		 -- 2017/12/6 16:40 fix ,B组的开战时间往后挪了一个小时，所以再加一个3600
                local fents=st+sevCfg.startWarTime[1]*3600+3600+sevCfg.startWarTime[2]*60+sevCfg.maxBattleTime
                
                local sents = fents+86400
                local et=100
                if ts>st and ts<fents then
                    et=fents-ts
                end
                if ts>fents and ts<sents then
                    et=sents-ts
                    if type(ret.data.schedule[2])~='table' then
                        et=100
                    end
                end
                if ts>sents then
                    et=tonumber(self.base.et)-ts
                    if type(ret.data.schedule[2])~='table' then
                        et=100
                    end
                    if ret.data.over==nil then
                        et=100
                    end
                end
                
                if ret.data.ainfo[myaid]~=nil then
                    myround=1 
                    cross=ret.data.ainfo[myaid]
                    
                end

                if ts<fents then
                    for k,v in pairs (ret.data.ainfo) do
                        local info = k:split('-')
                        if tonumber(info[1])==tonumber(zid) then
                            self.sendAllianceMail(info[2],fents-sevCfg.maxBattleTime)
                        end
                    end

                end

                if tonumber(ret.data.over)==1 then
                    self.sendMsg(zid,ret.data.ainfo)
                end   
                redis:set(keys,json.encode(ret.data))
                redis:expire(keys,et)
      
                return ret.data,myround,cross
            end

        end

    end

 --获取个人的信息
    function self.getaMatchUserInfo(aid,zid,uid)
        local  info = self.fetchInfo('areateamwarserver.getuser',{bid=self.base.bid,uid=uid,zid=zid,aid=aid})
        return info
    end



    function self.sendAllianceMail(aid,st)
        local redis = getRedis()
        local keys  = "z" .. getZoneId() ..".serverArea.matchinfo.sendMail-"..self.base.bid.."aid-"..aid
        local ret=tonumber(redis:get(keys))
        if ret and ret>=1 then
            return true
        end
        local ret =redis:incr(keys)
        if ret==1 then
           local ret =  M_alliance.getalliance{alliancebattle=1,method=1,aid=aid}
           if  ret and  ret.data.members then
                for k,v in pairs(ret.data.members) do

                   local content = {type=42,st=st}
                    content = json.encode(content)
                    local muid = tonumber(v.uid)
                    local ret =MAIL:mailSent(muid,1,muid,'',ret.data.aName,42,content,1,0)
                end
            
            end
        end
        redis:expireat(keys,tonumber(self.base.et))
    end

    -- 存储第一名军团的信息到缓存(LED广播需要)
    function self.setFirstAllianceInfoToCache(allianceZid,allianceName)
        local winkey ="z" .. getZoneId() ..".areacross.winer"
        local redis = getRedis()
        redis:set(winkey,json.encode({allianceZid,allianceName}))
        local expireat = (tonumber(self.base.et) or 0)
        redis:expireat(winkey,expireat)
    end

    -- 发送公告
    function self.sendMsg(zid,schedule)
            
        if type(schedule)~='table' then
            return true
        end    
        local redis = getRedis()
        local keys  = "z" .. getZoneId() ..".serverArea.matchinfo.sendMsg-"..self.base.bid
        local ret=tonumber(redis:get(keys))
        if ret and ret>=1 then
            return true
        end
        local ret =redis:incr(keys)
        if ret==1 then
            local param={}
            for k,v in pairs (schedule) do
                local info = k:split('-')
                if tonumber(info[1])==tonumber(zid) then
                   local tmp={v[1],v[6],v[3]}
                   table.insert(param,tmp)
                   if tonumber(v[3])==1 then
                        -- 每日捷报设设置群雄争霸结果冠军的信息
                        local setRet,code=M_alliance.getalliancesname{aids=json.encode({tonumber(info[2])})}
                        if setRet then
                            local ninfo=setRet.data[1]
                            if type(ninfo)=="table" and next(ninfo) then
                                local newsdata={ninfo.name,ninfo.level,ninfo.commander,ninfo.fight,ninfo.amaxnum,ninfo.memberNum,ninfo.type,ninfo.level_limit,ninfo.fight_limit,ninfo.notice,tonumber(info[2])}
                                local news={title="d25",content={
                                    allianceinfo={
                                        newsdata
                                    }
                                }}
                                setDayNews(news)
                            end
                        end
                    end
                end

                if tonumber(v[3])==1 then
                    self.setFirstAllianceInfoToCache(info[1],v[1])
                end
            end
            if next(param) then    
                local  msg = {
                        sender=0,
                        reciver=0,
                        channel=1,            
                        sendername="",
                        recivername="",
                        type="chat",
                        content={
                            isSystem=1,
                            params=param,    
                            ts=ts,
                            contentType=4,
                            subType=4,
                            type=27,
                        },
                }
                sendMessage(msg)
            end
        end
        redis:expireat(keys,tonumber(self.base.et))
    end


    self.fetchInfo = function(cmd, params)

        local data={cmd=cmd,params=params }
        local config = getConfig("config.areacrossserver.connect")
        local ret = {data={}}
        for i=1,1 do
            ret=sendGameserver(config.host,config.port,data)
            --ret=json.decode('{"ts":1446530569,"zoneid":1,"uid":1000001,"ret":0,"rnum":2,"cmd":"areawarserver.battlelist","msg":"Success","data":{"ainfo":{"3-32":["3chhhhh2","1438689696"],"3-42":["4Zxxnm2","0"],"3-41":["4Zxxnm1","0"],"3-31":["3chhhhh1","1438689696"],"1-11":["1Aaaaa1","1438690062"],"3-21":["2dyy1","1438689204"],"3-22":["2dyy2","1438689204"],"3-12":["1Aaaaa2","1438690062"]},"schedule":[{"b":["3-32","3-31","3-12","1-11"],"a":["3-42","3-41","3-22","3-21"]},{"b":["3-31","3-32","3-41","3-42"],"a":["1-11","3-12","3-21","3-22"]}]}}')
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


   

    --缓存key
    --
    --return string
    self.getRedisKey = function()
        local matchKey = "z" .. getZoneId() ..".serverArea.matchinfo"
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
        if self.base~=nil and   self.base.et  then
            redis:expireat(matchKey,tonumber(self.base.et))
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
    

    --验证用户是否参赛
    --
    --params string uid
    --
    --return boolean
    self.checkJoinUser = function(uid)
        local zid=getZoneId()
        local limit=tonumber(getConfig("platWarCfg.joinLimit"))
        local plat=getClientPlat()
        if type(self.userinfo)=='table' and next(self.userinfo) then
            for k,v in pairs (self.userinfo[plat]) do
                local uzid=tonumber(v.z)
                local zuid =tonumber(v.u)
                if tonumber(k)>limit then
                    break
                end
                if uzid==zid and zuid==uid then
                    return rank
                end
            end
        end
        return false
    end
   
    --初始化跨服战信息
    self.getAllInfo()

  




    return self
end


