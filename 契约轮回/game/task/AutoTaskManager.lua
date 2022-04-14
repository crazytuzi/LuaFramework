-- 
-- @Author: LaoY
-- @Date:   2018-09-07 16:05:13
-- 

AutoTaskManager = AutoTaskManager or class("AutoTaskManager",BaseManager)
local AutoTaskManager = AutoTaskManager

function AutoTaskManager:ctor()
	AutoTaskManager.Instance = self
	self.model = TaskModel:GetInstance()
	UpdateBeat:Add(self.Update,self,4,10)
	self:Reset()
	self:AddEvent()
end

function AutoTaskManager:Reset()
	self.task_info = {}
	self.auto_state = false

	self.scene_object_flag = true

	self.LastOperateTime = Time.time

	self.last_operate_task_time = Time.time

	self.astar_info = {scene_id = -1,pos = pos(0,0)}
end

function AutoTaskManager.GetInstance()
	if AutoTaskManager.Instance == nil then
		AutoTaskManager()
	end
	return AutoTaskManager.Instance
end

function AutoTaskManager:AddEvent()
	local function call_back()
		self:SetLastOperateTaskTime()
	end
	GlobalEvent:AddListener(TaskEvent.GlobalUpdateTask, call_back)
	GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

-- task_type 是目标类型，不是任务类型
function AutoTaskManager:SetTaskInfo(task_id,prog,target_id,goal_type)
	self.last_task_id = task_id
	self.task_info.task_id 		= task_id
	self.task_info.prog 		= prog
	self.task_info.target_id 	= target_id
	self.task_info.goal_type 	= goal_type

	local data = TaskModel.GetInstance().task_list[task_id]
	if data then
		self.task_info.task_type 	= data.task_type
	else
		self.task_info.task_type = nil
	end

	if self.task_info.task_type ~= enum.TASK_TYPE.TASK_TYPE_MAIN then
		self.task_info.main_task_id = TaskModel:GetInstance():GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_MAIN)
		-- local task_id = TaskModel:GetInstance():
	else
		self.task_info.main_task_id = nil
	end
end

function AutoTaskManager:GetLastTaskID()
	return self.last_task_id
end

function AutoTaskManager:GetTaskInfo()
	return self.task_info
end

function AutoTaskManager:CleanTaskInfo()
	self.task_info = {}

	self.astar_info.scene_id = -1
	self.astar_info.pos.x = 0
	self.astar_info.pos.y = 0
end

function AutoTaskManager:SetAutoTaskState(flag)
	self.auto_state = flag
end

function AutoTaskManager:GetAutoTaskState()
	return self.auto_state
end

function AutoTaskManager:IsAutoFight()
	if not self.auto_state or table.isempty(self.task_info) then
		return false
	end
	return self.task_info.goal_type == enum.EVENT.EVENT_CREEP
end

function AutoTaskManager:GetTaskTargetID()
	if not self.auto_state or table.isempty(self.task_info) then
		return true
	end
	if not (self.task_info.goal_type == enum.EVENT.EVENT_CREEP) then
		return true
	end
	local client_lock_target_id = FightManager:GetInstance().client_lock_target_id
	if client_lock_target_id then
		local object_data = SceneManager:GetInstance():GetObjectInfo(client_lock_target_id)
		if object_data.id == self.task_info.target_id then
			return true,client_lock_target_id
		end
	end
	local target = SceneManager:GetInstance():GetCreepInScreen(self.task_info.target_id)
	if not target then
		local new_target = SceneManager:GetInstance():GetCreepByTypeId(self.task_info.target_id)
		if new_target then
			local target_pos = new_target:GetPosition()
			if new_target.fountain_action then
				target_pos = new_target.object_info:GetFissionPos()
			end
			OperationManager:GetInstance():TryMoveToPosition(nil,nil,target_pos,nil,SceneConstant.AttactDis + SceneConstant.RushDis)
		end
		return false
	end
	return true,target.object_id
