--SharedTaskMgr.lua
require "system.sharedtask.SharedTaskConstant"
require "system.sharedtask.SharedTaskServlet"
SharedTaskMgr = class(nil,Singleton,Timer)
g_sharedTaskServlet = SharedTaskServlet.getInstance()

function SharedTaskMgr:__init()
	self.teamSharedTask = {}
	self.mobMonstersList = {}
	self.teamTimer = {}
	gTimerMgr:regTimer(self, 1000, 1000)
	print("SharedTaskMgr Timer", self._timerID_)
	g_listHandler:addListener(self)
	self.monAttachPlayer = {}
	self.playerTaskMap_Gold = {}
	self.playerTaskMap_Silver = {}
	self.playerTaskMap_Bronze = {}
end

function SharedTaskMgr:AddTaskToList(player,rank,taskStatus)
	local name = player:getName()
	local level = player:getLevel()
	local tempStatus = 0
	local info = {}
	info.name = name
	info.level = level
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not roleTaskInfo:IsTaskOwner() then
		return
	end
	if taskStatus==nil then
		info.taskStatus = 0
	else
		local status = unserialize(taskStatus)
		for _,v in ipairs(status) do
			if v==1 then
				tempStatus = tempStatus + 1
			end
		end
		info.taskStatus = tempStatus
	end
	info.rank = rank
	if rank==1 then
		--table.remove(self.playerTaskMap_Bronze,player:getSerialID())
		self.playerTaskMap_Bronze[player:getSerialID()] = info
	elseif rank==2 then
		--table.remove(self.playerTaskMap_Silver,player:getSerialID())
		self.playerTaskMap_Silver[player:getSerialID()] = info
	elseif rank==3 then
		--table.remove(self.playerTaskMap_Gold,player:getSerialID())
		self.playerTaskMap_Gold[player:getSerialID()] = info
	end
end

function SharedTaskMgr:RemoveTaskFromList(player,rank)
	if rank==1 then
		self.playerTaskMap_Bronze[player:getSerialID()] = nil
		--table.remove(self.playerTaskMap_Bronze,player:getSerialID())
	elseif rank==2 then
		self.playerTaskMap_Silver[player:getSerialID()] = nil
		--table.remove(self.playerTaskMap_Silver,player:getSerialID())
	elseif rank==3 then
		self.playerTaskMap_Gold[player:getSerialID()] = nil
		--table.remove(self.playerTaskMap_Gold,player:getSerialID())
	end
end

function SharedTaskMgr:GetSharedTaskPrizeNums(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then 
		print("can not find player")
		return 
	end
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not roleTaskInfo then
		print("no task data")
		--g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end

	local nums = roleTaskInfo:getRemainSharedTaskPrize()
	local ret = {}
	ret.remainNum = nums
	ret.allNum = SHARED_TASK_PRIZE_NUM
	fireProtoMessage(player:getID(), TASK_SC_GET_SHARED_TASK_TIMES, 'GetSharedTaskTimesRetProtocol', ret)

end

function SharedTaskMgr:AcceptSharedTask(roleID,taskRank,owner)
	local player = g_entityMgr:getPlayer(roleID)
	--local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then 
		print("can not find player")
		return 
	end
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not roleTaskInfo then
		print("no task data")
		--g_taskServlet:sendErrMsg2Client(player:getID(), -51, 0)
		return
	end
	
	if player:getLevel() < SHARED_TASK_NEEDLEVEL then
		g_taskServlet:sendErrMsg2Client(player:getID(), -96, 0)
		return
	end
	--查看现有任务
	if roleTaskInfo:getSharedTask() then
		--print("already have task")
		g_taskServlet:sendErrMsg2Client(player:getID(), -67, 0)
		return
	end

	if roleTaskInfo:getRemainSharedTaskPrize()>=SHARED_TASK_PRIZE_NUM then
		--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(TASK_SC_GET_SHARED_TASK_PRIZE_RET)
		retBuff:pushInt(roleID)
		returnCode = -2
		retBuff:pushInt(returnCode)
		g_engine:fireLuaEvent(player:getID(), retBuff)]]
		returnCode = -2
		local ret = {}
		ret.roleId = roleID
		ret.errCode = returnCode
		fireProtoMessage(player:getID(), TASK_SC_GET_SHARED_TASK_PRIZE_RET, 'GetSharedTaskPrizeRetProtocol', ret)
		return
	end

	local material = 0
	local errorCode = -1
	if taskRank==1 then
		material = SHARED_TASK_MATERIAL1
		errorCode = -73
	elseif taskRank==2 then
		material = SHARED_TASK_MATERIAL2
		errorCode = -74
	elseif taskRank==3 then
		material = SHARED_TASK_MATERIAL3
		errorCode = -75
	end
	if not isMatEnough(player, material, 1) then
		g_taskServlet:sendErrMsg2Client(player:getID(), errorCode, 0)
		return false
	end
	costMat(player, material, 1, 0, 0)

	local team = g_TeamPublic:getTeam(player:getTeamID())
	local teamnum = 0
	if team then
		teamMembers = team:getOnLineMems()
		teamnum = #teamMembers
	end
	g_tlogMgr:TlogYGBZFlow(player,taskRank,0,1)
	local taskId,targetList = g_LuaTaskDAO:filtrateSharedTask(taskRank)
	print("Accept shared task:",taskId,toString(targetList))
	roleTaskInfo:setSharedTaskTargetPos(targetList)
	g_taskServlet:receiveTask(player, TaskType.Shared, taskId,0,owner)
	

	roleTaskInfo:cast2db()
	local ret = {}
	ret.roleId = player:getID()
	fireProtoMessage(player:getID(), TASK_SC_AFTER_GET_SHARED_TASK, 'AfterGetSharedTaskProtocol', ret)
	self:AddTaskToList(player,taskRank,nil)
