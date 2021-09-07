CityCombatFBLogic = CityCombatFBLogic or BaseClass(CommonActivityLogic)

function CityCombatFBLogic:__init()
	self.block_grids = {
		{x = 275, y = 125},
		{x = 275, y = 126},
		{x = 275, y = 127},
		{x = 275, y = 128},
		{x = 275, y = 129},
		{x = 275, y = 130},
		{x = 275, y = 131},
		{x = 275, y = 132},
		{x = 275, y = 133},
		{x = 275, y = 134},
		{x = 275, y = 135},
		{x = 275, y = 136},
		{x = 275, y = 137},
		{x = 275, y = 138},
		{x = 275, y = 139},
		{x = 275, y = 140},
		{x = 275, y = 141},
		{x = 275, y = 142},
		{x = 275, y = 143},
		{x = 275, y = 144},
		{x = 275, y = 145},
		{x = 275, y = 146},
		{x = 275, y = 147},
		{x = 298, y = 125},
		{x = 298, y = 126},
		{x = 298, y = 127},
		{x = 298, y = 128},
		{x = 298, y = 129},
		{x = 298, y = 130},
		{x = 298, y = 131},
		{x = 298, y = 132},
		{x = 298, y = 133},
		{x = 298, y = 134},
		{x = 298, y = 135},
		{x = 298, y = 136},
		{x = 298, y = 137},
		{x = 298, y = 138},
		{x = 298, y = 139},
		{x = 298, y = 140},
		{x = 298, y = 141},
		{x = 298, y = 142},
		{x = 298, y = 143},
		{x = 298, y = 144},
		{x = 298, y = 145},
		{x = 298, y = 146},
		{x = 298, y = 147},
	}

	self.barrier = nil
	self.barrier_state = false
end

function CityCombatFBLogic:__delete()
end

function CityCombatFBLogic:OnSceneDetailLoadComplete()
	self.barrier = GameObject.Find("Detail/Effects/barrier")
	self:UpdateBarrierState()
end

function CityCombatFBLogic:Enter(old_scene_type, new_scene_type)
	-- 唐圣说删掉
	-- MainUICtrl.Instance:SetShowShield(false)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CityCombatView)
	ViewManager.Instance:Open(ViewName.CityCombatFBView)
	MainUICtrl.Instance.view:SetViewState(false)
	MainUICtrl.Instance:GetCityCombatButtons():SetActive(true)

	self.cg_layer = GameObject.Find("GameRoot").transform
end

function CityCombatFBLogic:Out(old_scene_type, new_scene_type)
	-- MainUICtrl.Instance:SetShowShield(true)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CityCombatFBView)
	MainUICtrl.Instance.view:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MainUICtrl.Instance:GetCityCombatButtons():SetActive(false)
	self:SetBlock(false)
end

function CityCombatFBLogic:Update(now_time, elapse_time)
	CommonActivityLogic.Update(self, now_time, elapse_time)

end

function CityCombatFBLogic:IsRoleEnemy(scene_obj, main_role)
	local is_poqiang = CityCombatData.Instance:GetIsPoQiang()
	local def_camp_type = CityCombatData.Instance:GetDefenceCampType()
	local is_pochen = CityCombatData.Instance:GetIsPoChen()
	if def_camp_type == 0 and is_poqiang == 0 then
		return false
	end

	if def_camp_type ~= 0 and is_pochen == 0 then
		local main_side = CityCombatData.Instance:GetMainSide()
		if main_side == scene_obj.vo.special_param then
			return false
		else
			return true
		end
	end
	return not self:IsSameCamp(scene_obj, main_role)
end

