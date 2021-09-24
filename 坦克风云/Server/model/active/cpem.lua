-- 冲破噩梦
-- model.active.cpem

local function setboss(self)
    if not self.activeInfo.HP or self.activeInfo.HP <=0 or not self.activeInfo.LEFTHP or self.activeInfo.LEFTHP<=0  then
        setRandSeed() 
        -- 改变boss类型
        if self.activeInfo.num%self.activeCfg.changeSpace==0 then
            local pool = copyTable(self.activeCfg.serverreward.bossPool)
            --self.activeInfo.type=1
            for k,v in pairs(pool[3]) do
                if v==self.activeInfo.type then
                    table.remove(pool[3],k)
                    table.remove(pool[2],k)
                end
            end

            local re,rkey = getRewardByPool(pool,1)  
            self.activeInfo.type = re[1]
        end

        self.activeInfo.num = self.activeInfo.num + 1 -- 轮数
        self.activeInfo.HP = self.activeCfg.bossHp + (self.activeInfo.num-1) * self.activeCfg.hpUp
        self.activeInfo.LEFTHP = self.activeInfo.HP

        return true

    end

    return false
end

local function init(self)
    if self.aid > 0 then
        local flag = false
        -- 军团奖励领取次数
        if not self.activeInfo.rt then
            self.activeInfo.rt = 0
            flag = true
        end

        -- 军团内部排名第一奖励
        if not self.activeInfo.pr then
            self.activeInfo.pr = 0
            flag = true
        end
 
        -- 军团总伤害
        if not self.activeInfo.damage then
            flag = true
            self.activeInfo.damage = 0
        end

        -- boss刷新的次数
        if not self.activeInfo.num then
            flag = true
            self.activeInfo.num = 0
        end
        -- boss类型
        if not self.activeInfo.type then
            self.activeInfo.type = 0 
            flag = true
        end

        if setboss(self) then
            flag = true
        end

        if flag then
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
    activeInfo.damage = (activeInfo.damage or 0) + params.damage

    if activeInfo.damage >= self.activeCfg.rLimit then
        local myRanking = self:setRankingPoint(activeInfo.damage)
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
                    score=activeInfo.damage,
                    acname=self.activeName,
                    alliancename=params.allianceName,
                    st=self.activeInfo.st,
                    zoneid=getZoneId(),
                },
            })
        end

        delRankingCache(self)
    end

    -- 多余的伤害 需要作用到下一轮 直至伤害为零
    local damage = params.damage
    local function setdamage(self,damage)
        local dif = self.activeInfo.LEFTHP - damage     
        if dif>0 then
            self.activeInfo.LEFTHP = dif
            return true
        else
            damage = damage - self.activeInfo.LEFTHP
            self.activeInfo.LEFTHP = 0
            setboss(self)
            setdamage(self,damage)
        end
    end

    setdamage(self,damage)
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end

local function subPoint(self,damage)
    if damage > 0 then
        local activeInfo = self.activeInfo
        activeInfo.damage = activeInfo.damage and activeInfo.damage or 0
        local olddam = activeInfo.damage
        activeInfo.damage = activeInfo.damage - damage
        if activeInfo.damage < 0 then 
            activeInfo.damage = 0
        end

        if olddam >= self.activeCfg.rLimit then
            local myRanking = self:setRankingPoint(activeInfo.damage)
            require("lib.crossActivity").setRankingData({
                whereColumns={
                    "zoneid",
                    "st",
                    "acname",
                    "aid",
                },
                data = {
                    aid=self.aid,
                    score=activeInfo.damage,
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

local methods = {
    init=init,
    setRankingPoint=setRankingPoint,
    addPoint=addPoint,
    subPoint=subPoint,
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
