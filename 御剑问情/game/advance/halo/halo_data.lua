HaloData = HaloData or BaseClass()

HaloDanId = {
		ChengZhangDanId = 22115,
		ZiZhiDanId = 22110,
}

HaloShuXingDanCfgType = {
		Type = 7
}

HaloDataEquipId = {
	16200, 16210, 16220, 16230
}

function HaloData:__init()
	if HaloData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	HaloData.Instance = self

	self.halo_info = {}
	self.temp_table_halo = {}
	self.halo_special_max_level = 0
	self.halo_cfg = ConfigManager.Instance:GetAutoConfig("halo_auto")
	self.equip_info_cfg = ListToMap(self.halo_cfg.halo_equip_info, "equip_idx", "equip_level")
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.halo_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end
	self:InitHaloMaxLevel()
end

--获取配置表中首种光环的最大等级
function HaloData:InitHaloMaxLevel()
	for i,v in ipairs(self.halo_cfg.special_image_upgrade) do
		if self.halo_special_max_level <= v.grade then
			self.halo_special_max_level = v.grade
		else
			break
		end
	end
end

function HaloData:__delete()
	if HaloData.Instance then
		HaloData.Instance = nil
	end
	self.halo_info = {}
	self.temp_table_halo = {}
end

function HaloData:SetHaloInfo(protocol)
	self.halo_info.halo_level = protocol.halo_level
	self.halo_info.grade = protocol.grade
	self.halo_info.grade_bless_val = protocol.grade_bless_val
	self.halo_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.halo_info.used_imageid = protocol.used_imageid
	self.halo_info.shuxingdan_count = protocol.shuxingdan_count
	self.halo_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.halo_info.active_image_flag = protocol.active_image_flag
	self.halo_info.active_special_image_flag = protocol.active_special_image_flag
	self.halo_info.active_special_image_flag2 = protocol.active_special_image_flag2
	self.halo_info.star_level = protocol.star_level
	self.halo_info.equip_skill_level = protocol.equip_skill_level

	self.halo_info.equip_level_list = protocol.equip_level_list
	self.halo_info.skill_level_list = protocol.skill_level_list
	self.halo_info.special_img_grade_list = protocol.special_img_grade_list
end

function HaloData:GetHaloInfo()
	return self.halo_info
end

