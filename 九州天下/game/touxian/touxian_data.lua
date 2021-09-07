TouXianData = TouXianData or BaseClass()
function TouXianData:__init()
	if TouXianData.Instance then
		print_error("[TouXianData] Attemp to create a singleton twice !")
	end
	TouXianData.Instance = self

	self.level_cfg = nil
	self.title_level = 0
	self.other_cfg = nil
end

function TouXianData:__delete()
	self.level_cfg = nil
	self.title_level = 0
	self.other_cfg = nil
	TouXianData.Instance = nil
end

function TouXianData:GetLevelCfg()
	if not self.level_cfg then
		local config = ConfigManager.Instance:GetAutoConfig("honourtitleconfig_auto").title_upgrade
		self.level_cfg = ListToMap(config, "titile_level")
	end
	return self.level_cfg
end

function TouXianData:GetConfigByLevel(level)
	local level_cfg = self:GetLevelCfg()
	if level_cfg[level] then
		return level_cfg[level]
	end
	return {}
end

function TouXianData:SetHonourTitleAllInfo(protocol)
	self.title_level = protocol.title_level
end

function TouXianData:GetCurLevel()
	return self.title_level
end

function TouXianData:GetOtherConfig()
	if not self.other_cfg then
		self.other_cfg = ConfigManager.Instance:GetAutoConfig("honourtitleconfig_auto").other[1]
	end
	return self.other_cfg
end

function TouXianData:SkillActiveName(skill_index)
	local level_cfg = self:GetLevelCfg()
	for k,v in pairs(level_cfg) do
		if v["skill_effect_" .. skill_index] and v["skill_effect_" .. skill_index] > 0 then
			return v.title_name
		end
	end
end

function TouXianData:GetSkillNameByIndex(skill_index)
	if skill_index == nil then return end
	local cfg = self:GetOtherConfig()
	for k,v in pairs(cfg) do
		if k == "skill_name_" .. skill_index  then
			return v
		end
	end
	return " "

end