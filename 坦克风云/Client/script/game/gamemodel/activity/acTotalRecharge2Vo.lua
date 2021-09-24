acTotalRecharge2Vo=activityVo:new()

function acTotalRecharge2Vo:updateSpecialData(data)
	if self.reward == nil then
		self.reward = {}
	end

	if data.reward ~= nil then
		self.reward = data.reward
	end

	if self.cost == nil then
		self.cost = {}
	end

	if data.cost ~= nil then
		self.cost = data.cost
	end
	self.onlineTime = -1
end


function acTotalRecharge2Vo:updateOnlineTime(data)
    self.onlineTime = data
end

function acTotalRecharge2Vo:setLastAddTime(t)
    self.lastAddTime = t
end


function acTotalRecharge2Vo:getLastAddTime()
    if self.lastAddTime ~= nil then
        return self.lastAddTime
    end
    return -1
end