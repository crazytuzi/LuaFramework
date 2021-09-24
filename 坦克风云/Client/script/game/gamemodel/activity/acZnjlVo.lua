acZnjlVo = activityVo:new()
function acZnjlVo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acZnjlVo:updateSpecialData(data)
    if data ~= nil then
        if data._activeCfg then
            self.activeCfg = data._activeCfg
        end
        --每日领取奖励的标识 1:今日已领取
        if data.c then
            self.rewardFlag = data.c
        end
        --领取奖励的时间戳，用于跨天重置
        if data.t then
            self.lastTime = data.t
        end
        if self.lastTime == 0 then
            self.lastTime = base.serverTime
        end
        --是否有获得幸运锦鲤的资格 1：有资格
        if data.v then
            self.qualification = data.v
        end

        if self.activeCfg and self.activeCfg.version then
            self.version = self.activeCfg.version
        end
    end
end
