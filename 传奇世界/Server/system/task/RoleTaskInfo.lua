--RoleTaskInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  RoleTaskInfo.lua
 --* Author:  seezon
 --* Modified: 2014Äê4ÔÂ8ÈÕ
 --* Purpose: Implementation of the class RoleTaskInfo
 -------------------------------------------------------------------*/

RoleTaskInfo = class()

local prop = Property(RoleTaskInfo)
prop:accessor("roleSID")
prop:accessor("roleID")
prop:accessor("taskEventSet")
prop:accessor("curMainTaskId")			--µ±Ç°Ö÷ÏßÈÎÎñID
prop:accessor("dailyTaskStamp", 0)		--ÈÕ³£ÈÎÎñÊ±¼ä´Á

-- ÐüÉÍÈÎÎñ20160106
prop:accessor("AnnRewardTaskNum", 0)			--Ã¿ÈÕ·¢²¼ÐüÉÍÈÎÎñ´ÎÊý
prop:accessor("AnnSuperRewardTaskNum", 0)
prop:accessor("AccBlueRewardTaskNum", 0)			--Ã¿ÈÕÁìÈ¡ÐüÉÍÈÎÎñÀ¶É«´ÎÊý
prop:accessor("AccPurpleRewardTaskNum", 0)		--Ã¿ÈÕÁìÈ¡ÐüÉÍÈÎÎñ×ÏÉ«´ÎÊý
prop:accessor("AccSuperRewardTaskNum", 0)
prop:accessor("RewardTaskStamp", 0)				--ÐüÉÍÈÎÎñÊ±¼ä´Á
prop:accessor("RewardTaskGUID", 0)				--ÐüÉÍÈÎÎñGUID
prop:accessor("RewardTaskGuardTime", 0)			--任务独占结束时间

prop:accessor("finishByIngot",0) --ÈÕ³£ÈÎÎñ»¨Ôª±¦Íê³ÉµÄ´ÎÊý

prop:accessor("SharedTaskStamp",0) --¹²ÏíÈÎÎñÊ±¼ä´Á
prop:accessor("SharedTaskPrizeNum",0) --¹²ÏíÈÎÎñÃ¿ÈÕÒÑÁì½±´ÎÊý



function RoleTaskInfo:__init()
	self.mainTask = nil --Ö÷ÏßÈÎÎñ
	self.dailyTask = nil --ÈÕ³£ÈÎÎñ
	self.branchTask = {}  --Ö§ÏßÈÎÎñ
	self.lastTaskInfo = {}  --×îºóÒ»¸öÈÎÎñµÄÐÅÏ¢
	self.hasFinishBrachIDs = {}  --ÒÑ¾­Íê³ÉµÄÖ§ÏßÈÎÎñID

-- ÐüÉÍÈÎÎñ20160106
	self.rewardTask = nil --ÁìÈ¡µÄÐüÉÍÈÎÎñ

	self.sharedTask = nil --ÁìÈ¡µÄ·ÖÏíÈÎÎñ
	self.sharedTaskOwner = 0 --±ê¼ÇÊÇ·ñÊÇ¹²ÏíÈÎÎñµÄÖ÷ÈË£¬Ö÷ÈË¿ÉÒÔ·ÖÏí¸ø±ðÈË
	self.sharedTaskTargetPos = {}

end

function RoleTaskInfo:__release()
	release(self.mainTask)
	release(self.dailyTask)
	release(self.rewardTask)
	release(self.sharedTask)

	for _,task in pairs(self.branchTask) do 
		release(task)
	end  
end

function RoleTaskInfo:getSharedTaskTargetPos()
	return self.sharedTaskTargetPos
end

function RoleTaskInfo:setSharedTaskTargetPos(targetPos)
	self.sharedTaskTargetPos = targetPos
end

--»ñÈ¡Íæ¼Ò×î¶àÄÜ×öµÄÈÕ³£ÈÎÎñ´ÎÊý
function RoleTaskInfo:getMaxDailyLoop()
    return TASK_DAILY_MAX_TIME
end

--Ë¢ÐÂÈÕ³£ÈÎÎñÊ±¼ä´Á
function RoleTaskInfo:freshDailyStamp()
	local stamp = tonumber(time.toedition("day") + 1)
	self:setDailyTaskStamp(stamp)
	self:setFinishByIngot(0)
	self:cast2db()
end

function RoleTaskInfo:freshDay()
	self:freshDailyTask()
end


--Ôö¼ÓÒÑ¾­Íê³ÉµÄÖ§ÏßÈÎÎñID
function RoleTaskInfo:addFinishBrachID(id)
	table.insert(self.hasFinishBrachIDs, id)
	self:cast2db2()
