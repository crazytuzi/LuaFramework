acTacticalDiscussVoApi={}

function acTacticalDiscussVoApi:getAcVo()
	return activityVoApi:getActivityVo("zhanshuyantao")
end
function acTacticalDiscussVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end
function acTacticalDiscussVoApi:updateLastTime(newTime)
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = newTime
	end
end
function acTacticalDiscussVoApi:getFreeTime( )
	local vo = self:getAcVo()
	if vo and vo.freeTime and vo.freeTime >0 then
		return true
	end
	return false
end
function acTacticalDiscussVoApi:setFreeTime(freeTime )
	local vo  = self:getAcVo()
	if vo and freeTime then
		vo.freeTime =freeTime
	else
		vo.freeTime =nil
	end
end
function acTacticalDiscussVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acTacticalDiscussVoApi:getUpTimes( )
	local vo = self:getAcVo()
	if vo and vo.reStartTime then
		return vo.reStartTime
	end
	return 0
end
function acTacticalDiscussVoApi:getGoldCost1( )
	local vo = self:getAcVo()
	if vo and vo.goldCost1 then
		return vo.goldCost1
	end
	return 999
end
function acTacticalDiscussVoApi:getGoldCost2( )
	local vo = self:getAcVo()
	if vo and vo.goldCost2 then
		return vo.goldCost2
	end
	return 999
end

function acTacticalDiscussVoApi:getNeedReward( )
	local vo = self:getAcVo()
	if vo and vo.rewardTb then
		return vo.rewardTb
	end
	return nil
end
function acTacticalDiscussVoApi:formatNeedReward(layerNum)
	local needReward = self:getNeedReward()
	local formatReward ={}
	
	for k,v in pairs(needReward) do
		local award = FormatItem(v,nil,true)
		table.insert(formatReward,award)
	end
	return formatReward
end

function acTacticalDiscussVoApi:getReStartGoldCostTb( )
	local vo = self:getAcVo()
	if vo and vo.reStartGoldCostTb then
		return vo.reStartGoldCostTb
	end
	return nil
end

function acTacticalDiscussVoApi:getLastAwardTb( )
	local vo = self:getAcVo()
	if vo and vo.lastAwardTb then
		return vo.lastAwardTb
	end
	return nil
end
function acTacticalDiscussVoApi:setLastAward(awardTb)
	local  vo = self:getAcVo()
	if vo and awardTb then
		vo.lastAwardTb = awardTb
	else
		vo.lastAwardTb ={}
	end
end
	-- if data.t then
	-- 	self.lastTime =data.t
	-- end

function acTacticalDiscussVoApi:getCurrRestartTime( )
	local vo = self:getAcVo()
	if vo and vo.currRestartTime then
		return vo.currRestartTime,vo.currRestartTime+1
	end
	return 0
end
function acTacticalDiscussVoApi:setCurrRestartTime(currRestartTime)
	local vo = self:getAcVo()
	if vo  and currRestartTime then
		-- if tonumber(vo.reStartTime) < tonumber(currRestartTime) then
		-- 	vo.currRestartTime =currRestartTime
		-- else
			vo.currRestartTime =currRestartTime
		-- end
	end
end

function acTacticalDiscussVoApi:getClickTag( )
	local vo = self:getAcVo()
	if vo and vo.clickTag then
		return vo.clickTag
	end
	return 0
end
function acTacticalDiscussVoApi:setClickTag(clickTag)
	local vo = self:getAcVo()
	if vo and vo.clickTag and clickTag then
		vo.clickTag =clickTag
	end
end

function acTacticalDiscussVoApi:getNeedCostNow( )
	local vo = self:getAcVo()
	if vo and vo.needCostNow then
		return vo.needCostNow
	end
	return nil
end
function acTacticalDiscussVoApi:setNeedCostNow(needCost)
	local  vo = self:getAcVo()
	if vo and needCost then
		vo.needCostNow = needCost
	end
end


function acTacticalDiscussVoApi:getCurrBigAwardIdx( )
	local vo = self:getAcVo()
	if vo and vo.currBigAwardIdx then
		return vo.currBigAwardIdx
	end
	return 0
end
function acTacticalDiscussVoApi:setCurrBigAwardIdx(currBigAwardIdx)
	local  vo = self:getAcVo()
	if vo and currBigAwardIdx then
		vo.currBigAwardIdx = currBigAwardIdx
	end
end