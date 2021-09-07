RoleShieldOptimize = RoleShieldOptimize or BaseClass(BaseShieldOptimize)

function RoleShieldOptimize:__init()
	self.max_appear_count = 20
	self.min_appear_count = 5
end

function RoleShieldOptimize:__delete()

end

function RoleShieldOptimize:GetAllObjIds()
	local all_objids = {}
	local appear_count = 0

	local role_list = Scene.Instance:GetRoleList()
	for _, v in pairs(role_list) do
		local is_visible = v:IsRoleVisible()
		all_objids[v:GetObjId()] = is_visible

		if is_visible then
			appear_count = appear_count + 1
		end
	end

	return all_objids, appear_count
end

function RoleShieldOptimize:AppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Role then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_OTHERS) then -- 已经屏其他角色
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP) 	-- 已经屏友方玩家
		and not Scene.Instance:IsEnemy(obj) then
		return false
	end

	obj:SetRoleVisible(not SettingData.Instance:IsShieldOtherRole(Scene.Instance:GetSceneId()))
	Scene.Instance:SetFollowLocalPosition(0, obj)

	return true
end

function RoleShieldOptimize:DisAppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Role then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_OTHERS) then -- 已经屏其他角色
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP) 	-- 已经屏友方玩家
		and not Scene.Instance:IsEnemy(obj) then
		return false
	end

	obj:SetRoleVisible(false)
	Scene.Instance:SetFollowLocalPosition(100, obj)

	return true
end
