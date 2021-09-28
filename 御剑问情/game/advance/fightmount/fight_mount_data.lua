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
	self.temp_table_fight_mount = {}
	self.fight_mount_special_max_level = 0
	self.mount_cfg = ConfigManager.Instance:GetAutoConfig("fight_mount_auto")
	self.equip_info_cfg = ListToMap(self.mount_cfg.mount_equip_info, "equip_idx", "equip_level")
	self.clear_bless_grade = 100
	self.clear_bless_grade_name = ""
	for i,v in ipairs(self.mount_cfg.grade) do
		if v.is_clear_bless == 1 then
			self.clear_bless_grade = v.grade
			self.clear_bless_grade_name = v.gradename
			break
		end
	end
	self:InitHaloMaxLevel()
end

--获取配置表中首种战斗坐骑的最大等级
function FightMountData:InitHaloMaxLevel()
	for i,v in ipairs(self.mount_cfg.special_image_upgrade) do
		if self.fight_mount_special_max_level <= v.grade then
			self.fight_mount_special_max_level = v.grade
		else
			break
		end
	end
end

function FightMountData:__delete()
	FightMountData.Instance = nil
	self.temp_table_fight_mount = {}
end

function FightMountData:SetFightMountInfo(protocol)
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
	self.mount_info.active_special_image_flag2 = protocol.active_special_image_flag2
	self.mount_info.star_level = protocol.star_level
	self.mount_info.equip_skill_level = protocol.equip_skill_level

	self.mount_info.equip_level_list = protocol.equip_level_list
	self.mount_info.skill_level_list = protocol.skill_level_list
	self.mount_info.special_img_grade_list = protocol.special_img_grade_list

	FestivalActivityCtrl.Instance:FlushView("fashion")
end

function FightMountData:GetUsedImageId()
	return self.mount_info.used_imageid
end

