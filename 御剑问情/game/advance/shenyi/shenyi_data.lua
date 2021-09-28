ShenyiData = ShenyiData or BaseClass()

ShenyiDanId = {
		ChengZhangDanId = 22117,
		ZiZhiDanId = 22112,
}

ShenyiShuXingDanCfgType = {
		Type = 9
}

ShenyiDataEquipId = {
	16400, 16410, 16420, 16430
}

SHENYIDATA_MAX_SPECIAL_LEVEL = 100

function ShenyiData:__init()
	if ShenyiData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	ShenyiData.Instance = self

	self.shenyi_info = {}

	self.shenyi_cfg = ConfigManager.Instance:GetAutoConfig("shenyi_auto")
	self.equip_info_cfg = ListToMap(self.shenyi_cfg.shenyi_equip_info, "equip_idx", "equip_level")
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.shenyi_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end
end

function ShenyiData:__delete()
	if ShenyiData.Instance then
		ShenyiData.Instance = nil
	end
	self.shenyi_info = {}
end

function ShenyiData:SetShenyiInfo(protocol)
	self.shenyi_info.star_level = protocol.star_level
	self.shenyi_info.shenyi_level = protocol.shenyi_level
	self.shenyi_info.grade = protocol.grade
	self.shenyi_info.grade_bless_val = protocol.grade_bless_val
	self.shenyi_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.shenyi_info.used_imageid = protocol.used_imageid
	self.shenyi_info.shuxingdan_count = protocol.shuxingdan_count
	self.shenyi_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.shenyi_info.active_image_flag = protocol.active_image_flag
	self.shenyi_info.active_special_image_flag = protocol.active_special_image_flag
	self.shenyi_info.active_special_image_flag2 = protocol.active_special_image_flag2
	self.shenyi_info.equip_skill_level = protocol.equip_skill_level

	self.shenyi_info.equip_level_list = protocol.equip_level_list
	self.shenyi_info.skill_level_list = protocol.skill_level_list
	self.shenyi_info.special_img_grade_list = protocol.special_img_grade_list
end

