MountData = MountData or BaseClass()

MountDanId = {
		ChengZhangDanId = 22113,
		ZiZhiDanId = 22108,
}

MountShuXingDanCfgType = {
		Type = 5
}

MountDataEquipId = {
	16000, 16010, 16020, 16030
}

function MountData:__init()
	if MountData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	MountData.Instance = self

	self.level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").level, "mount_level")
	self.grade_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").grade, "grade")
	self.special_img_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").special_img, "image_id")
	self.special_img_upgrade_list = ListToMapList(ConfigManager.Instance:GetAutoConfig("mount_auto").special_image_upgrade, "special_img_id")
	self.skill_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").mount_skill
	self.image_list_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").image_list, "image_id")
	self.mount_equip_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").mount_equip
	self.equip_exp_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").equip_exp
	self.up_start_exp_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").up_start_exp, "star_level")
	self.skill_id_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").skill_id
	self.mount_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto")
	self.equip_info_cfg = ListToMap(self.mount_cfg.mount_equip_info, "equip_idx", "equip_level")
	self.mount_info = {}

	self.temp_img_id = 0
	self.temp_img_id_has_select = 0
	self.temp_img_time = 0
	self.last_bless = 0
	self.last_grade = 0
	RemindManager.Instance:Register(RemindName.AdvanceMount, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function MountData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceMount)
	if MountData.Instance then
		MountData.Instance = nil
	end
	self.mount_info = {}
end

function MountData:SetMountInfo(protocol)
	self:SetLastInfo(self.mount_info.grade_bless_val, self.mount_info.grade)
	self.mount_info.mount_flag = protocol.mount_flag
	self.mount_info.mount_level = protocol.mount_level
	self.mount_info.grade = protocol.grade
	self.mount_info.grade_bless_val = protocol.grade_bless_val
	self.mount_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.mount_info.used_imageid = protocol.used_imageid
	self.mount_info.shuxingdan_count = protocol.shuxingdan_count
	self.mount_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.mount_info.active_image_flag = protocol.active_image_flag
	-- self.mount_info.active_special_image_flag_low = protocol.active_special_image_flag_low
	-- self.mount_info.active_special_image_flag_high = protocol.active_special_image_flag_high
	-- self.mount_info.active_special_image_list = bit:d2b(self.mount_info.active_special_image_flag)
	self.mount_info.active_special_image_list = protocol.active_special_image_flag_ex

	-- self.mount_info.equip_info_list = protocol.equip_info_list
	self.mount_info.skill_level_list = protocol.skill_level_list
	self.mount_info.special_img_grade_list = protocol.special_img_grade_list

	self.mount_info.show_grade = math.ceil(protocol.grade / 10)
	self.mount_info.star_level = protocol.grade % 10

	self.temp_img_id = protocol.temp_img_id
	self.temp_img_id_has_select = protocol.temp_img_id_has_select
	self.temp_img_time = protocol.temp_img_time

	self.mount_info.equip_skill_level = protocol.equip_skill_level
	self.mount_info.equip_level_list = protocol.equip_level_list
end

function MountData:GetUsedImageId()
	return self.mount_info.used_imageid
end


function MountData:IsShowTempMountIcon()
	if self.temp_img_id_has_select == 0 and self.temp_img_time ~= 0 then
		return false
	end
	return true
end

function MountData:GetTempMountTime()
	return self.temp_img_time
end

function MountData:HasChooseTempMount()
	return self.temp_img_id_has_select ~= 0
end

function MountData:GetTempImgId()
	return self.temp_img_id_has_select
end

function MountData:GetMountInfo()
	return self.mount_info
end

function MountData:GetCurMountCfg(grade)
	if not grade then return end
	local cfg = self:GetGradeCfg()
	return cfg[grade]
end

