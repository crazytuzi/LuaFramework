acSendGeneralVo = activityVo:new()

function acSendGeneralVo:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acSendGeneralVo:updateSpecialData(data)

	if self.value ==nil then
		self.value = 3888
	end 
	if data.value ~=nil then
		self.value =data.value
	end
	if data.dailyCondition ~=nil then --目前无用
		self.dailyCondition =data.dailyCondition
	end
	if data.rR then --补签价格
		self.retro = data.rR
	end
	if data.dailyReward then
		self.dailyReward = data.dailyReward
	end
	if data.bigReward then
		self.bigReward = data.bigReward
	end
	if data.p then
		self.sevenRe = data.p
	end
	if data.m then
		self.bigRewardHad =data.m
	end
end