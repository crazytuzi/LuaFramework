require "luascript/script/game/gamemodel/task/taskVo"

taskVoApi={
	currentTasks={},
	dailyTasks={},
	--每日任务领取过的次数
    -- dailyTaskNum=0,
	--选择的每日sid 没选为0
	-- selectedTask=0,
	--每日任务已经重置的次数
	-- resetTaskNum=0,
	--每日任务重置一次可以完成数量
	-- dailyMaxNum=5,
	--刷新需要宝石数量
	-- refreshGem=8,
	--重置需要宝石数量
	-- resetGem=28,
    --直接完成每颗星需要宝石数量
	-- starGem=5,
	refreshFlag=0,
	typeNumTab={},
	dailyLastRewardTime=0,

	dailyTypeTab={},
	-- extraRewardCfg={},
	extraTab={},
	isNotToday=false,
	daliyFlag=-1,--第一次打开板子初始化日常任务数据
	flag=-1,--刚进入游戏，是否有可领取的日常任务,1有，0无

	acPoint=0,	--活跃点数
	dailyHasRewardTb={},--已领取每日任务（包括活跃奖励）
}

--isDaily 每日任务配置，isDailyPoint 每日任务活跃点数奖励配置
function taskVoApi:getTaskFromCfg(sid,isDaily,isDailyPoint)
	local key="s"..tostring(sid)
	local task={}
	local isNewDailyCfg=false
	local rewardLevel = taskVoApi:getRewardLevel()
	if isDailyPoint==true then
		if dailyTaskCfg2 and dailyTaskCfg2.finalTask and dailyTaskCfg2.finalTask[rewardLevel] and dailyTaskCfg2.finalTask[rewardLevel][key] then
			task=dailyTaskCfg2.finalTask[rewardLevel][key]
			isNewDailyCfg=false
		end
	elseif isDaily==true then
		if self:isShowNew()==true then
			if dailyTaskCfg2 and dailyTaskCfg2.task and dailyTaskCfg2.task[rewardLevel] and dailyTaskCfg2.task[rewardLevel][key] then
				task=dailyTaskCfg2.task[rewardLevel][key]
				isNewDailyCfg=true
			end
		else
			if dailyTaskCfg and dailyTaskCfg.task and dailyTaskCfg.task[key] then
				-- if dailyTaskCfg.task[key].isExtra==1 then
				-- else
					task=dailyTaskCfg.task[key]
				-- end
			end
		end
	elseif taskCfg[key] then
		task=taskCfg[key]
	end
	return task,isNewDailyCfg
end

function taskVoApi:getRewardLevel( ... )
	local level = playerVoApi:getPlayerLevel()
	local levelCfg = dailyTaskCfg2.levelGroup
	for k,v in pairs(levelCfg) do
		if level < v then
			return k-1,#levelCfg
		end
	end
	return #levelCfg,#levelCfg
end
function taskVoApi:getExtraCfg(subType)
	if dailyTaskCfg and dailyTaskCfg.task then
		for k,v in pairs(dailyTaskCfg.task) do
			if v and v.isExtra and v.isExtra==1 then
				if subType and subType==v.subType then
					return v
				end
			end
		end
	end
	return {}
end
-- function taskVoApi:getExtraRewardCfg()
-- 	if self.extraRewardCfg==nil then
-- 		self.extraRewardCfg={}
-- 	end
-- 	if SizeOfTable(self.extraRewardCfg)==0 then
-- 		if dailyTaskCfg and dailyTaskCfg.task then
-- 			for k,v in pairs(dailyTaskCfg.task) do
-- 				if v and v.isExtra and v.isExtra==1 then
-- 					table.insert(self.extraRewardCfg,v)
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return self.extraRewardCfg
-- end
function taskVoApi:clearTasks()
	if self.currentTasks then
		for k,v in pairs(self.currentTasks) do
			self.currentTasks[k]=nil
		end
	end
	self.currentTasks={}
	if self.typeNumTab then
		for k,v in pairs(self.typeNumTab) do
			self.typeNumTab[k]=nil
		end
	end
	self.typeNumTab={}
    self.refreshFlag=0
    self.flag=-1
end
function taskVoApi:clearDailyTasks()
	if self.dailyTasks then
		for k,v in pairs(self.dailyTasks) do
			self.dailyTasks[k]=nil
		end
	end
	self.dailyTasks={}
 --    self.dailyTaskNum=0
	-- self.selectedTask=0
	-- self.resetTaskNum=0
	self.refreshFlag=0
	self.dailyLastRewardTime=0

	self.dailyTypeTab={}
	self.extraTab={}
	self.isNotToday=false
	self.daliyFlag=-1
	self.acPoint=0
	self.dailyHasRewardTb={}
end

function taskVoApi:getDailyHasRewardTb()
	return self.dailyHasRewardTb
end
function taskVoApi:setDailyHasRewardTb(sid)
	if self.dailyHasRewardTb==nil then
		self.dailyHasRewardTb={}
	end
	self.dailyHasRewardTb[sid]=1
end

function taskVoApi:getAcPoint()
	return self.acPoint
end
function taskVoApi:setAcPoint(acPoint)
	self.acPoint=acPoint
end

function taskVoApi:getFlag()
	return self.flag
end
function taskVoApi:setFlag(flag)
	self.flag=flag
end
function taskVoApi:getDaliyFlag()
	return self.daliyFlag
end
function taskVoApi:setDaliyFlag(daliyFlag)
	self.daliyFlag=daliyFlag
end