--形象进阶+幻化的战力
function MountData:GetMountPower()
	local cfg = self:GetCurMountCfg(self.mount_info.grade)
	local upgrade_power = CommonDataManager.GetCapabilityCalculation(cfg or {})
	local huanhua_power = 0
	for k,v in pairs(self.mount_info.active_special_image_list) do
		if v == 1 then
			local index = k
			local huanhua_cfg = self:GetSpecialImageUpgradeInfo(index)
			huanhua_power = huanhua_power + CommonDataManager.GetCapabilityCalculation(huanhua_cfg)
		end
	end
	return huanhua_power + upgrade_power
end

function MountData:GetMountLevelCfg(mount_level)
	if mount_level == nil then
		return nil
	end
	--local mount_config = ConfigManager.Instance:GetAutoConfig("mount_auto")
	if mount_level >= self:GetMaxMountLevelCfg() then
		mount_level = self:GetMaxMountLevelCfg()
	end
	--return mount_config.level[mount_level]
	return self.level_cfg[mount_level]
end

function MountData:GetMaxMountLevelCfg()
	--return #ConfigManager.Instance:GetAutoConfig("mount_auto").level
	return #self.level_cfg
end

function MountData:GetMountShowGradeCfg(mount_grade)
	--local mount_config = ConfigManager.Instance:GetAutoConfig("mount_auto")
	--return mount_config.grade[mount_grade * 10]
	if mount_grade ~= nil then
		return self.grade_cfg[mount_grade * 10]
	end

	return nil
end

function MountData:GetMountGradeCfg(mount_grade)
	--local mount_config = ConfigManager.Instance:GetAutoConfig("mount_auto")
	--return mount_config.grade[mount_grade]
	if mount_grade ~= nil then
		return self.grade_cfg[mount_grade]
	end

	return nil
end

function MountData:GetSpecialImageCfg(image_id)
	--local mount_config = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img
	if image_id ~= nil then
		return self.special_img_cfg[image_id]
	end

	return nil
end