end

function SharedTaskMgr:ShareTaskToTeamMate(roleID,taskId)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then return end
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not roleTaskInfo then
		print("no task data")
		return
	end

	local task = roleTaskInfo:getSharedTask()
	if not task or not (task:getID()==taskId) then
		g_taskServlet:sendErrMsg2Client(player:getID(), -70, 0)
		return
	end
	if task:canEnd() then
		g_taskServlet:sendErrMsg2Client(player:getID(), -84, 0)
		return
	end
	if not roleTaskInfo:IsTaskOwner() then
		g_taskServlet:sendErrMsg2Client(player:getID(), -68, 0)
		return
	end
	
	local teamId = player:getTeamID()
	local team = g_TeamPublic:getTeam(teamId)
	if team then
		self.teamSharedTask[teamId] = task
		local teamMember = team:getOnLineMems()
		for _,memberId in pairs(teamMember) do
			if not (memberId == player:getSerialID()) then 
				local member = g_entityMgr:getPlayerBySID(memberId)
				if member then
					if member:getLevel() >= SHARED_TASK_NEEDLEVEL then
						local taskInfo = g_taskMgr:getRoleTaskInfoBySID(memberId)
						if taskInfo and not taskInfo:getSharedTask() then
							local ret = {}
							ret.roleId = player:getID()
							ret.taskId = taskId
							ret.name = player:getName()
							fireProtoMessage(member:getID(), TASK_SC_SHARE_TASK, 'ShareTaskRetProtocol', ret)
						else
							g_taskServlet:sendErrMsg2Client(player:getID(), -78, 1,{member:getName()})
						end
					end
				end
			end
		end
		g_taskServlet:sendErrMsg2Client(player:getID(), -79, 0)
	else
		g_taskServlet:sendErrMsg2Client(player:getID(), -69, 0)
		return
	end
end

function SharedTaskMgr:checkSourcePlayerTask(roleID,taskId,tplayer)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then 
		return false
	end

	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not roleTaskInfo then
		return false
	end
	local task = roleTaskInfo:getSharedTask()
	if not task then
		return false
	end
	if task:getID() ~= taskId then
		return false
	end
	if tplayer:getTeamID()~=player:getTeamID() then
		return false
	end
	return true
end

