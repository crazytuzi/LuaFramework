acTianjiangxiongshiVoApi = {}

function acTianjiangxiongshiVoApi:getAcVo()
	return activityVoApi:getActivityVo("tianjiangxiongshi")
end

function acTianjiangxiongshiVoApi:getLastResultByLine(line)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.lastResult[line]
	end
	return 1
end

function acTianjiangxiongshiVoApi:updateLastResult(result)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.lastResult = result
	end
end

function acTianjiangxiongshiVoApi:getPicById(id)
	if id == 1 then
		return "tianjiangxiongshi_h.png"
	elseif id == 2 then
		return "tianjiangxiongshi_r.png"
	elseif id == 3 then
		return "tianjiangxiongshi_m.png"
	elseif id == 4 then
		return "tianjiangxiongshi_k.png"
	else
		return "tianjiangxiongshi_h.png"
	end
end

function acTianjiangxiongshiVoApi:getCost(num)
	local vo = self:getAcVo()
	if num==1 then
		return vo.cost1
	elseif num==2 then
		return vo.cost2
	elseif num==3 then
		return vo.cost3
	elseif num==4 then
		return vo.cost4
	end
end

function acTianjiangxiongshiVoApi:getTankTb()
	
	local vo = self:getAcVo()
	if vo and vo.tankTb then
		return vo.tankTb
	end
	return {}
end

function acTianjiangxiongshiVoApi:getRewardTank()
	
	local vo = self:getAcVo()
	if vo and vo.rewardTank then
		return vo.rewardTank
	end
	return vo.tankTb[1]
end

function acTianjiangxiongshiVoApi:setRewardTank(tankId)
	local vo = self:getAcVo()
	vo.rewardTank=tankId
end

function acTianjiangxiongshiVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acTianjiangxiongshiVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime=time
end

function acTianjiangxiongshiVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end