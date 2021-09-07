HeadwearData = HeadwearData or BaseClass()

HeadwearDanId = {
		ChengZhangDanId = 22115,
		ZiZhiDanId = 22116,
}

HeadwearShuXingDanCfgType = {
		Type = 15
}

HeadwearDataEquipId = {
	-- 16200, 16210, 16220, 16230
}

function HeadwearData:__init()
	if HeadwearData.Instance then
		print_error("[HeadwearData] Attemp to create a singleton twice !")
	end
	HeadwearData.Instance = self

	self.level_cfg = nil
	self.grade_cfg = nil
	self.special_img_cfg = nil
	self.special_image_upgrade_list = nil
	self.headwear_skill_cfg = nil
	self.image_list_cfg = nil
	self.headwear_equip_cfg = nil
	self.equip_exp_cfg = nil
	self.up_star_exp_cfg = nil
	self.skill_id_cfg = nil
	-- self.headwear_cfg = nil
	self.equip_info_cfg = nil

	self.headwear_info = {}
	self.last_bless = 0
	self.last_grade = 0

	RemindManager.Instance:Register(RemindName.DressUpHeadwear, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function HeadwearData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DressUpHeadwear)
	if HeadwearData.Instance then
		HeadwearData.Instance = nil
	end
	self.headwear_info = {}
end

function HeadwearData:SetHeadwearInfo(protocol)
	self:SetLastInfo(self.headwear_info.grade_bless_val, self.headwear_info.grade)
	self.headwear_info.headwear_level = protocol.headwear_level
	self.headwear_info.grade = protocol.grade
	self.headwear_info.grade_bless_val = protocol.grade_bless_val
	self.headwear_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.headwear_info.used_imageid = protocol.used_imageid
	self.headwear_info.shuxingdan_count = protocol.shuxingdan_count
	self.headwear_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.headwear_info.active_image_flag = protocol.active_image_flag
	self.headwear_info.active_special_image_flag = protocol.active_special_image_flag
	-- self.headwear_info.active_special_image_list = bit:d2b(self.headwear_info.active_special_image_flag)
	self.headwear_info.active_special_image_list = self.headwear_info.active_special_image_flag

	self.headwear_info.show_grade = math.ceil(protocol.grade / 10)
	self.headwear_info.star_level = protocol.grade % 10

	self.headwear_info.equip_info_list = protocol.equip_info_list
	self.headwear_info.skill_level_list = protocol.skill_level_list
	self.headwear_info.special_img_grade_list = protocol.special_img_grade_list

	self.headwear_info.equip_skill_level = protocol.equip_skill_level
	self.headwear_info.equip_level_list = protocol.equip_level_list
end

function HeadwearData:GetHeadwearInfo()
	return self.headwear_info
end

function HeadwearData:GetAllHeadwearCfg()
	return ConfigManager.Instance:GetAutoConfig("ugs_head_wear_auto") or {}
end

function HeadwearData:GetCurHeadwearCfg(grade)
	if not grade then return end
	local cfg = self:GetGradeCfg()
	return cfg[grade]
end

--形象进阶+幻化的战力
function HeadwearData:GetHeadwearPower()
	local cfg = self:GetCurHeadwearCfg(self.headwear_info.grade)
	local upgrade_power = CommonDataManager.GetCapabilityCalculation(cfg or {})
	local huanhua_power = 0
	for k,v in pairs(self.headwear_info.active_special_image_list) do
		if v == 1 then
			local index = k
			local huanhua_cfg = self:GetSpecialImageUpgradeInfo(index)
			huanhua_power = huanhua_power + CommonDataManager.GetCapabilityCalculation(huanhua_cfg)
		end
	end
	return huanhua_power + upgrade_power
end

function HeadwearData:GetAllHeadwearLevelCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.level_cfg then
		self.level_cfg = ListToMap(headwear_cfg.level, "headwear_level")
	end
	return self.level_cfg
