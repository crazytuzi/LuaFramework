ShengongData = ShengongData or BaseClass()

ShengongDanId = {
		ChengZhangDanId = 22116,
		ZiZhiDanId = 22111,
}

ShengongShuXingDanCfgType = {
		Type = 8
}

ShengongDataEquipId = {
	16300, 16310, 16320, 16330
}

function ShengongData:__init()
	if ShengongData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	ShengongData.Instance = self
    
    self.shengong_cfg = nil 
	self.level_cfg = nil
	self.grade_cfg = nil
	self.special_img_cfg = nil
	self.special_img_upgrade_list = nil
	self.skill_cfg = nil
	self.image_list_cfg = nil
	self.shengong_equip_list = nil
	self.up_start_stuff_cfg = nil
	self.up_start_exp_cfg = nil
	self.skill_id_cfg = nil
	self.foot_cfg = nil
	self.equip_info_cfg = nil
	self.shengong_info = {}

	RemindManager.Instance:Register(RemindName.AdvanceFoot, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function ShengongData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceFoot)
	if ShengongData.Instance then
		ShengongData.Instance = nil
	end
	self.shengong_info = {}
	self.last_bless = 0
	self.last_grade = 0
end

function ShengongData:SetShengongInfo(protocol)
	-- self.shengong_info.star_level = protocol.star_level
	self:SetLastInfo(self.shengong_info.grade_bless_val, self.shengong_info.grade)
	self.shengong_info.shengong_level = protocol.shengong_level
	self.shengong_info.grade = protocol.grade
	self.shengong_info.grade_bless_val = protocol.grade_bless_val
	self.shengong_info.used_imageid = protocol.used_imageid
	self.shengong_info.shuxingdan_count = protocol.shuxingdan_count
	self.shengong_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.shengong_info.active_image_flag = protocol.active_image_flag
	self.shengong_info.active_special_image_flag = protocol.active_special_image_flag
	self.shengong_info.active_special_image_list = bit:d2b(self.shengong_info.active_special_image_flag)
	self.shengong_info.clear_upgrade_time = protocol.clear_upgrade_time

	self.shengong_info.show_grade = math.ceil(protocol.grade / 10)
	self.shengong_info.star_level = protocol.grade % 10
	
	-- self.shengong_info.equip_info_list = protocol.equip_info_list
	self.shengong_info.skill_level_list = protocol.skill_level_list
	self.shengong_info.special_img_grade_list = protocol.special_img_grade_list

	self.shengong_info.equip_skill_level = protocol.equip_skill_level
	self.shengong_info.equip_level_list = protocol.equip_level_list
end

function ShengongData:GetShenGongCfg()
    if not self.shengong_cfg then
		self.shengong_cfg = ConfigManager.Instance:GetAutoConfig("shengong_auto")
	end
	return self.shengong_cfg	
end

function ShengongData:GetShengongInfo()
	return self.shengong_info
end

function ShengongData:GetCurShenGongCfg(grade)
	if not grade then return end
	local cfg = self:GetGradeCfg()
	return cfg[grade]
end

--形象进阶+幻化的战力
function ShengongData:GetShenGongPower()
	local cfg = self:GetCurShenGongCfg(self.shengong_info.grade)
	local upgrade_power = CommonDataManager.GetCapabilityCalculation(cfg or {})
	local huanhua_power = 0
	for k,v in pairs(self.shengong_info.active_special_image_list) do
		if v == 1 then
			local index = 32 - k
			local huanhua_cfg = self:GetSpecialImageUpgradeInfo(index)
			huanhua_power = huanhua_power + CommonDataManager.GetCapabilityCalculation(huanhua_cfg)
		end
	end
	return huanhua_power + upgrade_power
end

function ShengongData:GetShengongLevelCfg(shengong_level)
	--local shengong_config = ConfigManager.Instance:GetAutoConfig("shengong_auto")
	if shengong_level == nil then
		return nil
	end

	if shengong_level >= self:GetMaxShengongLevelCfg() then
		shengong_level = self:GetMaxShengongLevelCfg()
	end

    if not self.level_cfg then
    	self.level_cfg = ListToMap(self:GetShenGongCfg().level, "shengong_level")
    end 
	return self.level_cfg[shengong_level]
	--return shengong_config.level[shengong_level]
end

