local CTask = class("CTask")

function CTask.ctor(self, taskData)
	self.m_SData = self:CreateDefalutData(taskData)
	self.m_CData = DataTools.GetTaskData(taskData.taskid)
	self.m_TaskType = DataTools.GetTaskType(self:GetValue("type"))

	self.m_Finish = false
	self.m_ProgresID = nil
	self.m_EndTime = nil
end

function CTask.CreateDefalutData( self, dTask )
	local d = {
	taskid = 0,                                 
    tasktype = 0,                                 
    name = "",                                 
    targetdesc = "",                              
    detaildesc = "",                        
   	target = 0,                               
    needitem = nil,                             
    needsum = nil,                              
    clientnpc = nil;                             
    isdone = 0,                              
    time = 0,                               
    rewardinfo = 0,                             
    taskitem = nil,                               
    placeinfo = nil,                          
    achieveinfo = nil,       
    shapeinfo = nil,
    traceinfo = nil,
    pickiteminfo = nil,
    acceptgrade = 0,
    accepttime = nil,
    lilianinfo = nil,
    teachinfo = nil,
    playid = 0,
    submitRewardStr = nil,
    autotype = 1,
    partnertaskinfo = nil,
    patrolinfo = nil,
    shimeninfo = nil,
    findPathCb = nil,
    taskWalkingTips = nil,
	}
	return table.update(d, dTask)
end

--创建一个特殊任务，
function CTask.NewByData(d)
	d.taskid = d.taskid or CTaskCtrl.LocalTaskID
	d.statusinfo = d.statusinfo or {}
	d.statusinfo.status = d.statusinfo.status or define.Task.TaskStatus.Accept
	d.detaildesc = d.detaildesc or ""
	d.targetdesc = d.targetdesc or ""
	d.name = d.name or ""
	d.type = d.type or 0
	d.submitRewardStr = d.submitRewardStr or {}
	d.autotype = d.autotype or 1
	return CTask.New(d)
end

function CTask.GetValue(self, k, arg)
	if k == "traceinfo" then
		return self:GetTraceInfo()
	end
	local v = self.m_SData[k]	
	if v == nil then
		v = self.m_CData[k]
	end
	if v == nil then
		if k == "status" then
			v = self:GetStatus(arg)
		elseif k == "traceNpcType" then
			v = self:GetTraceNpcType()
		end
	end
	return v
end

function CTask.RefreshTask(self, dict)
	local t = {}
	for k , v in pairs(dict) do
		if self[k] ~= v then
			self[k] = v
			t[k] = v
		end
	end
	return t
end

-- 是否可放弃
function CTask.IsAbandon(self)
	return self.m_TaskType.dropable > 0
end

-- 是否指定任务行为种类
function CTask.IsTaskSpecityAction(self, actionType)
	if not actionType then
		printerror("无效的任务行为类型")
		return
	end
	local taskAction = self:GetValue("tasktype")
	return taskAction == actionType
end

-- 是否指定任务类别(主线、支线、师门、捉鬼等)
function CTask.IsTaskSpecityCategory(self, categoryType)
	if not categoryType then
		printerror("无效的任务类别类型")
		return
	end
	local taskCategory = self:GetValue("type")
	return taskCategory == categoryType.ID
end

function CTask.AssociatedNpc(self, npcId)
	if not self.m_SData or not npcId or npcId < 0 then
		return
	end
	local npc = g_MapCtrl:GetNpc(npcId)
	if not npc then
		npc = g_MapCtrl:GetDynamicNpc(npcId)
	end
	if not npc then
		return
	end
	if npc.classname == "CNpc" then
		local npcType = npc.m_NpcAoi.npctype
		if npcType == self:GetValue("target") then
			return true
		elseif npcType == self:GetValue("submitNpcId") and self:GetValue("status") ~= define.Task.TaskStatus.Accept then			
			return true
		elseif npcType == self:GetValue("acceptnpc") and self:GetValue("status") == define.Task.TaskStatus.Accept then
			return true
		end
	elseif npc.classname == "CDynamicNpc" then
		local clientnpc = self:GetValue("clientnpc")		
		if clientnpc and #clientnpc > 0 then
			for _,v in ipairs(clientnpc) do
				if v.npcid == npcId then					
					local npcType = g_MapCtrl:GetNpcTypeByNpcId(npcId)
					if npcType == self:GetValue("submitNpcId") and self:GetValue("status") ~= define.Task.TaskStatus.Accept then
						return true
					elseif npcType == self:GetValue("acceptnpc") and self:GetValue("status") == define.Task.TaskStatus.Accept then
						return true
					elseif self:GetValue("tasktype") == define.Task.TaskType.TASK_PICK then
						return true
					end							
				end
			end
		end
	end
