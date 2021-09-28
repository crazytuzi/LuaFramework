TaskData =BaseClass()

function TaskData:__init(PlayerTaskMsg)
	self.taskData = GetCfgData("task"):Get(PlayerTaskMsg.taskId) or {}
	self.currentNum = PlayerTaskMsg.currentNum or 0
	self.taskState = PlayerTaskMsg.taskState or 0 --任务状态（0：未完成  1：完成）
end

function TaskData:GetTaskData()
	return self.taskData
end

function TaskData:GetTaskContent()
	local rtnContent = ""
	if not TableIsEmpty(self.taskData) and self.taskData.content then
		rtnContent = self.taskData.content
	end
	return rtnContent
end

--获取任务类型
function TaskData:GetTaskType()
	return self.taskData.type
end

--获取任务目标列表
function TaskData:GetTaskTarget()
	local data = {}
	data.targetType = self.taskData.conditionType
	data.targetParam = self.taskData.condition
	return data
end

--[[
	获取奖励物品列表
	任务奖励
	[类型，物品编号，数量，是否绑定]
]]
function TaskData:GetRewardList()
	local rewards = {}
	local show = self.taskData.showReward
	if show ~= nil then
		local TaskRewardField = TaskConst.TaskRewardField
		for idx = 1, #show do
			local vo = {}
			rewards[idx] = vo
			for key , value in pairs(show[idx]) do
				if key == TaskRewardField.ItemType then
					vo.itemType = value
				elseif key == TaskRewardField.ItemId then
					vo.itemId = value
				elseif key == TaskRewardField.ItemCnt then
					vo.itemCnt = value
				elseif key == TaskRewardField.IsBinding then
					vo.isBinding = value
				end
			end
		end
	end
	
	return rewards
end

--获取剧情对白
function TaskData:GetDramaDialog()
	local content = {}
	local DramaField = TaskConst.DramaField
	for k, _ in pairs(self.taskData.npcWord) do
		content[k] = {}
		for kk, v in pairs(self.taskData.npcWord[k]) do
			if kk == DramaField.NPCID then
				content[k].npcID = v
			elseif kk == DramaField.DialogContent then
				content[k].dramaContent = v
			end
		end
	end
	return content
end

--获取领取任务面板对白
function TaskData:GetSubmitTaskDialog()
	local content = {}
	local data = self.taskData
	if data ~=nil and not TableIsEmpty(data) and data.submitNpc and data.submitWord then
		table.insert(content,{submitNpcId = data.submitNpc, submitWord = data.submitWord})
	end
	return content
end

--获取领取任务剧情对白
function TaskData:GetSubmitTaskDramaDialog()
	local content = {}
	local data = self.taskData
	if not TableIsEmpty(data) and data.submitNpc and data.submitWord then
		table.insert(content, {submitNpc = data.submitNpc, submitWord = data.submitWord })
	end
	return content
end

function TaskData:GetTaskState()
	return self.taskState
end

function TaskData:SetTaskState(state)
	if state == TaskConst.TaskState.NotFinish then
		self.taskState = TaskConst.TaskState.NotFinish
	elseif state == TaskConst.TaskState.Finish then
		self.taskState = TaskConst.TaskState.Finish
	end
end

function TaskData:GetTaskProcess()
	return self.currentNum
end

function TaskData:GetSubmitNPCId()
	return self.taskData.submitNpc
end

function TaskData:GetSubmitNPCInfo()
	local submitNpcInfo = {}
	submitNpcInfo.npcPos = {}
	submitNpcInfo.sceneId = -1
	submitNpcInfo.npcId = -1

	local submitNpcId = self:GetSubmitNPCId()
	if submitNpcId then
		local npcInfo = GetCfgData("npc"):Get(submitNpcId) or nil
		if not TableIsEmpty(npcInfo) then
			submitNpcInfo.sceneId = npcInfo.inScene or -1
			submitNpcInfo.npcId = npcInfo.eid
			local curNPCInfo = {}
			local mapCfg = SceneModel:GetInstance():GetSceneCfg(submitNpcInfo.sceneId)
			if not TableIsEmpty(mapCfg) then
				for npcIdIndex, npcInfo in pairs(mapCfg.npcs) do
					if npcIdIndex == submitNpcInfo.npcId then
						curNPCInfo = npcInfo
						break
					end
				end
			end

			if not TableIsEmpty(curNPCInfo) then
				submitNpcInfo.npcPos = Vector3.New(curNPCInfo.location[1] or 0, curNPCInfo.location[2] or 0, curNPCInfo.location[3] or 0) 
			end
				
		end
	end

	return submitNpcInfo
end


function TaskData:SetTaskProcessState(curNum, state)
	if curNum then
		self.currentNum = curNum
	end
	if state then
		self.taskState = state
	end
end

function TaskData:GetTaskId()
	return self.taskData.id or -1
end

function TaskData:IsAutoSumbit()
	local rtnIsAuto = false
	if not TableIsEmpty(self.taskData) then
		if self.taskData.autoSubmit == TaskConst.AutoSubmit.IsAuto then
			rtnIsAuto = true
		end
	end
	return rtnIsAuto
end

--是否需要剧情对白
function TaskData:IsHasDramaDialog()
	return not TableIsEmpty(self.taskData) and not TableIsEmpty(self.taskData.npcWord)
end

--是否需要提交任务剧情对白
function TaskData:IsHasSubmitDramaDialog()
	return not TableIsEmpty(self.taskData) and self.taskData.submitWord ~= ""
