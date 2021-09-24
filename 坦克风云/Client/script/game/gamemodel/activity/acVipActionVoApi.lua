acVipActionVoApi={}

function acVipActionVoApi:getAcVo()
	return activityVoApi:getActivityVo("vipAction")
end

function acVipActionVoApi:getDayRewardCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.dayRewardCfg
	end
	return nil
end

function acVipActionVoApi:getDayCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.dayCfg
	end
	return nil
end

function acVipActionVoApi:getTotalRewardCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.totalRewardCfg
	end
	return nil
end

function acVipActionVoApi:getTotalCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.totalCfg
	end
	return nil
end

-- 获取活动时间的现实格式
function acVipActionVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.et)
	return timeStr
end

--获取当日的充值金额
function acVipActionVoApi:getTodayCharge()
	local acVo = self:getAcVo()
	if acVo ~= nil and G_isToday(acVo.t) == true then
		return tonumber(acVo.todayCharge)
	end
	return 0
end

--获取累计充值金额
function acVipActionVoApi:getTotalCharge()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return tonumber(acVo.totalCharge)
	end
	return 0
end

-- 当前是否有奖励可以领取
function acVipActionVoApi:canReward()
	local vo = self:getAcVo()
	
	local dayRewardCfg = acVipActionVoApi:getDayRewardCfg()
    local dayCfg = acVipActionVoApi:getDayCfg()
    local totalRewardCfg = acVipActionVoApi:getTotalRewardCfg()
    local totalCfg = acVipActionVoApi:getTotalCfg()

	if dayRewardCfg == nil or dayCfg == nil or totalRewardCfg == nil  or totalCfg == nil then
		return false
	end

	for k,v in pairs(totalCfg) do
		if(vo.totalGet < k and vo.totalCharge>=v)then
			return true
		end
	end

	for k,v in pairs(dayCfg) do
		if(self:checkIfGetToday(k) == false and vo.todayCharge>=v)then
			return true
		end
	end
	return false
end


function acVipActionVoApi:checkIfGetToday(index)
	local vo = self:getAcVo()
	if vo ~= nil and vo.todayGet ~= nil then
		for k,v in pairs(vo.todayGet) do
			if tonumber(v) == tonumber(index) then
				return true
			end
		end
	end
	return false
end

-- needCost 需要充值的金额， isDay 是否是每日充值, index 奖励索引
function acVipActionVoApi:getRewardState(needCost, isDay, index)
	local vo = self:getAcVo()
	local state = 0 -- 不可领取
	if isDay == true then
        if vo.todayCharge>=needCost then
        	if self:checkIfGetToday(index) == false then
        		state = 1-- 可领取
        	else
        		state = 2-- 已领取
        	end
        end
	elseif isDay == false then
        if vo.totalCharge>=needCost then
        	if vo.totalGet< index then
        		state = 1-- 可领取
        	else
        		state = 2-- 已领取
        	end
        end
	end
	return state
end


-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acVipActionVoApi:addTodayMoney(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if G_isToday(acVo.t) == true then
            acVo.todayCharge = acVo.todayCharge + money
        else
        	acVo.todayCharge = money
        	acVo.t = base.serverTime
			acVo.todayGet = {}
			self.refreshTs = G_getWeeTs(base.serverTime) + 86400
		end
		acVo.totalCharge = acVo.totalCharge + money
		print("acVo.totalCharge:",acVo.totalCharge)
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end


function acVipActionVoApi:afterGetReward(isDay,index)
	local acVo = self:getAcVo()
	if acVo ~= nil  then
		if isDay == true and G_isToday(acVo.t) == true then
			if acVo.todayGet == nil then
				acVo.todayGet = {index}
			elseif self:checkIfGetToday(index) == false then
				table.insert(acVo.todayGet,index)
			end
		end 

		if isDay == false then
			acVo.totalGet = acVo.totalGet + 1
		end
	end
	activityVoApi:updateShowState(acVo)
end

-- 从前一天过度到后一天时重新获取数据
function acVipActionVoApi:refresh()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.t = G_getWeeTs(base.serverTime)
		acVo.todayGet = {}
		acVo.todayCharge = 0
		self.refreshTs = acVo.t + 86400
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true
	end
	
end
