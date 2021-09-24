acFightRankVoApi = {
    lastSt = 0,
    selfList=nil,
	rankList={},
	isMore = true,
}

function acFightRankVoApi:getAcVo()
	return activityVoApi:getActivityVo("fightRank")
end

function acFightRankVoApi:getCfg()
	return activityCfg["fightRank"]
end

function acFightRankVoApi:getRankEndTime()
	local vo = self:getAcVo()
	if vo ~= nil then
		return tonumber(vo.et - 86400)
	end
	return 0
end


function acFightRankVoApi:getRewardByRank()
	if self.selfList == nil or self.selfList[3] == nil then
		return nil
	end

	local rank = self.selfList[3]
	local cfg = self:getCfg()
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

function acFightRankVoApi:afterGetReward()
	local vo = self:getAcVo()
	vo.c = -1
	activityVoApi:updateShowState(vo)
end

function acFightRankVoApi:clearAll()
	if self.rankList then
		for k,v in pairs(self.rankList) do
			self.rankList[k]=nil
		end
	end
	self.rankList={}

	self.lastSt = 0
    self.selfList=nil
	self.isMore = true
end

-- reset 是否清空数据重新添加
function acFightRankVoApi:updateRankList(data, reset)
	if reset == true then
		if self.rankList then
			for k,v in pairs(self.rankList) do
				self.rankList[k]=nil
			end
	    end
		self.rankList={}

	    self.selfList=nil
		self.isMore = true
	end

	local listData = data.ranklist
	
	if data.mylist ~= nil then
		self.selfList = data.mylist
	end
	
	local newRankNum = 0
	if listData ~= nil then
		local uid = playerVoApi:getUid()
		for k,v in pairs(listData) do
			table.insert(self.rankList, v)
			-- if self.selfList ~= nil and uid == tonumber(v[1]]) then
			-- 	self.selfList.rank = tonumber(v.rank)
			-- end
			newRankNum = newRankNum + 1
		end
	end

	local function sortAsc(a, b)
		return tonumber(a[3]) < tonumber(b[3])
	end
	table.sort(self.rankList,sortAsc)

    if reset == false and self.isMore == true then
    	if newRankNum < 20 then
    		self.isMore = false
    	end
    end

	local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
	vo.stateChanged = true
end

function acFightRankVoApi:hadReward()
	local acVo = self:getAcVo()
	if acVo.c ~= nil and acVo.c < 0 then
		return true
	end
	return false
end


function acFightRankVoApi:canReward()
	local vo = self:getAcVo()
    if activityVoApi:isStart(vo) == true and tonumber(base.serverTime) > acFightRankVoApi:getRankEndTime() then -- 领奖时间内
    	local maxRank = tonumber(self:getMaxRank())
		if self.selfList ~= nil and self.selfList[3] ~= nil and self.selfList[3] > 0 and self.selfList[3] <= maxRank then
			if self:hadReward() == false then -- 还没有领奖
				return true
			end
		end
	end
    return false
end

function acFightRankVoApi:refresh()
	local function getList(fn,data)
        self:afterRefresh(fn,data)
    end
    local startIndex = 1
	local endIndex = 20
	if self.isMore == false then
	   endIndex = 30
	end
	socketHelper:getFightRankList(startIndex,endIndex,getList)
end

function acFightRankVoApi:afterRefresh( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData ~= nil then
       	  local vo = self:getAcVo()
       	  vo.refresh = true
       	  self:setLastSt()
          self:updateRankList(sData, true)
       end
    end
end

function acFightRankVoApi:update()
	local function getList(fn,data)
        self:afterUpdate(fn,data)
    end
	local startIndex = 1
	local endIndex = 20
	if self.isMore == false then
	   endIndex = 30
	end
	socketHelper:getFightRankList(startIndex,endIndex,getList)
end

function acFightRankVoApi:afterUpdate( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData ~= nil then
       	  self:setLastSt()
          self:updateRankList(sData, true)
       end
    end
end

function acFightRankVoApi:setLastSt()
	self.lastSt = base.serverTime
end

function acFightRankVoApi:getRankNum()
	return SizeOfTable(self.rankList) + 1
end

-- 获得冠军的战斗力
function acFightRankVoApi:getFirstFight()
	if self.rankList ~= nil then
		for k,v in pairs(self.rankList) do
			if v[3] ~= nil and v[3] == 1 and v[4] ~= nil then
				return tonumber(v[4])
			end
		end
	end
	return 0
end

-- 玩家离冠军相差的战斗力
function acFightRankVoApi:getDifferFight()
	local myFight = playerVoApi:getPlayerPower()
	local firstFight = self:getFirstFight()
	
    if firstFight > myFight then
    	return firstFight - myFight
    end
	return 0
end

--获取最大名次
function acFightRankVoApi:getMaxRank()
	local fightRank = self:getCfg()
    local max = 0
    for k,v in pairs(fightRank) do
    	if v.rank[2] and max<v.rank[2] then
    		max = v.rank[2]
    	elseif v.rank[1] and max<v.rank[1] then
    		max = v.rank[1]
    	end
    end
    return max
end