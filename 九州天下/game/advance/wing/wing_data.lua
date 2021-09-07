WingData = WingData or BaseClass()

WingDanId = {
		ChengZhangDanId = 22114,
		ZiZhiDanId = 22109,
}

WingShuXingDanCfgType = {
		Type = 6
}

WingDataEquipId = {
	16100, 16110, 16120, 16130
}

function WingData:__init()
	if WingData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	WingData.Instance = self

	self.level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("wing_auto").level, "wing_level")
	self.grade_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("wing_auto").grade, "grade")
	self.special_img_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("wing_auto").special_img, "image_id")
	self.all_special_img_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	self.special_img_upgrade_list = ListToMapList(ConfigManager.Instance:GetAutoConfig("wing_auto").special_image_upgrade, "special_img_id")
	self.skill_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").wing_skill
	self.image_list_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("wing_auto").image_list, "image_id")
	self.wing_equip_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").wing_equip
	self.up_start_exp_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("wing_auto").up_start_exp, "star_level")
	self.skill_id_list = ConfigManager.Instance:GetAutoConfig("wing_auto").skill_id

	self.wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto")
	self.equip_info_cfg = ListToMap(self.wing_cfg.wing_equip_info, "equip_idx", "equip_level")

	self.wing_info = {}
	self.temp_img_id = 0
	self.temp_img_id_has_select = 0
	self.temp_img_time = 0

	self.last_bless = 0
	self.last_grade = 0

	RemindManager.Instance:Register(RemindName.AdvanceWing, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function WingData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceWing)
	if WingData.Instance then
		WingData.Instance = nil
	end
	self.wing_info = {}
end

function WingData:SetWingInfo(protocol)
	self:SetLastInfo(self.wing_info.grade_bless_val, self.wing_info.grade)
	self.wing_info.wing_level = protocol.wing_level
	self.wing_info.grade = protocol.grade
	self.wing_info.grade_bless_val = protocol.grade_bless_val
	self.wing_info.used_imageid = protocol.used_imageid
	self.wing_info.shuxingdan_count = protocol.shuxingdan_count
	self.wing_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.wing_info.active_image_flag = protocol.active_image_flag
	-- self.wing_info.active_special_image_flag = protocol.active_special_image_flag
	self.wing_info.active_special_image_list = protocol.active_special_image_flag_ex
	self.wing_info.clear_upgrade_time = protocol.clear_upgrade_time

	-- self.wing_info.equip_info_list = protocol.equip_info_list
	self.wing_info.skill_level_list = protocol.skill_level_list
	self.wing_info.special_img_grade_list = protocol.special_img_grade_list

	self.wing_info.show_grade = math.ceil(protocol.grade / 10)
	self.wing_info.star_level = protocol.grade % 10
	
	self.temp_img_id = protocol.temp_img_id
	self.temp_img_id_has_select = protocol.temp_img_id_has_select
	self.temp_img_time = protocol.temp_img_time

	self.wing_info.equip_skill_level = protocol.equip_skill_level
	self.wing_info.equip_level_list = protocol.equip_level_list
end

function WingData:IsShowTempWingIcon()
	if self.temp_img_id_has_select == 0 and self.temp_img_time ~= 0 then
		return false
	end
	return true
end

function WingData:GetWingGrade()
	return self.wing_info.grade
end

function WingData:GetTempWingTime()
	return self.temp_img_time
end

function WingData:HasChooseTempWing()
	return self.temp_img_id_has_select ~= 0
end

function WingData:GetTempImgId()
	return self.temp_img_id_has_select
end


function WingData:GetWingInfo()
	return self.wing_info
end

function WingData:GetCurWingCfg(grade)
	local cfg = self:GetGradeCfg()
	for k,v in pairs(cfg) do
		if v.grade == grade then
			return v
		end
	end
end

