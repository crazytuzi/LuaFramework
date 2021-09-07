FaBaoData = FaBaoData or BaseClass()

FaBaoDanId = {
		ChengZhangDanId = 22120,
		ZiZhiDanId = 22120,
}

FaBaoShuXingDanCfgType = {
		Type = 20
}

FaBaoDataEquipId = {
	-- 16200, 16210, 16220, 16230
}

function FaBaoData:__init()
	if FaBaoData.Instance then
		print_error("[FaBaoData] Attemp to create a singleton twice !")
	end
	FaBaoData.Instance = self

	self.level_cfg = nil
	self.grade_cfg = nil
	self.special_img_cfg = nil
	self.special_image_upgrade_list = nil
	self.fabao_skill_cfg = nil
	self.image_list_cfg = nil
	self.fabao_equip_cfg = nil
	self.equip_exp_cfg = nil
	self.up_star_exp_cfg = nil
	self.skill_id_cfg = nil
	-- self.fabao_cfg = nil
	self.equip_info_cfg = nil

	self.fabao_info = {}
	self.last_bless = 0
	self.last_grade = 0

	RemindManager.Instance:Register(RemindName.DressUpFaBao, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function FaBaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DressUpFaBao)
	if FaBaoData.Instance then
		FaBaoData.Instance = nil
	end
	self.fabao_info = {}
end

function FaBaoData:SetFaBaoInfo(protocol)
	self:SetLastInfo(self.fabao_info.grade_bless_val, self.fabao_info.grade)
	self.fabao_info.fabao_level = protocol.fabao_level
	self.fabao_info.grade = protocol.grade
	self.fabao_info.grade_bless_val = protocol.grade_bless_val
	self.fabao_info.clear_upgrade_time = protocol.clear_upgrade_time
	self.fabao_info.used_imageid = protocol.used_imageid
	self.fabao_info.shuxingdan_count = protocol.shuxingdan_count
	self.fabao_info.chengzhangdan_count = protocol.chengzhangdan_count
	self.fabao_info.active_image_flag = protocol.active_image_flag
	self.fabao_info.active_special_image_flag = protocol.active_special_image_flag
	-- self.fabao_info.active_special_image_list = bit:d2b(self.fabao_info.active_special_image_flag)
	self.fabao_info.active_special_image_list = self.fabao_info.active_special_image_flag

	self.fabao_info.show_grade = math.ceil(protocol.grade / 10)
	self.fabao_info.star_level = protocol.grade % 10

	self.fabao_info.equip_info_list = protocol.equip_info_list
	self.fabao_info.skill_level_list = protocol.skill_level_list
	self.fabao_info.special_img_grade_list = protocol.special_img_grade_list

	self.fabao_info.equip_skill_level = protocol.equip_skill_level
	self.fabao_info.equip_level_list = protocol.equip_level_list
end

function FaBaoData:GetFaBaoInfo()
	return self.fabao_info
end

function FaBaoData:GetAllFaBaoCfg()
	return ConfigManager.Instance:GetAutoConfig("ugs_fabao_auto") or {}
end

function FaBaoData:GetCurFaBaoCfg(grade)
	if not grade then return end
	local cfg = self:GetGradeCfg()
	return cfg[grade]
end

--形象进阶+幻化的战力
function FaBaoData:GetFaBaoPower()
	local cfg = self:GetCurFaBaoCfg(self.fabao_info.grade)
	local upgrade_power = CommonDataManager.GetCapabilityCalculation(cfg or {})
	local huanhua_power = 0
	for k,v in pairs(self.fabao_info.active_special_image_list) do
		if v == 1 then
			local index = k
			local huanhua_cfg = self:GetSpecialImageUpgradeInfo(index)
			huanhua_power = huanhua_power + CommonDataManager.GetCapabilityCalculation(huanhua_cfg)
		end
	end
	return huanhua_power + upgrade_power
end

function FaBaoData:GetAllFaBaoLevelCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.level_cfg then
		self.level_cfg = ListToMap(fabao_cfg.level, "fabao_level")
	end
	return self.level_cfg
end