function HaloData:GetSpecialImageIsActive(img_id)
	if nil == self.halo_info.active_special_image_flag2 or nil == self.halo_info.active_special_image_flag then
		return false
	end
	
	local bit_list = bit:d2b(self.halo_info.active_special_image_flag2)
	local bit_list2 = bit:d2b(self.halo_info.active_special_image_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	return 1 == bit_list[64 - img_id]
end

function HaloData:GetLevelAttribute()
	local level_cfg = self:GetHaloStarLevelCfg(self.halo_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function HaloData:GetHaloLevelCfg(halo_level)
	if halo_level >= self:GetMaxHaloLevelCfg() then
		halo_level = self:GetMaxHaloLevelCfg()
	end
	return self.halo_cfg.level[halo_level]
end

function HaloData:GetMaxHaloLevelCfg()
	return #self.halo_cfg.level
end

function HaloData:GetHaloGradeCfg(halo_grade)
	halo_grade = halo_grade or self.halo_info.grade or 0
	return self.halo_cfg.grade[halo_grade]
end

function HaloData:GetSpecialImagesCfg()
	return self.halo_cfg.special_img
end

function HaloData:GetSpecialImageCfg(image_id)
	local halo_config = self.halo_cfg.special_img
	return halo_config[image_id]
end

function HaloData:GetMaxGrade()
	return #self.halo_cfg.grade
end

function HaloData:GetGradeCfg()
	return self.halo_cfg.grade
end

function HaloData:GetMaxSpecialImage()
	return #self.halo_cfg.special_img
end

function HaloData:GetSpecialImageUpgradeCfg()
	return self.halo_cfg.special_image_upgrade
end

function HaloData:GetHaloSkillCfg()
	return self.halo_cfg.halo_skill
end

function HaloData:GetHaloImageCfg()
	return self.halo_cfg.image_list
end

function HaloData:GetSingleHaloImageCfg(image_id)
	return self.halo_cfg.image_list[image_id]
end

function HaloData:GetHaloEquipCfg()
	return self.halo_cfg.halo_equip
end

function HaloData:GetHaloEquipExpCfg()
	return self.halo_cfg.equip_exp
end

function HaloData:GetHaloEquipRandAttr()
	return self.halo_cfg.equip_attr_range
end

function HaloData:GetHaloUpStarStuffCfg()
	return self.halo_cfg.up_star_stuff[1]
end

function HaloData:GetHaloUpStarExpCfg()
	return self.halo_cfg.up_star_exp
end

function HaloData:GetOhterCfg()
	return self.halo_cfg.other[1]
end

-- 全属性加成所需阶数
function HaloData:GetActiveNeedGrade()
  	local other_cfg = self:GetOhterCfg()
  	return other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function HaloData:GetGrade()
  	return self.halo_info.grade or 0
end

-- 全属性加成百分比
function HaloData:GetAllAttrPercent()
  	local other_cfg = self:GetOhterCfg()
  	local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function HaloData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

-- 获取当前点击坐骑特殊形象的配置
function HaloData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade or self.halo_info.special_img_grade_list[index] or 0
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
function HaloData:GetSpecialImageMaxUpLevelById(image_id)
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
function HaloData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetHaloImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

function HaloData:GetImageIdByRes(res_id)
	for k,v in pairs(self:GetHaloImageCfg()) do
		if v.res_id == res_id then
			return v.image_id
		end
	end
	return 0
end

-- 获取当前点击坐骑技能的配置
function HaloData:GetHaloSkillCfgById(skill_idx, level, halo_info)
	if self.halo_info.skill_level_list == nil then
		 return
	end

	local halo_info = halo_info or self.halo_info
	local level = level or halo_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetHaloSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获取特殊形象总增加的属性
function HaloData:GetSpecialImageAttrSum(halo_info)
	halo_info = halo_info or self.halo_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = halo_info.active_special_image_flag
	local active_flag2 = halo_info.active_special_image_flag2 or self.halo_info.active_special_image_flag2
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
	if self:GetHaloGradeCfg(halo_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetHaloGradeCfg(halo_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetHaloGradeCfg(halo_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetHaloGradeCfg(halo_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function HaloData:GetHaloSkillAttrSum(halo_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetHaloSkillCfgById(i, nil, halo_info)
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
function HaloData:GetHaloEquipAttrSum(halo_info)
	halo_info = halo_info or self.halo_info
	local attr_list = CommonStruct.Attribute()
	if nil == halo_info.equip_level_list then return attr_list end
	for k, v in pairs(halo_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function HaloData:GetDanAttr(halo_info)
	halo_info = halo_info or self.halo_info
	if halo_info.halo_level >= self:GetMaxHaloLevelCfg() then
		halo_info.halo_level = self:GetMaxHaloLevelCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local halo_level_cfg = self:GetHaloLevelCfg(halo_info.halo_level)
	local halo_grade_cfg = self:GetHaloGradeCfg(halo_info.grade)
	if not halo_grade_cfg then print_error("光环配置表为空", halo_info.grade) return attr_list end
	-- attr_list.gong_ji = math.floor((halo_level_cfg.gongji + halo_grade_cfg.gongji) * halo_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((halo_level_cfg.fangyu + halo_grade_cfg.fangyu) * halo_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((halo_level_cfg.maxhp + halo_grade_cfg.maxhp) * halo_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((halo_level_cfg.mingzhong + halo_grade_cfg.mingzhong) * halo_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((halo_level_cfg.shanbi + halo_grade_cfg.shanbi) * halo_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((halo_level_cfg.baoji + halo_grade_cfg.baoji) * halo_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((halo_level_cfg.jianren + halo_grade_cfg.jianren) * halo_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == HaloShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * halo_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * halo_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * halo_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function HaloData:GetHaloAttrSum(halo_info)
	halo_info = halo_info or self:GetHaloInfo()
	local attr = CommonStruct.Attribute()

	if nil == halo_info.grade or halo_info.grade <= 0 or halo_info.halo_level < 1 then
		return attr
	end

	if halo_info.halo_level >= self:GetMaxHaloLevelCfg() then
		halo_info.halo_level = self:GetMaxHaloLevelCfg()
	end
	local halo_level_cfg = self:GetHaloLevelCfg(halo_info.halo_level)
	local halo_grade_cfg = self:GetHaloGradeCfg(halo_info.grade)
	local star_cfg = self:GetHaloStarLevelCfg(halo_info.star_level)

	if not halo_grade_cfg or not star_cfg then return attr end

	-- local halo_next_grade_cfg = self:GetHaloGradeCfg(halo_info.grade + 1)
	local skill_attr = self:GetHaloSkillAttrSum(halo_info)
	-- local equip_attr = self:GetHaloEquipAttrSum(halo_info)
	local dan_attr = self:GetDanAttr(halo_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(halo_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().halo_attr_add / 10000 or 0

	-- if 	halo_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = halo_next_grade_cfg.maxhp - halo_grade_cfg.maxhp
	-- 	differ_value.gong_ji = halo_next_grade_cfg.gongji - halo_grade_cfg.gongji
	-- 	differ_value.fang_yu = halo_next_grade_cfg.fangyu - halo_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = halo_next_grade_cfg.mingzhong - halo_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = halo_next_grade_cfg.shanbi - halo_grade_cfg.shanbi
	-- 	differ_value.bao_ji = halo_next_grade_cfg.baoji - halo_grade_cfg.baoji
	-- 	differ_value.jian_ren = halo_next_grade_cfg.jianren - halo_grade_cfg.jianren
	-- end

	-- local temp_attr_per = halo_info.grade_bless_val/halo_grade_cfg.bless_val_limit

	attr.max_hp = (halo_level_cfg.maxhp
				+ star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (halo_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (halo_level_cfg.gongji
				+ star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (halo_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (halo_level_cfg.fangyu
				+ star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (halo_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (halo_level_cfg.mingzhong
					+ star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * halo_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (halo_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (halo_level_cfg.shanbi
				+ star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (halo_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (halo_level_cfg.baoji
				+ star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (halo_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (halo_level_cfg.jianren
				+ star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (halo_level_cfg.jianren + star_cfg.jianren)

	return attr
end


function HaloData:GetHaloMaxAttrSum(halo_info)
	halo_info = halo_info or self:GetHaloInfo()
	local attr = CommonStruct.Attribute()

	if nil == halo_info.grade or halo_info.grade <= 0 or halo_info.halo_level < 1 then
		return attr
	end

	if halo_info.halo_level >= self:GetMaxHaloLevelCfg() then
		halo_info.halo_level = self:GetMaxHaloLevelCfg()
	end
	local halo_level_cfg = self:GetHaloLevelCfg(halo_info.halo_level)
	local halo_grade_cfg = self:GetHaloGradeCfg(halo_info.grade)
	local star_cfg = self:GetHaloStarLevelCfg(120)

	if not halo_grade_cfg or not star_cfg then return attr end

	-- local halo_next_grade_cfg = self:GetHaloGradeCfg(halo_info.grade + 1)
	local skill_attr = self:GetHaloSkillAttrSum(halo_info)
	-- local equip_attr = self:GetHaloEquipAttrSum(halo_info)
	local dan_attr = self:GetDanAttr(halo_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(halo_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().halo_attr_add / 10000 or 0

	-- if 	halo_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = halo_next_grade_cfg.maxhp - halo_grade_cfg.maxhp
	-- 	differ_value.gong_ji = halo_next_grade_cfg.gongji - halo_grade_cfg.gongji
	-- 	differ_value.fang_yu = halo_next_grade_cfg.fangyu - halo_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = halo_next_grade_cfg.mingzhong - halo_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = halo_next_grade_cfg.shanbi - halo_grade_cfg.shanbi
	-- 	differ_value.bao_ji = halo_next_grade_cfg.baoji - halo_grade_cfg.baoji
	-- 	differ_value.jian_ren = halo_next_grade_cfg.jianren - halo_grade_cfg.jianren
	-- end

	-- local temp_attr_per = halo_info.grade_bless_val/halo_grade_cfg.bless_val_limit

	attr.max_hp = (halo_level_cfg.maxhp
				+ star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (halo_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (halo_level_cfg.gongji
				+ star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (halo_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (halo_level_cfg.fangyu
				+ star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (halo_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (halo_level_cfg.mingzhong
					+ star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * halo_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (halo_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (halo_level_cfg.shanbi
				+ star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (halo_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (halo_level_cfg.baoji
				+ star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (halo_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (halo_level_cfg.jianren
				+ star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * halo_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (halo_level_cfg.jianren + star_cfg.jianren)

	return attr
end
function HaloData:GetHaloStarLevelCfg(star_level)
	local star_level = star_level or self.halo_info.star_level

	for k, v in pairs(self:GetHaloUpStarExpCfg()) do
		if v.star_level == star_level then
			return v
		end
	end

	return nil
end

function HaloData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.halo_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.halo_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(HaloDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function HaloData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.halo_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.halo_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == HaloDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function HaloData:CanHuanhuaUpgrade()
	local list = {}
	if self.halo_info.grade == nil or self.halo_info.grade <= 0 then return list end
	if self.halo_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.halo_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.halo_info.special_img_grade_list[j.special_img_id] < self.halo_special_max_level then
			list[j.special_img_id] = j.special_img_id
		end
	end

	return list
end

function HaloData:IsCanHuanhuaUpgrade()
	if self.halo_info.grade == nil or self.halo_info.grade <= 0 then return false end
	if self.halo_info.special_img_grade_list == nil then
		return false
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.halo_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.halo_info.special_img_grade_list[j.special_img_id] < self.halo_special_max_level then
			return true
		end
	end

	return false
end

function HaloData:CanSkillUpLevelList()
	local list = {}
	if self.halo_info.grade == nil or self.halo_info.grade <= 0 then return list end
	if self.halo_info.skill_level_list == nil then
		return list
	end

	for i, j in pairs(self:GetHaloSkillCfg()) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.halo_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.halo_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end

	return list
end

function HaloData:CanJinjie()
	if self.halo_info.grade == nil or self.halo_info.grade <= 0 then return false end
	if self.halo_info.grade >= self:GetMaxGrade()then
		return false
	end

	local halo_grade_cfg = self.halo_cfg.grade[self.halo_info.grade]
	if nil == halo_grade_cfg or halo_grade_cfg.is_clear_bless == 1 then
		return false
	end

	local num = ItemData.Instance:GetItemNumInBagById(halo_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(halo_grade_cfg.upgrade_stuff2_id)
	return num >= halo_grade_cfg.upgrade_stuff_count
end

function HaloData:GetMaxSpecialImageCfgById(id)
	local list = {}
	if id == nil then return list end
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if id == v.special_img_id then
			list[v.grade] = v
		end
	end
	return #list
end

function HaloData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function HaloData:GetHaloGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetHaloImageCfg()
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

function HaloData:IsActiviteHalo()
	local active_flag = self.halo_info and self.halo_info.active_image_flag or 0
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function HaloData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function HaloData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.halo_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function HaloData:CalEquipRemind(equip_index)
	if nil == self.halo_info or nil == next(self.halo_info) then
		return 0
	end

	local equip_level = self.halo_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

function HaloData:IsOpenEquip()
	if nil == self.halo_info or nil == next(self.halo_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.halo_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function HaloData:GetNextPercentAttrCfg(equip_index)
	if nil == self.halo_info or nil == next(self.halo_info) then
		return
	end

	local equip_level = self.halo_info.equip_level_list[equip_index] or 0
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

function HaloData:GetEquipMinLevel()
	if nil == self.halo_info or nil == next(self.halo_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.halo_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function HaloData:IsActiveEquipSkill()
	if nil == self.halo_info or nil == next(self.halo_info) then
		return false
	end
	return self.halo_info.equip_skill_level > 0
end

function HaloData:GetHuanHuaHaloCfg()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local index_cell = 0
	local temp_table = {}
	for i=1, #self:GetSpecialImagesCfg() do
		local open_day = self:GetSpecialImageCfg(i).open_day or 0
    	local lvl = self:GetSpecialImageCfg(i).lvl or 0
    	if  level >= lvl and server_day >= open_day then
    		table.insert(temp_table, self:GetSpecialImageCfg(i))
    	end
	end
	self.temp_table_halo = temp_table
	return temp_table
end

function HaloData:GetHuanHuaHaloCfgByIndex(index)
	return self:GetSpecialImageCfg(index) or 0
end

function HaloData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function HaloData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetHaloGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade()
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end
	return power, huanhua_add_per
end

--得到幻化形象当前等级
function HaloData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.halo_info or nil == self.halo_info.special_img_grade_list or nil == self.halo_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.halo_info.special_img_grade_list[image_id]
	return grade
end

--当前使用形象
function HaloData:GetUsedImageId()
	return self.halo_info.used_imageid 
end

--当前进阶等级对应的image_id
function HaloData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetHaloGradeCfg(self.halo_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end