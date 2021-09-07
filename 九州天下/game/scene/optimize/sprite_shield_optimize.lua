SpiriteShieldOptimize = SpiriteShieldOptimize or BaseClass(BaseShieldOptimize)

function SpiriteShieldOptimize:__init()
	self.max_appear_count = 10
	self.min_appear_count = 3
end

function SpiriteShieldOptimize:__delete()

end

function SpiriteShieldOptimize:GetAllObjIds()
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

function SpiriteShieldOptimize:AppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Role then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SPIRIT) then -- 已经屏精灵
		return false
	end

	obj:SetSpriteVisible(true)

	return true
end

function SpiriteShieldOptimize:DisAppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Role then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SPIRIT) then -- 已经屏精灵
		return false
	end

	obj:SetSpriteVisible(false)

	return true
end
