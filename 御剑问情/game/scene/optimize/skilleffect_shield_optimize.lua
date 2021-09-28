SkillEffectShieldOptimize = SkillEffectShieldOptimize or BaseClass(BaseShieldOptimize)

function SkillEffectShieldOptimize:__init()
	self.max_appear_count = 8
	self.min_appear_count = 3
end

function SkillEffectShieldOptimize:__delete()

end

function SkillEffectShieldOptimize:GetAllObjIds()
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

function SkillEffectShieldOptimize:AppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Role then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SKILL_EFFECT) then -- 已经屏他人特效
		return false
	end

	local main_part = obj.draw_obj:GetPart(SceneObjPart.Main)
	main_part:EnableEffect(true)
	main_part:EnableFootsteps(true)

	return true
end

function SkillEffectShieldOptimize:DisAppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Role then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SKILL_EFFECT) then -- 已经屏他人特效
		return false
	end

	local main_part = obj.draw_obj:GetPart(SceneObjPart.Main)
	main_part:EnableEffect(false)
	main_part:EnableFootsteps(false)

	return true
end
