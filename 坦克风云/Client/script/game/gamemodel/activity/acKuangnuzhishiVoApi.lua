
acKuangnuzhishiVoApi = {
	lastSt = 0,
	rankList={},
	myRank= 0, -- 个人排名
}

function acKuangnuzhishiVoApi:getAcVo()
	return activityVoApi:getActivityVo("kuangnuzhishi")
end

function acKuangnuzhishiVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acKuangnuzhishiVoApi:getRewardListCfg()
	local vo=self:getAcVo()
	if vo and vo.rewardlist then
		return vo.rewardlist
	end
	return {}
end

function acKuangnuzhishiVoApi:FormatItem()
	local formatData={}	
	local num=0
	local name=""
	local pic=""
	local desc=""
    local id=0
	local index=0
    local eType=""
    local noUseIdx=0 --无用的index 只是占位
    local equipId
    local data = self:getRewardListCfg()
	if data then
		for k,v in pairs(data) do
			if v then
				for m,n in pairs(v) do
					if m~=nil and n~=nil then
						local isSpecial
						local score = 1
						local key,type1,num=m,k,n
						if type(n)=="table" then
							for i,j in pairs(n) do
								if i=="index" then
									index=j
								elseif i== "isSpecial" then
									isSpecial=j
								elseif i== "score" then
									score=j
								else
									key=i
									num=j
								end
							end
						end
						name,pic,desc,id,noUseIdx,eType,equipId=getItem(key,type1)
						if name and name~="" then
							table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId,isSpecial=isSpecial,score=score})
						end
					end
				end
			end
		end
	end
	if formatData and SizeOfTable(formatData)>0 then
		local function sortAsc(a, b)
			if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
				return a.index < b.index
			end
	    end
		table.sort(formatData,sortAsc)
	end
	return formatData
end
function acKuangnuzhishiVoApi:getItemByIndex(index)
	local itemList = self:FormatItem()
	for k,v in pairs(itemList) do
		if v then
			if v.index and v.index == index then
				return v
			end
		end
	end
	return {}
end
function acKuangnuzhishiVoApi:getLotteryOnceCost()
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end
function acKuangnuzhishiVoApi:getLotteryTenCost()
	local vo=self:getAcVo()
	if vo and vo.cost and vo.mul and vo.mulc then
		return tonumber(vo.cost*vo.mulc)
	end
	return 0
end
function acKuangnuzhishiVoApi:getLotteryOldTenCost()
	local vo=self:getAcVo()
	if vo and vo.cost and vo.mul then
		return tonumber(vo.cost*vo.mul)
	end
	return 0
end


function acKuangnuzhishiVoApi:getRankRewardCfg()
	local acVo = self:getAcVo()
    if acVo ~= nil and acVo.rankReward then
    	return acVo.rankReward
    end
    return {}
end

-- 活动排名名次最终确定的时间等领奖条件最终确定不变的时间
function acKuangnuzhishiVoApi:getEndTime()
    local acVo = self:getAcVo()
    if acVo ~= nil then
    	return acVo.acEt
    end
    return 0
end

function acKuangnuzhishiVoApi:hadRankReward()
	local acVo = self:getAcVo()
	if acVo ~= nil  then
		if acVo.hadRankReward and acVo.hadRankReward == 1 then
			return true
		end
	end
	return false
end

function acKuangnuzhishiVoApi:updateHadRankReward()
	local acVo = self:getAcVo()
	if acVo ~= nil  then
		acVo.hadRankReward = 1
	end
end
function acKuangnuzhishiVoApi:checkIfCanRankReward()
	local acVo = self:getAcVo()
	if acVo and activityVoApi:isStart(acVo) == true and base.serverTime >= self:getEndTime() and self.myRank>=1 and self.myRank<=self:getRankLimit() and self:hadRankReward() ==false then
		return true
	end
	return false
end
-- 根据排名获取相对应的奖励
function acKuangnuzhishiVoApi:getRewardByRank(rank)
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

function acKuangnuzhishiVoApi:clearAll()
	self:clear()
	self.lastSt = 0
end

function acKuangnuzhishiVoApi:clear()
	if self.rankList then
		for k,v in pairs(self.rankList) do
			self.rankList[k]=nil
		end
	end
	self.rankList={}
	self.myRank = 0

end

function acKuangnuzhishiVoApi:getMyRank()
	return self.myRank
end

-- reset 是否清空数据重新添加
function acKuangnuzhishiVoApi:updateRankList(data)
	self:clear()
	
	self.rankList=data.clientReward
	if data.rank then
		self.myRank = data.rank
	end

	local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
	vo.stateChanged = true
end

-- 活动排名结束时获取最新的
function acKuangnuzhishiVoApi:refresh()
	print("********acKuangnuzhishiVoApi:refresh**********")
	local function getList(fn,data)
        self:afterRefresh(fn,data)
    end
	socketHelper:activityKuangnuzhishiRankList(getList)
end

function acKuangnuzhishiVoApi:afterRefresh( fn,data )
	local ret,sData=base:checkServerData(data)
    if ret==true then
       if sData ~= nil then
       	  local vo = self:getAcVo()
       	  vo.refresh = true
       	  self:setLastSt()
          self:updateRankList(sData.data.kuangnuzhishi)
       end
    end
end

function acKuangnuzhishiVoApi:getMyScores()
	local vo = self:getAcVo()
	if vo and vo.myScores then
		return vo.myScores
	end
	return 0
end


function acKuangnuzhishiVoApi:addMyScores(score)
	local vo = self:getAcVo()
	if vo then
		if vo.myScores ==nil then
			vo.myScores = 0 
		end
		vo.myScores = vo.myScores +score
	end
end
function acKuangnuzhishiVoApi:getScoresLimit()
	local vo = self:getAcVo()
	if vo and vo.scoreLimit then
		return vo.scoreLimit
	end
	return 0
end
function acKuangnuzhishiVoApi:getRankLimit()
	local vo = self:getAcVo()
	if vo and vo.ranklimit then
		return vo.ranklimit
	end
	return 0
end
function acKuangnuzhishiVoApi:setLastSt()
	self.lastSt = base.serverTime
end

function acKuangnuzhishiVoApi:checkIsEnd()
	local acVo = acKuangnuzhishiVoApi:getAcVo()
	if acVo and base.serverTime >= self:getEndTime() then
		return true
	end
	return false
end

function acKuangnuzhishiVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acKuangnuzhishiVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acKuangnuzhishiVoApi:canReward()
	local canReward=false							--是否是第一次免费
	if (self:checkIsEnd()==false and self:isToday()==false) or acKuangnuzhishiVoApi:checkIfCanRankReward()==true then
		canReward=true
	end
	return canReward
end