function taskVoApi:formatTask(data)
	if data then
		local function sortTypeSidAsc(a, b)
			if a.type == b.type then
				if a.num and a.cNum and b.num and b.cNum then
					if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
						return tonumber(a.sid) < tonumber(b.sid)
					else
						if a.num>=a.cNum and b.num<b.cNum then
							return true
						elseif a.num<a.cNum and b.num>=b.cNum then
							return false
						end
					end
				else
					return tonumber(a.sid) < tonumber(b.sid)
				end
				-- return a.sid < b.sid
			else
				return a.type < b.type
			end
		end
		local maxTaskLevel=playerVoApi:getMaxLvByKey("unlockTaskLevel")
		for k,v in pairs(data) do
			local sid=tonumber(k) or tonumber(RemoveFirstChar(k))
			if sid then
				local taskCfg=self:getTaskFromCfg(sid)
				if taskCfg and SizeOfTable(taskCfg)>0 then
					local isShow=true
					local limitLevel=taskCfg.limitLevel
					if maxTaskLevel and limitLevel then
						if limitLevel>maxTaskLevel then
							isShow=false
						end
					end
					if tonumber(sid)==149 and playerVoApi:getPlayerLevel()<5 and (G_curPlatName()=="18" or G_curPlatName()=="androidtuerqi" or G_curPlatName()=="0") then
						isShow=false
					end
					if isShow==true then
						local type=tonumber(taskCfg.type)
						local vo = taskVo:new()
						vo:initWithData(tonumber(sid),type,v.c,v.v)
						if self.currentTasks==nil then
							self.currentTasks={}
						end
						table.insert(self.currentTasks,vo)
						if self.typeNumTab[type]==nil then
							self.typeNumTab[type]=1
						else
							self.typeNumTab[type]=self.typeNumTab[type]+1
						end
					end
				end
			end
		end
		table.sort(self.currentTasks,sortTypeSidAsc)
	end
end
--[[
function taskVoApi:getUpdateTime()
	local dailyTs=DailyUpdateTime()
	return dailyTs
end
]]
function taskVoApi:getDailyLastRewardTime()
	return self.dailyLastRewardTime
end
--是否今日已过
function taskVoApi:isUpdateDailyTask()
	--local updateTime=self:getUpdateTime()
	--if self.dailyLastRewardTime>updateTime then
	if G_isToday(self.dailyLastRewardTime) then
		return false
	end
	return true
end
function taskVoApi:formatDailyTask(data)
	if data then
		self.dailyLastRewardTime=0
		if data.ts then
			self.dailyLastRewardTime=data.ts
		end
		local function sortDailyAsc(a, b)
			if a and b and a.sid and b.sid then
				local ACfg=self:getTaskFromCfg(a.sid,true)
				local BCfg=self:getTaskFromCfg(b.sid,true)
				if (ACfg.isUrgency==1 and BCfg.isUrgency==1) or (ACfg.isUrgency~=1 and BCfg.isUrgency~=1) then
					if a.isReward and b.isReward then
						if a.isReward==b.isReward then
							if a.num and a.cNum and b.num and b.cNum then
								if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
									return tonumber(a.sid) < tonumber(b.sid)
								else
									if a.num>=a.cNum and b.num<b.cNum then
										return true
									elseif a.num<a.cNum and b.num>=b.cNum then
										return false
									end
								end
							else
								return tonumber(a.sid) < tonumber(b.sid)
							end
						else
							return a.isReward<b.isReward
						end
					else
						if a.num and a.cNum and b.num and b.cNum then
							if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
								return tonumber(a.sid) < tonumber(b.sid)
							else
								if a.num>=a.cNum and b.num<b.cNum then
									return true
								elseif a.num<a.cNum and b.num>=b.cNum then
									return false
								end
							end
						else
							return tonumber(a.sid) < tonumber(b.sid)
						end
					end
				else
					if ACfg.isUrgency==1 and BCfg.isUrgency~=1 then
						return true
					elseif ACfg.isUrgency~=1 and BCfg.isUrgency==1 then
						return false
					end
				end
			end
		end
		if self.dailyTasks==nil then
			self.dailyTasks={}
		end
		if self.dailyTypeTab==nil then
			self.dailyTypeTab={}
		end
		if data.t then
			for k,v in pairs(data.t) do
				if v and SizeOfTable(v)>0 then
					local sid=tonumber(k) or tonumber(RemoveFirstChar(k))
					local taskCfg=self:getTaskFromCfg(sid,true)
					local cNum=v.s
					local num=v.n or 0
					local isReward=v.r or 0
					local ts=v.ts
					local level=v.l
					if num>cNum then
						num=cNum
					end

					local vo = taskVo:new()
					vo:initWithData(tonumber(sid),tonumber(taskCfg.type),num,cNum,isReward,ts,level)
					-- table.insert(self.dailyTasks,vo)

					if self.extraTab==nil then
						self.extraTab={}
					end
					if self.dailyTypeTab[taskCfg.subType]==nil then
						self.dailyTypeTab[taskCfg.subType]={}
					end
					if taskCfg.isExtra==1 then
						self.extraTab[taskCfg.subType]=vo
						table.insert(self.dailyTasks,vo)
					else
						if taskCfg.isUrgency==1 then
							if isReward==1 then
							elseif ts and base.serverTime<=ts  then
								table.insert(self.dailyTasks,vo)
								table.insert(self.dailyTypeTab[taskCfg.subType],vo)
							end
						else
							table.insert(self.dailyTasks,vo)
							table.insert(self.dailyTypeTab[taskCfg.subType],vo)
						end
					end
				end
			end
		end
		table.sort(self.dailyTasks,sortDailyAsc)
		for k,v in pairs(self.dailyTypeTab) do
			table.sort(v,sortDailyAsc)
		end
		self:setFlag(-1)
	end