end

--ÅÐ¶ÏÊÇ·ñÒÑ¾­Íê³ÉµÄÖ§ÏßÈÎÎñID
function RoleTaskInfo:isFinishBrachID(id)
	return table.contains(self.hasFinishBrachIDs, id) and true or false
end

--»ñÈ¡ÒÑ¾­Íê³ÉµÄÖ§ÏßÈÎÎñ
function RoleTaskInfo:getAllFinishBrachID()
	return self.hasFinishBrachIDs
end

--ÉèÖÃÖ÷ÏßÈÎÎñ
function RoleTaskInfo:setMainTask(task)
	self.mainTask = task
	self:setCurMainTaskId(nil)
end

--ÒÆ³ýÖ÷ÏßÈÎÎñ
function RoleTaskInfo:romoveMainTask(nextTaskId)
	release(self.mainTask)
	self.mainTask = nil
	self:setCurMainTaskId(nextTaskId)
	self:cast2db()
end

---»ñÈ¡Ö÷ÏßÈÎÎñÈÎÎñ
function RoleTaskInfo:getMainTask()
	return self.mainTask
end

function RoleTaskInfo:getMainTaskID()
	local mainTask = self:getMainTask()
	if mainTask then
		return mainTask:getID()
	end
end

--ÉèÖÃÈÕ³£ÈÎÎñ
function RoleTaskInfo:setDailyTask(task)
	self.dailyTask = task
end

--ÒÆ³ýÈÕ³£ÈÎÎñ
function RoleTaskInfo:romoveDailyTask()
	release(self.dailyTask)
	self.lastTaskInfo[TaskType.Daily] = {id=self.dailyTask:getID(), rId=self.dailyTask:getRewardID()}
	self.dailyTask = nil
	self:cast2db()
end

---»ñÈ¡ÈÕ³£ÈÎÎñÈÎÎñ
function RoleTaskInfo:getDailyTask()
	return self.dailyTask
end

---»ñÈ¡ÈÕ³£ÈÎÎñ»·Êý
function RoleTaskInfo:getDailyTaskLoop()
	if self.dailyTask then
		return self.dailyTask:getCurrentLoop()
	end
	return 1
end

--Ôö¼ÓÖ§ÏßÈÎÎñ
function RoleTaskInfo:addBranchTask(task)
	local hasTask = false
	for _, bTask in pairs(self.branchTask or {}) do
		if bTask:getID() == task:getID() then
			hasTask = true
		end
	end
	
	if not hasTask then
		table.insert(self.branchTask, task)
	end
end

--»ñÈ¡Ö§ÏßÈÎÎñÊýÁ¿
function RoleTaskInfo:getBranchTaskNum()
	return table.size(self.branchTask)
end

--ÒÆ³ýÖ§ÏßÈÎÎñ
function RoleTaskInfo:romoveBranchTask(taskID)
	for i=#self.branchTask, 1, -1 do 
		local task = self.branchTask[i]
		if task:getID() == taskID then 
			table.remove(self.branchTask,i) 
			release(task)
		end 
	end  

	self:cast2db()
end

---»ñÈ¡Ö§ÏßÈÎÎñ
function RoleTaskInfo:getBranchTask(id)
	for _,task in pairs(self.branchTask) do
		if task:getID() == id then
			return task
		end
	end
end

---»ñÈ¡È«²¿Ö§ÏßÈÎÎñ
function RoleTaskInfo:getAllBranchTask()
	return self.branchTask
end

--有没有开启过某个密令
function RoleTaskInfo:hasOpenKeytask(itemID)
	for _,task in pairs(self.branchTask) do
		local taskP = g_LuaTaskDAO:getBranchTaskByID(task:getID())
		if taskP and taskP.q_item == itemID then
			return true
		end
	end

	for _, taskID in pairs(self.hasFinishBrachIDs) do
		local taskP = g_LuaTaskDAO:getBranchTaskByID(taskID)
		if taskP and taskP.q_item == itemID then
			return true
		end
	end
	
	return false
end

function RoleTaskInfo:getLastTaskInfo(taskType)
	return self.lastTaskInfo[taskType]
end


