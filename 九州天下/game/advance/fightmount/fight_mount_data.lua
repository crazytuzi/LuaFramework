FightMountData = FightMountData or BaseClass()

FightMountDanId = {
		ChengZhangDanId = 22113,
		ZiZhiDanId = 22107,
}

FightMountShuXingDanCfgType = {
		Type = 10
}

function FightMountData:__init()
	if FightMountData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end
	FightMountData.Instance = self

	self.mount_info = {}
	self.last_bless = 0
	self.last_grade = 0

	self.level_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").level
	self.grade_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("fight_mount_auto").grade, "grade")
	self.show_grade_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("fight_mount_auto").grade, "show_grade")
	self.special_img_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_img
	self.special_image_upgrade_list = ListToMapList(ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_image_upgrade, "special_img_id")
	self.skill_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("fight_mount_auto").mount_skill, "skill_idx", "skill_level")
	self.image_list_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("fight_mount_auto").image_list, "image_id")
	self.skill_id_list = ConfigManager.Instance:GetAutoConfig("fight_mount_auto").skill_id

	self.mount_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto")
	self.equip_info_cfg = ListToMap(self.mount_cfg.mount_equip_info, "equip_idx", "equip_level")
	RemindManager.Instance:Register(RemindName.AdvanceFightMount, BindTool.Bind(self.GetInAdvanceRedNum, self))
end

function FightMountData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AdvanceFightMount)
	FightMountData.Instance = nil
end

function FightMountData:SetFightMountInfo(protocol)
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
	self.mount_info.active_special_image_flag = protocol.active_special_image_flag

	self.mount_info.show_grade = math.ceil(protocol.grade / 10)
	self.mount_info.star_level = protocol.grade % 10

	self.mount_info.equip_info_list = protocol.equip_info_list
	self.mount_info.skill_level_list = protocol.skill_level_list
	self.mount_info.special_img_grade_list = protocol.special_img_grade_list

	self.mount_info.equip_skill_level = protocol.equip_skill_level
	self.mount_info.equip_level_list = protocol.equip_level_list
end

function FightMountData:GetFightMountInfo()
	return self.mount_info
end

function FightMountData:GetMountLevelCfg(mount_level)
	if mount_level >= self:GetMaxMountLevelCfg() then
		mount_level = self:GetMaxMountLevelCfg()
	end
	--return ConfigManager.Instance:GetAutoConfig("fight_mount_auto").level[mount_level]

	return self.level_cfg[mount_level]
end

function FightMountData:GetMaxMountLevelCfg()
	return #self.level_cfg
end

function FightMountData:GetMountShowGradeCfg(mount_grade)
	return self.grade_cfg[mount_grade * 10]
	--return ConfigManager.Instance:GetAutoConfig("fight_mount_auto").grade[mount_grade * 10]
end

function FightMountData:GetMountGradeCfg(mount_grade)
	return self.grade_cfg[mount_grade]
	--return ConfigManager.Instance:GetAutoConfig("fight_mount_auto").grade[mount_grade]
end

function FightMountData:GetSpecialImagesCfg()
	return self.special_img_cfg
end

function FightMountData:GetSpecialImageCfg(image_id)
	return self.special_img_cfg[image_id]
end

function FightMountData:GetMaxGrade()
	--return #ConfigManager.Instance:GetAutoConfig("fight_mount_auto").grade
	return #self.grade_cfg
end

function FightMountData:GetMaxSpecialImage()
	--return #ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_img
	return #self.special_img_cfg
end

function FightMountData:GetSpecialImageUpgradeCfg()
	return ConfigManager.Instance:GetAutoConfig("fight_mount_auto").special_image_upgrade
end

function FightMountData:GetSpecialImageUpgradeList(special_img_id)
	if special_img_id ~= nil then
		return self.special_image_upgrade_list[special_img_id]
	end

	return nil
end

function FightMountData:GetFightMountSkillCfg()
	return ConfigManager.Instance:GetAutoConfig("fight_mount_auto").mount_skill
