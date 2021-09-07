CrossServerSupremacySceneLogic = CrossServerSupremacySceneLogic or BaseClass(BaseFbLogic)
function CrossServerSupremacySceneLogic:__init()
	
end

function CrossServerSupremacySceneLogic:__delete()
	
end

function CrossServerSupremacySceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.SupremacyView)
	ViewManager.Instance:CloseAll()
	-- MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
end

function CrossServerSupremacySceneLogic:Out()
	BaseFbLogic.Out(self)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Close(ViewName.SupremacyView)
end

function CrossServerSupremacySceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end