-- 设置角色头上名字的颜色
function CityCombatFBLogic:GetColorName(scene_obj)
	local name = ToColorStr(Language.RankTogle.StrCamp[scene_obj.vo.camp], CAMP_COLOR[scene_obj.vo.camp]) .. ToColorStr(scene_obj.vo.name, TEXT_COLOR.GREEN)
	local enemy_name = ToColorStr(Language.RankTogle.StrCamp[scene_obj.vo.camp], CAMP_COLOR[scene_obj.vo.camp])  .. ToColorStr(scene_obj.vo.name, TEXT_COLOR.RED)
	local self_camp_role_name = ToColorStr(Language.RankTogle.StrCamp[scene_obj.vo.camp], CAMP_COLOR[scene_obj.vo.camp])  .. ToColorStr(scene_obj.vo.name, TEXT_COLOR.YELLOW)

	local main_role = Scene.Instance:GetMainRole()
	if main_role == nil or scene_obj.vo.role_id == main_role.vo.role_id then
		return name
	end

	if not (scene_obj:GetType() == SceneObjType.Role) then
		return name
	end

	return self:IsRoleEnemy(scene_obj, main_role) and enemy_name or self_camp_role_name
end

function CityCombatFBLogic:IsSameCamp(target_obj, main_role)
	local camp_info = target_obj:GetVo().camp
	if main_role:GetVo().camp == target_obj:GetVo().camp then			-- 同一边
		return true
	else
		return false
	end
end

function CityCombatFBLogic:IsEnemy(target_obj, main_role, ignore_table)
	if target_obj:IsDead() then
		return false
	end
	if target_obj:GetType() == SceneObjType.Monster then
		local id = target_obj:GetMonsterId()
		if not CityCombatData.Instance:GetIsAtkSide() then
			local flag_info = CityCombatData.Instance:GetFlagInfo()
			local wall_info = CityCombatData.Instance:GetWallInfo()
			if id == flag_info.boss2_1_id or id == flag_info.boss2_2_id or id == flag_info.boss2_3_id or id == wall_info.id then
				return false
			end
		end
	elseif target_obj:GetType() == SceneObjType.Role then
		local x,y = target_obj:GetLogicPos()
	-- 	local is_in_resource_zone = CityCombatData.Instance:CheckIsInResourceZone(x, y)
	-- 	if is_in_resource_zone then
	-- 		return false
	-- 	end
		local is_in_safe_area = target_obj:IsInSafeArea()
		if is_in_safe_area then
			return false
		else
			return self:IsRoleEnemy(target_obj, main_role)
		end
	end

	return BaseSceneLogic.IsEnemy(self, target_obj, main_role, ignore_table)
end

-- function CityCombatFBLogic:GetIsCanMove(x, y)
-- 	local is_can_move = CityCombatData.Instance:GetIsCanMove(x, y)
-- 	return is_can_move
-- end

function CityCombatFBLogic:SetBlock(state)
	for k,v in pairs(self.block_grids) do
		if state then
			AStarFindWay:SetBlockInfo(v.x, v.y)
		else
			AStarFindWay:RevertBlockInfo(v.x, v.y)
		end
	end

	self.barrier_state = state
	self:UpdateBarrierState()
end

function CityCombatFBLogic:UpdateBarrierState()
	if nil ~= self.barrier then
		self.barrier:SetActive(self.barrier_state)
	end
end

function CityCombatFBLogic:GetGuajiPos()
	return CityCombatData.Instance:GetFlagPosXY()
end

function CityCombatFBLogic:GetIsShowSpecialImage(obj)
	-- local is_poqiang = CityCombatData.Instance:GetIsPoQiang()
	-- local def_camp_type = CityCombatData.Instance:GetDefenceCampType()
	-- local is_pochen = CityCombatData.Instance:GetIsPoChen()

	-- --防
	-- if def_camp_type ~= 0 then
	-- 	if obj.vo.camp == def_camp_type then
	-- 		return true, "uis/images", "city_combine_1"
	-- 	end
	-- end

	-- --攻
	-- if obj.vo.camp ~= nil then
	-- 	if obj.vo.camp ~= def_camp_type then
	-- 		return true, "uis/images", "city_combine_0"
	-- 	end
	-- end

	-- if def_camp_type ~= 0 and is_pochen == 0 then
	-- 	if obj.vo.camp == def_camp_type then
	-- 		return true, "uis/images", "city_combine_1"
	-- 	else
	-- 		return true, "uis/images", "city_combine_0"
	-- 	end

	-- end
	-- return false
end