function ShenyiData:GetSpecialImageIsActive(img_id)
	if nil == self.shenyi_info.active_special_image_flag2 or nil == self.shenyi_info.active_special_image_flag then
		return false
	end

	local bit_list = bit:d2b(self.shenyi_info.active_special_image_flag2)
	local bit_list2 = bit:d2b(self.shenyi_info.active_special_image_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	return 1 == bit_list[64 - img_id]
end

function ShenyiData:GetLevelAttribute()
	local level_cfg = self:GetShenyiUpStarCfgByLevel(self.shenyi_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function ShenyiData:GetShenyiInfo()
	return self.shenyi_info
end

function ShenyiData:GetShenyiLevelCfg(shenyi_level)
	if shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_level = self:GetMaxShenyiLevelCfg()
	end
	return self.shenyi_cfg.level[shenyi_level]
end

function ShenyiData:GetMaxShenyiLevelCfg()
	return #self.shenyi_cfg.level
end

function ShenyiData:GetShenyiGradeCfg(shenyi_grade)
	shenyi_grade = shenyi_grade or self.shenyi_info.grade or 0
	return self.shenyi_cfg.grade[shenyi_grade]
end

function ShenyiData:GetSpecialImageCfg(image_id)
	local shenyi_config = self:GetSpecialImageList()
	for i,v in ipairs(shenyi_config) do
		if v.image_id == image_id then
			return v
		end
	end
	return {}
end

function ShenyiData:GetSpecialImageCfgByIndex(index)
	local shenyi_config = self:GetSpecialImageList()
	return shenyi_config[index]
end

function ShenyiData:GetSpecialImagesCfg()
	return self.shenyi_cfg.special_img
end

function ShenyiData:GetMaxGrade()
	return #self.shenyi_cfg.grade
end

function ShenyiData:GetGradeCfg()
	return self.shenyi_cfg.grade
end

function ShenyiData:GetMaxSpecialImage()
	local list = self:GetSpecialImageList()
	return #list
end

function ShenyiData:GetSpecialImageUpgradeCfg()
	return self.shenyi_cfg.special_image_upgrade
end

function ShenyiData:GetSpecialImageList()
	if self.special_image_list then
		return self.special_image_list
	end
	self.special_image_list = {}
	self.open_special_image_list = {}
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k,v in ipairs(self.shenyi_cfg.special_img) do
		if server_day >= v.open_day then
			table.insert(self.special_image_list, v)
			self.open_special_image_list[v.image_id] = true
		end
	end
	return self.special_image_list
end

function ShenyiData:GetShenyiSkillCfg()
	return self.shenyi_cfg.shenyi_skill
end

function ShenyiData:GetShenyiImageCfg()
	return self.shenyi_cfg.image_list
end

function ShenyiData:GetShenyiEquipCfg()
	return self.shenyi_cfg.shenyi_equip
end

function ShenyiData:GetShenyiEquipExpCfg()
	return self.shenyi_cfg.equip_exp
end

function ShenyiData:GetShenyiEquipRandAttr()
	return self.shenyi_cfg.equip_attr_range
end

function ShenyiData:GetShenyiUpStarPropCfg()
	return self.shenyi_cfg.up_start_stuff
end

function ShenyiData:IsShenyiStuff(item_id)
	for k,v in pairs(self.shenyi_cfg.up_start_stuff) do
		if item_id == v.up_star_item_id then
			return true
		end
	end
	return false
end

function ShenyiData:GetShenyiUpStarCfg()
	return self.shenyi_cfg.up_start_exp
end

function ShenyiData:GetShenyiMaxUpStarLevel()
	return #self.shenyi_cfg.up_start_exp
end

function ShenyiData:GetOhterCfg()
	return self.shenyi_cfg.other[1]
end

-- 全属性加成所需阶数
function ShenyiData:GetActiveNeedGrade()
  	local other_cfg = self:GetOhterCfg()
  	return other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function ShenyiData:GetGrade()
  	return self.shenyi_info.grade or 0
end

-- 全属性加成百分比
function ShenyiData:GetAllAttrPercent()
  	local other_cfg = self:GetOhterCfg()
  	local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function ShenyiData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

-- 获取当前点击坐骑特殊形象的配置
function ShenyiData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade or self.shenyi_info.special_img_grade_list[index] or 0
	if is_next then
		grade = grade + 1
	end

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == index and v.grade == grade then
			return v
		end
	end

	return nil
end

-- 获取幻化最大等级
function ShenyiData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

-- 获取形象列表的配置
function ShenyiData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetShenyiImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

-- 获取当前点击坐骑技能的配置
function ShenyiData:GetShenyiSkillCfgById(skill_idx, level, shenyi_info)
	local shenyi_info = shenyi_info or self.shenyi_info
	local level = level or shenyi_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetShenyiSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获取特殊形象总增加的属性丹和成长丹数量
function ShenyiData:GetSpecialImageAttrSum(shenyi_info)
	shenyi_info = shenyi_info or self.shenyi_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = shenyi_info.active_special_image_flag
	local active_flag2 = shenyi_info.active_special_image_flag2 or self.shenyi_info.active_special_image_flag2
	if active_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	local special_chengzhangdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(bit_list) do
		if v == 1 then
			if self:GetSpecialImageUpgradeInfo(64 - k) ~= nil then
				special_img_upgrade_info = self:GetSpecialImageUpgradeInfo(64 - k)
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
	if self:GetShenyiGradeCfg(shenyi_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetShenyiGradeCfg(shenyi_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetShenyiGradeCfg(shenyi_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetShenyiGradeCfg(shenyi_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function ShenyiData:GetShenyiSkillAttrSum(shenyi_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetShenyiSkillCfgById(i, nil, shenyi_info)
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
function ShenyiData:GetShenyiEquipAttrSum(shenyi_info)
	shenyi_info = shenyi_info or self.shenyi_info
	local attr_list = CommonStruct.Attribute()
	if nil == shenyi_info.equip_level_list then return attr_list end
	for k, v in pairs(shenyi_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function ShenyiData:GetDanAttr(shenyi_info)
	shenyi_info = shenyi_info or self.shenyi_info
	local attr_list = CommonStruct.Attribute()
	if shenyi_info.shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_info.shenyi_level = self:GetMaxShenyiLevelCfg()
	end
	local shenyi_level_cfg = self:GetShenyiLevelCfg(shenyi_info.shenyi_level)
	local shenyi_up_star_cfg = self:GetShenyiUpStarCfgByLevel(shenyi_info.star_level)
	shenyi_up_star_cfg = shenyi_up_star_cfg or CommonStruct.AttributeNoUnderline()
	-- local shenyi_grade_cfg = self:GetShenyiGradeCfg(shenyi_info.grade)
	-- attr_list.gong_ji = math.floor((shenyi_level_cfg.gongji + shenyi_up_star_cfg.gongji) * shenyi_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((shenyi_level_cfg.fangyu + shenyi_up_star_cfg.fangyu) * shenyi_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((shenyi_level_cfg.maxhp + shenyi_up_star_cfg.maxhp) * shenyi_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((shenyi_level_cfg.mingzhong + shenyi_up_star_cfg.mingzhong) * shenyi_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((shenyi_level_cfg.shanbi + shenyi_up_star_cfg.shanbi) * shenyi_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((shenyi_level_cfg.baoji + shenyi_up_star_cfg.baoji) * shenyi_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((shenyi_level_cfg.jianren + shenyi_up_star_cfg.jianren) * shenyi_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == ShenyiShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * shenyi_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * shenyi_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * shenyi_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function ShenyiData:GetShenyiAttrSum(shenyi_info, is_advancesucce)
	shenyi_info = shenyi_info or self:GetShenyiInfo()
	local attr = CommonStruct.Attribute()
	if nil == shenyi_info.grade or shenyi_info.grade <= 0 then
		return attr
	end
	if shenyi_info.shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_info.shenyi_level = self:GetMaxShenyiLevelCfg()
	end
	local shenyi_level_cfg = self:GetShenyiLevelCfg(shenyi_info.shenyi_level)
	-- local shenyi_grade_cfg = self:GetShenyiGradeCfg(shenyi_info.grade)
	local level = is_advancesucce and math.floor(shenyi_info.star_level / 10) * 10 or shenyi_info.star_level
	local shenyi_up_star_cfg = self:GetShenyiUpStarCfgByLevel(level) or CommonStruct.AttributeNoUnderline()
	-- local shenyi_next_grade_cfg = self:GetShenyiGradeCfg(shenyi_info.grade + 1)
	local skill_attr = self:GetShenyiSkillAttrSum(shenyi_info)
	-- local equip_attr = self:GetShenyiEquipAttrSum(shenyi_info)
	local dan_attr = self:GetDanAttr(shenyi_info)
	-- local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(shenyi_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().magic_wing_attr_add / 10000 or 0

	-- if 	shenyi_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = shenyi_next_grade_cfg.maxhp - shenyi_grade_cfg.maxhp
	-- 	differ_value.gong_ji = shenyi_next_grade_cfg.gongji - shenyi_grade_cfg.gongji
	-- 	differ_value.fang_yu = shenyi_next_grade_cfg.fangyu - shenyi_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = shenyi_next_grade_cfg.mingzhong - shenyi_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = shenyi_next_grade_cfg.shanbi - shenyi_grade_cfg.shanbi
	-- 	differ_value.bao_ji = shenyi_next_grade_cfg.baoji - shenyi_grade_cfg.baoji
	-- 	differ_value.jian_ren = shenyi_next_grade_cfg.jianren - shenyi_grade_cfg.jianren
	-- end

	-- local temp_attr_per = shenyi_info.grade_bless_val/shenyi_grade_cfg.bless_val_limit
	attr.max_hp = (shenyi_level_cfg.maxhp
				+ shenyi_up_star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * shenyi_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (shenyi_level_cfg.maxhp + shenyi_up_star_cfg.maxhp)

	attr.gong_ji = (shenyi_level_cfg.gongji
				+ shenyi_up_star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * shenyi_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (shenyi_level_cfg.gongji + shenyi_up_star_cfg.gongji)

	attr.fang_yu = (shenyi_level_cfg.fangyu
				+ shenyi_up_star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (shenyi_level_cfg.fangyu + shenyi_up_star_cfg.fangyu)

	attr.ming_zhong = (shenyi_level_cfg.mingzhong
					+ shenyi_up_star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (shenyi_level_cfg.mingzhong + shenyi_up_star_cfg.mingzhong)

	attr.shan_bi = (shenyi_level_cfg.shanbi
				+ shenyi_up_star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (shenyi_level_cfg.shanbi + shenyi_up_star_cfg.shanbi)

	attr.bao_ji = (shenyi_level_cfg.baoji
				+ shenyi_up_star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (shenyi_level_cfg.baoji + shenyi_up_star_cfg.baoji)

	attr.jian_ren = (shenyi_level_cfg.jianren
				+ shenyi_up_star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (shenyi_level_cfg.jianren + shenyi_up_star_cfg.jianren)

	return attr
end
--在原来的基础上加上进阶满级的属性（给顶级预览使用）
function ShenyiData:GetShenyiMaxAttrSum(shenyi_info, is_advancesucce)
	shenyi_info = shenyi_info or self:GetShenyiInfo()
	local attr = CommonStruct.Attribute()
	if nil == shenyi_info.grade or shenyi_info.grade <= 0 then
		return attr
	end
	if shenyi_info.shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_info.shenyi_level = self:GetMaxShenyiLevelCfg()
	end
	local shenyi_level_cfg = self:GetShenyiLevelCfg(shenyi_info.shenyi_level)
	-- local shenyi_grade_cfg = self:GetShenyiGradeCfg(shenyi_info.grade)
	local level = is_advancesucce and math.floor(shenyi_info.star_level / 10) * 10 or shenyi_info.star_level
	local shenyi_up_star_cfg = self:GetShenyiUpStarCfgByLevel(100) or CommonStruct.AttributeNoUnderline()
	-- local shenyi_next_grade_cfg = self:GetShenyiGradeCfg(shenyi_info.grade + 1)
	local skill_attr = self:GetShenyiSkillAttrSum(shenyi_info)
	-- local equip_attr = self:GetShenyiEquipAttrSum(shenyi_info)
	local dan_attr = self:GetDanAttr(shenyi_info)
	-- local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(shenyi_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().magic_wing_attr_add / 10000 or 0

	-- if 	shenyi_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = shenyi_next_grade_cfg.maxhp - shenyi_grade_cfg.maxhp
	-- 	differ_value.gong_ji = shenyi_next_grade_cfg.gongji - shenyi_grade_cfg.gongji
	-- 	differ_value.fang_yu = shenyi_next_grade_cfg.fangyu - shenyi_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = shenyi_next_grade_cfg.mingzhong - shenyi_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = shenyi_next_grade_cfg.shanbi - shenyi_grade_cfg.shanbi
	-- 	differ_value.bao_ji = shenyi_next_grade_cfg.baoji - shenyi_grade_cfg.baoji
	-- 	differ_value.jian_ren = shenyi_next_grade_cfg.jianren - shenyi_grade_cfg.jianren
	-- end

	-- local temp_attr_per = shenyi_info.grade_bless_val/shenyi_grade_cfg.bless_val_limit
	attr.max_hp = (shenyi_level_cfg.maxhp
				+ shenyi_up_star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * shenyi_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (shenyi_level_cfg.maxhp + shenyi_up_star_cfg.maxhp)

	attr.gong_ji = (shenyi_level_cfg.gongji
				+ shenyi_up_star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * shenyi_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (shenyi_level_cfg.gongji + shenyi_up_star_cfg.gongji)

	attr.fang_yu = (shenyi_level_cfg.fangyu
				+ shenyi_up_star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (shenyi_level_cfg.fangyu + shenyi_up_star_cfg.fangyu)

	attr.ming_zhong = (shenyi_level_cfg.mingzhong
					+ shenyi_up_star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (shenyi_level_cfg.mingzhong + shenyi_up_star_cfg.mingzhong)

	attr.shan_bi = (shenyi_level_cfg.shanbi
				+ shenyi_up_star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (shenyi_level_cfg.shanbi + shenyi_up_star_cfg.shanbi)

	attr.bao_ji = (shenyi_level_cfg.baoji
				+ shenyi_up_star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (shenyi_level_cfg.baoji + shenyi_up_star_cfg.baoji)

	attr.jian_ren = (shenyi_level_cfg.jianren
				+ shenyi_up_star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (shenyi_level_cfg.jianren + shenyi_up_star_cfg.jianren)

	return attr
end

function ShenyiData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.shenyi_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.shenyi_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(ShenyiDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function ShenyiData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.shenyi_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.shenyi_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == ShenyiDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function ShenyiData:CanHuanhuaUpgrade()
	local list = {}
	if self.shenyi_info.grade == nil or self.shenyi_info.grade <= 0 then return list end
	if self.shenyi_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.shenyi_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.shenyi_info.special_img_grade_list[j.special_img_id] < SHENYIDATA_MAX_SPECIAL_LEVEL then
			if not self.open_special_image_list then
				self:GetSpecialImageList()
			end
			if self.open_special_image_list[j.special_img_id] then
				list[j.special_img_id] = j.special_img_id
			end
		end
	end

	return list
end

function ShenyiData:IsCanHuanhuaUpgrade()
	local list = {}
	if self.shenyi_info.grade == nil or self.shenyi_info.grade <= 0 then return list end
	if self.shenyi_info.special_img_grade_list == nil then
		return false
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.shenyi_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.shenyi_info.special_img_grade_list[j.special_img_id] < SHENYIDATA_MAX_SPECIAL_LEVEL then
			return true
		end
	end

	return false
end

function ShenyiData:CanSkillUpLevelList()
	local list = {}
	if self.shenyi_info.grade == nil or self.shenyi_info.grade <= 0 then return list end
	if self.shenyi_info.skill_level_list == nil then
		return list
	end

	for i, j in pairs(self:GetShenyiSkillCfg()) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.shenyi_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.shenyi_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end

	return list
end

function ShenyiData:GetMaxSpecialImageCfgById(id)
	local list = {}
	if id == nil then return list end
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if id == v.special_img_id then
			list[v.grade] = v
		end
	end
	return #list
end

function ShenyiData:GetShenyiUpStarCfgByLevel(level)
	if nil == level then return end

	for k, v in pairs(self:GetShenyiUpStarCfg()) do
		if v.star_level == level then
			return v
		end
	end

	return nil
end

function ShenyiData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function ShenyiData:GetShenyiGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetShenyiImageCfg()
	if not image_list then return 0 end
	if not image_list[used_imageid] then return 0 end

	local show_grade = image_list[used_imageid].show_grade
	for k, v in pairs(self:GetGradeCfg()) do
		if v.show_grade == show_grade then
			return v.grade
		end
	end
	return 0
end

function ShenyiData:GetIsRichMoneyUpLevel(item_id)
	local is_rich = true
	local exp_cfg = 1
	local need_exp = self:GetShenyiUpStarCfgByLevel(self.shenyi_info.star_level).up_star_level_exp
	local num = 0
	for k,v in pairs(self:GetShenyiUpStarPropCfg()) do
		if v.up_star_item_id == item_id then
			exp_cfg = v.star_exp
		end
	end
	num = math.ceil(need_exp / exp_cfg)
	local all_gold = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id].gold * num
	if GameVoManager.Instance:GetMainRoleVo().gold > all_gold then
		return true
	else
		return false
	end
end

function ShenyiData:IsActiviteShenyi()
	local active_flag = self.shenyi_info and self.shenyi_info.active_image_flag or {}
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function ShenyiData:IsShowCancelHuanhuaBtn(grade)
	if grade == self.shenyi_info.grade then
		if self.shenyi_info.used_imageid > 1000 then
			return true
		end
	end
	return false
end

function ShenyiData:GetShowShenyiRes(grade)
	local grade = grade
	local shenyi_grade_cfg = self:GetShenyiGradeCfg(grade)
	local image_cfg = nil
	if shenyi_grade_cfg then
		image_cfg = self:GetShenyiImageCfg()
	end
	if self.shenyi_info.used_imageid < 1000 then
		if image_cfg then
			return image_cfg[shenyi_grade_cfg.image_id].res_id
		end
		return -1
	end
	if grade == self.shenyi_info.grade then
		return self:GetSpecialImageCfg(self.shenyi_info.used_imageid - 1000).res_id
	else
		if image_cfg then
			return image_cfg[shenyi_grade_cfg.image_id].res_id
		end
		return -1
	end
end

function ShenyiData:GetCurShenyiRes()
	local grade = 0
	if self.shenyi_info.used_imageid and self.shenyi_info.used_imageid > 1000  then
		local cfg = self:GetSpecialImageCfg(self.shenyi_info.used_imageid - 1000)
		if cfg then
			return cfg.res_id
		end
	else
		if self.shenyi_info.used_imageid then
			grade = self:GetShenyiGradeByUseImageId(self.shenyi_info.used_imageid)
			return self:GetShowShenyiRes(grade)
		end
	end
	return -1
end

function ShenyiData:GetColorName(grade)
	local image_id = self:GetShenyiGradeCfg(grade).image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..self:GetShenyiImageCfg()[image_id].image_name.."</color>"
	return name_str
end
function ShenyiData:GetName(grade)
	local image_id = self:GetShenyiGradeCfg(grade).image_id
	return self:GetShenyiImageCfg()[image_id].image_name
end

function ShenyiData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function ShenyiData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.shenyi_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function ShenyiData:CalEquipRemind(equip_index)
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return 0
	end

	local equip_level = self.shenyi_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

function ShenyiData:IsOpenEquip()
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.shenyi_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function ShenyiData:GetNextPercentAttrCfg(equip_index)
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return
	end

	local equip_level = self.shenyi_info.equip_level_list[equip_index] or 0
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

function ShenyiData:GetEquipMinLevel()
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.shenyi_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function ShenyiData:IsActiveEquipSkill()
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return false
	end
	return self.shenyi_info.equip_skill_level > 0
end

function ShenyiData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

--当前等级基础战力
function ShenyiData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetShenyiGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade()
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end
	return power, huanhua_add_per
end

--得到幻化形象当前等级
function ShenyiData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.shenyi_info or nil == self.shenyi_info.special_img_grade_list or nil == self.shenyi_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.shenyi_info.special_img_grade_list[image_id]
	return grade
end

--当前使用形象
function ShenyiData:GetUsedImageId()
	return self.shenyi_info.used_imageid
end

--当前进阶等级对应的image_id
function ShenyiData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetShenyiGradeCfg(self.shenyi_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end