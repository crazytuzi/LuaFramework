
acMoscowGamblingGaiVoApi={}

function acMoscowGamblingGaiVoApi:getAcVo()
	return activityVoApi:getActivityVo("moscowGamblingGai")
end

function acMoscowGamblingGaiVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end
function acMoscowGamblingGaiVoApi:getTanks( )
	local vo  = self:getAcVo()
	if vo and vo.partMap then
		return vo.partMap
	end
	return nil
end
function acMoscowGamblingGaiVoApi:isToday()

	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	if isToday==true then
	elseif isToday ==false then
	end
	return isToday
end
function acMoscowGamblingGaiVoApi:getGemOneCost( )
	local vo = self:getAcVo()
	if vo and vo.gemCost then
		return vo.gemCost
	end
	return 38
end
function acMoscowGamblingGaiVoApi:setTankPartNum(type,num)
	local vo = self:getAcVo()
	if type==1 then
		vo.rart1Num=num
	elseif type==2 then
		vo.rart2Num=num
	end
end

function acMoscowGamblingGaiVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime=time
end

function acMoscowGamblingGaiVoApi:canReward()
	local vo = self:getAcVo()
	local isCanReward=false
	if self:isToday()==false then
		isCanReward=true
	end
	return isCanReward
end


