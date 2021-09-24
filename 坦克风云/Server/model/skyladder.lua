function model_skyladder()
    local self = {
        base={}, -- 天梯赛季信息
        group={}, -- 分组信息
        ranking={}, -- 排行榜
        over={}, -- 结算
        errorCode = -1,
    }
    
    function self.getBase()
        if type(self.base)=='table' and not next(self.base) then
            local ts = getClientTs()
            local redis = getRedis()
            local list={}
            local keys  = "z"..getZoneId()..".skyladder.base"
            local base = json.decode(self.cacheget(keys,'status'))
            
            if type(base)=='table' and next(base) then
                -- print('getBase cache')
            else
                -- {"secret":"0d734a1dc94fe5a914185f45197ea846","zoneid":1,"params":{},"cmd":"skyladderserver.getstatus"}
                local ret=self.fetchInfo('skyladderserver.getstatus',{})
                if ret then
                    if ret.data.base then
                        --local nextTime = getWeeTs(ts + 86400)
                        --redis:set(keys,json.encode(ret.data.base))
                        --redis:expire(keys,nextTime-ts)
                        --redis:expire(keys,300)
                        
                        self.cacheinfo(keys,'status',json.encode(ret.data.base))
                        -- print('getBase db')
                        base = ret.data.base
                    end
                end
            end
            
            if base and type(base) == 'table' then
                for i,v in pairs(base) do
                    self.base[i] = v
                end
            end
        end
        
        if type(self.base)~='table' or not next(self.base) then
            self.base={
            cubid = 0, -- 当前的赛季id
            lsbid = 0, -- 上一次结束的赛季id
            status = 0, -- 开关状态
            season = 0,
            over = 0, -- 是否已结算
            overtime = 0, -- 结算的时间点
        }
        end
        
        return self.base
    end

    --获取赛事分组对阵情况
    function self.getGroup(cubid,gkey)
        local redis = getRedis()
        local list={}
        local keys  = "z"..getZoneId()..".skyladder.b"..cubid..".group."..gkey
        local group=json.decode(redis:get(keys))

        if type(group)=='table' and next(group) then
            -- print('getGroup cache')
            return group
        end

        -- {"secret":"0d734a1dc94fe5a914185f45197ea846","zoneid":1,"params":{"cubid":1,"gkey":5},"cmd":"skyladderserver.setgroup"}
        local ret=self.fetchInfo('skyladderserver.getgroup',{cubid=cubid,gkey=gkey})
        if ret then
            if ret.data.group then
                redis:set(keys,json.encode(ret.data.group))
                redis:expire(keys,300)
                -- print('getGroup db')
                return ret.data.group
            end
        end
    end

    --获取战报
    function self.getLog(action,id,up)
        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local redis = getRedis()
        local base = self.getBase()
        local list={}
        local keys  = "z"..getZoneId()..".skyladder.b"..base.cubid..".log."..action.."."..weeTs
        local allLog = json.decode(self.cacheget(keys,id))

        -- local refTimeKey = "z"..getZoneId()..".skyladder.reftime."..id
        -- local refTime = redis:get(refTimeKey) or 0
        -- if weeTs > refTime and ts < weeTs + 3600*18 then
            -- up = 1
            -- redis:set(refTimeKey,ts)
        -- end
        
        if not up and type(allLog)=='table' and next(allLog) then
            -- print('getLog cache')
            return allLog
        end

        -- {"secret":"0d734a1dc94fe5a914185f45197ea846","zoneid":1,"params":{"cubid":1,"gkey":5},"cmd":"skyladderserver.setgroup"}
        local ret=self.fetchInfo('skyladderserver.getlog',{action=action,zid=getZoneId(),id=id})
        if ret then
            if ret.data.allLog then
                -- ptb:p(ret.data.allLog)
                -- redis:set(keys,json.encode(ret.data.allLog))
                -- redis:expire(keys,300)
                -- local nextTime = getWeeTs(ts + 86400)
                -- redis:expire(keys,nextTime-ts+10)
                -- redis:set(refTimeKey,ts)
                -- redis:expire(refTimeKey,300)
                
                self.cacheinfo(keys,id,json.encode(ret.data.allLog))
                
                -- print('getLog db')
                return ret.data.allLog
            end
        end
    end

    -- 获取排行榜
    function self.getRankInfo(action,page)
        -- body
        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local redis = getRedis()
        local list={}
        local base = self.getBase()
        local keys  = "z" .. getZoneId() ..".skyladder.b"..base.cubid..".rank."..weeTs
        local ranklist = json.decode(self.cacheget(keys,action))

        -- local refTimeKey = "z"..getZoneId()..".skyladder.reftime."..id
        -- local refTime = redis:get(refTimeKey) or 0
        -- if weeTs > refTime and ts < weeTs + 3600*18 then
            -- up = 1
            -- redis:set(refTimeKey,ts)
        -- end
        
        if type(ranklist)=='table' and next(ranklist) then
            -- print('getRank cache') 
            return ranklist
        end

        local ret=self.fetchInfo('skyladderserver.getrank', {action=action})

        if ret then
            if ret.data.rankList then
                --redis:set(keys,json.encode(ret.data.rankList))
                --redis:expire(keys,300)
                --local nextTime = getWeeTs(ts + 86400)
                --redis:expire(keys,nextTime-ts+10)
                
                self.cacheinfo(keys,action,json.encode(ret.data.rankList))
                -- print('getRank db')
                return ret.data.rankList
            end

        end
    end

    -- 获取个人排名
    function self.getMyRank(action,id,up)
        -- body
        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local redis = getRedis()
        local list={}
        local base = self.getBase()
        local keys  = "z" .. getZoneId() ..".skyladder.b"..base.cubid..".myrank."..action.."."..weeTs
        local myrank = json.decode(self.cacheget(keys,id))
        
        if type(myrank)=='table' and next(myrank) and not up then
            -- print('getMyRank cache') 
            return myrank.m,myrank.d,myrank.s
        end

        local ret=self.fetchInfo('skyladderserver.getmyrank', {action=action,zid=getZoneId(),id=id})

        if ret then
            if ret.data.myrank then
                -- redis:set(keys,json.encode({m=ret.data.myrank,d=ret.data.detail,s=ret.data.score}))
                -- local nextTime = getWeeTs(ts + 86400)
                -- redis:expire(keys,nextTime-ts+10)
                
                self.cacheinfo(keys,id,json.encode({m=ret.data.myrank,d=ret.data.detail,s=ret.data.score}))
                
                -- print('getMyRank db') 
                return ret.data.myrank,ret.data.detail,ret.data.score
            end
        end
    end
    
    -- 结算个人奖励
    function self.getOverPersonReward(uid)
        local cfg = getConfig("skyladderCfg")
        local status = false
        local myrank = 0
        local base = self.getBase()
        local person=self.fetchInfo('skyladderserver.getmyrank', {action=1,zid=getZoneId(),id=uid})

        if person then
            if person.data.myrank then
                local plat = getClientPlat()
                myrank = tonumber(person.data.myrank) or 0
                -- 没有排名直接标记成功
                if myrank <= 0 then
                    return true,0
                end
                
                local rversion = cfg.personRewardMapping[plat] and cfg.personRewardMapping[plat] or cfg.personRewardMapping.default
                local rewardList = cfg.personRankReward[rversion]

                for i,v in pairs(rewardList) do
                    if myrank >= v.range[1] and myrank <= v.range[2] then
                        status = sendToRewardCenter(uid,'sky','person',base.cubid,nil,{r=myrank},v.serverreward)
                        break
                    end
                end
            end
        end
        
        return status,myrank
    end
    
    -- 结算军团奖励
    function self.getOverAllianceReward(aid)
        local cfg = getConfig("skyladderCfg")
        local status = false
        local myrank = 0
        local base = self.getBase()
        local alliance=self.fetchInfo('skyladderserver.getmyrank', {action=2,zid=getZoneId(),id=aid})

        if alliance then
            if alliance.data.myrank then
                myrank = tonumber(alliance.data.myrank) or 0
                if myrank <= 0 then
                    return true,0
                end
            end

            if myrank > 0 then
                -- 拉取军团成员 发奖
                local ret=self.fetchInfo('skyladderserver.getmemlist', {zid=getZoneId(),id=aid})
                -- print('myrank',myrank)
                -- print('ret')
                -- ptb:p(ret)
                if ret then
                    local memList = ret.data.memList or {}
                    -- print('memList',memList)
                    for i,v in pairs(cfg.allianceRankReward) do
                        if myrank >= v.range[1] and myrank <= v.range[2] then
                            for uid,_ in pairs(memList) do
                                -- print('uid',uid)
                                status = sendToRewardCenter(uid,'sky','alliance',base.cubid,nil,{r=myrank},v.serverreward)
                                status =true
                            end
                            break
                        end
                    end
                end
            end
        end
        
        return status,myrank
    end
    
    -- 拉取名人堂
    function self.getHistory()
        local redis = getRedis()
        local keys  = "z"..getZoneId()..".skyladder.hid"
        local cuhid = redis:get(keys) or 0
        local id = cuhid

        local ret = self.fetchInfo('skyladderserver.gethistory', {id=id})

        if ret then
            if ret.data.history then
                local hid =self.insertHistory(ret.data.history)
                if hid then
                    id = hid
                end
            end
        end

        if tonumber(id) >tonumber(cuhid) then
            redis:set(keys,id)
        end
    end
    
    -- 插入名人堂
    function self.insertHistory(data)
        if type(data)~='table' or not next(data) then
            return false
        end
        local db = getDbo()
        local id=0
        for k,logs in pairs (data) do
            local lid=tonumber(logs.id)
            if lid>id then
                id=lid
            end
            local ret = db:insert('skyladder_historydata',logs)
        end

        return id
    end
    
    function self.getAllHistory(start,num)
        local list
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local db = getDbo()
        local redis = getRedis()
        local page_rows = 20
        local bid =self.base.bid
        local count=nil
        local keys  = "z"..getZoneId()..".skyladder.htime"
        local htime = tonumber(redis:get(keys)) or 0

        if htime ~= weeTs then
            self.getHistory()
            redis:set(keys,weeTs)
            redis:expire(keys,86400)
        end

        local result=db:getRow("select count(id) AS count from skyladder_historydata")
        if result then
            if result.count ~=nil then
                count=result.count
            end
        end
        
        local start = start or 0
        maxeid = maxeid or page_rows
        mineid = mineid or 0
        
        list = db:getAllRows("select * from skyladder_historydata where id >= :mineid  order by id desc limit " .. start .. ",".. num, {maxeid=maxeid,mineid=mineid})
        return list,count
    end
    
    function self.getLastChampion(lsbid)
        local db = getDbo()
        local result = db:getRow("select * from skyladder_historydata where bid = ".. lsbid)
        if not result then
            result = {}
        end
        
        if not result.p then
            result.p = {}
        end
        
        local data = result.p[1] or {}

        if not result.sid then
            result.sid = 0
        end
        
        local champion = {}
        champion.sid = data[5] or 0
        champion.name = data[3] or ''
        champion.season = lsbid or 0
        
        return champion
    end
    
    --设置合服后的名称
    function self.setName(cubid,action,zid,id,name)
        -- {"cmd":"skyladderserver.setname","params":{"cubid":2,"action":1,"zid":3,"id":3000002,"name":"kkkopppppp"},"ts":1563017272,"zoneid":1}
        local ret=self.fetchInfo('skyladderserver.setname',{cubid=cubid,action=action,zid=zid,id=id,name=name})
        if ret then
            if ret.ret and ret.ret == 0 then
                return true
            end
        end
    end

    function self.fetchInfo(cmd,params)
        local data={cmd=cmd,params=params}
        local config = getConfig("config.skyladderserver.connect")
        local ret = {data={}}
