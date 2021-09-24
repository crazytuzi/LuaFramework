
acMoscowGamblingVoApi={}

function acMoscowGamblingVoApi:getAcVo()
	return activityVoApi:getActivityVo("moscowGambling")
end

function acMoscowGamblingVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end


function acMoscowGamblingVoApi:setTankPartNum(type,num)
	local vo = self:getAcVo()
	if type==1 then
		vo.rart1Num=num
	elseif type==2 then
		vo.rart2Num=num
	end
end

function acMoscowGamblingVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime=time
end

function acMoscowGamblingVoApi:canReward()
	local vo = self:getAcVo()
	local isCanReward=false
	if self:isToday()==false then
		isCanReward=true
	end
	return isCanReward
end


