BeautyHaloData = BeautyHaloData or BaseClass()

BeautyHaloDanId = {
		ChengZhangDanId = 22113,
		ZiZhiDanId = 22113,
}

BeautyHaloShuXingDanCfgType = {
		Type = 14
}

function BeautyHaloData:__init()
	if BeautyHaloData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	BeautyHaloData.Instance = self

	self.beauty_halo_grade_cfg = nil
	self.mount_level_cfg = nil
	self.beauty_halo_special_cfg = nil
	self.beauty_halo_special_upgrade = nil
	self.beauty_halo_special_upgrade_si_grade = nil
	self.beauty_halo_special_upgrade_all = nil
	-- self.beauty_halo_skill_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").skill, "skill_idx")--名字重复
	self.beauty_halo_image_list = nil
	self.mount_equip_cfg = nil
	self.beauty_halo_skill_id_list = nil
	-- self.beauty_all_grade_cfg = ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").grade
	self.beauty_halo_skill_cfg = nil
	-- self.shengong_cfg = ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto")
	self.equip_info_cfg = nil
	self.beauty_halo_info = {}

	self.temp_img_id = 0
	self.temp_img_id_has_select = 0
	self.temp_img_time = 0

	self.last_bless = 0
	self.last_grade = 0

	RemindManager.Instance:Register(RemindName.AdvanceBeautyHalo, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function BeautyHaloData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceBeautyHalo)
	if BeautyHaloData.Instance then
		BeautyHaloData.Instance = nil
	end
	self.beauty_halo_info = {}
end

function BeautyHaloData:SetBeautyHaloInfo(protocol)
	-- self.beauty_halo_info.mount_flag = protocol.mount_flag
	-- self.beauty_halo_info.mount_level = protocol.mount_level
	-- self.beauty_halo_info.grade = protocol.grade
	-- self.beauty_halo_info.grade_bless_val = protocol.grade_bless_val
	-- self.beauty_halo_info.clear_upgrade_time = protocol.clear_upgrade_time
	-- self.beauty_halo_info.used_imageid = protocol.used_imageid
	-- self.beauty_halo_info.shuxingdan_count = protocol.shuxingdan_count
	-- self.beauty_halo_info.chengzhangdan_count = protocol.chengzhangdan_count
	-- self.beauty_halo_info.active_image_flag = protocol.active_image_flag
	-- self.beauty_halo_info.active_special_image_flag = protocol.active_special_image_flag

	-- self.beauty_halo_info.equip_info_list = protocol.equip_info_list
	-- self.beauty_halo_info.skill_level_list = protocol.skill_level_list
	-- self.beauty_halo_info.special_img_grade_list = protocol.special_img_grade_list

	self:SetLastInfo(self.beauty_halo_info.grade_bless_val, self.beauty_halo_info.grade)
	self.beauty_halo_info.grade = protocol.grade
	self.beauty_halo_info.used_imageid = protocol.used_imageid
	self.beauty_halo_info.active_image_flag = protocol.active_image_flag
	self.beauty_halo_info.grade_bless_val = protocol.grade_bless_val
	self.beauty_halo_info.active_special_image_flag = protocol.active_special_image_flag
	self.beauty_halo_info.active_special_image_list = bit:d2b(self.beauty_halo_info.active_special_image_flag)
	self.beauty_halo_info.special_img_grade_list = protocol.special_img_grade_list

	self.beauty_halo_info.show_grade = math.ceil(protocol.grade / 10)
	self.beauty_halo_info.star_level = protocol.grade % 10

	self.beauty_halo_info.mount_level = 999
	self.beauty_halo_info.shuxingdan_count = protocol.shuxingdan_count
	self.beauty_halo_info.chengzhangdan_count = 0
	self.beauty_halo_info.equip_info_list = {}
	self.beauty_halo_info.skill_level_list = {}

	self.beauty_halo_info.equip_skill_level = protocol.equip_skill_level
	self.beauty_halo_info.equip_level_list = protocol.equip_level_list
	-- self.temp_img_id = protocol.temp_img_id
	-- self.temp_img_id_has_select = protocol.temp_img_id_has_select
	-- self.temp_img_time = protocol.temp_img_time
end

function BeautyHaloData:GetAllBeautyHaloCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto") or {}
end

function BeautyHaloData:IsShowTempIcon()
	if self.temp_img_id_has_select == 0 and self.temp_img_time ~= 0 then
		return false
	end
	return true