function ShengongData:GetMaxShengongLevelCfg()
	--return #ConfigManager.Instance:GetAutoConfig("shengong_auto").level
	if not self.level_cfg then
    	self.level_cfg = ListToMap(self:GetShenGongCfg().level, "shengong_level")
    end 
	return #self.level_cfg
end

function ShengongData:GetShengongShowGradeCfg(shengong_grade)
	--local shengong_config = ConfigManager.Instance:GetAutoConfig("shengong_auto")
	--return shengong_config.grade[shengong_grade * 10]
    if not self.grade_cfg then
    	self.grade_cfg =ListToMap(self:GetShenGongCfg().grade, "grade")
    end

	if shengong_grade ~= nil then
		return self.grade_cfg[shengong_grade * 10]
	end

	return nil
end

function ShengongData:GetShengongGradeCfg(shengong_grade)
	-- local shengong_config = ConfigManager.Instance:GetAutoConfig("shengong_auto")
	-- return shengong_config.grade[shengong_grade]
    if not self.grade_cfg then
    	self.grade_cfg =ListToMap(self:GetShenGongCfg().grade, "grade")
    end

	if shengong_grade ~= nil then
		return self.grade_cfg[shengong_grade]
	end

	return nil
end

function ShengongData:GetSpecialImagesCfg()
	return ConfigManager.Instance:GetAutoConfig("shengong_auto").special_img
end

function ShengongData:GetSpecialImageCfg(image_id)
	-- local shengong_config = ConfigManager.Instance:GetAutoConfig("shengong_auto").special_img
	-- return shengong_config[image_id]
    if not self.special_img_cfg then
    	self.special_img_cfg = ListToMap(self:GetShenGongCfg().special_img, "image_id")
    end
	if image_id ~= nil then
		return self.special_img_cfg[image_id]
	end

	return nil
end

function ShengongData:GetMaxGrade()
	--return #ConfigManager.Instance:GetAutoConfig("shengong_auto").grade / 10
    if not self.grade_cfg then
    	self.grade_cfg =ListToMap(self:GetShenGongCfg().grade, "grade")
    end
	return #self.grade_cfg / 10
end

function ShengongData:GetGradeCfg()
	--return ConfigManager.Instance:GetAutoConfig("shengong_auto").grade
    if not self.grade_cfg then
    	self.grade_cfg =ListToMap(self:GetShenGongCfg().grade, "grade")
    end
	return self.grade_cfg
end

function ShengongData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("shengong_auto").special_img
    if not self.special_img_cfg then
    	self.special_img_cfg = ListToMap(self:GetShenGongCfg().special_img, "image_id")
    end
	return #self.special_img_cfg
end