end

function CTask.AssociatedSubmit(self, npcid)
	if not self.m_SData or not npcid or npcid < 0 then
		return
	end
	local npc = g_MapCtrl:GetNpc(npcid)
	if not npc then
		return
	end
	-- 师门需要判断是否school
	if npc.classname == "CNpc" then
		local npctype = npc.m_NpcAoi.npctype
		if self:GetValue("submitNpcId") == npctype then
			return true
		else
			if self:IsTaskSpecityCategory(define.Task.TaskCategory.SHIMEN) then
				local extStrDic = self:GetTaskClientExtStrDic()
				if extStrDic and extStrDic.submitnpc and extStrDic.submitnpc == "School" then
					local schoolNpcID = CTaskHelp.GetSchoolNpcID()
					if npctype == schoolNpcID then
						return true
					end
				end
			end
		end
	end
end

function CTask.AssociatedPick(self, pickid)
	if not self.m_SData or not pickid or pickid < 0 then
		return
	end
	if not self:IsTaskSpecityAction(define.Task.TaskType.TASK_PICK) then
		return
	end
	local pickItem = g_MapCtrl:GetTaskPickItem(pickid)
	if not pickItem then
		return
	end

	if pickItem.classname == "CTaskPickItem" then
		local pickThing = self:GetProgressThing()
		if pickThing and pickThing.pickid == pickid then
			return true
		end
	end
end

-- 获取任务扩展字段
function CTask.GetTaskClientExtStrDic(self)
	local extStrDic = {}
	local extStr = self:GetValue("clientExtStr")
	if not extStr or string.len(extStr) <= 0 then
		return
	end
	local extStrList = string.split(extStr, ",")
	for _,v in ipairs(extStrList) do
		local termList = string.split(v, ":")
		if #termList == 2 and not extStrDic[termList[1]] then
			extStrDic[termList[1]] = termList[2]
		else
			printerror("错误：任务扩展字段配置错误，没有匹配的Key，任务ID：", self:GetValue("taskid"))
		end
	end
	return extStrDic
end

function CTask.GetProgressThing(self)
	if self:GetValue("status") == define.Task.TaskStatus.Done or self:GetValue("status") == define.Task.TaskStatus.Accept  then
		return
	else
		local thingList = {}
		if self:IsTaskSpecityAction(define.Task.TaskType.TASK_PICK) then
			local pickiteminfo = self:GetValue("pickiteminfo")
			table.insert(thingList, pickiteminfo )

		elseif self:IsTaskSpecityAction(define.Task.TaskType.TASK_USE_ITEM) then
			thingList = self:GetValue("taskitem")			
		end

		if thingList and #thingList > 0 then
			self.m_ProgresID = self.m_ProgresID or 1
			return thingList[self.m_ProgresID]
		else
			self:SetStatus(define.Task.TaskStatus.Done)
			return
		end
	end
end

function CTask.RaiseProgressIdx(self, idx)
	if idx and idx > 0 then
		self.m_ProgresID = idx
	else
		self.m_ProgresID = (self.m_ProgresID or 0) + 1
	end
end