function RoleTaskInfo:talkWithNPC(npcId, option)
	if not TASK_OPEN_FALG then
		return
	end
	--Ã»ÓÐÑ¡Ïî±íÊ¾µÚÒ»´Îµã»÷NPC£¬²éÑ¯ËùÓÐÈÎÎñ
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	local optionRet = {}
	if not option then
		self:checkMainTask(npcId, optionRet, TaskStatus.Done)
		--Èç¹ûÓÐ¿ÉÍê³ÉÖ÷ÏßÓÅÏÈ´¦Àí
		if table.size(optionRet) > 0 then
			return "", 0 , optionRet
		else
			--Ã»ÓÐÖ÷Ïß¾Í¼ÌÐø¼ì²éÆäËûÈÎÎñ
			self:checkBranchTask(npcId, optionRet, TaskStatus.Done)

			if table.size(optionRet) > 0 then
				return "", 0 , optionRet
			else
				--Ã»ÓÐ¿ÉÍê³ÉµÄ¾ÍÕÒ¿É½ÓµÄÈÎÎñ£¬»¹ÊÇÓÅÏÈÖ÷Ïß
				self:checkMainTask(npcId, optionRet, TaskStatus.Accept)

				if table.size(optionRet) > 0 then
					return "", 0 , optionRet
				else
					--Ã»ÓÐÖ÷Ïß¾Í¼ÌÐø¼ì²éÆäËûÈÎÎñ
					--self:checkBranchTask(npcId, optionRet, TaskStatus.Accept)

					if table.size(optionRet) > 0 then
						return "", 0 , optionRet
					else
						--Ã»ÓÐ¿ÉÍê³ÉÒ²Ã»ÓÐ¿É½Ó¾ÍÏÔÊ¾ÄÇÐ©Ã»Íê³ÉµÄÈÎÎñ£¬Ã»ÓÐÓÅÏÈ¼¶£¬È«²¿ÏÔÊ¾
						self:checkMainTask(npcId, optionRet, TaskStatus.Active)
						self:checkBranchTask(npcId, optionRet, TaskStatus.Active)
					end
				end
			end
		end
		return "", 0 , optionRet
	else
		local taskId = option.value
		local taskOp = option.param
		local txt = ""
		local txtId = 0

		if taskOp == TaskOp.op1 then
			local curMainId = self:getCurMainTaskId()
			if curMainId and curMainId > 0 then
				local taskP = g_LuaTaskDAO:getPrototype(curMainId)
				local param = TaskOp.op2
				
				if not g_taskServlet:canReceive(player, TaskType.Main, curMainId) then
					param = TaskOp.op11
				end
				local opInfo = self:createOpTb(TaskStateText.Accept, curMainId, param)
				table.insert(optionRet, opInfo)
				txt = tostring(TaskType.Main * 100 + tonumber(taskP.q_chapter))
				txtId = curMainId * 10 + TaskStatus.Accept
			else
				local taskID = self.mainTask:getID()
				local taskP = g_LuaTaskDAO:getPrototype(taskID)
				if self.mainTask:getStatus() == TaskStatus.Done then
					local param = TaskOp.op3
					local opInfo = self:createOpTb(TaskStateText.Finish, self.mainTask:getID(), param)
					table.insert(optionRet, opInfo)
					txt = tostring(TaskType.Main * 100 + tonumber(taskP.q_chapter))
					txtId = self.mainTask:getID() * 10 + TaskStatus.Done
				elseif self.mainTask:getStatus() == TaskStatus.Active then
					local opInfo = self:createOpTb2(TaskStateText.Active)
					table.insert(optionRet, opInfo)
					txt = tostring(TaskType.Main * 100 + tonumber(taskP.q_chapter))
					txtId = self.mainTask:getID() * 10 + TaskStatus.Active
				end
			end
		elseif taskOp == TaskOp.op2 then
			local curMainId = self:getCurMainTaskId()
			if curMainId and curMainId > 0 then
				local task = g_taskServlet:receiveTask(player, TaskType.Main, curMainId)
			end
		elseif taskOp == TaskOp.op3 then
			if self.mainTask and self.mainTask:getStatus() == TaskStatus.Done then
				g_taskServlet:finishTask(self:getRoleID(), self.mainTask)
			end
		elseif taskOp == TaskOp.op6 then
			local taskP = g_LuaTaskDAO:getBranchTaskByID(taskId)
			local param = TaskOp.op9
			local opInfo = self:createOpTb(TaskStateText.Accept, taskId, param)
			table.insert(optionRet, opInfo)
			txt = tostring(TaskType.Branch * 100)
			txtId = taskId * 10 + TaskStatus.Accept
		elseif taskOp == TaskOp.op7 then
			local task = self:getBranchTask(taskId)
			if task then
				local param = TaskOp.op10
				local opInfo = self:createOpTb(TaskStateText.Finish, task:getID(), param)
				table.insert(optionRet, opInfo)
				txt = tostring(TaskType.Branch * 100)
				txtId = task:getID() * 10 + TaskStatus.Done
			end
		elseif taskOp == TaskOp.op8 then
			local task = self:getBranchTask(taskId)
			if task then
				local opInfo = self:createOpTb2(TaskStateText.Active)
				table.insert(optionRet, opInfo)
				txt = tostring(TaskType.Branch * 100)
				txtId = task:getID() * 10 + TaskStatus.Active
			end
		elseif taskOp == TaskOp.op9 then
			local task = g_taskServlet:receiveTask(player, TaskType.Branch, taskId)
		elseif taskOp == TaskOp.op10 then
			local task = self:getBranchTask(taskId)
			if task and task:getStatus() == TaskStatus.Done then
				g_taskServlet:finishTask(self:getRoleID(), task)
			end
		end
		--print("NPC¶Ô»°¿ò²ÎÊý", txt, txtId , toString(optionRet))
		return txt, txtId , optionRet
	end
