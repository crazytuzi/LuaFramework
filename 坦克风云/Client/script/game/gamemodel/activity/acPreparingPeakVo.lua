acPreparingPeakVo=activityVo:new()
function acPreparingPeakVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end
function acPreparingPeakVo:updateSpecialData(data)
	 if self.props == nil then
        self.props = {}
    end
	if data.buy ~= nil then
    	self.props = data.buy
    end
    if data.t then
    	self.lastTime = data.t
    end
    if self.lastTime == nil and self.lastTime == 0 then
    	self.lastTime = G_getWeeTs(base.serverTime)
    end

    if self.reward == nil then
    	self.reward = {}
    end

    if data.v then
    	self.reward = data.v
    end

end