CrossCrystalSceneLogic = CrossCrystalSceneLogic or BaseClass(CommonActivityLogic)

function CrossCrystalSceneLogic:__init()
end

function CrossCrystalSceneLogic:__delete()

end

function CrossCrystalSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.CrossCrystalInfoView)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_CAMP)
end

function CrossCrystalSceneLogic:Out(old_scene_type, new_scene_type)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CrossCrystalInfoView)
end