--形象进阶+幻化的战力
function WingData:GetWingPower()
	local cfg = self:GetCurWingCfg(self.wing_info.grade)
	local upgrade_power = CommonDataManager.GetCapabilityCalculation(cfg)
	local huanhua_power = 0
	for k,v in pairs(self.wing_info.active_special_image_list) do
		if v == 1 then
			local index = k
			local huanhua_cfg = self:GetSpecialImageUpgradeInfo(index)
			huanhua_power = huanhua_power + CommonDataManager.GetCapabilityCalculation(huanhua_cfg)
		end
	end
	return huanhua_power + upgrade_power
end

function WingData:GetWingLevelCfg(wing_level)
	--local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	if wing_level == nil then
		return nil
	end

	if wing_level >= self:GetMaxWingLevelCfg() then
		wing_level = self:GetMaxWingLevelCfg()
	end
	--return wing_config.level[wing_level]
	return self.level_cfg[wing_level]
end

function WingData:GetMaxWingLevelCfg()
	--return #ConfigManager.Instance:GetAutoConfig("wing_auto").level
	return #self.level_cfg
end

function WingData:GetWingShowGradeCfg(wing_grade)
	-- local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	-- return wing_config.grade[wing_grade * 10]
	if wing_grade ~= nil then
		return self.grade_cfg[wing_grade * 10]
	end

	return nil
end

function WingData:GetWingGradeCfg(wing_grade)
	-- local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	-- return wing_config.grade[wing_grade]
	if wing_grade ~= nil then
		return self.grade_cfg[wing_grade]
	end

	return nil
end

function WingData:GetSpecialImageCfg(image_id)
	-- local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	-- return wing_config[image_id]
	if image_id ~= nil then
		return self.special_img_cfg[image_id]
	end

	return nil 
end

function WingData:GetSpecialImagesCfg()
	--return ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	return self.all_special_img_cfg
end

function WingData:GetMaxGrade()
	return #self.grade_cfg / 10
end

function WingData:GetGradeCfg()
	--return ConfigManager.Instance:GetAutoConfig("wing_auto").grade
	return self.grade_cfg
end

function WingData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	return #self.all_special_img_cfg
end

