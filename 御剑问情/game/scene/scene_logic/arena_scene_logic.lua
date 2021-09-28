ArenaSceneLogic = ArenaSceneLogic or BaseClass(CommonActivityLogic)

function ArenaSceneLogic:__init()

end

function ArenaSceneLogic:__delete()

end

-- 进入场景
function ArenaSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
	MainUICtrl.Instance:ChangeFightStateEnable(false)
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	
	ViewManager.Instance:CloseAll()
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetPlayerInfoState(false)
		MainUICtrl.Instance.view:HideMap(true)
		MainUICtrl.Instance.view:HideBianShen(false)
	end
	GlobalTimerQuest:AddDelayTimer(function()
		MainUICtrl.Instance:SetViewState(false)
		GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		MainUICtrl.Instance:ChangeFightStateEnable(false)
		end, 0.1)
	ArenaCtrl.Instance:CloseFightView()
	ArenaCtrl.Instance:InitFight()
end

function ArenaSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	MainUICtrl.Instance:ChangeFightStateEnable(true)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:HideBianShen(true)
	end
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)

	ArenaCtrl.Instance:CloseFightView()
	ViewManager.Instance:Open(ViewName.ArenaActivityView, TabIndex.arena_view)
	ArenaData.Instance:ClearCapabilityList()
end

function ArenaSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetAllViewState(true)
		MainUICtrl.Instance.view:SetPlayerInfoState(true)
		MainUICtrl.Instance.view:HideMap(false)
	end
end

-- 是否可以移动
function ArenaSceneLogic:CanMove()
	return ArenaCtrl.Instance:GetCanMove()
end

-- 目标是否是敌人
function ArenaSceneLogic:IsEnemy()
	return true
end

function ArenaSceneLogic:CanUseGoddessSkill()
	return false
end