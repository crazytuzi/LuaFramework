acTotalRechargeVoApi = {}

function acTotalRechargeVoApi:getAcVo()
	return activityVoApi:getActivityVo("totalRecharge")
end

function acTotalRechargeVoApi:getAcCfg()
	return activityCfg["totalRecharge"]
end
function acTotalRechargeVoApi:getTotalMoney()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return tonumber(acVo.v)
	end
	return 0
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acTotalRechargeVoApi:addTotalMoney(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.v = acVo.v + money
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

function acTotalRechargeVoApi:getMaxNeedMoney()
	local acCfg = self:getAcCfg()
	local rewardLen = SizeOfTable(acCfg.cost)
	if rewardLen ~= nil and rewardLen > 0 then
		return self:getNeedMoneyById(rewardLen)
	end
end


function acTotalRechargeVoApi:canReward()
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.reward ~= nil then
		local rewardLen = SizeOfTable(acCfg.reward)
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

function acTotalRechargeVoApi:getNeedMoneyById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.cost ~= nil then
		return tonumber(acCfg.cost[id])
	end
	return 0
end

function acTotalRechargeVoApi:checkIfHadRewardById(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.c ~= nil and acVo.c >= id then
		return true
	end
	return false
end

function acTotalRechargeVoApi:checkIfCanRewardById(id)
	local needMoney = self:getNeedMoneyById(id)
	local money = self:getTotalMoney()
	if needMoney ~= nil and money >= needMoney then
		return true
	end
	return false
end

-- 得到当前可以领取的奖励
function acTotalRechargeVoApi:getCurrentCanGetReward()
	local acCfg = self:getAcCfg()
	if acCfg ~= nil then
		local rewardLen = SizeOfTable(acCfg.reward)
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

function acTotalRechargeVoApi:getRewardById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.reward ~= nil then
		return acCfg.reward[id]
	end
	return nil
end

function acTotalRechargeVoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.c = acVo.c + 1
	end
	activityVoApi:updateShowState(acVo)
	acVo.stateChanged = true
end
