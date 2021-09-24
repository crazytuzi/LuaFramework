acNewYearVo = activityVo:new()

function acNewYearVo:new()
	local nc = {}

	self.version = 0 --当前版本
	self.curChargeGold = 0 --当前已经充值的金币数
	self.goldCost = 0 --当前用户充值数
	self.giveCount = 0 --服务器返还用户的金币数
	self.addRate = 0 --统帅升级后增加的统率成功率
	self.upRewards = {} --统帅升级后赠送的奖励（赠送统率书）
	self.packageRewards = {} --免费和付费礼包奖励
	self.rewardBeginTime = 0 --领取礼包的开始时间
	self.rewardEndTime = 0 --领取礼包的结束时间
	--是否领取奖励的标识（goldFlag --> 金币奖励领取的标识 freeRewardFlag --> 免费礼包的领取标识 chargeRewardFlag --> 付费礼包的领取标识）
	self.rewardFlag = {
		goldFlag = 0,
		freeRewardFlag = 0,
		chargeRewardFlag = 0
	}

	setmetatable(nc,self)
	self.__index = self

	return nc
end

--解析来自服务器的活动配置数据
function acNewYearVo:updateSpecialData(data)
	if data then
		if data.version then
			self.version = data.version
		end
		if data.cost then
			self.goldCost = data.cost
		end
		if data.v then
			self.curChargeGold = data.v
		end
		if data.give then
			self.giveCount = data.give
		end
		if data.troopUp then
			self.addRate = data.troopUp
		end
		if data.succr then
			self.upRewards = data.succr
		end
		if data.hxcfg then
			self.hxcfg = data.hxcfg
		end
		if data.reward then
			self.packageRewards = data.reward
		end
		if data.rtime and data.rtime[1] and data.rtime[2] then
			local beginTime = data.rtime[1] --领取礼包的开始时间
			local durationTime = data.rtime[2] --领取礼包的持续时间
			self.rewardBeginTime = G_getWeeTs(self.st) + beginTime * 3600
			self.rewardEndTime = self.rewardBeginTime + durationTime * 3600
		end
		if data.g then
			for k,v in pairs(data.g) do
				if v == 1 then
					self.rewardFlag.freeRewardFlag = 1
				elseif v == 2 then
					self.rewardFlag.chargeRewardFlag = 1
				end
			end
		end
		if data.c then
			self.rewardFlag.goldFlag = data.c
			print("self.rewardFlag.goldFlag ========= ",self.rewardFlag.goldFlag)
		end
	end
end