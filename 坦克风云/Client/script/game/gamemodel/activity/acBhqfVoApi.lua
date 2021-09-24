acBhqfVoApi = {}

function acBhqfVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acBhqfVoApi:setActiveName(name)
	self.name=name
end

function acBhqfVoApi:getActiveName()
	return self.name or "bhqf"
end

function acBhqfVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.activeCfg and acVo.activeCfg.version then
		return acVo.activeCfg.version
	end
	return 1
end

function acBhqfVoApi:getAcCfg()
	local acVo = self:getAcVo()
	if acVo and acVo.datas then
		return acVo.datas
	end
	return nil
end


function acBhqfVoApi:canReward()
	if self:isToday() == false or self:hasTaskReward() == true then
		return true
	end
	return false
end

function acBhqfVoApi:isToday()
	local vo = self:getAcVo()
	local isToday = false
	if vo and vo.t then
		isToday = G_isToday(vo.t)
	end
	return isToday
end

--获取和谐版奖励
function acBhqfVoApi:getHxReward()
	local vo = self:getAcVo()
	if vo and vo.hxReward then
		local rewardTb = FormatItem(vo.hxReward,nil,true)
		return rewardTb[1]
	end
end

function acBhqfVoApi:updateData(data)
	if data then
		local vo=self:getAcVo()
		vo:updateData(data)
		self:refreshState()
	end
end

-- 刷新活动状态
function acBhqfVoApi:refreshState()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		activityVoApi:updateShowState(acVo)
	end
end

function acBhqfVoApi:getTask(tid)
	local tType,str,cond = 1,"",0
	local acVo = self:getAcVo()
	if acVo and tid and acVo.activeCfg.collectTask[tid] then
		local task = acVo.activeCfg.collectTask[tid]
		if task then
			tType,str,cond = task[1] or 1,task[2] or "",task[3] or {}
			return tType,str,cond
		end
		
	end
	return tType,str,cond
end

function acBhqfVoApi:hasTaskReward()
	local acVo = self:getAcVo()
	if acVo and acVo.activeCfg and acVo.activeCfg.collectReward then
		for k,v in pairs(acVo.activeCfg.collectReward) do
			if v and v[1] then
				local status = self:getTaskState(v[1])
				if status == 1 then
					return true
				end
			end
		end
	end
	return false
end

function acBhqfVoApi:getTaskState(tid)
	local status = 0
	if tid then
		local acVo = self:getAcVo()
		if acVo then
			if acVo.rd then
				for k,v in pairs(acVo.rd) do
					if tid == v then
						status = 2
						do return status end
					end
				end
			end

			if acVo.words and SizeOfTable(acVo.words) > 0 then
				local wnum = SizeOfTable(acVo.words or {})
				local tType,str,cond = self:getTask(tid)
				if tType == 1 and type(cond) == "number" then
					if wnum > 0 and wnum >= cond then
						status = 1
					end
				else
					if type(cond) == "table" then
						local tmptb,num = {},0
						for k,v in pairs(cond) do
							tmptb[v] = 1
						end
						for kk,vv in pairs(acVo.words) do
							if tmptb[vv] then
								num = num + 1
							end
						end
						if SizeOfTable(cond) == num then
							status = 1
						end
					end
				end
			end
		end
	end
	return status
end

function acBhqfVoApi:hasWord(word)
	local acVo=self:getAcVo()
	if acVo and acVo.words and word then
		for k,v in pairs(acVo.words) do
			if word == v then
				return true
			end
		end
	end
	return false
end

function acBhqfVoApi:getRewardPool()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg.reward then
		local awardTb = {}
		for k,v in pairs(acVo.activeCfg.reward) do
			local formatTb = FormatItem(v,nil,true)
			table.insert(awardTb,formatTb)
		end
		return awardTb
	end
	return {}
end

function acBhqfVoApi:getRewardLog()
	return self.rewardLog
end
--格式化抽奖记录
function acBhqfVoApi:getLog(callback)
	if self.rewardLog and SizeOfTable(self.rewardLog)>0 then
		if callback then
			callback()
		end
	else
		local function logCallback(fn,data)
	        local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.log then
	            	self.rewardLog={}
					for k,v in pairs(sData.data.log) do
						self:formatLog(v)
					end
					if callback then
						callback()
					end
	            end
	        end
		end
		socketHelper:activeBhqfGetlog(logCallback)
	end
end

--格式化抽奖记录
function acBhqfVoApi:formatLog(data,addFlag)
	if self.rewardLog then
		local num=data[1] or 0
		local rewards,words=data[2].cr or {},data[2].zr or {}
		local time=data[3] or base.serverTime
		local rewardlist,wordslist={},{}
		for k,v in pairs(rewards) do
			local reward=FormatItem(v,nil,true)	
			table.insert(rewardlist,reward[1])
		end
		local hxReward=self:getHxReward()
		if hxReward then
			hxReward.num=hxReward.num*num
			table.insert(rewardlist,1,hxReward)
		end
		for k,v in pairs(words) do
			if v then
				for i,j in pairs(v) do
					wordslist[i]=(wordslist[i] or 0)+1
				end
			end
		end
		if addFlag and addFlag==true then
	    	table.insert(self.rewardLog,1,{num=num,reward=rewardlist,time=time,words=wordslist})
		else
		    table.insert(self.rewardLog,{num=num,reward=rewardlist,time=time,words=wordslist})
		end
		local lcount=SizeOfTable(self.rewardLog)
		if lcount>10 then
			for i=11,lcount do
				table.remove(self.rewardLog,i)
			end
		end
	end
end

function acBhqfVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
	spriteController:addTexture("public/activeCommonImage1.png")
end

function acBhqfVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
	spriteController:removeTexture("public/activeCommonImage1.png")
end

function acBhqfVoApi:clearAll()
	self.rewardLog = nil
end
