acOlympicCollectVoApi={
	isRefresh=false
}

function acOlympicCollectVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("aoyunjizhang")
	end
	return self.vo
end

function acOlympicCollectVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

function acOlympicCollectVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
		str=getlocal("activity_timeLabel")..":".."\n"..timeStr
	end

	return str
end

function acOlympicCollectVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acOlympicCollectVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acOlympicCollectVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end

	if vo.taskPoint then
		local taskPoint=vo.taskPoint
		local numberCell=SizeOfTable(taskPoint)
		-- 任务点是否有领取的奖励
		for i=1,numberCell do
			local flag=self:taskPointState(i,taskPoint)
			if flag==2 then
				return true
			end
		end
	end
	local dayNum=self:getNumOfDay()
	for i=1,dayNum do
		if vo.taskList and vo.taskList[i] then
			local taskNum=SizeOfTable(vo.taskList[i])
			local flag=self:isCanGetCurReward(i,taskNum)
			if flag==2 then
				return true
			end
		end
	end
	if vo.day and vo.taskList then
		for k,v in pairs(vo.taskList) do
			for kk,vv in pairs(v) do
				local flag=self:getTaskState(k,kk,vv[1][1],vv[1][2])
				if flag==2 then
					return true
				end
			end

		end
	end
	return false
end

--获取某一天的项目信息
function acOlympicCollectVoApi:getDayOfEvent(dayIdx)
	local vo=self:getAcVo()
	local pic="olympic_event"..dayIdx..".png"
	local name=getlocal("olympic_event_name"..dayIdx) or ""
	local desc=getlocal("olympic_event_desc"..dayIdx) or ""
	local openDay=vo.st+(dayIdx-1)*24*3600
	return pic,name,desc,openDay
end

-- 得到某一天的任务列表
function acOlympicCollectVoApi:getDayOfTask(idx)
	local vo=self:getAcVo()
	if vo and vo.taskList then
		return vo.taskList[idx]
	end
	return {}
end

-- 得到某一天的任务列表
function acOlympicCollectVoApi:getTaskPoint()
	local vo=self:getAcVo()
	if vo and vo.taskPoint then
		return vo.taskPoint
	end
	return {}
end

-- 完成某一天的任务所得奖励
function acOlympicCollectVoApi:getDayOfTaskReward(idx)
	local vo=self:getAcVo()
	if vo and vo.taskAllFinReward then
		return vo.taskAllFinReward[idx]
	end
	return {}
end

-- 任务点所得奖励
function acOlympicCollectVoApi:getTaskPointReward(idx)
	local vo = self:getAcVo()
	if vo and vo.taskPointReward then
		return vo.taskPointReward[idx]
	end
	return {}
end

-- 现在活动是第几天
function acOlympicCollectVoApi:getNumDayOfActive()
	local vo = self:getAcVo()
	local st = vo.st
	local weeTs = G_getWeeTs(st)
	local currDay = math.floor(math.abs(base.serverTime-weeTs)/(24*3600)) + 1

	return currDay
end

-- 某一天的任务完成进度
function acOlympicCollectVoApi:getDayTaskProgress(day)
	local vo=self:getAcVo()
	local dayTb=vo.day or {}
	local numDayTb=dayTb["d" .. day] or {}
	local tkTb=numDayTb.tk or {}
	local taskList=self:getDayOfTask(day)
	local alreadyNum=0
	for k,v in pairs(taskList) do
		local num=tkTb[v[1][1]] or 0
		if tonumber(num)>=tonumber(v[1][2]) then
			alreadyNum=alreadyNum+1
		end
		-- print("+++++++num,v[1][2]",num,v[1][2])
	end
	local allNum=SizeOfTable(taskList)
	-- print("+++++++++++day",day,alreadyNum)

	return alreadyNum,allNum
end

-- 某一天某一个的任务完成进度
function acOlympicCollectVoApi:getTypeTaskProgress(day,type)
	local vo = self:getAcVo()
	local dayTb = vo.day or {}
	local numDayTb = dayTb["d" .. day] or {}
	local tkTb = numDayTb.tk or {}
	local tkNum = tkTb[type] or 0
	return tkNum
end

