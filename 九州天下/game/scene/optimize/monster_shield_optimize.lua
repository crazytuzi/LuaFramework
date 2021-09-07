MonsterShieldOptimize = MonsterShieldOptimize or BaseClass(BaseShieldOptimize)

function MonsterShieldOptimize:__init()
	self.max_appear_count = 25
	self.min_appear_count = 10
end

function MonsterShieldOptimize:__delete()

end

function MonsterShieldOptimize:GetAllObjIds()
	local all_objids = {}
	local appear_count = 0

	local monster_list = Scene.Instance:GetMonsterList()
	for _, v in pairs(monster_list) do
		if not v:IsBoss() then
			if v.draw_obj then
				local is_visible = v.draw_obj:GetObjVisible()
				all_objids[v:GetObjId()] = is_visible
				if is_visible then
					appear_count = appear_count + 1
				end				
			end
		end
	end
	return all_objids, appear_count
end

function MonsterShieldOptimize:AppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Monster then
		return false
	end

	if CgManager.Instance:IsCgIng() then -- CG中
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_ENEMY) then -- 已经屏怪物
		return false
	end

	obj.draw_obj:SetVisible(true)
	local follow_ui = obj.draw_obj:GetSceneObj():GetFollowUi()
	if nil ~= follow_ui then
		follow_ui:SetHpBarLocalPosition(0, -5, 0)
	end

	return true
end

function MonsterShieldOptimize:DisAppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Monster then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_ENEMY) then -- 已经屏怪物
		return false
	end

	obj.draw_obj:SetVisible(false)
	local follow_ui = obj.draw_obj:GetSceneObj():GetFollowUi()
	if nil ~= follow_ui then
		follow_ui:SetHpBarLocalPosition(0, 80, 0)
	end

	return true
end