end

function HeadwearData:GetHeadwearLevelCfg(headwear_level)
	--local headwear_config = ConfigManager.Instance:GetAutoConfig("headwear_auto")
	if headwear_level == nil then
		return nil
	end

	if headwear_level >= self:GetMaxHeadwearLevelCfg() then
		headwear_level = self:GetMaxHeadwearLevelCfg()
	end
	--return headwear_config.level[headwear_level]
	return self:GetAllHeadwearLevelCfg()[headwear_level]
end

function HeadwearData:GetMaxHeadwearLevelCfg()
	--return #ConfigManager.Instance:GetAutoConfig("headwear_auto").level
	return #self:GetAllHeadwearLevelCfg()
end

function HeadwearData:GetHeadwearShowGradeCfg(headwear_grade)
	--local headwear_config = ConfigManager.Instance:GetAutoConfig("headwear_auto")
	--return headwear_config.grade[headwear_grade * 10]
	if headwear_grade ~= nil then
		return self:GetGradeCfg()[headwear_grade * 10]
	end

	return nil
end

function HeadwearData:GetHeadwearGradeCfg(headwear_grade)
	-- local headwear_config = ConfigManager.Instance:GetAutoConfig("headwear_auto")
	-- return headwear_config.grade[headwear_grade]
	if headwear_grade ~= nil then
		return self:GetGradeCfg()[headwear_grade]
	end

	return nil
end

function HeadwearData:GetSpecialImagesCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.special_img_cfg then
		self.special_img_cfg = headwear_cfg.special_img
	end
	return self.special_img_cfg
end

function HeadwearData:GetSpecialImageCfg(image_id)
	-- local headwear_config = ConfigManager.Instance:GetAutoConfig("headwear_auto").special_img
	-- return headwear_config[image_id]
	if image_id ~= nil then
		return self:GetSpecialImagesCfg()[image_id]
	end

	return nil
end

function HeadwearData:GetMaxGrade()
	--return #ConfigManager.Instance:GetAutoConfig("headwear_auto").grade / 10
	return #self:GetGradeCfg() / 10
end

function HeadwearData:GetGradeCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.grade_cfg then
		self.grade_cfg = ListToMap(headwear_cfg.grade, "grade")
	end
	return self.grade_cfg
end

function HeadwearData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("headwear_auto").special_img
	return #self:GetSpecialImagesCfg()
end

