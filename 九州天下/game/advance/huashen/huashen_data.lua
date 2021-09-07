HuashenData = HuashenData or BaseClass()

function HuashenData:__init()
	if HuashenData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	HuashenData.Instance = self

	self.huashen_info = {}
	self.huashen_protect_info = {}
	self.huashen_cfg_auto = ConfigManager.Instance:GetAutoConfig("huashen_cfg_auto")
end

function HuashenData:__delete()
	HuashenData.Instance = nil
	self.huashen_info = {}
	self.huashen_protect_info = {}
	self.huashen_cfg_auto = nil
end

-- 设置化神信息
function HuashenData:SetHuashenInfo(protocol)
	self.huashen_info.activie_flag = protocol.activie_flag
	self.huashen_info.cur_huashen_id = protocol.cur_huashen_id

	self.huashen_info.level_info_list = protocol.level_info_list
	self.huashen_info.grade_list = protocol.grade_list
end

function HuashenData:GetHuashenInfo()
	return self.huashen_info
end

-- 化神守护信息
function HuashenData:SetHuashenProtectInfo(protocol)
	self.huashen_protect_info[protocol.huashen_id] = protocol.spirit_list
end

function HuashenData:GetHuashenProtectInfo(huashen_id)
	return self.huashen_protect_info[huashen_id]
end

function HuashenData:GetHuashenInfoCfg()
	return self.huashen_cfg_auto.huashen_info
end

function HuashenData:GetHuashenProtectCfg()
	return self.huashen_cfg_auto.huashen_spirit
end

function HuashenData:GetMaxHuashenList()
	local index = 0
	for k, v in pairs(self.huashen_cfg_auto.huashen_info) do
		index = index + 1
	end
	return index
end

function HuashenData:GetHuashenLevelCfg(id, level)
	if not id then return end

	level = level or (self.huashen_info.level_info_list and self.huashen_info.level_info_list[id].level or 0)
	if 0 == level then
		local attr_list = CommonStruct.AttributeNoUnderline()
		return attr_list
	end
	for k, v in pairs(self.huashen_cfg_auto.huashen_level) do
		if v.id == id and v.level == level then
			return v
		end
	end
	return nil
end

function HuashenData:GetHuashenProtectLevelCfg(huashen_id, spirit_id, level)
	if not spirit_id then return end

	level = level or (self.huashen_protect_info[huashen_id] and self.huashen_protect_info[huashen_id][spirit_id].level or 0)
	-- local attr_list = CommonStruct.AttributeNoUnderline()
	-- if 0 == level then
	-- 	return attr_list
	-- end
	for k, v in pairs(self.huashen_cfg_auto.huashen_spirit) do
		if v.id == spirit_id and v.level == level then
			return v
		end
	end
	return nil
end

function HuashenData:GetHuashenMaxLevel(id)
	if not id then return end

	local count = 0
	for k, v in pairs(self.huashen_cfg_auto.huashen_level) do
		if v.id == id then
			count = count + 1
		end
	end
	return count
end

function HuashenData:GetHuashenProtectMaxLevel(spirit_id)
	if not spirit_id then return end

	local count = 0
	for k, v in pairs(self.huashen_cfg_auto.huashen_spirit) do
		if v.id == spirit_id then
			count = count + 1
		end
	end
	return count
end

function HuashenData:GetHuashenImageCfg(huashen_id, grade)
	if not huashen_id then return end

	grade = grade or (self.huashen_info.grade_list and self.huashen_info.grade_list[huashen_id] or 0)
	local attr_list = CommonStruct.AttributeNoUnderline()
	if 0 == grade then
		return attr_list
	end
	for k, v in pairs(self.huashen_cfg_auto.huashen_grade) do
		if v.id == huashen_id and v.grade == grade then
			return v
		end
	end
	return nil
end

function HuashenData:GetHuashenImageMaxGrade(huashen_id)
	if not huashen_id then return end

	local count = 0
	for k, v in pairs(self.huashen_cfg_auto.huashen_grade) do
		if v.id == huashen_id then
			count = count + 1
		end
	end
	return count
end