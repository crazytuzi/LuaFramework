acThrivingVoApi={
	curChooseDay = 0,
	whiTask = 0,
	taskcmpltNums = 0,
}

function acThrivingVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("zzrs")
	end
	return self.vo
end
function acThrivingVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acThrivingVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acThrivingVoApi:getActiveName()
	return "zzrs"
end
function acThrivingVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.t then
		isToday=G_isToday(vo.t)
	end
	return isToday
end
function acThrivingVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acThrivingVoApi:canReward()
	return self:getCanAwardNow( )
end

function acThrivingVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
	return activeTime,G_formatActiveDate(vo.et - base.serverTime)
end

function acThrivingVoApi:isInLastDay()
	local vo=self:getAcVo()
	local isIn = vo.et - base.serverTime <= 86400 and true or false
	return isIn
end


function acThrivingVoApi:getCurDays( )--当前第几天
	local vo = self:getAcVo()
	local day = math.ceil((base.serverTime - vo.st)/86400)
	-- print("cur active-day------->>>>",day)
	return day > 5 and 5 or day
end

function acThrivingVoApi:gethadBigAward( )
	local vo = self:getAcVo()
	if vo and vo.hadBigAward then
		return vo.hadBigAward
	end
	return 1 -- 1领过
end
function acThrivingVoApi:sethadBigAward(hadBigAward)
	local vo = self:getAcVo()
	if vo and hadBigAward then
		vo.hadBigAward = hadBigAward
	end
end

function acThrivingVoApi:getCanAwardNow( )
	local vo = self:getAcVo()
	local taskTb,taskClassTb = vo.taskList,vo.taskClassTb
	local isCan,CanAwardTb,canAwardDayTb = false,{},{}
	local curDay=acThrivingVoApi:getCurDays()
	if taskTb and taskClassTb then
		for i=1,SizeOfTable(taskTb) do
			CanAwardTb[i] = {}
			canAwardDayTb[i] = false
			for j=1,SizeOfTable(taskTb["d"..i]) do
				CanAwardTb[i][j] = false
				local qNeedTb = taskTb["d"..i]["q"..j]["need"]
				local curTaskType = taskClassTb[i][j]
				curTaskType = curTaskType =="gba" and "gb" or curTaskType
				-- print("curTaskType==========>>>>",curTaskType,vo.cpltTaskNumTb[curTaskType])
				local fullFlag
				if(i<=curDay)then
					fullFlag=acThrivingVoApi:checkTypeFull(curTaskType)
				end
				if vo.cpltTaskNumTb[curTaskType] or fullFlag then --对应类型任务完成的次数
					if vo.hasBeenRecAwardTb[curTaskType] then--对应类型任务已领取奖励的次数
						if SizeOfTable(vo.hasBeenRecAwardTb[curTaskType]) >= SizeOfTable(qNeedTb) then
						
						else
							local mayAwardIdx = 1
							for i=1,SizeOfTable(qNeedTb) do
								if qNeedTb[i] < vo.cpltTaskNumTb[curTaskType] and i < SizeOfTable(qNeedTb) then
									mayAwardIdx = mayAwardIdx + 1
								end
							end
							-- print("i-----j--mayAwardIdx---->>>>",i,j,mayAwardIdx)
							-- print("??????",mayAwardIdx , SizeOfTable(vo.hasBeenRecAwardTb[curTaskType]) , vo.cpltTaskNumTb[curTaskType],qNeedTb[mayAwardIdx])

							if mayAwardIdx > SizeOfTable(vo.hasBeenRecAwardTb[curTaskType]) and vo.cpltTaskNumTb[curTaskType] >= qNeedTb[mayAwardIdx] then
								CanAwardTb[i][j],isCan = true,true
								canAwardDayTb[i] = true
								-- print("i====j=======>>>>",i,j)
							end	
						end
					elseif fullFlag or vo.cpltTaskNumTb[curTaskType] >= qNeedTb[1] then
						CanAwardTb[i][j],isCan = true,true
						canAwardDayTb[i] = true
						-- print("i====j====222222===>>>>",i,j)
					end
				end
			end
		end
	end
	return isCan,CanAwardTb,canAwardDayTb
end

