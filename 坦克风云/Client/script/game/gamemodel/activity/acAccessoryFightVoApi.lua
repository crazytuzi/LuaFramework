acAccessoryFightVoApi={}

function acAccessoryFightVoApi:getAcVo()
	return activityVoApi:getActivityVo("accessoryFight")
end

function acAccessoryFightVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acAccessoryFightVoApi:canReward()
	return false
end