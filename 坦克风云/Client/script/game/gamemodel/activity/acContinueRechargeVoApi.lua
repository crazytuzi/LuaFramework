acContinueRechargeVoApi = {}

function acContinueRechargeVoApi:getAcVo()
	return activityVoApi:getActivityVo("continueRecharge")
end

-- 得到活动总天数
function acContinueRechargeVoApi:getTotalDays()
	-- return 7 -- todo 测试使用
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return math.floor((acVo.et - acVo.st)/86400) + 1
	end
	return 0
end
function acContinueRechargeVoApi:getVersion( )
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return nil
end
-- 获得第day天需要的充值数
function acContinueRechargeVoApi:getNeedMoneyByDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return tonumber(acVo.dayCfg)
	end
	return 999999
end

-- 获得第day天修改记录需要的充值数
function acContinueRechargeVoApi:getReviseNeedMoneyByDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.reviseCfg
	end
	return 999999
end

-- 最终大奖
function acContinueRechargeVoApi:getBigReward()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.bigReward ~= nil then
		for k,v in pairs(acVo.bigReward) do
			return k,v
		end
	end
	return nil,0
end

-- 最终大奖的价值
function acContinueRechargeVoApi:getBigRewardValue()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.bRValue
	end
	return 0
end

-- 得到第day天的已充值金额
function acContinueRechargeVoApi:getRechargeByDay(day)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.v ~= nil and type(acVo.v) == "table" and day <= SizeOfTable(acVo.v) then
		if acVo.v[day] ~= nil and tonumber(acVo.v[day]) > 0 then
			return tonumber(acVo.v[day])
		else
			return 0
		end
	end
	
	return 0
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acContinueRechargeVoApi:updateAfterRecharge(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		local day = math.floor((G_getWeeTs(base.serverTime) - G_getWeeTs(acVo.st))/86400) + 1 -- 当前是活动的第几天
		local recharge = self:getRechargeByDay(day)
		print("当前是第"..day.."天充值，之前已充值金额为"..recharge)
		if recharge > 0 then
			acVo.v[day] = acVo.v[day] + money
		else
			if type(acVo.v) ~= "table" then
				acVo.v = {}
				for i=1,day do
					acVo.v[i] = 0
				end
			end
			acVo.v[day] = money
		end

		for k,v in pairs(acVo.v) do
			print("k: ", k)
			print("v: ", v)
		end
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

-- 得到当前时间是第几天
function acContinueRechargeVoApi:getCurrentDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		local day = math.floor((G_getWeeTs(base.serverTime) - G_getWeeTs(acVo.st))/86400) + 1 -- 当前是活动的第几天
		return day
	end
	return 0
end
-- 是否已领取最终大奖
function acContinueRechargeVoApi:checkIfHadReward()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.c ~= nil and acVo.c == 1 then
		return true
	end
	return false
end

function acContinueRechargeVoApi:checkIfCanReward()
	local rewardLen = self:getTotalDays()
	if rewardLen ~= nil and rewardLen > 0 then
		for i=1,rewardLen do
			if tonumber(self:getRechargeByDay(i)) < tonumber(self:getNeedMoneyByDay(i)) then
				return false
			end
		end
		return true
	end
	return false
end

function acContinueRechargeVoApi:canReward()
    if self:checkIfHadReward() == false and self:checkIfCanReward() == true then
    	return true
    end
    return false
end


-- 更新充值记录
function acContinueRechargeVoApi:updateState()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		activityVoApi:updateShowState(acVo)
	    acVo.stateChanged = true -- 强制更新数据
	end
end

function acContinueRechargeVoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.c = 1
	end
	activityVoApi:updateShowState(acVo)
end
