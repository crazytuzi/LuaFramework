KfOneVOneSceneLogic = KfOneVOneSceneLogic or BaseClass(CrossServerSceneLogic)

function KfOneVOneSceneLogic:__init()

end

function KfOneVOneSceneLogic:__delete()

end

-- 进入场景
function KfOneVOneSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)

	MainUICtrl.Instance:SetViewState(false)
	GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
	--MainUICtrl.Instance:ChangeFightStateEnable(false)

	if MainUICtrl.Instance.view then

		MainUICtrl.Instance.view:SetPlayerInfoState(false)
		MainUICtrl.Instance.view:HideMap(true)
	end
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)
	ViewManager.Instance:CloseAll()
	KuaFu1v1Ctrl.Instance:InitFight()


	local x, y = KuaFu1v1Data.Instance:GetGuajiXY()
	if nil ~= x and nil ~= y then
		local pos_x, pos_z = GameMapHelper.LogicToWorld(x, y)
		local mainrole = Scene.Instance:GetMainRole()
		local mainrole_root = mainrole:GetRoot()
		if nil == mainrole_root then
			return
		end

		towards = u3d.vec3(pos_x, mainrole_root.transform.position.y, pos_z)
		mainrole_root.transform:DOLookAt(towards, 0)
	end
end

function KfOneVOneSceneLogic:Out(old_scene_type, new_scene_type)
	MainUICtrl.Instance:ChangeFightStateEnable(true)
	GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetAllViewState(true)
		MainUICtrl.Instance.view:SetPlayerInfoState(true)
		MainUICtrl.Instance.view:HideMap(false)
	end
	KuaFu1v1Ctrl.Instance:CloseFightView()
	KuaFu1v1Data.Instance:ClearMatchResult()
	--GlobalTimerQuest:AddDelayTimer(function()
 	--local state = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_ONEVONE)
	--if state then
	KuaFu1v1Data.Instance:SetIsOutFrom1v1Scene(true)
		--ViewManager.Instance:Open(ViewName.KuaFu1v1)
	--else
		--TipsCtrl.Instance:ShowReminding(Language.Kuafu1V1.MatchFailTxt2)
	--end
	--end, 2)
end

-- 目标是否是敌人
function KfOneVOneSceneLogic:IsEnemy(target_obj, main_role, ignore_table)
	if target_obj and target_obj:IsMainRole() then
		return false
	end
	return true
end

function KfOneVOneSceneLogic:GetGuajiPos()
	return KuaFu1v1Data.Instance:GetGuajiXY()
end