function acThrivingVoApi:checkTypeFull(taskType)
	if taskType=="au" then
		if accessoryVoApi:strengIsFull() then
			return true
		end
	elseif taskType=="wp" then
		if superWeaponVoApi:isCanPlunder() then
			return true
		end
	elseif taskType=="hu" then
		if heroEquipVoApi:isCanStreng() then
			return true
		end
	elseif taskType=="rc" then
		if alienTechVoApi:isCanUpdate() then
			return true
		end
	end
	return false
end

function acThrivingVoApi:getCurCompletedTaskNums( )
	local vo = self:getAcVo()
	local taskTb,taskClassTb = vo.taskList,vo.taskClassTb
	local needTb = {}
	self.taskcmpltNums = 0
	-- if self.taskcmpltNums == 0 then
		for i=1,SizeOfTable(taskTb) do
			for j=1,SizeOfTable(taskTb["d"..i]) do

				local qNeedTb = taskTb["d"..i]["q"..j]["need"]
				local curTaskType = taskClassTb[i][j]
				curTaskType = curTaskType =="gba" and "gb" or curTaskType
				if vo.cpltTaskNumTb[curTaskType] then
					for m=1,SizeOfTable(qNeedTb) do
						if vo.cpltTaskNumTb[curTaskType] >= qNeedTb[m]	then
							self.taskcmpltNums = self.taskcmpltNums + 1
						end
					end

				end
			end
		end
	-- end
	self.taskcmpltNums = self.taskcmpltNums > 100 and 100 or self.taskcmpltNums
	local curAwardNums = math.floor(self.taskcmpltNums/SizeOfTable(vo.bigRewardTb))
	-- print("curAwardNums=========>>>>",curAwardNums,self.taskcmpltNums)
	return self.taskcmpltNums,curAwardNums*10
end

function acThrivingVoApi:setCompletTaskTb(cpltTaskNumTb)
	local vo = self:getAcVo()
	if vo and cpltTaskNumTb then
		vo.cpltTaskNumTb = cpltTaskNumTb
	end
end
function acThrivingVoApi:setHasBeenRecAwardTb(newHasBeenRecAwardTb)
	local vo = self:getAcVo()
	if vo and newHasBeenRecAwardTb then
		vo.hasBeenRecAwardTb = newHasBeenRecAwardTb
	end
end