--print('cmd',json.encode(data))
        for i=1,1 do
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

    --缓存key
    --
    --return string
    function self.getRedisKey()
        local matchKey = "z" .. getZoneId() ..".skyladder.matchinfo"
        return matchKey
    end

    --缓存比赛中的数据
    --params item hash二层key
    --params table info 缓存的信息
    --return boolean
    function self.cacheinfo(matchKey,item, info,expire)
        local redis = getRedis()
        local ret=redis:hset(matchKey, item, info)
        local ts = getClientTs()
        local st = getWeeTs()
        local diff = 0
        
        if ts - st > 0 then
            diff = math.floor((ts - st)/(expire or 300))
        end

        -- 下一个5分钟的时间戳
        local nextExpireAt = st + (expire or 300) * (diff + 1) 
        redis:expireat(matchKey,nextExpireAt)
            
        return true
    end

    -- 获取缓存数据
    function self.cacheget(matchKey,item)
        local redis = getRedis()
        local data =redis:hget(matchKey,item)
        return data
    end
    
    --读取大战结束状态
    function self.getBattleFin(cubid,btype,battleid)
        -- local redis = getRedis()
        -- local keys  = "z"..getZoneId()..".skyladder.b"..cubid..".battleFin."..battleid
        -- local status=redis:get(keys)

        -- if status then
            -- print('getGroup cache')
            -- return status
        -- end
        -- {"cmd":"skyladderserver.getbattlefin","params":{"cubid":2,"btype":5,"battleid":2640},"ts":1563017272,"zoneid":1}
        local ret=self.fetchInfo('skyladderserver.getbattlefin',{cubid=cubid,btype=btype,battleid=battleid})
        if ret then
            if ret.ret and ret.ret == 0 and ret.data then
                -- redis:set(keys,ret.data.status)
                -- redis:expire(keys,300)
                return ret.data.status
            end
        end
    end

    return self
end