function FightMountData:GetSpecialImageIsActive(img_id)
	if nil == self.mount_info.active_special_image_flag2 or nil == self.mount_info.active_special_image_flag then
		return false
	end
	
	local bit_list = bit:d2b(self.mount_info.active_special_image_flag2)
	local bit_list2 = bit:d2b(self.mount_info.active_special_image_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	return 1 == bit_list[64 - img_id]
end

function FightMountData:GetLevelAttribute()
	local level_cfg = self:GetMountStarLevelCfg(self.mount_info.star_level)
	return CommonDataManager.GetAttributteByClass(level_cfg)
end

function FightMountData:GetFightMountInfo()
	return self.mount_info
end

function FightMountData:GetMountLevelCfg(mount_level)
	if mount_level >= self:GetMaxMountLevelCfg() then
		mount_level = self:GetMaxMountLevelCfg()
	end
	return self.mount_cfg.level[mount_level]
end

function FightMountData:GetMaxMountLevelCfg()
	return #self.mount_cfg.level
end

function FightMountData:GetMountGradeCfg(mount_grade)
	mount_grade = mount_grade or self.mount_info.grade or 0
	return self.mount_cfg.grade[mount_grade]
end

function FightMountData:GetSpecialImagesCfg()
	return self.mount_cfg.special_img
end

function FightMountData:GetSpecialImageCfg(image_id)
	return self.mount_cfg.special_img[image_id]
end

function FightMountData:GetMaxGrade()
	return #self.mount_cfg.grade
end

function FightMountData:GetMaxSpecialImage()
	return #self.mount_cfg.special_img
end

function FightMountData:GetSpecialImageUpgradeCfg()
	return self.mount_cfg.special_image_upgrade
end

function FightMountData:GetMountSkillCfg()
	return self.mount_cfg.mount_skill
end

function FightMountData:GetGradeCfg()
	return self.mount_cfg.grade
end

function FightMountData:GetMountImageCfg()
	return self.mount_cfg.image_list
end

function FightMountData:GetMountUpStarStuffCfg()
	return self.mount_cfg.up_star_stuff[1]
end

function FightMountData:GetMountUpStarExpCfg()
	return self.mount_cfg.up_star_exp
end

function FightMountData:GetOhterCfg()
	return self.mount_cfg.other[1]
end

-- 全属性加成所需阶数(服务器阶数)
function FightMountData:GetActiveNeedGrade()
  	local other_cfg = self:GetOhterCfg()
  	return other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function FightMountData:GetGrade()
  	return self.mount_info.grade or 0
end

-- 全属性加成百分比
function FightMountData:GetAllAttrPercent()
  	local other_cfg = self:GetOhterCfg()
  	local attr_percent = math.floor(other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function FightMountData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

-- 获取形象列表的配置
function FightMountData:GetImageListInfo(index)
	if (index == 0) or nil then
		return
	end
	for k, v in pairs(self:GetMountImageCfg()) do
		if v.image_id == index then
			return v
		end
	end

	return nil
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

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == index and v.grade == grade then
			return v
		end
	end

	return nil
end

-- 获取幻化最大等级
function FightMountData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if v.special_img_id == image_id and v.grade > 0 then
			max_level = max_level + 1
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
	local active_flag2 = mount_info.active_special_image_flag2 or self.mount_info.active_special_image_flag2
	local sum_attr_list = CommonStruct.Attribute()
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
			if self:GetSpecialImageUpgradeInfo(64 - k) ~= nil then
				special_img_upgrade_info = self:GetSpecialImageUpgradeInfo(64 - k)
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

-- 获得已升级装备属性
function FightMountData:GetMountEquipAttrSum(mount_info)
	mount_info = mount_info or self.mount_info
	local attr_list = CommonStruct.Attribute()
	if nil == mount_info.equip_level_list then return attr_list end
	for k, v in pairs(mount_info.equip_level_list) do
		attr_list = CommonDataManager.AddAttributeAttr(attr_list, CommonDataManager.GetAttributteByClass(self:GetEquipInfoCfg(k, v)))
	end
	return attr_list
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

	local attr = CommonStruct.Attribute()
	if not mount_info or not mount_info.grade or mount_info.grade <= 0 or mount_info.mount_level == 0 then
		return attr
	end

	if mount_info.mount_level >= self:GetMaxMountLevelCfg() then
		mount_info.mount_level = self:GetMaxMountLevelCfg()
	end

	local mount_level_cfg = self:GetMountLevelCfg(mount_info.mount_level)
	local mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade)
	local star_cfg = self:GetMountStarLevelCfg(mount_info.star_level)

	if not star_cfg then return attr end
	-- local mount_next_grade_cfg = self:GetMountGradeCfg(mount_info.grade + 1)
	local special_img_attr = self:GetSpecialImageAttrSum(mount_info)
	local dan_attr = self:GetDanAttr(mount_info)

	-- local differ_value = CommonStruct.Attribute()
	-- if 	mount_next_grade_cfg ~= nil then												-- 临时属性加成
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

	attr.max_hp = mount_level_cfg.maxhp + star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.max_hp + dan_attr.max_hp -- + skill_attr.max_hp --+ equip_attr.max_hp + dan_attr.max_hp

	attr.gong_ji = mount_level_cfg.gongji + star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.gong_ji + dan_attr.gong_ji -- + skill_attr.gong_ji --+ equip_attr.gong_ji + dan_attr.gong_ji

	attr.fang_yu = mount_level_cfg.fangyu + star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.fang_yu + dan_attr.fang_yu -- + skill_attr.fang_yu --+ equip_attr.fang_yu + dan_attr.fang_yu

	attr.ming_zhong = mount_level_cfg.mingzhong + star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.ming_zhong + dan_attr.ming_zhong -- + skill_attr.ming_zhong --+ equip_attr.ming_zhong + dan_attr.ming_zhong

	attr.shan_bi = mount_level_cfg.shanbi + star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.shan_bi + dan_attr.shan_bi -- + skill_attr.shan_bi --+ equip_attr.shan_bi + dan_attr.shan_bi

	attr.bao_ji = mount_level_cfg.baoji + star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.bao_ji + dan_attr.bao_ji -- + skill_attr.bao_ji --+ equip_attr.bao_ji + dan_attr.bao_ji

	attr.jian_ren = mount_level_cfg.jianren + star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.jian_ren + dan_attr.jian_ren -- + skill_attr.jian_ren --+ equip_attr.jian_ren + dan_attr.jian_ren

	attr.move_speed = star_cfg.speed --+ differ_value.move_speed * temp_attr_per

	return attr
end

function FightMountData:GetMountMaxAttrSum(mount_info)
	mount_info = mount_info or self.mount_info

	local attr = CommonStruct.Attribute()
	if not mount_info or not mount_info.grade or mount_info.grade <= 0 or mount_info.mount_level == 0 then
		return attr
	end

	if mount_info.mount_level >= self:GetMaxMountLevelCfg() then
		mount_info.mount_level = self:GetMaxMountLevelCfg()
	end

	local mount_level_cfg = self:GetMountLevelCfg(mount_info.mount_level)
	local mount_grade_cfg = self:GetMountGradeCfg(mount_info.grade)
	local star_cfg = self:GetMountStarLevelCfg(100)

	if not star_cfg then return attr end
	-- local mount_next_grade_cfg = self:GetMountGradeCfg(mount_info.grade + 1)
	local special_img_attr = self:GetSpecialImageAttrSum(mount_info)
	local dan_attr = self:GetDanAttr(mount_info)

	-- local differ_value = CommonStruct.Attribute()
	-- if 	mount_next_grade_cfg ~= nil then												-- 临时属性加成
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

	attr.max_hp = mount_level_cfg.maxhp + star_cfg.maxhp --+ differ_value.max_hp * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.max_hp + dan_attr.max_hp -- + skill_attr.max_hp --+ equip_attr.max_hp + dan_attr.max_hp

	attr.gong_ji = mount_level_cfg.gongji + star_cfg.gongji --+ differ_value.gong_ji * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.gong_ji + dan_attr.gong_ji -- + skill_attr.gong_ji --+ equip_attr.gong_ji + dan_attr.gong_ji

	attr.fang_yu = mount_level_cfg.fangyu + star_cfg.fangyu --+ differ_value.fang_yu * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.fang_yu + dan_attr.fang_yu -- + skill_attr.fang_yu --+ equip_attr.fang_yu + dan_attr.fang_yu

	attr.ming_zhong = mount_level_cfg.mingzhong + star_cfg.mingzhong --+ differ_value.ming_zhong * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.ming_zhong + dan_attr.ming_zhong -- + skill_attr.ming_zhong --+ equip_attr.ming_zhong + dan_attr.ming_zhong

	attr.shan_bi = mount_level_cfg.shanbi + star_cfg.shanbi --+ differ_value.shan_bi * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.shan_bi + dan_attr.shan_bi -- + skill_attr.shan_bi --+ equip_attr.shan_bi + dan_attr.shan_bi

	attr.bao_ji = mount_level_cfg.baoji + star_cfg.baoji --+ differ_value.bao_ji * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.bao_ji + dan_attr.bao_ji -- + skill_attr.bao_ji --+ equip_attr.bao_ji + dan_attr.bao_ji

	attr.jian_ren = mount_level_cfg.jianren + star_cfg.jianren --+ differ_value.jian_ren * temp_attr_per * mount_grade_cfg.bless_addition /10000
					+ special_img_attr.jian_ren + dan_attr.jian_ren -- + skill_attr.jian_ren --+ equip_attr.jian_ren + dan_attr.jian_ren

	attr.move_speed = star_cfg.speed --+ differ_value.move_speed * temp_attr_per

	return attr
end

function FightMountData:GetMountStarLevelCfg(star_level)
	local star_level = star_level or self.mount_info.star_level
	for k, v in pairs(self:GetMountUpStarExpCfg()) do
		if v.star_level == star_level then
			return v
		end
	end

	return nil
end

function FightMountData:GetMountGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetMountImageCfg()
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

function FightMountData:CanHuanhuaUpgrade()
	local list = {}
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return list end
	if self.mount_info.special_img_grade_list == nil then
		return list
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.mount_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.mount_info.special_img_grade_list[j.special_img_id] < self.fight_mount_special_max_level then
			list[j.special_img_id] = j.special_img_id
		end
	end

	return list
end

function FightMountData:IsCanHuanhuaUpgrade()
	if self.mount_info.grade == nil or self.mount_info.grade <= 0 then return false end
	if self.mount_info.special_img_grade_list == nil then
		return false
	end

	for i, j in pairs(self:GetSpecialImageUpgradeCfg()) do
		if j.stuff_num <= ItemData.Instance:GetItemNumInBagById(j.stuff_id)
			and self.mount_info.special_img_grade_list[j.special_img_id] == j.grade and
			self.mount_info.special_img_grade_list[j.special_img_id] < self.fight_mount_special_max_level then
			return true
		end
	end

	return false
end

function FightMountData:GetMaxSpecialImageCfgById(id)
	local list = {}
	if id == nil then return list end
	for k, v in pairs(self:GetSpecialImageUpgradeCfg()) do
		if id == v.special_img_id then
			list[v.grade] = v
		end
	end
	return #list
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
	if  self.mount_info.grade >= self:GetMaxGrade()then
		return false
	end

	local mount_grade_cfg = self.mount_cfg.grade[self.mount_info.grade]
	if nil == mount_grade_cfg or mount_grade_cfg.is_clear_bless == 1 then
		return false
	end

	local num = ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff2_id)
	return num >= mount_grade_cfg.upgrade_stuff_count