-- 是否开启进阶装备
function MountData:IsOpenEquip()
	if nil == self.mount_info or nil == next(self.mount_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.mount_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function MountData:GetOhterCfg()
	return self.mount_cfg.other[1]
end

function MountData:GetSpecialImagesCfg()
	return ConfigManager.Instance:GetAutoConfig("mount_auto").special_img
end
function MountData:GetMaxGrade()
	--return #ConfigManager.Instance:GetAutoConfig("mount_auto").grade / 10
	return #self.grade_cfg / 10
end

function MountData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("mount_auto").special_img
	return #self.special_img_cfg
end

function MountData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.mount_info.active_special_image_list or {}
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

function MountData:GetMountIsActive(image_id)
	return self.mount_info.active_special_image_list[image_id] ~= 0
end

function MountData:CheckIsHuanHuaItem(item_id)
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

function MountData:GetSpecialImageUpgradeCfg()
	return ConfigManager.Instance:GetAutoConfig("mount_auto").special_image_upgrade
end

function MountData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function MountData:GetSpecialImageUpgradeList(special_img_id)
	if special_img_id ~= nil then
		return self.special_img_upgrade_list[special_img_id]
	end

	return nil
end

function MountData:GetMountSkillCfg()
	--return ConfigManager.Instance:GetAutoConfig("mount_auto").mount_skill
	return self.skill_cfg
end

function MountData:GetGradeCfg()
	--return ConfigManager.Instance:GetAutoConfig("mount_auto").grade
	return self.grade_cfg
end

function MountData:GetMountImageCfg(image_id)
	--return ConfigManager.Instance:GetAutoConfig("mount_auto").image_list
	if image_id ~= nil then
		return self.image_list_cfg[image_id]
	end

	return nil
end

function MountData:GetMountEquipCfg()
	--return ConfigManager.Instance:GetAutoConfig("mount_auto").mount_equip
	return self.mount_equip_cfg
end

function MountData:GetMountEquipExpCfg()
	--return ConfigManager.Instance:GetAutoConfig("mount_auto").equip_exp
	return self.equip_exp_cfg
end

-- function MountData:GetMountEquipRandAttr()
-- 	return ConfigManager.Instance:GetAutoConfig("mount_auto").equip_attr_range
-- end

function MountData:GetMountUpStarExpCfg(star_level)
	--return ConfigManager.Instance:GetAutoConfig("mount_auto").up_start_exp
	if star_level ~= nil then
		return self.up_start_exp_cfg[star_level]
	end

	return nil
end

function MountData:GetMountSkillId()
	--return ConfigManager.Instance:GetAutoConfig("mount_auto").skill_id
	return self.skill_id_cfg
end

-- 获取当前点击坐骑特殊形象的配置
function MountData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade
	if grade == nil and self.mount_info ~= nil and self.mount_info.special_img_grade_list ~= nil then
		grade = self.mount_info.special_img_grade_list[index] or 0
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
function MountData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if v.special_img_id == image_id and v.grade > 0 then
	-- 		max_level = max_level + 1
	-- 	end
	-- end
	-- return max_level
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
function MountData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	-- for k, v in pairs(self:GetMountImageCfg()) do
	-- 	if v.image_id == index then
	-- 		return v
	-- 	end
	-- end

	return self:GetMountImageCfg(index)
end

-- 获取当前点击坐骑技能的配置
function MountData:GetMountSkillCfgById(skill_idx, level, mount_info)
	local mount_info = mount_info or self.mount_info
	local skill_id_list = self:GetMountSkillId()
	local skill_id = 0
	for k,v in pairs(skill_id_list) do
		if v.skill_id % 10 == skill_idx + 1 then
			skill_id = v.skill_id
			break
		end
	end
	local level = level or SkillData.Instance:GetSkillInfoById(skill_id) and SkillData.Instance:GetSkillInfoById(skill_id).level or 0
	for k, v in pairs(self:GetMountSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

-- 获取当前点击坐骑技能是否可以激活
function MountData:GetMountSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetMountSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end

-- 获取特殊形象总增加的属性丹和成长丹数量
function MountData:GetSpecialImageAttrSum(mount_info)
	mount_info = mount_info or self.mount_info
	local active_flag = mount_info.active_special_image_list
	local sum_attr_list = CommonStruct.Attribute()
	if active_flag == nil then
		sum_attr_list.chengzhangdan_count = 0
		sum_attr_list.shuxingdan_count = 0
		sum_attr_list.equip_limit = 0
		return sum_attr_list
	end
	local bit_list = active_flag
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
	if self:GetMountGradeCfg(mount_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetMountGradeCfg(mount_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetMountGradeCfg(mount_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetMountGradeCfg(mount_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总属性
function MountData:GetMountSkillAttrSum(mount_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetMountSkillCfgById(i, nil, mount_info)
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

-- 获得已升级装备属性
function MountData:GetMountEquipAttrSum(mount_info)
	mount_info = mount_info or self.mount_info
	local attr_list = CommonStruct.Attribute()
	if nil == mount_info.equip_level_list then return attr_list end
	for k, v in pairs(mount_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

function MountData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end


-- 获取已吃成长丹，资质丹属性
function MountData:GetDanAttr(mount_info)
	mount_info = mount_info or self.mount_info
	if mount_info.mount_level >= self:GetMaxMountLevelCfg() then
		mount_info.mount_level = self:GetMaxMountLevelCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local mount_level_cfg = self:GetMountLevelCfg(mount_info.mount_level)
	local mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade)
	if not mount_grade_cfg then return attr_list end
	-- attr_list.gong_ji = math.floor((mount_level_cfg.gongji + mount_grade_cfg.gongji) * mount_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((mount_level_cfg.fangyu + mount_grade_cfg.fangyu) * mount_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((mount_level_cfg.maxhp + mount_grade_cfg.maxhp) * mount_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((mount_level_cfg.mingzhong + mount_grade_cfg.mingzhong) * mount_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((mount_level_cfg.shanbi + mount_grade_cfg.shanbi) * mount_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((mount_level_cfg.baoji + mount_grade_cfg.baoji) * mount_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((mount_level_cfg.jianren + mount_grade_cfg.jianren) * mount_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == MountShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * mount_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * mount_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * mount_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function MountData:GetMountAttrSum(mount_info)
	mount_info = mount_info or self:GetMountInfo()
	local attr = CommonStruct.Attribute()
	if nil == mount_info.grade or mount_info.grade <= 0 or mount_info.mount_level == 0 then
		return attr
	end

	if mount_info.mount_level >= self:GetMaxMountLevelCfg() then
		mount_info.mount_level = self:GetMaxMountLevelCfg()
	end

	local mount_level_cfg = self:GetMountLevelCfg(mount_info.mount_level)
	local mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade)
	local star_cfg = self:GetMountStarLevelCfg(mount_info.star_level)

	if not star_cfg then return attr end

	local mount_next_grade_cfg = self:GetMountGradeCfg(mount_info.grade + 1)
	local skill_attr = self:GetMountSkillAttrSum(mount_info)
	-- local equip_attr = self:GetMountEquipAttrSum(mount_info)
	local dan_attr = self:GetDanAttr(mount_info)
	-- local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(mount_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().mount_attr_add / 10000 or 0
	local zhibao_percent = ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()) and
					ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()).mount_attr_add / 10000 or 0

	-- if mount_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = mount_next_grade_cfg.maxhp - mount_grade_cfg.maxhp
	-- 	differ_value.gong_ji = mount_next_grade_cfg.gongji - mount_grade_cfg.gongji
	-- 	differ_value.fang_yu = mount_next_grade_cfg.fangyu - mount_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = mount_next_grade_cfg.mingzhong - mount_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = mount_next_grade_cfg.shanbi - mount_grade_cfg.shanbi
	-- 	differ_value.bao_ji = mount_next_grade_cfg.baoji - mount_grade_cfg.baoji
	-- 	differ_value.jian_ren = mount_next_grade_cfg.jianren - mount_grade_cfg.jianren
	-- 	differ_value.move_speed = mount_next_grade_cfg.movespeed - mount_grade_cfg.movespeed
	-- end

	-- local temp_attr_per = mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit

	attr.max_hp = (mount_level_cfg.maxhp
				+ star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * mount_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent + zhibao_percent) * (mount_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (mount_level_cfg.gongji
				+ star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * mount_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent + zhibao_percent) * (mount_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (mount_level_cfg.fangyu
				+ star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * mount_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent + zhibao_percent) * (mount_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (mount_level_cfg.mingzhong
					+ star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent + zhibao_percent) * (mount_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (mount_level_cfg.shanbi
				+ star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * mount_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent + zhibao_percent) * (mount_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (mount_level_cfg.baoji
				+ star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * mount_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent + zhibao_percent) * (mount_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (mount_level_cfg.jianren
				+ star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * mount_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent + zhibao_percent) * (mount_level_cfg.jianren + star_cfg.jianren)

	attr.move_speed = mount_grade_cfg.movespeed --+ differ_value.move_speed * temp_attr_per
	-- attr.per_pofang = equip_attr.per_pofang
	-- attr.per_mianshang = equip_attr.per_mianshang

	return attr
end

function MountData:GetMountStarLevelCfg(star_level)
	local star_level = star_level or self.mount_info.star_level

	-- for k, v in pairs(self:GetMountUpStarExpCfg()) do
	-- 	if v.star_level == star_level then
	-- 		return v
	-- 	end
	-- end

	return self:GetMountUpStarExpCfg(star_level)
end

function MountData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.mount_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.mount_info.shuxingdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == MountDanId.ZiZhiDanId then
			return true
		end
	end
	return false
end

function MountData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.mount_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.mount_info.chengzhangdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(MountDanId.ChengZhangDanId) > 0 then
		return true
	end

	return false
end

function MountData:CanHuanhuaUpgrade()
	local list = {}
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return list end
	if self.mount_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.mount_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.mount_info.special_img_grade_list[j.special_img_id] < self:GetMaxSpecialImageCfgById(j.special_img_id) then
			list[j.special_img_id] = j.special_img_id
		end
	end
	return list
end

function MountData:GetNextPercentAttrCfg(equip_index)
	if nil == self.mount_info or nil == next(self.mount_info) then
		return
	end

	local equip_level = self.mount_info.equip_level_list[equip_index] or 0
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

function MountData:GetEquipMinLevel()
	if nil == self.mount_info or nil == next(self.mount_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.mount_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function MountData:CanSkillUpLevelList()
	local list = {}
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return list end

	for i, j in pairs(self:GetMountSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.mount_info.show_grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function MountData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetMountSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function MountData:CanJinjie()
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return false end
	local cfg = self:GetMountGradeCfg(self.mount_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.mount_info.grade < #self.grade_cfg then
			return true
		end
	end
	return false
end

function MountData:GetMaxSpecialImageCfgById(id)
	--local list = {}
	-- if id == nil then return list end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if id == v.special_img_id then
	-- 		list[v.grade] = v
	-- 	end
	-- end
	-- return #list

	local count = 0
	if id == nil then return end
	local cfg = self:GetSpecialImageUpgradeList(id)
	count = #cfg - 1

	return count
end

function MountData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function MountData:GetCraftCfgById(craft_id)
	local craft_cfg = ConfigManager.Instance:GetAutoConfig("aircraftcfg_auto")
	if craft_cfg then
		return craft_cfg.aircraft[craft_id]
	end
end

function MountData:GetMountGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetMountImageCfg(used_imageid)
	--if not image_list then return 0 end
	if not image_list then 
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

function MountData:IsActiviteMount()
	local active_flag = self.mount_info and self.mount_info.active_image_flag or 0
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function MountData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function MountData:GetLastGrade()
	return self.last_grade
end

function MountData:ChangeShowInfo()
	self.show_bless = self.mount_info.grade_bless_val
end

function MountData:GetShowBless()
	return self.show_bless or self.last_bless
end

function MountData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("mount_jinjie") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or next(self:CanSkillUpLevelList()) ~= nil or self:CanJinjie() or self:CalEquipBtnRemind() or AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.MOUNT)) then
		return 1
	end
	return 0
end

function MountData:IsActiveEquipSkill()
	if nil == self.mount_info or nil == next(self.mount_info) then
		return false
	end
	return self.mount_info.equip_skill_level > 0
end

-- 计算单件装备红点
function MountData:CalEquipRemind(equip_index)
	if nil == self.mount_info or nil == next(self.mount_info) then
		return 0
	end

	local equip_level = self.mount_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

-- 计算装备按钮的红点
function MountData:CalEquipBtnRemind()
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

function MountData:CheckHHIsActiveByItem(item_id)
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

	if index ~= nil and self.mount_info ~= nil and self.mount_info.active_special_image_list ~= nil then
		is_active = self.mount_info.active_special_image_list[index] == 1
		index = index + GameEnum.MOUNT_SPECIAL_IMA_ID
	end

	return is_active, index
end

function MountData:GetCanUseImage()
	local image_id = nil
	if self.mount_info == nil or self.mount_info.grade == nil then
		return image_id
	end

	local grade = self.mount_info.grade
	local grade_cfg = self:GetMountGradeCfg(grade)
	if grade_cfg == nil then
		return image_id
	end

	return grade_cfg.image_id
end

function MountData:GetMountCfgByResId(res_id)
	local cfg = nil

	if res_id == nil then
		return cfg
	end

	if self.image_list_cfg ~= nil then
		for k,v in pairs(self.image_list_cfg) do
			if v ~= nil and v.res_id == res_id then
				cfg = v
				break
			end
		end
	end

	if self.special_img_cfg ~= nil and cfg == nil then
		for k,v in pairs(self.special_img_cfg) do
			if v ~= nil and v.res_id == res_id then
				cfg = v
				break
			end
		end		
	end

	return cfg
end