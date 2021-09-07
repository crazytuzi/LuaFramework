CrossBossSceneLogic = CrossBossSceneLogic or BaseClass(CrossServerSceneLogic)

function CrossBossSceneLogic:__init()

end

function CrossBossSceneLogic:__delete()

end

function CrossBossSceneLogic:Enter(old_scene_type, new_scene_type)
	local main_role = Scene.Instance:GetMainRole()
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_GUILD then
		UnityEngine.PlayerPrefs.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	end
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.Activity)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
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

-- -- 是否可以拉取移动对象信息
-- function CrossBossSceneLogic:CanGetMoveObj()
-- 	return true
-- end