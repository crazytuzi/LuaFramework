DafuhaoSceneLogic = DafuhaoSceneLogic or BaseClass(BaseFbLogic)

function DafuhaoSceneLogic:__init()

end

function DafuhaoSceneLogic:__delete()

end

function DafuhaoSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.DaFuHao)
	ViewManager.Instance:Open(ViewName.FbIconView)
end

function DafuhaoSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.DaFuHao)
	ViewManager.Instance:Close(ViewName.FbIconView)
end

function DafuhaoSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end