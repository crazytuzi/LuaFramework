CrossTianJiangBossLogic = CrossTianJiangBossLogic or BaseClass(CrossServerSceneLogic)

function CrossTianJiangBossLogic:__init()

end

function CrossTianJiangBossLogic:__delete()

end

function CrossTianJiangBossLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.Activity)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
	end
	ViewManager.Instance:Open(ViewName.KuaFuBossTjFightView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function CrossTianJiangBossLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.KuaFuBossTjFightView)
	MainUICtrl.Instance.view:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function CrossTianJiangBossLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE_IN_BOSS_SCENE
end