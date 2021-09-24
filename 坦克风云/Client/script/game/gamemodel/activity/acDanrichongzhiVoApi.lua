acDanrichongzhiVoApi = {
	ChooseFlagList={},
}

function acDanrichongzhiVoApi:getAcVo()
	return activityVoApi:getActivityVo("danrichongzhi")
end

function acDanrichongzhiVoApi:canReward()
	local isfree=false	
	if self:isToday()==false then
		self:refresh()
	end
	local cost = self:getCostLevel()
	local num = SizeOfTable(cost)
	for i=1,num do
		local flag=self:getStateByid(i)
		if flag==2 then
			return true
		end
	end
	return isfree
end

function acDanrichongzhiVoApi:getVersion()
	return 1
end

function acDanrichongzhiVoApi:getAlreadyCost()
	local  vo = self:getAcVo()
	if vo and vo.alreadyCost then
		return vo.alreadyCost
	end
	return 0
end

function acDanrichongzhiVoApi:getCostLevel()
	local  vo = self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return {}
end

function acDanrichongzhiVoApi:getR1() -- 可选奖励
	local  vo = self:getAcVo()
	if vo and vo.reward then
		local reward = vo.reward
		if reward.r1 then
			return reward.r1
		end
	end
	return {}
end

function acDanrichongzhiVoApi:getR2() -- 固定奖励
	local  vo = self:getAcVo()
	if vo and vo.reward then
		local reward = vo.reward
		if reward.r2 then
			return reward.r2
		end
	end
	return {}
end

function acDanrichongzhiVoApi:takeHeroOrder( id )
	if id  then
		local heroId = heroCfg.soul2hero[id]
		if heroId then
			local orderId = heroListCfg[heroId]["fusion"]["p"]
			return heroId,orderId
		end
		
	end
	return nil
end

function acDanrichongzhiVoApi:getIsreward()
	local  vo = self:getAcVo()
	if vo and vo.isreward then
		return vo.isreward
	end
	return {}
end

function acDanrichongzhiVoApi:getRule()
	local  vo = self:getAcVo()
	if vo and vo.rule then
		return vo.rule
	end
	return {}
end

-- 档次 和 位置
function acDanrichongzhiVoApi:setChooseFlagList(id,weizhi)
	if self.ChooseFlagList==nil then
		self.ChooseFlagList={}
	end
	self.ChooseFlagList[id]=weizhi
end

function acDanrichongzhiVoApi:getChooseFlagList()
	return self.ChooseFlagList or {}
end

function acDanrichongzhiVoApi:getPercentage()
	local alreadyCost = self:getAlreadyCost()
	-- local alreadyCost=500
	local cost = self:getCostLevel()
	local numDuan = SizeOfTable(cost)
	local per = 0
	if numDuan==0 then
		numDuan=5
	end
	local everyPer = 100/numDuan

	local per = 0

	local diDuan=0 
	for i=1,numDuan do
		if alreadyCost<=cost[i] then
			diDuan=i
			break
		end
	end

	if alreadyCost>=cost[numDuan] then
		per=100
	elseif diDuan==1 then
		per=alreadyCost/cost[1]/numDuan*100
	else
		per = (diDuan-1)*everyPer+(alreadyCost-cost[diDuan-1])/(cost[diDuan]-cost[diDuan-1])/numDuan*100
	end

	return per
end

function acDanrichongzhiVoApi:getFlaglist()
	local  vo = self:getAcVo()
	if vo and vo.FlagList then
		return vo.FlagList
	end
	return {}
end

-- 判断 条件不足1  可领取2  已领取3
function acDanrichongzhiVoApi:getStateByid(id)
	local alReadyCost = self:getAlreadyCost()
	local flagList = self:getFlaglist()
	local cost = self:getCostLevel()
	if alReadyCost<cost[id] then
		return 1
	else
		if flagList[id] and flagList[id]==1 then
			return 3
		else
			return 2
		end
	end
	return 1
end

function acDanrichongzhiVoApi:gethadAwardList()
	local  vo = self:getAcVo()
	if vo and vo.hadAwardList then
		return vo.hadAwardList
	end
	return {}
end

function acDanrichongzhiVoApi:updataData(data)
	local  vo = self:getAcVo()
	vo:updateSpecialData(data)
end

function acDanrichongzhiVoApi:setLastTime(time)
	local  vo = self:getAcVo()
	if vo then
		vo.lastTime = time
	end
end

function acDanrichongzhiVoApi:setAlreadyCost(alreadyCost)
	local  vo = self:getAcVo()
	if vo then
		vo.alreadyCost = alreadyCost
	end
end

function acDanrichongzhiVoApi:setFlagList(FlagList)
	local  vo = self:getAcVo()
	if vo then
		vo.FlagList = FlagList
	end
end

function acDanrichongzhiVoApi:setHadAwardList(hadAwardList)
	local  vo = self:getAcVo()
	if vo then
		vo.hadAwardList = hadAwardList
	end
end

function acDanrichongzhiVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acDanrichongzhiVoApi:refresh()
	self:setLastTime(base.serverTime)
	self:setAlreadyCost(0)
	self:setFlagList({})
	self:setHadAwardList({})
end


function acDanrichongzhiVoApi:clearAll()
	self.ChooseFlagList=nil
end