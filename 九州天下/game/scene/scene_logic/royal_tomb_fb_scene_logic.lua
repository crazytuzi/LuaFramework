RoyalTombFbSceneLogic = RoyalTombFbSceneLogic or BaseClass(BaseFbLogic)

function RoyalTombFbSceneLogic:__init()
end

function RoyalTombFbSceneLogic:__delete()
end

function RoyalTombFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Open(ViewName.RoyalTombFbView)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_CAMP)
end

function RoyalTombFbSceneLogic:Out()
	BaseFbLogic.Out(self)
	ViewManager.Instance:Close(ViewName.RoyalTombFbView)
end

function RoyalTombFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end