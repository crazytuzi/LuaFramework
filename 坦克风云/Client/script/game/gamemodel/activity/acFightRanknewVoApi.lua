acFightRanknewVoApi = {
    lastSt = 0,
    selfList=nil,
	rankList={},
	isMore = false,
	lastScore = 0,
}

function acFightRanknewVoApi:getAcVo()
	return activityVoApi:getActivityVo("fightRanknew")
end

function acFightRanknewVoApi:getCfg()
	-- local acVo = self:getAcVo()
	-- if acVo.reward and SizeOfTable(acVo.reward)>0 then
	-- 	if base.heroSwitch==1 then
	-- 		return acVo.reward.hero
	-- 	else
	-- 		return acVo.reward.nohero
	-- 	end
	-- else
		return activityCfg["fightRanknew"]
	-- end
	-- return {}
end

function acFightRanknewVoApi:getRankEndTime()
	local vo = self:getAcVo()
	if vo ~= nil then
		return tonumber(vo.et - 86400)
	end
	return 0
end


function acFightRanknewVoApi:getRewardByRank()
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

function acFightRanknewVoApi:afterGetReward()
	local vo = self:getAcVo()
	vo.c = -1
	activityVoApi:updateShowState(vo)
end

function acFightRanknewVoApi:clearAll()
	if self.rankList then
		for k,v in pairs(self.rankList) do
			self.rankList[k]=nil
		end
	end
	self.rankList={}

	self.lastSt = 0
    self.selfList=nil
	self.isMore = false
	self.lastScore = 0
end

function acFightRanknewVoApi:getLastScore()
	return self.lastScore
end

-- reset 是否清空数据重新添加
function acFightRanknewVoApi:updateRankList(data, reset)
	if reset == true then
		if self.rankList then
			for k,v in pairs(self.rankList) do
				self.rankList[k]=nil
			end
	    end
		self.rankList={}

	    self.selfList=nil
		self.isMore = false
	end

	if data.lastScore then
		self.lastScore=data.lastScore
	end
	
	local listData = data.ranklist
	
	if data.mylist ~= nil then
		self.selfList = data.mylist
	end
	

	if listData ~= nil then
		local uid = playerVoApi:getUid()
		for k,v in pairs(listData) do
			table.insert(self.rankList, v)
			-- if self.selfList ~= nil and uid == tonumber(v[1]]) then
			-- 	self.selfList.rank = tonumber(v.rank)
			-- end
		end
	end

	local function sortAsc(a, b)
		return tonumber(a[3]) < tonumber(b[3])
	end
	table.sort(self.rankList,sortAsc)

	local rankLen=0
	if data.rankLen then
		rankLen=tonumber(data.rankLen)
	end

	if SizeOfTable(self.rankList)>=0 then
		self.isMore=true
	end
	if SizeOfTable(self.rankList)>=rankLen then
		self.isMore=false
	end

    -- if reset == false and self.isMore == true then
    -- 	self.isMore = false
    -- end

	local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
	vo.stateChanged = true
end

function acFightRanknewVoApi:hadReward()
	local acVo = self:getAcVo()
	if acVo.c ~= nil and acVo.c < 0 then
		return true
	end
	return false
end


function acFightRanknewVoApi:canReward()
	-- local vo = self:getAcVo()
 --    if activityVoApi:isStart(vo) == true and tonumber(base.serverTime) > acFightRanknewVoApi:getRankEndTime() then -- 领奖时间内
	-- 	if self.selfList ~= nil and self.selfList[3] ~= nil and self.selfList[3] > 0 and self.selfList[3]<= 30 then -- 排行前三十名
	-- 		if self:hadReward() == false then -- 还没有领奖
	-- 			return true
	-- 		end
	-- 	end
	-- end    	
    return false
end

function acFightRanknewVoApi:refresh()
	local function getList(fn,data)
        self:afterRefresh(fn,data)
    end
    local startIndex = 1
	local endIndex = SizeOfTable(self.rankList)
	if endIndex==0 then
		endIndex=20
	elseif endIndex>100 then
		endIndex=100
	end
	socketHelper:getFightRankNewList(startIndex,endIndex,getList)
end

function acFightRanknewVoApi:afterRefresh( fn,data )
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

function acFightRanknewVoApi:update()
	local function getList(fn,data)
        self:afterUpdate(fn,data)
    end
	local startIndex = 1
	local endIndex = SizeOfTable(self.rankList)
	if endIndex==0 then
		endIndex=20
	elseif endIndex>100 then
		endIndex=100
	end
	socketHelper:getFightRankNewList(startIndex,endIndex,getList)
end

function acFightRanknewVoApi:afterUpdate( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData ~= nil then
       	  self:setLastSt()
          self:updateRankList(sData, true)
       end
    end
end

function acFightRanknewVoApi:setLastSt()
	self.lastSt = base.serverTime
end

function acFightRanknewVoApi:getRankNum()
	return SizeOfTable(self.rankList) + 1
end

-- 获得冠军的战斗力
function acFightRanknewVoApi:getFirstFight()
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
function acFightRanknewVoApi:getDifferFight()
	local myFight = playerVoApi:getPlayerPower()
	local firstFight = self:getFirstFight()
	local isFirst=false
	if myFight and myFight>0 and firstFight and firstFight>0 and myFight>=firstFight then
		isFirst=true
	end
    if firstFight > myFight then
    	return firstFight - myFight
    end
	return 0,isFirst
end


