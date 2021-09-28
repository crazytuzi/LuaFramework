CloakData = CloakData or BaseClass()

CloakDanId = {
		ZiZhiDanId = 22104,
}

CloakShuXingDanCfgType = {
		Type = 13
}

-- CloakDataEquipId = {
-- 	16100, 16110, 16120, 16130
-- }

function CloakData:__init()
	if CloakData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	CloakData.Instance = self

	self.cloak_info = {
		cloak_level = 0,
		cur_exp = 0,
		used_imageid = 0,
		shuxingdan_count = 0,
		active_image_flag = 0,
		active_special_image_flag = 0,
		equip_skill_level = 0,
		equip_level_list = {},
		skill_level_list = {},
		special_img_grade_list = {},
	}

	self.temp_img_id = 0
	self.temp_img_id_has_select = 0
	self.temp_img_time = 0

	self.cloak_cfg = ConfigManager.Instance:GetAutoConfig("cloak_auto")
	self.equip_info_cfg = ListToMap(self.cloak_cfg.cloak_equip_info, "equip_idx", "equip_level")
end

function CloakData:__delete()
	if CloakData.Instance then
		CloakData.Instance = nil
	end
	self.cloak_info = {}
end

function CloakData:SetCloakInfo(protocol)
	self.cloak_info.cloak_level = protocol.cloak_level
	self.cloak_info.cur_exp = protocol.cur_exp
	self.cloak_info.used_imageid = protocol.used_imageid
	self.cloak_info.shuxingdan_count = protocol.shuxingdan_count
	self.cloak_info.active_image_flag = protocol.active_image_flag
	self.cloak_info.active_special_image_flag = protocol.active_special_image_flag
	self.cloak_info.equip_skill_level = protocol.equip_skill_level

	self.cloak_info.equip_level_list = protocol.equip_level_list
	self.cloak_info.skill_level_list = protocol.skill_level_list
	self.cloak_info.special_img_grade_list = protocol.special_img_grade_list
end

function CloakData:GetCloakInfo()
	return self.cloak_info
end

function CloakData:GetCloakLevelCfg(cloak_level)
	for k,v in pairs(self.cloak_cfg.up_level_cfg) do
		if cloak_level == v.level then
			return v
		end
	end
end

function CloakData:GetMaxCloakLevel()
	local max_level = 0
	for k, v in pairs(self.cloak_cfg.up_level_cfg) do
		if v.level > max_level then
			max_level = v.level
		end
	end
	return max_level
end

function CloakData:CheckSelectItem(cur_index)
	local cur_item_id = self:GetCloakUpLevelStuffCfg(cur_index).up_level_item_id
	local num = ItemData.Instance:GetItemNumInBagById(cur_item_id)
	if num > 0 then return cur_index end

	for i, v in ipairs(self.cloak_cfg.up_level_stuff) do
		if v.up_level_item_id ~= cur_item_id then
			local num = ItemData.Instance:GetItemNumInBagById(v.up_level_item_id)
			if num > 0 then return v.up_level_item_index + 1 end
		end
	end

	return self.cloak_cfg.up_level_stuff[1].up_level_item_index + 1
end

function CloakData:GetNextActiveImgLevel()
	local level_cfg = self:GetCloakLevelCfg(self.cloak_info.cloak_level)
	for i, v in ipairs(self.cloak_cfg.up_level_cfg) do
		if v.level > self.cloak_info.cloak_level and v.active_image > level_cfg.active_image then
			return v.level
		end
	end
end

function CloakData:GetSpecialImageCfg(image_id)
	local cloak_config = self.cloak_cfg.special_img
	return cloak_config[image_id]
end

function CloakData:GetSpecialImagesCfg()
	return self.cloak_cfg.special_img
end

function CloakData:GetMaxSpecialImage()
	return #self.cloak_cfg.special_img
end

function CloakData:GetSpecialImageUpgradeCfg()
	return self.cloak_cfg.special_image_upgrade
end

function CloakData:GetCloakSkillCfg()
	return self.cloak_cfg.cloak_skill
end

function CloakData:GetGradeCfg()
	return self.cloak_cfg.grade
end

function CloakData:GetCloakImageCfg()
	return self.cloak_cfg.image_list
end

function CloakData:GetCloakEquipCfg()
	return self.cloak_cfg.cloak_equip
end

function CloakData:GetCloakEquipExpCfg()
	return self.cloak_cfg.equip_exp
