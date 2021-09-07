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

		local mian_view = MainUICtrl.Instance:GetView()
		if mian_view.hide_show_view and mian_view.hide_show_view.HideShowMining then
			mian_view.hide_show_view:HideShowMining(true)
		end
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

		local mian_view = MainUICtrl.Instance:GetView()
		if mian_view.hide_show_view and mian_view.hide_show_view.HideShowMining then
			mian_view.hide_show_view:HideShowMining(false)
		end
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