function SharedTaskMgr:doConfirmSharedTask(roleID,taskId,sRoleID,result)

	local player = g_entityMgr:getPlayer(roleID)
	if not player then 
		return 
	end
	if player:getLevel() < SHARED_TASK_NEEDLEVEL then
		return
	end
	if result==0 then
		g_taskServlet:sendErrMsg2Client(sRoleID, -77, 1,{player:getName()})
		return
	end
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not roleTaskInfo then
		print("no task data")
		return
	end
	local task = roleTaskInfo:getSharedTask()
	if task then
		return
	end



	if not self:checkSourcePlayerTask(sRoleID,taskId,player) then
		g_taskServlet:sendErrMsg2Client(player:getID(), -85, 0)
		return
	end

	if roleTaskInfo:getRemainSharedTaskPrize()>=SHARED_TASK_PRIZE_NUM then
		returnCode = -2
		local ret = {}
		ret.roleId = roleID
		ret.errCode = returnCode
		fireProtoMessage(player:getID(), TASK_SC_GET_SHARED_TASK_PRIZE_RET, 'GetSharedTaskPrizeRetProtocol', ret)
		return
	end


	local teamId = player:getTeamID()
	local team = g_TeamPublic:getTeam(teamId)
	if not team then return end
	if self.teamSharedTask[teamId] and not self.teamSharedTask[teamId]:getID() == taskId then
		g_taskServlet:sendErrMsg2Client(player:getID(), -70, 0)
		return
	end

	local sPlayer = g_entityMgr:getPlayer(sRoleID)
	if not sPlayer then return end
	local taskinfo = g_taskMgr:getRoleTaskInfoBySID(sPlayer:getSerialID())

	local state = serialize(self.teamSharedTask[teamId]:getTargetStates())
	roleTaskInfo:loadSharedTask(taskId,state)
	roleTaskInfo:setSharedTaskTargetPos(taskinfo:getSharedTaskTargetPos())
	roleTaskInfo:clearTaskOwner()
	task = roleTaskInfo:getSharedTask()
	local retBuffer = SCADDSHAREDTASK.writeFun(task:getID(), task:getTargetStates(),0,roleTaskInfo:getSharedTaskTargetPos())
	--g_engine:fireLuaEvent(player:getID(), retBuffer)
	fireProtoMessage(player:getID(), TASK_SC_ADD_SHARED_TASK, 'AddSharedTaskProtocol', retBuffer)
	g_taskServlet:sendErrMsg2Client(sPlayer:getID(), -76, 1,{player:getName()})

	local ret = {}
	ret.roleId = player:getID()
	fireProtoMessage(player:getID(), TASK_SC_AFTER_GET_SHARED_TASK, 'AfterGetSharedTaskProtocol', ret)

end

