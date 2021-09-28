CityCombatFBLogic = CityCombatFBLogic or BaseClass(CommonActivityLogic)

function CityCombatFBLogic:__init()
	self.block_grids = {
		{x = 116, y = 256},
		{x = 115, y = 256},
		{x = 114, y = 256},
		{x = 113, y = 256},
		{x = 112, y = 256},
		{x = 111, y = 256},
		{x = 110, y = 256},
		{x = 109, y = 256},
		{x = 108, y = 256},
		{x = 107, y = 256},
		{x = 106, y = 256},
		{x = 105, y = 256},
		{x = 104, y = 256},
		{x = 103, y = 256},
		{x = 102, y = 256},
		{x = 101, y = 256},
		{x = 100, y = 256},
		{x = 99, y = 256},
		{x = 98, y = 256},
		{x = 116, y = 284},
		{x = 115, y = 284},
		{x = 114, y = 284},
		{x = 113, y = 284},
		{x = 112, y = 284},
		{x = 111, y = 284},
		{x = 110, y = 284},
		{x = 109, y = 284},
		{x = 108, y = 284},
		{x = 107, y = 284},
		{x = 106, y = 284},
		{x = 105, y = 284},
		{x = 104, y = 284},
		{x = 103, y = 284},
		{x = 102, y = 284},
		{x = 101, y = 284},
		{x = 100, y = 284},
		{x = 99, y = 284},
		{x = 98, y = 284},
	}

	self.barrier = nil
	self.barrier_state = false

	self.is_show_auto_effect = true
	self.main_ui_auto_change = GlobalEventSystem:Bind(MainUIEventType.CLICK_AUTO_BUTTON, BindTool.Bind(self.OnAutoChange, self))
end

function CityCombatFBLogic:__delete()
	if self.main_ui_auto_change then
		GlobalEventSystem:UnBind(self.main_ui_auto_change)
		self.main_ui_auto_change = nil
	end
end

function CityCombatFBLogic:OnSceneDetailLoadComplete()
	self.barrier = GameObject.Find("Detail/Effects/barrier")
	self:UpdateBarrierState()
end

function CityCombatFBLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CityCombatView)
	ViewManager.Instance:Open(ViewName.CityCombatFBView)
	MainUICtrl.Instance.view:SetViewState(false)
	MainUICtrl.Instance:GetCityCombatButtons():SetActive(true)

	MainUICtrl.Instance:FlushView("auto_effect")
	
	local door_list = Scene.Instance:GetObjListByType(SceneObjType.Door)
	for _, door in pairs(door_list) do
		local vo = door:GetVo()
		vo.target_name = CityCombatData.Instance:GetDorrName()
	end
end

function CityCombatFBLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CityCombatFBView)
	MainUICtrl.Instance.view:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MainUICtrl.Instance:GetCityCombatButtons():SetActive(false)
	self:SetBlock(false)

	self.is_show_auto_effect = false
	MainUICtrl.Instance:FlushView("auto_effect")
end

function CityCombatFBLogic:OnAutoChange()
	if not self.is_show_auto_effect then return end

	self.is_show_auto_effect = false
	MainUICtrl.Instance:FlushView("auto_effect")
end

function CityCombatFBLogic:Update(now_time, elapse_time)
	CommonActivityLogic.Update(self, now_time, elapse_time)

end

function CityCombatFBLogic:IsRoleEnemy(scene_obj, main_role)
	return not self:IsSameSide(scene_obj, main_role)
end

-- 设置角色头上名字的颜色
function CityCombatFBLogic:GetColorName(scene_obj)
	local name = scene_obj.vo.name

	local main_role = Scene.Instance:GetMainRole()
	if main_role == nil or scene_obj.vo.role_id == main_role.vo.role_id then
		return name
	end

	if not (scene_obj:GetType() == SceneObjType.Role) then
		return name
	end

	return self:IsRoleEnemy(scene_obj, main_role) and ToColorStr(name, TEXT_COLOR.RED) or ToColorStr(name, TEXT_COLOR.WHITE)
end

function CityCombatFBLogic:IsSameSide(target_obj, main_role)
	local def_gulid_id = CityCombatData.Instance:GetDefenceGulidID()
	local guild_id = target_obj:GetVo().guild_id
	if main_role:GetVo().guild_id == def_gulid_id then
		if main_role:GetVo().guild_id == target_obj:GetVo().guild_id then			-- 同一边
			return true
		else
			return false
		end
	else
		if target_obj:GetVo().guild_id == def_gulid_id then
			return false
		else
			return true
		end
	end
end

function CityCombatFBLogic:IsEnemy(target_obj, main_role, ignore_table)
	if nil == target_obj or nil == main_role or not target_obj:IsCharacter() then
		return false
	end

	if target_obj:IsDead() then
		return false
	end

	if main_role:IsInSafeArea() then											-- 自己在安全区
		return false
	end
	if target_obj:GetType() == SceneObjType.Monster then
		local id = target_obj:GetMonsterId()
		if not CityCombatData.Instance:GetIsAtkSide() then
			local flag_info = CityCombatData.Instance:GetFlagInfo()
			local wall_info = CityCombatData.Instance:GetWallInfo()
			if id == flag_info.id or id == wall_info.id then
				return false
			end
		end
	elseif target_obj:GetType() == SceneObjType.Role then
		local x,y = target_obj:GetLogicPos()

		local is_in_safe_area = target_obj:IsInSafeArea()
		if is_in_safe_area then
			return false
		else
			return self:IsRoleEnemy(target_obj, main_role)
		end
	end

	return BaseSceneLogic.IsEnemy(self, target_obj, main_role, ignore_table)
end

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
	local def_gulid_id = CityCombatData.Instance:GetDefenceGulidID()
	if obj.vo.guild_id == def_gulid_id then
		return true, "uis/images_atlas", "city_combine_1"
	else
		return true, "uis/images_atlas", "city_combine_0"
	end
end
