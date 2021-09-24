-- 
-- desc:节日花朵
-- user:chenyunhe
-- 注：该活动排行榜是本服内的 缓存定义key的时候跟跨服的做点了区别 如果其他人复用代码 可自定义
--
local function setRankingPoint(self,point)
    local key = getActiveCacheKey(self.activeName,"rank.aActivity",self.activeInfo.st)
    local redis = getRedis()

    redis:zadd(key,point,self.aid)
    redis:expireat(key,self.activeInfo.et+172800)

    return tonumber(redis:zrevrank(key,self.aid))
end

local function delRankingCache(self)
    getRedis():del(getActiveCacheKey(self.activeName,"rank.aActivity",self.activeInfo.st))
end

local function addPoint(self,params)
    local activeInfo = self.activeInfo
    activeInfo.score = (activeInfo.score or 0) + params.score
    activeInfo.aname = params.allianceName
    activeInfo.anum = params.anum or 0

    if activeInfo.score>=self.activeCfg.rLimit then
        delRankingCache(self)
    end   
    
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end

local function subPoint(self,score)
    if score > 0 then
        local activeInfo = self.activeInfo
        local oScore = activeInfo.score or 0
        activeInfo.score = (activeInfo.score or 0) - score
        if activeInfo.score < 0 then 
            activeInfo.score = 0
        end

        if oScore >= self.activeCfg.rLimit then
            delRankingCache(self)
        end

        regEventAfterSave(self.aid,'saveAllianceActive')
    end
end


local function getRankingList(self)
    local list = {}
    local key = getActiveCacheKey(self.activeName,"rank.aActivity",self.activeInfo.st)
    local redis = getRedis()
    local result = redis:zrevrange(key,0,(self.activeCfg.rNumLimit-1),'withscores')

    local db = getDbo()
    if type(result)~='table' or not next(result) then
        local res = db:getAllRows("select * from allianceactive where info like '%"..self.activeName.."%' order by aid") 
        if type(res)=='table' and next(res) then
            for k,v in pairs(res) do
                local aid = tonumber(v.aid)
                local info = json.decode(v.info)
                if info[self.activeName].st==self.activeInfo.st and (info[self.activeName].score or 0) > self.activeCfg.rLimit then
                    redis:zadd(key,info[self.activeName].score,tonumber(v.aid))
                    redis:expireat(key,self.activeInfo.et+172800)
                end
            end

            list = redis:zrevrange(key,0,(self.activeCfg.rNumLimit-1),'withscores')
        end
    else
        list = result
    end

    local list1 = {}
    if next(list) then
        local aids = {}
        for k,v in pairs(list) do
            table.insert(aids,v[1])
        end
        aids = table.concat(aids,',')
        local res = db:getAllRows("select * from allianceactive where aid in ("..aids..")") 
        local tmp = {}
        if type(res)=='table' and next(res) then
            for k,v in pairs(res) do
                local info = json.decode(v.info)
                local index = 'a'..tonumber(v.aid)
                tmp[index] = info[self.activeName] 
            end
        end

        for k,v in pairs(list) do
            local aid = tonumber(v[1])
            table.insert(list1,{aid,tmp['a'..aid].aname,tonumber(tmp['a'..aid].anum),tonumber(tmp['a'..aid].score)})
        end
    end

    return list1
end

local function addshare(self,params)
    local activeInfo = self.activeInfo
    activeInfo.aname = params.allianceName
    activeInfo.anum = params.anum or 0
    activeInfo.share = (activeInfo.share or 0) + params.share

    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end

local methods = {
    setRankingPoint=setRankingPoint,
    addPoint=addPoint,
    subPoint=subPoint,
    getRankingList=getRankingList,
    addshare=addshare,
    delRankingCache=delRankingCache,
}

---------------------------------------------

local new = function(aid,activeName,activeInfo,activeCfg)
    local o = {
        aid=aid,
        activeName=activeName,
        activeInfo=activeInfo,
        activeCfg=activeCfg,
    }

    setmetatable(o, {__index = methods})
    return o
end

return {
  new = new,
}