function SharedTaskMgr:doGetSharedTaskPrize(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then return end
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not roleTaskInfo then
		print("no task data")
		return
	end
	local task = roleTaskInfo:getSharedTask()
	local returnCode = 0
	if not task then
		returnCode = -1
		local ret = {}
		ret.roleId = roleID
		ret.errCode = returnCode
		ret.sharedTaskPrizeNum = roleTaskInfo:getSharedTaskPrizeNum()
		ret.allPrizeNum = SHARED_TASK_PRIZE_NUM
		fireProtoMessage(player:getID(), TASK_SC_GET_SHARED_TASK_PRIZE_RET, 'GetSharedTaskPrizeRetProtocol', ret)
		return
	end
	if roleTaskInfo:getRemainSharedTaskPrize()>=SHARED_TASK_PRIZE_NUM then
		returnCode = -2
		local ret = {}
		ret.roleId = roleID
		ret.errCode = returnCode
		ret.sharedTaskPrizeNum = roleTaskInfo:getSharedTaskPrizeNum()
		ret.allPrizeNum = SHARED_TASK_PRIZE_NUM
		fireProtoMessage(player:getID(), TASK_SC_GET_SHARED_TASK_PRIZE_RET, 'GetSharedTaskPrizeRetProtocol', ret)
		return
	end
	if not task:canEnd() then
		returnCode = -3
		local ret = {}
		ret.roleId = roleID
		ret.errCode = returnCode
		ret.sharedTaskPrizeNum = roleTaskInfo:getSharedTaskPrizeNum()
		ret.allPrizeNum = SHARED_TASK_PRIZE_NUM
		fireProtoMessage(player:getID(), TASK_SC_GET_SHARED_TASK_PRIZE_RET, 'GetSharedTaskPrizeRetProtocol', ret)
		return
	end
	g_taskServlet:finishTask(player:getID(), roleTaskInfo:getSharedTask())
	local num = roleTaskInfo:getSharedTaskPrizeNum()
	roleTaskInfo:updateSharedTaskPrize(1)
	local ret = {}
	ret.roleId = roleID
	ret.errCode = returnCode
	ret.sharedTaskPrizeNum = roleTaskInfo:getSharedTaskPrizeNum()
	ret.allPrizeNum = SHARED_TASK_PRIZE_NUM
	fireProtoMessage(player:getID(), TASK_SC_GET_SHARED_TASK_PRIZE_RET, 'GetSharedTaskPrizeRetProtocol', ret)
	roleTaskInfo:cast2db()

	local prizeStr = SHARED_TASK_PRIZE1
	local taskproto = g_LuaTaskDAO:getSharedTask(task:getID())
	if taskproto.q_rank == 1 then
		prizeStr = SHARED_TASK_PRIZE1
	elseif taskproto.q_rank == 2 then
		prizeStr = SHARED_TASK_PRIZE2
	elseif taskproto.q_rank == 3 then
		prizeStr = SHARED_TASK_PRIZE3
	end
	if roleTaskInfo:IsTaskOwner() then
		self:RemoveTaskFromList(player,taskproto.q_rank)
	end
	

	local team = g_TeamPublic:getTeam(player:getTeamID())
	local teamnum = 0
	if team then
		teamMembers = team:getOnLineMems()
		teamnum = #teamMembers
	end

	g_tlogMgr:TlogYGBZFlow(player,taskproto.q_rank,-1,1)
	-- g_masterMgr:finishMasterTask(MASTER_TASK_ID.TREASURE, player:getSerialID())
	g_normalMgr:activeness(player:getID(),ACTIVENESS_TYPE.PRECIOUS)
	g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.PRECIOUS, 1)

	roleTaskInfo:clearTaskOwner()

	if taskproto.q_rank == 3 then
		g_entityDao:updateShareTaskCount(player:getSerialID(),taskproto.q_rank)
	end

	g_taskServlet:sendErrMsg2Client(player:getID(), -72, 1,{prizeStr})
end
local MonsterPos = 
{
	-1,0,  -1,1,  0,1,   1,1,   1,0,   1,-1,   0,-1,  -1,-1, 
	-2,0,  -2,1,  -2,2,  -1,2,  0,2,   1,2,    2,2,   2,1,  2,0,  2,-1,  2,-2,  1,-2,  0,-2,  -1,-2,  -2,-2,  -2,-1,
	-3,0,  -3,1,  -3,2,  -3,3,  -2,3,  -1,3,   0,3,   1,3,  2,3,  3,3,   3,2,   3,1,   3,0,   3,-1,   3,-2,    3,-3,
	2,-3,  1,-3,  0,-3,  -1,-3, -2,-3, -3,-3,  -3,-2, -3,-1
}

function SharedTaskMgr:IsTreasureKeeper(monsterId)
	if monsterId>=391 and monsterId<=402 then return true else return false end
end

function SharedTaskMgr:SyncTaskStatus(monsterId,monId,mapId)
	local playerSId = self.monAttachPlayer[monId]
	local player = g_entityMgr:getPlayerBySID(playerSId)
	if not player then return end
	table.remove(self.monAttachPlayer,monId)
	local teamId = player:getTeamID()
	local mapId = player:getMapID()
	local team = g_TeamPublic:getTeam(teamId)
	--取不到队伍至少让玩家自己走任务进度
	if team then
		local teamMember = team:getOnLineMems()
		
		--队友杀死的怪物可以共享
		for _,memberId in pairs(teamMember) do
			if not (roleSID == memberId) then
				--print("TaskManager:onMonsterKill",memberId)
				local member = g_entityMgr:getPlayerBySID(memberId)
				if member then --and mapId == member:getMapID() then
					g_taskMgr:NotifyListener(member, "onMonsterKilled", monsterId,mapId)
				end
			end
		end
	end
	g_taskMgr:NotifyListener(player, "onMonsterKilled", monsterId)
end