end
function taskVoApi:formatNewDailyTask(data)
	if data then
		self.dailyLastRewardTime=0
		if data.ts then
			self.dailyLastRewardTime=data.ts
		end
		-- local function sortDailyAsc(a, b)
		-- 	if a and b and a.sid and b.sid then
		-- 		local ACfg=self:getTaskFromCfg(a.sid,true)
		-- 		local BCfg=self:getTaskFromCfg(b.sid,true)
		-- 		local playerLv=playerVoApi:getPlayerLevel()
		-- 		-- if (ACfg.isUrgency==1 and BCfg.isUrgency==1) or (ACfg.isUrgency~=1 and BCfg.isUrgency~=1) then
		-- 		if ACfg.needLv and BCfg.needLv and ((playerLv>=ACfg.needLv and playerLv>=BCfg.needLv) or (playerLv<ACfg.needLv and playerLv<BCfg.needLv)) then
		-- 			if a.isReward and b.isReward then
		-- 				if a.isReward==b.isReward then
		-- 					if a.num and a.cNum and b.num and b.cNum then
		-- 						if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
		-- 							return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
		-- 						else
		-- 							if a.num>=a.cNum and b.num<b.cNum then
		-- 								return true
		-- 							elseif a.num<a.cNum and b.num>=b.cNum then
		-- 								return false
		-- 							end
		-- 						end
		-- 					else
		-- 						return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
		-- 					end
		-- 				else
		-- 					return a.isReward<b.isReward
		-- 				end
		-- 			else
		-- 				if a.num and a.cNum and b.num and b.cNum then
		-- 					if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
		-- 						return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
		-- 					else
		-- 						if a.num>=a.cNum and b.num<b.cNum then
		-- 							return true
		-- 						elseif a.num<a.cNum and b.num>=b.cNum then
		-- 							return false
		-- 						end
		-- 					end
		-- 				else
		-- 					return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
		-- 				end
		-- 			end
		-- 		else
		-- 			if playerLv>=ACfg.needLv and playerLv<BCfg.needLv then
		-- 				return true
		-- 			elseif playerLv<ACfg.needLv and playerLv>=BCfg.needLv then
		-- 				return false
		-- 			end
		-- 		end
		-- 		-- else
		-- 		-- 	if ACfg.isUrgency==1 and BCfg.isUrgency~=1 then
		-- 		-- 		return true
		-- 		-- 	elseif ACfg.isUrgency~=1 and BCfg.isUrgency==1 then
		-- 		-- 		return false
		-- 		-- 	end
		-- 		-- end
		-- 	end
		-- end
		if self.dailyTasks==nil then
			self.dailyTasks={}
		end
		if self.dailyTypeTab==nil then
			self.dailyTypeTab={}
		end
		if data.r1 then
			self.dailyHasRewardTb={}
			for k,v in pairs(data.r1) do
				self:setDailyHasRewardTb(v)
			end
		end
		if data.t then
			local dailyHasRewardTb=self:getDailyHasRewardTb()
			for k,v in pairs(self.dailyTasks) do
				if v and v.sid then
					local taskid="s"..v.sid
					if data.t[taskid] then
						v.num=tonumber(data.t[taskid]) or 0
						if v.num>v.cNum then
							v.num=v.cNum
						end
					end
					if dailyHasRewardTb and dailyHasRewardTb[taskid] then
						v.isReward=1
					end
				end
			end
		end
		if data.c then
			self.acPoint=tonumber(data.c) or 0
		end
		-- if self.dailyTasks and SizeOfTable(self.dailyTasks)>0 then
		-- 	table.sort(self.dailyTasks,sortDailyAsc)
		-- end
		self:dailyTaskSort(self.dailyTasks)
		self:setFlag(-1)
	end
end
function taskVoApi:dailyTaskSort(tb)
	local function sortDailyAsc(a, b)
		if a and b and a.sid and b.sid then
			local ACfg=self:getTaskFromCfg(a.sid,true)
			local BCfg=self:getTaskFromCfg(b.sid,true)
			local playerLv=playerVoApi:getPlayerLevel()
			-- if (ACfg.isUrgency==1 and BCfg.isUrgency==1) or (ACfg.isUrgency~=1 and BCfg.isUrgency~=1) then
			if ACfg.needLv and BCfg.needLv and ((playerLv>=ACfg.needLv and playerLv>=BCfg.needLv) or (playerLv<ACfg.needLv and playerLv<BCfg.needLv)) then
				local aCompletedState=1
				local bCompletedState=1
				if self:isCompletedTask(a.sid,true)==true then
					aCompletedState=0
				end
				if self:isCompletedTask(b.sid,true)==true then
					bCompletedState=0
				end
				if a.isReward and b.isReward then
					if a.isReward==b.isReward then
						-- if a.num and a.cNum and b.num and b.cNum then
						-- 	if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
						-- 		return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
						-- 	else
						-- 		if a.num>=a.cNum and b.num<b.cNum then
						-- 			return true
						-- 		elseif a.num<a.cNum and b.num>=b.cNum then
						-- 			return false
						-- 		end
						-- 	end
						-- else
						-- 	return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
						-- end
						if aCompletedState==bCompletedState then
							return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
						else
							return aCompletedState<bCompletedState
						end
					else
						return a.isReward<b.isReward
					end
				else
					-- if a.num and a.cNum and b.num and b.cNum then
					-- 	if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
					-- 		return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
					-- 	else
					-- 		if a.num>=a.cNum and b.num<b.cNum then
					-- 			return true
					-- 		elseif a.num<a.cNum and b.num>=b.cNum then
					-- 			return false
					-- 		end
					-- 	end
					-- else
					-- 	return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
					-- end
					if aCompletedState==bCompletedState then
						return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
					else
						return aCompletedState<bCompletedState
					end
				end
			else
				if playerLv>=ACfg.needLv and playerLv<BCfg.needLv then
					return true
				elseif playerLv<ACfg.needLv and playerLv>=BCfg.needLv then
					return false
				end
			end
			-- else
			-- 	if ACfg.isUrgency==1 and BCfg.isUrgency~=1 then
			-- 		return true
			-- 	elseif ACfg.isUrgency~=1 and BCfg.isUrgency==1 then
			-- 		return false
			-- 	end
			-- end
		end
	end
	if tb and SizeOfTable(tb)>0 then
		table.sort(tb,sortDailyAsc)
	end