end

--是否需要显示提交任务面板
function TaskData:IsNeedShowSubmitPanel()
	return not TableIsEmpty(self.taskData) and self.taskData.autoSubmit ~= 1

end

--[[
	自动完成任务（是否需要跑到npc旁）
	任务目标达成，任务就完成，不需要与npc交付
	0：不自动（需跑到npc处）
	1：自动（不需跑到npc处）
]]
function TaskData:IsNeedAutoComplete()
	return not TableIsEmpty(self.taskData) and self.taskData.autoComplete == 1
end

--是否自动执行任务
function TaskData:IsNeedAutoExec()
	return not TableIsEmpty(self.taskData) and self.taskData.automatic == 1
end

--执行任务寻路至任务目标点的寻路方式
function TaskData:GetExecTaskPathMethod()
	local PathMethod = TaskConst.PathMethod
	local result = PathMethod.None
	if self.taskData.executeTransfer == 0 then
		result = PathMethod.WorldPath
	elseif self.taskData.executeTransfer == 1 then
		result = PathMethod.LocalPath
	else
		result = PathMethod.None
	end
	return result
end

--提交任务寻路至任务目标点的寻路方式
function TaskData:GetSubmitTaskPathMethod()
	local PathMethod = TaskConst.PathMethod
	local result = PathMethod.None
	if self.taskData.compleTeransfer == 0 then
		result = PathMethod.WorldPath
	elseif self.taskData.compleTeransfer == 1 then
		result = PathMethod.LocalPath
	else
		result = PathMethod.None
	end
	return result
end

--获取任务的引导ID
function TaskData:GetGuideId()
	return self.taskData.guildId
end

--获取任务的引导配置信息
function TaskData:GetGuideInfo()
	local rtn = {}
	local id = self:GetGuideId()
	if id and id ~= 0 then
		local cfg =  GetCfgData("FunctionGuide"):Get(id)
		if not TableIsEmpty(cfg) then
			rtn = cfg
		end
	end
	return rtn
end

--是否是功能引导任务
function TaskData:IsGuideTask()
	local rtnIsGuideTask = false
	if self:GetTaskType() == TaskConst.TaskType.GuideTask and  self.taskData.guildId ~= 0 then
		rtnIsGuideTask = true
	end
	return rtnIsGuideTask
end

--获取引导任务的执行次数
function TaskData:GetGuideTaskExecCnt()
	local rtnCnt = -1
	if self:IsGuideTask() then
		local guideData =  NewbieGuideModel:GetInstance():GetGuideDataByGuideId(self.taskData.guildId)
		if not TableIsEmpty(guideData) then
			rtnCnt = guideData:GetExecCnt()
		end
	end
	
	return rtnCnt
end

--获取任务名称
function TaskData:GetTaskName()
	return self.taskData.taskName
end

--获取任务名称（带主线支线）
function TaskData:GetTaskNameWithType()
	local rtnName = ""
	local TaskType = TaskConst.TaskType
	local t = self:GetTaskType()
	if t == TaskType.MainLine then
		rtnName = StringFormat("{0}{1}", "[主]", self:GetTaskName())
	elseif t == TaskType.BranchLine then
		rtnName = StringFormat("{0}{1}", "[支]", self:GetTaskName())
	elseif t == TaskType.DailyTask then
		rtnName = StringFormat("{0}{1}", "[日常]", self:GetTaskName())
	elseif t == TaskType.CycleTask then
		rtnName = StringFormat("{0}{1}", "[环]", self:GetTaskName())
	elseif t == TaskType.HuntingMonster then
		rtnName = StringFormat("{0}{1}", "[猎妖]", self:GetTaskName())
	elseif t == TaskType.GuideTask then
		rtnName = StringFormat("{0}{1}", "[引导]", self:GetTaskName())
	end
	return rtnName
end

--[[
	该任务是否可放弃（除了主线和支线和引导任务之外的任务类型都可以放弃）
]]
function TaskData:IsCanAbandon()
	local rtnIsCan = true
	local curTaskType = self:GetTaskType()
	local TaskType = TaskConst.TaskType
	if curTaskType == TaskType.MainLine or curTaskType == TaskType.BranchLine or curTaskType == TaskType.GuideTask then
		rtnIsCan = false
	end
	return rtnIsCan
end

function TaskData:IsCycleTask()
	return self:GetTaskType() == TaskConst.TaskType.CycleTask
end

function TaskData:IsDailyTask()
	return self:GetTaskType() == TaskConst.TaskType.DailyTask
end

function TaskData:GetFinishAudio()
	local rtnAudioId = 0
	if not TableIsEmpty(self.taskData) then
		rtnAudioId = self.taskData.audio or 0
	end
	return rtnAudioId
end

--获取任务的逻辑阶段（完全属于策划思维中的逻辑阶段）
--各个阶段分别为：任务接取   任务进行中  任务提交
function TaskData:GetTaskLogicalStage()
	local LogicalStage = TaskConst.LogicalStage
	local rtnStage = LogicalStage.None
	local stage = self.taskData.stage
	if not TableIsEmpty(self.taskData) then
		if stage == LogicalStage.Accept then
			rtnStage = LogicalStage.Accept
		elseif stage == LogicalStage.Execute then
			rtnStage = LogicalStage.Execute
		elseif stage == LogicalStage.Submit then
			rtnStage = LogicalStage.Submit
		end
	end
	return rtnStage
end

function TaskData:__delete()
	self.taskData = {}
end