function SharedTaskMgr:flushMonster(monsterinfo,player,teamId,mapid,x,y)
	--开始刷怪
	local mapID = mapid
	local scene = player:getScene()
	local monnum = 0
	if scene then
		monsterlist = {}
		for i=1,monsterinfo[2] do
			monnum = monnum + 2
			local mon = g_entityMgr:getFactory():createMonster(monsterinfo[1])
			--mon:setLevel(player:getLevel())
			if scene:attachEntity(mon:getID(), x+MonsterPos[monnum-1], y+MonsterPos[monnum]) then
				scene:addMonster(mon)
				--mon:changeAIRule(0)
				table.insert(monsterlist,mon:getID())
			end
			if mon then
				self.monAttachPlayer[mon:getID()] = player:getSerialID()
			end
		end
		self:addToMonsterList(teamId,monsterlist)
		self:addToTeamTimer(teamId,os.time()+SHARED_TASK_MON_LASTTIME)
		g_taskServlet:sendErrMsg2Client(player:getID(), -80, 0)
	end
end

function SharedTaskMgr:getDistance(x1,y1,tx,ty)
	local dist1 = math.abs(x1-tx)
	local dist2 = math.abs(y1-ty)
	return math.max(dist1,dist2)
end


function SharedTaskMgr:doFlushTaskMonsters(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	--local player = g_entityMgr:getPlayerBySID(roleID)
	if not player then return end
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
	if not roleTaskInfo then
		print("no task data")
		return
	end
	local task = roleTaskInfo:getSharedTask()
	if not task then
		print("no task")
		return
	end
	local taskTargetState = task:getTargetStates()
	local targetPos = roleTaskInfo:getSharedTaskTargetPos()
	local taskProto = g_LuaTaskDAO:getSharedTask(task:getID())
	local curPosx = player:getPosition().x
	local curPosy = player:getPosition().y
	local monsterinfo = {}
	local mapid = 0
	local x = 0
	local y = 0
	if taskProto then
		local monsters = '{' ..taskProto.q_monsters .. '}'
		monsters = string.gsub(monsters, '%[', '%{')
		monsters = string.gsub(monsters, '%]', '%}')
		monsters = unserialize(monsters)
		local curMapID = player:getMapID()
		for i=1,#monsters do
			mapid = targetPos[i].mapid
			x = targetPos[i].x
			y = targetPos[i].y
			local distance = self:getDistance(curPosx,curPosy,x,y)
			
			if distance<=SHARED_TASK_MOB_RANGE and curMapID==mapid then
				--if taskTargetState[i]<monsters[i][2] then
				if taskTargetState[i]==0 then--当前任务目标还没完成
					if i==1 then
						monsterinfo = monsters[i]
						break
					elseif taskTargetState[i-1]==1 then--前一个目标已经完成，四个任务目标必须一个一个杀
						monsterinfo = monsters[i]
						break
					end
				end
			end
		end
	end
	if monsterinfo=="{}" or #monsterinfo==0 then
		print("no monsters")
		return
	end
	local teamId = player:getTeamID()
	if teamId == 0 then
		teamId = player:getSerialID()
	end
	local strID = string.format("%d_%d_%d_%d",teamId,mapid,x*1000+y,task:getID())
	local monsterList = self:getTeamMonsterList(strID)
	if monsterList and #monsterList>0 then
		--g_taskServlet:sendErrMsg2Client(sRoleID, -86, 0)
		--print("already monsters",strID)
		for i=1,#monsterlist do
			g_entityMgr:destoryEntity(monsterList[i])
		end
		self:clearTeamMonsterList(strID)
		self:clearTeamTimer(strID)
	end
	--local taskProto = g_LuaTaskDAO:getSharedTask(20000)
	self:flushMonster(monsterinfo,player,strID,mapid,x,y)
end

function SharedTaskMgr:addToMonsterList(teamid,monsterlist)
	self.mobMonstersList[teamid] = monsterlist
end

function SharedTaskMgr:getTeamMonsterList(teamid)
	return self.mobMonstersList[teamid] or {}
end

function SharedTaskMgr:clearTeamMonsterList(teamid)
	self.mobMonstersList[teamid] = {}
end

function SharedTaskMgr:addToTeamTimer(teamid,time)
	self.teamTimer[teamid] = time
end

function SharedTaskMgr:getTeamTimer(teamid)
	return self.teamTimer[teamid] or 0
end

function SharedTaskMgr:clearTeamTimer(teamid)
	self.teamTimer[teamid] = 0
end



function SharedTaskMgr:onPlayerLogout(player)
	
end

function SharedTaskMgr:onPlayerInactive(player)
	print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	local roleSID = player:getSerialID()
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleSID)
	if not roleTaskInfo then
		return
	end
	local task = roleTaskInfo:getSharedTask()
	if not task then
		return
	end
	if roleTaskInfo:IsTaskOwner() then
		local taskP = g_LuaTaskDAO:getSharedTask(task:getID())
		self:RemoveTaskFromList(player,taskP.q_rank)
	end
	self:deleteSharedTask(player:getID(),false)
