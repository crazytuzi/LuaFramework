acDayRechargeVoApi = {}

function acDayRechargeVoApi:getAcVo()
	return activityVoApi:getActivityVo("dayRecharge")
end

function acDayRechargeVoApi:getAcCfg()
    local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.rewardCfg
	end
	return nil
end

function acDayRechargeVoApi:getVersion( )
	local  acVo = self:getAcVo()
	if acVo then
		return acVo.version
	end
	return nil
end

function acDayRechargeVoApi:getTodayMoney()
	local acVo = self:getAcVo()
	if acVo ~= nil and G_isToday(acVo.t) == true then
		return tonumber(acVo.v)
	end
	return 0
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acDayRechargeVoApi:addTodayMoney(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if G_isToday(acVo.t) == true then
            acVo.v = acVo.v + money
        else
        	acVo.v = money
        	acVo.t = base.serverTime
			acVo.c = 0
			self.refreshTs = G_getWeeTs(base.serverTime) + 86400
		end
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

function acDayRechargeVoApi:getMaxNeedMoney()
	local acCfg = self:getAcCfg()
	local rewardLen = SizeOfTable(acCfg.cost)
	if rewardLen ~= nil and rewardLen > 0 then
		return self:getNeedMoneyById(rewardLen)
	end
end


function acDayRechargeVoApi:canReward()
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

function acDayRechargeVoApi:getNeedMoneyById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.cost ~= nil then
		return tonumber(acCfg.cost[id])
	end
	return 0
end

function acDayRechargeVoApi:checkIfHadRewardById(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.c ~= nil and acVo.c >= id and G_isToday(acVo.t) == true then
		return true
	end
	return false
end

function acDayRechargeVoApi:checkIfCanRewardById(id)
	local needMoney = self:getNeedMoneyById(id)
	local money = self:getTodayMoney()
	if needMoney ~= nil and money >= needMoney then
		return true
	end
	return false
end

-- 得到当前可以领取的奖励
function acDayRechargeVoApi:getCurrentCanGetReward()
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

function acDayRechargeVoApi:getRewardById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.reward ~= nil then
		return acCfg.reward[id]
	end
	return nil
end

function acDayRechargeVoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and G_isToday(acVo.t) == true then
		if acVo.c == nil then
			acVo.c = 1
		else
			acVo.c = acVo.c + 1
		end
	end
	activityVoApi:updateShowState(acVo)
end

-- 从前一天过度到后一天时重新获取数据
function acDayRechargeVoApi:refresh()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.t = G_getWeeTs(base.serverTime)
		acVo.c = 0
		acVo.v = 0
		self.refreshTs = acVo.t + 86400
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true
	end
	
end