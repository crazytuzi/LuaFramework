acAllianceLevelVoApi = {
	lastSt = 0,
    selfList=nil,
	rankList={},
}

function acAllianceLevelVoApi:getAcVo()
	return activityVoApi:getActivityVo("allianceLevel")
end

function acAllianceLevelVoApi:getAcCfg()
	return activityCfg["allianceLevel"]
end

-- 活动排名名次最终确定的时间等领奖条件最终确定不变的时间
function acAllianceLevelVoApi:getEndTime()
    local acVo = self:getAcVo()
    if acVo ~= nil then
    	return acVo.acEt
    end
    return 0
end

function acAllianceLevelVoApi:hadReward()
	local acVo = self:getAcVo()
	if acVo.c ~= nil and acVo.c < 0 then
		return true
	end
	return false
end

function acAllianceLevelVoApi:canReward()
	if self:hadReward() == false and self:checkIfCanReward() == true then
		return true
	end
end

function acAllianceLevelVoApi:getRewardById(id, isHead)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil then
		if acCfg[id] ~= nil then
			local reward = acCfg[id].award
			if reward ~= nil and SizeOfTable(reward) == 2 then
				if isHead == true then
				    return reward[1]
				else
					return reward[2]
				end
			end
		end
	end
	return nil
end


-- 判断是否满足领奖的条件
function acAllianceLevelVoApi:checkIfCanReward()
	local acVo = self:getAcVo()
	local selfAlliance = allianceVoApi:getSelfAlliance()
	if selfAlliance ~= nil then
		if acVo ~= nil and activityVoApi:isStart(acVo) == true and base.serverTime >= self:getEndTime() and allianceVoApi:getJoinTime() < self:getEndTime() then
			local myRank = self:getSelfRank() -- 自己的排名
			local cfg = self:getAcCfg()
			local rankCfg
			for k,v in pairs(cfg) do
				rankCfg = v.rank
				if rankCfg ~= nil then
					if SizeOfTable(rankCfg) > 1 then
						if myRank >= rankCfg[1] and myRank <= rankCfg[2] then
							return true
						end
					else
						if myRank == rankCfg[1] then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

-- 获取自己的排名
function acAllianceLevelVoApi:getSelfRank()
	if self.selfList ~= nil and self.selfList.rank ~= nil then
		return self.selfList.rank
	end
	return 0
end

-- 得到自己可以领取的奖励
function acAllianceLevelVoApi:getMyReward()
	local rank = self:getSelfRank()
	local reward = self:getRewardByRank(rank)
	if reward ~= nil then
		local selfAlliance = allianceVoApi:getSelfAlliance()
		if selfAlliance ~= nil then
			local isHead = false
			if selfAlliance.role == 2 then
				isHead = true
			end
			if isHead == true then
				return reward[1]
			else
				return reward[2]
			end
		end
	end
	return nil
end

-- 根据排名获取相对应的奖励
function acAllianceLevelVoApi:getRewardByRank(rank)
	local cfg = self:getAcCfg()
	local rankCfg
	for k,v in pairs(cfg) do
		rankCfg = v.rank
		if rankCfg ~= nil then
			if SizeOfTable(rankCfg) > 1 then
				if rank >= rankCfg[1] and rank <= rankCfg[2] then
					return v.award
				end
			else
				if rank == rankCfg[1] then
					return v.award
				end
			end
		end
	end
	return nil
end

function acAllianceLevelVoApi:afterGetReward()
	local vo = self:getAcVo()
	vo.c = -1
	activityVoApi:updateShowState(vo)
end

function acAllianceLevelVoApi:clearAll()
	self:clear()
	self.lastSt = 0
end

function acAllianceLevelVoApi:clear()
	if self.rankList then
		for k,v in pairs(self.rankList) do
			self.rankList[k]=nil
		end
	end
	self.rankList={}
    self.selfList=nil
end

-- reset 是否清空数据重新添加
function acAllianceLevelVoApi:updateRankList(data)
	self:clear()
	local listData = data.ranklist

    local selfAlliance = allianceVoApi:getSelfAlliance()
	if listData ~= nil then
		for k,v in pairs(listData) do
			if selfAlliance ~= nil and tonumber(v.aid) == tonumber(selfAlliance.aid) then
				self.selfList = v
			end
			table.insert(self.rankList, v)
		end
	end

	local function sortAsc(a, b)
		return tonumber(a.rank) < tonumber(b.rank)
	end
	table.sort(self.rankList,sortAsc)

	local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
	vo.stateChanged = true
end

-- 活动排名结束时获取最新的
function acAllianceLevelVoApi:refresh()
	print("********acAllianceLevelVoApi:refresh**********")
	local function getList(fn,data)
        self:afterRefresh(fn,data)
    end
    local selfAlliance = allianceVoApi:getSelfAlliance()
	if selfAlliance ~= nil then
		print("********acAllianceLevelVoApi:refresh***1*******")
	    socketHelper:getAllianceLevelList(selfAlliance.aid, getList)
	end
end

function acAllianceLevelVoApi:afterRefresh( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData ~= nil then
       	  local vo = self:getAcVo()
       	  vo.refresh = true
       	  self:setLastSt()
          self:updateRankList(sData)
       end
    end
end

-- 手动刷新列表
function acAllianceLevelVoApi:update()
	print("********acAllianceLevelVoApi:update**********")
	local function getList(fn,data)
        self:afterUpdate(fn,data)
    end
    local selfAlliance = allianceVoApi:getSelfAlliance()
	if selfAlliance ~= nil then
		print("********acAllianceLevelVoApi:update**1********")
	    socketHelper:getAllianceLevelList(selfAlliance.aid, getList)
	else
		local vo = self:getAcVo()
		activityVoApi:updateShowState(vo)
		vo.stateChanged = true
	end
end

function acAllianceLevelVoApi:afterUpdate( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData ~= nil then
       	  self:setLastSt()
          self:updateRankList(sData)
       end
    end
end

function acAllianceLevelVoApi:setLastSt()
	self.lastSt = base.serverTime
end

