
acMingjiangVoApi = {
	ranklist={},
	rank = nil,
}

function acMingjiangVoApi:getAcVo()
	return activityVoApi:getActivityVo("huoxianmingjianggai")
end

function acMingjiangVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	if self:acIsStop()==true then
		isfree=false
	end
	return isfree
end

function acMingjiangVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
	return timeStr
end
function acMingjiangVoApi:getRewardTimeStr( )
	local vo  = self:getAcVo()
	local reTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
	return reTimeStr
end

function acMingjiangVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acMingjiangVoApi:rankCanReward()
	local vo=self:getAcVo()
	if vo and vo.isReceive==nil and self:acIsStop()==true and activityVoApi:isStart(vo) then
		if vo.score and vo.score>=self:getscoreLimit() then
			if self.ranklist and SizeOfTable(self.ranklist)>0 then
				for k,v in pairs(self.ranklist) do
					if v and v[1] and tonumber(v[1])==tonumber(playerVoApi:getUid()) then
						return tonumber(k) or 0
					end
				end
			end
		end
	end
	return 0
end

function acMingjiangVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acMingjiangVoApi:isSearchToday()
	local vo=self:getAcVo()
	if self:checkCanSearch() and G_isToday(vo.lastTime)==false then
		return false
	end
	return true
end

function acMingjiangVoApi:checkCanSearch()
	local vo=self:getAcVo()
	if self:acIsStop()==false and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acMingjiangVoApi:getOneCost()
	local vo=self:getAcVo()
	if vo.cost then
		return vo.cost
	end
end

function acMingjiangVoApi:getTenCost()
	local vo=self:getAcVo()
	if vo.cost and vo.value then
		return math.floor(vo.cost*vo.value*10)
	end
end

function acMingjiangVoApi:getScore()
	local vo=self:getAcVo()
	if vo.score then
		return vo.score
	end
end

function acMingjiangVoApi:getscoreLimit()
	local vo=self:getAcVo()
	if vo.scoreLimit then
		return vo.scoreLimit
	end
end

function acMingjiangVoApi:getValue()
	local vo=self:getAcVo()
	if vo.value then
		return vo.value*10
	end
end

function acMingjiangVoApi:getscoreReward()
	local vo=self:getAcVo()
	if vo.scoreReward then
		return vo.scoreReward
	end
end

function acMingjiangVoApi:getrankReward()
	local vo = self:getAcVo()
	if vo.rankReward then
		return vo.rankReward
	end
end

function acMingjiangVoApi:getrongyuPoint()
	local vo = self:getAcVo()
	if vo.rongyuPoint then
		return vo.rongyuPoint
	end
end

function acMingjiangVoApi:setRanklist(list)
	self.ranklist={}
	if list then
		self.ranklist=list
	end
end

function acMingjiangVoApi:getRanklist()
	return self.ranklist
end

function acMingjiangVoApi:setRank(rank)
	self.rank = rank
end

function acMingjiangVoApi:getRank()
	return self.rank
end

function acMingjiangVoApi:isReceive()
	local vo = self:getAcVo()
	return vo.isReceive
end

function acMingjiangVoApi:setReceive(receive)
	local vo = self:getAcVo()
    vo.isReceive=receive
end

function acMingjiangVoApi:getVersion()
	local vo = self:getAcVo()
    return vo.version
end

function acMingjiangVoApi:getAward(flag)
	local scoreReward = self:getscoreReward()
	local Formadata = FormatItem(scoreReward[flag][2],true,true)
	local formadata=Formadata[1]
	local award = {}
	award={name=formadata.name,num=formadata.num,pic=formadata.pic,desc=formadata.desc,id=formadata.id,type=formadata.type,index=formadata.index,key=formadata.key,eType=formadata.eType,equipId=formadata.equipId}
	return award
end

function acMingjiangVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acMingjiangVoApi:getLogList()
	return self.logTimeList,self.logItemList,self.logItemNumList
end

function acMingjiangVoApi:analyzeItem(item)
	for k,v in pairs(item) do
		
		if SizeOfTable(v)==1 then	
			table.insert(self.logItemList,v)
		end
	end

end

function acMingjiangVoApi:initLogData(data)
	for k,v in pairs(data) do
    	local tb = {}
    	tb.time=v[2]
    	self:analyzeItem(v[1])
    	table.insert(self.logTimeList,v[2])
    end

    local tb = {}
    for k,v in pairs(self.logItemList) do
    	for p,q in pairs(v) do
    		table.insert(tb,p)
    		table.insert(self.logItemNumList,q)
    	end
    end
    self.logItemList = tb
end

function acMingjiangVoApi:clear()
	self:clearLogData()
end

function acMingjiangVoApi:clearLogData()
	self.logTimeList={}
	self.logItemList={}
	self.logItemNumList={}
end

function acMingjiangVoApi:clearAll()
	self.logTimeList=nil
	self.logItemList = nil
	self.logItemNumList=nil
	self.ranklist=nil
	self.rank = nil
end