end

function RoleTaskInfo:checkMainTask(npcId, optionRet, taskState)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())

	if taskState == TaskStatus.Accept then
		local curMainId = self:getCurMainTaskId()
		if curMainId and curMainId > 0 then
			local taskP = g_LuaTaskDAO:getPrototype(curMainId)
			if taskP then
				if tonumber(taskP.q_startnpc) == npcId then
					local param = TaskOp.op1
					local opInfo = self:createOpTb(taskP.q_name, curMainId, param)
					table.insert(optionRet, opInfo)
				end
			end
		end
	elseif taskState == TaskStatus.Done then
		if self.mainTask then
			local taskID = self.mainTask:getID()
			local taskP = g_LuaTaskDAO:getPrototype(taskID)
			if tonumber(taskP.q_endnpc) == npcId and self.mainTask:getStatus() == TaskStatus.Done then
				local param = TaskOp.op1
				local opInfo = self:createOpTb(taskP.q_name, self.mainTask:getID(), param)
				table.insert(optionRet, opInfo)
			end
		end
	elseif taskState == TaskStatus.Active then
		if self.mainTask then
			local taskID = self.mainTask:getID()
			local taskP = g_LuaTaskDAO:getPrototype(taskID)
			if tonumber(taskP.q_endnpc) == npcId and self.mainTask:getStatus() == TaskStatus.Active then
				local param = TaskOp.op1
				local opInfo = self:createOpTb(taskP.q_name, self.mainTask:getID(), param)
				table.insert(optionRet, opInfo)
			end
		end
	end
end


function RoleTaskInfo:checkBranchTask(npcId, optionRet, taskState)
	local branchTask = self:getAllBranchTask()
	
	--ÏÈ¸üÐÂ×îÐÂ×´Ì¬
	for _,task in pairs(branchTask) do
		task:validate()
	end

	if taskState == TaskStatus.Accept then
		local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
		local allTaskP = g_LuaTaskDAO:getAllBranchTask()
		for id,taskP in pairs(allTaskP) do
			--¹ýÂËµôÕýÔÚ½øÐÐºÍÒÑ¾­Íê³É¹ýµÄÖ§ÏßÈÎÎñ
			if not self:getBranchTask(id) and not self:isFinishBrachID(id) then
				if tonumber(taskP.q_startnpc) == npcId and g_taskServlet:canReceive(player, TaskType.Branch, id) then
					local param = TaskOp.op6
					local opInfo = self:createOpTb(taskP.q_name, id, param)
					table.insert(optionRet, opInfo)
				end
			end
		end
	elseif taskState == TaskStatus.Done then
		for _,task in pairs(branchTask) do
			local taskP = g_LuaTaskDAO:getBranchTaskByID(task:getID())
			if taskP then
				if tonumber(taskP.q_endnpc) == npcId and task:getStatus() == TaskStatus.Done then
					local param = TaskOp.op7
					local opInfo = self:createOpTb(taskP.q_name, task:getID(), param)
					table.insert(optionRet, opInfo)
				end
			end
		end
	elseif taskState == TaskStatus.Active then
		for _,task in pairs(branchTask) do
			local taskP = g_LuaTaskDAO:getBranchTaskByID(task:getID())
			if taskP then
				if tonumber(taskP.q_endnpc) == npcId and task:getStatus() == TaskStatus.Active then
					local param = TaskOp.op8
					local opInfo = self:createOpTb(taskP.q_name, task:getID(), param)
					table.insert(optionRet, opInfo)
				end
			end
		end
	end
end

function RoleTaskInfo:createOpTb(text, value, param)
	local optionInfo = {}
	optionInfo.text = text
	optionInfo.type = DialogActionType.Runtime_Task
	optionInfo.value = value
	optionInfo.icon = 0
	optionInfo.param = param
	return optionInfo
end

function RoleTaskInfo:createOpTb2(text)
	local optionInfo = {}
	optionInfo.text = text
	optionInfo.type = DialogActionType.Close
	optionInfo.value = 0
	optionInfo.icon = 0
	optionInfo.param = 0
	return optionInfo