function HeadwearData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.headwear_info.active_special_image_list or {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	for k,v in pairs(self:GetSpecialImagesCfg()) do
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

function HeadwearData:GetHeadwearIsActive(image_id)
	return self.headwear_info.active_special_image_list[image_id] ~= 0
end

function HeadwearData:CheckIsHuanHuaItem(item_id)
	local is_item = false
	if item_id == nil or self:GetSpecialImagesCfg() == nil then
		return
	end

	for k,v in pairs(self:GetSpecialImagesCfg()) do
		if v ~= nil and v.item_id == item_id then
			is_item = true
			break
		end
	end

	return is_item
end

function HeadwearData:GetSpecialImageUpgradeCfg()
	return ConfigManager.Instance:GetAutoConfig("ugs_head_wear_auto").special_image_upgrade
end

function HeadwearData:GetSpecialImageUpgradeListCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.special_image_upgrade_list then
		self.special_image_upgrade_list = ListToMapList(headwear_cfg.special_image_upgrade, "special_img_id")
	end
	return self.special_image_upgrade_list
end

function HeadwearData:GetSpecialImageUpgradeList(special_img_id)
	if special_img_id ~= nil then
		return self:GetSpecialImageUpgradeListCfg()[special_img_id]
	end
	return nil
end

function HeadwearData:GetHeadwearSkillCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.headwear_skill_cfg then
		self.headwear_skill_cfg = headwear_cfg.skill
	end
	return self.headwear_skill_cfg
end

function HeadwearData:GetImageListCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.image_list_cfg then
		self.image_list_cfg = ListToMap(headwear_cfg.image_list, "image_id")
	end
	return self.image_list_cfg
end

function HeadwearData:GetHeadwearImageCfg(image_id)
	--return ConfigManager.Instance:GetAutoConfig("headwear_auto").image_list
	if image_id ~= nil then
		return self:GetImageListCfg()[image_id]
	end

	return nil
end

function HeadwearData:GetSingleHeadwearImageCfg(image_id)
	return ConfigManager.Instance:GetAutoConfig("ugs_head_wear_auto").image_list[image_id]
end

function HeadwearData:GetHeadwearEquipCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.headwear_equip_cfg then
		self.headwear_equip_cfg = headwear_cfg.headwear_equip
	end
	return self.headwear_equip_cfg
end

function HeadwearData:GetHeadwearEquipExpCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.equip_exp_cfg then
		self.equip_exp_cfg = headwear_cfg.equip_exp
	end
	return self.equip_exp_cfg
end

function HeadwearData:GetHeadwearEquipRandAttr()
	return ConfigManager.Instance:GetAutoConfig("ugs_head_wear_auto").equip_attr_range
end

function HeadwearData:GetAllHeadwearUpStarExpCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.up_star_exp_cfg then
		self.up_star_exp_cfg = ListToMap(headwear_cfg.up_star_exp, "star_level")
	end
	return self.up_star_exp_cfg
end

function HeadwearData:GetHeadwearUpStarExpCfg(star_level)
	--return ConfigManager.Instance:GetAutoConfig("headwear_auto").up_star_exp
	if star_level ~= nil then
		return self:GetAllHeadwearUpStarExpCfg()[star_level]
	end
	return nil
end

function HeadwearData:GetHeadwearSkillId()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.skill_id_cfg then
		self.skill_id_cfg = headwear_cfg.skill_id
	end
	return self.skill_id_cfg
end

-- 获取当前点击坐骑特殊形象的配置
function HeadwearData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade
	if grade == nil and self.headwear_info ~= nil and self.headwear_info.special_img_grade_list ~= nil then
		grade = self.headwear_info.special_img_grade_list[index] or 0
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
	if index ~= nil and grade ~= nil then
		local cfg = self:GetSpecialImageUpgradeList(index)
		if cfg ~= nil then
			for k,v in pairs(cfg) do
				if v.grade == grade then
					return v
				end
			end
		end
	end

	return nil
end

-- 获取幻化最大等级
function HeadwearData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if v.special_img_id == image_id and v.grade > 0 then
	-- 		max_level = max_level + 1
	-- 	end
	-- end
	if image_id ~= nil then
		local cfg = self:GetSpecialImageUpgradeList(image_id)
		if cfg ~= nil then
			for k,v in pairs(cfg) do
				if v.grade > 0 then
					max_level = max_level + 1
				end
			end
		end
	end
	return max_level
end

-- 获取形象列表的配置
function HeadwearData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	-- for k, v in pairs(self:GetHeadwearImageCfg()) do
	-- 	if v.image_id == index then
	-- 		return v
	-- 	end
	-- end

	return self:GetHeadwearImageCfg(index)
end

function HeadwearData:GetImageIdByRes(res_id)
	-- for k,v in pairs(self:GetHeadwearImageCfg()) do
	-- 	if v.res_id == res_id then
	-- 		return v.image_id
	-- 	end
	-- end
	if res_id == 0 then return 0 end
	for k,v in pairs(self:GetImageListCfg()) do
		if v.res_id == res then
			return v.image_id
		end
	end

	return 0
end

-- 获取当前点击坐骑技能的配置
function HeadwearData:GetHeadwearSkillCfgById(skill_idx, level, headwear_info)
	local skill_id_list = self:GetHeadwearSkillId()
	local skill_id = 0
	for k,v in pairs(skill_id_list) do
		if v.skill_id % 10 == skill_idx + 1 then
			skill_id = v.skill_id
			break
		end
	end
	local level = level or SkillData.Instance:GetSkillInfoById(skill_id) and SkillData.Instance:GetSkillInfoById(skill_id).level or 0
	for k, v in pairs(self:GetHeadwearSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

function HeadwearData:GetHeadwearSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetHeadwearSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end

-- 获取特殊形象总增加的属性
function HeadwearData:GetSpecialImageAttrSum(headwear_info)
	headwear_info = headwear_info or self.headwear_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = headwear_info.active_special_image_flag
	if active_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	-- local bit_list = bit:d2b(active_flag)
	local special_chengzhangdan_count = 0
	local special_shuxingdan_count = 0
	local special_equip_limit = 0
	local special_img_upgrade_info = nil
	for k, v in pairs(active_flag) do
		if v == 1 then
			if self:GetSpecialImageUpgradeInfo(k) ~= nil then
				special_img_upgrade_info = self:GetSpecialImageUpgradeInfo(k)
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
	if self:GetHeadwearGradeCfg(headwear_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetHeadwearGradeCfg(headwear_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetHeadwearGradeCfg(headwear_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetHeadwearGradeCfg(headwear_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function HeadwearData:GetHeadwearSkillAttrSum(headwear_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetHeadwearSkillCfgById(i, nil, headwear_info)
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
function HeadwearData:GetHeadwearEquipAttrSum(headwear_info)
	headwear_info = headwear_info or self.headwear_info
	local attr_list = CommonStruct.Attribute()
	if nil == headwear_info.equip_level_list then return attr_list end
	for k, v in pairs(headwear_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function HeadwearData:GetDanAttr(headwear_info)
	headwear_info = headwear_info or self.headwear_info
	if headwear_info.headwear_level >= self:GetMaxHeadwearLevelCfg() then
		headwear_info.headwear_level = self:GetMaxHeadwearLevelCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local headwear_level_cfg = self:GetHeadwearLevelCfg(headwear_info.headwear_level)
	local headwear_grade_cfg = self:GetHeadwearGradeCfg(headwear_info.grade)
	if not headwear_grade_cfg then print_error("光环配置表为空", headwear_info.grade) return attr_list end
	-- attr_list.gong_ji = math.floor((headwear_level_cfg.gongji + headwear_grade_cfg.gongji) * headwear_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((headwear_level_cfg.fangyu + headwear_grade_cfg.fangyu) * headwear_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((headwear_level_cfg.maxhp + headwear_grade_cfg.maxhp) * headwear_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((headwear_level_cfg.mingzhong + headwear_grade_cfg.mingzhong) * headwear_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((headwear_level_cfg.shanbi + headwear_grade_cfg.shanbi) * headwear_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((headwear_level_cfg.baoji + headwear_grade_cfg.baoji) * headwear_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((headwear_level_cfg.jianren + headwear_grade_cfg.jianren) * headwear_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == HeadwearShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * headwear_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * headwear_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * headwear_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function HeadwearData:GetHeadwearAttrSum(headwear_info)
	headwear_info = headwear_info or self:GetHeadwearInfo()
	local attr = CommonStruct.Attribute()

	if nil == headwear_info.grade or headwear_info.grade <= 0 or headwear_info.headwear_level < 1 then
		return attr
	end

	if headwear_info.headwear_level >= self:GetMaxHeadwearLevelCfg() then
		headwear_info.headwear_level = self:GetMaxHeadwearLevelCfg()
	end
	local headwear_level_cfg = self:GetHeadwearLevelCfg(headwear_info.headwear_level)
	local headwear_grade_cfg = self:GetHeadwearGradeCfg(headwear_info.grade)
	local star_cfg = self:GetHeadwearStarLevelCfg(headwear_info.star_level)

	if not headwear_grade_cfg or not star_cfg then return attr end

	-- local headwear_next_grade_cfg = self:GetHeadwearGradeCfg(headwear_info.grade + 1)
	local skill_attr = self:GetHeadwearSkillAttrSum(headwear_info)
	-- local equip_attr = self:GetHeadwearEquipAttrSum(headwear_info)
	local dan_attr = self:GetDanAttr(headwear_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(headwear_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().headwear_attr_add / 10000 or 0

	-- if 	headwear_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = headwear_next_grade_cfg.maxhp - headwear_grade_cfg.maxhp
	-- 	differ_value.gong_ji = headwear_next_grade_cfg.gongji - headwear_grade_cfg.gongji
	-- 	differ_value.fang_yu = headwear_next_grade_cfg.fangyu - headwear_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = headwear_next_grade_cfg.mingzhong - headwear_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = headwear_next_grade_cfg.shanbi - headwear_grade_cfg.shanbi
	-- 	differ_value.bao_ji = headwear_next_grade_cfg.baoji - headwear_grade_cfg.baoji
	-- 	differ_value.jian_ren = headwear_next_grade_cfg.jianren - headwear_grade_cfg.jianren
	-- end

	-- local temp_attr_per = headwear_info.grade_bless_val/headwear_grade_cfg.bless_val_limit

	attr.max_hp = (headwear_level_cfg.maxhp
				+ star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * headwear_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (headwear_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (headwear_level_cfg.gongji
				+ star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * headwear_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (headwear_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (headwear_level_cfg.fangyu
				+ star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * headwear_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (headwear_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (headwear_level_cfg.mingzhong
					+ star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * headwear_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (headwear_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (headwear_level_cfg.shanbi
				+ star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * headwear_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (headwear_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (headwear_level_cfg.baoji
				+ star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * headwear_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (headwear_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (headwear_level_cfg.jianren
				+ star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * headwear_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (headwear_level_cfg.jianren + star_cfg.jianren)

	return attr
end

function HeadwearData:GetHeadwearStarLevelCfg(star_level)
	local star_level = star_level or self.headwear_info.star_level

	-- for k, v in pairs(self:GetHeadwearUpStarExpCfg()) do
	-- 	if v.star_level == star_level then
	-- 		return v
	-- 	end
	-- end
	if star_level ~= nil then
		return self:GetHeadwearUpStarExpCfg(star_level)
	end

	return nil
end

function HeadwearData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.headwear_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.headwear_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(HeadwearDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function HeadwearData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.headwear_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.headwear_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == HeadwearDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function HeadwearData:CanHuanhuaUpgrade()
	local list = {}
	if self.headwear_info.grade == nil or self.headwear_info.grade <= 0 then return list end
	if self.headwear_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.headwear_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.headwear_info.special_img_grade_list[j.special_img_id] < self:GetMaxSpecialImageCfgById(j.special_img_id)then
			list[j.special_img_id] = j.special_img_id
		end
	end

	return list
end

function HeadwearData:CanSkillUpLevelList()
	local list = {}
	if self.headwear_info.grade == nil or self.headwear_info.grade <= 0 then return list end

	for i, j in pairs(self:GetHeadwearSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.headwear_info.show_grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end

	return list
end

function HeadwearData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetHeadwearSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function HeadwearData:CanJinjie()
	if self.headwear_info.grade == nil or self.headwear_info.grade <= 0 then return false end
	local cfg = self:GetHeadwearGradeCfg(self.headwear_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.headwear_info.grade < #self:GetGradeCfg() then
			return true
		end
	end
	return false
end

function HeadwearData:GetAllEquipInfoCfg()
	local headwear_cfg = self:GetAllHeadwearCfg()
	if nil == self.equip_info_cfg then
		self.equip_info_cfg = ListToMap(headwear_cfg.equip_info, "equip_idx", "equip_level")
	end
	return self.equip_info_cfg
end

function HeadwearData:GetEquipInfoCfg(equip_index, level)
	if nil == self:GetAllEquipInfoCfg()[equip_index] then
		return
	end
	return self:GetAllEquipInfoCfg()[equip_index][level]
end

function HeadwearData:GetMaxSpecialImageCfgById(id)
	local list = {}
	local count = 0
	if id == nil then return count end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if id == v.special_img_id then
	-- 		list[v.grade] = v
	-- 	end
	-- end

	if id ~= nil then
		local cfg = self:GetSpecialImageUpgradeList(id)
		count = #cfg - 1 -- 配置表是从0到100
	end
	return count
end

function HeadwearData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function HeadwearData:GetHeadwearGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetHeadwearImageCfg(used_imageid)
	--if not image_list then return 0 end
	if not image_list then print_error("光环形象配置没有image_id:", used_imageid) return 0 end

	local show_grade = image_list.show_grade
	for k, v in pairs(self:GetGradeCfg()) do
		if v.show_grade == show_grade then
			return v.show_grade
		end
	end
	return 0
end

function HeadwearData:IsActiviteHeadwear()
	local active_flag = self.headwear_info and self.headwear_info.active_image_flag or {}
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function HeadwearData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function HeadwearData:GetLastGrade()
	return self.last_grade
end

function HeadwearData:ChangeShowInfo()
	self.show_bless = self.headwear_info.grade_bless_val
end

function HeadwearData:GetShowBless()
	return self.show_bless or self.last_bless
end

function HeadwearData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("headwear") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or next(self:CanSkillUpLevelList()) ~= nil or self:CalEquipBtnRemind() or self:CanJinjie()) then -- or AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.headwear)) then
		return 1
	end
	return 0
end

function HeadwearData:CalEquipRemind(equip_index)
	if nil == self.headwear_info or nil == next(self.headwear_info) then
		return 0
	end

	local equip_level = self.headwear_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

-- 计算装备按钮的红点
function HeadwearData:CalEquipBtnRemind()
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

function HeadwearData:GetOhterCfg()
	return self.GetAllHeadwearCfg().other[1]
end

function HeadwearData:IsOpenEquip()
	if nil == self.headwear_info or nil == next(self.headwear_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.headwear_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function HeadwearData:GetNextPercentAttrCfg(equip_index)
	if nil == self.headwear_info or nil == next(self.headwear_info) then
		return
	end

	local equip_level = self.headwear_info.equip_level_list[equip_index] or 0
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

function HeadwearData:GetEquipMinLevel()
	if nil == self.headwear_info or nil == next(self.headwear_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.headwear_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function HeadwearData:IsActiveEquipSkill()
	if nil == self.headwear_info or nil == next(self.headwear_info) then
		return false
	end
	return self.headwear_info.equip_skill_level > 0
end

function HeadwearData:GetShowHeadwearRes(grade)
	local grade = grade
	local headwear_grade_cfg = self:GetHeadwearGradeCfg(grade)
	local image_cfg = nil
	if headwear_grade_cfg then
		image_cfg = self:GetHeadwearImageCfg(headwear_grade_cfg.image_id)
	end
	if self.headwear_info.used_imageid < 1000 then
		if image_cfg then
			return image_cfg.res_id
		end
		return -1
	end
	if grade == self.headwear_info.grade then
		return self:GetSpecialImageCfg(self.headwear_info.used_imageid - 1000).res_id
	else
		if image_cfg then
			return image_cfg.res_id
		end
		return -1
	end
end

function HeadwearData:GetResIdByImgId(img_id)
	if not img_id then return 0 end
	local image_list = self:GetHeadwearImageCfg(img_id)
	if not image_list then print_error("光环形象配置没有image_id:", img_id) return 0 end
	return image_list.res_id or 0
end

function HeadwearData:GetSpecialResId(img_id)
	if not img_id then return 0 end
	local special_cfg = self:GetSpecialImageCfg(img_id)
	local res_id = special_cfg and special_cfg.res_id or 0
	return res_id
end