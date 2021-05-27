
CommonSceneLogic = CommonSceneLogic or BaseClass(BaseSceneLogic)

function CommonSceneLogic:__init()
end

function CommonSceneLogic:__delete()
end

function CommonSceneLogic:Enter(old_scene_type, new_scene_type)	
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)
end

--退出
function CommonSceneLogic:Out()
	BaseSceneLogic.Out(self)
end