function acThrivingVoApi:socketByCall(typeName,chooseDay,taskNeedNum,showCellAward)
	local function getCellAwardCall(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
        	if sData and sData.data and sData.data.zzrs then
        		self:updateData(sData.data.zzrs)
        		if sData.data.zzrs.rd then
        			print("set success~~~~!!!!!!")
	        		self:setHasBeenRecAwardTb(sData.data.zzrs.rd)
	        	end
        	end
            for k,v in pairs(showCellAward) do
				G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
			end
			G_showRewardTip(showCellAward,true)
        end
    end
    typeName = typeName =="gba" and "gb" or typeName
    socketHelper:acThrivingRequest("active.zzrs.reward",{action=typeName,day=chooseDay,num=taskNeedNum},getCellAwardCall)
end

----------------------------------------------------------------------------------------------------------------------------

function acThrivingVoApi:getHadTaskNumTb( )
	local vo  = self:getAcVo()
	if vo and vo.cpltTaskNumTb then
		return vo.cpltTaskNumTb
	end
end

function acThrivingVoApi:getTaskClassTb(bigTb,smlTb)
	local vo  = self:getAcVo()
	if vo and vo.taskClassTb then
		if vo.taskClassTb[bigTb] and vo.taskClassTb[bigTb][smlTb] then
			return vo.taskClassTb[bigTb][smlTb]
		end
	end
	print("error:Don't has taskClassTb~~~~~")
	return nil
end	

function acThrivingVoApi:isRec(typeName,needNum)
	local vo = self:getAcVo()
	if vo and vo.hasBeenRecAwardTb and vo.hasBeenRecAwardTb[typeName] then
		for k,v in pairs(vo.hasBeenRecAwardTb[typeName]) do
			if tonumber(v) == needNum then
				return true
			end
		end
	end
	return nil
end

function acThrivingVoApi:getTaskDays()
	-- taskList
	local vo = self:getAcVo()
	if vo.taskList then
		return SizeOfTable(vo.taskList) > 5 and 5 or SizeOfTable(vo.taskList)
	end
	-- print("error~~~~~~ writedeath getTaskDays====>>>>FIVE~~~~~~")
	return 5
end

function acThrivingVoApi:getCurDayTaskTb(curTaskDays)--curTaskDays 当前是第几天

	local vo = self:getAcVo()
	if vo.taskList then
		return vo.taskList["d"..curTaskDays]
	end
	-- print("error~~~~~~getCurDayTaskTb~~~~~~~~~~~~")
	return {}
end
function acThrivingVoApi:setCurChooseDayTask(curChooseDay,whiTask)
	self.curChooseDay,self.whiTask = curChooseDay,whiTask
end
function acThrivingVoApi:getCurChooseDayTask()
	local vo = self:getAcVo()
	if vo.taskList["d"..self.curChooseDay]["q"..self.whiTask] then
		return vo.taskList["d"..self.curChooseDay]["q"..self.whiTask]["reward"],self.curChooseDay,self.whiTask,vo.taskList["d"..self.curChooseDay]["q"..self.whiTask]["need"]
	end
	-- print("error------getCurChooseDayTask---self.curChooseDay,self.whiTask------->>>",self.curChooseDay,self.whiTask)
	return {},self.curChooseDay,self.whiTask
end


----------------------------------------------------------------------------------------------------------------------------
function acThrivingVoApi:getIconColor(dIdx,tIdx,cellIdx,rIdx)
	local vo = self:getAcVo()
	if vo.taskList then
		if vo.taskList["d"..dIdx] and vo.taskList["d"..dIdx]["q"..tIdx] and vo.taskList["d"..dIdx]["q"..tIdx]["flicker"] and vo.taskList["d"..dIdx]["q"..tIdx]["flicker"][cellIdx] and vo.taskList["d"..dIdx]["q"..tIdx]["flicker"][cellIdx][rIdx] then
			return vo.taskList["d"..dIdx]["q"..tIdx]["flicker"][cellIdx][rIdx]
		end
	end
	return ""
end


function acThrivingVoApi:getBigAwardMaxAmount(idx)

	local vo = self:getAcVo()
	if vo.bigRewardTb then
		local whiIdx = idx or SizeOfTable(vo.bigRewardTb)
		local formatAward = FormatItem(vo.bigRewardTb[whiIdx])
		return formatAward
	end
	return nil
end

function acThrivingVoApi:checkSetFull(callback)
	local vo = self:getAcVo()
	if(vo==nil)then
		do return end
	end
	local curDay=acThrivingVoApi:getCurDays()
	local fullTb={}
	local taskTb,taskClassTb = vo.taskList,vo.taskClassTb
	local length1=SizeOfTable(taskTb)
	if taskTb and taskClassTb then
		for i=1,length1 do
			if(i<=curDay)then
				local length2=SizeOfTable(taskTb["d"..i])
				for j=1,length2 do
					local curTaskType = taskClassTb[i][j]
					if curTaskType=="au" and accessoryVoApi:strengIsFull() then
						table.insert(fullTb,"au")
					elseif curTaskType=="wp" and superWeaponVoApi:isCanPlunder() then
						table.insert(fullTb,"wp")
					elseif curTaskType=="hu" and heroEquipVoApi:isCanStreng() then
						table.insert(fullTb,"hu")
					elseif curTaskType=="rc" and alienTechVoApi:isCanUpdate() then
						table.insert(fullTb,"rc")
					end
				end
			end
		end
	end
	if(fullTb[1])then
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if(ret==true)then
				for k,v in pairs(fullTb) do
					if(vo.cpltTaskNumTb==nil)then
						vo.cpltTaskNumTb={}
					end
					vo.cpltTaskNumTb[v]=99
				end
				if(callback)then
					callback()
				end
			end
		end
		socketHelper:acThrivingRequest("active.zzrs.setaction",{action=fullTb},onRequestEnd)
	else
		if(callback)then
			callback()
		end
	end
end

function acThrivingVoApi:clearAll()
	self.curChooseDay = nil
	self.whiTask = nil
	self.taskcmpltNums= nil
	self.vo = nil
end