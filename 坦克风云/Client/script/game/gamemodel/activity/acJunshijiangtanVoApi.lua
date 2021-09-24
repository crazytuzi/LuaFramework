
acJunshijiangtanVoApi = {
	ranklist={},
	rank = nil,
	formatData1=nil,
	formatData2=nil,
	formatData3=nil,
	num1=nil,
	num2=nil,
	num3=nil,


}

function acJunshijiangtanVoApi:getAcVo()
	return activityVoApi:getActivityVo("junshijiangtan")
end

function acJunshijiangtanVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end
function acJunshijiangtanVoApi:getVersion(  )
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end
function acJunshijiangtanVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
	return timeStr
end
function acJunshijiangtanVoApi:getRewardTimeStr( )
	local vo  = self:getAcVo()
	local reTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
	return reTimeStr
end
function acJunshijiangtanVoApi:getTvNum(flag)
	local rewardlist=self:getrewardlist()
	local num = 0
	if flag == 1 then
 		local number = SizeOfTable(rewardlist[1])
		for i=1,number do
			local formatData = FormatItem(rewardlist[1][i])
			num = num+SizeOfTable(formatData)
		end	
	elseif flag == 2 then
		local number = SizeOfTable(rewardlist[2])
		for i=1,number do
			local formatData = FormatItem(rewardlist[2][i])
			num = num+SizeOfTable(formatData)
		end		
	elseif flag == 3 then
		local number = SizeOfTable(rewardlist[3])
		for i=1,number do
			local formatData = FormatItem(rewardlist[3][i])
			num = num+SizeOfTable(formatData)
		end	
 	end
 	return num
end

function acJunshijiangtanVoApi:formatData()
	local rewardlist=self:getrewardlist()
	self.formatData1=FormatItem(rewardlist[1][1],true,true)
	self.formatData2=FormatItem(rewardlist[2][1],true,true)
	self.formatData3=FormatItem(rewardlist[3][1],true,true)
end

function acJunshijiangtanVoApi:gerFormadata(flag)
	if flag ==1 then
		return self.formatData1
	elseif flag ==2 then
		return self.formatData2
	else
		return self.formatData3
	end

end

function acJunshijiangtanVoApi:getOneCost(flag)
	local vo = self:getAcVo()
	if vo.gemcost then
		return vo.gemcost[flag][1]
	end
end

function acJunshijiangtanVoApi:getTenCost(flag)
	local vo = self:getAcVo()
	if vo.gemcost then
		return vo.gemcost[flag][2]
	end
end

function acJunshijiangtanVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acJunshijiangtanVoApi:isSearchToday()
	local vo=self:getAcVo()
	if self:checkCanSearch() and G_isToday(vo.lastTime)==false then
		return false
	end
	return true
end

function acJunshijiangtanVoApi:getScore()
	local vo = self:getAcVo()
	local score = 0
	if vo.score then
		score = vo.score
	end
	return score
end

function acJunshijiangtanVoApi:setScore(score)
	local vo = self:getAcVo()
	if score then
		if vo.score then
			vo.score = vo.score+score
		end
	end
end

function acJunshijiangtanVoApi:getLimitScore()
	local vo = self:getAcVo()
	if vo.scoreLimit then
		return vo.scoreLimit
	end
end

function acJunshijiangtanVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime = time
end

function acJunshijiangtanVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acJunshijiangtanVoApi:setRanklist(list)
	self.ranklist={}
	if list then
		self.ranklist=list
	end
end

function acJunshijiangtanVoApi:getRanklist()
	return self.ranklist
end

function acJunshijiangtanVoApi:setRank(rank)
	self.rank = rank
end

function acJunshijiangtanVoApi:getRank()
	return self.rank
end

function acJunshijiangtanVoApi:getrankReward()
	local vo = self:getAcVo()
	if vo.rankReward then
		return vo.rankReward
	end
end

function acJunshijiangtanVoApi:getrewardlist()
	local vo = self:getAcVo()
	if vo.rewardlist then
		return vo.rewardlist
	end
end

function acJunshijiangtanVoApi:isReceive()
	local vo = self:getAcVo()
	return vo.isReceive
end

function acJunshijiangtanVoApi:setReceive(receive)
	local vo = self:getAcVo()
    vo.isReceive=receive
end

function acJunshijiangtanVoApi:rankCanReward()
	local vo=self:getAcVo()
	if vo and vo.isReceive==nil and self:acIsStop()==true and activityVoApi:isStart(vo) then
		if vo.score and vo.score>=self:getLimitScore() then
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

function acJunshijiangtanVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acJunshijiangtanVoApi:checkCanSearch()
	local vo=self:getAcVo()
	if self:acIsStop()==false and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acJunshijiangtanVoApi:clearAll()
	self.ranklist={}
	self.rank = nil
	self.formatData1=nil
	self.formatData2=nil
	self.formatData3=nil
	self.num1=nil
	self.num2=nil
	self.num3=nil
end






