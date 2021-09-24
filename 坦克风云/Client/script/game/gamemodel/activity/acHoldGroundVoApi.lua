acHoldGroundVoApi = {}

function acHoldGroundVoApi:getAcVo()
	return activityVoApi:getActivityVo("holdGround")
end

function acHoldGroundVoApi:getAcCfg()
	local acVo=self:getAcVo()
	if acVo.acCfg then
		return acVo.acCfg
	end
	return {}
end
function acHoldGroundVoApi:getVersion()
    local acVo=self:getAcVo()
    if acVo and acVo.version then
        return acVo.version
    end
    return 1
end
function acHoldGroundVoApi:canRewardById(id)
	local canReward=false
	local acVo=self:getAcVo()
	local rewardNum=acVo.rewardNum or 0
	local lastTime=acVo.lastTime or 0
	if rewardNum+1==id and G_isToday(lastTime)==false then
		canReward=true
	end
	return canReward
end

function acHoldGroundVoApi:checkCanReward()
	local canReward=false
	local acVo=self:getAcVo()
	if acVo and acVo.lastTime and activityVoApi:isStart(acVo) then
		local lastTime=acVo.lastTime or 0
		if G_isToday(lastTime)==false then
			return true
		end
	end
	return false
end

function acHoldGroundVoApi:afterGetReward(time)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.rewardNum=acVo.rewardNum+1
		acVo.lastTime=time
		activityVoApi:updateShowState(acVo)
	end
end

-- function acHoldGroundVoApi:getTimeStr()
-- 	local timeStr=""
-- 	local acVo = self:getAcVo()
-- 	if acVo then
-- 		local ifInRechargeDay,ifInRewardDay=self:getIfInDays()
--     	local chargeDays,rewardDays,totalDays,leftDays=self:getAcDays()
--     	if ifInRechargeDay then
--     		local endTs=G_getWeeTs(acVo.st)+chargeDays*(24*3600)-1
--         	timeStr=activityVoApi:getActivityTimeStr(acVo.st,endTs)
--     	elseif ifInRewardDay then
--     		local startTs=G_getWeeTs(acVo.st)+chargeDays*(24*3600)
--         	timeStr=activityVoApi:getActivityTimeStr(startTs,acVo.acEt)
--     	end
--     end
-- 	return timeStr
-- end

function acHoldGroundVoApi:canReward()
	local canReward=self:checkCanReward()
	return canReward
end
