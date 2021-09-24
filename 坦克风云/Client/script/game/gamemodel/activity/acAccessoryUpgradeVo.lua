acAccessoryUpgradeVo=activityVo:new()
function acAccessoryUpgradeVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.lastByTimestamp=0	 --上次购买水晶的时间戳
	self.todayBy=0			 --今天买了几次
	return nc
end

function acAccessoryUpgradeVo:updateSpecialData(data)
	if(data.t)then
        self.lastByTimestamp=tonumber(data.t)
    end
    if(self.lastByTimestamp<G_getWeeTs(base.serverTime))then
        self.todayBy=0
    elseif(data.c)then
        self.todayBy=tonumber(data.c)
    end

    if data.version then
    	self.version =data.version
    end

    if data.t then
        self.lastTime =data.t
    end
end
