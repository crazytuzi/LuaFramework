acDailyEquipPlanVoApi={
	heroEquipTask={},
	taskStateCfg={FINISHED=1,UNFINISH=2,HAS_REWARD=3} --任务的状态配置，该配置在切换账号时不能清空
}

function acDailyEquipPlanVoApi:getAcVo()
	if self.vo == nil then
		self.vo = activityVoApi:getActivityVo("dailyEquipPlan")
	end
	return self.vo
end

--判断是否有任务奖励领取
function acDailyEquipPlanVoApi:canReward()
	local vo = self:getAcVo()
	if vo then
		-- for k,v in pairs(vo.tasklistCfg) do
		-- 	print(k,v)
		-- end
		if vo.tasklistCfg and SizeOfTable(vo.tasklistCfg)>0 and vo.taskData and SizeOfTable(vo.taskData)>0 then
			for k,t in pairs(vo.taskData) do
				local tid=tostring(k)
				if t>=vo.tasklistCfg[tid][1] then
					return true
				end
			end
		end
	end
	return false
end

function acDailyEquipPlanVoApi:getTimeStr()
	local vo = self:getAcVo()
	local timeStr = activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

--获取当前任务数据
function acDailyEquipPlanVoApi:getTaskData()
	return self.heroEquipTask
end

--根据后台发来的数据初始化任务数据
function acDailyEquipPlanVoApi:initTaskData()
	if self:isToday()==false then
		-- print("==========重置任务数据==========")
		self:resetTaskData()
	end
	local vo = self:getAcVo()
	if vo then
		if vo.tasklistCfg and vo.taskData and SizeOfTable(self.heroEquipTask)==0 then
			for k,taskCfg in pairs(vo.tasklistCfg) do
				local task={}
				task.tid=tostring(k)
				task.curTimes=0
				task.maxTimes=taskCfg[1]
				task.rewardCfg=taskCfg[2]
				task.index=taskCfg[3]
				task.hasRewarded=false
				if vo.taskData[task.tid] then			
					if vo.taskData[task.tid]<0 then
						task.curTimes=task.maxTimes
						task.hasRewarded=true
					else
						task.curTimes=vo.taskData[task.tid]
					end
				end
				task.state=self:getTaskState(task)
				task.desc=getlocal("activity_dailyequip_des_"..k,{task.maxTimes})
				table.insert(self.heroEquipTask,task)
			end
			local function initPos(a,b)
				return a.index<b.index			
			end
			table.sort(self.heroEquipTask,initPos)
		elseif SizeOfTable(self.heroEquipTask)>0 then
			self:updateTaskData()
		end
		self:sortTaskList()
	end
end

function acDailyEquipPlanVoApi:resetTaskData()
	local vo = self:getAcVo()
	if vo then
		vo.taskData={}
		self.heroEquipTask={}
	end
end

function acDailyEquipPlanVoApi:updateData(data)
	local acVo = self:getAcVo()
	if acVo then
		acVo:updateSpecialData(data)
		self:updateTaskData()
	end
end

--根据后台同步来的数据来更新任务数据
function acDailyEquipPlanVoApi:updateTaskData()
	--更新任务进度
	local vo = self:getAcVo()
	if vo==nil then
		return
	end
	if self.heroEquipTask and vo.taskData then
		for k,task in pairs(self.heroEquipTask) do
			if vo.taskData[task.tid] then			
				if vo.taskData[task.tid]<0 then
					task.curTimes=task.maxTimes
					task.hasRewarded=true
				else
					task.curTimes=vo.taskData[task.tid]
				end
			end
			task.state=self:getTaskState(task)
		end
		--更新完成后按照规则对任务列表排序
		self:sortTaskList()
	end
end

--根据任务是否完成或是否领取完奖励来进行排序
function acDailyEquipPlanVoApi:sortTaskList()
	local function sortFunc(task1,task2)
		return task1.state<task2.state
	end
	if self.heroEquipTask then
		table.sort(self.heroEquipTask,sortFunc)
	
	end
end

function acDailyEquipPlanVoApi:getTaskState(task)
	local state=self.taskStateCfg.UNFINISH
	if task then
		if task.curTimes<task.maxTimes then
			state=self.taskStateCfg.UNFINISH
		elseif task.curTimes>=task.maxTimes and task.hasRewarded==false then
			state=self.taskStateCfg.FINISHED
		elseif task.hasRewarded==true then
			state=self.taskStateCfg.HAS_REWARD
		end
	end
	return state
end

--玩家等级在20级及以上才能参加活动
function acDailyEquipPlanVoApi:isCanJoinActivity()
	local curLevel = playerVoApi:getPlayerLevel()
	local limitLv
	if(base.heroEquipOpenLv)then
		limitLv=base.heroEquipOpenLv
	else
		limitLv=30
	end
	if tonumber(curLevel) >= limitLv then
		return true,limitLv
	end
	return false,limitLv
end

function acDailyEquipPlanVoApi:getTaskStateCfg()
	return self.taskStateCfg
end

function acDailyEquipPlanVoApi:isToday()
	local flag = false
	local vo=self:getAcVo()
	if vo then
		flag=G_isToday(vo.t)
	end
	return flag
end

function acDailyEquipPlanVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acDailyEquipPlanVoApi:clearAll()
	self.heroEquipTask={}
	self.vo=nil
end