end

function SharedTaskMgr:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleSID)
	if not roleTaskInfo then
		return
	end
	local task = roleTaskInfo:getSharedTask()
	if not task then
		return
	end
	if roleTaskInfo:IsTaskOwner() then
		local taskP = g_LuaTaskDAO:getSharedTask(task:getID())
		self:RemoveTaskFromList(player,taskP.q_rank)
	end
	self:deleteSharedTask(player:getID(),false)
end

function SharedTaskMgr:IsTaskOwner(roleSID)
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleSID)
	if not roleTaskInfo then
		return false
	end
	return roleTaskInfo:IsTaskOwner()
end

function SharedTaskMgr:deleteSharedTask(roleID,force)
	local player = g_entityMgr:getPlayer(roleID)
	local roleSID = player:getSerialID()
	local roleTaskInfo = g_taskMgr:getRoleTaskInfoBySID(roleSID)
	if not roleTaskInfo then
		return false
	end
	if roleTaskInfo:IsTaskOwner() and force then
		local task = g_LuaTaskDAO:getSharedTask(roleTaskInfo:getSharedTask():getID())
		self:RemoveTaskFromList(player,task.q_rank)
	end
	--print("+++++++++++++deleteSharedTask",roleID,force)
	if roleTaskInfo:IsTaskOwner()  and not force then 
		local sTeamID = player:getTeamID()
		local team = g_TeamPublic:getTeam(sTeamID)
		if team then 
			local onMems = team:getOnLineMems() or {}
			for _,mem in pairs(onMems) do
				local member = g_entityMgr:getPlayerBySID(mem)
				if member and not g_sharedTaskMgr:IsTaskOwner(member:getSerialID()) then
					g_sharedTaskMgr:deleteSharedTask(member:getID(),false)
				end
			end
		end
		return 
	end
	local task = roleTaskInfo:getSharedTask()
	if not task then
    	return false
	end 
	if task:canEnd() and not force then
		return false
	end
	if roleTaskInfo:IsTaskOwner() then
		local sTeamID = player:getTeamID()
		local team = g_TeamPublic:getTeam(sTeamID)
		if team then 
			local onMems = team:getOnLineMems() or {}
			for _,mem in pairs(onMems) do
				local member = g_entityMgr:getPlayerBySID(mem)
				if member then
					g_sharedTaskMgr:deleteSharedTask(member:getID(),false)
				end
			end
		end
	end
	
	roleTaskInfo:removeSharedTask()
	local retBuff = SCADDSHAREDTASK.writeFun(0,"{}",0,{})
	fireProtoMessage(roleID, TASK_SC_ADD_SHARED_TASK, 'AddSharedTaskProtocol', retBuff)

	g_taskServlet:sendErrMsg2Client(player:getID(), -71, 0)
	roleTaskInfo:clearTaskOwner()
	return true
end


function SharedTaskMgr:update()
	for teamid,timer in pairs(self.teamTimer) do
		if os.time()>=timer then
			local monsterlist = self:getTeamMonsterList(teamid)
			for i=1,#monsterlist do
				table.remove(self.monAttachPlayer,monsterlist[i])
				g_entityMgr:destoryEntity(monsterlist[i])
			end
			self:clearTeamMonsterList(teamid)
			self:clearTeamTimer(teamid)
		end
	end
end

