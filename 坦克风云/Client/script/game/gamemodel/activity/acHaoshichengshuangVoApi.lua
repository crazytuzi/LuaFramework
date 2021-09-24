acHaoshichengshuangVoApi={
	rankList={},
	selfRankData={},
	lastfreshTime=0,
}

-- 这里需要修改
function acHaoshichengshuangVoApi:getAcVo()
	return activityVoApi:getActivityVo("haoshichengshuang")
end

function acHaoshichengshuangVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acHaoshichengshuangVoApi:canReward()
	local isfree=false		
	local count = self:getownCount()
	if count>0 then
		isfree=true
	end
	return isfree
end

function acHaoshichengshuangVoApi:getCfg()
	local acVo = self:getAcVo()
	return acVo.reward or {}
end

function acHaoshichengshuangVoApi:getownCount()   --获取可翻牌次数
	local acVo = self:getAcVo()
	if acVo then
		return acVo.currentState.nums or 0
	end
	return 0
end

-- function acHaoshichengshuangVoApi:getCurrentTime()
-- 	local acVo = self:getAcVo()
-- 	return acVo.currentState.refreshTs
-- end


function acHaoshichengshuangVoApi:updateData(data)
	-- print("------")
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

-- function acHaoshichengshuangVoApi:getRewardList()
-- 	local acVo = self:getAcVo()
-- 	local rewardList = {}
-- 	for k,v in pairs(acVo.reward.r) do
-- 		rewardList[k]={}
-- 		rewardList[k].req=v.req
-- 		rewardList[k].reward=v.reward
-- 		rewardList[k].index=k
-- 		rewardList[k].isOk=true
-- 		for m,n in pairs(v.req) do
-- 			if acVo.props[m]<=0 then
-- 				rewardList[k].isOk=false
-- 				break
-- 			end
-- 		end
-- 	end
-- 	local function sortByindexAndIsOk(a,b)
-- 		if a.isOk == b.isOk then
-- 			return tonumber(a.index)<tonumber(b.index)
-- 		end
-- 		if a.isOk then
-- 			return true
-- 		end 
-- 		return false
-- 	end
-- 	table.sort(rewardList,sortByindexAndIsOk)
-- 	return rewardList
-- end

-- function acHaoshichengshuangVoApi:formatData(data)
-- 	local acVo = self:getAcVo()
-- 	if acVo.myrank==nil then
-- 		acVo.myrank=100
-- 	end
-- 	if acVo.allPoint==nil then
-- 		acVo.allPoint=0
-- 	end
-- 	if data.myrank then
-- 		acVo.myrank = data.myrank
-- 	end
-- 	if data.allPoint then
-- 		acVo.allPoint = data.allPoint
-- 	end
-- end

-- function acHaoshichengshuangVoApi:FormatRankList(data)
-- 	self.rankList={}
-- 	if data.rankList then
--     	self.rankList=data.rankList
--     	self.selfRankData={}
--     	for k,v in pairs(data.rankList) do
--     		if v and SizeOfTable(v)>0 and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
-- 				self.selfRankData[1]=v[1]
-- 				self.selfRankData[2]=v[2]
-- 				self.selfRankData[3]=v[3]
-- 				self.selfRankData[4]=v[4]
-- 				self.selfRankData[5]=k
-- 				self:getAcVo().myrank = k
-- 				break
-- 			end
--     	end
--     end
-- end

function acHaoshichengshuangVoApi:getRewardItem(index,iscurrent)  --iscurrent是否是当前翻牌
	-- print("----index="..index)
	local acVo = self:getAcVo()
	local rewardCfg = self:getCfg()
	local rewardIndex = acVo.currentState.open[index]
	reward = acVo.currentState.pool[rewardIndex]
	if iscurrent==true then
		reward = acVo.currentState.pool[index]
	end
	if reward[1]==1 then
		local item = {o=rewardCfg.troopPool.o[reward[2]]}
		item=FormatItem(item)
		-- print("找不到对应奖励===1")
		return item[1]
	else
		local item = {p=rewardCfg.pool.p[reward[2]]}
		item=FormatItem(item)
		-- print("找不到对应奖励===2")
		return item[1]
	end
	return nil
end


-- function acHaoshichengshuangVoApi:getRankList()
-- 	if self.rankList then
-- 		return self.rankList
-- 	end
-- 	return {}
-- end

-- function acHaoshichengshuangVoApi:rankCanReward()
-- 	local acVo = self:getAcVo()
-- 	if acVo.acEt < base.serverTime then
-- 		for k,v in pairs(self.rankList) do
-- 			if v and SizeOfTable(v)>0 and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) and k<=10 and acVo.rankReward==0 then
-- 				return true
-- 			end
-- 		end
-- 	end
-- 	return false
-- end

-- function acHaoshichengshuangVoApi:canReward()
-- 	return self:rankCanReward()
-- end

function acHaoshichengshuangVoApi:clearAll()
	self.rankList={}
	self.selfRankData={}
	self.lastfreshTime=0
end
