acHarvestDayVoApi = {

}

function acHarvestDayVoApi:clearAll()

end

function acHarvestDayVoApi:getAcVo()
	return activityVoApi:getActivityVo("harvestDay")
end

function acHarvestDayVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acHarvestDayVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.et)
	return timeStr
end

function acHarvestDayVoApi:getHadRewardNum(index)
	local vo=self:getAcVo()
	local num=0
	if vo then
		if index==1 then
			num=vo.bidRewardNum
		elseif index==2 then
			num=vo.warRewardNum
		elseif index==3 then
			num=vo.vicRewardNum
		end
	end
	return num
end
function acHarvestDayVoApi:getCanRewardNum(index)
	local vo=self:getAcVo()
	local maxNum=vo.maxRewardTab[index]
	local num=0
	if vo then
		if index==1 then
			num=vo.bidCanRewardNum
		elseif index==2 then
			num=vo.warCanRewardNum
		elseif index==3 then
			num=vo.vicCanRewardNum
		end
	end
	if maxNum>0 and num>maxNum then
		num=maxNum
	end
	return num
end

function acHarvestDayVoApi:getCanReward(index)
	local vo=self:getAcVo()
	-- if activityVoApi:isStart(vo) and self:acIsStop()==false then
	if activityVoApi:isStart(vo) then
		local hadRewardNum=self:getHadRewardNum(index)
		local canRewardNum=self:getCanRewardNum(index)
		if canRewardNum>hadRewardNum then
			if index==1 then
				local selfAlliance=allianceVoApi:getSelfAlliance()
				if selfAlliance and tonumber(selfAlliance.aid) and tonumber(selfAlliance.aid)>0 and tonumber(selfAlliance.role) and tonumber(selfAlliance.role)==2 then
					return true
				end
			else
				return true
			end
		end
	end
	return false
end

function acHarvestDayVoApi:getLeftNum(index)
	local leftNum=0
	local vo=self:getAcVo()
	local maxNum=vo.maxRewardTab[index]
	-- if activityVoApi:isStart(vo) and self:acIsStop()==false then
	if activityVoApi:isStart(vo) then
		local hadRewardNum=self:getHadRewardNum(index)
		local canRewardNum=self:getCanRewardNum(index)
	    local selfAlliance=allianceVoApi:getSelfAlliance()
	    if (index~=1) or (index==1 and selfAlliance and tonumber(selfAlliance.aid) and tonumber(selfAlliance.aid)>0 and tonumber(selfAlliance.role) and tonumber(selfAlliance.role)==2) then
	        leftNum=canRewardNum-hadRewardNum
	        if leftNum<0 then
	            leftNum=0
	        end
	        if maxNum>0 and leftNum>maxNum then
	            leftNum=maxNum
	        end
	    end
	end
	return leftNum
end

function acHarvestDayVoApi:getNeedUpdate()
	local vo=self:getAcVo()
	if activityVoApi:isStart(vo) then
		local maxTab=vo.maxRewardTab
		local bidMaxNum=maxTab[1] or 0
		local vicMaxNum=maxTab[3] or 0
		local bidNum=vo.bidCanRewardNum or 0
		local vicNum=vo.vicCanRewardNum or 0
		if (bidMaxNum>0 and bidNum<bidMaxNum) or (vicMaxNum>0 and vicNum<vicMaxNum) then
			return true
		end
	end
	return false
end

function acHarvestDayVoApi:setRewardNum(index)
	local vo=self:getAcVo()
	if index==1 then
		vo.bidRewardNum=vo.bidRewardNum+1
	elseif index==2 then
		vo.warRewardNum=vo.warRewardNum+1
	elseif index==3 then
		vo.vicRewardNum=vo.vicRewardNum+1
	end
	activityVoApi:updateShowState(vo)
end

function acHarvestDayVoApi:canReward()
	local vo=self:getAcVo()
	if activityVoApi:isStart(vo) then
		for k=1,3 do
			if acHarvestDayVoApi:getCanReward(k)==true then
				return true
			end
		end
	end
	return false
end

-- function acHarvestDayVoApi:acIsStop()
-- 	local vo=self:getAcVo()
-- 	if vo and base.serverTime<(vo.et-24*3600) then
-- 		return false
-- 	end
-- 	return true
-- end


