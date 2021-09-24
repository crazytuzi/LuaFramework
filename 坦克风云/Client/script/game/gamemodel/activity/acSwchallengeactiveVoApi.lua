acSwchallengeactiveVoApi={}

function acSwchallengeactiveVoApi:getAcVo()
	return activityVoApi:getActivityVo("swchallengeactive")
end

function acSwchallengeactiveVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acSwchallengeactiveVoApi:canReward()
	return false
end

function acSwchallengeactiveVoApi:getReward( ... )
	local reward = self:getAcVo().reward
	
	return FormatItem(reward)
end

function acSwchallengeactiveVoApi:getActivityLocalName( ... )
	return getlocal("activity_swchallengeactive_title")
end