end

function CloakData:GetCloakEquipRandAttr()
	return self.cloak_cfg.equip_attr_range
end

function CloakData:GetCloakUpLevelStuffCfg(index)
	return self.cloak_cfg.up_level_stuff[index]
end

function CloakData:GetOhterCfg()
	return self.cloak_cfg.other[1]
end


function CloakData:GetSkillIsActive(skill_index)
	if next(self.cloak_info) then
		for k,v in pairs(self.cloak_cfg.cloak_skill) do
			if v.skill_idx == skill_index and self.cloak_info.cloak_level >= v.level then
				return true
			end
		end
	end
	return false
end

function CloakData:GetCloakSkillCfgBuyIndex(index)
	for k,v in pairs(self.cloak_cfg.cloak_skill) do
		if index == v.skill_idx then
			return v
		end
	end
end

-- 获取当前点击披风特殊形象的配置
function CloakData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end
	local grade = grade or self.cloak_info.special_img_grade_list[index] or 0
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
function CloakData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetCloakImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
end

-- 获取幻化最大等级
function CloakData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

-- 获取当前点击披风技能的配置
function CloakData:GetCloakSkillCfgById(skill_idx, level, cloak_info)
	local cloak_info = cloak_info or self.cloak_info
	local level = level or cloak_info.skill_level_list[skill_idx]

	for k, v in pairs(self:GetCloakSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获取特殊形象总增加的属性
function CloakData:GetSpecialImageAttrSum(cloak_info)
	cloak_info = cloak_info or self.cloak_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = cloak_info.active_special_image_flag
	if active_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	local bit_list = bit:d2b(active_flag)
	local special_chengzhangdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(bit_list) do
		if v == 1 then
			if self:GetSpecialImageUpgradeInfo(32 - k) ~= nil then
				special_img_upgrade_info = self:GetSpecialImageUpgradeInfo(32 - k)
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

	return sum_attr_list
end

-- 获得已学习的技能总战力
function CloakData:GetCloakSkillAttrSum(cloak_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetCloakSkillCfgById(i, nil, cloak_info)
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
function CloakData:GetCloakEquipAttrSum(cloak_info)
	cloak_info = cloak_info or self.cloak_info
	local attr_list = CommonStruct.Attribute()
	if nil == cloak_info.equip_level_list then return attr_list end
	for k, v in pairs(cloak_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function CloakData:GetDanAttr(cloak_info)
	cloak_info = cloak_info or self.cloak_info
	local attr_list = CommonStruct.Attribute()
	-- if cloak_info.cloak_level >= self:GetMaxCloakLevel() then
	-- 	cloak_info.cloak_level = self:GetMaxCloakLevel()
	-- end
	-- local cloak_level_cfg = self:GetCloakLevelCfg(cloak_info.cloak_level)
	-- local cloak_grade_cfg = self:GetCloakGradeCfg(cloak_info.grade)
	-- if not cloak_level_cfg then return attr_list end

	-- attr_list.gong_ji = math.floor((cloak_level_cfg.gongji + cloak_grade_cfg.gongji) * cloak_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((cloak_level_cfg.fangyu + cloak_grade_cfg.fangyu) * cloak_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((cloak_level_cfg.maxhp + cloak_grade_cfg.maxhp) * cloak_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((cloak_level_cfg.mingzhong + cloak_grade_cfg.mingzhong) * cloak_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((cloak_level_cfg.shanbi + cloak_grade_cfg.shanbi) * cloak_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((cloak_level_cfg.baoji + cloak_grade_cfg.baoji) * cloak_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((cloak_level_cfg.jianren + cloak_grade_cfg.jianren) * cloak_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == CloakShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * cloak_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * cloak_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * cloak_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function CloakData:GetCloakAttrSum(cloak_info, is_next)
	cloak_info = cloak_info or self:GetCloakInfo()

	local attr = CommonStruct.Attribute()
	local cloak_level = cloak_info.cloak_level or 0
	if cloak_level < 1 then
		return attr
	end

	if cloak_info.cloak_level >= self:GetMaxCloakLevel() then
		cloak_info.cloak_level = self:GetMaxCloakLevel()
	end

	local cloak_level_cfg = self:GetCloakLevelCfg(is_next and cloak_info.cloak_level + 1 or cloak_info.cloak_level)
	if not cloak_level_cfg then return attr end

	-- local cloak_next_grade_cfg = self:GetCloakGradeCfg(cloak_info.grade + 1)
	local skill_attr = self:GetCloakSkillAttrSum(cloak_info)
	-- local equip_attr = self:GetCloakEquipAttrSum(cloak_info)
	local dan_attr = self:GetDanAttr(cloak_info)
	-- local differ_value = CommonStruct.Attribute()
	-- local special_img_attr = self:GetSpecialImageAttrSum(cloak_info)
	-- local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().cloak_attr_add / 10000 or 0
	-- local zhibao_percent = ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()) and
	-- 				ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()).cloak_attr_add / 10000 or 0

	-- if 	cloak_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = cloak_next_grade_cfg.maxhp - cloak_grade_cfg.maxhp
	-- 	differ_value.gong_ji = cloak_next_grade_cfg.gongji - cloak_grade_cfg.gongji
	-- 	differ_value.fang_yu = cloak_next_grade_cfg.fangyu - cloak_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = cloak_next_grade_cfg.mingzhong - cloak_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = cloak_next_grade_cfg.shanbi - cloak_grade_cfg.shanbi
	-- 	differ_value.bao_ji = cloak_next_grade_cfg.baoji - cloak_grade_cfg.baoji
	-- 	differ_value.jian_ren = cloak_next_grade_cfg.jianren - cloak_grade_cfg.jianren
	-- end

	-- local temp_attr_per = cloak_info.grade_bless_val/cloak_grade_cfg.bless_val_limit

	attr.max_hp = (cloak_level_cfg.maxhp
				-- + star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp)
				-- + special_img_attr.max_hp)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (cloak_level_cfg.gongji
				-- + star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji)
				-- + special_img_attr.gong_ji)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (cloak_level_cfg.fangyu
				-- + star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu)
				-- + special_img_attr.fang_yu)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (cloak_level_cfg.mingzhong
					-- + star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * cloak_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong)
					-- + special_img_attr.ming_zhong)
					-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (cloak_level_cfg.shanbi
				-- + star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi)
				-- + special_img_attr.shan_bi)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (cloak_level_cfg.baoji
				-- + star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji)
				-- + special_img_attr.bao_ji)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (cloak_level_cfg.jianren
				-- + star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren)
				-- + special_img_attr.jian_ren)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.jianren + star_cfg.jianren)

	-- attr.per_pofang = equip_attr.per_pofang
	-- attr.per_mianshang = equip_attr.per_mianshang

	return attr
