acContinueRechargeNewGuidVoApi = {}

function acContinueRechargeNewGuidVoApi:getAcVo()
	return activityVoApi:getActivityVo("lxcz")
end

-- 得到活动总天数
function acContinueRechargeNewGuidVoApi:getTotalDays()
	-- return 7 -- todo 测试使用
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return math.floor((acVo.et - acVo.st)/86400)
	end
	return 0
end
function acContinueRechargeNewGuidVoApi:getVersion( )
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return nil
end
-- 获得每日需要的充值金币数(因为标题描述原因，默认取的第一天的金币数)
function acContinueRechargeNewGuidVoApi:getNeedMoneyByDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return tonumber(acVo.dayCfg)
	end
	return 999999
end

function acContinueRechargeNewGuidVoApi:getNeedDay( )
	local acVo = self:getAcVo()
	if acVo and acVo.needDay then
		return acVo.needDay
	end
	return 7
end

function acContinueRechargeNewGuidVoApi:getFinal( )
	local acVo = self:getAcVo()
	if acVo and acVo.final then
		local formatBigAward = FormatItem(acVo.final)

		return acVo.final,formatBigAward
	end
	return nil
end

function acContinueRechargeNewGuidVoApi:bigAwardHad( )
	local acVo = self:getAcVo()
	if acVo and acVo.bigAwardHad then
		return acVo.bigAwardHad
	end
	return 0
end

function acContinueRechargeNewGuidVoApi:getContinueRechargedAward(idx)
	local acVo = self:getAcVo()
	if acVo and acVo.continue then
		-- print("idx------->",idx)
		local formatContinue = FormatItem(acVo.continue[idx]["award"],nil,true)
		return formatContinue,acVo.continue[idx]["needMoney"]
	end
	-- print("error~~~~~~~~~~~~~~~ in getContinueRechargedAward()")
	return nil
end

function acContinueRechargeNewGuidVoApi:getRechargedTb( )
	local acVo = self:getAcVo()
	if acVo and acVo.rechargedTb and type(acVo.rechargedTb) =="table" then
		local rechargedDays = 0
		local rechargeGemsLower = self:getNeedMoneyByDay()
		local isAgain = false
		local isAgainLargeDay = false
		local largeDay = 0
		local CurrentDay = self:getCurrentDay()
		if SizeOfTable(acVo.rechargedTb) > 0 then
			for k,v in pairs(acVo.rechargedTb) do
				-- print("k---v--->",k,v,isAgain,largeDay)
				if k <= CurrentDay then
					if v >= rechargeGemsLower then
						rechargedDays = rechargedDays +1
					else
						if k == CurrentDay then
						else
							rechargedDays = 0
						end
					end
				end

				if v >= rechargeGemsLower then
					-- rechargedDays = rechargedDays +1
					if isAgain ==true then
						-- rechargedDays = 0
						isAgain = false
						if isAgainLargeDay then
							largeDay = 0
							isAgainLargeDay = false
						end
					end
					
					largeDay = largeDay+1
				else 
					isAgain =true
					if largeDay <4 then
						isAgainLargeDay = true
					end
				end
			end
		end
		-- print("rechargedDays----->",rechargedDays)
		return acVo.rechargedTb,rechargedDays,largeDay
	end
	-- print("no rechargedTb~~~~~~~!!!!!~~~~~~~~")
	return nil,0,0
end

function acContinueRechargeNewGuidVoApi:getAwardTbInDays()
	local acVo = self:getAcVo()
	if acVo and acVo.getAwardTb then
		local awardDaysTb = {}
		for k,v in pairs(acVo.getAwardTb) do
			awardDaysTb[v] = 1
		end
		return awardDaysTb,acVo.getAwardTb
	end
	-- print("tb is nil ~~~~~~~~~~~~ in getAwardTb()")
	return nil
end
---------------------------------------------------------------------------------------------------
-- 获得第day天修改记录需要的充值数
function acContinueRechargeNewGuidVoApi:getReviseNeedMoneyByDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.reviseCfg
	end
	return 999999
end

-- 最终大奖
function acContinueRechargeNewGuidVoApi:getBigReward()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.final ~= nil then
		for k,v in pairs(acVo.final) do
			return k,v
		end
	end
	return nil,0
end

-- 最终大奖的价值
function acContinueRechargeNewGuidVoApi:getBigRewardValue()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.bRValue
	end
	return 0
end

-- 得到第day天的已充值金额
function acContinueRechargeNewGuidVoApi:getRechargeByDay(day)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.rechargedTb ~= nil and type(acVo.rechargedTb) == "table" and day <= SizeOfTable(acVo.rechargedTb) then
		if acVo.rechargedTb[day] ~= nil and tonumber(acVo.rechargedTb[day]) > 0 then
			return tonumber(acVo.rechargedTb[day])
		else
			return 0
		end
	end
	
	return 0
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acContinueRechargeNewGuidVoApi:updateAfterRecharge(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		local day = math.floor((G_getWeeTs(base.serverTime) - G_getWeeTs(acVo.st))/86400) + 1 -- 当前是活动的第几天
		local recharge = self:getRechargeByDay(day)
		print("当前是第"..day.."天充值，之前已充值金额为"..recharge)
		if recharge > 0 then
			acVo.rechargedTb[day] = acVo.rechargedTb[day] + money
		else
			if type(acVo.rechargedTb) ~= "table" then
				acVo.rechargedTb = {}
				for i=1,day do
					acVo.rechargedTb[i] = 0
				end
			end
			acVo.rechargedTb[day] = money
		end

		-- for k,v in pairs(acVo.rechargedTb) do
		-- 	print("k: ", k)
		-- 	print("v: ", v)
		-- end
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

-- 得到当前时间是第几天
function acContinueRechargeNewGuidVoApi:getCurrentDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		local day = math.floor((G_getWeeTs(base.serverTime) - G_getWeeTs(acVo.st))/86400) + 1 -- 当前是活动的第几天
		return day
	end
	return 0
end
-- 是否已领取最终大奖
function acContinueRechargeNewGuidVoApi:checkIfHadReward()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.bigAwardHad ~= nil and acVo.bigAwardHad == 1 then
		return true
	end
	return false
end

function acContinueRechargeNewGuidVoApi:checkIfCanReward()
	local acVo = self:getAcVo()
	local CurrentDay = self:getCurrentDay()
	local isGetTb= self:getAwardTbInDays()
	if acVo.allDay then
		for i=1,acVo.allDay do
			if tonumber(self:getRechargeByDay(i)) >= tonumber(self:getNeedMoneyByDay()) and (isGetTb == nil or isGetTb[i] == nil or isGetTb[i] == 0 ) then
				return true
			end
		end
	end
	return false
end
function acContinueRechargeNewGuidVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acContinueRechargeNewGuidVoApi:canReward()
	local rechargeDayTb,days = self:getRechargedTb( )
    if (self:checkIfHadReward() == false and days and days >= 4) or self:checkIfCanReward() == true then
    	return true
    end
    return false
end


-- 更新充值记录
function acContinueRechargeNewGuidVoApi:updateState()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		activityVoApi:updateShowState(acVo)
	    acVo.stateChanged = true -- 强制更新数据
	end
end

function acContinueRechargeNewGuidVoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	-- if acVo ~= nil then
	-- 	acVo.c = 1
	-- end
	activityVoApi:updateShowState(acVo)
end
