acDailyRechargeByNewGuiderVoApi = {}

function acDailyRechargeByNewGuiderVoApi:getAcVo()
	return activityVoApi:getActivityVo("mrcz")
end

function acDailyRechargeByNewGuiderVoApi:getAcCfg()
    local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.rewardCfg
	end
	return nil
end

function acDailyRechargeByNewGuiderVoApi:getVersion( )
	local  acVo = self:getAcVo()
	if acVo then
		return acVo.version
	end
	return nil
end

function acDailyRechargeByNewGuiderVoApi:getFlickCfg( )
	local acVo = self:getAcVo()
	if acVo then
		return acVo.flickCfg
	end
	print("errror~~~~ in getFlickCfg")
	return nil
end

function acDailyRechargeByNewGuiderVoApi:getTodayMoney()
	local acVo = self:getAcVo()
	if acVo ~= nil and G_isToday(acVo.t) == true then
		return tonumber(acVo.v)
	end
	return 0
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acDailyRechargeByNewGuiderVoApi:addTodayMoney(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if G_isToday(acVo.t) == true then
            acVo.v = acVo.v + money
            acVo.refreshTs = G_getWeeTs(base.serverTime) + 86400
            self.refreshTs = G_getWeeTs(base.serverTime) + 86400
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

function acDailyRechargeByNewGuiderVoApi:getMaxNeedMoney()
	local acCfg = self:getAcCfg()
	local rewardLen = SizeOfTable(acCfg.cost)
	if rewardLen ~= nil and rewardLen > 0 then
		return self:getNeedMoneyById(rewardLen)
	end
end


function acDailyRechargeByNewGuiderVoApi:canReward()
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

function acDailyRechargeByNewGuiderVoApi:getNeedMoneyById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.cost ~= nil then
		return tonumber(acCfg.cost[id])
	end
	return 0
end

function acDailyRechargeByNewGuiderVoApi:checkIfHadRewardById(id)
	local acVo = self:getAcVo()
	-- print("--id--->",id)
	G_dayin(acVo.r)
	if acVo ~= nil and SizeOfTable(acVo.r) > 0 and G_isToday(acVo.t) == true then
		for k,v in pairs(acVo.r) do
			-- print("v----acVo.r--->",v,id)
			if v == id then
				return true
			end
		end
		
	end
	return false
end

function acDailyRechargeByNewGuiderVoApi:checkIfCanRewardById(id)
	local needMoney = self:getNeedMoneyById(id)
	local money = self:getTodayMoney()
	-- print("money---needMoney--->",money,needMoney)
	if needMoney ~= nil and money >= needMoney then
		return true
	end
	return false
end

-- 得到当前可以领取的奖励
function acDailyRechargeByNewGuiderVoApi:getCurrentCanGetReward()
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

function acDailyRechargeByNewGuiderVoApi:getRewardById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.reward ~= nil then
		return acCfg.reward[id]
	end
	return nil
end

function acDailyRechargeByNewGuiderVoApi:afterGetReward(id,newR)
	local acVo = self:getAcVo()
	if acVo ~= nil and G_isToday(acVo.t) == true then
		acVo.r = newR
	end
	activityVoApi:updateShowState(acVo)
end

-- 从前一天过度到后一天时重新获取数据
function acDailyRechargeByNewGuiderVoApi:refresh()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		-- print("in voApi:refresh~~~~~~")
		acVo.t = G_getWeeTs(base.serverTime)
		acVo.c = 0
		acVo.v = 0
		acVo.r = {}
		self.refreshTs = acVo.t + 86400
		activityVoApi:updateShowState(acVo)
		-- print("self.refreshTs-----acVo.t----base.serverTime----->",self.refreshTs,acVo.t,base.serverTime)
		acVo.stateChanged = true
	end
	
end