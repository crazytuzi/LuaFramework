acJtxlhVo = activityVo:new()
function acJtxlhVo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acJtxlhVo:updateSpecialData(data)
    if data ~= nil then
        if(data._activeCfg)then
            self.activeCfg = data._activeCfg
            if self.activeCfg.version then
                self.version = self.activeCfg.version
            end
        end
        self.arNum = tonumber(data.arecharge) or 0 --军团充值金额
        self.prNum = tonumber(data.v) or 0 --个人充值金额
        self.aRgs = data.areward or {} --军团奖励领取状态
        self.pRgs = data.tr or {} --个人奖励领取状态
    end
end
