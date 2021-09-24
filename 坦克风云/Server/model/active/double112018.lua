-- 双十一2018

-- 增加消耗积分
local function addPoint(self,point)
    if point <= 0 then return end

    self.activeInfo.p = (self.activeInfo.p or 0) + point

    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo.p
end

local function getPoint(self,point)
    return self.activeInfo.p or 0
end

local function subPoint(self,point)
    if point <= 0 then return end

    local activeInfo = self.activeInfo
    activeInfo.p = (activeInfo.p or 0) - point
    if activeInfo.p < 0 then 
        activeInfo.p = 0
    end

    regEventAfterSave(self.aid,'saveAllianceActive')
end

local function getRebateRate(self)
    local p = self.activeInfo.p or 0
    local rate
    for i=1,#self.activeCfg.rebateStep do
        if p < self.activeCfg.rebateStep[i] then
            break 
        end
        rate = self.activeCfg.rebateRate[i]
    end

    if not rate then rate = 0 end

    -- 为了安全写死
    if rate > 0.5 then rate = 0.5 end

    return rate
end

local methods = {
    addPoint=addPoint,
    subPoint=subPoint,
    getPoint=getPoint,
    getRebateRate=getRebateRate,
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
