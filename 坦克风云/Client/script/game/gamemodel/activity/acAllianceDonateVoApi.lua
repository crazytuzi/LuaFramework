acAllianceDonateVoApi={}

function acAllianceDonateVoApi:getAcVo()
	return activityVoApi:getActivityVo("allianceDonate")
end

function acAllianceDonateVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acAllianceDonateVoApi:getRank(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=self:getAcVo()
			vo:updateRank(sData.data)
			if(callback)then
				callback()
			end
		end
	end
	local aid
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance)then
		aid=selfAlliance.aid
	else
		aid=0
	end
	socketHelper:activeAllianceDonateGetList(aid,onRequestEnd)
end

function acAllianceDonateVoApi:getRankList()
	local vo=self:getAcVo()
	return vo.rankList
end

function acAllianceDonateVoApi:getHasReward()
	local vo=self:getAcVo()
	return vo.hasReward
end

function acAllianceDonateVoApi:getReward(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=self:getAcVo()
			vo.hasReward=true
            activityVoApi:updateShowState(vo)
			local award=FormatItem(sData.data.reward) or {}
			for k,v in pairs(award) do
				G_addPlayerAward(v.type,v.key,v.id,v.num)
			end
			G_showRewardTip(award, true)
			callback()
		end
	end
	socketHelper:activeAllianceDonateGetReward(self:getSelfRank(),onRequestEnd)
end

function acAllianceDonateVoApi:canReward()
	if(self:hasSelf() and self:getHasReward()==false)then
		local vo=self:getAcVo()
		if(allianceVoApi:getJoinTime()>0 and allianceVoApi:getJoinTime()<vo.acEt)then
			if(base.serverTime>=vo.acEt and base.serverTime<vo.et)then
				return true
			else
				return false
			end
		else
			return false
		end
	end
	return false
end

function acAllianceDonateVoApi:hasSelf()
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance==nil)then
		return false
	end
	local selfAid=tonumber(selfAlliance.aid)
	local vo=self:getAcVo()
	for k,v in pairs(vo.rankList) do
		if(v.aid==selfAid)then
			if(type(v.rank)=="string")then
				return false
			elseif(v.rank<=10)then
				return true
			else
				return false
			end
		end
	end
	return false
end

function acAllianceDonateVoApi:getSelfRank()
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance==nil)then
		return 0
	end
	local selfAid=tonumber(selfAlliance.aid)
	local vo=self:getAcVo()
	for k,v in pairs(vo.rankList) do
		if(v.aid==selfAid)then
			if(type(v.rank)=="string")then
				return 0
			elseif(v.rank<=10)then
				return v.rank
			else
				return 0
			end
		end
	end
	return 0
end