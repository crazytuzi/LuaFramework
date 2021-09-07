KFXiuLuoTowerSceneLogic = KFXiuLuoTowerSceneLogic or BaseClass(CrossServerSceneLogic)

function KFXiuLuoTowerSceneLogic:__init()

end

function KFXiuLuoTowerSceneLogic:__delete()

end

-- 进入场景
function KFXiuLuoTowerSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	if old_scene_type ~= new_scene_type then
		KuaFuXiuLuoTowerCtrl.Instance:OpenFubenView()
		--MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALL)
		MainUICtrl.Instance:SetViewState(false)
	end
end

-- 退出
function KFXiuLuoTowerSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	if old_scene_type ~= new_scene_type then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
		ViewManager.Instance:CloseAll()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		KuaFuXiuLuoTowerCtrl.Instance:CloseFubenView()
	end
end

function KFXiuLuoTowerSceneLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function KFXiuLuoTowerSceneLogic:GetIsShowSpecialImage(obj)
	local obj_type = obj:GetType()
	if obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole then
		if obj.vo.special_param == 1 then
			return true, "uis/images", "box_01"
		end
	end
	return false
end

function KFXiuLuoTowerSceneLogic:OnMainRoleRealive()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function KFXiuLuoTowerSceneLogic:GetGuajiPos()
	return KuaFuXiuLuoTowerData.Instance:GetGuajiXY()
end