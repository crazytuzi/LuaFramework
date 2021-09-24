--
-- desc: 感恩节拼图
-- user: chenyunhe
--

local function init(self)
    if self.aid > 0 then
        if type(self.activeInfo.store)~='table' then
            self.activeInfo.store = {}
            for k,v in pairs(self.activeCfg.puzzleItem) do
                table.insert(self.activeInfo.store,0)
            end
        end
        
        regEventAfterSave(self.aid,'saveAllianceActive')  
    end
end

local function addFrag(self,params)
    local activeInfo = self.activeInfo
    activeInfo.store[params.index] = activeInfo.store[params.index] + params.num

    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end

local function subFrag(self,params)
    if params.num<=0 then return false end
    local activeInfo = self.activeInfo
    if activeInfo.store[params.index]<params.num then
        return false
    end
    activeInfo.store[params.index] = activeInfo.store[params.index] - params.num

    regEventAfterSave(self.aid,'saveAllianceActive')
    return self.activeInfo
end


local methods = {
    init=init,
    addFrag=addFrag,
    subFrag=subFrag,
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