end
function taskVoApi:initDailyTask()
	local function sortDailyAsc(a, b)
		if a and b and a.sid and b.sid then
			local ACfg=self:getTaskFromCfg(a.sid,true)
			local BCfg=self:getTaskFromCfg(b.sid,true)
			if (ACfg.isUrgency==1 and BCfg.isUrgency==1) or (ACfg.isUrgency~=1 and BCfg.isUrgency~=1) then
				if a.isReward and b.isReward then
					if a.isReward==b.isReward then
						if a.num and a.cNum and b.num and b.cNum then
							if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
								return tonumber(a.sid) < tonumber(b.sid)
							else
								if a.num>=a.cNum and b.num<b.cNum then
									return true
								elseif a.num<a.cNum and b.num>=b.cNum then
									return false
								end
							end
						else
							return tonumber(a.sid) < tonumber(b.sid)
						end
					else
						return a.isReward<b.isReward
					end
				else
					if a.num and a.cNum and b.num and b.cNum then
						if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
							return tonumber(a.sid) < tonumber(b.sid)
						else
							if a.num>=a.cNum and b.num<b.cNum then
								return true
							elseif a.num<a.cNum and b.num>=b.cNum then
								return false
							end
						end
					else
						return tonumber(a.sid) < tonumber(b.sid)
					end
				end
			else
				if ACfg.isUrgency==1 and BCfg.isUrgency~=1 then
					return true
				elseif ACfg.isUrgency~=1 and BCfg.isUrgency==1 then
					return false
				end
			end
		end
	end
	if self.dailyTasks==nil then
		self.dailyTasks={}
	end
	if self.dailyTypeTab==nil then
		self.dailyTypeTab={}
	end
	for k,v in pairs(self.dailyTasks) do
		local cfg=self:getTaskFromCfg(v.sid,true)
		if cfg and cfg.isUrgency and cfg.isUrgency==1 then
		else
			self.dailyTasks[k].isReward=0
			self.dailyTasks[k].num=0
		end
	end
	for k,v in pairs(self.dailyTypeTab) do
		for m,n in pairs(v) do
			local cfg=self:getTaskFromCfg(n.sid,true)
			if cfg and cfg.isUrgency and cfg.isUrgency==1 then
			else
				self.dailyTypeTab[k][m].isReward=0
				self.dailyTypeTab[k][m].num=0
			end
		end
	end
	if self.dailyTasks and SizeOfTable(self.dailyTasks)>0 then
		table.sort(self.dailyTasks,sortDailyAsc)
	end
	for k,v in pairs(self.dailyTypeTab) do
		table.sort(v,sortDailyAsc)
	end
	self:setFlag(-1)
end
function taskVoApi:initNewDailyTask()
	if self:isShowNew()==true then
		-- local function sortDailyAsc(a, b)
		-- 	if a and b and a.sid and b.sid then
		-- 		local ACfg=self:getTaskFromCfg(a.sid,true)
		-- 		local BCfg=self:getTaskFromCfg(b.sid,true)
		-- 		-- if (ACfg.isUrgency==1 and BCfg.isUrgency==1) or (ACfg.isUrgency~=1 and BCfg.isUrgency~=1) then
		-- 			if a.isReward and b.isReward then
		-- 				if a.isReward==b.isReward then
		-- 					if a.num and a.cNum and b.num and b.cNum then
		-- 						if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
		-- 							return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
		-- 						else
		-- 							if a.num>=a.cNum and b.num<b.cNum then
		-- 								return true
		-- 							elseif a.num<a.cNum and b.num>=b.cNum then
		-- 								return false
		-- 							end
		-- 						end
		-- 					else
		-- 						return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
		-- 					end
		-- 				else
		-- 					return a.isReward<b.isReward
		-- 				end
		-- 			else
		-- 				if a.num and a.cNum and b.num and b.cNum then
		-- 					if (a.num>=a.cNum and b.num>=b.cNum) or (a.num<a.cNum and b.num<b.cNum) then
		-- 						return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
		-- 					else
		-- 						if a.num>=a.cNum and b.num<b.cNum then
		-- 							return true
		-- 						elseif a.num<a.cNum and b.num>=b.cNum then
		-- 							return false
		-- 						end
		-- 					end
		-- 				else
		-- 					return tonumber(ACfg.sortId) < tonumber(BCfg.sortId)
		-- 				end
		-- 			end
		-- 		-- else
		-- 		-- 	if ACfg.isUrgency==1 and BCfg.isUrgency~=1 then
		-- 		-- 		return true
		-- 		-- 	elseif ACfg.isUrgency~=1 and BCfg.isUrgency==1 then
		-- 		-- 		return false
		-- 		-- 	end
		-- 		-- end
		-- 	end
		-- end
		if self.dailyTasks==nil then
			self.dailyTasks={}
		end
		local rewardLevel = self:getRewardLevel()
		if dailyTaskCfg2 and dailyTaskCfg2.task and dailyTaskCfg2.task[rewardLevel] then
			self.dailyTasks={}
			for k,v in pairs(dailyTaskCfg2.task[rewardLevel]) do
				local sid=tonumber(k) or tonumber(RemoveFirstChar(k))
				local taskCfg,isNewDailyCfg=self:getTaskFromCfg(sid,true)
				if taskCfg and taskCfg.require and taskCfg.require[1] then
					local cNum=taskCfg.require[1]
					local num=0
					local isReward=0
					local ts=0
					local level=0
					if num>cNum then
						num=cNum
					end
					local vo = taskVo:new()
					vo:initWithData(tonumber(sid),tonumber(taskCfg.type),num,cNum,isReward,ts,level)
					table.insert(self.dailyTasks,vo)
				end
			end
			-- if self.dailyTasks and SizeOfTable(self.dailyTasks)>0 then
			-- 	table.sort(self.dailyTasks,sortDailyAsc)
			-- end
			self:dailyTaskSort(self.dailyTasks)
		end
	end
end

function taskVoApi:getExtraTab(subType)
	if subType then
		if self.extraTab and self.extraTab[subType] then
			return self.extraTab[subType]
		end
	else
		return self.extraTab
	end
	return {}
end
function taskVoApi:getDailyTypeTab(subType)
	if subType then
		if self.dailyTypeTab and self.dailyTypeTab[subType] then
			return self.dailyTypeTab[subType]
		end
	else
		return self.dailyTypeTab
	end
	return {}
end
function taskVoApi:getUrgencyTasks()
	local taskTab={}
	local dailyTypeTab=self:getDailyTypeTab(2)
	if dailyTypeTab and SizeOfTable(dailyTypeTab)>0 then
		for k,v in pairs(dailyTypeTab) do
			if v and v.sid then
				local sid=v.sid
				local cfg=self:getTaskFromCfg(sid,true)
				if cfg.isUrgency==1 then
					table.insert(taskTab,v)
				end
			end
		end
	end	
	return taskTab
