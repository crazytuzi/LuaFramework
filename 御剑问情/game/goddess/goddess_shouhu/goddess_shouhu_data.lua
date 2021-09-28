GoddessShouhuData = GoddessShouhuData or BaseClass()
function GoddessShouhuData:__init()
	if GoddessShouhuData.Instance then
		print_error("[GoddessShouhuData] Attemp to create a singleton twice !")
	end
	GoddessShouhuData.Instance = self
	self.shou_hu_info = {}
	self.is_first = true
end

function GoddessShouhuData:__delete()
	GoddessShouhuData.Instance = nil
end

function GoddessShouhuData:SCXiannvShouhuInfo(protocol)
	local shou_hu_info = {}
	shou_hu_info.star_level = protocol.star_level
	shou_hu_info.grade = protocol.grade
	shou_hu_info.used_change = false
	if self.shou_hu_info.grade ~= protocol.grade and not self.is_first then
		shou_hu_info.used_change = true
	end
	shou_hu_info.used_imageid = protocol.used_imageid
	shou_hu_info.active_image_flag = bit:d2b(protocol.active_image_flag)
	shou_hu_info.grade_bless_val = protocol.grade_bless_val
	self.shou_hu_info = shou_hu_info
	if self.is_first then self.is_first = false end
end

function GoddessShouhuData:GetShouHuInfo()
	return self.shou_hu_info
end

function GoddessShouhuData:GetShouHuGradeCfg(grade)
	return ConfigManager.Instance:GetAutoConfig("xiannv_shouhu_auto").grade[grade]
end

function GoddessShouhuData:GetShouHuImageCfg(image_id)
	return ConfigManager.Instance:GetAutoConfig("xiannv_shouhu_auto").image_list[image_id]
end

function GoddessShouhuData:GetUpStartStuffCfg()
	return ConfigManager.Instance:GetAutoConfig("xiannv_shouhu_auto").up_start_stuff
end

function GoddessShouhuData:GetUpStartExpCfg(star_level)
	local list = ConfigManager.Instance:GetAutoConfig("xiannv_shouhu_auto").up_start_exp
	for k,v in pairs(list) do
		if v.star_level == star_level then
			return v
		end
	end
end

function GoddessShouhuData:GetShowHuShowValue(select_grade)
	local show_list = {}
	if select_grade == 0 then
		select_grade = 1
	end
	local shou_hu_grade_info = self:GetShouHuGradeCfg(select_grade)
	show_list.grade_name = shou_hu_grade_info.gradename
	show_list.image_name = self:GetShouHuImageCfg(shou_hu_grade_info.image_id).image_name
	show_list.used_imageid = self.shou_hu_info.used_imageid
	-- show_list.up_star_item_id = self:GetUpStartStuffCfg().up_star_item_id
	-- show_list.bag_num = ItemData.Instance:GetItemNumInBagById(show_list.up_star_item_id)
	show_list.star_exp_info = self:GetUpStartExpCfg(self.shou_hu_info.star_level)
	show_list.grade_bless_val = self.shou_hu_info.grade_bless_val
	show_list.fix_exp = self:GetUpStartExpCfg(self.shou_hu_info.star_level).up_star_level_exp
	show_list.shou_hu_level = self.shou_hu_info.star_level
	show_list.used_change = self.shou_hu_info.used_change
	return show_list
end

--获取升星材料
function GoddessShouhuData:GetUpStartMat()
	local list = self:GetUpStartStuffCfg()
	data = {}
	for k,v in pairs(list) do
		data[k] = ItemData.Instance:GetItemConfig(v.up_star_item_id)
	end
	return data
end

function GoddessShouhuData:GetIsUseGrade(grade)
	return self.shou_hu_info.used_imageid == self:GetImageByGrade(grade)
end

function GoddessShouhuData:GetImageByGrade(grade)
	if grade == 0 then
		grade = 1
	end
	return ConfigManager.Instance:GetAutoConfig("xiannv_shouhu_auto").grade[grade].image_id
end

function GoddessShouhuData:GetMatInfo(item_id)
	local list = self:GetUpStartStuffCfg()
	for k,v in pairs(list) do
		if v.up_star_item_id == item_id then
			return v
		end
	end
end

function GoddessShouhuData:GetGradeByImage(image_id)
	local grade_list = ConfigManager.Instance:GetAutoConfig("xiannv_shouhu_auto").grade
	for k,v in pairs(grade_list) do
		if v.image_id == image_id then
			return v.grade
		end
	end
end

function GoddessShouhuData:GetRedPoint()
	local item_num_list = {}
	local all_mat_cfg = self:GetUpStartStuffCfg()
	local cfg_exp_list = {}
	for k,v in pairs(all_mat_cfg) do
		cfg_exp_list[#cfg_exp_list + 1] = v.star_exp
		item_num_list[#item_num_list + 1] = ItemData.Instance:GetItemNumInBagById(v.up_star_item_id)
	end
	local total_exp = 0
	local exp_list = {}
	for k,v in pairs(item_num_list) do
		exp_list[k] = v * cfg_exp_list[k]
	end
	for k,v in pairs(exp_list) do
		total_exp = total_exp + v
	end
	if self.shou_hu_info.star_level == nil then
		return false
	else
		if total_exp >= self:GetUpStartExpCfg(self.shou_hu_info.star_level).up_star_level_exp - self.shou_hu_info.grade_bless_val then
			return true
		else
			return false
		end
	end
end
