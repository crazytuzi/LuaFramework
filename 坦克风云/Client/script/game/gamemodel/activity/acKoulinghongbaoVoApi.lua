acKoulinghongbaoVoApi={}

function acKoulinghongbaoVoApi:getAcVo()
	return activityVoApi:getActivityVo("koulinghongbao")
end

function acKoulinghongbaoVoApi:getAcCfg()
	local acVo=self:getAcVo()
	if acVo and acVo.acCfg then
		return acVo.acCfg
	end
	return {}
end

function acKoulinghongbaoVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.et)
	return timeStr
end

function acKoulinghongbaoVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
	return vo
end

function acKoulinghongbaoVoApi:canReward()
	return false
end