end

function RoleTaskInfo:getFinishBranch()
	local ret = {}
	ret.taskID = self.hasFinishBrachIDs
	fireProtoMessage(self:getRoleID(), TASK_SC_GET_FINISH_BRANCH_RET, 'GetFinishBranchRetProtocol', ret)
end

function RoleTaskInfo:setTaskBuf2(luaBuf)
	local allFinishTask = self:getAllFinishBrachID()
	local num = table.size(allFinishTask)
	luaBuf:pushInt(num)
	for _, taskId in pairs(allFinishTask) do
		luaBuf:pushInt(taskId)
	end
end

--±£´æµ½Êý¾Ý¿â
function RoleTaskInfo:cast2db()
	local cache_buff = self:writeObject()
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_TASK, cache_buff, #cache_buff)
end

--±£´æµ½Êý¾Ý¿â
function RoleTaskInfo:cast2db2()
	local cache_buff2 = self:writeObject2()
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_TASK2, cache_buff2, #cache_buff2)
end

--±£´æµ½Êý¾Ý¿â
function RoleTaskInfo:writeObject()
	local task_datas = {}
	--Ö÷ÏßÈÎÎñ
	local mainTask = self.mainTask
	
	if mainTask then
		task_datas.mainTaskId = self.mainTask:getID()
		task_datas.maintaskState = self.mainTask:getStatus()
		task_datas.mainTaskTargetState = serialize(self.mainTask:getTargetStates())
	else
		task_datas.mainTaskId = self:getCurMainTaskId()
		task_datas.maintaskState = 0
		task_datas.mainTaskTargetState = "null"
	end

	--ÈÕ³£ÈÎÎñ
	task_datas.dailyTaskStamp = self:getDailyTaskStamp()
	if not self.dailyTask then 
		task_datas.dailyTaskId = 0
		task_datas.dailyCurLoop = 0
		task_datas.dailyRewardId = 0
		task_datas.dailyTaskTargetState = "null"
	else
		task_datas.dailyTaskId = self.dailyTask:getID()
		task_datas.dailyCurLoop = self.dailyTask:getCurrentLoop()
		task_datas.dailyRewardId = self.dailyTask:getRewardID()
		task_datas.dailyTaskTargetState = serialize(self.dailyTask:getTargetStates())
	end

	task_datas.finishByIngot = self:getFinishByIngot()
	task_datas.lastTaskInfo = serialize(self.lastTaskInfo)
-- ÐüÉÍÈÎÎñ20160106
	task_datas.annRewardTaskNum = self:getAnnRewardTaskNum()
	task_datas.accBlueRewardTaskNum = self:getAccBlueRewardTaskNum()
	task_datas.accPurpleRewardTaskNum = self:getAccPurpleRewardTaskNum()
	task_datas.rewardTaskStamp = self:getRewardTaskStamp()
	task_datas.rewardTaskGUID = self:getRewardTaskGUID()
	task_datas.rewardTaskGuardTime = self:getRewardTaskGuardTime()
	task_datas.annSuperRewardTaskNum = self:getAnnSuperRewardTaskNum()
	task_datas.accSuperRewardTaskNum = self:getAccSuperRewardTaskNum()

	if not self.rewardTask then
		task_datas.rewardTaskId = 0
		task_datas.rewardTaskTargetState = "null"
	else
		task_datas.rewardTaskId = self.rewardTask:getID()
		task_datas.rewardTaskTargetState = serialize(self.rewardTask:getTargetStates())
	end

	--Ö§ÏßÈÎÎñ
	task_datas.branchs = {}
	local allBranch = self:getAllBranchTask()
	for _,branch in ipairs(allBranch) do
		local branchTB = {}
		branchTB.branchID = branch:getID()
		branchTB.state = branch:getStatus()
		branchTB.taskTargetState = serialize(branch:getTargetStates())
		table.insert(task_datas.branchs, branchTB)
	end
	if self:IsTaskOwner() then 
		task_datas.sharedTaskOwner = 1
	else
		task_datas.sharedTaskOwner = 0
	end
	task_datas.sharedPrizeStamp = self:getSharedTaskStamp()
	task_datas.sharedPrizeNum = self:getSharedTaskPrizeNum()
	if not self.sharedTask then
		task_datas.sharedTaskId = 0
		task_datas.sharedTaskTargetState = "null"
	else
		task_datas.sharedTaskId = self.sharedTask:getID()
		task_datas.sharedTaskTargetState = serialize(self.sharedTask:getTargetStates())
	end
	task_datas.sharedTaskTargetPos = serialize(self:getSharedTaskTargetPos())

	return protobuf.encode("TaskProtocol", task_datas)
