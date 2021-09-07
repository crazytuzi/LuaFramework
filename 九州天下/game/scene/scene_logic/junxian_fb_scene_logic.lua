JunXianFbSceneLogic = JunXianFbSceneLogic or BaseClass(BaseFbLogic)

function JunXianFbSceneLogic:__init()
end

function JunXianFbSceneLogic:__delete()
end

function JunXianFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
end

function JunXianFbSceneLogic:Out()
	BaseFbLogic.Out(self)
end

function JunXianFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end