acAllianceFightVoApi = {
	lastSt = 0,
    selfList=nil,
	rankList={},
	myRankInAlliance = 0, -- 军团中我的个人排名
}

function acAllianceFightVoApi:getAcVo()
	return activityVoApi:getActivityVo("allianceFight")
end

function acAllianceFightVoApi:getAcCfg()
	return activityCfg["allianceFight"]
end

-- 活动排名名次最终确定的时间等领奖条件最终确定不变的时间
function acAllianceFightVoApi:getEndTime()
    local acVo = self:getAcVo()
    if acVo ~= nil then
    	return acVo.acEt
    end
    return 0
end

function acAllianceFightVoApi:hadReward()
	local acVo = self:getAcVo()
	if acVo.c ~= nil and acVo.c < 0 then
		return true
	end
	return false
end

function acAllianceFightVoApi:canReward()
	if self:hadReward() == false and self:checkIfCanReward() == true then
		return true
	end
end

function acAllianceFightVoApi:getRewardById(id, isHead)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil then
		if acCfg[id] ~= nil then
			return acCfg[id].award
		end
	end
	return nil
end


-- 判断是否满足领奖的条件
function acAllianceFightVoApi:checkIfCanReward()
	local acVo = self:getAcVo()
	local selfAlliance = allianceVoApi:getSelfAlliance()
	if selfAlliance ~= nil then
		if acVo ~= nil and activityVoApi:isStart(acVo) == true and base.serverTime >= self:getEndTime() and allianceVoApi:getJoinTime() < self:getEndTime() and self.myRankInAlliance > 0 and self.myRankInAlliance < 11 then
			local myRank = self:getSelfRank() -- 自己的排名
			local cfg = self:getAcCfg()
			local rank
			for k,v in pairs(cfg) do
				rank = tonumber(v.rank)
				if rank == myRank then
					return true
				end
			end
		end
	end
	return false
end

-- 获取自己的排名
function acAllianceFightVoApi:getSelfRank()
	if self.selfList ~= nil and self.selfList.rank ~= nil then
		return self.selfList.rank
	end
	return 0
end

-- 得到自己可以领取的奖励
function acAllianceFightVoApi:getMyReward()
	local rank = self:getSelfRank()
	local reward = self:getRewardByRank(rank)
	if reward ~= nil then
		return reward
	end
	return nil
end

-- 根据排名获取相对应的奖励
function acAllianceFightVoApi:getRewardByRank(rank)
	local cfg = self:getAcCfg()
	local rankCfg
	for k,v in pairs(cfg) do
		rankCfg = tonumber(v.rank)
		if rank == rankCfg then
			return v.award
		end
	end
	return nil
end

function acAllianceFightVoApi:afterGetReward()
	local vo = self:getAcVo()
	vo.c = -1
	activityVoApi:updateShowState(vo)
end

function acAllianceFightVoApi:clearAll()
	self:clear()
	self.lastSt = 0
end

function acAllianceFightVoApi:clear()
	if self.rankList then
		for k,v in pairs(self.rankList) do
			self.rankList[k]=nil
		end
	end
	self.rankList={}
    self.selfList=nil
    self.myRankInAlliance = 0
end

-- reset 是否清空数据重新添加
function acAllianceFightVoApi:updateRankList(data)
	self:clear()
	local listData = data.ranklist
    if data.myrank ~= nil then
       self.myRankInAlliance = tonumber(data.myrank)
    end
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
function acAllianceFightVoApi:refresh()
	print("********acAllianceFightVoApi:refresh**********")
	local function getList(fn,data)
        self:afterRefresh(fn,data)
    end
    local selfAlliance = allianceVoApi:getSelfAlliance()
	if selfAlliance ~= nil then
		print("********acAllianceFightVoApi:refresh***1*******")
	    socketHelper:getAllianceFightList(selfAlliance.aid,getList)
	end
end

function acAllianceFightVoApi:afterRefresh( fn,data )
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
function acAllianceFightVoApi:update()
	print("********acAllianceFightVoApi:update**********")
	local function getList(fn,data)
        self:afterUpdate(fn,data)
    end
    local selfAlliance = allianceVoApi:getSelfAlliance()
	if selfAlliance ~= nil then
		print("********acAllianceFightVoApi:update1**********")
	    socketHelper:getAllianceFightList(selfAlliance.aid, getList)
	else
		local vo = self:getAcVo()
		activityVoApi:updateShowState(vo)
		vo.stateChanged = true
	end
end

function acAllianceFightVoApi:afterUpdate( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData ~= nil then
       	  self:setLastSt()
          self:updateRankList(sData)
       end
    end
end

function acAllianceFightVoApi:setLastSt()
	self.lastSt = base.serverTime
end

