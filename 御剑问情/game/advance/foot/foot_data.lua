FootData = FootData or BaseClass()

FootDanId = {
		ChengZhangDanId = 22114,
		ZiZhiDanId = 22105,
}

FootShuXingDanCfgType = {
		Type = 12
}

FootDataEquipId = {
	16100, 16110, 16120, 16130
}

function FootData:__init()
	if FootData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	FootData.Instance = self

	self.foot_info = {
		footprint_level = 0,
		grade = 0,
		star_level = 0,
		used_imageid = 0,
		shuxingdan_count = 0,
		chengzhangdan_count = 0,
		grade_bless_val = 0,
		active_image_flag = 0,
		active_special_image_flag = 0,
		active_special_image_flag2 = 0,
		clear_upgrade_time = 0,
		equip_skill_level = 0,
		equip_level_list = {},
		skill_level_list = {},
		special_img_grade_list = {},
	}
	self.temp_table_foot = {}
	self.temp_img_id = 0
	self.temp_img_id_has_select = 0
	self.temp_img_time = 0
	self.foot_special_max_level = 0
	self.foot_cfg = ConfigManager.Instance:GetAutoConfig("footprint_auto")
	self.equip_info_cfg = ListToMap(self.foot_cfg.footprint_equip_info, "equip_idx", "equip_level")
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.foot_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end
	self:InitFootMaxLevel()
end

--获取配置表中首种幻化足迹的最大等级
function FootData:InitFootMaxLevel()
	for i,v in ipairs(self.foot_cfg.special_image_upgrade) do
		if self.foot_special_max_level <= v.grade then
			self.foot_special_max_level = v.grade
		else
			break
		end
	end
end

function FootData:__delete()
	if FootData.Instance then
		FootData.Instance = nil
	end
	self.foot_info = {}
	self.temp_table_foot = {}
end

function FootData:SetFootInfo(protocol)
	self.foot_info.footprint_level = protocol.footprint_level
	self.foot_info.grade = protocol.grade
	self.foot_info.grade_bless_val = protocol.grade_bless_val
	self.foot_info.used_imageid = protocol.used_imageid
	self.foot_info.shuxingdan_count = protocol.shuxingdan_count
	self.foot_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.foot_info.active_image_flag = protocol.active_image_flag
	self.foot_info.active_special_image_flag = protocol.active_special_image_flag
	self.foot_info.active_special_image_flag2 = protocol.active_special_image_flag2
	self.foot_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.foot_info.star_level = protocol.star_level
	self.foot_info.equip_skill_level = protocol.equip_skill_level

	self.foot_info.equip_level_list = protocol.equip_level_list
	self.foot_info.skill_level_list = protocol.skill_level_list
	self.foot_info.special_img_grade_list = protocol.special_img_grade_list
end

