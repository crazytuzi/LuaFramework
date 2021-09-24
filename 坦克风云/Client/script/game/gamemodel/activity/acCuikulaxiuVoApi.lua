acCuikulaxiuVoApi = {
	lastSt = 0,
	rankList={},
	myRank= 0, -- 个人排名
	myPoint= 0,--活动中获得的军功
}

function acCuikulaxiuVoApi:getAcVo()
	return activityVoApi:getActivityVo("cuikulaxiu")
end

function acCuikulaxiuVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acCuikulaxiuVoApi:getPointRewardCfg()
	local acVo = self:getAcVo()
    if acVo ~= nil and acVo.pointReward then
    	return acVo.pointReward
    end
    return {}
end

function acCuikulaxiuVoApi:getNeedPointByID(id)
	local pointRewardCfg = self:getPointRewardCfg()
	if pointRewardCfg and type(pointRewardCfg)=="table" then
		for k,v in pairs(pointRewardCfg) do
			if k == id and v and v[1] then
				return tonumber(v[1])
			end
		end
	end
	return 0 
end

function acCuikulaxiuVoApi:getPointRewardByID(id)
	local pointRewardCfg = self:getPointRewardCfg()
	if pointRewardCfg and type(pointRewardCfg)=="table" then
		for k,v in pairs(pointRewardCfg) do
			if k == id and v and v[2] then
				return v[2]
			end
		end
	end
	return {}
end

function acCuikulaxiuVoApi:getRankRewardCfg()
	local acVo = self:getAcVo()
    if acVo ~= nil and acVo.rankReward then
    	return acVo.rankReward
    end
    return {}
end

function acCuikulaxiuVoApi:getRankMinPoint()
	local acVo = self:getAcVo()
    if acVo ~= nil and acVo.minPoint then
    	return acVo.minPoint
    end
    return 0
end


function acCuikulaxiuVoApi:getMyPoint()
    return tonumber(self.myPoint)
end

function acCuikulaxiuVoApi:getMyRank()
	return tonumber(self.myRank)
end

function acCuikulaxiuVoApi:getHadRewardTb()
	local acVo = self:getAcVo()
    if acVo ~= nil and acVo.hadRewardTb then
    	return acVo.hadRewardTb
    end
    return {}
end

function acCuikulaxiuVoApi:addHadRewardTb(id)
	local acVo = self:getAcVo()
    if acVo ~= nil then
    	if  acVo.hadRewardTb == nil then
    		 acVo.hadRewardTb = {}
    	end
    	table.insert(acVo.hadRewardTb,id)
    end
end

function acCuikulaxiuVoApi:getIsHadRewardByID(id)
	local rewardTb = self:getHadRewardTb()
	if rewardTb then
		for k,v in pairs(rewardTb) do
			if v and v == id then
				return true
			end
		end
	end
	return false
end
-- 活动排名名次最终确定的时间等领奖条件最终确定不变的时间
function acCuikulaxiuVoApi:getEndTime()
    local acVo = self:getAcVo()
    if acVo ~= nil then
    	return acVo.acEt
    end
    return 0
end

function acCuikulaxiuVoApi:hadRankReward()
	local acVo = self:getAcVo()
	if acVo ~= nil  then
		if acVo.hadRankReward and acVo.hadRankReward == 1 then
			return true
		end
	end
	return false
end

function acCuikulaxiuVoApi:updateHadRankReward()
	local acVo = self:getAcVo()
	if acVo ~= nil  then
		acVo.hadRankReward = 1
	end
end
function acCuikulaxiuVoApi:checkIfCanRankReward()
	local acVo = self:getAcVo()
	if acVo and activityVoApi:isStart(acVo) == true and base.serverTime >= self:getEndTime() and self.myRank>=1 and self.myRank<=10 and self:hadRankReward() ==false then
		return true
	end
	return false
end
function acCuikulaxiuVoApi:checkIfCanPointReward()
	local pointCfg = self:getPointRewardCfg()
	local needPoint
	for k,v in pairs(pointCfg) do
		needPoint = self:getNeedPointByID(k)
		if self.myPoint>=needPoint and self:getIsHadRewardByID(k)==false then
			return true
		end
	end
	return false
end
function acCuikulaxiuVoApi:canReward()
	if self:checkIfCanRankReward() == true or self:checkIfCanPointReward() ==true then
		return true
	end
end

function acCuikulaxiuVoApi:getRewardById(id, isHead)
	local acCfg = self:getRankRewardCfg()
	if acCfg ~= nil then
		if acCfg[id] ~= nil then
			return acCfg[id][2]
		end
	end
	return nil
end


-- 根据排名获取相对应的奖励
function acCuikulaxiuVoApi:getRewardByRank(rank)
	local cfg = self:getRankRewardCfg()
	local award
	for k,v in pairs(cfg) do
		local isReward = false
		for m,n in pairs(v) do
			if m==1 then
				if rank<=n[2] and rank>=n[1] then
					isReward = true
				end
			elseif m==2 then
				if isReward == true then
					award = n
					return award
				end
			end
		end
	end
	return nil
end

function acCuikulaxiuVoApi:clearAll()
	self:clear()
	self.lastSt = 0
end

function acCuikulaxiuVoApi:clear()
	if self.rankList then
		for k,v in pairs(self.rankList) do
			self.rankList[k]=nil
		end
	end
	self.rankList={}
	self.myRank = 0
	self.point = 0

end

-- reset 是否清空数据重新添加
function acCuikulaxiuVoApi:updateRankList(data)
	self:clear()
	
	self.rankList=data.clientReward
	if data.rank then
		self.myRank = data.rank
	end
	if data.point then
		self.myPoint = data.point
	end

	local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
	vo.stateChanged = true
end

-- 活动排名结束时获取最新的
function acCuikulaxiuVoApi:refresh()
	print("********acCuikulaxiuVoApi:refresh**********")
	local function getList(fn,data)
        self:afterRefresh(fn,data)
    end
	socketHelper:activityCuikulaxiuList(getList)
end

function acCuikulaxiuVoApi:afterRefresh( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData ~= nil then
       	  local vo = self:getAcVo()
       	  vo.refresh = true
       	  self:setLastSt()
          self:updateRankList(sData.data.cuikulaxiu)
       end
    end
end

function acCuikulaxiuVoApi:setLastSt()
	self.lastSt = base.serverTime
end