end

function RoleTaskInfo:writeObject2()
	local task_datas = {}
	task_datas.branchDones = self.hasFinishBrachIDs
	return protobuf.encode("TaskProtocol2", task_datas)
end

function RoleTaskInfo:switchWorld(peer, dbid, mapID)
	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_TASK_SETS)
	--¾ßÌåÊý¾Ý¸úÔÚºóÃæ
	local buff = self:writeObject()
	luaBuf:pushLString(buff, #buff)
	local buff2 = self:writeObject2()
	luaBuf:pushLString(buff2, #buff2)
	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
end

--¼ÓÔØÊý¾Ý¿âµÄÊý¾Ý
function RoleTaskInfo:loadTaskData(cache_buf)
	if #cache_buf > 0 then
		local datas,err = protobuf.decode("TaskProtocol", cache_buf)
		if datas == false then
			print("ÈÎÎñÊý¾Ý¿â¼ÓÔØ´íÎó", err)
			return
		end
		--Ö÷ÏßÈÎÎñ
		local mainTaskId = datas.mainTaskId
		local maintaskState = datas.maintaskState
		local mainTaskTargetState = datas.mainTaskTargetState
		self:loadMainTask(mainTaskId,maintaskState,mainTaskTargetState)

		--ÈÕ³£ÈÎÎñ
		local dailyTaskStamp = datas.dailyTaskStamp
		self:setDailyTaskStamp(dailyTaskStamp)
		local dailyTaskId = datas.dailyTaskId
		if not (dailyTaskId == 0) then
			curLoop = datas.dailyCurLoop
			rewardId = datas.dailyRewardId
			taskTargetState = datas.dailyTaskTargetState
			self:loadDailyTask(dailyTaskId, curLoop, rewardId, taskTargetState)
		end

		--¼ì²éÈÕ³£ÈÎÎñÊÇ·ñÐèÒªË¢ÐÂ
		self:setFinishByIngot(datas.finishByIngot)
		self.lastTaskInfo = unserialize(datas.lastTaskInfo)
		self:freshDailyTask()

		-- ÐüÉÍÈÎÎñ20160106
		self:setAnnRewardTaskNum(datas.annRewardTaskNum)
		self:setAccBlueRewardTaskNum(datas.accBlueRewardTaskNum)
		self:setAccPurpleRewardTaskNum(datas.accPurpleRewardTaskNum)
		self:setRewardTaskStamp(datas.rewardTaskStamp)
		self:setRewardTaskGUID(datas.rewardTaskGUID)
		self:setRewardTaskGuardTime(datas.rewardTaskGuardTime)
		self:setAnnSuperRewardTaskNum(datas.annSuperRewardTaskNum)
		self:setAccSuperRewardTaskNum(datas.accSuperRewardTaskNum)

		local rewardTaskId = datas.rewardTaskId
		if not (rewardTaskId == 0) then
			local taskTargetState
			taskTargetState = datas.rewardTaskTargetState
			self:loadRewardTask(rewardTaskId, self:getRewardTaskGUID(), taskTargetState)
		end

		for i, branch in pairs(datas.branchs) do
			local branchID = branch.branchID
			local state = branch.state
			local taskTargetState = branch.taskTargetState
			self:loadBranchTask(branchID, state, taskTargetState)
		end

		self:setSharedTaskStamp(datas.sharedPrizeStamp)
		self:setSharedTaskPrizeNum(datas.sharedPrizeNum)
		self:setSharedTaskTargetPos(unserialize(datas.sharedTaskTargetPos))
		local sharedTaskId = datas.sharedTaskId
		if not(sharedTaskId == 0) then
			local taskTargetState = datas.sharedTaskTargetState
			self:loadSharedTask(sharedTaskId,taskTargetState)
			if datas.sharedTaskOwner then
				self:setTaskOwner()
				local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
				local taskP = g_LuaTaskDAO:getSharedTask(sharedTaskId)
				if taskP then
					g_sharedTaskMgr:AddTaskToList(player,taskP.q_rank,taskTargetState)
				end
			end
		end
	end
end

--¼ÓÔØÊý¾Ý¿âµÄÊý¾Ý
function RoleTaskInfo:loadTaskData2(cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("TaskProtocol2", cache_buf)
		self.hasFinishBrachIDs = datas.branchDones
	end
end

--´¦ÀíÈÕ³£ÈÎÎñË¢ÐÂ
function RoleTaskInfo:freshDailyTask()
	print("RoleTaskInfo:freshDailyTask>>>>>>>>>>",self:getRoleSID())
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	local dailyTaskStamp = self:getDailyTaskStamp()
	local timeStamp = time.toedition("day")
	if tonumber(timeStamp) >= tonumber(dailyTaskStamp) then 
		--Èç¹ûµ½´ïµÈ¼¶£¬È´ÓÐÃ»ÓÐÈÎÎñ£¬Ìí¼ÓÐÂÒ»»·µÄÈÎÎñ
		if player:getLevel() >= TASK_DAILY_ACTIVE_LEVEL then
			self:freshDailyStamp()
			local dailyTaskId = g_LuaTaskDAO:getDailyTaskByLevel(player:getLevel())
			g_taskServlet:receiveTask(player, TaskType.Daily, dailyTaskId, 1)
		end
	end
end

--¼ÓÔØÈÕ³£ÈÎÎñ
function RoleTaskInfo:loadDailyTask(taskId, curLoop, rewardId, taskTargetState)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	local task = g_LuaTaskDAO:loadTask(player, taskId, TaskType.Daily)
	self:setDailyTask(task)
	
	--Ôö¼ÓÈÕ³£ÈÎÎñÈÎÎñ£¬Í¨Öª¿Í»§¶Ë
	--task:setStatus(TaskStatus.Active)
	task:setCurrentLoop(curLoop)
	task:setRewardID(rewardId)
	task:setStatesInDB(taskTargetState)
	task:initTargets()
end

--¼ÓÔØÖ§ÏßÈÎÎñ
function RoleTaskInfo:loadBranchTask(branchID, state, taskTargetState)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	local task = g_LuaTaskDAO:loadTask(player, branchID, TaskType.Branch)
	
	--task:setStatus(state)
	task:setStatesInDB(taskTargetState)
	task:initTargets()
	self:addBranchTask(task)
end

--¼ÓÔØÖ÷ÏßÈÎÎñ
function RoleTaskInfo:loadMainTask(taskId,taskState,taskTargetState)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return
	end

	if taskId == 10041 and taskState ~= TaskStatus.Done then
		taskState = 0
	end

	--Ô¼¶¨taskStateÎª0ÊÇÎÞÖ÷ÏßÈÎÎñ£¬»ñÈ¡ÏÂÒ»¸öÈÎÎñµÄID
	if taskState == 0 then
		local nextTaskId = taskId
		local chapter = 1
		if not (nextTaskId == 0) then
			local nextTaskP = g_LuaTaskDAO:getPrototype(nextTaskId)
			if nextTaskP then
				chapter = nextTaskP.q_chapter
			end
		end

		local ret = {}
		ret.taskID = nextTaskId
		ret.chapter = chapter
		fireProtoMessage(player:getID(), TASK_SC_CUR_MAIN_TASK, 'CurMainTaskProtocol', ret)
		print("++++++++++++++++++++++++++++++++++++++++++", nextTaskId)
		--¼ÇÂ¼½Ó²»µ½µÄÈÎÎñID
		self:setCurMainTaskId(nextTaskId)
		return
	end

	local task = g_LuaTaskDAO:loadTask(player, taskId, TaskType.Main)
	if not task then
		return
	end

	--task:setStatus(taskState)

	self:setMainTask(task)
	
	local taskP = g_LuaTaskDAO:getPrototype(taskId)
	local chapter = taskP.q_chapter
	task:setStatesInDB(taskTargetState)
	task:initTargets(true)
end

-- ÐüÉÍÈÎÎñ20160106
--Ë¢ÐÂÐüÉÍÈÎÎñÊ±¼ä´Á
function RoleTaskInfo:freshRewardTaskStamp()
	local stamp = tonumber(time.toedition("day") + 1)
	self:setRewardTaskStamp(stamp)
	self:setAnnRewardTaskNum(0)
	self:setAccBlueRewardTaskNum(0)
	self:setAccPurpleRewardTaskNum(0)
	self:setAnnSuperRewardTaskNum(0)
	self:setAccSuperRewardTaskNum(0)
	self:cast2db()
end

--»ñÈ¡ÒÑÍê³ÉÐüÉÍÈÎÎñµÄ´ÎÊý
function RoleTaskInfo:getRemainAccBlueRewardTaskNum()
	local timeStamp = time.toedition("day")
	if tonumber(timeStamp) < self:getRewardTaskStamp() then
		return self:getAccBlueRewardTaskNum()
	else
		--¹ýÆÚµÄÊ±¼ä´ÁÒªË¢ÐÂ
		self:freshRewardTaskStamp()
		return 0
	end
end

function RoleTaskInfo:getRemainAccPurpleRewardTaskNum()
	local timeStamp = time.toedition("day")
	if tonumber(timeStamp) < self:getRewardTaskStamp() then
		return self:getAccPurpleRewardTaskNum()
	else
		--¹ýÆÚµÄÊ±¼ä´ÁÒªË¢ÐÂ
		self:freshRewardTaskStamp()
		return 0
	end
end

function RoleTaskInfo:getRemainAccSuperRewardTaskNum()
	local timeStamp = time.toedition("day")
	if tonumber(timeStamp) < self:getRewardTaskStamp() then
		return self:getAccSuperRewardTaskNum()
	else
		--¹ýÆÚµÄÊ±¼ä´ÁÒªË¢ÐÂ
		self:freshRewardTaskStamp()
		return 0
	end
end

--»ñÈ¡ÐüÉÍÈÎÎñ
function RoleTaskInfo:getRewardTask()
	return self.rewardTask
end

--ÉèÖÃÐüÉÍÈÎÎñ
function RoleTaskInfo:setRewardTask(task)
	self.rewardTask = task
end

--ÒÆ³ýÐüÉÍÈÎÎñ
function RoleTaskInfo:romoveRewardTask()
	release(self.rewardTask)
	self.rewardTask = nil
end

--»ñÈ¡ÒÑ·¢²¼ÐüÉÍÈÎÎñµÄ´ÎÊý
function RoleTaskInfo:getRemainAnnRewardTaskNum()
	local timeStamp = time.toedition("day")
	if tonumber(timeStamp) < self:getRewardTaskStamp() then
		return self:getAnnRewardTaskNum()
	else
		--¹ýÆÚµÄÊ±¼ä´ÁÒªË¢ÐÂ
		self:freshRewardTaskStamp()
		return 0
	end
end

function RoleTaskInfo:getRemainAnnSuperRewardTaskNum()
	local timeStamp = time.toedition("day")
	if tonumber(timeStamp) < self:getRewardTaskStamp() then
		return self:getAnnSuperRewardTaskNum()
	else
		self:freshRewardTaskStamp()
		return 0
	end
end

--¼ÓÔØÐüÉÍÈÎÎñ
function RoleTaskInfo:loadRewardTask(taskId, taskGUID, taskTargetState)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	local task = g_LuaTaskDAO:loadTask(player, taskId, TaskType.Reward)
	self:setRewardTask(task)
	
	--Ôö¼ÓÐüÉÍÈÎÎñÈÎÎñ£¬Í¨Öª¿Í»§¶Ë
	task:setStatus(TaskStatus.Active)
	task:setStatesInDB(taskTargetState)
	task:initTargets()
end


function RoleTaskInfo:getSharedTask()
	return self.sharedTask
end

function RoleTaskInfo:setSharedTask(task)
	self.sharedTask = task
end

--ÒÆ³ýÐüÉÍÈÎÎñ
function RoleTaskInfo:removeSharedTask()
	release(self.sharedTask)
	self.sharedTask = nil
	self.sharedTaskOwner = 0
	self:cast2db()
end

function RoleTaskInfo:IsTaskOwner()
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if self.sharedTaskOwner == 0 then
		return false
	else
		return true
	end
end

function RoleTaskInfo:setTaskOwner()
	self.sharedTaskOwner = 1
end

function RoleTaskInfo:clearTaskOwner()
	self.sharedTaskOwner = 0
end

--¼ÓÔØ¹²ÏíÈÎÎñ
function RoleTaskInfo:loadSharedTask(taskId, taskTargetState)
	print("RoleTaskInfo:loadSharedTask",taskId)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	local task = g_LuaTaskDAO:loadTask(player, taskId, TaskType.Shared)
	self:setSharedTask(task)
	local taskP = g_LuaTaskDAO:getSharedTask(taskId)
	
	
	--Ôö¼Ó¹²ÏíÈÎÎñ£¬Í¨Öª¿Í»§¶Ë
	--task:setStatus(TaskStatus.Active)
	task:setStatesInDB(taskTargetState)
	task:initTargets()
	self:cast2db()

end

function RoleTaskInfo:freshSharedTaskStamp()
	self.sharedTaskOwner = 0
	local stamp = tonumber(time.toedition("day"))
	self:setSharedTaskStamp(stamp)
	self:setSharedTaskPrizeNum(0)
	self:cast2db()
end

function  RoleTaskInfo:getRemainSharedTaskPrize()
	local timeStamp = time.toedition("day")
	if tonumber(timeStamp) == self:getSharedTaskStamp() then
		return self:getSharedTaskPrizeNum()
	else
		--¹ýÆÚµÄÊ±¼ä´ÁÒªË¢ÐÂ
		self:freshSharedTaskStamp()
		return 0
	end
end

function RoleTaskInfo:updateSharedTaskPrize(num)
	self:setSharedTaskPrizeNum(self:getSharedTaskPrizeNum()+num)
	self:cast2db()
end
