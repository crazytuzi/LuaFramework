acMeteoriteLandingVo=activityVo:new()
function acMeteoriteLandingVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acMeteoriteLandingVo:updateSpecialData(data)

	if data.cost then
		self.oneCost = data.cost
	end
	if data.mulCost then
		self.mulCost = data.mulCost
	end

	if data.ranklimit then
		self.ranklimit = data.ranklimit
	end

	if data.rankNeedPoint then
		self.scoreLimit=data.rankNeedPoint
	end

	if data.resource then
		self.resource=data.resource
	end
	if data.rewardTime then
		self.rewardTime=data.rewardTime
	end

	if data.m then 
        self.isReceive = data.m
    end 

	if data.l then
		self.score=data.l
	end

	if data.rankReward then
		self.rankReward=data.rankReward
	end

	if data.t then
		self.lastTime=data.t
	end

end