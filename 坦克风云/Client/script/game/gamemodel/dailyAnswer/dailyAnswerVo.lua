dailyAnswerVo=dailyActivityVo:new()

function dailyAnswerVo:new(type)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.type=type
    return nc
end

function dailyAnswerVo:dispose()
	dailyAnswerVoApi:clear(true)
end

function dailyAnswerVo:updateData(data)
    if data[1] then
      self.st = data[1]
    end
    if data[2] then
        self.et = data[2]
    end
end

function dailyAnswerVo:checkActive()
    if base.dailyAcYouhuaSwitch==1 then
        local st = meiridatiCfg.openTime[1][1]*60*60+meiridatiCfg.openTime[1][2]*60
        local et = meiridatiCfg.openTime[2][1]*60*60+meiridatiCfg.openTime[2][2]*60
        local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
        if dayTime and dayTime>st and dayTime<et then
            return true
        end
    end
    return false
end