end

function CloakData:GetCloakMaxAttrSum(cloak_info, is_next)
	cloak_info = cloak_info or self:GetCloakInfo()

	local attr = CommonStruct.Attribute()
	local cloak_level = cloak_info.cloak_level or 0
	if cloak_level < 1 then
		return attr
	end

	if cloak_info.cloak_level >= self:GetMaxCloakLevel() then
		cloak_info.cloak_level = self:GetMaxCloakLevel()
	end

	local cloak_level_cfg = self:GetCloakLevelCfg(1000)
	if not cloak_level_cfg then return attr end

	-- local cloak_next_grade_cfg = self:GetCloakGradeCfg(cloak_info.grade + 1)
	local skill_attr = self:GetCloakSkillAttrSum(cloak_info)
	-- local equip_attr = self:GetCloakEquipAttrSum(cloak_info)
	local dan_attr = self:GetDanAttr(cloak_info)
	-- local differ_value = CommonStruct.Attribute()
	-- local special_img_attr = self:GetSpecialImageAttrSum(cloak_info)
	-- local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().cloak_attr_add / 10000 or 0
	-- local zhibao_percent = ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()) and
	-- 				ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()).cloak_attr_add / 10000 or 0

	-- if 	cloak_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = cloak_next_grade_cfg.maxhp - cloak_grade_cfg.maxhp
	-- 	differ_value.gong_ji = cloak_next_grade_cfg.gongji - cloak_grade_cfg.gongji
	-- 	differ_value.fang_yu = cloak_next_grade_cfg.fangyu - cloak_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = cloak_next_grade_cfg.mingzhong - cloak_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = cloak_next_grade_cfg.shanbi - cloak_grade_cfg.shanbi
	-- 	differ_value.bao_ji = cloak_next_grade_cfg.baoji - cloak_grade_cfg.baoji
	-- 	differ_value.jian_ren = cloak_next_grade_cfg.jianren - cloak_grade_cfg.jianren
	-- end

	-- local temp_attr_per = cloak_info.grade_bless_val/cloak_grade_cfg.bless_val_limit

	attr.max_hp = (cloak_level_cfg.maxhp
				-- + star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp)
				-- + special_img_attr.max_hp)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (cloak_level_cfg.gongji
				-- + star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji)
				-- + special_img_attr.gong_ji)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (cloak_level_cfg.fangyu
				-- + star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu)
				-- + special_img_attr.fang_yu)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (cloak_level_cfg.mingzhong
					-- + star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * cloak_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong)
					-- + special_img_attr.ming_zhong)
					-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (cloak_level_cfg.shanbi
				-- + star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi)
				-- + special_img_attr.shan_bi)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (cloak_level_cfg.baoji
				-- + star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji)
				-- + special_img_attr.bao_ji)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (cloak_level_cfg.jianren
				-- + star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * cloak_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren)
				-- + special_img_attr.jian_ren)
				-- + (medal_percent + zhibao_percent) * (cloak_level_cfg.jianren + star_cfg.jianren)

	-- attr.per_pofang = equip_attr.per_pofang
	-- attr.per_mianshang = equip_attr.per_mianshang

	return attr