end

function AutoTaskManager:DoCollect(task_id,target_id)
	if not FightManager:GetInstance():TryDoCollect(target_id) and task_id then
		self:SetAutoTaskState(false)
		self.model:DoTask(task_id)
	end
end

function AutoTaskManager:DoTalk(task_id,target_id)
	local object = SceneManager:GetInstance():GetObject(target_id)
	local main_role = SceneManager:GetInstance():GetMainRole()
	if object and Vector2.Distance(object:GetPosition(), main_role:GetPosition()) < SceneConstant.NPCRange then
		if AutoFightManager:GetInstance():GetAutoFightState() then
			GlobalEvent:Brocast(FightEvent.AutoFight)
		end
		self:SetAutoTaskState(false)
		object:OnClick()
		return true
	end
	self.model:DoTask(task_id)
end

function AutoTaskManager:SetLastOperateTime(time)
	self.LastOperateTime = time or Time.time
end

function AutoTaskManager:GetLastOperateTime()
	return self.LastOperateTime
end

function AutoTaskManager:SetAStarInfo(scene_id,pos)
	self.astar_info.scene_id = scene_id
	self.astar_info.pos.x = pos.x
	self.astar_info.pos.y = pos.y
end

function AutoTaskManager:IsTaskAStar()
	if self.astar_info.scene_id == -1 then
		return false
	end
	return OperationManager:GetInstance():IsAutoWay() and OperationManager:GetInstance():IsSameTargetPos(self.astar_info.pos,self.astar_info.scene_id)
end

function AutoTaskManager:SetLastOperateTaskTime(value)
	self.last_operate_task_time = value or Time.time
end

function AutoTaskManager:IsCanAutoGuide(deltaTime)
	return Time.time - self.last_operate_task_time >= deltaTime
end

function AutoTaskManager:UpdateTaskGuide()
	if self:IsCanAutoGuide(GuideItem4.AutoMaintaskTip) then
		TaskModel:GetInstance():Brocast(TaskEvent.UpdateGuild)
	end

	if self:IsCanAutoGuide(GuideItem4.AutoActiveTaskTip) then
		TaskModel:GetInstance():Brocast(TaskEvent.UpdateGuild)
	end
	
	if self:IsCanAutoGuide(GuideItem4.AutoDailyTaskTip) then
		TaskModel:GetInstance():Brocast(TaskEvent.UpdateGuild)
	end
end

function AutoTaskManager:SetSceneObjectLayer(flag)
	if self.scene_object_flag == flag then
		return
	end
	self.scene_object_flag = flag
	SceneManager:GetInstance():SetObjectsBitState(self.scene_object_flag,SceneManager.SceneObjectVisibleState.NoOperate)

	if flag then
		PlatformManager:GetInstance():SetBrightness(1)
	else
		PlatformManager:GetInstance():SetBrightness(-100)
	end
end

function AutoTaskManager:Update()
	if SceneManager:GetInstance():GetChangeSceneState() or not AppConfig.GameStart then
		return
	end

	if self.auto_state and not TaskModel:GetInstance().is_pause and self.task_info.task_type ~= enum.TASK_TYPE.TASK_TYPE_LOOP2 then
		self:SetLastOperateTime()
	end

	if OperationManager:GetInstance():IsOutScreenAutoWay() then
		self:SetLastOperateTime()
	end

	local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
	if AutoFightManager:GetInstance().is_city_or_feild and not TaskModel:GetInstance().isOpenNpcPanel then
		if lv then
			local offsetTime = lv <= 90 and 20 or 90
			if Time.time - self.LastOperateTime > offsetTime and lv <= 160 then
				TaskModel:GetInstance():DoNextTaskByType()
			end
		end
	else
		-- self:SetLastOperateTime()
	end

	self:SetSceneObjectLayer(Time.time - self.LastOperateTime > Constant.EnterLowPowerTime)

	self:UpdateTaskGuide()
end