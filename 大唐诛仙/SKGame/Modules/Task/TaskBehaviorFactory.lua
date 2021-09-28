require "SKGame/Modules/Task/TaskBehaviorStrategy"

TaskBehaviorFactory =BaseClass()


function TaskBehaviorFactory:__init()

end

function TaskBehaviorFactory:Create(data)
	if data == nil or TableIsEmpty(data) then return nil end
	local mgr = TaskObjectMgr:GetInstance()
	local isHas, hasObj = mgr:IsContainTaskBhaviorObj(data:GetTaskId())
	if isHas == true and (not TableIsEmpty(hasObj)) then
		local data = hasObj.taskData
		local tState = data:GetTaskState()
		if not TableIsEmpty(data) then
			if data:GetTaskState() ~= tState then
				data:SetTaskState(tState)
			end
		end
		return hasObj
	else
		local taskTarget = data:GetTaskTarget()
		local taskBehaviorObj = TaskBehaviorFactory.CreateBehaviorTable[taskTarget.targetType](data)
		if taskBehaviorObj then
			mgr:AddTaskBehaviorObj(data:GetTaskId(), taskBehaviorObj)
			return taskBehaviorObj
		end
	end
	
end
local TTType = TaskConst.TaskTargetType
TaskBehaviorFactory.CreateBehaviorTable = {
	[TTType.NPCInteraction] = function (data)
		return TaskNPCDialog.New(data)
	end,
	[TTType.UpgradeLevel] = function (data)
		return TaskUpgradeLevel.New(data)
	end,
	[TTType.CopyPass] = function (data)
		return TaskCopy.New(data)
	end,
	[TTType.KillMonster] = function (data)
		return TaskKillMonster.New(data)
	end,
	[TTType.WearEquipment] = function (data)
		return TaskWearEquipment.New(data)
	end,
	[TTType.StrengthenEquipment] = function (data)
		return TaskStrengthenEquipment.New(data)
	end,
	[TTType.UseGodFightRune] = function (data)
		return TaskUseGodFightRune.New(data)
	end,
	-- [TTType.WashEquipment] = function (data)
	-- 	return TaskWashEquipment.New(data)
	-- end,
	-- [TTType.InlayEquipment] = function (data)
	-- 	return TaskInlayEquipment.New(data)
	-- end,
	[TTType.ActiveSkill] = function (data)
		return TaskActiveSkill.New(data)
	end,
	[TTType.UpgradeSkill] = function (data)
		return TaskUpgradeSkill.New(data)
	end,
	[TTType.CollectItem] = function (data)
		return TaskCollectItem.New(data)
	end,
	[TTType.SwitchModelGuide] = function (data)
		return TaskSwitchModelGuide.New(data)
	end,
	--获取物品的任务类型表现，对于客户端而言，表现和杀怪一样，只是杀怪后的掉落是随机的
	[TTType.GetItem] = function (data)
		return TaskKillMonster.New(data)
	end,
	[TTType.UseMedicine] = function (data)
		return TaskUseMedicine.New(data)
	end,
	[TTType.Decompose] = function (data)
		return TaskDecompose.New(data)
	end,
	[TTType.Compose] = function (data)
		return TaskCompose.New(data)
	end,
	[TTType.BuyItem] = function (data)
		return TaskBuyItem.New(data)
	end,
	[TTType.OperateTeam] = function (data)
		return TaskOperateTeam.New(data)
	end,
	[TTType.JoinFamily] = function (data)
		return TaskJoinFamily.New(data)
	end,
	[TTType.AddFriend] = function (data)
		return TaskAddFriend.New(data)
	end,
	[TTType.RankMatchCounter] = function (data)
		return TaskRankMatchCounter.New(data)
	end,
	[TTType.ChatGuide] = function (data)
		return TaskChatGuide.New(data)
	end,
	[TTType.ClimbTower] = function (data)
		return TaskClimbTower.New(data)
	end,
	[TTType.FriendGuide] = function (data)
		return TaskFriendGuide.New(data)
	end,
	[TTType.DailyTaskCounter] = function (data)
		return TaskDailyCounter.New(data)
	end,
	[TTType.CycleTaskCounter] = function (data)
		return TaskCycleCounter.New(data)
	end,
	[TTType.ClimbTowerCounter] = function (data)
		return TaskClimbTowerCounter.New(data)
	end,
	[TTType.HuntingMonsterCounter] = function (data)
		return TaskHuntingMonsterCounter.New(data)
	end,
	[TTType.ConsignForSale] = function (taskDataObj)
		return TaskConsignForSale.New(taskDataObj)
	end
}

function TaskBehaviorFactory:GetInstance()
	if TaskBehaviorFactory.inst == nil then
		TaskBehaviorFactory.inst = TaskBehaviorFactory.New()
	end
	return TaskBehaviorFactory.inst
end

function TaskBehaviorFactory:__delete()
	TaskBehaviorFactory.inst = nil
end

