XuKongShopFbLogic = XuKongShopFbLogic or BaseClass(FbSceneLogic)

function XuKongShopFbLogic:__init()
end

function XuKongShopFbLogic:__delete()
end

function XuKongShopFbLogic:Enter(old_scene_type, new_scene_type)
	FbSceneLogic.Enter(self, old_scene_type, new_scene_type)
	FubenCtrl.Instance:OpenXukongView()
end

function XuKongShopFbLogic:Out()
	FbSceneLogic.Out(self)
	FubenCtrl.Instance:CloseXukongView()
end
