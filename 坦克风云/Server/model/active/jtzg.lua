-- 军团之光
-- model.active.jtzg

local function setRankingPoint(self,point)
    local key = getActiveCacheKey(self.activeName,"rank.aActivity",self.activeInfo.st)
    local redis = getRedis()

    redis:zadd(key,point,self.aid)
    redis:expireat(key,self.activeInfo.et+172800)

    return tonumber(redis:zrevrank(key,self.aid))
end

local function delRankingCache(self)
    getRedis():del(getActiveCacheKey(self.activeName,"crossrank.aActivity",self.activeInfo.st))
end

local function addPoint(self,params)
    local activeInfo = self.activeInfo
    activeInfo.score = (activeInfo.score or 0) + params.score
    activeInfo.aname = params.allianceName
    activeInfo.anum = params.anum or 0
    if activeInfo.score >= self.activeCfg.rLimit then
        local myRanking = self:setRankingPoint(activeInfo.score)
        if myRanking <= self.activeCfg.rNumLimit then
            require("lib.crossActivity").setRankingData({
                whereColumns={
                    "zoneid",
                    "st",
                    "acname",
                    "aid",
                },
                data = {
                    aid=self.aid,
                    score=activeInfo.score,
                    acname=self.activeName,
                    alliancename=params.allianceName,
                    st=self.activeInfo.st,
                    zoneid=getZoneId(),
                },
            })
        end

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
            local myRanking = self:setRankingPoint(activeInfo.score)
            require("lib.crossActivity").setRankingData({
                whereColumns={
                    "zoneid",
                    "st",
                    "acname",
                    "aid",
                },
                data = {
                    aid=self.aid,
                    score=activeInfo.score,
                    acname=self.activeName,
                    st=self.activeInfo.st,
                    zoneid=getZoneId(),
                },
            })
        end

        delRankingCache(self)
    end

    regEventAfterSave(self.aid,'saveAllianceActive')
end


local function getRankingList(self)
    local list = {}

    local key = getActiveCacheKey(self.activeName,"crossrank.aActivity",self.activeInfo.st)
    local redis = getRedis()
    local result = redis:get(key)
    result = result and json.decode(result)
    if not result then
        result = require("lib.crossActivity").getRankingList({
            whereColumns={
                "st",
                "acname",
            },
            data = {
                acname=self.activeName,
                st=self.activeInfo.st,
            },
        })

        local score = 0
        if type(result) == "table" then
            for k,v in pairs(result) do
                score = tonumber(v.score) or 0
                if score > self.activeCfg.rLimit then
                    table.insert(list,{
                            tonumber(v.zoneid) or 0,
                            tonumber(v.aid) or 0,
                            tonumber(v.score) or 0,
                            tostring(v.alliancename)
                    })
                end
            end
        end

        redis:set(key,json.encode(list))

        local expireat = os.time() + 120
        if expireat > self.activeInfo.et then
            expireat = self.activeInfo.et
        end

        redis:expireat(key,expireat)
    else
        list = result
    end

    return list
end

local function resetPoint(self)
    local activeInfo = self.activeInfo

    if activeInfo.score >= self.activeCfg.rLimit then
        local myRanking = self:setRankingPoint(activeInfo.score)
        if myRanking <= self.activeCfg.rNumLimit then
            require("lib.crossActivity").setRankingData({
                whereColumns={
                    "zoneid",
                    "st",
                    "acname",
                    "aid",
                },
                data = {
                    aid=self.aid,
                    score=activeInfo.score,
                    acname=self.activeName,
                    alliancename=activeInfo.aname,
                    st=self.activeInfo.st,
                    zoneid=getZoneId(),
                },
            })
        end

        delRankingCache(self)
    end

    return self.activeInfo
end

local methods = {
    setRankingPoint=setRankingPoint,
    addPoint=addPoint,
    subPoint=subPoint,
    getRankingList=getRankingList,
    resetPoint=resetPoint,
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
