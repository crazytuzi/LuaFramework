DiMaiFbSceneLogic = DiMaiFbSceneLogic or BaseClass(BaseFbLogic)

function DiMaiFbSceneLogic:__init()
end

function DiMaiFbSceneLogic:__delete()
end

function DiMaiFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.DiMaiFbInfoView)
end

function DiMaiFbSceneLogic:Out()
	BaseFbLogic.Out(self)
	ViewManager.Instance:Close(ViewName.DiMaiFbInfoView)
end

function DiMaiFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end