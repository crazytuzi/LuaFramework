acJjzzVo = activityVo:new()
function acJjzzVo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function acJjzzVo:updateSpecialData(data)
    if data ~= nil then
        if data._activeCfg then
            self.acCfg = data._activeCfg
            self.version = self.acCfg.version
        end
        
        if data.key then
            self.key = data.key--默认将领
        end
        
        if data.times then
            self.times = data.times--已经抽奖的次数
        end
    end
end
