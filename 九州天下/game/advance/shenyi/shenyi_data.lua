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

function ShenyiData:__init()
	if ShenyiData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	ShenyiData.Instance = self

	-- self.level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shenyi_auto").level, "shenyi_level")
	-- self.grade_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shenyi_auto").grade, "grade")
	-- self.special_img_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img, "image_id")
	-- self.special_img_upgrade_list = ListToMapList(ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_image_upgrade, "special_img_id")
	-- self.skill_cfg = ConfigManager.Instance:GetAutoConfig("shenyi_auto").shenyi_skill
	-- self.image_list_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shenyi_auto").image_list, "image_id")
	-- self.shenyi_equip_list = ConfigManager.Instance:GetAutoConfig("shenyi_auto").shenyi_equip
	-- self.up_start_stuff_cfg = ConfigManager.Instance:GetAutoConfig("shenyi_auto").up_start_stuff
	-- self.up_start_exp_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("shenyi_auto").up_start_exp, "star_level")
	-- self.skill_id_cfg = ConfigManager.Instance:GetAutoConfig("shenyi_auto").skill_id
	-- self.equip_info_cfg = ListToMap(self.shenyi_cfg.shenyi_equip_info, "equip_idx", "equip_level")
	self.shenyi_info = {}
	self.last_bless = 0
	self.last_grade = 0

	RemindManager.Instance:Register(RemindName.AdvanceMantle, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function ShenyiData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceMantle)
	if ShenyiData.Instance then
		ShenyiData.Instance = nil
	end
	self.shenyi_info = {}
end

function ShenyiData:GetShenYiCfg()
	if not self.shenyi_cfg then
		self.shenyi_cfg = ConfigManager.Instance:GetAutoConfig("shenyi_auto")
	end
	return self.shenyi_cfg
end

function ShenyiData:GetLevelCfg()
	if not self.level_cfg then
		self.level_cfg = ListToMap(self:GetShenYiCfg().level, "shenyi_level")
	end
	return self.level_cfg
end

function ShenyiData:GetGradeInfoCfg()
	if not self.grade_cfg then
		self.grade_cfg = ListToMap(self:GetShenYiCfg().grade, "grade")
	end
	return self.grade_cfg
end

function ShenyiData:GetSpecialCfg()
	if not self.special_img_cfg then
		self.special_img_cfg = ListToMap(self:GetShenYiCfg().special_img, "image_id")
	end
	return self.special_img_cfg
end

function ShenyiData:GetSpecialUpgradeCfg()
	if not self.special_img_upgrade_list then
		self.special_img_upgrade_list = ListToMapList(self:GetShenYiCfg().special_image_upgrade, "special_img_id")
	end
	return self.special_img_upgrade_list
end

function ShenyiData:GetSkillCfg()
	if not self.skill_cfg then
		self.skill_cfg = self:GetShenYiCfg().shenyi_skill
	end
	return self.skill_cfg
end

function ShenyiData:GetImageListCfg()
	if not self.image_list_cfg then
		self.image_list_cfg = ListToMap(self:GetShenYiCfg().image_list, "image_id")
	end
	return self.image_list_cfg
end

function ShenyiData:GetEquipList()
	if not self.shenyi_equip_list then
		self.shenyi_equip_list = self:GetShenYiCfg().shenyi_equip
	end
	return self.shenyi_equip_list
end

function ShenyiData:GetUpStarCfg()
	if not self.up_start_stuff_cfg then
		self.up_start_stuff_cfg = self:GetShenYiCfg().up_start_stuff
	end
	return self.up_start_stuff_cfg
end

function ShenyiData:GetUpStarExpCfg()
	if not self.up_start_exp_cfg then
		self.up_start_exp_cfg = ListToMap(self:GetShenYiCfg().up_start_exp, "star_level")
	end
	return self.up_start_exp_cfg
end

function ShenyiData:GetsKILLIDCfg()
	if not self.skill_id_cfg then
		self.skill_id_cfg = self:GetShenYiCfg().skill_id
	end
	return self.skill_id_cfg
