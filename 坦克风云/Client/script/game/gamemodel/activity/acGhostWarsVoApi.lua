
acGhostWarsVoApi = {}

function acGhostWarsVoApi:getAcVo()
	return activityVoApi:getActivityVo("ghostWars")
end
function acGhostWarsVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acGhostWarsVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acGhostWarsVoApi:getCollectSpeedRate()
	local vo=self:getAcVo()
	if vo and vo.collectspeedup then
		return tonumber(vo.collectspeedup*100) 
	end
	return 0
end

function acGhostWarsVoApi:getMinLevel()
	local vo=self:getAcVo()
	if vo and vo.minLv then
		return vo.minLv
	end
	return 0
end

function acGhostWarsVoApi:getMedalsRate()
	local vo=self:getAcVo()
	if vo and vo.pointup then
		return  tonumber(vo.pointup*100) 
	end
	return 0
end

function acGhostWarsVoApi:canReward()
	return false
end