end
function taskVoApi:getDailyFinishNum(subType)
	local finishNum=0
	if subType then
		local dailyTypeTab=self:getDailyTypeTab(subType)
		if dailyTypeTab and SizeOfTable(dailyTypeTab)>0 then
			for k,v in pairs(dailyTypeTab) do
				if v and v.num and v.cNum and v.num>=v.cNum then
					if v.isReward and v.isReward==1 then
					else
						finishNum=finishNum+1
					end
				end
			end
		end
		local extraTab=taskVoApi:getExtraTab(subType)
		if extraTab then
			if extraTab.num and extraTab.cNum and extraTab.num>=extraTab.cNum then 
				if extraTab.isReward and extraTab.isReward==1 then
				else
					finishNum=finishNum+1
				end
			end
		end
	end
	return finishNum
end

function taskVoApi:updateDailyTaskNum()
	local isUpdate=self:isUpdateDailyTask()
	if isUpdate==true then
		if self.isNotToday~=isUpdate then
			-- local urgencyTaskTab=self:getUrgencyTasks()
			-- self:clearDailyTasks()
			self:initDailyTask()
			self:initNewDailyTask()
			self.acPoint=0
			self.dailyHasRewardTb={}
			self.isNotToday=isUpdate
			return true
		end
		-- if self.dailyTaskNum~=0 or self.resetTaskNum~=0 then
		-- 	self.dailyTaskNum=0
		-- 	self.resetTaskNum=0
		-- 	return true
		-- end
	end
	return false
end

function taskVoApi:getTaskBySid(sid,isDaily)
	local task={}
	if isDaily==true then
		task=self:getDailyTaskBySid(sid)
	else
		task=self:getCurrentTaskBySid(sid)
	end
	return task
end
function taskVoApi:getCurrentTaskBySid(sid)
	local cTasks=self:getCurrentTasks()
	for k,v in pairs(cTasks) do
		if tostring(v.sid)==tostring(sid) then
			return v
		end
	end
	return nil
end
function taskVoApi:getDailyTaskBySid(sid)
	local dTasks=self:getDailyTasks()
	for k,v in pairs(dTasks) do
		if tostring(v.sid)==tostring(sid) then
			return v
		end
	end
	return nil
end

function taskVoApi:getCurrentTasks()
	if self.currentTasks==nil then
		self.currentTasks={}
	end
	return self.currentTasks
end
function taskVoApi:getDailyTasks()
	if self.dailyTasks==nil then
		self.dailyTasks={}
	end
	return self.dailyTasks
end

function taskVoApi:getCurrentTasksNum()
	return SizeOfTable(self:getCurrentTasks())
end
-- function taskVoApi:getDailyTasksNum()
-- 	return SizeOfTable(self:getDailyTasks())
-- end

--isShowAddPoint 是否显示军团资金奖励
function taskVoApi:getAwardBySid(sid,isDaily,isShowAddPoint,isDailyPoint)
	if isShowAddPoint==nil then
		isShowAddPoint=true
	end
	local award = {}
	local task,isNewDailyCfg = self:getTaskFromCfg(sid,isDaily,isDailyPoint)
	if task and SizeOfTable(task)>0 then
		if type(task.award)=="table" then
			local awardTab = FormatItem(task.award,nil,true)
			for k,v in pairs(awardTab) do
				if v.type=="a" and v.key=="point" and isShowAddPoint==false then
				else
					-- local vt = {name=v.name,num=v.num,pic=v.pic,key=v.key}
					if isNewDailyCfg==true then
						if v.type=="u" then
							local playerLv=playerVoApi:getPlayerLevel()
							if v.key=="exp" and dailyTaskCfg2.exp and dailyTaskCfg2.exp[playerLv] then
								v.num=dailyTaskCfg2.exp[playerLv]*v.num
							end
							if (v.key=="r1" or v.key=="r2" or v.key=="r3" or v.key=="r4" or v.key=="gold") and dailyTaskCfg2.resource and dailyTaskCfg2.resource[playerLv] then
								v.num=dailyTaskCfg2.resource[playerLv]*v.num
							end
						end
					end
					G_dayin(v)
					table.insert(award,v)
				end
			end
		else
			local awardTab = Split(task.award, ",")
			local vt = {}
			for k,v in pairs(awardTab) do
				if k>=3 and (k%3)==0 then
					vt = {name=awardTab[k-2],num=awardTab[k-1],pic=v}
					table.insert(award,vt)
				end
			end
		end
	end
	return award
end

--base.isConvertGems==1
function taskVoApi:needValueByPlayerInfo( )
    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local honTb =Split(playerCfg.honors,",")
    local maxHonors =honTb[maxLevel] --当前服 最大声望值
    local expTb =Split(playerCfg.level_exps,",")
    local maxExp = expTb[maxLevel] --当前服 最大经验值
    local playerExp = playerVoApi:getPlayerExp() --用户当前的经验值
    local AllGems = 0 --用于满级后的水晶数量

    return playerHonors,maxHonors,maxExp,playerExp,AllGems
end
--isShowAddPoint 是否显示加上军团资金奖励
function taskVoApi:getAwardStr(sid,isDaily,isShowAddPoint,isDailyPoint)
    local playerHonors,maxHonors,maxExp,playerExp,AllGems = self:needValueByPlayerInfo()

	local awardTab = self:getAwardBySid(sid,isDaily,isShowAddPoint,isDailyPoint)
	local str = getlocal("promptTaskFinish")

	for k,v in pairs(awardTab) do
		local nameStr=getlocal(v.name)
		if isDaily==true then
			nameStr=v.name
		end
		if k==SizeOfTable(awardTab) then
			if k==1 and nameStr == getlocal("honor") and base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
				AllGems = AllGems+playerVoApi:convertGems(2,v.num)
				-- local name = getlocal("money")
				-- str = str .. name .. " x" .. AllGems
			elseif k==1 and nameStr == getlocal("sample_general_exp") and base.isConvertGems==1 and tonumber(playerExp) >=tonumber(maxExp) then
				AllGems = AllGems+playerVoApi:convertGems(1,v.num)
				-- local name = getlocal("money")
				-- str = str .. name .. " x" .. AllGems
			else
				str = str .. nameStr .. " x" .. v.num
			end
		else
			if nameStr == getlocal("honor") and base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
				AllGems = AllGems+playerVoApi:convertGems(2,v.num)
			elseif nameStr == getlocal("sample_general_exp") and base.isConvertGems==1 and tonumber(playerExp) >=tonumber(maxExp) then
				AllGems = AllGems+playerVoApi:convertGems(1,v.num)
			elseif nameStr == getlocal("money") and base.isConvertGems==1  then
				AllGems = AllGems+v.num
			else
				str = str .. nameStr .. " x" .. v.num .. ","
			end					
		end
	end
	if AllGems >0 then
		local name = getlocal("money")
		if #awardTab >1 then
			str = str ..","..name .. " x" .. AllGems 
		else
			str = str ..name .. " x" .. AllGems 
		end
	end
	return str,awardTab