function FootData:GetSpecialImageIsActive(img_id)
	if nil == self.foot_info.active_special_image_flag2 or nil == self.foot_info.active_special_image_flag then
		return false
	end
	
	local bit_list = bit:d2b(self.foot_info.active_special_image_flag2)
	local bit_list2 = bit:d2b(self.foot_info.active_special_image_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	return 1 == bit_list[64 - img_id]
end

function FootData:GetLevelAttribute()
	local level_cfg = self:GetFootStarLevelCfg(self.foot_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function FootData:IsShowTempFootIcon()
	if self.temp_img_id_has_select == 0 and self.temp_img_time ~= 0 then
		return false
	end
	return true
end

function FootData:GetTempFootTime()
	return self.temp_img_time
end

function FootData:HasChooseTempFoot()
	return self.temp_img_id_has_select ~= 0
end

function FootData:GetTempImgId()
	return self.temp_img_id_has_select
end

function FootData:GetFootInfo()
	return self.foot_info
end

function FootData:GetFootLevelCfg(foot_level)
	if foot_level >= self:GetMaxFootLevelCfg() then
		foot_level = self:GetMaxFootLevelCfg()
	end
	return self.foot_cfg.level[foot_level]
end

function FootData:GetMaxFootLevelCfg()
	return #self.foot_cfg.level
end

function FootData:GetFootGradeCfg(foot_grade)
	foot_grade = foot_grade or self.foot_info.grade or 0
	return self.foot_cfg.grade[foot_grade]
end

function FootData:GetSpecialImageCfg(image_id)
	local foot_config = self.foot_cfg.special_img
	return foot_config[image_id]
end

function FootData:GetSpecialImagesCfg()
	return self.foot_cfg.special_img
end

function FootData:GetMaxGrade()
	return #self.foot_cfg.grade
end

function FootData:GetGradeCfg()
	return self.foot_cfg.grade
end

function FootData:GetMaxSpecialImage()
	return #self.foot_cfg.special_img
end

function FootData:GetSpecialImageUpgradeCfg()
	return self.foot_cfg.special_image_upgrade
end

function FootData:GetFootSkillCfg()
	return self.foot_cfg.footprint_skill
end

function FootData:GetFootImageCfg()
	return self.foot_cfg.image_list
end

function FootData:GetFootResidByLevel(level)
	local res_id = 0
	if level < 1000 then
		local image_cfg = self:GetFootImageCfg()
		res_id = image_cfg[level] and image_cfg[level].res_id or 0
    else
        local special_img = self:GetSpecialImagesCfg()
    	level = level%1000
    	res_id = special_img[level] and special_img[level].res_id or 0
    end
	return res_id
end

function FootData:GetFootEquipCfg()
	return self.foot_cfg.foot_equip
end

function FootData:GetFootEquipExpCfg()
	return self.foot_cfg.equip_exp
end

function FootData:GetFootEquipRandAttr()
	return self.foot_cfg.equip_attr_range
end

function FootData:GetFootUpStarStuffCfg()
	return self.foot_cfg.up_star_stuff[1]
end

function FootData:GetFootUpStarExpCfg()
	return self.foot_cfg.up_star_exp
end

function FootData:GetOhterCfg()
	return self.foot_cfg.other[1]
end

-- 全属性加成所需阶数
function FootData:GetActiveNeedGrade()
  	local other_cfg = self:GetOhterCfg()
  	return other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function FootData:GetGrade()
  	return self.foot_info.grade or 0
end

-- 全属性加成百分比
function FootData:GetAllAttrPercent()
  	local other_cfg = self:GetOhterCfg()
  	local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function FootData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

-- 获取当前点击坐骑特殊形象的配置
function FootData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end
	local grade = grade or self.foot_info.special_img_grade_list[index] or 0
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

-- 获取形象列表的配置
function FootData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetFootImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

-- 获取形象列表的配置(幻化形象)
function FootData:GetSpecialImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetSpecialImagesCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

-- 获取幻化最大等级
function FootData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

-- 获取当前点击坐骑技能的配置
function FootData:GetFootSkillCfgById(skill_idx, level, foot_info)
	local foot_info = foot_info or self.foot_info
	local level = level or foot_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetFootSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获取特殊形象总增加的属性
function FootData:GetSpecialImageAttrSum(foot_info)
	foot_info = foot_info or self.foot_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = foot_info.active_special_image_flag
	local active_flag2 = foot_info.active_special_image_flag2 or self.foot_info.active_special_image_flag2
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
			if self:GetSpecialImageUpgradeInfo(36 - k) ~= nil then
				special_img_upgrade_info = self:GetSpecialImageUpgradeInfo(36 - k)
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
	if self:GetFootGradeCfg(foot_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetFootGradeCfg(foot_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetFootGradeCfg(foot_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetFootGradeCfg(foot_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function FootData:GetFootSkillAttrSum(foot_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetFootSkillCfgById(i, nil, foot_info)
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
function FootData:GetFootEquipAttrSum(foot_info)
	foot_info = foot_info or self.foot_info
	local attr_list = CommonStruct.Attribute()
	if nil == foot_info.equip_level_list then return attr_list end
	for k, v in pairs(foot_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function FootData:GetDanAttr(foot_info)
	foot_info = foot_info or self.foot_info
	local attr_list = CommonStruct.Attribute()
	if foot_info.footprint_level >= self:GetMaxFootLevelCfg() then
		foot_info.footprint_level = self:GetMaxFootLevelCfg()
	end
	local foot_level_cfg = self:GetFootLevelCfg(foot_info.footprint_level)
	local foot_grade_cfg = self:GetFootGradeCfg(foot_info.grade)
	if not foot_grade_cfg then return attr_list end

	-- attr_list.gong_ji = math.floor((foot_level_cfg.gongji + foot_grade_cfg.gongji) * foot_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((foot_level_cfg.fangyu + foot_grade_cfg.fangyu) * foot_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((foot_level_cfg.maxhp + foot_grade_cfg.maxhp) * foot_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((foot_level_cfg.mingzhong + foot_grade_cfg.mingzhong) * foot_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((foot_level_cfg.shanbi + foot_grade_cfg.shanbi) * foot_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((foot_level_cfg.baoji + foot_grade_cfg.baoji) * foot_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((foot_level_cfg.jianren + foot_grade_cfg.jianren) * foot_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == FootShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * foot_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * foot_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * foot_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function FootData:GetFootAttrSum(foot_info)
	foot_info = foot_info or self:GetFootInfo()

	local attr = CommonStruct.Attribute()
	if nil == foot_info.grade or foot_info.grade <= 0 or foot_info.footprint_level < 1 then
		return attr
	end

	if foot_info.footprint_level >= self:GetMaxFootLevelCfg() then
		foot_info.footprint_level = self:GetMaxFootLevelCfg()
	end

	local foot_level_cfg = self:GetFootLevelCfg(foot_info.footprint_level)
	local foot_grade_cfg = self:GetFootGradeCfg(foot_info.grade)
	local star_cfg = self:GetFootStarLevelCfg(foot_info.star_level)

	if not star_cfg then return attr end

	-- local foot_next_grade_cfg = self:GetFootGradeCfg(foot_info.grade + 1)
	local skill_attr = self:GetFootSkillAttrSum(foot_info)
	-- local equip_attr = self:GetFootEquipAttrSum(foot_info)
	local dan_attr = self:GetDanAttr(foot_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(foot_info)
	local medal_percent = 0 --MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().foot_attr_add / 10000 or 0
	local zhibao_percent = 0 --ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()) and
					-- ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()).foot_attr_add / 10000 or 0

	-- if 	foot_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = foot_next_grade_cfg.maxhp - foot_grade_cfg.maxhp
	-- 	differ_value.gong_ji = foot_next_grade_cfg.gongji - foot_grade_cfg.gongji
	-- 	differ_value.fang_yu = foot_next_grade_cfg.fangyu - foot_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = foot_next_grade_cfg.mingzhong - foot_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = foot_next_grade_cfg.shanbi - foot_grade_cfg.shanbi
	-- 	differ_value.bao_ji = foot_next_grade_cfg.baoji - foot_grade_cfg.baoji
	-- 	differ_value.jian_ren = foot_next_grade_cfg.jianren - foot_grade_cfg.jianren
	-- end

	-- local temp_attr_per = foot_info.grade_bless_val/foot_grade_cfg.bless_val_limit

	attr.max_hp = (foot_level_cfg.maxhp
				+ star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (foot_level_cfg.gongji
				+ star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (foot_level_cfg.fangyu
				+ star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (foot_level_cfg.mingzhong
					+ star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * foot_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent + zhibao_percent) * (foot_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (foot_level_cfg.shanbi
				+ star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (foot_level_cfg.baoji
				+ star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (foot_level_cfg.jianren
				+ star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.jianren + star_cfg.jianren)

	-- attr.per_pofang = equip_attr.per_pofang
	-- attr.per_mianshang = equip_attr.per_mianshang

    attr.move_speed = star_cfg.speed
	return attr
end

function FootData:GetFootMaxAttrSum(foot_info)
	foot_info = foot_info or self:GetFootInfo()
	local attr = CommonStruct.Attribute()
	if nil == foot_info.grade or foot_info.grade <= 0 or foot_info.footprint_level < 1 then
		return attr
	end

	if foot_info.footprint_level >= self:GetMaxFootLevelCfg() then
		foot_info.footprint_level = self:GetMaxFootLevelCfg()
	end

	local foot_level_cfg = self:GetFootLevelCfg(foot_info.footprint_level)
	local foot_grade_cfg = self:GetFootGradeCfg(foot_info.grade)
	local star_cfg = self:GetFootStarLevelCfg(100)

	if not star_cfg then return attr end

	-- local foot_next_grade_cfg = self:GetFootGradeCfg(foot_info.grade + 1)
	local skill_attr = self:GetFootSkillAttrSum(foot_info)
	-- local equip_attr = self:GetFootEquipAttrSum(foot_info)
	local dan_attr = self:GetDanAttr(foot_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(foot_info)
	local medal_percent = 0 --MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().foot_attr_add / 10000 or 0
	local zhibao_percent = 0 --ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()) and
					-- ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()).foot_attr_add / 10000 or 0

	-- if 	foot_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = foot_next_grade_cfg.maxhp - foot_grade_cfg.maxhp
	-- 	differ_value.gong_ji = foot_next_grade_cfg.gongji - foot_grade_cfg.gongji
	-- 	differ_value.fang_yu = foot_next_grade_cfg.fangyu - foot_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = foot_next_grade_cfg.mingzhong - foot_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = foot_next_grade_cfg.shanbi - foot_grade_cfg.shanbi
	-- 	differ_value.bao_ji = foot_next_grade_cfg.baoji - foot_grade_cfg.baoji
	-- 	differ_value.jian_ren = foot_next_grade_cfg.jianren - foot_grade_cfg.jianren
	-- end

	-- local temp_attr_per = foot_info.grade_bless_val/foot_grade_cfg.bless_val_limit

	attr.max_hp = (foot_level_cfg.maxhp
				+ star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (foot_level_cfg.gongji
				+ star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (foot_level_cfg.fangyu
				+ star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (foot_level_cfg.mingzhong
					+ star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * foot_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent + zhibao_percent) * (foot_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (foot_level_cfg.shanbi
				+ star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (foot_level_cfg.baoji
				+ star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (foot_level_cfg.jianren
				+ star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * foot_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent + zhibao_percent) * (foot_level_cfg.jianren + star_cfg.jianren)

	-- attr.per_pofang = equip_attr.per_pofang
	-- attr.per_mianshang = equip_attr.per_mianshang
	attr.move_speed = star_cfg.speed
	return attr
end

function FootData:GetFootStarLevelCfg(star_level)
	local star_level = star_level or self.foot_info.star_level

	for k, v in pairs(self:GetFootUpStarExpCfg()) do
		if v.star_level == star_level then
			return v
		end
	end

	return nil
end

function FootData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.foot_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.foot_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(FootDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function FootData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.foot_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.foot_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == FootDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function FootData:CanHuanhuaUpgrade()
	if self.foot_info.grade == nil or self.foot_info.grade <= 0 then
		return nil
	end

	local special_img_grade_list = self.foot_info.special_img_grade_list
	if special_img_grade_list == nil then
		return nil
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id) and
			special_img_grade_list[j.special_img_id] == j.grade and
			j.grade < self.foot_special_max_level then --self:GetMaxSpecialImageCfgById(j.special_img_id)
			return j.special_img_id
		end
	end

	return nil
end

function FootData:CanSkillUpLevelList()
	local list = {}
	if self.foot_info.grade == nil or self.foot_info.grade <= 0 then return list end
	if self.foot_info.skill_level_list == nil then
		return list
	end

	for i, j in pairs(self:GetFootSkillCfg()) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.foot_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.foot_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function FootData:CanJinjie()
	if self.foot_info.grade == nil or self.foot_info.grade <= 0 then return false end
	if self.foot_info.grade >= self:GetMaxGrade()then
		return false
	end

	local foot_grade_cfg = self.foot_cfg.grade[self.foot_info.grade]
	if nil == foot_grade_cfg or foot_grade_cfg.is_clear_bless == 1 then
		return false
	end

	local num = ItemData.Instance:GetItemNumInBagById(foot_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(foot_grade_cfg.upgrade_stuff2_id)
	return num >= foot_grade_cfg.upgrade_stuff_count
end

function FootData:GetMaxSpecialImageCfgById(id)
	if id == nil then return 0 end

	local count = 0
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if id == v.special_img_id then
			count = count + 1
		end
	end

	return count
end

function FootData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function FootData:GetFootGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetFootImageCfg()
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

function FootData:IsActiviteFoot()
	local active_flag = self.foot_info and self.foot_info.active_image_flag or 0
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function FootData:GetFootModelResCfg(sex, prof)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = sex or vo.sex
	local prof = prof or vo.prof
	if sex == 0 then
		return tonumber("100"..PROF_ROLE[prof])
	else
		return tonumber("110"..PROF_ROLE[prof])
	end
end

function FootData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function FootData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.foot_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function FootData:CalEquipRemind(equip_index)
	if nil == self.foot_info or nil == next(self.foot_info) then
		return 0
	end

	local equip_level = self.foot_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

function FootData:IsOpenEquip()
	if nil == self.foot_info or nil == next(self.foot_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.foot_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function FootData:GetNextPercentAttrCfg(equip_index)
	if nil == self.foot_info or nil == next(self.foot_info) then
		return
	end

	local equip_level = self.foot_info.equip_level_list[equip_index] or 0
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

function FootData:GetEquipMinLevel()
	if nil == self.foot_info or nil == next(self.foot_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.foot_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function FootData:IsActiveEquipSkill()
	if nil == self.foot_info or nil == next(self.foot_info) then
		return false
	end
	return self.foot_info.equip_skill_level > 0
end

function FootData:GetHuanHuaFootCfg()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local temp_table = {}
	for i=1, #self:GetSpecialImagesCfg() do
		local open_day = self:GetSpecialImageCfg(i).open_day
    	local lvl = self:GetSpecialImageCfg(i).lvl
    	if  level >= lvl and server_day >= open_day then
    		table.insert(temp_table,self:GetSpecialImageCfg(i))
		end
	end
	self.temp_table_foot = temp_table
	return temp_table
end

function FootData:GetHuanHuaFootCfgByIndex(index)
	return self:GetSpecialImageCfg(index) or 0
end

function FootData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function FootData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetFootGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade()
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end
	return power, huanhua_add_per
end

--得到幻化形象当前等级
function FootData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.foot_info or nil == self.foot_info.special_img_grade_list or nil == self.foot_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.foot_info.special_img_grade_list[image_id]
	return grade
end

--当前使用形象
function FootData:GetUsedImageId()
	return self.foot_info.used_imageid
end

--当前进阶等级对应的image_id
function FootData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetFootGradeCfg(self.foot_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end