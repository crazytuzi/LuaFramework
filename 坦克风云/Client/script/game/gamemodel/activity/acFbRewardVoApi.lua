acFbRewardVoApi = {
	lastSt = 0,
	rankList = {},
	selfList = nil,
}

function acFbRewardVoApi:getAcVo()
	return activityVoApi:getActivityVo("fbReward")
end

function acFbRewardVoApi:getRankEndTime()
	local vo = self:getAcVo()
	if vo ~= nil then
		return tonumber(vo.refreshTs)
	end
	return 0
end
function acFbRewardVoApi:getRewardByRank(getAexp)
	if self.selfList~= nil and self.selfList.rank > 0 and self.selfList.rank < 4 then
		local vo = self:getAcVo()
		local reward = vo.reward[self.selfList.rank]

		if getAexp == false and reward ~= nil then
			reward = {u = reward.u}
		end
		return reward
	end
	return  {}
end

function acFbRewardVoApi:afterGetReward()
	local vo = self:getAcVo()
	vo.c = -1
	activityVoApi:updateShowState(vo)
end

function acFbRewardVoApi:clear()
	if self.rankList then
		for k,v in pairs(self.rankList) do
			self.rankList[k]=nil
		end
	end
	self.rankList={}
end

function acFbRewardVoApi:updateRankList(data)
	self:clear()
	local listData = data.ranklist
	if data.mylist ~= nil and data.mylist[1] ~= nil then
		self.selfList = data.mylist[1]
	    self.selfList.rank = SizeOfTable(listData) + 1
	else
		self.selfList = nil
	end
	

	if listData ~= nil then
		local selfAlliance = allianceVoApi:getSelfAlliance()
		for k,v in pairs(listData) do
			table.insert(self.rankList, v)
			if self.selfList ~= nil and selfAlliance ~= nil and selfAlliance.aid == tonumber(v.aid) then
				self.selfList.rank = tonumber(v.rank)
			end
		end
	end

	local function sortAsc(a, b)
		return tonumber(a.rank) < tonumber(b.rank)
	end
	table.sort(self.rankList,sortAsc)
	local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
end

function acFbRewardVoApi:hadReward()
	local acVo = self:getAcVo()
	if acVo.c ~= nil and acVo.c < 0 then
		return true
	end
	return false
end


function acFbRewardVoApi:canReward()
	local selfAlliance = allianceVoApi:getSelfAlliance()
	local vo = self:getAcVo()
    if selfAlliance ~= nil then -- 有军团
    	if self:hadReward() == false then -- 还没有领奖
    		if activityVoApi:isStart(vo) == true and tonumber(base.serverTime) > acFbRewardVoApi:getRankEndTime() then -- 领奖时间内
    			if self.selfList ~= nil and self.selfList.rank > 0 and self.selfList.rank < 4 then -- 排行前三名
    				if allianceVoApi:getJoinTime() < acFbRewardVoApi:getRankEndTime()  then -- 不是排行确定之后加入军团的
    					return true
    				end
    			end
    		end
    	end
    end
    return false
end

function acFbRewardVoApi:refresh()
	local function getList(fn,data)
        self:afterRefresh(fn,data)
    end
	socketHelper:getFbRewardRankList(getList)
end

function acFbRewardVoApi:afterRefresh( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData.data.unlockranking ~= nil then
       	  local vo = self:getAcVo()
       	  vo.refresh = true
       	  self:setLastSt()
          self:updateRankList(sData.data.unlockranking)
       end
    end
end

function acFbRewardVoApi:update()
	local function getList(fn,data)
        self:afterUpdate(fn,data)
    end
	socketHelper:getFbRewardRankList(getList)
end

function acFbRewardVoApi:afterUpdate( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData.data.unlockranking ~= nil then
       	  self:setLastSt()
          self:updateRankList(sData.data.unlockranking)
       end
    end
end

function acFbRewardVoApi:setLastSt()
	self.lastSt = base.serverTime
end

function acFbRewardVoApi:clearAll()
	print("*************acFbRewardVoApi:clearAll****************")
	self:clear()
	self.lastSt = 0
	self.selfList = nil
end
