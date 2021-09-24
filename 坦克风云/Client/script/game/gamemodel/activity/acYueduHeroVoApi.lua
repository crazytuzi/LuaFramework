acYueduHeroVoApi={}

-- 这里需要修改
function acYueduHeroVoApi:getAcVo()
	return activityVoApi:getActivityVo("yuedujiangling")
end

function acYueduHeroVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acYueduHeroVoApi:canReward()
	local isfree=false		
	local flag1 = self:getFlagByTag(1)	
	local flag2	= self:getFlagByTag(2)	
	if flag1==2 or flag2==2 then
		isfree=true	
	end	
	return isfree
end

function acYueduHeroVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	local lastTime=vo.lastTime or 0
	if lastTime then
		isToday=G_isToday(lastTime)
	end
	return isToday
end

function acYueduHeroVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime=time
end

function acYueduHeroVoApi:getCost(tag)
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost[tag] 
	end
end

function acYueduHeroVoApi:getRecord(tag)
	local vo=self:getAcVo()
	if vo and vo.record then
		return vo.record[tag] 
	end
	return 0
end

function acYueduHeroVoApi:setRecord(tag,num)
	local vo=self:getAcVo()
	if vo and vo.record then
		vo.record[tag]=num 
	end
end

function acYueduHeroVoApi:getFlag(tag)
	local vo=self:getAcVo()
	if vo and vo.flag then
		return vo.flag[tag] 
	end
end

function acYueduHeroVoApi:setFlag(tag,num)
	local vo=self:getAcVo()
	if vo and vo.flag then
		vo.flag[tag]=num
	end
end

function acYueduHeroVoApi:getRewardById(id)
	local vo=self:getAcVo()
	local reward = vo.reward
	local rewardItem=FormatItem(reward[id],nil,true)
	return rewardItem
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acYueduHeroVoApi:addGold(money)
	local vo = self:getAcVo()
	if vo ~= nil then
		vo.record[2] = vo.record[2] + money
		vo.stateChanged = true -- 强制更新数据
	end
end

-- tag 1：军工领取  2：金币充值
-- flag 1:未达到领取条件 2：达到领取条件但是未领取 3：已领取
function acYueduHeroVoApi:getFlagByTag(tag)
	local flag=1
	if tag==1 then
		local flag1=self:getFlag(tag)
		if flag1==1 then
			return 3
		end
		local record1 = self:getRecord(tag)
		local cost1 = self:getCost(tag)
		if cost1 and record1 and record1>=cost1 then
			return 2
		else
			return 1
		end
	else
		local flag2=self:getFlag(tag)

		if flag2==1 then
			return 3
		end
		local record2 = self:getRecord(tag)
		local cost2 = self:getCost(tag)
		if cost2 and record2 and record2>=cost2 then
			return 2
		else
			return 1
		end
	end
end

function acYueduHeroVoApi:getIconReward()
	local reward = self:getRewardById(1)
	local item 
	for k,v in pairs(reward) do
		if v.index==1 then
			item=v
			break
		end
	end
	return item
end

function acYueduHeroVoApi:kuaTianRefresh()
	self:setLastTime(base.serverTime)
    self:setRecord(1,0)
    self:setRecord(2,0)
    self:setFlag(1,0)
    self:setFlag(2,0)
end


function acYueduHeroVoApi:clearAll()
end