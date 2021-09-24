acOnlineRewardXVIIIVo=activityVo:new()
function acOnlineRewardXVIIIVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acOnlineRewardXVIIIVo:updateSpecialData(data)
	if not self.cfgNum then
		self.cfgNum = 0
	end
	if self.rewardCfg == nil then
		self.rewardCfg = {}
	end

	if data._activeCfg and data._activeCfg.oward then
		local newT = nil
		if self.cfgNum > 0 and self.rewardCfg and self.rewardCfg[self.cfgNum].t > 7200 then
			newT = self.rewardCfg[self.cfgNum].t
		end
		self.rewardCfg = data._activeCfg.oward

		if self.cfgNum == 0 then
			self.cfgNum = SizeOfTable(self.rewardCfg)
		end

		if newT then
			self.rewardCfg[self.cfgNum].t =newT
		end
		if not self.oldLastAwardT then
			self.oldLastAwardT = 7200
		end
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

	if self.refreshLastAward == nil then
		self.refreshLastAward = false
	end
	if not self.acOnlineTime then
		self.acOnlineTime = -1
	end
end

function acOnlineRewardXVIIIVo:updateOnlineTime(data)
    self.acOnlineTime = data
end

function acOnlineRewardXVIIIVo:setLastAddTime(t)
    self.lastAddTime = t
end


function acOnlineRewardXVIIIVo:getLastAddTime()
    if self.lastAddTime ~= nil then
        return self.lastAddTime
    end
    return -1
end