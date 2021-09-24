acNlgcVo = activityVo:new()

function acNlgcVo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    nc.item = {ac = {nlgc_a1 = 1}}

    return nc
end

function acNlgcVo:updateSpecialData(data)
    if data ~= nil then
        if data._activeCfg then
            self.acCfg = data._activeCfg
            self.version = self.acCfg.version
        end
        if data.gems then
            self.gems = data.gems--累计充值/消费
        end
        if data.times then
            self.times = data.times--购买次数
        end
        if data.rd then
            self.rd = data.rd--领奖的次数
        end
        if data.enery then
            self.enery = data.enery--能量数
        end
    end
end