end

function BeautyHaloData:GetGradeListCfg()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.beauty_halo_grade_cfg then
		self.beauty_halo_grade_cfg = ListToMap(beauty_halo_cfg.grade, "grade")
	end
	return self.beauty_halo_grade_cfg
end

function BeautyHaloData:GetCurBeautyHaloCfg(grade)
	if not grade then return end
	return self:GetGradeListCfg()[grade]
end

--形象进阶+幻化的战力
function BeautyHaloData:GetBeautyHaloPower()
	local cfg = self:GetCurBeautyHaloCfg(self.beauty_halo_info.grade)
	local upgrade_power = CommonDataManager.GetCapabilityCalculation(cfg)
	local huanhua_power = 0
	for k,v in pairs(self.beauty_halo_info.active_special_image_list) do
		if v == 1 then
			local index = 32 - k
			local arr_cfg = self:GetSpecialImageUpgradeInfo(index)
			huanhua_power = huanhua_power + CommonDataManager.GetCapabilityCalculation(arr_cfg)
		end
	end
	return huanhua_power + upgrade_power
end

function BeautyHaloData:GetTempTime()
	return self.temp_img_time
end

function BeautyHaloData:HasChooseTemp()
	return self.temp_img_id_has_select ~= 0
end

function BeautyHaloData:GetTempImgId()
	return self.temp_img_id_has_select
end

function BeautyHaloData:GetBeautyHaloInfo()
	return self.beauty_halo_info
end

function BeautyHaloData:GetLevelCfg(mount_level)
	--local mount_config = ConfigManager.Instance:GetAutoConfig("mount_auto")
	if mount_level == nil then
		return nil
	end
	
	if mount_level >= self:GetMaxLevelCfg() then
		mount_level = self:GetMaxLevelCfg()
	end
	return self.level_cfg[mount_level]
end

function BeautyHaloData:GetMaxLevelCfg()
	if not self.mount_level_cfg then
		self.mount_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").level, "mount_level")
	end
	return #self.mount_level_cfg
end


function BeautyHaloData:GetShowBeautyHaloGradeCfg(mount_grade)
	--local mount_config = ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto")
	--return mount_config.grade[mount_grade * 10]
	if mount_grade ~= nil then
		return self:GetGradeListCfg()[mount_grade * 10]
	end

	return nil
end

function BeautyHaloData:GetBeautyHaloGradeCfg(mount_grade)
	--local mount_config = ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto")
	if mount_grade ~= nil then
		return self:GetGradeListCfg()[mount_grade]
	end

	return nil
end

function BeautyHaloData:GetSpecialImageCfg(image_id)
	--local mount_config = ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").special_img
	if image_id ~= nil then
		return self:GetSpecialImagesCfgByItemId()[image_id]
	end

	return nil
end

function BeautyHaloData:GetSpecialImagesCfgByItemId()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.beauty_halo_special_cfg then
		self.beauty_halo_special_cfg = ListToMap(beauty_halo_cfg.special_img, "image_id")
	end
	return self.beauty_halo_special_cfg
end

function BeautyHaloData:GetMaxGrade()
	--return #ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").grade / 10
	return #self:GetGradeListCfg() / 10
end

function BeautyHaloData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").special_img
	return #self:GetSpecialImagesCfgByItemId()
end

