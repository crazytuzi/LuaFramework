acWanshengjiedazuozhanVoApi = {}

function acWanshengjiedazuozhanVoApi:getAcVo()
	return activityVoApi:getActivityVo("wanshengjiedazuozhan")
end

function acWanshengjiedazuozhanVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acWanshengjiedazuozhanVoApi:canReward()
	if self:isFree()==true or self:taskCanReward()==true then
		return true
	else
		return false
	end
end

function acWanshengjiedazuozhanVoApi:getList()
	local acVo=self:getAcVo()
	return acVo.map
end

function acWanshengjiedazuozhanVoApi:isFree()
	local acVo=self:getAcVo()
	if acVo.lastTime and G_isToday(acVo.lastTime)==false then
		return true
	else
		return false
	end
end

function acWanshengjiedazuozhanVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acWanshengjiedazuozhanVoApi:taskCanReward()
	local taskList=self:getTaskList()
	if taskList then
		for k,v in pairs(taskList) do
			if v and v.status==1 then
				return true
			end
		end
	end
	return false
end

function acWanshengjiedazuozhanVoApi:getTaskList()
	local taskList={}
	local acVo=self:getAcVo()
	if acVo and acVo.taskList then
		local taskData=acVo.taskData
		local rewardData=acVo.rewardData
		for k,v in pairs(acVo.taskList) do
			local id=k
			local index=tonumber(v.index)
			if v then
				local reward=v.reward
				local conditions=v.conditions
				local taskType
				local num=0
				local maxNum=0
				local isReward=false
				local status
				local sordId
				if conditions then
					if conditions.type then
						taskType=conditions.type
					end
					if conditions.num then
						maxNum=conditions.num
					end
				end
				if taskData and taskType and taskData[taskType] then
					num=taskData[taskType]
				end
				if rewardData and SizeOfTable(rewardData)>0 then
					for m,n in pairs(rewardData) do
						if m==k and n==1 then
							isReward=true
						end
					end
				end
				if num>0 and maxNum>0 and num>=maxNum then
					if isReward==true then
						status=3
					else
						status=1
					end
				else
					status=2
				end
				sordId=status*100+index
				local tb={id=id,index=index,reward=reward,taskType=taskType,num=num,maxNum=maxNum,isReward=isReward,status=status,sordId=sordId}
				table.insert(taskList,tb)
			end
		end
		if taskList and SizeOfTable(taskList)>0 then
			local function sortFunc(a,b)
				return a.sordId<b.sordId
			end
			table.sort(taskList,sortFunc)
		end
	end
	return taskList
end


