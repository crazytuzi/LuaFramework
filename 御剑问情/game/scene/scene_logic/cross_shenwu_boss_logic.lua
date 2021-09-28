CrossShenWuBossLogic = CrossShenWuBossLogic or BaseClass(CrossServerSceneLogic)

function CrossShenWuBossLogic:__init()

end

function CrossShenWuBossLogic:__delete()

end

function CrossShenWuBossLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.Activity)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
	end
	ViewManager.Instance:Open(ViewName.KuaFuBossSwFightView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function CrossShenWuBossLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.KuaFuBossSwFightView)
	MainUICtrl.Instance.view:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function CrossShenWuBossLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
end