end

function taskVoApi:getCurrentNumByType(type)
	local num=0
	if self.typeNumTab[type]~=nil then
		num=self.typeNumTab[type]
	end
	return num
	--[[
	local typeTask={}
	local numType1=0
	local numType2=0
	local cTasks=self:getCurrentTasks()
	for k,v in pairs(cTasks) do
		if v then
			if tostring(v.type)==tostring(type1) then
				numType1=numType1+1
			elseif tostring(v.type)==tostring(type2) then
				numType2=numType2+1
			end
		end
	end
	return numType1,numType2
	]]
end

-- function taskVoApi:getDirectGem(sid)
-- 	local task=self:getTaskFromCfg(sid)
-- 	if task and SizeOfTable(task)>0 then
-- 		local gems=task.star*self.starGem
-- 		return gems
-- 	end
-- 	return 0
-- end
-- function taskVoApi:getRefreshGem()
-- 	return self.refreshGem
-- end
-- function taskVoApi:getResetGem()
-- 	return self.resetGem
-- end

-- function taskVoApi:getDailyTaskNum()
-- 	return self.dailyTaskNum
-- end
-- function taskVoApi:setDailyTaskNum(num)
-- 	self.dailyTaskNum = num
-- end
-- function taskVoApi:getDailyMaxNum()
-- 	return self.dailyMaxNum
-- end

-- function taskVoApi:setResetTaskNum(num)
-- 	self.resetTaskNum=num
-- end
-- function taskVoApi:getResetTaskNum()
-- 	return self.resetTaskNum
-- end
-- function taskVoApi:getResetMaxNum()
-- 	local vip=playerVoApi:getVipLevel()
-- 	local maxNum=Split(playerCfg.vip4TaskRestQueue,",")[vip+1]
-- 	return maxNum
-- end
-- function taskVoApi:getResetRemainNum()
-- 	local resetNum=self:getResetTaskNum()
-- 	local maxNum=self:getResetMaxNum()
-- 	local remainNum=maxNum-resetNum
-- 	return remainNum
-- end

-- function taskVoApi:getSelectedTask()
-- 	return self.selectedTask
-- end
-- function taskVoApi:setSelectedTask(sid)
-- 	if sid==0 then
-- 		local dTasks=self:getDailyTasks()
-- 		for k,v in pairs(dTasks) do
-- 			if tostring(v.sid)==tostring(self.selectedTask) then
-- 				self.dailyTasks[k].num=0
-- 			end
-- 		end
-- 	end
-- 	self.selectedTask = sid
-- end

function taskVoApi:isCompletedTask(sid,isDaily)
	if isDaily==true then
		local dailyTask=self:getTaskBySid(sid,true)
		if dailyTask then
			if dailyTask.isReward and dailyTask.isReward==1 then
			else
				-- print('buildingVoApi:isAllBuildingsMax()',buildingVoApi:isAllBuildingsMax())
				-- print('technologyVoApi:isAllTechnologyMaxLv()',technologyVoApi:isAllTechnologyMaxLv())
				-- print('accessoryVoApi:strengIsFull()',accessoryVoApi:strengIsFull())
				-- print('superWeaponVoApi:isCanPlunder()',superWeaponVoApi:isCanPlunder())
				if tostring(dailyTask.sid)=="1002" and buildingVoApi:isAllBuildingsMax()==true then
					return true
				elseif tostring(dailyTask.sid)=="1003" and technologyVoApi:isAllTechnologyMaxLv()==true then
					return true
				elseif tostring(dailyTask.sid)=="1005" and accessoryVoApi:strengIsFull()==true then
					return true
				elseif tostring(dailyTask.sid)=="1012" and superWeaponVoApi:isCanPlunder()==true then
					return true
				elseif dailyTask.num and dailyTask.cNum and dailyTask.num>=dailyTask.cNum then
					return true
				end
			end
		end
	else
		local task=self:getTaskBySid(sid)
		if task then
			if task.num>=task.cNum then
				return true
			end
		end
	end
	return false
end

function taskVoApi:hadCurrentCompletedTask()
	local tasks=self:getCurrentTasks()
	local num=0
	local sid
	if tasks then
		for k,v in pairs(tasks) do
			if v.num>=v.cNum then
				num=num+1
				if sid==nil then
					sid=v.sid
				end
				--return true,v.sid
			end
		end
	end
	return num,sid
	--return false
end
function taskVoApi:hadDailyCompletedTask()
	local tasks=self:getDailyTasks()
	local num=0
	local sid
	local finishFlag=self:getFlag()
	if finishFlag>=0 then
		num=finishFlag
	end
	if tasks and SizeOfTable(tasks)>0 then
		num=0
		for k,v in pairs(tasks) do
			if self:isCompletedTask(v.sid,true)==true then
				num=num+1
				if sid==nil then
					sid=v.sid
				end
			end
		end
	end
	local boxRewardNum=self:dailyBoxCanRewardNum()
	num=num+boxRewardNum
	return num,sid
	--return false
end
function taskVoApi:hadCompletedTask()
	local num=self:hadCurrentCompletedTask()+self:hadDailyCompletedTask()
	return num
end

function taskVoApi:showIcon()
	local pic
	local completedNum=self:hadCurrentCompletedTask()
	if G_checkUseAuditUI()==true or G_getGameUIVer()==1 then
		if self:hadCurrentCompletedTask()>0 or self:hadDailyCompletedTask()>0 then
			pic="Icon_taskDone.png"
		else
			pic="Icon_haveTask.png"
		end
	else
		if self:hadCurrentCompletedTask()>0 or self:hadDailyCompletedTask()>0 then
			pic="Icon_taskDone1.png"
		else
			pic="Icon_haveTask1.png"
		end
	end
	return pic
