acMeteoriteLandingVoApi ={}

function acMeteoriteLandingVoApi:getAcVo()
	return activityVoApi:getActivityVo("yunxingjianglin")
end

function acMeteoriteLandingVoApi:getCostGems(idx)
	local vo = self:getAcVo()
	if vo and vo.oneCost and (idx==1 or idx==nil) then
		return vo.oneCost
	end
	if vo and vo.mulCost and idx== 10 then
		return vo.mulCost
	end
end


function acMeteoriteLandingVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acMeteoriteLandingVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
	return timeStr
end
function acMeteoriteLandingVoApi:getRewardTimeStr( )
	local vo  = self:getAcVo()
	local reTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
	return reTimeStr
end
function acMeteoriteLandingVoApi:isToday()
	local isToday=false--false 是免费，true是不免费
	local vo = self:getAcVo()

	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acMeteoriteLandingVoApi:isReceive()
	local vo = self:getAcVo()
	return vo.isReceive
end

function acMeteoriteLandingVoApi:setReceive(receive)
	local vo = self:getAcVo()
    vo.isReceive=receive
end

function acMeteoriteLandingVoApi:setRanklist(list)
	self.ranklist={}
	if list then
		self.ranklist=list
	end
end

function acMeteoriteLandingVoApi:setRank(rank)
	self.rank = rank
end

function acMeteoriteLandingVoApi:getRanklist()
	return self.ranklist
end

function acMeteoriteLandingVoApi:getRank()
	return self.rank
end

function acMeteoriteLandingVoApi:getScore()
	local vo = self:getAcVo()
	local score = 0
	if vo.score then
		score = vo.score
	end
	return score
end

function acMeteoriteLandingVoApi:setScore(score)
	local vo = self:getAcVo()
	vo.score = score
end

function acMeteoriteLandingVoApi:rankCanReward()
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

function acMeteoriteLandingVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acMeteoriteLandingVoApi:getLimitScore()
	local vo = self:getAcVo()
	if vo.scoreLimit then
		return vo.scoreLimit
	end
end

function acMeteoriteLandingVoApi:getResource(id)
	local vo = self:getAcVo()
	if vo.resource then
		return vo.resource[id]
	end
end

function acMeteoriteLandingVoApi:getGetNameAndPic(id)
	local resource = self:getResource(id)
	local getItem=FormatItem(resource.get)
	return getItem[1].name,getItem[1].pic,getItem[1].key,getItem[1].desc,getItem[1].num
end

function acMeteoriteLandingVoApi:getCostItem(id)
	local resource = self:getResource(id)
	local costItem=FormatItem(resource.cost)
	return costItem
end

function acMeteoriteLandingVoApi:getGetItem(id)
	local resource = self:getResource(id)
	local getItem=FormatItem(resource.get)
	return getItem
end

function acMeteoriteLandingVoApi:getMaxNum(costItem)
	local num1 = costItem[1].num
	local num2 = tonumber(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(costItem[1].key))))

	local num3 = costItem[2].num
	local num4 =alienTechVoApi:getAlienResByType(costItem[2].key)
	local maxnum1 = num2 / num1
	local maxnum2 = num4 / num3
	local maxNum = maxnum2
	if maxnum1<maxnum2 then
	maxNum=maxnum1
	end
	return maxNum
end


function acMeteoriteLandingVoApi:getRewardNum(num)
	local vo = self:getAcVo()
	if vo.rewardTime then
		if type(vo.rewardTime[num])~="number" then
			return 1
		else
			return vo.rewardTime[num]
		end
	end
end

function acMeteoriteLandingVoApi:isSearchToday()
	local vo=self:getAcVo()
	if self:checkCanSearch() and G_isToday(vo.lastTime)==false then
		return false
	end
	return true
end

function acMeteoriteLandingVoApi:checkCanSearch()
	local vo=self:getAcVo()
	if self:acIsStop()==false and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acMeteoriteLandingVoApi:getrankReward()
	local vo = self:getAcVo()
	if vo.rankReward then
		return vo.rankReward
	end
end

function acMeteoriteLandingVoApi:getSocketRankList(callback)
	local function getRankList(fn,data)
		local ret,sData=base:checkServerData(data)
	    if ret==true then
	        if sData and sData.data and sData.data.yunxingjianglin and sData.data.yunxingjianglin.clientReward then
	            self:setRanklist(sData.data.yunxingjianglin.clientReward)
	        end
	        if sData and sData.data and sData.data.yunxingjianglin then
	            self:setRank(sData.data.yunxingjianglin.rank)
	            self:setScore(sData.data.yunxingjianglin.point)
	        end
	       
	        callback()
	    end
	end
	socketHelper:acMeteoriteLandingRank(getRankList)
end

function acMeteoriteLandingVoApi:clearAll()
	
end


function acMeteoriteLandingVoApi:setT(t) --点击抽奖时的时间戳
	self:getAcVo().lastTime=t
end