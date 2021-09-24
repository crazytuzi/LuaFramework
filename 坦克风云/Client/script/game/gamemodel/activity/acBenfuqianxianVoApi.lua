acBenfuqianxianVoApi={
	task=nil,
    flickRewards=nil,
	flag={},
	lastIntegral=nil,
}

function acBenfuqianxianVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("benfuqianxian")
	end
	return self.vo
end

function acBenfuqianxianVoApi:canReward()
	local flag=false
	local vo=self:getAcVo()
	if vo then
		local integralLvCfg=self:getIntegralLvCfg()
		for k,v in pairs(integralLvCfg) do
			local state=self:getStateByIntegralLv(k)
			if state==2 then
				flag=true
				do break end
			end
		end
	end

	return flag
end

function acBenfuqianxianVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
		str=getlocal("activity_timeLabel")..":".."\n"..timeStr
	end

	return str
end

function acBenfuqianxianVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acBenfuqianxianVoApi:getIntegralLvCfg()
	local vo=self:getAcVo()
	if vo then
		return vo.need
	end
	return {}
end

function acBenfuqianxianVoApi:getRewardsByIntegralLv(lv)
	local rewards={}
	local vo=self:getAcVo()
	if vo then
		if vo.reward and vo.reward[lv] then
			rewards=vo.reward[lv]
		end
	end
	return rewards
end

function acBenfuqianxianVoApi:getFlickRewards()
	if self.flickRewards==nil then
		local vo=self:getAcVo()
		if vo then
			if vo.flickReward then
				self.flickRewards=vo.flickReward
				self.flickRewards=FormatItem(self.flickRewards)
			end
		end
	end

	return self.flickRewards
end

function acBenfuqianxianVoApi:isFlick(rewardKey)
	local flag=false
	if rewardKey then
		local flickRewards=self:getFlickRewards()
		for k,v in pairs(flickRewards) do
			if v.key==rewardKey then
				flag=true
			end
		end
	end
	return flag
end

--获取各个充值等级的状态 1：还未达到 2：已达到 3：已领取
function acBenfuqianxianVoApi:getStateByIntegralLv(lv)
 	local state=1
 	local vo=self:getAcVo()
 	local integralLvCfg=self:getIntegralLvCfg()
 	if vo and vo.hasRewardTb and vo.integral and integralLvCfg and integralLvCfg[lv] then
 		if tonumber(vo.integral)<tonumber(integralLvCfg[lv]) then
 			state=1
		elseif self:hasRewarded(lv)==false then
			state=2
		else
 			state=3
 		end
 	end
 	return state
end

function acBenfuqianxianVoApi:hasRewarded(lv)
	local rewardFlag=false
 	local vo=self:getAcVo()
	if vo and vo.hasRewardTb then
		for k,v in pairs(vo.hasRewardTb) do
			if tonumber(v)==tonumber(lv) then
				rewardFlag=true
				do break end
			end
		end
	end
	return rewardFlag
end

function acBenfuqianxianVoApi:getIntegralCount()
	local count=0
	local vo=self:getAcVo()
	if vo and vo.integral then
		count=math.floor(tonumber(vo.integral))
	end
	return count
end

function acBenfuqianxianVoApi:getIntegralPercent()
	local per=0
	local vo=self:getAcVo()
	if vo then
		local integralCount=self:getIntegralCount()
		local integralLvCfg=self:getIntegralLvCfg()
		local numDuan=SizeOfTable(integralLvCfg)
		if numDuan==0 then
			numDuan=4
		end
		local everyPer=100/numDuan
		local diDuan=0 
		for i=1,numDuan do
			if integralCount<=tonumber(integralLvCfg[i]) then
				diDuan=i
				break
			end
		end

		if integralCount>=integralLvCfg[numDuan] then
			per=100
		elseif diDuan==1 then
			per=integralCount/integralLvCfg[1]/numDuan*100
		else
			per=(diDuan-1)*everyPer+(integralCount-integralLvCfg[diDuan-1])/(integralLvCfg[diDuan]-integralLvCfg[diDuan-1])/numDuan*100
		end
	end
	return per	
end

function acBenfuqianxianVoApi:getLastIntegral()
	return self.lastIntegral
end

function acBenfuqianxianVoApi:setLastIntegral(integral)
	self.lastIntegral=tonumber(integral)
end

