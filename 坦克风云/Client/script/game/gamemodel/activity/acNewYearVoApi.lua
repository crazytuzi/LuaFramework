acNewYearVoApi={
	--0表示当前不可领取，1表示已经领取 2表示可领取但未领取
	flagConfig = {REWARD_DISABLE = 0,HAS_REWARD = 1,REWARD_ENABLE = 2,OVER_REWARD = 3},
	--元旦活动领取奖励的类型
	rewardType = {GOLD_REWARD = 1,FREE_REWARD = 2,CHARGE_REWARD = 3},

	needRefresh = false
}

function acNewYearVoApi:getAcVo()
	if self.vo == nil then
		self.vo = activityVoApi:getActivityVo("newyeargift")
	end
	return self.vo
end

function acNewYearVoApi:canReward()
	goldRewardFlag = self:getRewardFlag(self.rewardType.GOLD_REWARD)
	freeRewardFlag = self:getRewardFlag(self.rewardType.FREE_REWARD)
	chargeRewardFlag = self:getRewardFlag(self.rewardType.CHARGE_REWARD)
	if goldRewardFlag == self.flagConfig.REWARD_ENABLE
		or freeRewardFlag == self.flagConfig.REWARD_ENABLE
		or chargeRewardFlag == self.flagConfig.REWARD_ENABLE then

		return true
	end

	return false
end

function acNewYearVoApi:getTimeStr()
	local vo = self:getAcVo()
	local timeStr = activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acNewYearVoApi:getPackageRewardTimeStr()
	local vo = self:getAcVo()
	if vo then
		return G_getDataTimeStr(vo.rewardBeginTime,true,false) .. "—" .. G_getDataTimeStr(vo.rewardEndTime,true,false)
	end
	return nil
end

function acNewYearVoApi:getCurChargeGold()
	local goldCount = 0
	local vo = self:getAcVo()
	if vo then
		if vo.curChargeGold >= vo.goldCost then
			goldCount = vo.goldCost
		else
			goldCount = vo.curChargeGold
		end
	end
	return goldCount
end

function acNewYearVoApi:getCostGold()
	local vo = self:getAcVo()
	if vo then
		return vo.goldCost
	end
	return 0
end

function acNewYearVoApi:getGiveGemsCount()
	local vo = self:getAcVo()
	if vo then
		return vo.giveCount
	end
	return 0
end

function acNewYearVoApi:getAddRate()
	local vo = self:getAcVo()
	if vo then
		return vo.addRate * 100
	end
	return 0
end

--获取升级后获得的统率书个数
function acNewYearVoApi:getAddCommandBook()
	local upRewards = self:getUpRewards()
	if upRewards and upRewards.p then
		if upRewards.p[1] then
			return upRewards.p[1].p20
		end
	end
	return 0
end

function acNewYearVoApi:getFreeRewards()
	local acVo = self:getAcVo()
	if acVo and acVo.packageRewards and acVo.packageRewards[1] and acVo.packageRewards[1].r then
		return acVo.packageRewards[1].r
	end
end

function acNewYearVoApi:getChargeRewards()
	local acVo = self:getAcVo()
	if acVo and acVo.packageRewards and acVo.packageRewards[2] and acVo.packageRewards[2].r then
		return acVo.packageRewards[2].r
	end
end

function acNewYearVoApi:getChargeRewardsCost()
	local cost = 0
	local acVo = self:getAcVo()
	if acVo and acVo.packageRewards and acVo.packageRewards[2] and acVo.packageRewards[2].gems then
		cost = acVo.packageRewards[2].gems
	end
	return cost
end

function acNewYearVoApi:getUpRewards()
	local acVo = self:getAcVo()
	if acVo and acVo.upRewards and acVo.upRewards.r then
		return acVo.upRewards.r
	end
end