end

function ShenyiData:GetInfoCfg()
	if not self.equip_info_cfg then
		self.equip_info_cfg = ListToMap(self:GetShenYiCfg().shenyi_equip_info, "equip_idx", "equip_level")
	end
	return self.equip_info_cfg
end

function ShenyiData:SetShenyiInfo(protocol)
	-- self.shenyi_info.star_level = protocol.star_level
	self:SetLastInfo(self.shenyi_info.grade_bless_val, self.shenyi_info.grade)
	self.shenyi_info.shenyi_level = protocol.shenyi_level
	self.shenyi_info.grade = protocol.grade
	self.shenyi_info.grade_bless_val = protocol.grade_bless_val
	self.shenyi_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.shenyi_info.used_imageid = protocol.used_imageid
	self.shenyi_info.shuxingdan_count = protocol.shuxingdan_count
	self.shenyi_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.shenyi_info.active_image_flag = protocol.active_image_flag
	self.shenyi_info.active_special_image_flag = protocol.active_special_image_flag
	self.shenyi_info.active_special_image_list = bit:d2b(self.shenyi_info.active_special_image_flag)

	self.shenyi_info.show_grade = math.ceil(protocol.grade / 10)
	self.shenyi_info.star_level = protocol.grade % 10

	-- self.shenyi_info.equip_info_list = protocol.equip_info_list
	self.shenyi_info.skill_level_list = protocol.skill_level_list
	self.shenyi_info.special_img_grade_list = protocol.special_img_grade_list

	self.shenyi_info.equip_skill_level = protocol.equip_skill_level
	self.shenyi_info.equip_level_list = protocol.equip_level_list
end

function ShenyiData:GetShenyiInfo()
	return self.shenyi_info
end

function ShenyiData:GetCurShenYiCfg(grade)
	if not grade then return end
	local cfg = self:GetGradeCfg()
	return cfg[grade]
end

--形象进阶+幻化的战力
function ShenyiData:GetShenYiPower()
	local cfg = self:GetCurShenYiCfg(self.shenyi_info.grade)
	local upgrade_power = CommonDataManager.GetCapabilityCalculation(cfg)
	local huanhua_power = 0
	for k,v in pairs(self.shenyi_info.active_special_image_list) do
		if v == 1 then
			local index = 32 - k
			local huanhua_cfg = self:GetSpecialImageUpgradeInfo(index)
			huanhua_power = huanhua_power + CommonDataManager.GetCapabilityCalculation(huanhua_cfg)
		end
	end
	return huanhua_power + upgrade_power
end

function ShenyiData:GetShenyiLevelCfg(shenyi_level)
	--local shenyi_config = ConfigManager.Instance:GetAutoConfig("shenyi_auto")
	if shenyi_level == nil then
		return nil
	end

	if shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_level = self:GetMaxShenyiLevelCfg()
	end

	return self:GetLevelCfg()[shenyi_level]
	--return shenyi_config.level[shenyi_level]
end

function ShenyiData:GetMaxShenyiLevelCfg()
	--return #ConfigManager.Instance:GetAutoConfig("shenyi_auto").level
	return #self:GetLevelCfg()
end

function ShenyiData:GetShenyiShowGradeCfg(shenyi_grade)
	-- local shenyi_config = ConfigManager.Instance:GetAutoConfig("shenyi_auto")
	-- return shenyi_config.grade[shenyi_grade * 10]
	if shenyi_grade ~= nil then
		return self:GetGradeCfg()[shenyi_grade * 10]
	end

	return nil
end

function ShenyiData:GetShenyiGradeCfg(shenyi_grade)
	-- local shenyi_config = ConfigManager.Instance:GetAutoConfig("shenyi_auto")
	-- return shenyi_config.grade[shenyi_grade]

	if shenyi_grade ~= nil then
		return self:GetGradeCfg()[shenyi_grade]
	end

	return nil
end