end

function FaZhenData:GetFightMountSkillList(skill_idx, skill_level)
	if skill_idx ~= nil and skill_level ~= nil then
		if self.skill_cfg[skill_idx] ~= nil then
			return self.skill_cfg[skill_idx][skill_level]
		end
	end

	return nil
end

function FightMountData:GetGradeCfg(show_grade)
	--return ConfigManager.Instance:GetAutoConfig("fight_mount_auto").grade
	if show_grade ~= nil then
		return self.show_grade_cfg[show_grade]
	end

	return nil
end

function FightMountData:GetMountImageCfg(image_id)
	--return ConfigManager.Instance:GetAutoConfig("fight_mount_auto").image_list
	if image_id ~= nil then
		return self.image_list_cfg[image_id]
	end

	return nil
end

function FightMountData:GetMountSkillId()
	--return ConfigManager.Instance:GetAutoConfig("fight_mount_auto").skill_id
	return self.skill_id_list
end

-- 获取形象列表的配置
function FightMountData:GetImageListInfo(index)
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

-- 获取当前点击坐骑特殊形象的配置
function FightMountData:GetSpecialImageUpgradeInfo(index, grade, is_next)
	if (index == 0) or nil then
		return
	end

	local grade = grade or self.mount_info.special_img_grade_list[index]
	if is_next then
		grade = grade + 1
	end

	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if v.special_img_id == index and v.grade == grade then
	-- 		return v
	-- 	end
	-- end
	local cfg = self:GetSpecialImageUpgradeList(index)
	if cfg ~= nil then
		for k,v in pairs(cfg) do
			if v.grade == grade then
				return v
			end
		end
	end

	return nil
end

-- 获取幻化最大等级
function FightMountData:GetSpecialImageMaxUpLevelById(image_id)
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

-- 获取已吃成长丹，资质丹属性
function FightMountData:GetDanAttr(mount_info)
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
		if v.type == FightMountShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * mount_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * mount_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * mount_info.shuxingdan_count
			break
		end
	end

	return attr_list
end

-- 获取特殊形象总增加的属性丹和成长丹数量
function FightMountData:GetSpecialImageAttrSum(mount_info)
	mount_info = mount_info or self.mount_info
	local active_flag = mount_info.active_special_image_flag
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
	if self:GetMountGradeCfg(mount_info.grade) then
		sum_attr_list.chengzhangdan_count = special_chengzhangdan_count + self:GetMountGradeCfg(mount_info.grade).chengzhangdan_limit
		sum_attr_list.shuxingdan_count = special_shuxingdan_count + self:GetMountGradeCfg(mount_info.grade).shuxingdan_limit
		sum_attr_list.equip_limit = special_equip_limit + self:GetMountGradeCfg(mount_info.grade).equip_level_limit
	end

	return sum_attr_list
end

-- 获取已吃成长丹，资质丹属性
function FightMountData:GetDanAttr(mount_info)
	local mount_info = mount_info or self.mount_info
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
		if v.type == FightMountShuXingDanCfgType.Type then
			attr_list.gong_ji = attr_list.gong_ji + v.gongji * mount_info.shuxingdan_count
			attr_list.fang_yu = attr_list.fang_yu + v.fangyu * mount_info.shuxingdan_count
			attr_list.max_hp = attr_list.max_hp + v.maxhp * mount_info.shuxingdan_count
			break
		end
	end

	return attr_list
end