function acNewYearVoApi:getRewardFlag(rewardType)
	local acVo = self:getAcVo()
	local curTime = base.serverTime
	local curFlag = 0
	if acVo and acVo.rewardFlag then
		if rewardType == self.rewardType.GOLD_REWARD then
			if acVo.rewardFlag.goldFlag == self.flagConfig.HAS_REWARD then
				print("acNewYearApi ===== the gold reward has received!")
			elseif curTime >= acVo.st and curTime <= acVo.acEt then
				if acVo.curChargeGold >= acVo.goldCost then
					acVo.rewardFlag.goldFlag = self.flagConfig.REWARD_ENABLE
				else
					acVo.rewardFlag.goldFlag = self.flagConfig.REWARD_DISABLE
				end
			else
				acVo.rewardFlag.goldFlag = self.flagConfig.REWARD_DISABLE
			end
			curFlag = acVo.rewardFlag.goldFlag
		elseif rewardType == self.rewardType.FREE_REWARD then
			if curTime < acVo.rewardBeginTime then
				acVo.rewardFlag.freeRewardFlag = self.flagConfig.REWARD_DISABLE
				print("curTime ===== ",curTime)	
				print("rewardBeginTime ===== ",acVo.rewardBeginTime)		
				print("acNewYearVoApi ===== the free package reward received disable")	
			elseif acVo.rewardFlag.freeRewardFlag == self.flagConfig.HAS_REWARD then
				print("acNewYearVoApi ===== the free package reward has received!")
			elseif curTime > acVo.rewardEndTime then
				acVo.rewardFlag.freeRewardFlag = self.flagConfig.OVER_REWARD
			elseif curTime >= acVo.rewardBeginTime and curTime <= acVo.rewardEndTime then
				acVo.rewardFlag.freeRewardFlag = self.flagConfig.REWARD_ENABLE
			end
			curFlag = acVo.rewardFlag.freeRewardFlag
		elseif rewardType == self.rewardType.CHARGE_REWARD then
			if curTime < acVo.rewardBeginTime then 
				acVo.rewardFlag.chargeRewardFlag = self.flagConfig.REWARD_DISABLE			
			elseif acVo.rewardFlag.chargeRewardFlag == self.flagConfig.HAS_REWARD then
				print("acNewYearVoApi ===== the charge package reward has received!")	
			elseif curTime > acVo.rewardEndTime then
				acVo.rewardFlag.chargeRewardFlag = self.flagConfig.OVER_REWARD			
			elseif curTime >= acVo.rewardBeginTime and curTime <= acVo.rewardEndTime then
				acVo.rewardFlag.chargeRewardFlag = self.flagConfig.REWARD_ENABLE	
			end
			curFlag = acVo.rewardFlag.chargeRewardFlag
		end
	end
	return curFlag
end

function acNewYearVoApi:updateData(data)
	local acVo = self:getAcVo()
	if acVo then
		acVo:updateSpecialData(data)
	end
end

function acNewYearVoApi:isGemsEnough()
	local isEnough = false
	if playerVoApi then
		local curGems = playerVoApi:getGems()
		if curGems >= self:getChargeRewardsCost() then
			isEnough = true
		end
	end
	return isEnough
end

function acNewYearVoApi:onChargeGoldChanged(addGold)
	local acVo = self:getAcVo()
	if acVo then
		acVo.curChargeGold = acVo.curChargeGold + addGold
		print("current charge gold has changed!!! ==== ".. addGold)
		self.needRefresh = true
	end
end

--判断是否在活动期间
function acNewYearVoApi:getTroopsConfig()
	local isAtPeroid = false
	local troopCount = 0
	local addPercent = 0
	local acVo = self:getAcVo()
	if acVo then
		if base.serverTime >= acVo.st and base.serverTime <= acVo.acEt then
			isAtPeroid = true
			troopCount = self:getAddCommandBook()
			addPercent = acVo.addRate
		end
	end
	return isAtPeroid, troopCount, addPercent
end

function acNewYearVoApi:cancelRefresh()
	self.needRefresh = false
end

function acNewYearVoApi:hasFirstRecharge()
	local hasCharge = false
	local vo = activityVoApi:getActivityVo("firstRecharge")
	if vo == nil then
		hasCharge = true
		print("首冲活动未开启")
	elseif acFirstRechargeVoApi:canReward() == true then
		hasCharge = true
		print("首冲活动开启，并首冲完毕")
	end
	return hasCharge
end

function acNewYearVoApi:clearAll()
	-- flagConfig = nil
	-- rewardType = nil
	needRefresh = false
	self.vo = nil
end