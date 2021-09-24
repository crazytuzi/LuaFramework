acBaseLevelingVo=activityVo:new()

function acBaseLevelingVo:updateSpecialData(data)
	if(data.reward and self.cfg==nil)then
		self.cfg=data.reward
	end
	-- c代表主基地等级
	-- t 是否领奖 若领奖则包含该领奖需要达到的玩家等级
	self.acEt = self.acEt - 86400
end