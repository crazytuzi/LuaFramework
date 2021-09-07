
--元素战场
ElementSceneLogic = ElementSceneLogic or BaseClass(CommonActivityLogic)

function ElementSceneLogic:__init()

end

function ElementSceneLogic:__delete()

end

function ElementSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.ElementBattleFightView)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_CAMP)
end

function ElementSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.ElementBattleFightView)
	MainUICtrl.Instance:SetViewState(true)
end

function ElementSceneLogic:CanGetMoveObj()
	return true
end

function ElementSceneLogic:GetMoveObjAllInfoFrequency()
	return 3
end

function ElementSceneLogic:GetRoleNameBoardText(role_vo)
	local role_kill = ElementBattleData.GetSpecialToKill(role_vo.special_param)
	local role_side = ElementBattleData.GetSpecialToSide(role_vo.special_param)
	local main_side = ElementBattleData.GetSpecialToSide(GameVoManager.Instance:GetMainRoleVo().special_param)

	local t = {}
	local index = 1

	local is_camp = (main_side == role_side)
	t[index] = {}
	t[index].color = is_camp and COLOR.WHITE or COLOR.RED
	t[index].text = role_vo.name

	if role_kill >= 5 then
		index = index + 1
		t[index] = {}
		t[index].color = COLOR.YELLOW
		t[index].text = string.format(Language.Dungeon.KillCount, role_kill)
	end
	return t
end

function ElementSceneLogic:IsRoleEnemy(target_obj, main_role)
	if ElementBattleData.GetSpecialToSide(main_role:GetVo().special_param) ==
	ElementBattleData.GetSpecialToSide(target_obj:GetVo().special_param) then			-- 同一边
		return false, Language.Fight.Side
	end
	return true
end

function ElementSceneLogic:IsMonsterEnemy(target_obj, main_role)
	return false
end

function ElementSceneLogic:GetIsShowSpecialImage(obj)
	local role_side = ElementBattleData.GetSpecialToSide(obj.vo.special_param)
	if role_side >= 0 and role_side <= 2 then
		return true, "uis/views/elementbattle/images_atlas", "camp_" .. role_side
	end
	return false
end

function ElementSceneLogic:OnMainRoleRealive()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function ElementSceneLogic:GetGuajiPos()
	return ElementBattleData.Instance:GetGuajiXY()
end
