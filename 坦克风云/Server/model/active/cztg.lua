-- 累计充值
-- guohaojie

local function addPoint(self,params)
    local activeInfo = self.activeInfo
    --隔天初始化 军团数据
    if activeInfo.ats  ~= getWeeTs() then
        activeInfo.legion=0
        activeInfo.ats  = getWeeTs()
    end
    activeInfo.legion= (activeInfo.legion or 0) + params.num
    activeInfo.aname = params.allianceName
    
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end

local function remake(self,num,id)

    local activeInfo = self.activeInfo
    activeInfo.legion = 0
    activeInfo.ats    = getWeeTs()
    
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end


local methods = {
    addPoint=addPoint,
    remake=remake,
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