end

function taskVoApi:getRefreshFlag()
	return self.refreshFlag
end
function taskVoApi:setRefreshFlag(refreshFlag)
	self.refreshFlag=refreshFlag
end


function taskVoApi:getTaskInfoById(sid,ifName,isDaily)
	local cfg = self:getTaskFromCfg(sid,isDaily)
	if cfg and SizeOfTable(cfg)>0 then
		local reqValue=cfg.require
		local requireValue=1
		if tonumber(cfg.type) ~= 4 then  --主线任务
			local groupId = cfg.group

			local key = "task_name_group_" .. groupId
			local value = ""

			local desc_key = "task_desc_group_" .. groupId
			local desc = "**"
			
			if groupId == "1" then -- 攻打玩家
				value = getlocal(key)
				desc = getlocal(desc_key)
			elseif reqValue then
				if groupId == "2" then -- 攻打关卡
					-- local k1 = Split(reqValue, ",")[1]
					-- local k2 = Split(reqValue, ",")[2]
					local k1 = reqValue[1]
					local k2 = reqValue[2]
					local k = getlocal("chapter_name_".. k1) .. "-" .. k2

					local str;
			        stid= (k1 -1) * 16 + k2
			        if stid<10 then
			            str="sample_stage_00"..stid
			        elseif stid>=10 and stid<100 then
			            str="sample_stage_0"..stid
			        elseif stid>=100 then
			            str="sample_stage_"..stid
			        end

					-- value = string.format(getlocal(key), k)
					value = getlocal(key,{k})
					desc = getlocal(str)
				elseif groupId == "5" then -- 晋升%s
					-- value = string.format(getlocal(key), playerVoApi:getRankName(tonumber(reqValue[1])))
					value = getlocal(key,{playerVoApi:getRankName(tonumber(reqValue[1]))}) 
					desc = getlocal(desc_key)
					requireValue=tonumber(reqValue[1])
				elseif tonumber(groupId) >= 6 and tonumber(groupId) <= 14 then
					local bMap = {a9="sample_build_name_02", a10="qiankuangchang", a6="sample_build_name_07", 
								  a8="sample_build_name_01", a7="sample_build_name_05", a14="sample_build_name_06",
								  a12="sample_build_name_08", a13="sample_build_name_10",a11="sample_build_name_04"}
					-- local k1 = Split(reqValue, ",")[1]
					-- local k2 = Split(reqValue, ",")[2]
					local k1 = reqValue[2]
					local k2 = reqValue[1]
					if tonumber(k1) == 1 then
						-- value = string.format(getlocal("task_name_group_b_1"), k2, getlocal(bMap["a"..groupId]))
						-- desc = string.format(getlocal(desc_key .. "_1"), k2)
						value = getlocal("task_name_group_b_1",{k2, getlocal(bMap["a"..groupId])}) 
						desc = getlocal(desc_key .. "_1",{k2})
						requireValue=k2
					elseif tonumber(k1) > 1 then
						-- value = string.format(getlocal("task_name_group_b_2"), k1, getlocal(bMap["a"..groupId]))
						value = getlocal("task_name_group_b_2",{k1, getlocal(bMap["a"..groupId])})
						if groupId == "14" then
							-- if k2 == "1" then
								local tankId=tankVoApi:getUnlockTankByBarrackLv(k1)
								if tankId and tonumber(tankId) then
									-- desc = string.format(getlocal(desc_key .. "_2"), k1, getlocal(tankCfg[tonumber(tankId)].name))
									desc = getlocal(desc_key .. "_2",{k1, getlocal(tankCfg[tonumber(tankId)].name)})
								end
							-- else
							-- 	desc = string.format(getlocal(desc_key .. "_3"), k1)
							--  desc = getlocal(desc_key .. "_3",{k1})
							-- end
						else
							-- desc = string.format(getlocal(desc_key .. "_2"), k1)
							desc = getlocal(desc_key .. "_2",{k1})
						end
						requireValue=k1
					end
				elseif groupId == "21" or groupId == "20" or groupId == "19" then
					local resMap = {a21="silicon", a20="oil", a19="metal"}
					key = "task_name_group_res"
					-- value = string.format(getlocal(key), getlocal(resMap["a"..groupId]), reqValue[1]..getlocal("schedule_hours"))
					-- desc = string.format(getlocal(desc_key), reqValue[1]..getlocal("schedule_hours"))
					value = getlocal(key,{getlocal(resMap["a"..groupId]), reqValue[1]..getlocal("schedule_hours")})
					desc = getlocal(desc_key,{reqValue[1]..getlocal("schedule_hours")})
					requireValue=reqValue[1]
				elseif groupId == "4" or groupId == "3" then --声望达到%s级， 攻打%s级地区
					-- value = string.format(getlocal(key), reqValue[1])
					value = getlocal(key,{reqValue[1]})
					if groupId == "4" then
						desc = getlocal(desc_key)
					else
						-- desc = string.format(getlocal(desc_key), reqValue[1])
						desc = getlocal(desc_key,{reqValue[1]})
					end
					requireValue=reqValue[1]
				elseif (tonumber(groupId) >= 15 and tonumber(groupId) <= 18) or (tonumber(groupId) >= 31 and tonumber(groupId) <= 39) then --造兵
					-- local k1 = Split(reqValue, ",")[1]
					-- local k2 = Split(reqValue, ",")[2]
					local k1 = reqValue[1]
					local k2 = reqValue[2]
					-- if tonumber(groupId) >= 37 then
					-- 	key = "task_name_group_s"
					-- elseif tonumber(groupId) >= 34 then
					-- 	key = "task_name_group_a"
					-- elseif tonumber(groupId) >= 31 then
					-- 	key = "task_name_group_t"
					-- end
					key = "task_name_group_t"
					-- value = string.format(getlocal(key), k2, getlocal(tankCfg[k1].name))
					value = getlocal(key,{k2, getlocal(tankCfg[k1].name)}) 
					desc_key = "task_desc_group_unit"
					-- desc = string.format(getlocal(desc_key), value)
					desc = getlocal(desc_key,{value})
					requireValue=k2
				end
			end 
			
			if ifName then
				return value,requireValue
			else
				return desc
			end
		elseif reqValue then
			-- local t = Split(reqValue, ",")[1]
			-- local v = Split(reqValue, ",")[2]
			local t = reqValue[1]
			local v = reqValue[2]
			local value_k = "dailytask_name_" .. t

			local isShowDesc=false
			if ifName then
			else
				if cfg then
					if cfg.isUrgency and cfg.isUrgency==1 then
						isShowDesc=true
					elseif cfg.isExtra and cfg.isExtra==1 then
						isShowDesc=true
					end
				end
			end
			if isShowDesc==true then
				local dTask=self:getTaskBySid(sid,true)
				local value_str=0
				if dTask and dTask.level then
					local num=dTask.level or 0
					if tonumber(sid)==2 then
						local chapterNum=checkPointVoApi:getChapterNum()
						local k1=math.ceil(num/chapterNum)
						local k2=num%chapterNum
						if k2==0 then
							k2=chapterNum
						end
						value_str = getlocal("chapter_name_".. k1) .. "-" .. k2
					else
						value_str=num
					end
				end
				local desc_k = "daily_task_des_" .. sid
				return getlocal(desc_k,{value_str})
			else
				local v = reqValue[1]
				local value_k = "daily_task_name_" .. sid
				local desc_k="daily_task_des_"..sid
				if (ifName==nil or ifName==false) then
					local descStr=getlocal(desc_k)
					if descStr then
						return descStr
					end
				end
				-- return string.format(getlocal(value_k), v),v
				return getlocal(value_k,{v}),v
			end
		else
			return ""
		end
	end
	return ""