--若npcId不为空时，根据当前的npc是否是提交任务的NPC和当前任务状态来返回真实的状态
--若为空，则返回服务器下放的任务状态
function CTask.GetStatus(self, npcType)
	local status = self.m_SData.statusinfo.status
	if self:GetValue("type") == define.Task.TaskCategory.ACHIEVE.ID then
		local degree = self:GetValue("degree")
		local target = self:GetValue("target")
		if degree >= target then
			status = define.Task.TaskStatus.Done
		else
			status = define.Task.TaskStatus.Doing
		end
	else
		if npcType ~= nil then
			local taskType = self:GetValue("tasktype")
			local submitNpc = self:GetValue("submitnpc")
			if taskType == define.Task.TaskType.TASK_FIND_NPC then			
				--if submitNpc == npcType and status == define.Task.TaskStatus.Doing then
				if status == define.Task.TaskStatus.Doing then
					status = define.Task.TaskStatus.Done
				end
				
			elseif taskType == define.Task.TaskType.TASK_TRACE then
				if submitNpc == npcType and status == define.Task.TaskStatus.Doing then
					status = define.Task.TaskStatus.Done
				end

			-- elseif taskType == define.Task.TaskType.TASK_ESCORT then
			-- 	if submitNpc == npcType and status == define.Task.TaskStatus.Doing  then
			-- 		status = define.Task.TaskStatus.Done
			-- 	end

			end
		end
	end
	return status
end

--是否生成护送类的动态NPC
function CTask.IsAddEscortDynamicNpc(self, npcType)
	local b = false
	if self:GetValue("tasktype") == define.Task.TaskType.TASK_ESCORT then
		if npcType == self:GetValue("acceptnpc") and self:GetValue("status") == define.Task.TaskStatus.Accept then
			b = true
		end
	end
	return b 
end

--设置任务的状态
function CTask.SetStatus(self, status)
	if status then
		self.m_SData.statusinfo.status = status
	end
end

--重置任务结束时间
function CTask.ResetEndTime(self)
	local time = self:GetValue("time")
	local status = self:GetValue("status")
	if time and time > 0 and (status == define.Task.TaskStatus.Doing or status == define.Task.TaskStatus.Done) then
		local now = g_TimeCtrl:GetTimeS()
		local to = now + time
		self.m_EndTime = to
	else
		self.m_EndTime = nil
	end
end

--获取任务剩余时间（单位：秒）
function CTask.GetRemainTime(self)
	local time = 0
	local status = self:GetValue("status")
	if (status == define.Task.TaskStatus.Doing or status == define.Task.TaskStatus.Done) then
		if self.m_EndTime then
			local now = g_TimeCtrl:GetTimeS()
			if now >= self.m_EndTime then
				time = 0 
			else
				time = self.m_EndTime - now
			end
		end
	end
	return time
end

--是否是小萌请求任务
function CTask.IsMissMengTask(self)
	local b = false
	local taskId = self:GetValue("taskid")
	if taskId >= 2000 and taskId <= 2999 then
		b = true
	end
	return b
end

function CTask.GetTraceNpcType(self)
	local npcType = 0
	local traceinfo = self:GetValue("traceinfo")
	if traceinfo then
		npcType = traceinfo.npctype
	end
	return npcType
end

function CTask.GetTaskTypeSpriteteName(self)
	local sprName = "tujian"
	local d = data.taskdata.TASKTYPE[self:GetValue("type")]
	if d and d.icon and d.icon ~= "" then
		sprName = d.icon
	end
	return sprName
end

function CTask.GetChaptetFubenData(self)
	local t = nil
	if not self.m_ChapterFb then
		self.m_ChapterFb = g_TaskCtrl:GetValueByTaskIdAndKey(self:GetValue("taskid"), "ChapterFb")	
	end
	if self.m_ChapterFb and self.m_ChapterFb ~= "" then
		local list = string.split(self.m_ChapterFb, ",")
		if #list >= 2 then
			t = {}
			t[1] = tonumber(list[1])
			t[2] = tonumber(list[2])
		end
	end
	return t
end

function CTask.IsPassChaterFuben(self)
	local b = true
	local chapterData = self:GetChaptetFubenData()
	if chapterData then
		if not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, chapterData[1], chapterData[2]) then
			b = false
		end
	end
	return b
end

function CTask.GetTraceInfo(self)
	if not self.m_TraceInfo then
		local t = table.copy(self.m_SData.traceinfo) 
		self.m_TraceInfo = t
	end
	return self.m_TraceInfo
end

return CTask