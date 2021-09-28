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
	MainUICtrl.Instance:GetView():Flush(MainUIViewChat.IconList.ChatButtons, {false})

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	main_role_vo.main_role_id_t[role_id] = true
end

function CrossServerSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:GetView():Flush(MainUIViewChat.IconList.ChatButtons, {true})
end