function ShenyiData:GetSpecialImageCfg(image_id)
	-- local shenyi_config = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img
	-- return shenyi_config[image_id]

	if image_id ~= nil then
		return self:GetSpecialCfg()[image_id]
	end

	return nil
end

function ShenyiData:GetSpecialImagesCfg()
	return ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img
end

function ShenyiData:GetMaxGrade()
	--return #ConfigManager.Instance:GetAutoConfig("shenyi_auto").grade / 10
	return #self:GetGradeCfg() / 10
end

function ShenyiData:GetGradeCfg()
	--return ConfigManager.Instance:GetAutoConfig("shenyi_auto").grade
	return self:GetGradeInfoCfg()
end

function ShenyiData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img
	return #self:GetSpecialCfg()
end

function ShenyiData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.shenyi_info.active_special_image_list or {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	for k,v in pairs(self:GetSpecialCfg()) do
		local index = 32 - k
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

function ShenyiData:GetShenyiIsActive(image_id)
	return self.shenyi_info.active_special_image_list[32 - image_id] ~= 0
end

function ShenyiData:CheckIsHuanHuaItem(item_id)
	local is_item = false
	if item_id == nil or self:GetSpecialCfg() == nil then
		return
	end

	for k,v in pairs(self:GetSpecialCfg()) do
		if v ~= nil and v.item_id == item_id then
			is_item = true
			break
		end
	end

	return is_item
end

function ShenyiData:GetSpecialImageUpgradeCfg()
	return ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_image_upgrade
end

function ShenyiData:GetSpecialImageUpgradeList(special_img_id)
	if special_img_id ~= nil then
		return self:GetSpecialUpgradeCfg()[special_img_id]
	end

	return nil
end

function ShenyiData:GetShenyiSkillCfg()
	--return ConfigManager.Instance:GetAutoConfig("shenyi_auto").shenyi_skill
	return self:GetSkillCfg()
end

function ShenyiData:GetShenyiImageCfg(image_id)
	--return ConfigManager.Instance:GetAutoConfig("shenyi_auto").image_list
	if image_id ~= nil then
		return self:GetImageListCfg()[image_id]
	end

	return 
end

function ShenyiData:GetShenyiEquipCfg()
	--return ConfigManager.Instance:GetAutoConfig("shenyi_auto").shenyi_equip
	return self:GetEquipList()
end

-- function ShenyiData:GetShenyiEquipExpCfg()
-- 	return ConfigManager.Instance:GetAutoConfig("shenyi_auto").equip_exp
-- end

function ShenyiData:GetShenyiEquipRandAttr()
	return ConfigManager.Instance:GetAutoConfig("shenyi_auto").equip_attr_range
end

function ShenyiData:GetShenyiUpStarPropCfg()
	--return ConfigManager.Instance:GetAutoConfig("shenyi_auto").up_start_stuff
	return self:GetUpStarCfg()
end

function ShenyiData:GetShenyiUpStarCfg(star_level)
	--return ConfigManager.Instance:GetAutoConfig("shenyi_auto").up_start_exp
	if star_level ~= nil then
		return self:GetUpStarExpCfg()[star_level]
	end

	return nil
end

function ShenyiData:GetShenyiMaxUpStarLevel()
	--return #ConfigManager.Instance:GetAutoConfig("shenyi_auto").up_start_exp
	return #self:GetUpStarExpCfg()
end

function ShenyiData:GetShenyiSkillId()
	--return ConfigManager.Instance:GetAutoConfig("shenyi_auto").skill_id
	return self:GetsKILLIDCfg()
end

function ShenyiData:IsShenyiStuff(item_id)
	for k,v in pairs(self:GetUpStarCfg()) do
		if item_id == v.up_star_item_id then
			return true
		end
	end
	return false
end

-- 获取当前点击坐骑特殊形象的配置
function ShenyiData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade
	if grade == nil and self.shenyi_info ~= nil and self.shenyi_info.special_img_grade_list ~= nil then
		grade = self.shenyi_info.special_img_grade_list[index] or 0
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

-- 获取幻化最大等级
function ShenyiData:GetSpecialImageMaxUpLevelById(image_id)
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

-- 获取形象列表的配置
function ShenyiData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	-- for k, v in pairs(self:GetShenyiImageCfg()) do
	-- 	if v.image_id == index then
	-- 		return v
	-- 	end
	-- end

	return self:GetShenyiImageCfg(index)
end

-- 获取当前点击坐骑技能的配置
function ShenyiData:GetShenyiSkillCfgById(skill_idx, level, shenyi_info)
	local skill_id_list = self:GetShenyiSkillId()
	local skill_id = 0
	for k,v in pairs(skill_id_list) do
		if v.skill_id % 10 == skill_idx + 1 then
			skill_id = v.skill_id
			break
		end
	end
	local level = level or SkillData.Instance:GetSkillInfoById(skill_id) and SkillData.Instance:GetSkillInfoById(skill_id).level or 0

	for k, v in pairs(self:GetShenyiSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

function ShenyiData:GetShenyiSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetShenyiSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end

-- 获取特殊形象总增加的属性丹和成长丹数量
function ShenyiData:GetSpecialImageAttrSum(shenyi_info)
	shenyi_info = shenyi_info or self.shenyi_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = shenyi_info.active_special_image_flag
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
	local item_cfg = nil
	local equip_cfg = nil
	local equip_level = nil
	for i = 0, 3 do
		item_cfg = ItemData.Instance:GetItemConfig(shenyi_info.equip_info_list[i].equip_id)
		if item_cfg ~= nil then
			equip_cfg = self:GetShenyiEquipCfg()[i + 1]
			equip_level = shenyi_info.equip_info_list[i].level
			equip_id_attr_list = shenyi_info.equip_info_list[i].attr_list
			attr_list.gong_ji = attr_list.gong_ji + equip_cfg.gongji * equip_level * item_cfg.color
			attr_list.fang_yu = attr_list.fang_yu + equip_cfg.fangyu * equip_level * item_cfg.color
			attr_list.max_hp = attr_list.max_hp + equip_cfg.maxhp * equip_level * item_cfg.color
			attr_list.ming_zhong = attr_list.ming_zhong + equip_cfg.mingzhong * equip_level * item_cfg.color
			attr_list.shan_bi = attr_list.shan_bi + equip_cfg.shanbi * equip_level * item_cfg.color
			attr_list.bao_ji = attr_list.bao_ji + equip_cfg.baoji * equip_level * item_cfg.color
			attr_list.jian_ren = attr_list.jian_ren + equip_cfg.jianren * equip_level * item_cfg.color
			if i == 0 then
				attr_list.gong_ji = attr_list.gong_ji + equip_id_attr_list[0]
				attr_list.fang_yu = attr_list.fang_yu + equip_id_attr_list[1]
				attr_list.max_hp = attr_list.max_hp + equip_id_attr_list[2]
			elseif i ==1 then
				attr_list.gong_ji = attr_list.gong_ji + equip_id_attr_list[0]
				attr_list.per_pofang = attr_list.per_pofang + equip_id_attr_list[1]
			elseif i == 2 then
				attr_list.fang_yu = attr_list.fang_yu + equip_id_attr_list[0]
				attr_list.per_mianshang = attr_list.per_mianshang + equip_id_attr_list[1]
			else
				attr_list.max_hp = attr_list.max_hp + equip_id_attr_list[0]
				attr_list.per_mianshang = attr_list.per_mianshang + equip_id_attr_list[1]
			end
		end
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
	local shenyi_up_star_cfg = self:GetShenyiUpStarCfgByLevel(shenyi_info.grade)
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
	if shenyi_info.grade == nil or shenyi_info.grade <= 0 then
		return 0
	end
	if shenyi_info.shenyi_level >= self:GetMaxShenyiLevelCfg() then
		shenyi_info.shenyi_level = self:GetMaxShenyiLevelCfg()
	end
	local shenyi_level_cfg = self:GetShenyiLevelCfg(shenyi_info.shenyi_level)
	-- local shenyi_grade_cfg = self:GetShenyiGradeCfg(shenyi_info.grade)
	local level = is_advancesucce and math.floor(shenyi_info.grade / 10) * 10 or shenyi_info.grade
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
	local attr = CommonStruct.Attribute()
	attr.max_hp = (shenyi_level_cfg.maxhp + shenyi_up_star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * shenyi_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp + dan_attr.max_hp + special_img_attr.max_hp) + (medal_percent) * (shenyi_level_cfg.maxhp + shenyi_up_star_cfg.maxhp)
	attr.gong_ji = (shenyi_level_cfg.gongji + shenyi_up_star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * shenyi_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji + dan_attr.gong_ji + special_img_attr.gong_ji) + (medal_percent) * (shenyi_level_cfg.gongji + shenyi_up_star_cfg.gongji)
	attr.fang_yu = (shenyi_level_cfg.fangyu + shenyi_up_star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per
				+ skill_attr.fang_yu + dan_attr.fang_yu + special_img_attr.fang_yu) + (medal_percent) * (shenyi_level_cfg.fangyu + shenyi_up_star_cfg.fangyu)
	attr.ming_zhong = (shenyi_level_cfg.mingzhong + shenyi_up_star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per
					+ skill_attr.ming_zhong + dan_attr.ming_zhong + special_img_attr.ming_zhong) + (medal_percent) * (shenyi_level_cfg.mingzhong + shenyi_up_star_cfg.mingzhong)
	attr.shan_bi = (shenyi_level_cfg.shanbi + shenyi_up_star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per
				+ skill_attr.shan_bi + dan_attr.shan_bi + special_img_attr.shan_bi) + (medal_percent) * (shenyi_level_cfg.shanbi + shenyi_up_star_cfg.shanbi)
	attr.bao_ji = (shenyi_level_cfg.baoji + shenyi_up_star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per
				+ skill_attr.bao_ji + dan_attr.bao_ji + special_img_attr.bao_ji) + (medal_percent) * (shenyi_level_cfg.baoji + shenyi_up_star_cfg.baoji)
	attr.jian_ren = (shenyi_level_cfg.jianren + shenyi_up_star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per
				+ skill_attr.jian_ren + dan_attr.jian_ren + special_img_attr.jian_ren) + (medal_percent) * (shenyi_level_cfg.jianren + shenyi_up_star_cfg.jianren)
	-- attr.per_pofang = equip_attr.per_pofang
	-- attr.per_mianshang = equip_attr.per_mianshang

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
			self.shenyi_info.special_img_grade_list[j.special_img_id] < self:GetMaxSpecialImageCfgById(j.special_img_id)then
			list[j.special_img_id] = j.special_img_id
		end
	end

	return list
end

function ShenyiData:CanSkillUpLevelList()
	local list = {}
	if self.shenyi_info.grade == nil or self.shenyi_info.grade <= 0 then return list end

	for i, j in pairs(self:GetShenyiSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.shenyi_info.show_grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end

	return list
end

function ShenyiData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetShenyiSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function ShenyiData:GetMaxSpecialImageCfgById(id)
	-- local list = {}
	-- if id == nil then return list end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if id == v.special_img_id then
	-- 		list[v.grade] = v
	-- 	end
	-- end
	-- return #list

	local count = 0
	if id == nil then return count end
	local cfg = self:GetSpecialImageUpgradeList(id)
	if cfg ~= nil then
		count = #cfg - 1
	end

	return count
end

function ShenyiData:GetShenyiUpStarCfgByLevel(level)
	if nil == level then return end

	-- for k, v in pairs(self:GetShenyiUpStarCfg()) do
	-- 	if v.star_level == level then
	-- 		return v
	-- 	end
	-- end

	return self:GetShenyiUpStarCfg(level)
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
	local image_list = self:GetShenyiImageCfg(used_imageid)
	if not image_list then return 0 end
	--if not image_list[used_imageid] then return 0 end

	local show_grade = image_list.show_grade
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
	local need_exp = self:GetShenyiUpStarCfgByLevel(self.shenyi_info.grade).up_star_level_exp
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
	-- if grade == self.shenyi_info.grade then
	-- 	if self.shenyi_info.used_imageid > 1000 then
	-- 		return true
	-- 	end
	-- end
	return false
end

function ShenyiData:GetShowShenyiRes(grade)
	local grade = grade
	local shenyi_grade_cfg = self:GetShenyiGradeCfg(grade)
	local image_cfg = nil
	if shenyi_grade_cfg then
		image_cfg = self:GetShenyiImageCfg(shenyi_grade_cfg.image_id)
	end
	if self.shenyi_info.used_imageid < 1000 then
		if image_cfg then
			return image_cfg.res_id
		end
		return -1
	end
	if grade == self.shenyi_info.grade then
		return self:GetSpecialImageCfg(self.shenyi_info.used_imageid - 1000).res_id
	else
		if image_cfg then
			return image_cfg.res_id
		end
		return -1
	end
end

function ShenyiData:GetColorName(grade)
	local image_id = self:GetShenyiGradeCfg(grade).image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local shenyi_cfg = self:GetShenyiImageCfg(image_id)
	local str = shenyi_cfg ~= nil and shenyi_cfg.image_name or ""
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">".. str .."</color>"
	return name_str
end

function ShenyiData:GetShenyiGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetShenyiImageCfg(used_imageid)
	--if not image_list then return 0 end
	if not image_list then 
		--print_error("披风配置没有image_id:", used_imageid) 
		return 0 
	end

	local show_grade = image_list.show_grade
	for k, v in pairs(self:GetGradeCfg()) do
		if v.show_grade == show_grade then
			return v.show_grade
		end
	end
	return 0
end

function ShenyiData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function ShenyiData:GetLastGrade()
	return self.last_grade
end

function ShenyiData:ChangeShowInfo()
	self.show_bless = self.shenyi_info.grade_bless_val
end

function ShenyiData:GetShowBless()
	return self.show_bless or self.last_bless
end

function ShenyiData:CanJinjie()
	if self.shenyi_info.grade == nil or self.shenyi_info.grade <= 0 then return false end
	local cfg = self:GetShenyiGradeCfg(self.shenyi_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.shenyi_info.grade < #self:GetGradeCfg() then
			return true
		end
	end
	return false
end

function ShenyiData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("shenyi_jinjie") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or next(self:CanSkillUpLevelList()) ~= nil or self:CanJinjie() or self:CalEquipBtnRemind() or AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.MANTLE)) then
		return 1
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

-- 计算装备按钮的红点
function ShenyiData:CalEquipBtnRemind()
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

function ShenyiData:GetOhterCfg()
	return self:GetShenYiCfg().other[1]
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

-- 获得已升级装备战力
function ShenyiData:GetFootEquipAttrSum(foot_info)
	foot_info = foot_info or self.shenyi_info
	local attr_list = CommonStruct.Attribute()
	if nil == foot_info.equip_level_list then return attr_list end
	for k, v in pairs(foot_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

function ShenyiData:GetEquipInfoCfg(equip_index, level)
	if nil == self:GetInfoCfg()[equip_index] then
		return
	end
	return self:GetInfoCfg()[equip_index][level]
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

function ShenyiData:GetFootGradeCfg(foot_grade)
	return self:GetShenYiCfg().grade[foot_grade]
end

function ShenyiData:GetFootImageCfg()
	return self:GetShenYiCfg().image_list
end

function ShenyiData:IsActiveEquipSkill()
	if nil == self.shenyi_info or nil == next(self.shenyi_info) then
		return false
	end
	return self.shenyi_info.equip_skill_level > 0
end

function ShenyiData:GetShengongInfo()
	return self.shenyi_info
end