function WingData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.wing_info.active_special_image_list or {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	for k,v in pairs(self.special_img_cfg) do
		local index = k
		if v ~= nil then
			if (v.show_level ~= nil and role_level >= v.show_level) and (v.open_day ~= nil and open_day >= v.open_day) then
				num = num + 1
				table.insert(show_list, v)
			else
				local has_num = ItemData.Instance:GetItemNumInBagById(v.item_id)
				if (active_list[index] ~= nil and active_list[index] == 1) or has_num > 0 then
					num = num + 1
					table.insert(show_list, v)					
				end
			end
		end
	end

	local function sort_function(a, b)
		return a.image_id < b.image_id
	end
	table.sort(show_list, sort_function)

	return num, show_list
end

function WingData:GetWingIsActive(image_id)
	return self.wing_info.active_special_image_list[image_id] ~= 0
end

function WingData:CheckIsHuanHuaItem(item_id)
	local is_item = false
	if item_id == nil or self.special_img_cfg == nil then
		return
	end

	for k,v in pairs(self.special_img_cfg) do
		if v ~= nil and v.item_id == item_id then
			is_item = true
			break
		end
	end

	return is_item
end

function WingData:GetSpecialImageUpgradeCfg()
	return ConfigManager.Instance:GetAutoConfig("wing_auto").special_image_upgrade
end

function WingData:GetSpecialImageUpgradeList(special_img_id)
	if special_img_id ~= nil then
		return self.special_img_upgrade_list[special_img_id]
	end

	return nil
end

function WingData:GetWingSkillCfg()
	--return ConfigManager.Instance:GetAutoConfig("wing_auto").wing_skill
	return self.skill_cfg
end

function WingData:GetWingImageCfg(image_id)
	--return ConfigManager.Instance:GetAutoConfig("wing_auto").image_list
	if image_id ~= nil then
		return self.image_list_cfg[image_id]
	end

	return nil
end

function WingData:GetWingEquipCfg()
	--return ConfigManager.Instance:GetAutoConfig("wing_auto").wing_equip
	return self.wing_equip_cfg
end

-- function WingData:GetWingEquipExpCfg()
-- 	return ConfigManager.Instance:GetAutoConfig("wing_auto").equip_exp
-- end

-- function WingData:GetWingEquipRandAttr()
-- 	return ConfigManager.Instance:GetAutoConfig("wing_auto").equip_attr_range
-- end

function WingData:GetWingUpStarExpCfg(star_level)
	--return ConfigManager.Instance:GetAutoConfig("wing_auto").up_start_exp
	if star_level ~= nil then
		return self.up_start_exp_cfg[star_level]
	end

	return nil
end

function WingData:GetWingSkillId()
	--return ConfigManager.Instance:GetAutoConfig("wing_auto").skill_id\
	return self.skill_id_list
end

-- 获取当前点击坐骑特殊形象的配置
function WingData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade
	if grade == nil and self.wing_info ~= nil and self.wing_info.special_img_grade_list ~= nil then
		grade = self.wing_info.special_img_grade_list[index] or 0
	elseif grade == nil then
		grade = 0
	end

	if is_next then
		grade = grade + 1
	end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if v.special_img_id == index and v.grade == grade then
	-- 		return v
	-- 	end
	-- end

	local cfg = self:GetSpecialImageUpgradeList(index)
	if cfg ~= nil and grade ~= nil then
		for k,v in pairs(cfg) do
			if v.grade == grade then
				return v
			end
		end
	end

	return nil
end

-- 获取形象列表的配置
function WingData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	-- for k, v in pairs(self:GetWingImageCfg()) do
	-- 	if v.image_id == index then
	-- 		return v
	-- 	end
	-- end

	return self:GetWingImageCfg(index)
end

-- 获取幻化最大等级
function WingData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if v.special_img_id == image_id and v.grade > 0 then
	-- 		max_level = max_level + 1
	-- 	end
	-- end

	local cfg = self:GetSpecialImageUpgradeList(image_id)
	if cfg ~= nil then
		for k,v in pairs(cfg) do
			if v.grade > 0 then
				max_level = max_level + 1
			end
		end
	end

	return max_level
end

-- 获取当前点击坐骑技能的配置
function WingData:GetWingSkillCfgById(skill_idx, level, wing_info)
	local wing_info = wing_info or self.wing_info
	local skill_id_list = self:GetWingSkillId()
	local skill_id = 0
	for k,v in pairs(skill_id_list) do
		if v.skill_id % 10 == skill_idx + 1 then
			skill_id = v.skill_id
			break
		end
	end
	local level = level or SkillData.Instance:GetSkillInfoById(skill_id) and SkillData.Instance:GetSkillInfoById(skill_id).level or 0
	for k, v in pairs(self:GetWingSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

function WingData:GetWingSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetWingSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end


-- 获取特殊形象总增加的属性
function WingData:GetSpecialImageAttrSum(wing_info)
	wing_info = wing_info or self.wing_info
	local sum_attr_list = CommonStruct.Attribute()
	-- local active_flag = wing_info.active_special_image_flag
	local bit_list = wing_info.active_special_image_list
	if bit_list == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	
	local special_chengzhangdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(bit_list) do
		if v == 1 then
			local spec_img_up_info = self:GetSpecialImageUpgradeInfo(k)
			if spec_img_up_info ~= nil then
				special_img_upgrade_info = spec_img_up_info
				special_chengzhangdan_count = special_chengzhangdan_count + special_img_upgrade_info.chengzhangdan_count
				special_shuxingdan_count = special_shuxingdan_count + special_img_upgrade_info.shuxingdan_count
				special_equip_limit = special_equip_limit + special_img_upgrade_info.equip_level

				sum_attr_list.max_hp = sum_attr_list.max_hp + special_img_upgrade_info.maxhp
				sum_attr_list.gong_ji = sum_attr_list.gong_ji + special_img_upgrade_info.gongji
				sum_attr_list.fang_yu = sum_attr_list.fang_yu + special_img_upgrade_info.fangyu
				sum_attr_list.ming_zhong = sum_attr_list.ming_zhong + special_img_upgrade_info.mingzhong
				sum_attr_list.shan_bi = sum_attr_list.shan_bi + special_img_upgrade_info.shanbi
				sum_attr_list.bao_ji = sum_attr_list.bao_ji + special_img_upgrade_info.baoji
				sum_attr_list.jian_ren = sum_attr_list.jian_ren + special_img_upgrade_info.jianren
			end
		end
	end
	if self:GetWingGradeCfg(wing_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetWingGradeCfg(wing_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetWingGradeCfg(wing_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetWingGradeCfg(wing_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function WingData:GetWingSkillAttrSum(wing_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetWingSkillCfgById(i, nil, wing_info)
		if skill_cfg ~=nil then
			attr_list.fang_yu = attr_list.fang_yu + skill_cfg.fangyu
			attr_list.gong_ji = attr_list.gong_ji + skill_cfg.gongji
			attr_list.max_hp = attr_list.max_hp + skill_cfg.maxhp
			attr_list.ming_zhong = attr_list.ming_zhong + skill_cfg.mingzhong
			attr_list.shan_bi = attr_list.shan_bi + skill_cfg.shanbi
			attr_list.bao_ji = attr_list.bao_ji + skill_cfg.baoji
			attr_list.jian_ren = attr_list.jian_ren + skill_cfg.jianren
		end
	end
	return attr_list
end

-- 获得已升级装备战力
function WingData:GetWingEquipAttrSum(wing_info)
	wing_info = wing_info or self.wing_info
	local attr_list = CommonStruct.Attribute()
	if nil == wing_info.equip_level_list then return attr_list end
	for k, v in pairs(wing_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end


-- 获取已吃成长丹，资质丹属性
function WingData:GetDanAttr(wing_info)
	wing_info = wing_info or self.wing_info
	local attr_list = CommonStruct.Attribute()
	if wing_info.wing_level >= self:GetMaxWingLevelCfg() then
		wing_info.wing_level = self:GetMaxWingLevelCfg()
	end
	local wing_level_cfg = self:GetWingLevelCfg(wing_info.wing_level)
	local wing_grade_cfg = self:GetWingGradeCfg(wing_info.grade)
	if not wing_grade_cfg then return attr_list end

	-- attr_list.gong_ji = math.floor((wing_level_cfg.gongji + wing_grade_cfg.gongji) * wing_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((wing_level_cfg.fangyu + wing_grade_cfg.fangyu) * wing_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((wing_level_cfg.maxhp + wing_grade_cfg.maxhp) * wing_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((wing_level_cfg.mingzhong + wing_grade_cfg.mingzhong) * wing_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((wing_level_cfg.shanbi + wing_grade_cfg.shanbi) * wing_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((wing_level_cfg.baoji + wing_grade_cfg.baoji) * wing_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((wing_level_cfg.jianren + wing_grade_cfg.jianren) * wing_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == WingShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * wing_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * wing_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * wing_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function WingData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function WingData:GetWingAttrSum(wing_info)
	wing_info = wing_info or self:GetWingInfo()

	local attr = CommonStruct.Attribute()
	if nil == wing_info.grade or wing_info.grade <= 0 or wing_info.wing_level < 1 then
		return attr
	end

	if wing_info.wing_level >= self:GetMaxWingLevelCfg() then
		wing_info.wing_level = self:GetMaxWingLevelCfg()
	end

	local wing_level_cfg = self:GetWingLevelCfg(wing_info.wing_level)
	local wing_grade_cfg = self:GetWingGradeCfg(wing_info.grade)
	local star_cfg = self:GetWingStarLevelCfg(wing_info.star_level)

	if not star_cfg then return attr end

	-- local wing_next_grade_cfg = self:GetWingGradeCfg(wing_info.grade + 1)
	local skill_attr = self:GetWingSkillAttrSum(wing_info)
	-- local equip_attr = self:GetWingEquipAttrSum(wing_info)
	local dan_attr = self:GetDanAttr(wing_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(wing_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().wing_attr_add / 10000 or 0
	local zhibao_percent = ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()) and
					ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()).wing_attr_add / 10000 or 0

	-- if 	wing_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = wing_next_grade_cfg.maxhp - wing_grade_cfg.maxhp
	-- 	differ_value.gong_ji = wing_next_grade_cfg.gongji - wing_grade_cfg.gongji
	-- 	differ_value.fang_yu = wing_next_grade_cfg.fangyu - wing_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = wing_next_grade_cfg.mingzhong - wing_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = wing_next_grade_cfg.shanbi - wing_grade_cfg.shanbi
	-- 	differ_value.bao_ji = wing_next_grade_cfg.baoji - wing_grade_cfg.baoji
	-- 	differ_value.jian_ren = wing_next_grade_cfg.jianren - wing_grade_cfg.jianren
	-- end

	-- local temp_attr_per = wing_info.grade_bless_val/wing_grade_cfg.bless_val_limit

	attr.max_hp = (wing_level_cfg.maxhp
				+ star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * wing_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent + zhibao_percent) * (wing_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (wing_level_cfg.gongji
				+ star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * wing_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent + zhibao_percent) * (wing_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (wing_level_cfg.fangyu
				+ star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * wing_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent + zhibao_percent) * (wing_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (wing_level_cfg.mingzhong
					+ star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * wing_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent + zhibao_percent) * (wing_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (wing_level_cfg.shanbi
				+ star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * wing_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent + zhibao_percent) * (wing_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (wing_level_cfg.baoji
				+ star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * wing_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent + zhibao_percent) * (wing_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (wing_level_cfg.jianren
				+ star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * wing_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent + zhibao_percent) * (wing_level_cfg.jianren + star_cfg.jianren)

	-- attr.per_pofang = equip_attr.per_pofang
	-- attr.per_mianshang = equip_attr.per_mianshang

	return attr
end

function WingData:GetWingStarLevelCfg(star_level)
	local star_level = star_level or self.wing_info.star_level

	-- for k, v in pairs(self:GetWingUpStarExpCfg()) do
	-- 	if v.star_level == star_level then
	-- 		return v
	-- 	end
	-- end

	return self:GetWingUpStarExpCfg(star_level)
end

function WingData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.wing_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.wing_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(WingDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function WingData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.wing_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.wing_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == WingDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function WingData:GetNextPercentAttrCfg(equip_index)
	if nil == self.wing_info or nil == next(self.wing_info) then
		return
	end

	local equip_level = self.wing_info.equip_level_list[equip_index] or 0
	local now_cfg = self:GetEquipInfoCfg(equip_index, equip_level)
	if nil == now_cfg then return end

	local next_cfg = nil
	while(true) do
		equip_level = equip_level + 1
		next_cfg = self:GetEquipInfoCfg(equip_index, equip_level)
		if nil == next_cfg then return end

		if now_cfg.add_percent < next_cfg.add_percent then
			return next_cfg
		end
	end
end

function WingData:GetEquipMinLevel()
	if nil == self.wing_info or nil == next(self.wing_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.wing_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end


function WingData:CanHuanhuaUpgrade()
	local list = {}
	if self.wing_info.grade == nil or self.wing_info.grade <= 0 then return list end
	if self.wing_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.wing_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.wing_info.special_img_grade_list[j.special_img_id] < self:GetMaxSpecialImageCfgById(j.special_img_id)then
			list[j.special_img_id] = j.special_img_id
		end
	end
	return list
end

function WingData:CanSkillUpLevelList()
	local list = {}
	if self.wing_info.grade == nil or self.wing_info.grade <= 0 then return list end

	for i, j in pairs(self:GetWingSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.wing_info.show_grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function WingData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetWingSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function WingData:CanJinjie()
	if self.wing_info.grade == nil or self.wing_info.grade <= 0 then return false end
	local cfg = self:GetWingGradeCfg(self.wing_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.wing_info.grade < #self.grade_cfg then
			return true
		end
	end
	return false
end

function WingData:GetMaxSpecialImageCfgById(id)
	-- local list = {}
	-- if id == nil then return list end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if id == v.special_img_id then
	-- 		list[v.grade] = v
	-- 	end
	-- end
	-- return #list

	local count = 0
	local cfg = self:GetSpecialImageUpgradeList(id)
	if cfg ~= nil then
		count = #cfg - 1
	end

	return count
end

function WingData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function WingData:GetWingGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetWingImageCfg(used_imageid)
	--if not image_list then return 0 end
	if not image_list then print_error("羽翼形象配置没有image_id:", used_imageid) return 0 end

	local show_grade = image_list.show_grade
	for k, v in pairs(self:GetGradeCfg()) do
		if v.show_grade == show_grade then
			return v.show_grade
		end
	end
	return 0
end

function WingData:IsActiviteWing()
	local active_flag = self.wing_info and self.wing_info.active_image_flag or {}
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function WingData:GetWingModelResCfg(sex, prof)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = sex or vo.sex
	local prof = prof or vo.prof
	if sex == 0 then
		return tonumber("100"..prof)
	else
		return tonumber("110"..prof)
	end
end

function WingData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function WingData:GetLastGrade()
	return self.last_grade
end

function WingData:ChangeShowInfo()
	self.show_bless = self.wing_info.grade_bless_val
end

function WingData:GetShowBless()
	return self.show_bless or self.last_bless
end

function WingData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("wing_jinjie") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or next(self:CanSkillUpLevelList()) ~= nil or self:CalEquipBtnRemind() or self:CanJinjie() or AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.WING)) then
		return 1
	end
	return 0
end

function WingData:GetOhterCfg()
	return self.wing_cfg.other[1]
end

function WingData:IsOpenEquip()
	if nil == self.wing_info or nil == next(self.wing_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.wing_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function WingData:CalEquipRemind(equip_index)
	if nil == self.wing_info or nil == next(self.wing_info) then
		return 0
	end

	local equip_level = self.wing_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

-- 计算装备按钮的红点
function WingData:CalEquipBtnRemind()
	local flag = false
	for i = 0, 3 do
		local item_flag = self:CalEquipRemind(i)
		if item_flag == 1 then
			flag =true
			break
		end
	end
	return flag
end

function WingData:IsActiveEquipSkill()
	if nil == self.wing_info or nil == next(self.wing_info) then
		return false
	end
	return self.wing_info.equip_skill_level > 0
end

function WingData:CheckHHIsActiveByItem(item_id)
	local is_active = false
	local index = nil
	if item_id == nil then
		return is_active, index
	end

	for k,v in pairs(self.special_img_cfg) do
		if v.item_id == item_id then
			index = v.image_id
			break
		end
	end

	if index ~= nil and self.wing_info ~= nil and self.wing_info.active_special_image_list ~= nil then
		is_active = self.wing_info.active_special_image_list[index] == 1
		index = index + GameEnum.MOUNT_SPECIAL_IMA_ID
	end

	return is_active, index
end

function WingData:GetCanUseImage()
	local image_id = nil
	if self.wing_info == nil or self.wing_info.grade == nil then
		return image_id
	end

	local grade = self.wing_info.grade
	local grade_cfg = self:GetWingGradeCfg(grade)
	if grade_cfg == nil then
		return image_id
	end

	return grade_cfg.image_id
end