function FightMountData:GetMountAttrSum(mount_info)
	mount_info = mount_info or self.mount_info
	if not mount_info or not mount_info.grade or mount_info.grade <= 0 or mount_info.mount_level == 0 then
		return 0
	end

	if mount_info.mount_level >= self:GetMaxMountLevelCfg() then
		mount_info.mount_level = self:GetMaxMountLevelCfg()
	end

	local mount_level_cfg = self:GetMountLevelCfg(mount_info.mount_level)
	local mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade)
	local mount_next_grade_cfg = self:GetMountGradeCfg(mount_info.grade + 1)
	local special_img_attr = self:GetSpecialImageAttrSum(mount_info)
	local dan_attr = self:GetDanAttr(mount_info)

	local differ_value = CommonStruct.Attribute()
	if 	mount_next_grade_cfg ~= nil then												-- 临时属性加成
		differ_value.max_hp = mount_next_grade_cfg.maxhp - mount_grade_cfg.maxhp
		differ_value.gong_ji = mount_next_grade_cfg.gongji - mount_grade_cfg.gongji
		differ_value.fang_yu = mount_next_grade_cfg.fangyu - mount_grade_cfg.fangyu
		differ_value.ming_zhong = mount_next_grade_cfg.mingzhong - mount_grade_cfg.mingzhong
		differ_value.shan_bi = mount_next_grade_cfg.shanbi - mount_grade_cfg.shanbi
		differ_value.bao_ji = mount_next_grade_cfg.baoji - mount_grade_cfg.baoji
		differ_value.jian_ren = mount_next_grade_cfg.jianren - mount_grade_cfg.jianren
		differ_value.move_speed = mount_next_grade_cfg.movespeed - mount_grade_cfg.movespeed
	end

	local temp_attr_per = mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit

	local attr = CommonStruct.Attribute()
	attr.max_hp = mount_level_cfg.maxhp + mount_grade_cfg.maxhp + differ_value.max_hp * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.max_hp + dan_attr.max_hp -- + skill_attr.max_hp --+ equip_attr.max_hp + dan_attr.max_hp
	attr.gong_ji = mount_level_cfg.gongji + mount_grade_cfg.gongji + differ_value.gong_ji * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.gong_ji + dan_attr.gong_ji -- + skill_attr.gong_ji --+ equip_attr.gong_ji + dan_attr.gong_ji
	attr.fang_yu = mount_level_cfg.fangyu + mount_grade_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per
					+ special_img_attr.fang_yu + dan_attr.fang_yu -- + skill_attr.fang_yu --+ equip_attr.fang_yu + dan_attr.fang_yu
	attr.ming_zhong = mount_level_cfg.mingzhong + mount_grade_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per
					+ special_img_attr.ming_zhong + dan_attr.ming_zhong -- + skill_attr.ming_zhong --+ equip_attr.ming_zhong + dan_attr.ming_zhong
	attr.shan_bi = mount_level_cfg.shanbi + mount_grade_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per
					+ special_img_attr.shan_bi + dan_attr.shan_bi -- + skill_attr.shan_bi --+ equip_attr.shan_bi + dan_attr.shan_bi
	attr.bao_ji = mount_level_cfg.baoji + mount_grade_cfg.baoji --+ differ_value.bao_ji * temp_attr_per
					+ special_img_attr.bao_ji + dan_attr.bao_ji -- + skill_attr.bao_ji --+ equip_attr.bao_ji + dan_attr.bao_ji
	attr.jian_ren = mount_level_cfg.jianren + mount_grade_cfg.jianren --+ differ_value.jian_ren * temp_attr_per
					+ special_img_attr.jian_ren + dan_attr.jian_ren -- + skill_attr.jian_ren --+ equip_attr.jian_ren + dan_attr.jian_ren
	attr.move_speed = mount_grade_cfg.movespeed --+ differ_value.move_speed * temp_attr_per

	return attr
end

function FightMountData:GetMountGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetMountImageCfg(used_imageid)
	if not image_list then return 0 end
	if not image_list[used_imageid] then print_error("战斗坐骑形象配置没有image_id:", used_imageid) return 0 end

	local show_grade = image_list.show_grade

	-- for k, v in pairs(self:GetGradeCfg()) do
	-- 	if v.show_grade == show_grade then
	-- 		return v.show_grade
	-- 	end
	-- end
	local cfg = self:GetGradeCfg(show_grade)
	if cfg ~= nil then
		return cfg.show_grade
	end
	return 0
end

function FightMountData:CanHuanhuaUpgrade()
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

