acTotalRecharge2VoApi = {}

function acTotalRecharge2VoApi:getAcVo()
	return activityVoApi:getActivityVo("totalRecharge2")
end

function acTotalRecharge2VoApi:getAcRewardCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.reward ~= nil then
		return acVo.reward
	end
	return {}
end

function acTotalRecharge2VoApi:getAcCostCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.cost ~= nil then
		return acVo.cost
	end
	return {}
end


function acTotalRecharge2VoApi:getTotalMoney()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return tonumber(acVo.v)
	end
	return 0
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acTotalRecharge2VoApi:addTotalMoney(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.v = acVo.v + money
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

function acTotalRecharge2VoApi:getMaxNeedMoney()
	local acCfg = self:getAcCostCfg()
	local rewardLen = SizeOfTable(acCfg)
	if rewardLen ~= nil and rewardLen > 0 then
		return self:getNeedMoneyById(rewardLen)
	end
end


function acTotalRecharge2VoApi:canReward()
	local acCfg = self:getAcRewardCfg()
	if acCfg ~= nil then
		local rewardLen = SizeOfTable(acCfg)
		if rewardLen ~= nil and rewardLen > 0 then
			for i=1,rewardLen do
				if self:checkIfCanRewardById(i) == true and self:checkIfHadRewardById(i) == false then
					return true
				end
			end
		end
	end	
	return false
end

function acTotalRecharge2VoApi:getNeedMoneyById(id)
	local acCfg = self:getAcCostCfg()
	if acCfg ~= nil then
		return tonumber(acCfg[id])
	end
	return 0
end

function acTotalRecharge2VoApi:checkIfHadRewardById(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.c ~= nil and acVo.c >= id then
		return true
	end
	return false
end

function acTotalRecharge2VoApi:checkIfCanRewardById(id)
	local needMoney = self:getNeedMoneyById(id)
	local money = self:getTotalMoney()
	if needMoney ~= nil and money >= needMoney then
		return true
	end
	return false
end

-- 得到当前可以领取的奖励
function acTotalRecharge2VoApi:getCurrentCanGetReward()
	local acCfg = self:getAcRewardCfg()
	if acCfg ~= nil then
		local rewardLen = SizeOfTable(acCfg)
		if rewardLen ~= nil and rewardLen > 0 then
			for i=1,rewardLen do
				if self:checkIfCanRewardById(i) == true and self:checkIfHadRewardById(i) == false then
					return self:getRewardById(i), i
				end
			end
		end
	end	
	return nil
end

function acTotalRecharge2VoApi:getRewardById(id)
	local acCfg = self:getAcRewardCfg()
	if acCfg ~= nil then
		return acCfg[id]
	end
	return nil
end

function acTotalRecharge2VoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.c = acVo.c + 1
	end
	activityVoApi:updateShowState(acVo)
	acVo.stateChanged = true
end
