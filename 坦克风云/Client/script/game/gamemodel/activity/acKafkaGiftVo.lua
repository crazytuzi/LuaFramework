acKafkaGiftVo= activityVo:new()

function acKafkaGiftVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acKafkaGiftVo:updateSpecialData( data )
	if data then
		if data.t then
			self.lastTime =data.t --抽奖时间戳
		end
		if data.v then
			self.recharged =data.v --已充值的金币数 当天的
		end
		if data.flag then
			self.recAwardFlagList =data.flag --领过奖的标记列表
		end
		if self.recAwardFlagList ==nil then
			self.recAwardFlagList={}
		end

		if self.hadAwardList ==nil then
			self.hadAwardList ={}
		end
		if data.mark then
			self.hadAwardList =data.mark --暂时无用
		end

		if data.cost then 
			self.costStandardList =data.cost --充值等级列表
		end
		if data.rule then
			self.requireInVipList =data.rule --选择奖励所需的VIP等级列表
		end
		if data.reward then
			self.awardList =data.reward --奖励列表
		end
		if self.clickBigAward ==nil then
			self.clickBigAward ={}
		end
		if data.t  then  --每日领取奖励时间标识
			self.time = data.t
		end

		if self.ChooseFlagList ==nil then
			self.ChooseFlagList ={}
		end

		if data.version then
			 self.version =data.version
		end
       

	end
end