function FaBaoData:GetFaBaoLevelCfg(fabao_level)
	--local fabao_config = ConfigManager.Instance:GetAutoConfig("fabao_auto")
	if fabao_level == nil then
		return nil
	end

	if fabao_level >= self:GetMaxFaBaoLevelCfg() then
		fabao_level = self:GetMaxFaBaoLevelCfg()
	end
	--return fabao_config.level[fabao_level]
	return self:GetAllFaBaoLevelCfg()[fabao_level]
end

function FaBaoData:GetMaxFaBaoLevelCfg()
	--return #ConfigManager.Instance:GetAutoConfig("fabao_auto").level
	return #self:GetAllFaBaoLevelCfg()
end

function FaBaoData:GetFaBaoShowGradeCfg(fabao_grade)
	--local fabao_config = ConfigManager.Instance:GetAutoConfig("fabao_auto")
	--return fabao_config.grade[fabao_grade * 10]
	if fabao_grade ~= nil then
		return self:GetGradeCfg()[fabao_grade * 10]
	end

	return nil
end

function FaBaoData:GetFaBaoGradeCfg(fabao_grade)
	-- local fabao_config = ConfigManager.Instance:GetAutoConfig("fabao_auto")
	-- return fabao_config.grade[fabao_grade]
	if fabao_grade ~= nil then
		return self:GetGradeCfg()[fabao_grade]
	end

	return nil
end

function FaBaoData:GetSpecialImagesCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.special_img_cfg then
		self.special_img_cfg = fabao_cfg.special_img
	end
	return self.special_img_cfg
end

function FaBaoData:GetSpecialImageCfg(image_id)
	-- local fabao_config = ConfigManager.Instance:GetAutoConfig("fabao_auto").special_img
	-- return fabao_config[image_id]
	if image_id ~= nil then
		return self:GetSpecialImagesCfg()[image_id]
	end

	return nil
end

function FaBaoData:GetMaxGrade()
	--return #ConfigManager.Instance:GetAutoConfig("fabao_auto").grade / 10
	return #self:GetGradeCfg() / 10
end

function FaBaoData:GetGradeCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.grade_cfg then
		self.grade_cfg = ListToMap(fabao_cfg.grade, "grade")
	end
	return self.grade_cfg
end

function FaBaoData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("fabao_auto").special_img
	return #self:GetSpecialImagesCfg()
end

function FaBaoData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.fabao_info.active_special_image_list or {}
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

function FaBaoData:GetFaBaoIsActive(image_id)
	return self.fabao_info.active_special_image_list[image_id] ~= 0
end

function FaBaoData:CheckIsHuanHuaItem(item_id)
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

function FaBaoData:GetSpecialImageUpgradeCfg()
	return ConfigManager.Instance:GetAutoConfig("ugs_fabao_auto").special_image_upgrade
end

function FaBaoData:GetSpecialImageUpgradeListCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.special_image_upgrade_list then
		self.special_image_upgrade_list = ListToMapList(fabao_cfg.special_image_upgrade, "special_img_id")
	end
	return self.special_image_upgrade_list
end

function FaBaoData:GetSpecialImageUpgradeList(special_img_id)
	if special_img_id ~= nil then
		return self:GetSpecialImageUpgradeListCfg()[special_img_id]
	end
	return nil
end

function FaBaoData:GetFaBaoSkillCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.fabao_skill_cfg then
		self.fabao_skill_cfg = fabao_cfg.skill
	end
	return self.fabao_skill_cfg
end

function FaBaoData:GetImageListCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.image_list_cfg then
		self.image_list_cfg = ListToMap(fabao_cfg.image_list, "image_id")
	end
	return self.image_list_cfg
end

function FaBaoData:GetFaBaoImageCfg(image_id)
	--return ConfigManager.Instance:GetAutoConfig("fabao_auto").image_list
	if image_id ~= nil then
		return self:GetImageListCfg()[image_id]
	end

	return nil
end

function FaBaoData:GetSingleFaBaoImageCfg(image_id)
	return ConfigManager.Instance:GetAutoConfig("ugs_fabao_auto").image_list[image_id]
end

function FaBaoData:GetFaBaoEquipCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.fabao_equip_cfg then
		self.fabao_equip_cfg = fabao_cfg.fabao_equip
	end
	return self.fabao_equip_cfg
end

function FaBaoData:GetFaBaoEquipExpCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.equip_exp_cfg then
		self.equip_exp_cfg = fabao_cfg.equip_exp
	end
	return self.equip_exp_cfg
end

function FaBaoData:GetFaBaoEquipRandAttr()
	return ConfigManager.Instance:GetAutoConfig("ugs_fabao_auto").equip_attr_range
end

function FaBaoData:GetAllFaBaoUpStarExpCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.up_star_exp_cfg then
		self.up_star_exp_cfg = ListToMap(fabao_cfg.up_star_exp, "star_level")
	end
	return self.up_star_exp_cfg
end

function FaBaoData:GetFaBaoUpStarExpCfg(star_level)
	--return ConfigManager.Instance:GetAutoConfig("fabao_auto").up_star_exp
	if star_level ~= nil then
		return self:GetAllFaBaoUpStarExpCfg()[star_level]
	end
	return nil
end

function FaBaoData:GetFaBaoSkillId()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.skill_id_cfg then
		self.skill_id_cfg = fabao_cfg.skill_id
	end
	return self.skill_id_cfg
end

-- 获取当前点击坐骑特殊形象的配置
function FaBaoData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade
	if grade == nil and self.fabao_info ~= nil and self.fabao_info.special_img_grade_list ~= nil then
		grade = self.fabao_info.special_img_grade_list[index] or 0
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
function FaBaoData:GetSpecialImageMaxUpLevelById(image_id)
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
function FaBaoData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	-- for k, v in pairs(self:GetFaBaoImageCfg()) do
	-- 	if v.image_id == index then
	-- 		return v
	-- 	end
	-- end

	return self:GetFaBaoImageCfg(index)
end

function FaBaoData:GetImageIdByRes(res_id)
	-- for k,v in pairs(self:GetFaBaoImageCfg()) do
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
function FaBaoData:GetFaBaoSkillCfgById(skill_idx, level, fabao_info)
	local skill_id_list = self:GetFaBaoSkillId()
	local skill_id = 0
	for k,v in pairs(skill_id_list) do
		if v.skill_id % 10 == skill_idx + 1 then
			skill_id = v.skill_id
			break
		end
	end
	local level = level or SkillData.Instance:GetSkillInfoById(skill_id) and SkillData.Instance:GetSkillInfoById(skill_id).level or 0
	for k, v in pairs(self:GetFaBaoSkillCfg()) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end

	return nil
end

function FaBaoData:GetFaBaoSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetFaBaoSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end

