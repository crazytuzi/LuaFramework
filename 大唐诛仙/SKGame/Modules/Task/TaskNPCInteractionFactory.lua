TaskNPCInteractionFactory =BaseClass()

function TaskNPCInteractionFactory:__init()

end

function TaskNPCInteractionFactory:__delete()
	TaskNPCInteractionFactory.inst = nil
end

function TaskNPCInteractionFactory:GetInstance()
	if TaskNPCInteractionFactory.inst == nil then
		TaskNPCInteractionFactory.inst = TaskNPCInteractionFactory.New()
	end

	return TaskNPCInteractionFactory.inst
end

function TaskNPCInteractionFactory:Create(data) -- taskDataObj
	if data == nil or TableIsEmpty(data) then return nil end
	local mgr = TaskObjectMgr:GetInstance()
	local taskId = data:GetTaskId()
	local isHas, hasObj = mgr:IsContainNPCInteractionObj(taskId)
	
	if isHas == true and (not TableIsEmpty(hasObj)) then
		local taskData = hasObj.taskData
		if not TableIsEmpty(taskData) then
			if taskData:GetTaskState() ~= data:GetTaskState() then
				taskData:SetTaskState(data:GetTaskState())
			end
		end
		return hasObj
	else
		local taskTarget = data:GetTaskTarget()
		local obj = TaskNPCInteractionFactory.CreateBehaviorTable[taskTarget.targetType](data)
		if obj then
			mgr:AddNPCInteractionObj(taskId, obj)
			return obj
		end
	end

end
local IType = TaskConst.NPCInteractionType
TaskNPCInteractionFactory.CreateBehaviorTable = {
	[IType.DialogTest] = function (data) 
		return NPCDialogTest.New(data)
	end,
	[IType.UpgradeLevel] = function (data)
		return NPCUpgradePlayerLevel.New(data)
	end,
	[IType.KillMonster] = function (data)
		return NPCKillMonster.New(data)
	end,
	[IType.UpgradeSkill] = function (data)
		return NPCUpgradeSkill.New(data)
	end,
	[IType.ActiveSkill] = function (data)
		return NPCActiveSkill.New(data)
	end,
	[IType.CollectItem] = function (data)
		return NPCCollectItem.New(data)
	end,
	[IType.CopyPass] = function (data)
		return NPCCopy.New(data)
	end,
	[IType.WearEquipment] = function (data)
		return NPCWearEquipment.New(data)
	end,
	[IType.StrengthenEquipment] = function (data)
		return NPCStrengthenEquipment.New(data)
	end,
	[IType.UseGodFightRune] = function (data)
		return NPCUseGodFightRune.New(data)
	end,
	[IType.SwitchModelGuide] = function (data)
		return NPCSwitchModelGuide.New(data)
	end,
	[IType.GetItem] = function (data)
		return NPCGetItem.New(data)
	end,
	[IType.UseMedicine] = function (data)
		return NPCUseMedicine.New(data)
	end,
	[IType.Decompose] = function (data)
		return NPCDecompose.New(data)
	end,
	[IType.Compose] = function (data)
		return NPCCompose.New(data)
	end,
	[IType.BuyItem] = function (data)
		return NPCBuyItem.New(data)
	end,
	[IType.OperateTeam] = function (data)
		return NPCOperateTeam.New(data)
	end,
	[IType.JoinFamily] = function (data)
		return NPCJoinFamily.New(data)
	end,
	[IType.AddFriend] = function (data)
		return NPCAddFriend.New(data)
	end,
	[IType.RankMatchCounter] = function (data)
		return NPCRankMatchCounter.New(data)
	end,
	[IType.ChatGuide] = function (data)
		return NPCChatGuide.New(data)
	end,
	[IType.ClimbTower] = function (data)
		return NPCClimbTower.New(data)
	end,
	[IType.FriendGuide] = function (data)
		return NPCFriendGuide.New(data)
	end,
	[IType.DailyTaskCounter] = function (data)
		return NPCDailyTaskCounter.New(data)
	end,
	[IType.CycleTaskCounter] = function (data)
		return NPCCycleTaskCounter.New(data)
	end,
	[IType.ClimbTowerCounter] = function (data)
		return NPCClimbTower.New(data)
	end,
	[IType.HuntingMonsterCounter] = function (data)
		return NPCHuntingMonsterCounter.New(data)
	end,
	[IType.ConsignForSale] = function (data)
		return NPCConsignForSale.New(data)
	end
}