end

function FightMountData:IsActiviteMount()
	local active_flag = self.mount_info and self.mount_info.active_image_flag or 0
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(bit_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

function FightMountData:GetEquipInfoCfg(equip_index, level)
	if nil == self.equip_info_cfg[equip_index] then
		return
	end
	return self.equip_info_cfg[equip_index][level]
end

function FightMountData:CalAllEquipRemind()
	if not self:IsOpenEquip() then return 0 end

	for k, v in pairs(self.mount_info.equip_level_list) do
		if self:CalEquipRemind(k) > 0 then
			return 1
		end
	end
	return 0
end

function FightMountData:CalEquipRemind(equip_index)
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
	if nil == self.mount_info or nil == next(self.mount_info) then
		return false
	end
	return self.mount_info.equip_skill_level > 0
end

function FightMountData:GetHuanHuaFightMountCfg()
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
	self.temp_table_fight_mount = temp_table
	return temp_table
end

function FightMountData:GetHuanHuaFightMountCfgByIndex(index)
	return self:GetSpecialImageCfg(index) or 0
end

function FightMountData:GetClearBlessGrade()
	return self.clear_bless_grade, self.clear_bless_grade_name
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function FightMountData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetMountGradeCfg(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade()
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end
	return power, huanhua_add_per
end

--得到幻化形象当前等级
function FightMountData:GetSingleSpecialImageGrade(image_id)
	local grade = 0
	if nil == self.mount_info or nil == self.mount_info.special_img_grade_list or nil == self.mount_info.special_img_grade_list[image_id] then
		return grade
	end

	grade = self.mount_info.special_img_grade_list[image_id]
	return grade
end

--当前进阶等级对应的image_id
function FightMountData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetMountGradeCfg(self.mount_info.grade)
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end