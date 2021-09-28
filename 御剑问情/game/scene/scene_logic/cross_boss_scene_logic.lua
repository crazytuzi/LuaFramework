CrossBossSceneLogic = CrossBossSceneLogic or BaseClass(CrossServerSceneLogic)

function CrossBossSceneLogic:__init()

end

function CrossBossSceneLogic:__delete()

end

function CrossBossSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.Activity)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
	end
	BossCtrl.Instance:ShowKfBossInfoView()
end

function CrossBossSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance.view:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	BossCtrl.Instance:CloseKfBossInfoView()
end

function CrossBossSceneLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
end