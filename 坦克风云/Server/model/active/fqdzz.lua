--
-- 番茄大作战
-- chenyunhe
--

local function setRankingPoint(self,steps)
    local key = getActiveCacheKey(self.activeName,"rank.aActivity",self.activeInfo.st)
    local redis = getRedis()

    redis:zadd(key,steps,self.aid)
    redis:expireat(key,self.activeInfo.et+172800)

    return tonumber(redis:zrevrank(key,self.aid))
end

local function delRankingCache(self)
    getRedis():del(getActiveCacheKey(self.activeName,"crossrank.aActivity",self.activeInfo.st))
end

-- 增加番茄汁
local function addPoint(self,params)
    local activeInfo = self.activeInfo

    activeInfo.aname = params.allianceName
    if type(activeInfo.reward)~='table' then
        activeInfo.reward = {}
    end

    -- 军团各奖励数据
    if type(params.reward)=='table' and next(params.reward) then
        for k,v in pairs(params.reward) do
            activeInfo.reward[k] = (activeInfo.reward[k] or 0) + v
        end
    end
   

 
    local result = require("lib.crossActivity").setRankingData({
        whereColumns={
            "zoneid",
            "st",
            "acname",
            "aid",
        },
        data = {
            aid=self.aid,
            score=params.score,
            acname=self.activeName,
            alliancename=params.allianceName,
            nickname=params.logo,
            st=self.activeInfo.st,
            zoneid=getZoneId(),
        },
    })

    delRankingCache(self)
   
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo,json.decode(result)
end

-- 排行榜
local function getRankingList(self,aid)
    local list = {}
    local result,other = require("lib.crossActivity").getRankingList({
        whereColumns={
            "st",
            "acname",
        },
        data = {
            acname=self.activeName,
            st=self.activeInfo.st,
            aid = aid,
            zoneid = getZoneId(),
        },
    })

    local score = 0
    if type(result) == "table" then
        for k,v in pairs(result) do
            score = tonumber(v.score) or 0
            if score >= self.activeCfg.rLimit then
                table.insert(list,{
                        tonumber(v.zoneid) or 0,
                        tonumber(v.aid) or 0,
                        tonumber(v.score) or 0,
                        tostring(v.alliancename)
                })
            end
        end
    end
 
    return list,other
end



-- 记录军团番茄数
local function addfq(self,params)
    local activeInfo = self.activeInfo
    activeInfo.fqdzz_a1 = (activeInfo.fqdzz_a1 or 0) + params.fqdzz_a1
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end

--获取可以扔番茄的军团
local function gettargets(self)
    local result = require("lib.crossActivity").gettargets({
        data = {
            acname=self.activeName,
            st = self.activeInfo.st,
            aid = self.aid,
            zoneid=getZoneId(),
        },
    })
    
    if type(result)~='table' or not next(result) then
        return {}
    end

    return result
end

local methods = {
    setRankingPoint=setRankingPoint,
    addPoint=addPoint,
    getRankingList=getRankingList,
    addfq = addfq,
    gettargets = gettargets,
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
