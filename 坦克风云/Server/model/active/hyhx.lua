--
-- 海域航线
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

local function addPoint(self,params)
    local activeInfo = self.activeInfo
    activeInfo.score = (activeInfo.score or 0) + params.score
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
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

local function initcells(self)
    self.activeInfo.cells = {}
    local n = (self.activeInfo.n or 0) + 1
    for k,v in pairs(self.activeCfg.distribute) do
        -- 宝箱
        if v==1 then
            table.insert(self.activeInfo.cells,{1,0})
        else
            -- boss
            local blood = self.activeCfg.initialHp + (n-1)*self.activeCfg.hpUp
            if blood>self.activeCfg.maxHp then
                blood = self.activeCfg.maxHp
            end
            table.insert(self.activeInfo.cells,{2,blood,blood})
        end
    end

    self.activeInfo.n = n -- 更新轮次
    self.activeInfo.index = 1 -- 更新位置
end

-- 获取格子数据
local function getcells(self,act)
    if type(self.activeInfo.cells)~='table' or act then
        initcells(self)
        regEventAfterSave(self.aid,'saveAllianceActive')
    end

    return self.activeInfo.cells
end

-- 移动 
local function move(self,params)
    local  ret = 0
    local score = self.activeInfo.score or 0 -- 当前积分
    local curindex = self.activeInfo.index or 1 -- 当前的位置
    local curn = self.activeInfo.n or 1 --轮次 
    -- 当前位置状态  宝箱 or BOSS
    local cells = self.activeInfo.cells
    if type(cells)~='table' or not next(cells) then
        ret = -102
        return ret
    end

    -- 下一轮了
    if params.index ==8 then
        -- 最后一个箱子没开
        if curindex~=7 or cells[7][2]~=1 then
            ret = -100
            return ret
        end

        self.activeInfo.index = 1
        initcells(self)
    else
        self.activeInfo.index = params.index
        if params.index ~= curindex+1 then
            ret =-102
            return ret
        end

        if cells[curindex][1]==1 then
            if cells[curindex][2] ==0 then
                ret = -1989
                return ret
            end
        else---boss是否被击杀
            if cells[curindex][3]>0 then
                ret = -1989
                return ret
            end
        end
        -- 下一个也验证一下
        if cells[params.index][1]==1 then
            if cells[params.index][2] ==1 then
                ret = -100
                return ret
            end
        else---boss是否被击杀
            if cells[params.index][3]==0 then
                ret = -100
                return ret
            end
        end
    end
   
    -- 判断消耗
    if score<self.activeCfg.cost1 then
        ret = -107
        return ret
    end

    self.activeInfo.score = score - self.activeCfg.cost1
    self.activeInfo.steps = (self.activeInfo.steps or 0) + 1
    if self.activeInfo.steps >= self.activeCfg.rLimit then
        local myRanking = self:setRankingPoint(self.activeInfo.steps)
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
                    score=self.activeInfo.steps,
                    acname=self.activeName,
                    alliancename=params.allianceName,
                    st=self.activeInfo.st,
                    zoneid=getZoneId(),
                },
            })
        end
    end

    delRankingCache(self)
    regEventAfterSave(self.aid,'saveAllianceActive')

    return ret  
end

-- 团长打开格子上的宝箱
local function open(self,params)
    local  ret = 0
    local score = self.activeInfo.score or 0 -- 当前积分
    local curindex = self.activeInfo.index or 0 -- 当前的位置
    local curn = self.activeInfo.n or 1 --轮次 
    -- 当前位置状态  宝箱 or BOSS
    local cells = self.activeInfo.cells
    if type(cells)~='table' or not next(cells) then
        ret = -102
        return ret
    end
    
    if params.index ~= curindex then
        ret =-102
        return ret
    end
    -- 是不是箱子
    if cells[params.index][1]~=1 then
        ret = -102
        return ret
    end
    -- 有没有打开
    if cells[params.index][2]==1 then
        ret = -1976
        return ret
    end
    
    -- （每层增长，即消耗=cost2+（当前层数-1）*costUp）
    local cost = self.activeCfg.cost2 + (curn-1)*self.activeCfg.costUp
    if cost~=params.cost then
        ret = -100
        return ret
    end
    -- 判断消耗
    if score<cost then
        ret = -107
        return ret
    end

    self.activeInfo.score = score - cost
    if type(self.activeInfo.abox)~='table' then
        self.activeInfo.abox = {}
    end

    local pool = {1,0,2,0,3,0,4}
    local pid= pool[params.index]
    if pid==0 then
        ret=-120
        return ret
    end

    self.activeInfo.abox['p'..pid] = (self.activeInfo.abox['p'..pid] or 0) + 1
    cells[params.index][2] =  1 -- 这行代码不要换位置
    -- 如果是最后一个 需要重新开启一轮
    -- if params.index>=self.activeCfg.cellNum then
    --     initcells(self)
    -- end
  
    regEventAfterSave(self.aid,'saveAllianceActive')

    return ret  
end

-- 攻打boss
local function attack(self,params)
    local  ret = 0
    local curindex = self.activeInfo.index or 0 -- 当前的位置
    local curn = self.activeInfo.n or 1
    -- 当前位置状态  宝箱 or BOSS
    local cells = self.activeInfo.cells
    if type(cells)~='table' or not next(cells) then
        ret = -102
        return ret
    end
    
    if params.bi ~= curindex or params.bn~=curn then
        ret =-102
        return ret
    end
    -- 是不是boss
    if cells[params.bi][1]~=2 then
        ret = -102
        return ret
    end
    -- 有没有被打死
    if cells[params.bi][3]<=0 then
        ret = -100
        return ret
    end

    setRandSeed()
    -- 伤害 = 保底伤害 + 额外伤害（min(战力/x+rand(1,100),extraLimit)）
    local min = math.floor(params.fc/self.activeCfg.extraDmgRate+rand(1,100))
    local exatt = math.min(min,self.activeCfg.extraLimit)
    local attacknum = self.activeCfg.minDmg + exatt

    local killflag = false
    if cells[params.bi][3]>attacknum then
        cells[params.bi][3] =  cells[params.bi][3] - attacknum
    else
        killflag = true
        cells[params.bi][3] = 0
    end

    regEventAfterSave(self.aid,'saveAllianceActive')

    return ret,killflag,curn,curindex
end

local methods = {
    setRankingPoint=setRankingPoint,
    addPoint=addPoint,
    getRankingList=getRankingList,
    getcells=getcells,
    move=move,
    open=open,
    attack=attack,
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
