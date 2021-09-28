KFMiningSceneLogic = KFMiningSceneLogic or BaseClass(CrossServerSceneLogic)

function KFMiningSceneLogic:__init()

end

function KFMiningSceneLogic:__delete()

end

-- 进入场景
function KFMiningSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	if old_scene_type ~= new_scene_type then
		ViewManager.Instance:CloseAll()
		KuaFuMiningCtrl.Instance:OpenFubenView()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
		MainUICtrl.Instance:SetViewState(false)
		MainUICtrl.Instance.view:HideBianShen(false)
		--MainUICtrl.Instance.view:SetAllViewState(false)

		-- --隐藏player_info
		-- local mian_view = MainUICtrl.Instance:GetView()
		-- if mian_view.player_info and mian_view.player_info.canvas_group then
		-- 	mian_view.player_info.canvas_group.alpha = 0
		-- end
	end
end

-- 退出
function KFMiningSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	if old_scene_type ~= new_scene_type then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
		--ViewManager.Instance:CloseAll()
		KuaFuMiningCtrl.Instance:CloseFubenView()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
		MainUICtrl.Instance:SetViewState(true)
		MainUICtrl.Instance.view:HideBianShen(true)
		--MainUICtrl.Instance.view:SetAllViewState(true)

		-- --隐藏player_info
		-- local mian_view = MainUICtrl.Instance:GetView()
		-- if mian_view.player_info and mian_view.player_info.canvas_group then
		-- 	mian_view.player_info.canvas_group.alpha = 1
		-- end
	end
end

function KFMiningSceneLogic:GetIsShowSpecialImage(obj)
	local obj_type = obj:GetType()
	if obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole then
		if obj.vo.special_param == 1 then
			return true, "uis/images", "box_01"
		end
	end
	return false
end

function KFMiningSceneLogic:OnMainRoleRealive()
	-- GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

--闪烁称号
function KFMiningSceneLogic:ChangeTitle()
	local main_role = Scene.Instance:GetMainRole()
	local title_obj_list = main_role:GetFollowUi():GetTitleObj()
	for k, v in pairs(title_obj_list) do
		if v.gameObject.name == "Title_wudi_gather(Clone)" then
			local ani = v.animator
			ani:SetBool("twinkle", true)
			break
		end
	end
end