end

function taskVoApi:getMainTask(isShowFinish)
	local task,isFinish=nil,false
	-- local incompleteTank=nil
	if base.mainTaskSwitch==1 then
		local tasks=self:getCurrentTasks()
		for k,v in pairs(tasks) do
			local taskCfg=self:getTaskFromCfg(v.sid)
			local isCompleted=self:isCompletedTask(v.sid)
			-- if taskCfg.main and taskCfg.main==1 then
				if task and task.sid then
					local tCfg=self:getTaskFromCfg(task.sid)
					local nameStr=taskVoApi:getTaskInfoById(task.sid,true)
					-- print("task.sid,nameStr,task.mainSort",task.sid,nameStr,tCfg.mainSort)
					if isShowFinish==true then
						-- local lastIsCompleted=self:isCompletedTask(task.sid)
						-- -- if tCfg.sortId and taskCfg.sortId and tonumber(taskCfg.sortId)<tonumber(tCfg.sortId) then
						-- if tCfg.mainSort and taskCfg.mainSort and tonumber(taskCfg.mainSort)<tonumber(tCfg.mainSort) then
						-- 	if isCompleted==true then
						-- 		task=v
						-- 		isFinish=isCompleted
						-- 	end
						-- else
						-- 	if lastIsCompleted==false and isCompleted==true then
						-- 		task=v
						-- 		isFinish=isCompleted
						-- 	end
						-- end
						if (isFinish==true and isCompleted==true) or (isFinish==false and isCompleted==false) then
							if taskCfg.mainSort<tCfg.mainSort then
								task=v
								isFinish=isCompleted
							end
						elseif isFinish==false and isCompleted==true then
							task=v
							isFinish=isCompleted
						end
					else
						if tCfg.mainSort and taskCfg.mainSort and tonumber(taskCfg.mainSort)<tonumber(tCfg.mainSort) then
							task=v
							isFinish=isCompleted
						end
					end
				else
					task=v
					isFinish=isCompleted
				end
			-- end
		end
	end
	return task,isFinish
end

function taskVoApi:removeDailyTask(sid,subType)
	if self.dailyTasks then
		for k,v in pairs(self.dailyTasks) do
			if tostring(v.sid)==tostring(sid) then
				table.remove(self.dailyTasks,k)
			end
		end
	end
	if self.dailyTypeTab and subType and self.dailyTypeTab[subType] then
		for k,v in pairs(self.dailyTypeTab[subType]) do
			if tostring(v.sid)==tostring(sid) then
				table.remove(self.dailyTypeTab[subType],k)
			end
		end
	end
end

function taskVoApi:getAddAlliancePoint(sid,isDailyPoint)
	local cfg=taskVoApi:getTaskFromCfg(sid,true,isDailyPoint)
	if cfg and cfg.raising and cfg.raising>0 then
		return cfg.raising
	end
	return 0
end
function taskVoApi:addAlliancePoint(sid,isDailyPoint)
	if sid then
		local point=self:getAddAlliancePoint(sid,isDailyPoint)
		if point and point>0 then
			G_addPlayerAward("a","point",nil,point,true)
		end
	end
end

function taskVoApi:taskRewardSmallDialog(index,layerNum,callback)
	require "luascript/script/game/scene/gamedialog/taskRewardSmallDialog"
    local sDialog=taskRewardSmallDialog:new()
    sDialog:init(index,layerNum,callback)
    return sDialog
end

function taskVoApi:acPointIsReward(index)
	local dailyHasRewardTb=self:getDailyHasRewardTb()
	local taskid="s200"..index
	if dailyHasRewardTb and dailyHasRewardTb[taskid] then
		return true
	else
		return false
	end			
end

function taskVoApi:setValueBySid(sid,num)
	if base.newDailyTask==1 then
		if self.dailyTasks then
			for k,v in pairs(self.dailyTasks) do
				if tostring(v.sid)==tostring(sid) then
					if num then
						v.num=num
					else
						v.num=v.num+1
					end
				end
			end
		end
	end
end

--新版优化开关
function taskVoApi:isShowNew()
	if base.newDailyTask==1 then
		return true
	else
		return false
	end
end

--新版优化开关
function taskVoApi:dailyBoxCanRewardNum()
	local num=0
	local nodeNum=5
	local acPoint=self:getAcPoint()
	local maxPoint=dailyTaskCfg2.maxPoint
	for i=1,nodeNum do
		local pointNum=maxPoint/nodeNum*i
		local isReward=self:acPointIsReward(i)
		if acPoint>=pointNum and isReward==false then
			num=num+1
		end
	end
	return num
end

