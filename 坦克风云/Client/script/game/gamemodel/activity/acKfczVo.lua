acKfczVo = activityVo:new()

function acKfczVo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function acKfczVo:updateSpecialData(data)
    if data == nil then
        return
    end
    if data._activeCfg then
        if data._activeCfg.version then
            self.version = data._activeCfg.version
        end
    	if data._activeCfg.rankingReward then --排行奖励
        	self.rankingReward = data._activeCfg.rankingReward
        end
        if data._activeCfg.luckyReward then --幸运奖励
        	self.luckyReward = data._activeCfg.luckyReward
        end
        if data._activeCfg.rankingRecharge then --排行榜最低充值金额
        	self.rankingRecharge = data._activeCfg.rankingRecharge
        end
        if data._activeCfg.luckyNum then --幸运奖个数
        	self.luckyNum = data._activeCfg.luckyNum
        end
        if data._activeCfg.rankingNum then --充值排名个数
        	self.rankingNum = data._activeCfg.rankingNum
        end
        if data._activeCfg.listReward then --上榜奖励
        	self.listReward = data._activeCfg.listReward
        end
        if data._activeCfg.keepReward then --连榜奖励
        	self.keepReward = data._activeCfg.keepReward
        end
    end
    if data.dn then --今日充值金币数
    	self.dn = data.dn
    end
    if data.yn then --昨日充值金币数
    	self.yn = data.yn
    end
    if data.total then --总充值金币数
    	self.total = data.total
    end
end