function SharedTaskMgr:ComposeSharedTaskList(roleId,sid)
	local ret = {}
	ret.infos = {}
	local count = 0
	for i,v in pairs(self.playerTaskMap_Gold) do
		if i~=sid and v.taskStatus<4 then
			local info = {}
			info.name = v.name
			info.level = v.level
			info.roleSid = i
			info.taskRank = v.rank
			info.taskStatus = v.taskStatus
			table.insert(ret.infos,info)
			count = count + 1
			if count>=MAX_SHARED_TASK_LIST_NUM then break end
		end
	end
	if count<MAX_SHARED_TASK_LIST_NUM then
		for i,v in pairs(self.playerTaskMap_Silver) do
			if i~=sid and v.taskStatus<4 then
				local info = {}
				info.name = v.name
				info.level = v.level
				info.roleSid = i
				info.taskRank = v.rank
				info.taskStatus = v.taskStatus
				table.insert(ret.infos,info)
				count = count + 1
				if count>=MAX_SHARED_TASK_LIST_NUM then break end
			end
		end
	end
	if count<MAX_SHARED_TASK_LIST_NUM then
		for i,v in pairs(self.playerTaskMap_Bronze) do
			if i~=sid and v.taskStatus<4 then
				local info = {}
				info.name = v.name
				info.level = v.level
				info.roleSid = i
				info.taskRank = v.rank
				info.taskStatus = v.taskStatus
				table.insert(ret.infos,info)
				count = count + 1
				if count>=MAX_SHARED_TASK_LIST_NUM then break end
			end
		end
	end
	fireProtoMessage(roleId,TASK_SC_GET_SHARED_TASK_RET,"GetSharedTaskListRetProtocol",ret)
end

