MiningSceneLogic = MiningSceneLogic or BaseClass(BaseFbLogic)

function MiningSceneLogic:__init()
	self.has_reset_rotate = false --初始化方向
end

function MiningSceneLogic:__delete()

end

local next_time = 0
function MiningSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
	if next_time > now_time then
		return
	end
	next_time = now_time + 0.5
	if not self.has_reset_rotate then
		local role_list = Scene.Instance:GetRoleList()
		local role1 = Scene.Instance:GetMainRole()
		local role2 = nil
		for k,v in pairs(role_list) do
			role2 = v
			break
		end
		if role1 and role2 and role1:GetRoot() and role2:GetRoot() then
			local obj1 = role1:GetRoot()
			local obj2 = role2:GetRoot()
			local towards = u3d.vec3(obj2.transform.position.x, obj1.transform.position.y, obj2.transform.position.z)
			obj1.transform:DOLookAt(towards, 0)
			towards = u3d.vec3(obj1.transform.position.x, obj2.transform.position.y, obj1.transform.position.z)
			obj2.transform:DOLookAt(towards, 0)
			self.has_reset_rotate = true
		end
	end
end

-- 进入场景
function MiningSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	self.has_reset_pos = false
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetPlayerInfoState(false)
		MainUICtrl.Instance.view:HideMap(true)
	end
	GlobalTimerQuest:AddDelayTimer(function()
		MainUICtrl.Instance:SetViewState(false)
		GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
		MainUICtrl.Instance:ChangeFightStateEnable(false)

		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)
	ViewManager.Instance:CloseAll()
	MiningController.Instance:InitFight()
end

function MiningSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:ChangeFightStateEnable(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	local info_data = MiningData.Instance:GetFightingResultNotify()

	-- 挑衅战斗来结果要弹出界面
	if info_data.fighting_type == MiningChallengeType.CHALLENGE_TYPE_FIGHTING then
		ViewManager.Instance:Open(ViewName.MiningView, TabIndex.mining_challenge)
	-- 炼丹炉战斗结束要弹出该界面
	elseif info_data.fighting_type == MiningChallengeType.CHALLENGE_TYPE_SAILING_ROB then
		ViewManager.Instance:Open(ViewName.MiningView, TabIndex.mining_sea)

	elseif info_data.fighting_type == MiningChallengeType.CHALLENGE_TYPE_SAILING_ROB_ROBOT then
		ViewManager.Instance:Open(ViewName.MiningView, TabIndex.mining_sea)

	elseif info_data.fighting_type == MiningChallengeType.CHALLENGE_TYPE_SAILING_REVENGE then
		ViewManager.Instance:Open(ViewName.MiningView, TabIndex.mining_sea)
	-- 拓印战斗结束要弹出该界面
	elseif info_data.fighting_type == MiningChallengeType.CHALLENGE_TYPE_MINING_ROB then
		ViewManager.Instance:Open(ViewName.MiningView, TabIndex.mining_mining)

	elseif info_data.fighting_type == MiningChallengeType.CHALLENGE_TYPE_MINING_ROB_ROBOT then
		ViewManager.Instance:Open(ViewName.MiningView, TabIndex.mining_mining)

	elseif info_data.fighting_type == MiningChallengeType.CHALLENGE_TYPE_MINING_REVENGE then
		ViewManager.Instance:Open(ViewName.MiningView, TabIndex.mining_mining)

	end

	MiningData.Instance:SetFightingResultNotifyNo()
	MiningController.Instance:CloseFightView()
	MiningData.Instance:ClearCapabilityList()
end

function MiningSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetAllViewState(true)
		MainUICtrl.Instance.view:SetPlayerInfoState(true)
		MainUICtrl.Instance.view:HideMap(false)
	end
end

-- 是否可以移动
function MiningSceneLogic:CanMove()
	return MiningController.Instance:GetCanMove()
end

-- 角色是否是敌人
function MiningSceneLogic:IsRoleEnemy(target_obj, main_role)
	return true
end