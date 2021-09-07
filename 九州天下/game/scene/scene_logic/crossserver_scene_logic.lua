CrossServerSceneLogic = CrossServerSceneLogic or BaseClass(CommonActivityLogic)

function CrossServerSceneLogic:__init()

end

function CrossServerSceneLogic:__delete()

end

function CrossServerSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	--if old_scene_type ~= new_scene_type then
		--BaseView.CloseAllView()
	--end
end

function CrossServerSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
end