function BeautyHaloData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.beauty_halo_info.active_special_image_list or {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	for k,v in pairs(self:GetSpecialImagesCfgByItemId()) do
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

function BeautyHaloData:GetBeautyHaloIsActive(image_id)
	return self.beauty_halo_info.active_special_image_list[32 - image_id] ~= 0
end

function BeautyHaloData:CheckIsHuanHuaItem(item_id)
	local is_item = false
	if item_id == nil or self:GetSpecialImagesCfgByItemId() == nil then
		return
	end

	for k,v in pairs(self:GetSpecialImagesCfgByItemId()) do
		if v ~= nil and v.item_id == item_id then
			is_item = true
			break
		end
	end

	return is_item
end

function BeautyHaloData:GetSpecialImageUpgradeCfg()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.beauty_halo_special_upgrade then
		self.beauty_halo_special_upgrade = ListToMapList(beauty_halo_cfg.special_image_upgrade, "special_img_id")
	end
	return self.beauty_halo_special_upgrade
end

function BeautyHaloData:GetSpecialUpgradeSiCfg()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.beauty_halo_special_upgrade_si_grade then
		self.beauty_halo_special_upgrade_si_grade = ListToMap(beauty_halo_cfg.special_image_upgrade, "stuff_id", "grade")
	end
	return self.beauty_halo_special_upgrade_si_grade
end

function BeautyHaloData:GetSpecialImageUpgradeCfgBySiGrade(stuff_id, grade)
	if stuff_id == nil or grade == nil then
		return
	end
	return self:GetSpecialUpgradeSiCfg()[stuff_id][grade]
end

function BeautyHaloData:GetSkillCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").skill
	--return self.beauty_halo_skill_cfg
end

function BeautyHaloData:GetBeautyHaloSkillCfg()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.beauty_halo_skill_cfg then
		self.beauty_halo_skill_cfg = ListToMap(beauty_halo_cfg.skill, "skill_idx", "skill_level")
	end
	return self.beauty_halo_skill_cfg
end

function BeautyHaloData:GetBeautyHaloSkillList(skill_idx, skill_level)
	if skill_idx ~= nil and skill_level ~= nil then
		if self:GetBeautyHaloSkillCfg()[skill_idx] ~= nil then
			return self:GetBeautyHaloSkillCfg()[skill_idx][skill_level]
		end
	end
	return nil
end

function BeautyHaloData:GetGradeCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").grade
end

function BeautyHaloData:GetImageCfg()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.beauty_halo_image_list then
		self.beauty_halo_image_list = ListToMap(beauty_halo_cfg.image_list, "image_id")
	end
	return self.beauty_halo_image_list
end

function BeautyHaloData:GetEquipCfg()
	if not self.mount_equip_cfg then
		self.mount_equip_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").mount_equip
	end
	return self.mount_equip_cfg
end

-- function BeautyHaloData:GetEquipExpCfg()
-- 	return ConfigManager.Instance:GetAutoConfig("mount_auto").equip_exp
-- end

-- function BeautyHaloData:GetEquipRandAttr()
-- 	return ConfigManager.Instance:GetAutoConfig("mount_auto").equip_attr_range
-- end

function BeautyHaloData:GetBeautyHaloSkillId()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.beauty_halo_skill_id_list then
		self.beauty_halo_skill_id_list = beauty_halo_cfg.skill_id
	end
	return self.beauty_halo_skill_id_list
end

-- 获取当前点击坐骑特殊形象的配置
function BeautyHaloData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade
	if grade == nil and self.beauty_halo_info ~= nil and self.beauty_halo_info.special_img_grade_list ~= nil then
		grade = self.beauty_halo_info.special_img_grade_list[index] or 0
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
	local cfg = self:GetSpecialImageUpgradeCfg()
	if cfg ~= nil and cfg[index] ~= nil then
		for k,v in pairs(cfg[index]) do
			if v.grade == grade then
				return v
			end
		end
	end

	return nil
end

-- 获取幻化最大等级
function BeautyHaloData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if v.special_img_id == image_id and v.grade > 0 then
	-- 		max_level = max_level + 1
	-- 	end
	-- end

	local cfg = self:GetSpecialImageUpgradeCfg()
	if cfg ~= nil and cfg[image_id] ~= nil then
		for k,v in pairs(cfg[image_id]) do
			if v.grade > 0 then
				max_level = max_level + 1
			end
		end
	end
	return max_level
end

-- 获取形象列表的配置
function BeautyHaloData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	-- for k, v in pairs(self:GetImageCfg()) do
	-- 	if v.image_id == index then
	-- 		return v
	-- 	end
	-- end

	--return self:GetImageCfg()[index]
	return self:GetImageCfg()[index]
end

-- 获取当前点击坐骑技能的配置
function BeautyHaloData:GetSkillCfgById(skill_idx, level, beauty_halo_info)
	local skill_id_list = self:GetBeautyHaloSkillId()
	local skill_id = 0
	for k,v in pairs(skill_id_list) do
		if v.skill_id % 10 == skill_idx + 1 then
			skill_id = v.skill_id
			break
		end
	end
	local level = level or SkillData.Instance:GetSkillInfoById(skill_id) and SkillData.Instance:GetSkillInfoById(skill_id).level or 0

	-- for k, v in pairs(self:GetSkillCfg()) do
	-- 	if v.skill_idx == skill_idx and v.skill_level == level then
	-- 		return v
	-- 	end
	-- end

	return self:GetBeautyHaloSkillList(skill_idx, level)
end

function BeautyHaloData:GetBeautyHaloSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end

-- 获取特殊形象总增加的属性丹和成长丹数量
function BeautyHaloData:GetSpecialImageAttrSum(beauty_halo_info)
	beauty_halo_info = beauty_halo_info or self.beauty_halo_info
	local active_flag = beauty_halo_info.active_special_image_flag
	local sum_attr_list = CommonStruct.Attribute()
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
	if self:GetBeautyHaloGradeCfg(beauty_halo_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetBeautyHaloGradeCfg(beauty_halo_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetBeautyHaloGradeCfg(beauty_halo_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetBeautyHaloGradeCfg(beauty_halo_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总属性
function BeautyHaloData:GetSkillAttrSum(beauty_halo_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetSkillCfgById(i, nil, beauty_halo_info)
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

function BeautyHaloData:GetShowShengongRes(grade)
	local grade = grade
	local shengong_grade_cfg = self:GetShengongGradeCfg(grade)
	local image_cfg = nil
	if shengong_grade_cfg then
		image_cfg = self:GetShengongImageCfg()
	end
	if self.beauty_halo_info.used_imageid < 1000 then
		if image_cfg then
			return image_cfg[shengong_grade_cfg.image_id].res_id
		end
		return -1
	end
	if grade == self.beauty_halo_info.grade then
		return self:GetSpecialImageCfg(self.beauty_halo_info.used_imageid - 1000).res_id
	else
		if image_cfg then
			return image_cfg[shengong_grade_cfg.image_id].res_id
		end
		return -1
	end
end

function BeautyHaloData:GetShengongImageCfg()
	return self:GetAllBeautyHaloCfg().image_list
end

function BeautyHaloData:GetShengongGradeCfg(shengong_grade)
	return self:GetAllBeautyHaloCfg().grade[shengong_grade]
end

-- 获得已升级装备属性
function BeautyHaloData:GetEquipAttrSum(shengong_info)
	shengong_info = shengong_info or self.beauty_halo_info
	local attr_list = CommonStruct.Attribute()
	if nil == shengong_info.equip_level_list then return attr_list end
	for k, v in pairs(shengong_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

function BeautyHaloData:GetEquipInfoListCfg()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.equip_info_cfg then
		self.equip_info_cfg = ListToMap(beauty_halo_cfg.equip_info, "equip_idx", "equip_level")
	end
	return self.equip_info_cfg
end

function BeautyHaloData:GetEquipInfoCfg(equip_index, level)
	if nil == self:GetEquipInfoListCfg()[equip_index] then
		return
	end
	return self:GetEquipInfoListCfg()[equip_index][level]
end

-- 获取已吃成长丹，资质丹属性
function BeautyHaloData:GetDanAttr(beauty_halo_info)
	beauty_halo_info = beauty_halo_info or self.beauty_halo_info
	if beauty_halo_info.mount_level >= self:GetMaxLevelCfg() then
		beauty_halo_info.mount_level = self:GetMaxLevelCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local mount_level_cfg = self:GetLevelCfg(beauty_halo_info.mount_level)
	local mount_grade_cfg = self:GetBeautyHaloGradeCfg(beauty_halo_info.grade)
	if not mount_grade_cfg then return attr_list end
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == ShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * beauty_halo_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * beauty_halo_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * beauty_halo_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function BeautyHaloData:GetAttrSum(beauty_halo_info)
	beauty_halo_info = beauty_halo_info or self:GetBeautyHaloInfo()
	if beauty_halo_info.grade <= 0 or beauty_halo_info.mount_level == 0 then
		return CommonStruct.Attribute()
	end

	if beauty_halo_info.mount_level >= self:GetMaxLevelCfg() then
		beauty_halo_info.mount_level = self:GetMaxLevelCfg()
	end

	local mount_level_cfg = self:GetLevelCfg(beauty_halo_info.mount_level)
	local mount_grade_cfg = self:GetBeautyHaloGradeCfg(beauty_halo_info.grade)
	local mount_next_grade_cfg = self:GetBeautyHaloGradeCfg(beauty_halo_info.grade + 1)
	local skill_attr = self:GetSkillAttrSum(beauty_halo_info)
	-- local equip_attr = self:GetEquipAttrSum(beauty_halo_info)
	local dan_attr = self:GetDanAttr(beauty_halo_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(beauty_halo_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().mount_attr_add / 10000 or 0
	local zhibao_percent = ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()) and
					ZhiBaoData.Instance:GetLevelCfgByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()).mount_attr_add / 10000 or 0

	if 	mount_next_grade_cfg ~= nil then												-- 临时属性加成
		differ_value.max_hp = mount_next_grade_cfg.maxhp - mount_grade_cfg.maxhp
		differ_value.gong_ji = mount_next_grade_cfg.gongji - mount_grade_cfg.gongji
		differ_value.fang_yu = mount_next_grade_cfg.fangyu - mount_grade_cfg.fangyu
		differ_value.ming_zhong = mount_next_grade_cfg.mingzhong - mount_grade_cfg.mingzhong
		differ_value.shan_bi = mount_next_grade_cfg.shanbi - mount_grade_cfg.shanbi
		differ_value.bao_ji = mount_next_grade_cfg.baoji - mount_grade_cfg.baoji
		differ_value.jian_ren = mount_next_grade_cfg.jianren - mount_grade_cfg.jianren
	end

	local temp_attr_per = beauty_halo_info.grade_bless_val/mount_grade_cfg.bless_val_limit

	local attr = CommonStruct.Attribute()
	attr.max_hp = (mount_level_cfg.maxhp + mount_grade_cfg.maxhp + differ_value.max_hp * temp_attr_per * mount_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp + dan_attr.max_hp + special_img_attr.max_hp) + (medal_percent + zhibao_percent) * (mount_level_cfg.maxhp + mount_grade_cfg.maxhp)
	attr.gong_ji = (mount_level_cfg.gongji + mount_grade_cfg.gongji + differ_value.gong_ji * temp_attr_per * mount_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji + dan_attr.gong_ji + special_img_attr.gong_ji) + (medal_percent + zhibao_percent) * (mount_level_cfg.gongji + mount_grade_cfg.gongji)
	attr.fang_yu = (mount_level_cfg.fangyu + mount_grade_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per
				+ skill_attr.fang_yu + dan_attr.fang_yu + special_img_attr.fang_yu) + (medal_percent + zhibao_percent) * (mount_level_cfg.fangyu + mount_grade_cfg.fangyu)
	attr.ming_zhong = (mount_level_cfg.mingzhong + mount_grade_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per
					+ skill_attr.ming_zhong + dan_attr.ming_zhong + special_img_attr.ming_zhong) + (medal_percent + zhibao_percent) * (mount_level_cfg.mingzhong + mount_grade_cfg.mingzhong)
	attr.shan_bi = (mount_level_cfg.shanbi + mount_grade_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per
				+ skill_attr.shan_bi + dan_attr.shan_bi + special_img_attr.shan_bi) + (medal_percent + zhibao_percent) * (mount_level_cfg.shanbi + mount_grade_cfg.shanbi)
	attr.bao_ji = (mount_level_cfg.baoji + mount_grade_cfg.baoji --+ differ_value.bao_ji * temp_attr_per
				+ skill_attr.bao_ji + dan_attr.bao_ji + special_img_attr.bao_ji) + (medal_percent + zhibao_percent) * (mount_level_cfg.baoji + mount_grade_cfg.baoji)
	attr.jian_ren = (mount_level_cfg.jianren + mount_grade_cfg.jianren --+ differ_value.jian_ren * temp_attr_per
				+ skill_attr.jian_ren + dan_attr.jian_ren + special_img_attr.jian_ren) + (medal_percent + zhibao_percent) * (mount_level_cfg.jianren + mount_grade_cfg.jianren)
	attr.per_pofang = 0
	attr.per_mianshang = 0

	return attr
end

function BeautyHaloData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.beauty_halo_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.beauty_halo_info.shuxingdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == BeautyHaloDanId.ZiZhiDanId then
			return true
		end
	end
	return false
end

function BeautyHaloData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.beauty_halo_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.beauty_halo_info.chengzhangdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(BeautyHaloDanId.ChengZhangDanId) > 0 then
		return true
	end

	return false
end

function BeautyHaloData:GetSpecialUpgradeAll()
	local beauty_halo_cfg = self:GetAllBeautyHaloCfg()
	if not self.beauty_halo_special_upgrade_all then
		self.beauty_halo_special_upgrade_all = beauty_halo_cfg.special_image_upgrade
	end
	return self.beauty_halo_special_upgrade_all
end

function BeautyHaloData:CanHuanhuaUpgrade()
	local list = {}
	if self.beauty_halo_info.grade == nil or self.beauty_halo_info.grade <= 0 then return list end
	if self.beauty_halo_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialUpgradeAll()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.beauty_halo_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.beauty_halo_info.special_img_grade_list[j.special_img_id] < self:GetMaxSpecialImageCfgById(j.special_img_id) then
			list[j.special_img_id] = j.special_img_id
		end
	end
	return list
end

function BeautyHaloData:CanSkillUpLevelList()
	local list = {}
	if self.beauty_halo_info.grade == nil or self.beauty_halo_info.grade <= 0 then return list end

	for i, j in pairs(self:GetSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.beauty_halo_info.show_grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function BeautyHaloData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetBeautyHaloSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function BeautyHaloData:CanJinjie()
	if self.beauty_halo_info.grade == nil or self.beauty_halo_info.grade <= 0 then return false end
	local cfg = self:GetBeautyHaloGradeCfg(self.beauty_halo_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.beauty_halo_info.grade < #self:GetGradeListCfg() then
			return true
		end
	end
	return false
end

function BeautyHaloData:GetMaxSpecialImageCfgById(id)
	local list = {}
	local count = 0
	if id == nil then return count end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if id == v.special_img_id then
	-- 		list[v.grade] = v
	-- 	end
	-- end

	local cfg = self:GetSpecialImageUpgradeCfg()
	if cfg ~= nil and cfg[id] then
		count = #cfg[id]
	end
	return count
end

function BeautyHaloData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function BeautyHaloData:GetCraftCfgById(craft_id)
	local craft_cfg = ConfigManager.Instance:GetAutoConfig("aircraftcfg_auto")
	if craft_cfg then
		return craft_cfg.aircraft[craft_id]
	end
end

function BeautyHaloData:GetBeautyHaloGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetImageCfg()
	if not image_list then return 0 end
	if not image_list[used_imageid] then print_error("坐骑形象配置没有image_id:", used_imageid) return 0 end

	local show_grade = image_list[used_imageid].show_grade
	for k, v in pairs(self:GetGradeCfg()) do
		if v.show_grade == show_grade then
			return v.show_grade
		end
	end
	return 0
end

function BeautyHaloData:IsActiviteBeautyHalo()
	local active_flag = self.beauty_halo_info and self.beauty_halo_info.active_image_flag or {}
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function BeautyHaloData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function BeautyHaloData:GetLastGrade()
	return self.last_grade
end

function BeautyHaloData:ChangeShowInfo()
	self.show_bless = self.beauty_halo_info.grade_bless_val
end

function BeautyHaloData:GetShowBless()
	return self.show_bless or self.last_bless
end

function BeautyHaloData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("meiren_guanghuan") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or next(self:CanSkillUpLevelList()) ~= nil or self:CanJinjie() or self:CalEquipBtnRemind() or AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.BEAUTY_HALO)) then
		return 1
	end
	return 0
end

function BeautyHaloData:CalEquipRemind(equip_index)
	if nil == self.beauty_halo_info or nil == next(self.beauty_halo_info) then
		return 0
	end

	local equip_level = self.beauty_halo_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

-- 计算装备按钮的红点
function BeautyHaloData:CalEquipBtnRemind()
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

function BeautyHaloData:GetOhterCfg()
	return self:GetAllBeautyHaloCfg().other[1]
end

function BeautyHaloData:IsOpenEquip()
	if nil == self.beauty_halo_info or nil == next(self.beauty_halo_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.beauty_halo_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function BeautyHaloData:GetNextPercentAttrCfg(equip_index)
	if nil == self.beauty_halo_info or nil == next(self.beauty_halo_info) then
		return
	end

	local equip_level = self.beauty_halo_info.equip_level_list[equip_index] or 0
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

function BeautyHaloData:GetEquipMinLevel()
	if nil == self.beauty_halo_info or nil == next(self.beauty_halo_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.beauty_halo_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end


function BeautyHaloData:IsActiveEquipSkill()
	if nil == self.beauty_halo_info or nil == next(self.beauty_halo_info) then
		return false
	end
	return self.beauty_halo_info.equip_skill_level > 0
end