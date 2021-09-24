acShareHappinessVo=activityVo:new()

function acShareHappinessVo:updateSpecialData(data)
	-- self.c 代表是否已经领取过奖励  -1 代表已经领取过
	self.acEt = self.acEt - 86400
end