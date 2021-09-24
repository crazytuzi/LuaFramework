acRechargeGameVo=activityVo:new()
function acRechargeGameVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acRechargeGameVo:updateSpecialData( data )
	if data.showMod then
		self.showMod =data.showMod
	end

	if data.reward then --奖励TB
		self.rewardTb =data.reward
	end

	if self.rewardTb ==nil then
		self.rewardTb = {}
	end

	if self.rankList ==nil then--排名名单
		self.rankList ={}
	end

	if self.rechargeGold ==nil then
		self.rechargeGold =0
	end

	if data.ranklimit then
		self.ranklimit =data.ranklimit
	end

	if self.ranklimit ==nil then
		self.ranklimit =20
	end
	if data.rankMixValue then
		self.rankMixValue =data.rankMixValue
	end
	if self.rankMixValue ==nil then
		self.rankMixValue =5000
	end

	if self.isRefRank ==nil then
		self.isRefRank =false
	end

end