function ShengongData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.shengong_info.active_special_image_list or {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
    if not self.special_img_cfg then
    	self.special_img_cfg = ListToMap(self:GetShenGongCfg().special_img, "image_id")
    end

	for k,v in pairs(self.special_img_cfg) do
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

function ShengongData:GetShengongIsActive(image_id)
	return self.shengong_info.active_special_image_list[32 - image_id] ~= 0
end

function ShengongData:CheckIsHuanHuaItem(item_id)
    if not self.special_img_cfg then
    	self.special_img_cfg = ListToMap(self:GetShenGongCfg().special_img, "image_id")
    end
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

function ShengongData:GetSpecialImageUpgradeCfg()
	return ConfigManager.Instance:GetAutoConfig("shengong_auto").special_image_upgrade
end

function ShengongData:GetSpecialImageUpgradeList(special_img_id)
    if not self.special_img_upgrade_list then
    	self.special_img_upgrade_list = ListToMapList(self:GetShenGongCfg().special_image_upgrade, "special_img_id")
    end

	if special_img_id ~= nil then
		return self.special_img_upgrade_list[special_img_id]
	end

	return nil
end

function ShengongData:GetShengongSkillCfg()
	--return ConfigManager.Instance:GetAutoConfig("shengong_auto").shengong_skill
	if not self.skill_cfg then
		self.skill_cfg = self:GetShenGongCfg().shengong_skill
	end
	return self.skill_cfg
end

function ShengongData:GetShengongImageCfg(image_id)
	--return ConfigManager.Instance:GetAutoConfig("shengong_auto").image_list
	if not self.image_list_cfg then
		self.image_list_cfg =  ListToMap(self:GetShenGongCfg().image_list, "image_id")
	end
	if image_id ~= nil then
		return self.image_list_cfg[image_id]
	end

	return nil
end

function ShengongData:GetShengongEquipCfg()
	--return ConfigManager.Instance:GetAutoConfig("shengong_auto").shengong_equip
	if not self.shengong_equip_list then
		self.shengong_equip_list = self:GetShenGongCfg().shengong_equip
	end
	return self.shengong_equip_list
end

-- function ShengongData:GetShengongEquipExpCfg()
-- 	return ConfigManager.Instance:GetAutoConfig("shengong_auto").equip_exp
-- end

-- function ShengongData:GetShengongEquipRandAttr()
-- 	return ConfigManager.Instance:GetAutoConfig("shengong_auto").equip_attr_range
-- end

function ShengongData:GetShengongUpStarPropCfg()
	--return ConfigManager.Instance:GetAutoConfig("shengong_auto").up_start_stuff
	if not self.up_start_stuff_cfg then
		self.up_start_stuff_cfg = self:GetShenGongCfg().up_start_stuff
	end
	return self.up_start_stuff_cfg
end

function ShengongData:GetShengongUpStarCfg(star_level)
	--return ConfigManager.Instance:GetAutoConfig("shengong_auto").up_start_exp
    if not self.up_start_exp_cfg then
    	self.up_start_exp_cfg = ListToMap(self:GetShenGongCfg().up_start_exp, "star_level")
    end

	if star_level ~= nil then
		return self.up_start_exp_cfg[star_level]
	end

	return nil
end

-- function ShengongData:GetShengongMaxUpStarLevel()
-- 	return #ConfigManager.Instance:GetAutoConfig("shengong_auto").up_start_exp
-- end

function ShengongData:GetShengongSkillId()
	--return ConfigManager.Instance:GetAutoConfig("shengong_auto").skill_id
	if not self.skill_id_cfg then
		self.skill_id_cfg = self:GetShenGongCfg().skill_id
	end
	return self.skill_id_cfg
end

function ShengongData:IsShengongStuff(item_id)
	if not self.up_start_stuff_cfg then
		self.up_start_stuff_cfg = self:GetShenGongCfg().up_start_stuff
	end

	for k,v in pairs(self.up_start_stuff_cfg) do
		if item_id == v.up_star_item_id then
			return true
		end
	end
	return false
end


-- 获取当前点击坐骑特殊形象的配置
function ShengongData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade
	if grade == nil and self.shengong_info ~= nil and self.shengong_info.special_img_grade_list ~= nil then
		grade = self.shengong_info.special_img_grade_list[index] or 0
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
function ShengongData:GetSpecialImageMaxUpLevelById(image_id)
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
function ShengongData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	-- for k, v in pairs(self:GetShengongImageCfg()) do
	-- 	if v.image_id == index then
	-- 		return v
	-- 	end
	-- end

	return self:GetShengongImageCfg(index)
end


-- 获取当前点击坐骑技能的配置
function ShengongData:GetShengongSkillCfgById(skill_idx, level, shengong_info)
	local skill_id_list = self:GetShengongSkillId()
	local skill_id = 0
	for k,v in pairs(skill_id_list) do
		if v.skill_id % 10 == skill_idx + 1 then
			skill_id = v.skill_id
			break
		end
	end
	local level = level or SkillData.Instance:GetSkillInfoById(skill_id) and SkillData.Instance:GetSkillInfoById(skill_id).level or 0

	for k, v in pairs(self:GetShengongSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

function ShengongData:GetShengongSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetShengongSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end

-- 获取特殊形象总增加的属性
function ShengongData:GetSpecialImageAttrSum(shengong_info)
	shengong_info = shengong_info or self.shengong_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = shengong_info.active_special_image_flag
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
	if self:GetShengongGradeCfg(shengong_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetShengongGradeCfg(shengong_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetShengongGradeCfg(shengong_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetShengongGradeCfg(shengong_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function ShengongData:GetShengongSkillAttrSum(shengong_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetShengongSkillCfgById(i, nil, shengong_info)
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
function ShengongData:GetShengongEquipAttrSum(shengong_info)
	shengong_info = shengong_info or self.shengong_info
	local attr_list = CommonStruct.Attribute()
	local item_cfg = nil
	local equip_cfg = nil
	local equip_level = nil
	for i = 0, 2 do
		item_cfg = ItemData.Instance:GetItemConfig(shengong_info.equip_info_list[i].equip_id)
		if item_cfg ~= nil then
			equip_cfg = self:GetShengongEquipCfg()[i + 1]
			equip_level = shengong_info.equip_info_list[i].level
			equip_id_attr_list = shengong_info.equip_info_list[i].attr_list
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
function ShengongData:GetDanAttr(shengong_info)
	shengong_info = shengong_info or self.shengong_info
	if shengong_info.shengong_level and shengong_info.shengong_level >= self:GetMaxShengongLevelCfg() then
		shengong_info.shengong_level = self:GetMaxShengongLevelCfg()
	end
	local attr_list = CommonStruct.Attribute()
	local shengong_level_cfg = self:GetShengongLevelCfg(shengong_info.shengong_level)
	local shengong_up_star_cfg = self:GetShengongUpStarCfgByLevel(shengong_info.star_level)
	shengong_up_star_cfg = shengong_up_star_cfg or CommonStruct.AttributeNoUnderline()
	-- local shengong_grade_cfg = self:GetShengongGradeCfg(shengong_info.grade)
	-- attr_list.gong_ji = math.floor((shengong_level_cfg.gongji + shengong_up_star_cfg.gongji) * shengong_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((shengong_level_cfg.fangyu + shengong_up_star_cfg.fangyu) * shengong_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((shengong_level_cfg.maxhp + shengong_up_star_cfg.maxhp) * shengong_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((shengong_level_cfg.mingzhong + shengong_up_star_cfg.mingzhong) * shengong_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((shengong_level_cfg.shanbi + shengong_up_star_cfg.shanbi) * shengong_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((shengong_level_cfg.baoji + shengong_up_star_cfg.baoji) * shengong_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((shengong_level_cfg.jianren + shengong_up_star_cfg.jianren) * shengong_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == ShengongShuXingDanCfgType.Type and shengong_info and shengong_info.shuxingdan_count then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * shengong_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * shengong_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * shengong_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function ShengongData:GetShengongAttrSum(shengong_info, is_advancesucce)
	shengong_info = shengong_info or self:GetShengongInfo()
	if not shengong_info or not next(shengong_info) then return end

	if shengong_info.grade and shengong_info.grade <= 0 then
		return 0
	end
	if shengong_info.shengong_level and shengong_info.shengong_level >= self:GetMaxShengongLevelCfg() then
		shengong_info.shengong_level = self:GetMaxShengongLevelCfg()
	end
	local shengong_level_cfg = self:GetShengongLevelCfg(shengong_info.shengong_level)
	-- local shengong_grade_cfg = self:GetShengongGradeCfg(shengong_info.grade)
	local level = is_advancesucce and math.floor(shengong_info.grade / 10) * 10 or shengong_info.grade
	local shengong_up_star_cfg = self:GetShengongUpStarCfgByLevel(level) or CommonStruct.AttributeNoUnderline()

	-- local shengong_next_grade_cfg = self:GetShengongGradeCfg(shengong_info.grade + 1)
	local skill_attr = self:GetShengongSkillAttrSum(shengong_info)
	-- local equip_attr = self:GetShengongEquipAttrSum(shengong_info)
	local dan_attr = self:GetDanAttr(shengong_info)
	-- local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(shengong_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().magic_bow_attr_add / 10000 or 0
	-- if 	shengong_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = shengong_next_grade_cfg.maxhp - shengong_grade_cfg.maxhp
	-- 	differ_value.gong_ji = shengong_next_grade_cfg.gongji - shengong_grade_cfg.gongji
	-- 	differ_value.fang_yu = shengong_next_grade_cfg.fangyu - shengong_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = shengong_next_grade_cfg.mingzhong - shengong_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = shengong_next_grade_cfg.shanbi - shengong_grade_cfg.shanbi
	-- 	differ_value.bao_ji = shengong_next_grade_cfg.baoji - shengong_grade_cfg.baoji
	-- 	differ_value.jian_ren = shengong_next_grade_cfg.jianren - shengong_grade_cfg.jianren
	-- end

	-- local temp_attr_per = shengong_info.grade_bless_val/shengong_grade_cfg.bless_val_limit

	local attr = CommonStruct.Attribute()
	if shengong_level_cfg ~= nil then
		attr.max_hp = (shengong_level_cfg.maxhp + shengong_up_star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * shengong_grade_cfg.bless_addition /10000
					+ skill_attr.max_hp + dan_attr.max_hp + special_img_attr.max_hp) + (medal_percent) * (shengong_level_cfg.maxhp + shengong_up_star_cfg.maxhp)
		attr.gong_ji = (shengong_level_cfg.gongji + shengong_up_star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * shengong_grade_cfg.bless_addition /10000
					+ skill_attr.gong_ji + dan_attr.gong_ji + special_img_attr.gong_ji) + (medal_percent) * (shengong_level_cfg.gongji + shengong_up_star_cfg.gongji)
		attr.fang_yu = (shengong_level_cfg.fangyu + shengong_up_star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per
					+ skill_attr.fang_yu + dan_attr.fang_yu + special_img_attr.fang_yu) + (medal_percent) * (shengong_level_cfg.fangyu + shengong_up_star_cfg.fangyu)
		attr.ming_zhong = (shengong_level_cfg.mingzhong + shengong_up_star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per
						+ skill_attr.ming_zhong + dan_attr.ming_zhong + special_img_attr.ming_zhong) + (medal_percent) * (shengong_level_cfg.mingzhong + shengong_up_star_cfg.mingzhong)
		attr.shan_bi = (shengong_level_cfg.shanbi + shengong_up_star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per
					+ skill_attr.shan_bi + dan_attr.shan_bi + special_img_attr.shan_bi) + (medal_percent) * (shengong_level_cfg.shanbi + shengong_up_star_cfg.shanbi)
		attr.bao_ji = (shengong_level_cfg.baoji + shengong_up_star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per
					+ skill_attr.bao_ji + dan_attr.bao_ji + special_img_attr.bao_ji) + (medal_percent) * (shengong_level_cfg.baoji + shengong_up_star_cfg.baoji)
		attr.jian_ren = (shengong_level_cfg.jianren + shengong_up_star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per
					+ skill_attr.jian_ren + dan_attr.jian_ren + special_img_attr.jian_ren) + (medal_percent) * (shengong_level_cfg.jianren + shengong_up_star_cfg.jianren)
	end
	-- attr.per_pofang = equip_attr.per_pofang
	-- attr.per_mianshang = equip_attr.per_mianshang
	return attr
end

function ShengongData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.shengong_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.shengong_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(ShengongDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function ShengongData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.shengong_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.shengong_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == ShengongDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function ShengongData:GetOhterCfg()
	if not self.foot_cfg then
		self.foot_cfg = self:GetShenGongCfg()
	end
	return self.foot_cfg.other[1]
end

function ShengongData:CanHuanhuaUpgrade()
	local list = {}
	if self.shengong_info.grade == nil or self.shengong_info.grade <= 0 then return list end
	if self.shengong_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.shengong_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.shengong_info.special_img_grade_list[j.special_img_id] < self:GetMaxSpecialImageCfgById(j.special_img_id)then
			list[j.special_img_id] = j.special_img_id
		end
	end

	return list
end

function ShengongData:CanSkillUpLevelList()
	local list = {}
	if self.shengong_info.grade == nil or self.shengong_info.grade <= 0 then return list end

	for i, j in pairs(self:GetShengongSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.shengong_info.show_grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function ShengongData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetShengongSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function ShengongData:GetMaxSpecialImageCfgById(id)
	-- local list = {}
	-- if id == nil then return list end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if id == v.special_img_id then
	-- 		list[v.grade] = v
	-- 	end
	-- end
	-- return #list
	local count = 0
	if id == 0 then return coutn end

	local cfg = self:GetSpecialImageUpgradeList(id)
	if cfg ~= nil then
		count = #cfg - 1
	end

	return count
end

function ShengongData:GetShengongUpStarCfgByLevel(level)
	if nil == level then return end

	-- for k, v in pairs(self:GetShengongUpStarCfg()) do
	-- 	if v.star_level == level then
	-- 		return v
	-- 	end
	-- end

	return self:GetShengongUpStarCfg(level)
end

function ShengongData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function ShengongData:GetShengongGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetShengongImageCfg(used_imageid)
	if not image_list then return 0 end

	local show_grade = image_list.show_grade
	for k, v in pairs(self:GetGradeCfg()) do
		if v.show_grade == show_grade then
			return v.show_grade
		end
	end
	return 0
end

function ShengongData:GetIsRichMoneyUpLevel(item_id)
	local is_rich = true
	local exp_cfg = 1
	local need_exp = self:GetShengongUpStarCfgByLevel(self.shengong_info.star_level).up_star_level_exp
	local num = 0
	for k,v in pairs(self:GetShengongUpStarPropCfg()) do
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

function ShengongData:IsActiviteShengong()
	local active_flag = self.shengong_info and self.shengong_info.active_image_flag or {}
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function ShengongData:GetShowShengongRes(grade)
	local grade = grade
	local shengong_grade_cfg = self:GetShengongGradeCfg(grade)
	local image_cfg = nil
	if shengong_grade_cfg then
		image_cfg = self:GetShengongImageCfg(shengong_grade_cfg.image_id)
	end
	if self.shengong_info.used_imageid < 1000 then
		if image_cfg then
			return image_cfg.res_id
		end
		return -1
	end
	if grade == self.shengong_info.grade then
		return self:GetSpecialImageCfg(self.shengong_info.used_imageid - 1000).res_id
	else
		if image_cfg then
			return image_cfg.res_id
		end
		return -1
	end
end

function ShengongData:GetGoddessShengongRes()
	if self.shengong_info.used_imageid == 0 then
		return -1
	end
	if self.shengong_info.used_imageid > 1000 then
		return self:GetSpecialImageCfg(self.shengong_info.used_imageid - 1000).res_id
	end
	local image_cfg = self:GetShengongImageCfg(self.shengong_info.used_imageid)
	if image_cfg then
		return image_cfg.res_id
	end
	return -1
end

function ShengongData:IsShowCancelHuanhuaBtn(grade)
	-- if grade == self.shengong_info.grade then
	-- 	if self.shengong_info.used_imageid > 1000 then
	-- 		return true
	-- 	end
	-- end
	return false
end

function ShengongData:GetColorName(grade)
	local image_id = self:GetShengongGradeCfg(grade).image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local cfg = self:GetShengongImageCfg(image_id)
	local str = cfg ~= nil and cfg.image_name or ""
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">".. str .."</color>"
	return name_str
end

function ShengongData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function ShengongData:GetLastGrade()
	return self.last_grade
end

function ShengongData:ChangeShowInfo()
	self.show_bless = self.shengong_info.grade_bless_val
end

function ShengongData:GetShowBless()
	return self.show_bless or self.last_bless
end

function ShengongData:CanJinjie()
	if self.shengong_info.grade == nil or self.shengong_info.grade <= 0 then return false end
	local cfg = self:GetShengongGradeCfg(self.shengong_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.shengong_info.grade < #self.grade_cfg then
			return true
		end
	end
	return false
end

function ShengongData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("shengong_jinjie") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or next(self:CanSkillUpLevelList()) ~= nil or self:CanJinjie() or self:CalEquipBtnRemind() or AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.FOOT)) then
		return 1
	end
	return 0
end

function ShengongData:CalEquipRemind(equip_index)
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return 0
	end

	local equip_level = self.shengong_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

-- 计算装备按钮的红点
function ShengongData:CalEquipBtnRemind()
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

function ShengongData:IsOpenEquip()
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.shengong_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function ShengongData:GetNextPercentAttrCfg(equip_index)
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return
	end

	local equip_level = self.shengong_info.equip_level_list[equip_index] or 0
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
function ShengongData:GetFootEquipAttrSum(foot_info)
	foot_info = foot_info or self.shengong_info
	local attr_list = CommonStruct.Attribute()
	if nil == foot_info.equip_level_list then return attr_list end
	for k, v in pairs(foot_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

function ShengongData:GetEquipInfoCfg(equip_index, level)
	if not self.equip_info_cfg then
		self.equip_info_cfg = ListToMap(self:GetShenGongCfg().shengong_equip_info, "equip_idx", "equip_level")
	end
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function ShengongData:GetEquipMinLevel()
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.shengong_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function ShengongData:GetFootGradeCfg(foot_grade)
	if not self.foot_cfg then
		self.foot_cfg = self:GetShenGongCfg()
	end
	return self.foot_cfg.grade[foot_grade]
end

function ShengongData:GetFootImageCfg()
	if not self.foot_cfg then
		self.foot_cfg = self:GetShenGongCfg()
	end
	return self.foot_cfg.image_list
end

function ShengongData:IsActiveEquipSkill()
	if nil == self.shengong_info or nil == next(self.shengong_info) then
		return false
	end
	return self.shengong_info.equip_skill_level > 0
end