function acBenfuqianxianVoApi:initTasks()
	if self.task==nil then
		self.task={}
		local vo=self:getAcVo()
		if vo and vo.task and vo.taskData then
			for k,item in pairs(vo.task) do
				local taskItem={}
				taskItem.tid=tostring(k) --表示购买道具的位置
				taskItem.cur=tonumber(vo.taskData[k]) or 0
				taskItem.max=tonumber(item[1])
				taskItem.exchange=1
				taskItem.exchangePoint=tonumber(item[2])
				if taskItem.exchangePoint<1 then
					local rate=1/taskItem.exchangePoint
					taskItem.exchangePoint=taskItem.exchangePoint*rate
					taskItem.exchange=taskItem.exchange*rate
				end
				taskItem.curPoint=math.floor(taskItem.cur/taskItem.exchange)*taskItem.exchangePoint
				taskItem.maxPoint=math.floor(taskItem.max/taskItem.exchange)*taskItem.exchangePoint
				taskItem.sortId=tonumber(item[3])
				table.insert(self.task,taskItem)
			end
		end
	end
end

function acBenfuqianxianVoApi:updateTasks()
	local vo=self:getAcVo()
	if self.task and vo.taskData then
		for k,item in pairs(self.task) do
			item.cur=tonumber(vo.taskData[item.tid]) or 0
			item.curPoint=math.floor(item.cur/item.exchange)*item.exchangePoint
		end
		self:sortTaskList()
	end
end

function acBenfuqianxianVoApi:sortTaskList()
	if self.task==nil then
		return
	end
	local function sortFunc(task1,task2)
		local sortWeight1=(task1.max-task1.cur>0) and (10*task1.sortId) or (100*task1.sortId)
		local sortWeight2=(task2.max-task2.cur>0) and (10*task2.sortId) or (100*task2.sortId)

		return sortWeight1<sortWeight2
	end
	table.sort(self.task,sortFunc)
end

function acBenfuqianxianVoApi:getTasks()
	if self.task==nil then
		self:initTasks()
	else
		self:updateTasks()
	end
	return self.task
end

function acBenfuqianxianVoApi:getTaskContent(task)
	local desc
	local exchangeStr
	local titleStr
	local iconStr
	local hasBg=true
	local btnName="activity_heartOfIron_goto"
	if task and task.tid then
		local tid=task.tid
		if tostring(tid)=="t1" then
			desc="attack_player_task"
			exchangeStr="attack_exchange"
			iconStr="item_attack_player_success.png"
		elseif tostring(tid)=="t2" then
			desc="attack_wildmine_task"
			exchangeStr="attack_exchange"
			iconStr="item_attack_wild.png"
		elseif tostring(tid)=="t3" then
			desc="help_attack_task"
			exchangeStr="fight_help_exchange"
			iconStr="icon_help_defense.png"
		elseif tostring(tid)=="t4" then
			desc="alliance_medals_task"
			exchangeStr="alliance_medals_exchange"
			iconStr="rpCoin.png"
			hasBg=false
		elseif tostring(tid)=="t5" then
			desc="recharge_gems_task"
			exchangeStr="gems_exchange"
			iconStr="resourse_normal_gem.png"
			btnName="recharge"
		end
		if desc and exchangeStr then
			desc=getlocal(desc,{task.cur.."/"..task.max})
			exchangeStr=getlocal(exchangeStr,{task.exchange,task.exchangePoint..getlocal("bfqx_intelligence")})
			titleStr=getlocal("bfqx_task_title"..RemoveFirstChar(tid))
		end
	end
	return desc,exchangeStr,titleStr,iconStr,hasBg,btnName
end

function acBenfuqianxianVoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acBenfuqianxianVoApi:receiveRewardsRequest(rewardId,callback)
	local function rewardCallback(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.benfuqianxian then
            	self:updateData(sData.data.benfuqianxian)
            end
            local rewards=acBenfuqianxianVoApi:getRewardsByIntegralLv(rewardId)
            if rewards then
    	      	local award=FormatItem(rewards) or {}
				for k,v in pairs(award) do
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
				end
				G_showRewardTip(award)
            end
            if callback then
            	callback()
            end
        end
    end
	local state=self:getStateByIntegralLv(rewardId)
	if state==2 then
		socketHelper:receiveIntegralRewards(rewardId,rewardCallback)
	end
end

function acBenfuqianxianVoApi:getNeedNoticeCfg()
	local notice={}
	local vo=self:getAcVo()
	if vo and vo.needNotice then
		notice=vo.needNotice
	end
	return notice
end

function acBenfuqianxianVoApi:getFlag(idx)
	if SizeOfTable(self.flag)==0 then
		return -1
	elseif idx and self.flag[idx] then
		return self.flag[idx]
	else
		return -1
	end
end

function acBenfuqianxianVoApi:setFlag(idx,flag)
	self.flag[idx]=flag
end

function acBenfuqianxianVoApi:setAllFlag()
    for i=1,2 do
        self.flag[i]=0
    end
end

function acBenfuqianxianVoApi:tick()
end

function acBenfuqianxianVoApi:clearAll()
	self.task=nil
    self.flickRewards=nil
	self.flag={}
	self.lastIntegral=nil
	self.vo=nil
end