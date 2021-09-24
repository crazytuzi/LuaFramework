acAlienbumperweekVoApi = {}

function acAlienbumperweekVoApi:getAcVo()
	return activityVoApi:getActivityVo("alienbumperweek")
end

function acAlienbumperweekVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acAlienbumperweekVoApi:canReward()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.reward then
		for i=1,#acVo.reward do
			local state = self:getRewardBtnState(i)
			if state==1 then
				return true
			end
		end
	end
	return false
end

-- 已经累计充值的金额，每日需要重置
function acAlienbumperweekVoApi:hasRechargeNum()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.v then
		return acVo.v
	end
	return 0
end

-- 获取奖励列表
function acAlienbumperweekVoApi:getRewardList()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.reward then
		return acVo.reward
	end
	return nil
end

-- 获取具体的某个档位奖励
function acAlienbumperweekVoApi:getRewardListById(id)
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.reward and acVo.reward[id] then
		return acVo.reward[id]
	end
	return nil
end

-- 获取消耗列表
function acAlienbumperweekVoApi:getCostList(index)
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.cost and acVo.cost[index] then
		return acVo.cost[index]
	end
	return nil
end

-- 上次充值的凌晨时间戳
function acAlienbumperweekVoApi:getLastRechargeWeeTs()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.c then
		return acVo.c
	end
	return nil
end

-- 上次领取奖励的时间
function acAlienbumperweekVoApi:getLastGetRewartTs()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.t then
		return acVo.t
	end
	return nil
end

-- 该活动的版本号
function acAlienbumperweekVoApi:getActivityVersion()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end
-- 该档位奖励的领取状态,0不满足条件，1可以领取，2已领取
function acAlienbumperweekVoApi:getRewardBtnState(index)
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.r then
		for i=1,#acVo.r do
			if acVo.r[i] and acVo.r[i]==index then
				return 2
			end
		end
	end
	local totalCost = self:hasRechargeNum()
	local needCost = self:getCostList(index)
	if totalCost>=needCost then
		return 1
	end
	return 0
end

-- 更改按钮状态
function acAlienbumperweekVoApi:setRewardBtnState(index)
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.r==nil then
		acVo.r={}
		acVo.r[1]=index
	elseif acVo and acVo.r~=nil then
		acVo.r[(#acVo.r+1)]=index
	end
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acAlienbumperweekVoApi:addTotalMoney(money)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.v = acVo.v + money
		acVo.c = G_getWeeTs(base.serverTime)
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

-- 设置该时间戳
function acAlienbumperweekVoApi:setLastSt()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.t then
		acVo.t=base.serverTime
	end
end

-- 领奖之后更新数据
function acAlienbumperweekVoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	if acVo then
		self:setLastSt()
		self:setRewardBtnState(id)
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true
	end
end

-- 跨天之后更新数据
function acAlienbumperweekVoApi:changeDayUpdateData()
	local acVo = self:getAcVo()
	if acVo then
		acVo.v=0
		acVo.r=nil
		acVo.stateChanged = true
	end
end


-- 资源上限加成
function acAlienbumperweekVoApi:getResRate()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.value then
		return acVo.value+1
	end
	return 1
end

-- 资源生产加成
function acAlienbumperweekVoApi:getProduceRate()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.addrate then
		return acVo.addrate+1
	end
	return 1
end

function acAlienbumperweekVoApi:getResRateStr()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.value then
		return tostring(acVo.value*100)
	end
	return ""
end

function acAlienbumperweekVoApi:getProduceRateStr()
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.addrate then
		return tostring(acVo.addrate*100)
	end
	return ""
end

function acAlienbumperweekVoApi:getIconPicById(index)
	local acVo = acAlienbumperweekVoApi:getAcVo()
	if acVo and acVo.icon and acVo.icon[index] then
		return acVo.icon[index]
	end
	return ""
end



