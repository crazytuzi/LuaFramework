CrystalFbLogic = CrystalFbLogic or BaseClass(FbSceneLogic)

function CrystalFbLogic:__init()
end

function CrystalFbLogic:__delete()
end

function CrystalFbLogic:Enter(old_scene_type, new_scene_type)
	FbSceneLogic.Enter(self, old_scene_type, new_scene_type)
	FubenCtrl.Instance:OpenCrystalView()
end

function CrystalFbLogic:Out()
	FbSceneLogic.Out(self)
	FubenCtrl.Instance:CloseCrystalView()
end
