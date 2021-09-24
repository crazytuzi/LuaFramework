-- model.active.foolday2018

local function createTask(activeCfg,oldTask)
    setRandSeed()
    local n = rand(1,#activeCfg.allianceTask)
    if activeCfg.allianceTask[n].type == oldTask then
        n = n == #activeCfg.allianceTask and 1 or (n+1)
    end

    return {
        id = n,
        tp = activeCfg.allianceTask[n].type,
        num = 0, -- 完成进度
        r = 0, -- 当日领取任务完成次数
    }
end

local function init(self)
    if self.aid > 0 then
        if not self.activeInfo.t then
            self.activeInfo.r = 0 -- 排行榜领取次数
            self.activeInfo.dnr = {0,0,0,0} -- 捐献奖励领取次数
            self.activeInfo.atask = createTask(self.activeCfg) -- 排行榜领取次数
            self.activeInfo.t = getClientTs()
            regEventAfterSave(self.aid,'saveAllianceActive')
        elseif self.activeInfo.t < getWeeTs() then
            local oldTask = self.activeInfo.atask and self.activeInfo.atask.tp
            self.activeInfo.atask = createTask(self.activeCfg,oldTask)
            self.activeInfo.t = getClientTs()
            regEventAfterSave(self.aid,'saveAllianceActive')
        end
    end
end

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
    if params.item then
        if not activeInfo.itemPoint then activeInfo.itemPoint = {} end
        activeInfo.itemPoint[params.item] = (activeInfo.itemPoint[params.item] or 0) + params.point
    end

    activeInfo.p = (activeInfo.p or 0) + params.point

    if activeInfo.p >= self.activeCfg.rLimit then
        local myRanking = self:setRankingPoint(activeInfo.p)
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
                    score=activeInfo.p,
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

local function subPoint(self,point)
    if point > 0 then
        local activeInfo = self.activeInfo
        local oldPoint = activeInfo.p or 0
        activeInfo.p = (activeInfo.p or 0) - point
        if activeInfo.p < 0 then 
            activeInfo.p = 0
        end

        if oldPoint >= self.activeCfg.rLimit then
            local myRanking = self:setRankingPoint(activeInfo.p)
            require("lib.crossActivity").setRankingData({
                whereColumns={
                    "zoneid",
                    "st",
                    "acname",
                    "aid",
                },
                data = {
                    aid=self.aid,
                    score=activeInfo.p,
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

local function setTask(self,params)
    if params.tp == self.activeInfo.atask.tp then
        if params.num > 0 then
            local maxNum = self.activeCfg.allianceTask[self.activeInfo.atask.id].num
            if self.activeInfo.atask.num < maxNum then
                self.activeInfo.atask.num = self.activeInfo.atask.num + params.num
                if self.activeInfo.atask.num > maxNum then
                    self.activeInfo.atask.num = maxNum
                end

                regEventAfterSave(self.aid,'saveAllianceActive')
            end
        end
    end
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

local methods = {
    init=init,
    setRankingPoint=setRankingPoint,
    addPoint=addPoint,
    subPoint=subPoint,
    setTask=setTask,
    getRankingList=getRankingList,
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

    if aid > 0 and o.init then o:init() end

    return o
end

return {
  new = new,
}