function SharedTaskMgr:RequestAddToSharedTaskTeam(roleId,tRoleSid,taskRank)
	local targetPlayer = g_entityMgr:getPlayerBySID(tRoleSid)
	local player = g_entityMgr:getPlayer(roleId)
	if not player then return end
	if not targetPlayer then
		g_taskServlet:sendErrMsg2Client(roleId, -93, 0)--这里需要定新的错误编号
		return
	end
	local teamId = targetPlayer:getTeamID()
	local team = g_TeamPublic:getTeam(teamId)
	if team then--有队伍就申请加入该队伍
		local playerTeamId = player:getTeamID()
		local playerTeam = g_TeamPublic:getTeam(playerTeamId)
		if playerTeam then
			local buffer6 = g_TeamPublic:getTipsMsg(TEAM_ERR_CAN_APPLY_JOIN,TEAM_CS_INVITE_TEAM,0,{})
			fireProtoMessageBySid(player:getSerialID(), FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
			return
		end
		local sTeamId = player:getTeamID()
		local sTeam = g_TeamPublic:getTeam()
		if sTeamId==teamId then
			return
		end
		self:ApplyInTeam(teamId,player:getSerialID(),tRoleSid)
	else--没有队伍就申请组队
		
		local sTeamId = player:getTeamID()
		local sTeam = g_TeamPublic:getTeam(sTeamId)
		if not sTeam then 
			g_TeamPublic:onCreateTeam(player)
			local sRoleMemInfo = g_TeamPublic:getMemInfoBySID(player:getSerialID())
			sTeamId = sRoleMemInfo:getTeamID()
		end
		self:InviteInTeam(sTeamId,player:getSerialID(),tRoleSid)
	end
end

function SharedTaskMgr:InviteInTeam(sTeamID,dbid,sRoleSID)
	--他加入我的队伍   队员拉人进来 不需要 通过队长同意
	local sTeam = g_TeamPublic:getTeam(sTeamID)
	if not sTeam then return end
	local tRoleMemInfo = g_TeamPublic:getMemInfoBySID(sRoleSID)
	if not tRoleMemInfo then return end
	if sTeam:getMemCount() >= TEAM_MAX_MEMBER then
		--返回队伍人数已满提示			
		local buffer6 = g_TeamPublic:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	else
		if tRoleMemInfo:getAutoInvited() then
			--删除过期的邀请
			tRoleMemInfo:updateInvite()				
			--玩家忙
			if tRoleMemInfo:getInviteCnt() >= TEAM_MAX_INVITE then
				local buffer = g_TeamPublic:getTipsMsg(TEAM_TIP_PLAYER_BUSY, TEAM_CS_INVITE_TEAM, 0, {})
				fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
				return
			end
			--已经邀请过了
			if tRoleMemInfo:isInvited(dbid) then
				local buffer = g_TeamPublic:getTipsMsg(TEAM_ERR_HAS_INVITED, TEAM_CS_INVITE_TEAM, 0, {})
				fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
				return
			end
			tRoleMemInfo:addInvite(dbid)	
			local player = g_entityMgr:getPlayerBySID(dbid)			
			local retBuff = SCINVITETEAMRET.writeFun(dbid, sTeamID, true,player:getName())			
			fireProtoMessageBySid(sRoleSID, TEAM_SC_INVITE_TEAM_RET , 'TeamInviteTeamRetProtocol', retBuff)
			--g_engine:fireSerialEvent(tRoleSID,retBuff) 		--发消息给对方
			
			--返回提示成功向对方发起组队邀请
			local buffer = g_TeamPublic:getTipsMsg(TEAM_TIP_INVITE_SEND_SUCCEED,TEAM_CS_INVITE_TEAM,0,{})
			fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		else
			--他设置了不能自动组队				
			local buffer6 = g_TeamPublic:getTipsMsg(TEAM_ERR_INVITE_REFUSED,TEAM_CS_INVITE_TEAM,1,{tRoleMemInfo:getName() or ""})
			fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
			return
		end
	end	
end

function SharedTaskMgr:ApplyInTeam(teamId,sRoleSID,tRoleSID)
	local tTeam = g_TeamPublic:getTeam(teamId)
	local tLeaderSID = tTeam.leaderID
	local dbid = sRoleSID
	local player = g_entityMgr:getPlayerBySID(dbid)
	local sRoleMemInfo = g_TeamPublic:getMemInfoBySID(sRoleSID)
	if tTeam:isApplyed(sRoleSID) then
		--返回错误提示 已经申请过了
		local buffer6 = g_TeamPublic:getTipsMsg(TEAM_ERR_HAS_APPLYED,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	end

	if tTeam:getMemCount() >= TEAM_MAX_MEMBER then
		--返回队伍人数已满提示			
		local buffer6 = g_TeamPublic:getTipsMsg(TEAM_ERR_MAX_MEMBER,TEAM_CS_INVITE_TEAM,0,{})
		fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer6)
		return
	else
		if not tTeam:getAutoInvited() then
			if tTeam:getApplyCnt() >= TEAM_MAX_APPLY then
				local buffer = g_TeamPublic:getTipsMsg(TEAM_TIP_TEAM_BUSY, TEAM_CS_INVITE_TEAM, 0, {})
				fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
				return
			end				
			
			--已经申请过了
			if tTeam:isApplyed(sRoleSID) then
				--tTeam:updateApplyTime(sRoleSID)
				local buffer = g_TeamPublic:getTipsMsg(TEAM_ERR_HAS_APPLYED, TEAM_CS_INVITE_TEAM, 0, {})
				fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
				return
			end
			tTeam:addNewApply(tLeaderSID,sRoleSID, dbid)				
			local leaderMemInfo = g_TeamPublic:getMemInfoBySID(tLeaderSID)
			if leaderMemInfo then
				local retBuff = SCINVITETEAMRET.writeFun(sRoleSID, tTeamID, false,player:getName())			
				fireProtoMessageBySid(tLeaderSID, TEAM_SC_INVITE_TEAM_RET , 'TeamInviteTeamRetProtocol', retBuff)
			end								
			--返回提示申请发送成功
			local buffer = g_TeamPublic:getTipsMsg(TEAM_TIP_APPLYED_SEND_SUCCEED,TEAM_CS_INVITE_TEAM,0,{})
			fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
			return
		else
			--清除tRole所有的邀请和申请记录
			tTeam:removeApplyID(sRoleSID)
			if sRoleMemInfo then 
				sRoleMemInfo:clear()
			end
			if isApply then
				g_TeamPublic:addMemIntoTeam(tLeaderSID,sRoleSID,dbid)
			else				
				g_TeamPublic:addMemIntoTeam(tRoleSID,sRoleSID,dbid)
			end
			
			--返回提示申请成功
			local buffer = g_TeamPublic:getTipsMsg(TEAM_TIP_APPLYED_SUCCEED,TEAM_CS_INVITE_TEAM,0,{})
			fireProtoMessageBySid(dbid, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', buffer)
		end
	end
end

function SharedTaskMgr.getInstance()
	return SharedTaskMgr()
end
g_sharedTaskMgr = SharedTaskMgr.getInstance()