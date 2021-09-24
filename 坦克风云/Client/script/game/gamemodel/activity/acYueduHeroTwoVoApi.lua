acYueduHeroTwoVoApi={}

-- 这里需要修改
function acYueduHeroTwoVoApi:getAcVo()
	return activityVoApi:getActivityVo("ydjl2")
end

function acYueduHeroTwoVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acYueduHeroTwoVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acYueduHeroTwoVoApi:canReward()
	local isfree=false		
	local flag1 = self:getFlagByTag(1)	
	local flag2	= self:getFlagByTag(2)	
	if flag1==2 or flag2==2 then
		isfree=true	
	end	
	return isfree
end

function acYueduHeroTwoVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	local lastTime=vo.lastTime or 0
	if lastTime then
		isToday=G_isToday(lastTime)
	end
	return isToday
end

function acYueduHeroTwoVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		--该活动没有领奖日，故不再需要减一天了时间了
		-- local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
		local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end
	return str
end

function acYueduHeroTwoVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime=time
end

function acYueduHeroTwoVoApi:getIsRef(tag)
	local vo=self:getAcVo()
	if vo and vo.isRef then
		return vo.isRef[tag]
	end
	return 0
end

function acYueduHeroTwoVoApi:setIsRef(isRefTb)
	local vo=self:getAcVo()
	if vo and isRefTb then
		vo.isRef = isRefTb
	elseif isRefTb == nil then
		vo.isRef[1] = 0
		vo.isRef[2] = 0
	end
end

function acYueduHeroTwoVoApi:getCurRewardTb( )--后台推过来的库编号，只用于领取奖励时区别第几个库使用
	local vo = self:getAcVo()
	if vo and vo.refKey then
		return vo.refKey
	end
end

function acYueduHeroTwoVoApi:setCurRewardTb(newReward)
	local vo = self:getAcVo()
	if vo and newReward then
		vo.refKey = newReward
		vo.reward[1]=vo.allReward[1][vo.refKey[1]]
        vo.reward[2]=vo.allReward[2][vo.refKey[2]]
	end
end


function acYueduHeroTwoVoApi:getCost(tag)
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost[tag] 
	end
end

function acYueduHeroTwoVoApi:getRecord(tag)
	local vo=self:getAcVo()
	if vo and vo.record then
		return vo.record[tag] 
	end
	return 0
end

function acYueduHeroTwoVoApi:setRecord(tag,num)
	local vo=self:getAcVo()
	if vo and vo.record then
		vo.record[tag]=num 
	end
end

function acYueduHeroTwoVoApi:getFlag(tag)
	local vo=self:getAcVo()
	if vo and vo.flag then
		return vo.flag[tag] 
	end
end

function acYueduHeroTwoVoApi:setFlag(tag,num)
	local vo=self:getAcVo()
	if vo and vo.flag then
		vo.flag[tag]=num
	end
end

function acYueduHeroTwoVoApi:getRewardById(id)
	local vo=self:getAcVo()
	local reward = vo.reward
	local rewardItem=FormatItem(reward[id],nil,true)
	return rewardItem
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acYueduHeroTwoVoApi:addGold(money)
	local vo = self:getAcVo()
	if vo ~= nil then
		if(vo.record==nil)then
			vo.record={0,0}
		end
		vo.record[2] = vo.record[2] + money
		vo.stateChanged = true -- 强制更新数据
	end
end

-- tag 1：军工领取  2：金币充值
-- flag 1:未达到领取条件 2：达到领取条件但是未领取 3：已领取
function acYueduHeroTwoVoApi:getFlagByTag(tag)
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

function acYueduHeroTwoVoApi:getIconReward()
	local vo=self:getAcVo()
	local reward = vo.allReward[1][1]

	local rewardItem=FormatItem(reward[id],nil,true)

	return rewardItem
end

function acYueduHeroTwoVoApi:kuaTianRefresh()
	self:setLastTime(base.serverTime)
    self:setRecord(1,0)
    self:setRecord(2,0)
    self:setFlag(1,0)
    self:setFlag(2,0)
    self:setIsRef()
end

--获取刷新次数
function acYueduHeroTwoVoApi:getRefreshTb()
	local vo = self:getAcVo()
	if vo then
		return vo.refresh
	end
	return {1,1}
end

function acYueduHeroTwoVoApi:clearAll()
end