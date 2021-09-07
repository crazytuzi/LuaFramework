HalidomData = HalidomData or BaseClass()

HalidomDanId = {
		ChengZhangDanId = 22113,
		ZiZhiDanId = 22114,
}

HalidomShuXingDanCfgType = {
		Type = 13
}

function HalidomData:__init()
	if HalidomData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	HalidomData.Instance = self

	self.mount_level_cfg = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").level, "mount_level")
	self.grade_cfg = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").grade, "grade")
	self.special_img_cfg = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_img, "image_id")
	self.all_special_img_list = nil  --ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_img
	self.special_image_upgrade_cfg = nil	--ListToMapList(ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_image_upgrade, "special_img_id")
	self.skill_cfg = nil	--ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").skill
	self.image_list = nil	--ListToMap(ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").image_list, "image_id")

	-- self.shenyi_cfg = ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto")
	self.equip_info_cfg = nil	--ListToMap(self.shenyi_cfg.equip_info, "equip_idx", "equip_level")
	self.halidom_info = {}

	self.temp_img_id = 0
	self.temp_img_id_has_select = 0
	self.temp_img_time = 0

	self.last_bless = 0
	self.last_grade = 0

	RemindManager.Instance:Register(RemindName.AdvanceHalidom, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function HalidomData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceHalidom)
	HalidomData.Instance = nil
	self.halidom_info = {}
end

function HalidomData:SetHalidomInfo(protocol)
	-- self.halidom_info.mount_flag = protocol.mount_flag
	-- self.halidom_info.mount_level = protocol.mount_level
	-- self.halidom_info.grade = protocol.grade
	-- self.halidom_info.grade_bless_val = protocol.grade_bless_val
	-- self.halidom_info.clear_upgrade_time = protocol.clear_upgrade_time
	-- self.halidom_info.used_imageid = protocol.used_imageid
	-- self.halidom_info.shuxingdan_count = protocol.shuxingdan_count
	-- self.halidom_info.chengzhangdan_count = protocol.chengzhangdan_count
	-- self.halidom_info.active_image_flag = protocol.active_image_flag
	-- self.halidom_info.active_special_image_flag = protocol.active_special_image_flag

	-- self.halidom_info.equip_info_list = protocol.equip_info_list
	-- self.halidom_info.skill_level_list = protocol.skill_level_list
	-- self.halidom_info.special_img_grade_list = protocol.special_img_grade_list

	self:SetLastInfo(self.halidom_info.grade_bless_val, self.halidom_info.grade)
	self.halidom_info.grade = protocol.grade
	self.halidom_info.used_imageid = protocol.used_imageid
	self.halidom_info.active_image_flag = protocol.active_image_flag
	self.halidom_info.grade_bless_val = protocol.grade_bless_val
	self.halidom_info.active_special_image_flag = protocol.active_special_image_flag
	self.halidom_info.active_special_image_list = bit:d2b(self.halidom_info.active_special_image_flag)
	self.halidom_info.special_img_grade_list = protocol.special_img_grade_list

	self.halidom_info.show_grade = math.ceil(protocol.grade / 10)
	self.halidom_info.star_level = protocol.grade % 10

	self.halidom_info.mount_level = 999
	self.halidom_info.shuxingdan_count = protocol.shuxingdan_count
	self.halidom_info.chengzhangdan_count = 0
	self.halidom_info.equip_info_list = {}
	self.halidom_info.skill_level_list = {}

	self.halidom_info.equip_skill_level = protocol.equip_skill_level
	self.halidom_info.equip_level_list = protocol.equip_level_list
	-- self.temp_img_id = protocol.temp_img_id
	-- self.temp_img_id_has_select = protocol.temp_img_id_has_select
	-- self.temp_img_time = protocol.temp_img_time
end

function HalidomData:GetAllHalidomCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto") or {}
end

function HalidomData:IsShowTempIcon()
	if self.temp_img_id_has_select == 0 and self.temp_img_time ~= 0 then
		return false
	end
	return true
end

function HalidomData:GetCurHalidomCfg(grade)
	if not grade then return end
	local cfg = self:GetGradeCfg()
	return cfg[grade]
end

--形象进阶+幻化的战力
function HalidomData:GetHalidomPower()
	local cfg = self:GetCurHalidomCfg(self.halidom_info.grade)
	local upgrade_power = CommonDataManager.GetCapabilityCalculation(cfg or {})
	local huanhua_power = 0
	for k,v in pairs(self.halidom_info.active_special_image_list) do
		if v == 1 then																--判断各幻化是否激活
			local index = 32 - k														
			local huanhua_cfg = self:GetSpecialImageUpgradeInfo(index)
			huanhua_power = huanhua_power + CommonDataManager.GetCapabilityCalculation(huanhua_cfg)
		end
	end
	return huanhua_power + upgrade_power
end

function HalidomData:GetTempTime()
	return self.temp_img_time
end

function HalidomData:HasChooseTemp()
	return self.temp_img_id_has_select ~= 0
end

function HalidomData:GetTempImgId()
	return self.temp_img_id_has_select
end

function HalidomData:GetHalidomInfo()
	return self.halidom_info
end

function HalidomData:GethalidomLevelCfg()
	if not self.mount_level_cfg then
		self.mount_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").level, "mount_level")
	end
	return self.mount_level_cfg
end

function HalidomData:GetLevelCfg(mount_level)
	--local mount_config = ConfigManager.Instance:GetAutoConfig("mount_auto")
	if mount_level ~= nil then
		return
	end

	if mount_level >= self:GetMaxLevelCfg() then
		mount_level = self:GetMaxLevelCfg()
	end
	--return mount_config.level[mount_level]
	return self:GethalidomLevelCfg()[mount_level]
end

function HalidomData:GetMaxLevelCfg()
	return #self:GethalidomLevelCfg()
end

function HalidomData:GetShowHalidomGradeCfg(mount_grade)
	-- local mount_config = ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto")
	-- return mount_config.grade[mount_grade * 10]
	if mount_grade ~= nil then
		return self:GetGradeCfg()[mount_grade * 10]
	end

	return nil
end

function HalidomData:GetHalidomGradeCfg(mount_grade)
	-- local mount_config = ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto")
	-- return mount_config.grade[mount_grade]
	if mount_grade ~= nil then
		return self:GetGradeCfg()[mount_grade]
	end

	return nil
end

-- 获得已升级装备战力
function HalidomData:GetShenyiEquipAttrSum(shenyi_info)
	shenyi_info = shenyi_info or self.halidom_info
	local attr_list = CommonStruct.Attribute()
	if nil == shenyi_info.equip_level_list then return attr_list end
	for k, v in pairs(shenyi_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

function HalidomData:GethalidomSpecialImageCfg()
	local halidom_cfg = self:GetAllHalidomCfg()
	if not self.special_img_cfg then
		self.special_img_cfg = ListToMap(halidom_cfg.special_img, "image_id")
	end
	return self.special_img_cfg
end

function HalidomData:GetSpecialImageCfg(image_id)
	-- local mount_config = ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_img
	-- return mount_config[image_id]
	if image_id ~= nil then
		return self:GethalidomSpecialImageCfg()[image_id]
	end
	return nil
end

function HalidomData:CalEquipRemind(equip_index)
	if nil == self.halidom_info or nil == next(self.halidom_info) then
		return 0
	end

	local equip_level = self.halidom_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

-- 计算装备按钮的红点
function HalidomData:CalEquipBtnRemind()
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

function HalidomData:GetShenyiImageCfg()
	return self.halidom_info.image_list
end

function HalidomData:GetShengWuGradeCfg()
	local halidom_cfg = self:GetAllHalidomCfg()
	if not self.halidom_grade_cfg then
		self.halidom_grade_cfg = halidom_cfg.grade
	end
	return self.halidom_grade_cfg
end

function HalidomData:GetShenyiGradeCfg(shenyi_grade)
	return self:GetShengWuGradeCfg()[shenyi_grade]
end

function HalidomData:GetShowShenyiRes(grade)
	local grade = grade
	local shenyi_grade_cfg = self:GetShenyiGradeCfg(grade)
	local image_cfg = nil
	if shenyi_grade_cfg then
		image_cfg = self:GetShenyiImageCfg()
	end
	if self.halidom_info.used_imageid < 1000 then
		if image_cfg then
			return image_cfg[shenyi_grade_cfg.image_id].res_id
		end
		return -1
	end
	if grade == self.halidom_info.grade then
		return self:GetSpecialImageCfg(self.halidom_info.used_imageid - 1000).res_id
	else
		if image_cfg then
			return image_cfg[shenyi_grade_cfg.image_id].res_id
		end
		return -1
	end
end

function HalidomData:GetCurShenyiRes()
	local grade = 0
	if self.halidom_info.used_imageid and self.halidom_info.used_imageid > 1000  then
		local cfg = self:GetSpecialImageCfg(self.halidom_info.used_imageid - 1000)
		if cfg then
			return cfg.res_id
		end
	else
		if self.halidom_info.used_imageid then
			grade = self:GetShenyiGradeByUseImageId(self.halidom_info.used_imageid)
			return self:GetShowShenyiRes(grade)
		end
	end
	return -1
end

function HalidomData:GetSpecialImagesCfg()
	local halidom_cfg = self:GetAllHalidomCfg()
	if not self.all_special_img_list then
		self.all_special_img_list = halidom_cfg.special_img
	end
	return self.all_special_img_list
end
function HalidomData:GetMaxGrade()
	--return #ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").grade / 10
	return #self:GetGradeCfg() / 10
end

function HalidomData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_img
	return #self:GetSpecialImagesCfg()
end

function HalidomData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.halidom_info.active_special_image_list or {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	for k,v in pairs(self:GetSpecialImagesCfg()) do
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

function HalidomData:GetHalidomIsActive(image_id)
	return self.halidom_info.active_special_image_list[32 - image_id] ~= 0
end

function HalidomData:CheckIsHuanHuaItem(item_id)
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

function HalidomData:GetSpecialImageUpgradeCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_image_upgrade
end

function HalidomData:GetSpecialListCfg()
	local halidom_cfg = self:GetAllHalidomCfg()
	if not self.special_image_upgrade_cfg then
		self.special_image_upgrade_cfg = ListToMapList(halidom_cfg.special_image_upgrade, "special_img_id")
	end
	return self.special_image_upgrade_cfg
end

function HalidomData:GetSpecialImageUpgradeList(special_img_id)
	if special_img_id ~= nil then
		return self:GetSpecialListCfg()[special_img_id]
	end

	return nil
end

function HalidomData:GetSkillCfg()
	local halidom_cfg = self:GetAllHalidomCfg()
	if not self.skill_cfg then
		self.skill_cfg = halidom_cfg.skill
	end
	return self.skill_cfg
end

function HalidomData:GetGradeCfg()
	local halidom_cfg = self:GetAllHalidomCfg()
	if not self.grade_cfg then
		self.grade_cfg = ListToMap(halidom_cfg.grade, "grade")
	end
	return self.grade_cfg
end

function HalidomData:GetImageListCfg()
	local halidom_cfg = self:GetAllHalidomCfg()
	if not self.image_list then
		self.image_list = ListToMap(halidom_cfg.image_list, "image_id")
	end
	return self.image_list
end

function HalidomData:GetImageCfg(image_id)
	if image_id ~= nil then
		return self:GetImageListCfg()[image_id]
	end
	return nil
end

function HalidomData:GetEquipCfg()
	return ConfigManager.Instance:GetAutoConfig("mount_auto").mount_equip
end

function HalidomData:GetEquipExpCfg()
	return ConfigManager.Instance:GetAutoConfig("mount_auto").equip_exp
end

function HalidomData:GetEquipRandAttr()
	return ConfigManager.Instance:GetAutoConfig("mount_auto").equip_attr_range
end

function HalidomData:GetHalidomSkillId()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").skill_id
end

-- 获取当前点击坐骑特殊形象的配置
function HalidomData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade
	if grade == nil and self.halidom_info ~= nil and self.halidom_info.special_img_grade_list ~= nil then
		grade = self.halidom_info.special_img_grade_list[index] or 0
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
function HalidomData:GetSpecialImageMaxUpLevelById(image_id)
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
function HalidomData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	if index ~= nil then
		local cfg = self:GetImageCfg(index)
		if cfg ~= nil then
			return cfg
		end
	end

	return nil
end

-- 获取当前点击坐骑技能的配置
function HalidomData:GetSkillCfgById(skill_idx, level, halidom_info)
	local halidom_info = halidom_info or self.halidom_info
	local skill_id_list = self:GetHalidomSkillId()
	local skill_id = 0
	for k,v in pairs(skill_id_list) do
		if v.skill_id % 10 == skill_idx + 1 then
			skill_id = v.skill_id
			break
		end
	end
	local level = level or SkillData.Instance:GetSkillInfoById(skill_id) and SkillData.Instance:GetSkillInfoById(skill_id).level or 0

	for k, v in pairs(self:GetSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

function HalidomData:GetHalidomSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end

-- 获取特殊形象总增加的属性丹和成长丹数量
function HalidomData:GetSpecialImageAttrSum(halidom_info)
	halidom_info = halidom_info or self.halidom_info
	local active_flag = halidom_info.active_special_image_flag
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
	if self:GetHalidomGradeCfg(halidom_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetHalidomGradeCfg(halidom_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetHalidomGradeCfg(halidom_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetHalidomGradeCfg(halidom_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总属性
function HalidomData:GetSkillAttrSum(halidom_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetSkillCfgById(i, nil, halidom_info)
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
function HalidomData:GetEquipAttrSum(shenyi_info)
	shenyi_info = shenyi_info or self.halidom_info
	local attr_list = CommonStruct.Attribute()
	if nil == shenyi_info.equip_level_list then return attr_list end
	for k, v in pairs(shenyi_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end


-- 获取已吃成长丹，资质丹属性
function HalidomData:GetDanAttr(halidom_info)
	halidom_info = halidom_info or self.halidom_info
	if halidom_info.mount_level >= self:GetMaxLevelCfg() then
		halidom_info.mount_level = self:GetMaxLevelCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local mount_level_cfg = self:GetLevelCfg(halidom_info.mount_level)
	local mount_grade_cfg = self:GetHalidomGradeCfg(halidom_info.grade)
	if not mount_grade_cfg then return attr_list end
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == ShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * halidom_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * halidom_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * halidom_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function HalidomData:GetAttrSum(halidom_info)
	halidom_info = halidom_info or self:GetHalidomInfo()
	if halidom_info.grade <= 0 or halidom_info.mount_level == 0 then
		return 0
	end

	if halidom_info.mount_level >= self:GetMaxLevelCfg() then
		halidom_info.mount_level = self:GetMaxLevelCfg()
	end

	local mount_level_cfg = self:GetLevelCfg(halidom_info.mount_level)
	local mount_grade_cfg = self:GetHalidomGradeCfg(halidom_info.grade)
	local mount_next_grade_cfg = self:GetHalidomGradeCfg(halidom_info.grade + 1)
	local skill_attr = self:GetSkillAttrSum(halidom_info)
	-- local equip_attr = self:GetEquipAttrSum(halidom_info)
	local dan_attr = self:GetDanAttr(halidom_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(halidom_info)
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

	local temp_attr_per = halidom_info.grade_bless_val/mount_grade_cfg.bless_val_limit

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

function HalidomData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.halidom_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.halidom_info.shuxingdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == HalidomDanId.ZiZhiDanId then
			return true
		end
	end
	return false
end

function HalidomData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.halidom_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.halidom_info.chengzhangdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(HalidomDanId.ChengZhangDanId) > 0 then
		return true
	end

	return false
end

function HalidomData:CanHuanhuaUpgrade()
	local list = {}
	if self.halidom_info.grade == nil or self.halidom_info.grade <= 0 then return list end
	if self.halidom_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.halidom_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.halidom_info.special_img_grade_list[j.special_img_id] < self:GetMaxSpecialImageCfgById(j.special_img_id) then
			list[j.special_img_id] = j.special_img_id
		end
	end
	return list
end

function HalidomData:CanSkillUpLevelList()
	local list = {}
	if self.halidom_info.grade == nil or self.halidom_info.grade <= 0 then return list end
	-- if self.halidom_info.skill_level_list == nil then
	-- 	return list
	-- end

	for i, j in pairs(self:GetSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.halidom_info.show_grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function HalidomData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetHalidomSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function HalidomData:CanJinjie()
	if self.halidom_info.grade == nil or self.halidom_info.grade <= 0 then return false end
	local cfg = self:GetHalidomGradeCfg(self.halidom_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.halidom_info.grade < #self:GetGradeCfg() then
			return true
		end
	end
	return false
end

function HalidomData:GetMaxSpecialImageCfgById(id)
	--local list = {}
	local count = 0
	if id == nil then return count end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if id == v.special_img_id then
	-- 		list[v.grade] = v
	-- 	end
	-- end

	if id ~= nil then
		local cfg = self:GetSpecialImageUpgradeList(id)
		count = #cfg - 1
	end
	return count
end

function HalidomData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function HalidomData:GetCraftCfgById(craft_id)
	local craft_cfg = ConfigManager.Instance:GetAutoConfig("aircraftcfg_auto")
	if craft_cfg then
		return craft_cfg.aircraft[craft_id]
	end
end

function HalidomData:GetHalidomGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
--	local image_list = self:GetImageCfg()
	--if not image_list then return 0 end
	local image_list = self:GetImageCfg(used_imageid)
	if not image_list then print_error("坐骑形象配置没有image_id:", used_imageid) return 0 end

	local show_grade = image_list.show_grade
	for k, v in pairs(self:GetGradeCfg()) do
		if v.show_grade == show_grade then
			return v.show_grade
		end
	end
	return 0
end

function HalidomData:IsActiviteHalidom()
	local active_flag = self.halidom_info and self.halidom_info.active_image_flag or {}
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function HalidomData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function HalidomData:GetLastGrade()
	return self.last_grade
end

function HalidomData:ChangeShowInfo()
	self.show_bless = self.halidom_info.grade_bless_val
end

function HalidomData:GetShowBless()
	return self.show_bless or self.last_bless
end

function HalidomData:GetNormalResId(image_id)
	-- local cfg = self:GetImageCfg()
	-- for k,v in pairs(cfg) do
	-- 	if image_id == v.image_id then
	-- 		return v.res_id
	-- 	end
	-- end
	if image_id ~= nil then
		local cfg = self:GetImageCfg(image_id)
		if cfg ~= nil then
			return cfg.res_id
		end
	end
	return 0
end

function HalidomData:GetSpecialResId(image_id)
	local cfg = self:GetSpecialImagesCfg()
	for k,v in pairs(cfg) do
		if image_id == v.image_id then
			return v.res_id
		end
	end
	return 0
end

function HalidomData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("halidom_jinjie") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or next(self:CanSkillUpLevelList()) ~= nil or self:CanJinjie() or self:CalEquipBtnRemind() or AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.HALIDOM)) then
		return 1
	end
	return 0
end

function HalidomData:GetEquipListCfg()
	local halidom_cfg = self:GetAllHalidomCfg()
	if not self.equip_info_cfg then
		self.equip_info_cfg = ListToMap(halidom_cfg.equip_info, "equip_idx", "equip_level")
	end
	return self.equip_info_cfg
end

function HalidomData:GetEquipInfoCfg(equip_index, level)
	if nil == self:GetEquipListCfg()[equip_index] then
		return
	end

	return self:GetEquipListCfg()[equip_index][level]
end

function HalidomData:GetOhterCfg()
	return self:GetAllHalidomCfg().other[1]
end


function HalidomData:IsOpenEquip()
	if nil == self.halidom_info or nil == next(self.halidom_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.halidom_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function HalidomData:GetNextPercentAttrCfg(equip_index)
	if nil == self.halidom_info or nil == next(self.halidom_info) then
		return
	end

	local equip_level = self.halidom_info.equip_level_list[equip_index] or 0
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

function HalidomData:GetEquipMinLevel()
	if nil == self.halidom_info or nil == next(self.halidom_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.halidom_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function HalidomData:IsActiveEquipSkill()
	if nil == self.halidom_info or nil == next(self.halidom_info) then
		return false
	end
	return self.halidom_info.equip_skill_level > 0
end