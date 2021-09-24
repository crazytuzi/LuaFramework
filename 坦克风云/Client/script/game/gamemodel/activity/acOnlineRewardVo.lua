acOnlineRewardVo=activityVo:new()
function acOnlineRewardVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acOnlineRewardVo:updateSpecialData(data)
	if self.rewardCfg == nil then
		self.rewardCfg = {}
	end

	if data.oward then
		self.rewardCfg = data.oward
	end

	if self.hadReward == nil then
		self.hadReward = {}
	end
	if data.v and type(data.v)=="table" then
		self.hadReward = data.v
	end

	if data.t then
		self.lastTime = data.t
	end
    if self.lastTime then
		if G_isToday(self.lastTime) == false then
            self.lastTime = G_getWeeTs(base.serverTime)
            self.hadReward  ={}
        end
	end


	self.acOnlineTime = -1
end

function acOnlineRewardVo:updateOnlineTime(data)
    self.acOnlineTime = data
end

function acOnlineRewardVo:setLastAddTime(t)
    self.lastAddTime = t
end


function acOnlineRewardVo:getLastAddTime()
    if self.lastAddTime ~= nil then
        return self.lastAddTime
    end
    return -1
end