-- 得到任务状态
-- day 第几天
-- idx 第几个任务
-- type 任务类型
-- num 一个任务需要完成的次数
-- return 1:已结束 2:能领取 3:已领取 4:前往 5:未开启（时间还没到）
function acOlympicCollectVoApi:getTaskState(day,idx,type,num)
	local vo=self:getAcVo()
	local dayTb=vo.day or {}
	local numDayTb=dayTb["d" .. day] or {}
	local tkTb=numDayTb.tk or {}
	local finTb=numDayTb.fin or {}
	local gf=numDayTb.gf or 0
	local nowDay=self:getNumDayOfActive()

	local tkNum=tkTb[type] or 0
	local finFlag=finTb["t" .. idx] or 0

	if day>nowDay then
		return 5
	end
	if finFlag==1 then
		return 3
	end
	if nowDay>=day then
		if type=="au" then
			if accessoryVoApi:strengIsFull() then
				return 2,"au"
			end
		end
		if type=="wp" then
			if superWeaponVoApi:isCanPlunder() then
				return 2,"wp"
			end
		end

		if type=="hu" then
			if heroEquipVoApi:isCanStreng() then
				return 2,"hu"
			end
		end
		if type=="rc" then
			if alienTechVoApi:isCanUpdate() then
				return 2,"rc"
			end
		end
	end
	-- 任务没完成，过去
	if tkNum<num and nowDay>day then
		return 1
	end
	-- 任务没完成，未来或者当天
	if tkNum<num and nowDay<=day then
		return 4
	end
	-- 任务完成，没领取
	if tkNum>=num and finFlag==0 then
		return 2
	end
	return 3
end

-- 是否能领取当天大礼包
-- 1：不能领取 2：能领取 3:已领取 4:已结束
function acOlympicCollectVoApi:isCanGetCurReward(day,cellNum)
	local vo=self:getAcVo()
	local dayTb=vo.day or {}
	local nowDay=self:getNumDayOfActive()
	local numDayTb=dayTb["d" .. day] or {}
	local gf=numDayTb.gf or 0
	if gf==1 then
		return 3
	end
	local numTask=self:getDayTaskProgress(day)
	if numTask<cellNum then
		if nowDay>day then
			return 4
		end
		return 1
	end
	return 2
end

-- 自己当前的任务点
function acOlympicCollectVoApi:getMyPoint()
	local vo=self:getAcVo()
	if vo and vo.myPoint then
		return vo.myPoint
	end
	return 0
end

-- 1:已领取 2：可领取 3：未达到条件
function acOlympicCollectVoApi:taskPointState(index,taskPoint)
	local vo=self:getAcVo()
	local tbox=vo.tbox or {}
	local flag=tbox["tb" .. index] or 0
	if flag==1 then
		return 1
	end

	local myPoint=self:getMyPoint()
	if taskPoint[index]<=myPoint then
		return 2
	end
	return 3
end

function acOlympicCollectVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
	activityVoApi:updateShowState(vo)
end

function acOlympicCollectVoApi:getNumOfDay()
	local vo=self:getAcVo()
	if vo and vo.taskList then
		return SizeOfTable(vo.taskList)
	end
	return 2
end

function acOlympicCollectVoApi:getPercentage()
	local alreadyCost=self:getMyPoint()
	local cost=self:getTaskPoint()
	local numDuan=SizeOfTable(cost)
	local per=0
	if numDuan==0 then
		numDuan=5
	end
	local everyPer=100/numDuan

	local per=0

	local diDuan=0 
	for i=1,numDuan do
		if alreadyCost<=cost[i] then
			diDuan=i
			break
		end
	end

	if alreadyCost>=cost[numDuan] then
		per=100
	elseif diDuan==1 then
		per=alreadyCost/cost[1]/numDuan*100
	else
		per=(diDuan-1)*everyPer+(alreadyCost-cost[diDuan-1])/(cost[diDuan]-cost[diDuan-1])/numDuan*100
	end
	-- print("+++++++++++")
	return per
	-- if cost[numDuan]<=0 then
	-- 	per=0
	-- elseif alreadyCost>=cost[numDuan] then
	-- 	per=100
	-- else
	-- 	per=(alreadyCost/cost[numDuan])*100
	-- end
	-- return per
end

-- 领取每日任务奖励
function acOlympicCollectVoApi:getSocketReward(action,day,tid,callback,taskType)
	local function rewardCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.aoyunjizhang then
				self:updateData(sData.data.aoyunjizhang)
			end
			if callback then
				callback()
			end
		end
	end
	socketHelper:acOlympicTaskReward(action,day,tid,taskType,rewardCallback)
end

function acOlympicCollectVoApi:showSmallDialog(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
	local sd=acChunjiepanshengSmallDialog:new()
	sd:init(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi)
end

function acOlympicCollectVoApi:setRefresh(refresh)
	self.isRefresh=refresh
end

function acOlympicCollectVoApi:isNeedRefresh()
	return self.isRefresh
end

function acOlympicCollectVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acOlympicCollectVoApi:clearAll()
	self.isRefresh=false
	self.vo=nil
end