acPersonalHonorVoApi = {
	lastSt = 0,
    selfList=nil,
	rankList={},
}

function acPersonalHonorVoApi:getAcVo()
	return activityVoApi:getActivityVo("personalHonor")
end

function acPersonalHonorVoApi:getAcCfg()
	return activityCfg["personalHonor"]
end

-- 活动排名名次最终确定的时间等领奖条件最终确定不变的时间
function acPersonalHonorVoApi:getEndTime()
    local acVo = self:getAcVo()
    if acVo ~= nil then
    	return acVo.acEt
    end
    return 0
end

function acPersonalHonorVoApi:hadReward()
	local acVo = self:getAcVo()
	if acVo.c ~= nil and acVo.c < 0 then
		return true
	end
	return false
end

function acPersonalHonorVoApi:canReward()
	if self:hadReward() == false and self:checkIfCanReward() == true then
		return true
	end
end

function acPersonalHonorVoApi:getRewardById(id, isHead)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil then
		if acCfg[id] ~= nil then
			return acCfg[id].award
		end
	end
	return nil
end


-- 判断是否满足领奖的条件
function acPersonalHonorVoApi:checkIfCanReward()
	local acVo = self:getAcVo()
	if acVo ~= nil and activityVoApi:isStart(acVo) == true and base.serverTime >= self:getEndTime() then
		local myRank = self:getSelfRank() -- 自己的排名
		local cfg = self:getAcCfg()
		local rankCfg
		for k,v in pairs(cfg) do
			rankCfg = v.rank
			if rankCfg ~= nil then
				if SizeOfTable(rankCfg) > 1 then
					if myRank >= tonumber(rankCfg[1]) and myRank <= tonumber(rankCfg[2]) then
						return true
					end
				else
					if myRank == tonumber(rankCfg[1]) then
						return true
					end
				end
			end
		end
		return false
	end
	return false
end

-- 获取自己的排名
function acPersonalHonorVoApi:getSelfRank()
	if self.selfList ~= nil and self.selfList[3] ~= nil then
		return tonumber(self.selfList[3])
	end
	return 0
end

function acPersonalHonorVoApi:getSelfCredit()
	if self.selfList ~= nil and self.selfList[4] ~= nil then
		local credit = tonumber(self.selfList[4])
		if credit > 0 then
		    return credit
		end
	end
	return 0
end

-- 得到自己可以领取的奖励
function acPersonalHonorVoApi:getMyReward()
	local rank = self:getSelfRank()
	local reward = self:getRewardByRank(rank)
	if reward ~= nil then
		return reward
	end
	return nil
end

-- 根据排名获取相对应的奖励
function acPersonalHonorVoApi:getRewardByRank(rank)
	local cfg = self:getAcCfg()
	local rankCfg
	for k,v in pairs(cfg) do
		rankCfg = v.rank
		if rankCfg ~= nil then
			if SizeOfTable(rankCfg) > 1 then
				if tonumber(rank) >= tonumber(rankCfg[1]) and rank <= tonumber(rankCfg[2]) then
					return v.award
				end
			else
				if tonumber(rank) == tonumber(rankCfg[1]) then
					return v.award
				end
			end
		end
	end
	return nil
end

function acPersonalHonorVoApi:afterGetReward()
	local vo = self:getAcVo()
	vo.c = -1
	activityVoApi:updateShowState(vo)
end

function acPersonalHonorVoApi:clearAll()
	self:clear()
	self.lastSt = 0
end

function acPersonalHonorVoApi:clear()
	if self.rankList then
		for k,v in pairs(self.rankList) do
			self.rankList[k]=nil
		end
	end
	self.rankList={}
    self.selfList=nil
end

-- reset 是否清空数据重新添加
function acPersonalHonorVoApi:updateRankList(data)
	self:clear()
	local listData = data.ranklist
    self.selfList = data.myranking
	if listData ~= nil then
		for k,v in pairs(listData) do
			table.insert(self.rankList, v)
		end
	end

	local function sortAsc(a, b)
		return tonumber(a[3]) < tonumber(b[3])
	end
	table.sort(self.rankList,sortAsc)

	local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
	vo.stateChanged = true
end

-- 活动排名结束时获取最新的
function acPersonalHonorVoApi:refresh()
	local function getList(fn,data)
        self:afterRefresh(fn,data)
    end
    socketHelper:getPersonalHonorList(getList)
end

function acPersonalHonorVoApi:afterRefresh( fn,data )
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
function acPersonalHonorVoApi:update()
	local function getList(fn,data)
        self:afterUpdate(fn,data)
    end
    socketHelper:getPersonalHonorList(getList)
end

function acPersonalHonorVoApi:afterUpdate(fn,data)
	local ret,sData=base:checkServerData(data)
    if ret==true then
        if sData ~= nil then
            self:updateRankList(sData)
            self:setLastSt()
        end
    end
end

function acPersonalHonorVoApi:setLastSt()
	self.lastSt = base.serverTime
end