end

function CloakData:IsShowZizhiRedPoint()
	local level_cfg = self:GetCloakLevelCfg(self.cloak_info.cloak_level)
	if level_cfg == nil then return false end
	local count_limit = level_cfg.shuxingdan_limit
	if self.cloak_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.cloak_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(CloakDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function CloakData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.cloak_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.cloak_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == CloakDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function CloakData:CanHuanhuaUpgrade()
	if self.cloak_info.grade == nil or self.cloak_info.grade <= 0 then
		return nil
	end

	local special_img_grade_list = self.cloak_info.special_img_grade_list
	if special_img_grade_list == nil then
		return nil
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id) and 
			special_img_grade_list[j.special_img_id] == j.grade and
			j.grade < self:GetMaxSpecialImageCfgById(j.special_img_id) then
			return j.special_img_id
		end
	end

	return nil
end

function CloakData:CanSkillUpLevelList()
	local list = {}
	if self.cloak_info.grade == nil or self.cloak_info.grade <= 0 then return list end
	if self.cloak_info.skill_level_list == nil then
		return list
	end

	for i, j in pairs(self:GetCloakSkillCfg()) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.cloak_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.cloak_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function CloakData:GetMaxSpecialImageCfgById(id)
	if id == nil then return 0 end

	local count = 0
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if id == v.special_img_id then
			count = count + 1
		end
	end

	return count
end

function CloakData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function CloakData:GetCloakGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetCloakImageCfg()
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

function CloakData:IsActiviteCloak()
	return self.cloak_info.cloak_level > 0
end

function CloakData:GetCloakModelResCfg(sex, prof)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = sex or vo.sex
	local prof = prof or vo.prof
	if sex == 0 then
		return tonumber("100"..PROF_ROLE[prof])
	else
		return tonumber("110"..PROF_ROLE[prof])
	end
end

function CloakData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function CloakData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.cloak_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function CloakData:CalEquipRemind(equip_index)
	if nil == self.cloak_info or nil == next(self.cloak_info) then
		return 0
	end

	local equip_level = self.cloak_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

function CloakData:GetRemind()
	if self:IsShowZizhiRedPoint() then
		return 1
	end

	if self.cloak_info.cloak_level >= self:GetMaxCloakLevel() then
		return 0
	end

	for k,v in pairs(self.cloak_cfg.up_level_stuff) do
		local num = ItemData.Instance:GetItemNumInBagById(v.up_level_item_id)
		if num > 0 then return 1 end
	end
	return 0
end

function CloakData:IsOpenEquip()
	if nil == self.cloak_info or nil == next(self.cloak_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.cloak_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function CloakData:GetNextPercentAttrCfg(equip_index)
	if nil == self.cloak_info or nil == next(self.cloak_info) then
		return
	end

	local equip_level = self.cloak_info.equip_level_list[equip_index] or 0
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

function CloakData:GetEquipMinLevel()
	if nil == self.cloak_info or nil == next(self.cloak_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.cloak_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function CloakData:IsActiveEquipSkill()
	if nil == self.cloak_info or nil == next(self.cloak_info) then
		return false
	end
	return self.cloak_info.equip_skill_level > 0
end

function CloakData:GetUsedImageid()
	return self.cloak_info.used_imageid or 0
end