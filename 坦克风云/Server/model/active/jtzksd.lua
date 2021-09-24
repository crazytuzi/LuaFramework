-- 军团折扣商店
-- model.active.jtzksd

local function addPoint(self,params)
    local activeInfo = self.activeInfo

    activeInfo.legion= (activeInfo.legion or 0) + params.num
    activeInfo.aname = params.allianceName
    
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end

local function delnum(self,num,id)

    local activeInfo = self.activeInfo

    if type(activeInfo.rlimit) ~= 'table' then
            activeInfo.rlimit = {}  
            for key,val in pairs(self.activeCfg.shopRecharge) do
                table.insert(activeInfo.rlimit,num)
            end
    end
    activeInfo.rlimit[id]=activeInfo.rlimit[id]-1
    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end


local methods = {
    addPoint=addPoint,
    delnum=delnum,
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