function FightMountData:GetMaxSpecialImageCfgById(id)
	local list = {}
	local count = 0
	if id == nil then return count end
	-- for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
	-- 	if id == v.special_img_id then
	-- 		list[v.grade] = v
	-- 	end
	-- end

	local cfg = self:GetSpecialImageUpgradeList(id)
	if cfg ~= nil then
		count = #cfg - 1
	end

	return count
end

function FightMountData:IsShowZizhiRedPoint()
	local count_limit = self:GetSpecialImageAttrSum().shuxingdan_count
	if self.mount_info.shuxingdan_count == nil or count_limit == nil then
		return false
	end
	if self.mount_info.shuxingdan_count >= count_limit then
		return false
	end

	if ItemData.Instance:GetItemNumInBagById(FightMountDanId.ZiZhiDanId) > 0 then
		return true
	end

	return false
end

function FightMountData:CanJinjie()
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return false end
	local cfg = self:GetMountGradeCfg(self.mount_info.grade)
	if cfg then
		if cfg.upgrade_stuff_count <= ItemData.Instance:GetItemNumInBagById(cfg.upgrade_stuff_id)
			and self.mount_info.grade < self:GetMaxGrade()then
			return true
		end
	end
	return false
end

function FightMountData:IsActiviteMount()
	local active_flag = self.mount_info and self.mount_info.active_image_flag or {}
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

-- 获取当前点击坐骑技能的配置
function FightMountData:GetSkillCfgById(skill_idx, level, mount_info)
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

	-- for k, v in pairs(self:GetMountSkillCfg()) do
	-- 	if v.skill_idx == skill_idx and v.skill_level == level then
	-- 		return v
	-- 	end
	-- end

	return self:GetFightMountSkillList(skill_idx, level)
end

function FightMountData:GetFightMountSkillIsActvity(skill_idx, cur_grade)
	local can_activity = self:GetSkillCfgById(skill_idx, 1)
	return cur_grade >= can_activity.grade
end

function FightMountData:CanSkillUpLevelList()
	local list = {}
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return list end

	for i, j in pairs(self:GetFightMountSkillCfg()) do
		local skill_level = self:GetSkillLevel(j.skill_idx + 1)
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and skill_level == (j.skill_level - 1)
			and j.grade <= self.mount_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

function FightMountData:GetSkillLevel(skill_index)
	local skill_id_list = self:GetBeautyHaloSkillId()
	local skill_id = skill_id_list[skill_index] and skill_id_list[skill_index].skill_id
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_level = skill_info and skill_info.level
	return skill_level or 0
end

function FightMountData:SetLastInfo(bless, grade)
	self.last_bless = bless or 0
	self.last_grade = grade or 0
end

function FightMountData:GetLastGrade()
	return self.last_grade
end

function FightMountData:ChangeShowInfo()
	self.show_bless = self.mount_info.grade_bless_val
end

function FightMountData:GetShowBless()
	return self.show_bless or self.last_bless
end

function FightMountData:GetInAdvanceRedNum()
	if OpenFunData.Instance:CheckIsHide("fight_mount") and (next(self:CanHuanhuaUpgrade()) ~= nil
		or self:IsShowZizhiRedPoint() or self:CanJinjie()) then
		return 1
	end
	return 0
end

function FightMountData:GetOhterCfg()
	return self.mount_cfg.other[1]
end

function FightMountData:IsOpenEquip()
	if nil == self.mount_info or nil == next(self.mount_info) then
		return false, 0
	end

	local otehr_cfg = self:GetOhterCfg()
	if self.mount_info.grade >= otehr_cfg.active_equip_grade then
		return true, 0
	end

	return false, otehr_cfg.active_equip_grade - 1
end

function FightMountData:GetNextPercentAttrCfg(equip_index)
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

function FightMountData:GetEquipMinLevel()
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

function FightMountData:IsActiveEquipSkill()
	-- if nil == self.mount_info or nil == next(self.mount_info) then
	-- 	return false
	-- end
	-- return self.mount_info.equip_skill_level > 0
end