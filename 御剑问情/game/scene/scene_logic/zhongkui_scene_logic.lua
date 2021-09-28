ZhongKuiSceneLogic = ZhongKuiSceneLogic or BaseClass(BaseFbLogic)

function ZhongKuiSceneLogic:__init()

end

function ZhongKuiSceneLogic:__delete()

end

function ZhongKuiSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)

	MainUICtrl.Instance:SetViewState(false)
		-- MainUICtrl.Instance.view.player_view:SwitchPeaceMode()
	ZhuaGuiCtrl.Instance:ShowZhuaGuiView()
end

-- 是否可以拉取移动对象信息
function ZhongKuiSceneLogic:CanGetMoveObj()
	return true
end

-- 拉取移动对象信息间隔
function ZhongKuiSceneLogic:GetMoveObjAllInfoFrequency()
	return 1
end

-- 角色是否敌人
function ZhongKuiSceneLogic:IsRoleEnemy(target_obj, main_role)
	return false
end

function ZhongKuiSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)

	ZhuaGuiCtrl.Instance:CloseZhuaGuiView()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function ZhongKuiSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end
