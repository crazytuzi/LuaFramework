acUserFundVoApi = {}

function acUserFundVoApi:getAcVo()
	return activityVoApi:getActivityVo("userFund")
end

function acUserFundVoApi:getAcCfg()
	local acVo=self:getAcVo()
	local acCfg={}
	if acVo then
		acCfg.reward=acVo.reward
		acCfg.chargeday=acVo.chargeday
		acCfg.cost=acVo.cost
		acCfg.extra=acVo.extra
	end
	return acCfg
end
function acUserFundVoApi:getTodayMoney()
	local acVo = self:getAcVo()
	-- if acVo ~= nil and G_isToday(acVo.t) == true then
	-- 	return tonumber(acVo.v)
	-- end
	if acVo ~= nil and tonumber(acVo.v) then
		return tonumber(acVo.v)
	end
	return 0
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acUserFundVoApi:addMoney(money)
	local acVo = self:getAcVo()
	local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
	if acVo and acVo.v then
		if ifInRechargeDay==true then
			acVo.v = acVo.v + money
			activityVoApi:updateShowState(acVo)
			acVo.stateChanged = true -- 强制更新数据
		end
	end
end

function acUserFundVoApi:getMaxNeedMoney()
	local acCfg = self:getAcCfg()
	if acCfg.cost then
		local rewardLen = SizeOfTable(acCfg.cost)
		if rewardLen ~= nil and rewardLen > 0 then
			return self:getNeedMoneyById(rewardLen)
		end
	end
	return 0
end


function acUserFundVoApi:canRewardRecharge()
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

function acUserFundVoApi:getNeedMoneyById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.cost ~= nil and acCfg.cost[id] then
		return tonumber(acCfg.cost[id])
	end
	return 0
end

function acUserFundVoApi:checkIfHadRewardById(id)
	local acVo = self:getAcVo()
	-- if acVo ~= nil and acVo.c ~= nil and acVo.c >= id and G_isToday(acVo.t) == true then
	if acVo ~= nil and acVo.c ~= nil and acVo.c >= id then
		return true
	end
	return false
end

function acUserFundVoApi:checkIfCanRewardById(id)
	local needMoney = self:getNeedMoneyById(id)
	local money = self:getTodayMoney()
	if needMoney ~= nil and money >= needMoney then
		local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
		if ifInRechargeDay==true then
			return true
		end
	end
	return false
end

-- 得到当前可以领取的奖励
function acUserFundVoApi:getCurrentCanGetReward()
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.reward ~= nil then
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

function acUserFundVoApi:getRewardById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil and acCfg.reward ~= nil and acCfg.reward[id] then
		return acCfg.reward[id]
	end
	return nil
end

function acUserFundVoApi:afterGetReward()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if acVo.c == nil then
			acVo.c = 1
		else
			acVo.c = acVo.c + 1
		end
	end
	activityVoApi:updateShowState(acVo)
end

-- 从前一天过度到后一天时重新获取数据
-- function acUserFundVoApi:refresh()
-- 	local acVo = self:getAcVo()
-- 	if acVo ~= nil then
-- 		acVo.t = G_getWeeTs(base.serverTime)
-- 		acVo.c = 0
-- 		acVo.v = 0
-- 		self.refreshTs = acVo.t + 86400
-- 		activityVoApi:updateShowState(acVo)
-- 		acVo.stateChanged = true
-- 	end
-- end


function acUserFundVoApi:getAcDays()
	local acVo = self:getAcVo()
	local zeroSt=G_getWeeTs(acVo.st)
	local zeroEt=G_getWeeTs(acVo.et)
	local currentWeeTs=G_getWeeTs(base.serverTime)
	local totalDays=math.ceil((zeroEt-zeroSt)/(3600*24))+1
	local chargeDays=acVo.chargeday
	local rewardDays=totalDays-chargeDays
	local leftDays=math.ceil((zeroEt-currentWeeTs)/(3600*24))+1
	return chargeDays,rewardDays,totalDays,leftDays
end

function acUserFundVoApi:getIfInDays()
	local acVo = self:getAcVo()
	local zeroSt=G_getWeeTs(acVo.st)
	local zeroEt=G_getWeeTs(acVo.et)
	local currentWeeTs=G_getWeeTs(base.serverTime)
    local chargeDays,rewardDays,totalDays=acUserFundVoApi:getAcDays()

    local ifInRechargeDay=false
    local ifInRewardDay=false
    if activityVoApi:isStart(acVo) then
	    if currentWeeTs<(zeroSt+(chargeDays*3600*24)) then
	    	ifInRechargeDay=true
	    end
	    if currentWeeTs>=(zeroSt+(chargeDays*3600*24)) then
	    	ifInRewardDay=true
	    end
	end
	return ifInRechargeDay,ifInRewardDay
end

function acUserFundVoApi:getSampleNum()
	local acVo = self:getAcVo()
	local costNum=0
	local sampleNum=0
	if acVo and acVo.cost then
		local num=math.ceil(SizeOfTable(acVo.cost)/2)+1
		if num>SizeOfTable(acVo.cost) then
			num=SizeOfTable(acVo.cost)
		end
		sampleNum=math.floor(((acVo.cost[num]-acVo.cost[num-1])/2+acVo.cost[num-1])/1000)*1000
		for k,v in pairs(acVo.cost) do
			if v<=sampleNum then
				costNum=v
			end
		end
	end
	return sampleNum,costNum
end

function acUserFundVoApi:getTimeStr()
	local timeStr=""
	local acVo = self:getAcVo()
	if acVo then
		local ifInRechargeDay,ifInRewardDay=self:getIfInDays()
    	local chargeDays,rewardDays,totalDays,leftDays=self:getAcDays()
    	if ifInRechargeDay then
    		local endTs=G_getWeeTs(acVo.st)+chargeDays*(24*3600)-1
        	timeStr=activityVoApi:getActivityTimeStr(acVo.st,endTs)
    	elseif ifInRewardDay then
    		local startTs=G_getWeeTs(acVo.st)+chargeDays*(24*3600)
        	timeStr=activityVoApi:getActivityTimeStr(startTs,acVo.acEt)
    	end
    end
	return timeStr
end

function acUserFundVoApi:getRewardNum()
	local acVo = self:getAcVo()
	if acVo.t and acVo.t>0 then
		if acVo.extra and acVo.extra[acVo.t] and tonumber(acVo.extra[acVo.t]) then
			return tonumber(acVo.extra[acVo.t])
		end
	end
	return 0
end

function acUserFundVoApi:canRewardExtra()
	local acVo = self:getAcVo()
	if activityVoApi:isStart(acVo) then
		local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
		if ifInRewardDay==true then
			if acUserFundVoApi:getRewardNum()>0 then
				local lastRewardTs=acVo.rt
				if G_isToday(lastRewardTs)==false then
					return true
				end
			end
		end
	end
	return false
end

function acUserFundVoApi:afterGetRewardExtra(ts)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.rt=ts
		activityVoApi:updateShowState(acVo)
	end	
end

function acUserFundVoApi:canReward()
	if self:canRewardRecharge()==true or self:canRewardExtra()==true then
		return true
	end
	return false
end