-- 获取特殊形象总增加的属性
function FaBaoData:GetSpecialImageAttrSum(fabao_info)
	fabao_info = fabao_info or self.fabao_info
	local sum_attr_list = CommonStruct.Attribute()
	local active_flag = fabao_info.active_special_image_flag
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
	if self:GetFaBaoGradeCfg(fabao_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetFaBaoGradeCfg(fabao_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetFaBaoGradeCfg(fabao_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetFaBaoGradeCfg(fabao_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获得已学习的技能总战力
function FaBaoData:GetFaBaoSkillAttrSum(fabao_info)
	local attr_list = CommonStruct.Attribute()
	for i = 0, 3 do
		local skill_cfg = self:GetFaBaoSkillCfgById(i, nil, fabao_info)
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
function FaBaoData:GetFaBaoEquipAttrSum(fabao_info)
	fabao_info = fabao_info or self.fabao_info
	local attr_list = CommonStruct.Attribute()
	if nil == fabao_info.equip_level_list then return attr_list end
	for k, v in pairs(fabao_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
end

-- 获取已吃成长丹，资质丹属性
function FaBaoData:GetDanAttr(fabao_info)
	fabao_info = fabao_info or self.fabao_info
	if fabao_info.fabao_level >= self:GetMaxFaBaoLevelCfg() then
		fabao_info.fabao_level = self:GetMaxFaBaoLevelCfg()
	end

	local attr_list = CommonStruct.Attribute()
	local fabao_level_cfg = self:GetFaBaoLevelCfg(fabao_info.fabao_level)
	local fabao_grade_cfg = self:GetFaBaoGradeCfg(fabao_info.grade)
	if not fabao_grade_cfg then print_error("光环配置表为空", fabao_info.grade) return attr_list end
	-- attr_list.gong_ji = math.floor((fabao_level_cfg.gongji + fabao_grade_cfg.gongji) * fabao_info.chengzhangdan_count * 0.01)
	-- attr_list.fang_yu = math.floor((fabao_level_cfg.fangyu + fabao_grade_cfg.fangyu) * fabao_info.chengzhangdan_count * 0.01)
	-- attr_list.max_hp = math.floor((fabao_level_cfg.maxhp + fabao_grade_cfg.maxhp) * fabao_info.chengzhangdan_count * 0.01)
	-- attr_list.ming_zhong = math.floor((fabao_level_cfg.mingzhong + fabao_grade_cfg.mingzhong) * fabao_info.chengzhangdan_count * 0.01)
	-- attr_list.shan_bi = math.floor((fabao_level_cfg.shanbi + fabao_grade_cfg.shanbi) * fabao_info.chengzhangdan_count * 0.01)
	-- attr_list.bao_ji = math.floor((fabao_level_cfg.baoji + fabao_grade_cfg.baoji) * fabao_info.chengzhangdan_count * 0.01)
	-- attr_list.jian_ren = math.floor((fabao_level_cfg.jianren + fabao_grade_cfg.jianren) * fabao_info.chengzhangdan_count * 0.01)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == FaBaoShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * fabao_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * fabao_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * fabao_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

function FaBaoData:GetFaBaoAttrSum(fabao_info)
	fabao_info = fabao_info or self:GetFaBaoInfo()
	local attr = CommonStruct.Attribute()

	if nil == fabao_info.grade or fabao_info.grade <= 0 or fabao_info.fabao_level < 1 then
		return attr
	end

	if fabao_info.fabao_level >= self:GetMaxFaBaoLevelCfg() then
		fabao_info.fabao_level = self:GetMaxFaBaoLevelCfg()
	end
	local fabao_level_cfg = self:GetFaBaoLevelCfg(fabao_info.fabao_level)
	local fabao_grade_cfg = self:GetFaBaoGradeCfg(fabao_info.grade)
	local star_cfg = self:GetFaBaoStarLevelCfg(fabao_info.star_level)

	if not fabao_grade_cfg or not star_cfg then return attr end

	-- local fabao_next_grade_cfg = self:GetFaBaoGradeCfg(fabao_info.grade + 1)
	local skill_attr = self:GetFaBaoSkillAttrSum(fabao_info)
	-- local equip_attr = self:GetFaBaoEquipAttrSum(fabao_info)
	local dan_attr = self:GetDanAttr(fabao_info)
	local differ_value = CommonStruct.Attribute()
	local special_img_attr = self:GetSpecialImageAttrSum(fabao_info)
	local medal_percent = MedalData.Instance:GetMedalSuitActiveCfg() and MedalData.Instance:GetMedalSuitActiveCfg().fabao_attr_add / 10000 or 0

	-- if 	fabao_next_grade_cfg ~= nil then												-- 临时属性加成
	-- 	differ_value.max_hp = fabao_next_grade_cfg.maxhp - fabao_grade_cfg.maxhp
	-- 	differ_value.gong_ji = fabao_next_grade_cfg.gongji - fabao_grade_cfg.gongji
	-- 	differ_value.fang_yu = fabao_next_grade_cfg.fangyu - fabao_grade_cfg.fangyu
	-- 	differ_value.ming_zhong = fabao_next_grade_cfg.mingzhong - fabao_grade_cfg.mingzhong
	-- 	differ_value.shan_bi = fabao_next_grade_cfg.shanbi - fabao_grade_cfg.shanbi
	-- 	differ_value.bao_ji = fabao_next_grade_cfg.baoji - fabao_grade_cfg.baoji
	-- 	differ_value.jian_ren = fabao_next_grade_cfg.jianren - fabao_grade_cfg.jianren
	-- end

	-- local temp_attr_per = fabao_info.grade_bless_val/fabao_grade_cfg.bless_val_limit

	attr.max_hp = (fabao_level_cfg.maxhp
				+ star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * fabao_grade_cfg.bless_addition /10000
				+ skill_attr.max_hp
				-- + equip_attr.max_hp
				+ dan_attr.max_hp
				+ special_img_attr.max_hp)
				+ (medal_percent) * (fabao_level_cfg.maxhp + star_cfg.maxhp)

	attr.gong_ji = (fabao_level_cfg.gongji
				+ star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * fabao_grade_cfg.bless_addition /10000
				+ skill_attr.gong_ji
				-- + equip_attr.gong_ji
				+ dan_attr.gong_ji
				+ special_img_attr.gong_ji)
				+ (medal_percent) * (fabao_level_cfg.gongji + star_cfg.gongji)

	attr.fang_yu = (fabao_level_cfg.fangyu
				+ star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * fabao_grade_cfg.bless_addition /10000
				+ skill_attr.fang_yu
				-- + equip_attr.fang_yu
				+ dan_attr.fang_yu
				+ special_img_attr.fang_yu)
				+ (medal_percent) * (fabao_level_cfg.fangyu + star_cfg.fangyu)

	attr.ming_zhong = (fabao_level_cfg.mingzhong
					+ star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * fabao_grade_cfg.bless_addition /10000
					+ skill_attr.ming_zhong
					-- + equip_attr.ming_zhong
					+ dan_attr.ming_zhong
					+ special_img_attr.ming_zhong)
					+ (medal_percent) * (fabao_level_cfg.mingzhong + star_cfg.mingzhong)

	attr.shan_bi = (fabao_level_cfg.shanbi
				+ star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * fabao_grade_cfg.bless_addition /10000
				+ skill_attr.shan_bi
				-- + equip_attr.shan_bi
				+ dan_attr.shan_bi
				+ special_img_attr.shan_bi)
				+ (medal_percent) * (fabao_level_cfg.shanbi + star_cfg.shanbi)

	attr.bao_ji = (fabao_level_cfg.baoji
				+ star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * fabao_grade_cfg.bless_addition /10000
				+ skill_attr.bao_ji
				-- + equip_attr.bao_ji
				+ dan_attr.bao_ji
				+ special_img_attr.bao_ji)
				+ (medal_percent) * (fabao_level_cfg.baoji + star_cfg.baoji)

	attr.jian_ren = (fabao_level_cfg.jianren
				+ star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * fabao_grade_cfg.bless_addition /10000
				+ skill_attr.jian_ren
				-- + equip_attr.jian_ren
				+ dan_attr.jian_ren
				+ special_img_attr.jian_ren)
				+ (medal_percent) * (fabao_level_cfg.jianren + star_cfg.jianren)

	return attr
end

function FaBaoData:GetFaBaoStarLevelCfg(star_level)
	local star_level = star_level or self.fabao_info.star_level

	-- for k, v in pairs(self:GetFaBaoUpStarExpCfg()) do
	-- 	if v.star_level == star_level then
	-- 		return v
	-- 	end
	-- end
	if star_level ~= nil then
		return self:GetFaBaoUpStarExpCfg(star_level)
	end

	return nil
end

function FaBaoData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.fabao_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.fabao_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(FaBaoDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function FaBaoData:IsShowChengzhangRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().chengzhangdan_count
	if self.fabao_info.chengzhangdan_count == nil or count_limit == nil then
		return false
	end
	if self.fabao_info.chengzhangdan_count >= count_limit then
		return false
	end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		if v.item_id == FaBaoDanId.ChengZhangDanId then
			return true
		end
	end
	return false
end

function FaBaoData:CanHuanhuaUpgrade()
	local list = {}
	if self.fabao_info.grade == nil or self.fabao_info.grade <= 0 then return list end
	if self.fabao_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.fabao_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.fabao_info.special_img_grade_list[j.special_img_id] < self:GetMaxSpecialImageCfgById(j.special_img_id)then
			list[j.special_img_id] = j.special_img_id
		end
	end

	return list
end

function FaBaoData:CanSkillUpLevelList()
	local list = {}
	if self.fabao_info.grade == nil or self.fabao_info.grade <= 0 then return list end

	for i, j in pairs(self:GetFaBaoSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.fabao_info.show_grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end

	return list
end

function FaBaoData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetFaBaoSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function FaBaoData:CanJinjie()
	if self.fabao_info.grade == nil or self.fabao_info.grade <= 0 then return false end
	local cfg = self:GetFaBaoGradeCfg(self.fabao_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.fabao_info.grade < #self:GetGradeCfg() then
			return true
		end
	end
	return false
end

function FaBaoData:GetAllEquipInfoCfg()
	local fabao_cfg = self:GetAllFaBaoCfg()
	if nil == self.equip_info_cfg then
		self.equip_info_cfg = ListToMap(fabao_cfg.equip_info, "equip_idx", "equip_level")
	end
	return self.equip_info_cfg
end

function FaBaoData:GetEquipInfoCfg(equip_index, level)
	if nil == self:GetAllEquipInfoCfg()[equip_index] then
		return
	end
	return self:GetAllEquipInfoCfg()[equip_index][level]
end

function FaBaoData:GetMaxSpecialImageCfgById(id)
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

function FaBaoData:GetChengzhangDanLimit()
	for i = 1, self:GetMaxGrade() do
		if self:GetGradeCfg()[i] and self:GetGradeCfg()[i].chengzhangdan_limit > 0 then
			return self:GetGradeCfg()[i]
		end
	end
	return nil
end

function FaBaoData:GetFaBaoGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetFaBaoImageCfg(used_imageid)
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

function FaBaoData:IsActiviteFaBao()
	local active_flag = self.fabao_info and self.fabao_info.active_image_flag or {}
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function FaBaoData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function FaBaoData:GetLastGrade()
	return self.last_grade
end

function FaBaoData:ChangeShowInfo()
	self.show_bless = self.fabao_info.grade_bless_val
end

function FaBaoData:GetShowBless()
	return self.show_bless or self.last_bless
end

function FaBaoData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("fabao") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or next(self:CanSkillUpLevelList()) ~= nil or self:CalEquipBtnRemind() or self:CanJinjie()) then -- or AdvanceSkillData.Instance:ShowSkillRedPoint(ADVANCE_SKILL_TYPE.fabao)) then
		return 1
	end
	return 0
end

function FaBaoData:CalEquipRemind(equip_index)
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return 0
	end

	local equip_level = self.fabao_info.equip_level_list[equip_index] or 0
	local equip_cfg = self:GetEquipInfoCfg(equip_index, equip_level + 1)
	if nil == equip_cfg then return 0 end

	local item_data = equip_cfg.item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

	return had_prop_num >= item_data.num and 1 or 0
end

-- 计算装备按钮的红点
function FaBaoData:CalEquipBtnRemind()
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

function FaBaoData:GetOhterCfg()
	return self.GetAllFaBaoCfg().other[1]
end

function FaBaoData:IsOpenEquip()
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.fabao_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function FaBaoData:GetNextPercentAttrCfg(equip_index)
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return
	end

	local equip_level = self.fabao_info.equip_level_list[equip_index] or 0
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

function FaBaoData:GetEquipMinLevel()
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return 0
	end
	local min_level = 999
	for k, v in pairs(self.fabao_info.equip_level_list) do
		if min_level > v then
			min_level = v
		end
	end
	return min_level
end

function FaBaoData:IsActiveEquipSkill()
	if nil == self.fabao_info or nil == next(self.fabao_info) then
		return false
	end
	return self.fabao_info.equip_skill_level > 0
end

function FaBaoData:GetShowFaBaoRes(grade)
	local grade = grade
	local fabao_grade_cfg = self:GetFaBaoGradeCfg(grade)
	local image_cfg = nil
	if fabao_grade_cfg then
		image_cfg = self:GetFaBaoImageCfg(fabao_grade_cfg.image_id)
	end
	if self.fabao_info.used_imageid < 1000 then
		if image_cfg then
			return image_cfg.res_id
		end
		return -1
	end
	if grade == self.fabao_info.grade then
		return self:GetSpecialImageCfg(self.fabao_info.used_imageid - 1000).res_id
	else
		if image_cfg then
			return image_cfg.res_id
		end
		return -1
	end
end

function FaBaoData:GetResIdByImgId(img_id)
	if not img_id then return 0 end
	local image_list = self:GetFaBaoImageCfg(img_id)
	if not image_list then print_error("光环形象配置没有image_id:", img_id) return 0 end
	return image_list.res_id or 0
end

function FaBaoData:GetSpecialResId(img_id)
	if not img_id then return 0 end
	local special_cfg = self:GetSpecialImageCfg(img_id)
	local res_id = special_cfg and special_cfg.res_id or 0
	return res_id
end