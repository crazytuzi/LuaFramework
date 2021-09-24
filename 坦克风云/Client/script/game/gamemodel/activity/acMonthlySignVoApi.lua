--月度签到
acMonthlySignVoApi = {
	--充值签到状态（3已领奖   2已充值   1未充值   0未开启 -1已结束）
	payStateHadReward = 3,--已领奖
	payStateHadRecharge = 2,--已充值，未领奖
	payStateNotRecharge = 1,--已开启，未充值
	payStateNotOpen = 0,--未开启
	payStateEnd = -1,--时间已过，但是未充值

	-- 免费签到状态（2已领奖   1未领奖   0未开启 -1已结束）
	freeStateHadReward = 2,--已领奖
	freeStateNoReward = 1,--未领奖
	freeStateNotOpen = 0,--未开启
	freeStateEnd = -1,--时间已过
}

function acMonthlySignVoApi:getAcVo()
	return activityVoApi:getActivityVo("monthlysign")
end

function acMonthlySignVoApi:getFreeState()
	local acVo = self:getAcVo()
	if acVo and acVo.freeState then
		return acVo.freeState
	end
	return {}
end

--得到免费签到总天数
function acMonthlySignVoApi:getFreeTotalSign()
	local freeState = self:getFreeState()
	local num = 0
	if freeState then
		for k,v in pairs(freeState) do
			if v and tonumber(v) > 0 then
				num = num + 1
			end
		end
	end
	return num
end

function acMonthlySignVoApi:getPayState()
	local acVo = self:getAcVo()
	if acVo and acVo.payState then
		return acVo.payState
	end
	return {}
end

function acMonthlySignVoApi:getFreeCfg()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.freereward or {}
	end
	return {}
end

function acMonthlySignVoApi:getFreeCfgByIndex(index)
	local freeCfg = self:getFreeCfg()
	return freeCfg[index]
end

function acMonthlySignVoApi:getPayCfg()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.payreward or {}
	end
	return {}
end

function acMonthlySignVoApi:getPayCfgByIndex(index)
	local payCfg = self:getPayCfg()
	return payCfg[index]
end

function acMonthlySignVoApi:getVersion( )
	local  acVo = self:getAcVo()
	if acVo then
		return acVo.version
	end
	return nil
end

function acMonthlySignVoApi:getCurrentDate()
	local date=G_getDate(base.serverTime)
	return date.month,date.day
end

--当前是活动第几天
function acMonthlySignVoApi:getCurrentDay()
	local acVo=self:getAcVo()
	if(acVo)then
		local firstDayTs=G_getWeeTs(acVo.st)
		return math.ceil((base.serverTime - firstDayTs)/86400)
	end
	return 0
end
-----------------------------------------领奖状态判断----------------------------------------
function acMonthlySignVoApi:canReward()
	if self:checkIfCanGetFreeReward() == true or self:checkIfCanGetPayReward() == true then
		return true
	end
	return false
end


-- 当前是否有可以领取的免费签到奖励
function acMonthlySignVoApi:checkIfCanGetFreeReward()
	local curDay=self:getCurrentDay()
	local state=self:getFreeRewardState(curDay)
	if(state==self.freeStateNoReward)then
		return true
	else
		return false
	end
end

-- 某天免费签到领奖状态
function acMonthlySignVoApi:getFreeRewardState(day)
	local had = false
	local freeState = self:getFreeState()
	for k,v in pairs(freeState) do
		if tonumber(v) == tonumber(day) then
		   had = true
		   break
		end
	end
	local state
	if(had)then
		state=self.freeStateHadReward
	else
		curDay=self:getCurrentDay()
		if(day==curDay)then
			state=self.freeStateNoReward
		elseif(day<curDay)then
			state=self.freeStateEnd
		else
			state=self.freeStateNotOpen
		end
	end
	return state
end

-- 当前是否有可以领取的充值签到奖励
function acMonthlySignVoApi:checkIfCanGetPayReward()
	local curDay=self:getCurrentDay()
	for i=1,curDay do
		local state=self:getPayRewardState(i)
		if(state==self.payStateHadRecharge)then
			return true
		end
	end
	return false
end

-- 某天充值签到领奖状态(领奖条件：时间到+已充值)
function acMonthlySignVoApi:getPayRewardState(day)
	local state = self.payStateNotOpen
	local payState = self:getPayState()
	local saveState=payState[day]
	local curDay=self:getCurrentDay()
	local state
	if(saveState==nil)then
		if(day==curDay)then
			state=self.payStateNotRecharge
		elseif(day<curDay)then
			state=self.payStateEnd
		else
			state=self.payStateNotOpen
		end
	else
		if(day==curDay)then
			state=saveState
		elseif(day>curDay)then
			state=self.payStateNotOpen
		else
			if(saveState==self.payStateHadRecharge or saveState==self.payStateHadReward)then
				state=saveState
			else
				state=self.payStateEnd
			end
		end
	end
	return state
end

-- 得到当天充值签到的配置中表示节日的字段
function acMonthlySignVoApi:getCurrentFestivalPayCfg()
	local currentDayIndex,currentDayCfg = self:getCurrentPayCfg()
	if currentDayCfg and currentDayCfg.sf then
		return currentDayCfg.sf
	end
	return 0
end

-- 得到当天充值的配置
function acMonthlySignVoApi:getCurrentPayCfg()
	local curDay=self:getCurrentDay()
	local payCfg = self:getPayCfg()
	if payCfg then
		return payCfg[curDay]
	end
end

-- 得到当天签到的配置
function acMonthlySignVoApi:getCurrentFreeCfg()
	local curDay=self:getCurrentDay()
	local freeCfg = self:getFreeCfg()
	if(freeCfg)then
		return freeCfg[curDay]
	end
end

-- 领奖后更新状态数据(领奖后活动数据后台会一起发送给前台，所以这里不需要前台重新设置数据)
function acMonthlySignVoApi:afterGetReward()
	local acVo = self:getAcVo()
	activityVoApi:updateShowState(acVo)-- 若领奖状态发生了改变重置领奖状态并更新UI
	acVo.stateChanged = true-- 强制更新UI
end

function acMonthlySignVoApi:afterUpdate()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.refreshTs = G_getWeeTs(base.serverTime) + 86400--玩家在线时间跨多天
	end
end

-- 从前一天过度到后一天时重新获取数据
function acMonthlySignVoApi:refresh()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		activityVoApi:updateShowState(acVo) -- 若领奖状态发生了改变重置领奖状态并更新UI
		acVo.stateChanged = true-- 强制更新UI
	end
end