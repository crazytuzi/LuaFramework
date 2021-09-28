CheckData = CheckData or BaseClass()

CHECK_TAB_TYPE =
{
	JUE_SE = 1,
	MOUNT = 2,
	WING = 3,
	HALO = 4,
	FIGHT_MOUNT = 5,
	SPIRIT = 6,
	GODDESS = 7,
	SHEN_GONG = 8,
	SHEN_YI = 9,
	FOOT = 10,
	WAIST = 11,
	HEAD = 12,
	ARM = 13,
	MASK = 14,
	LINGZHU = 15,
	XIANBAO = 16,
	LINGCHONG = 17,
	LINGGONG = 18,
	LINGQI = 19,
	-- CLOAK = 11,
	-- ranktag
}

ADVANCE_IMAGE_ID_CHAZHI = 1000 -- 形象的差值，幻化了image_id需要减1000
function CheckData:__init()
	if CheckData.Instance then
		print_error("[CheckData] Attemp to create a singleton twice !")
	end
	CheckData.Instance = self
	self.current_user_id = -1
	self.role_info = {}
	self.is_ming_ren = false
	self.cur_minren_index = 0
end

function CheckData:__delete()
	CheckData.Instance = nil
	if self.role_info_event then
		GlobalEventSystem:UnBind(self.role_info_event)
		self.role_info_event = nil
	end
end

function CheckData:GetRoleInfo()
	return self.role_info
end

function CheckData:SetMingrenFlag(flag)
	self.is_ming_ren = flag
end

function CheckData:GetRoleId()
	return self.role_info.role_id or 0
end

function CheckData:RoleInfoChange(info)
	-- 这里必须要Copy一份，否则会出bug
	self.role_info = TableCopy(info)
end

function CheckData:GetMinEternityLevel(info)
	local count_t = {}
	for k,v in pairs(info or {}) do
		for i=1, v.eternity_level do
			local count = count_t[i]
			count_t[i] = count and count + 1 or 1
		end
	end
	local level = 0
	for k,v in pairs(count_t) do
		if v >= ETERNITY_ACTIVE_NEED and level < k then
			level = k
		end
	end
	return level
end

-- 设置魅力值
function CheckData:SetAllCharm(all_charm)
	self.role_info.all_charm = all_charm
end

function CheckData:SetCurrentUserId(current_user_id)
	self.current_user_id = current_user_id
end

function CheckData:GetCurrentUserId()
	return self.current_user_id
end

function CheckData:UpdateAttrView()
	if self.role_info == nil or not next(self.role_info) then return {} end
	local role_info = self.role_info
	local zhanli_attr = {
		max_hp = role_info.gongji,
		gong_ji = role_info.maxhp,
		fang_yu = role_info.fangyu,
		ming_zhong = role_info.mingzhong,
		shan_bi = role_info.shanbi,
		bao_ji = role_info.baoji,
		jian_ren = role_info.jianren,
		per_baoji = 0,
		per_pofang = 0,
		per_mianshang = 0,
		per_jingzhun = 0
	}

	local zhanli = CommonDataManager.GetCapability(zhanli_attr)
	local present_attr = {
		role_id = role_info.role_id,
		level = role_info.level,
		all_charm = role_info.all_charm,
		prof = role_info.prof,
		lover_name = role_info.lover_name,
		guild_name = role_info.guild_name,
		zhan_li = zhanli,
		role_name = role_info.role_name
	}

	local info_attr = {}
	info_attr.capability = role_info.capability
	info_attr.shengming = role_info.max_hp
	info_attr.gongji = role_info.gongji
	info_attr.fangyu = role_info.fangyu
	info_attr.mingzhong = role_info.mingzhong
	info_attr.shanbi = role_info.shanbi
	info_attr.baoji = role_info.baoji
	info_attr.kangbao = role_info.jianren
	info_attr.fujia_shanghai = role_info.fujia_shanghai
	info_attr.dikang_shanghai = role_info.dikang_shanghai
	info_attr.evil_val = role_info.evil_val

	info_attr.per_jingzhun = role_info.per_jingzhun
	info_attr.per_baoji = role_info.per_baoji
	info_attr.per_kangbao = role_info.per_kangbao
	info_attr.per_pofang = role_info.per_pofang
	info_attr.per_mianshang = role_info.per_mianshang

	info_attr.max_hp =role_info.max_hp
	info_attr.gong_ji = role_info.gongji
	info_attr.fang_yu = role_info.fangyu
	info_attr.ming_zhong = role_info.mingzhong
	info_attr.shan_bi = role_info.shanbi
	info_attr.bao_ji = role_info.baoji
	info_attr.jian_ren = role_info.jianren
	info_attr.base_max_hp = role_info.max_hp
	info_attr.base_gongji = role_info.gongji							-- 基础攻击
	info_attr.base_fangyu = role_info.fangyu							-- 基础防御
	info_attr.base_mingzhong = role_info.mingzhong						-- 基础命中
	info_attr.base_shanbi = role_info.shanbi							-- 基础闪避
	info_attr.base_baoji = role_info.baoji							-- 基础暴击
	info_attr.base_jianren = role_info.jianren							-- 基础坚韧
	info_attr.base_fujia_shanghai = role_info.fujia_shanghai
	info_attr.base_dikang_shanghai = role_info.dikang_shanghai
	info_attr.base_per_jingzhun = info_attr.per_jingzhun
	info_attr.base_per_baoji = info_attr.per_baoji
	info_attr.base_per_kangbao = info_attr.per_kangbao
	info_attr.base_per_pofang = info_attr.per_pofang
	info_attr.base_per_mianshang = info_attr.per_mianshang
	info_attr.other_capability = 0
	info_attr.base_move_speed = 0
	info_attr.move_speed = 0
	info_attr.level = role_info.level
	local equip_attr = role_info.equipment_info
	if info_attr then
		info_attr.use_eternity_level = self:GetMinEternityLevel(equip_attr)
	end

	local temp_halo_info = role_info.halo_info or {}
	local halo_info = {
		halo_level = temp_halo_info.level,
		grade = temp_halo_info.grade,
		grade_bless_val = 0,
		clear_upgrade_time = 0,
		used_imageid = temp_halo_info.used_imageid,
		shuxingdan_count = temp_halo_info.shuxingdan_count,
		chengzhangdan_count = temp_halo_info.chengzhangdan_count,
		active_image_flag = 0,
		active_special_image_flag = temp_halo_info.active_special_image_flag,
		active_special_image_flag2 = temp_halo_info.active_special_image_flag2,
		equip_info_list = temp_halo_info.equip_info_list,
		skill_level_list = temp_halo_info.skill_level_list,
		special_img_grade_list = {},
		star_level = temp_halo_info.star_level
	}
	local h_attr = HaloData.Instance:GetHaloAttrSum(halo_info)
	local halo_attr = {}
	halo_attr.capability = temp_halo_info.capability
	if h_attr == 0 then
		halo_attr.gong_ji = 0
		halo_attr.fang_yu = 0
		halo_attr.max_hp = 0
		halo_attr.ming_zhong = 0
		halo_attr.shan_bi = 0
		halo_attr.bao_ji = 0
		halo_attr.jian_ren = 0
		halo_attr.per_pofang = 0
		halo_attr.per_mianshang = 0
		halo_attr.client_grade = 0
		halo_attr.used_imageid = 0
		halo_attr.halo_level = halo_info.halo_level
	else
		local h_attr_2 = HaloData.Instance:GetHaloEquipAttrSum(halo_info)
		halo_attr.gong_ji = h_attr.gong_ji
		halo_attr.fang_yu = h_attr.fang_yu
		halo_attr.max_hp = h_attr.max_hp
		halo_attr.ming_zhong = h_attr.ming_zhong
		halo_attr.shan_bi = h_attr.shan_bi
		halo_attr.bao_ji = h_attr.bao_ji
		halo_attr.jian_ren = h_attr.jian_ren
		halo_attr.per_pofang = h_attr_2.per_pofang
		halo_attr.per_mianshang = h_attr_2.per_mianshang
		halo_attr.client_grade = (halo_info.grade or 0) - 1
		halo_attr.used_imageid = halo_info.used_imageid
		halo_attr.halo_level = halo_info.halo_level
	end

	local temp_mount_info = role_info.mount_info or {}
	local mount_info = {
		mount_flag = 0,
		mount_level = temp_mount_info.level,
		grade = temp_mount_info.grade,
		grade_bless_val = 0,
		clear_upgrade_time = 0,
		used_imageid = temp_mount_info.used_imageid,
		shuxingdan_count = temp_mount_info.shuxingdan_count,
		chengzhangdan_count = temp_mount_info.chengzhangdan_count,
		active_image_flag = 0,
		active_special_image_flag = temp_mount_info.active_special_image_flag,
		active_special_image_flag2 = temp_mount_info.active_special_image_flag2,
		equip_info_list = temp_mount_info.equip_info_list,
		skill_level_list = temp_mount_info.skill_level_list,
		special_img_grade_list = {},
		star_level = temp_mount_info.star_level,
	}

	local m_attr = MountData.Instance:GetMountAttrSum(mount_info)
	local mount_attr = {}
	mount_attr.capability = temp_mount_info.capability
	if m_attr == 0 then
		mount_attr.gong_ji = 0
		mount_attr.fang_yu = 0
		mount_attr.max_hp = 0
		mount_attr.ming_zhong = 0
		mount_attr.shan_bi = 0
		mount_attr.bao_ji = 0
		mount_attr.jian_ren = 0
		mount_attr.per_pofang = 0
		mount_attr.per_mianshang = 0
		mount_attr.client_grade = 0
		mount_attr.used_imageid = 0
		mount_attr.mount_level = mount_info.mount_level
	else
		local m_attr_2 = MountData.Instance:GetMountEquipAttrSum(mount_info)
		mount_attr.gong_ji = m_attr.gong_ji
		mount_attr.fang_yu = m_attr.fang_yu
		mount_attr.max_hp = m_attr.max_hp
		mount_attr.ming_zhong = m_attr.ming_zhong
		mount_attr.shan_bi = m_attr.shan_bi
		mount_attr.bao_ji = m_attr.bao_ji
		mount_attr.jian_ren = m_attr.jian_ren
		mount_attr.per_pofang = m_attr_2.per_pofang
		mount_attr.per_mianshang = m_attr_2.per_mianshang
		mount_attr.client_grade = (mount_info.grade or 0) - 1
		mount_attr.used_imageid = mount_info.used_imageid
		mount_attr.mount_level = mount_info.mount_level
	end

	local temp_wing_info = role_info.wing_info or {}
	local wing_info = {
		wing_level = temp_wing_info.level,
		grade = temp_wing_info.grade,
		grade_bless_val = 0,
		used_imageid = temp_wing_info.used_imageid,
		shuxingdan_count = temp_wing_info.shuxingdan_count,
		chengzhangdan_count = temp_wing_info.chengzhangdan_count,
		active_image_flag = 0,
		active_special_image_flag = temp_wing_info.active_special_image_flag,
		active_special_image_flag2 = temp_wing_info.active_special_image_flag2,
		clear_upgrade_time = 0,
		equip_info_list = temp_wing_info.equip_info_list,
		skill_level_list = temp_wing_info.skill_level_list,
		special_img_grade_list = {},
		star_level = temp_wing_info.star_level,
	}

	local w_attr = WingData.Instance:GetWingAttrSum(wing_info)
	local wing_attr = {}
	wing_attr.capability = temp_wing_info.capability
	if w_attr == 0 then
		wing_attr.gong_ji = 0
		wing_attr.fang_yu = 0
		wing_attr.max_hp = 0
		wing_attr.ming_zhong = 0
		wing_attr.shan_bi = 0
		wing_attr.bao_ji = 0
		wing_attr.jian_ren = 0
		wing_attr.per_pofang = 0
		wing_attr.client_grade = 0
		wing_attr.client_grade = 0
		wing_attr.used_imageid = 0
		wing_attr.wing_level = wing_info.wing_level
	else
		local w_attr_2 = WingData.Instance:GetWingEquipAttrSum(wing_info)
		wing_attr.gong_ji = w_attr.gong_ji
		wing_attr.fang_yu = w_attr.fang_yu
		wing_attr.max_hp = w_attr.max_hp
		wing_attr.ming_zhong = w_attr.ming_zhong
		wing_attr.shan_bi = w_attr.shan_bi
		wing_attr.bao_ji = w_attr.bao_ji
		wing_attr.jian_ren = w_attr.jian_ren
		wing_attr.per_pofang = w_attr_2.per_pofang
		wing_attr.per_mianshang = w_attr_2.per_mianshang
		wing_attr.client_grade = (wing_info.grade or 0) - 1
		wing_attr.used_imageid = wing_info.used_imageid
		wing_attr.wing_level = wing_info.wing_level
	end

	local temp_shengong_info = role_info.shengong_info or {}
	local shengong_info = {
		shengong_level = temp_shengong_info.level,
		grade = temp_shengong_info.grade,
		grade_bless_val = 0,
		used_imageid = temp_shengong_info.used_imageid,
		shuxingdan_count = temp_shengong_info.shuxingdan_count,
		chengzhangdan_count = temp_shengong_info.chengzhangdan_count,
		active_image_flag = 0,
		active_special_image_flag = temp_shengong_info.active_special_image_flag,
		active_special_image_flag2 = temp_shengong_info.active_special_image_flag2,
		clear_upgrade_time = 0,
		equip_info_list = temp_shengong_info.equip_info_list,
		skill_level_list = temp_shengong_info.skill_level_list,
		star_level = temp_shengong_info.star_level,
		special_img_grade_list = {},
	}
	local s_attr = ShengongData.Instance:GetShengongAttrSum(shengong_info)
	local shengong_attr = {}
	shengong_attr.capability = temp_shengong_info.capability
	if s_attr == 0 then
		shengong_attr.gong_ji = 0
		shengong_attr.fang_yu = 0
		shengong_attr.max_hp = 0
		shengong_attr.ming_zhong = 0
		shengong_attr.shan_bi = 0
		shengong_attr.bao_ji = 0
		shengong_attr.jian_ren = 0
		shengong_attr.per_pofang = 0
		shengong_attr.per_mianshang = 0
		shengong_attr.client_grade = 0
		shengong_attr.used_imageid = 0
		shengong_attr.shengong_level = shengong_info.shengong_level
	else
		local s_attr_2 = ShengongData.Instance:GetShengongEquipAttrSum(shengong_info)
		shengong_attr.gong_ji = s_attr.gong_ji
		shengong_attr.fang_yu = s_attr.fang_yu
		shengong_attr.max_hp = s_attr.max_hp
		shengong_attr.ming_zhong = s_attr.ming_zhong
		shengong_attr.shan_bi = s_attr.shan_bi
		shengong_attr.bao_ji = s_attr.bao_ji
		shengong_attr.jian_ren = s_attr.jian_ren
		shengong_attr.per_pofang = s_attr_2.per_pofang
		shengong_attr.per_mianshang = s_attr_2.per_mianshang
		shengong_attr.client_grade = (shengong_info.grade or 0) - 1
		shengong_attr.used_imageid = shengong_info.used_imageid
		shengong_attr.shengong_level = shengong_info.shengong_level
	end

	local temp_shenyi_info = role_info.shenyi_info or {}
	local shenyi_info = {
		shenyi_level = temp_shenyi_info.level,
		grade = temp_shenyi_info.grade,
		grade_bless_val = 0,
		used_imageid = temp_shenyi_info.used_imageid,
		shuxingdan_count = temp_shenyi_info.shuxingdan_count,
		chengzhangdan_count = temp_shenyi_info.chengzhangdan_count,
		active_image_flag = 0,
		active_special_image_flag = temp_shenyi_info.active_special_image_flag,
		active_special_image_flag2 = temp_shenyi_info.active_special_image_flag2,
		star_level = temp_shenyi_info.star_level,
		clear_upgrade_time = 0,
		equip_info_list = temp_shenyi_info.equip_info_list,
		skill_level_list = temp_shenyi_info.skill_level_list,
		special_img_grade_list = {}
	}
	local sy_attr = ShenyiData.Instance:GetShenyiAttrSum(shenyi_info)
	local shenyi_attr = {}
	shenyi_attr.capability = temp_shenyi_info.capability
	if sy_attr == 0 then
		shenyi_attr.gong_ji = 0
		shenyi_attr.fang_yu = 0
		shenyi_attr.max_hp = 0
		shenyi_attr.ming_zhong = 0
		shenyi_attr.shan_bi = 0
		shenyi_attr.bao_ji = 0
		shenyi_attr.jian_ren = 0
		shenyi_attr.per_pofang = 0
		shenyi_attr.per_mianshang = 0
		shenyi_attr.client_grade = 0
		shenyi_attr.used_imageid = 0
		shenyi_attr.shenyi_level = shenyi_info.shenyi_level
	else
		local sy_attr_2 = ShenyiData.Instance:GetShenyiEquipAttrSum(shenyi_info)
		shenyi_attr.gong_ji = sy_attr.gong_ji
		shenyi_attr.fang_yu = sy_attr.fang_yu
		shenyi_attr.max_hp = sy_attr.max_hp
		shenyi_attr.ming_zhong = sy_attr.ming_zhong
		shenyi_attr.shan_bi = sy_attr.shan_bi
		shenyi_attr.bao_ji = sy_attr.bao_ji
		shenyi_attr.jian_ren = sy_attr.jian_ren
		shenyi_attr.per_pofang = sy_attr_2.per_pofang
		shenyi_attr.per_mianshang = sy_attr_2.per_mianshang
		shenyi_attr.client_grade = (shenyi_info.grade or 0) - 1
		shenyi_attr.used_imageid = shenyi_info.used_imageid
		shenyi_attr.shenyi_level = shenyi_info.shenyi_level
	end

	local temp_fight_mount_info = role_info.fight_mount_info or {}
	local fight_mount_info = {
		mount_level = temp_fight_mount_info.mount_level,
		grade = temp_fight_mount_info.grade,
		grade_bless_val = 0,
		used_imageid = temp_fight_mount_info.used_imageid,
		shuxingdan_count = temp_fight_mount_info.shuxingdan_count,
		chengzhangdan_count = temp_fight_mount_info.chengzhangdan_count,
		active_image_flag = 0,
		active_special_image_flag = temp_fight_mount_info.active_special_image_flag,
		active_special_image_flag2 = temp_fight_mount_info.active_special_image_flag2,
		clear_upgrade_time = 0,
		equip_info_list = temp_fight_mount_info.equip_info_list,
		skill_level_list = temp_fight_mount_info.skill_level_list,
		special_img_grade_list = {},
		star_level = temp_fight_mount_info.star_level,
	}
	local fm_attr = FightMountData.Instance:GetMountAttrSum(fight_mount_info)
	local fight_mount_attr = {}
	fight_mount_attr.capability = temp_fight_mount_info.capability
	if fm_attr == 0 then
		fight_mount_attr.gong_ji = 0
		fight_mount_attr.fang_yu = 0
		fight_mount_attr.max_hp = 0
		fight_mount_attr.ming_zhong = 0
		fight_mount_attr.shan_bi = 0
		fight_mount_attr.bao_ji = 0
		fight_mount_attr.jian_ren = 0
		-- fight_mount_attr.per_pofang = 0
		-- fight_mount_attr.per_mianshang = 0
		fight_mount_attr.client_grade = 0
		fight_mount_attr.used_imageid = 0
		fight_mount_attr.level = fight_mount_info.level
	else
		fight_mount_attr.gong_ji = fm_attr.gong_ji
		fight_mount_attr.fang_yu = fm_attr.fang_yu
		fight_mount_attr.max_hp = fm_attr.max_hp
		fight_mount_attr.ming_zhong = fm_attr.ming_zhong
		fight_mount_attr.shan_bi = fm_attr.shan_bi
		fight_mount_attr.bao_ji = fm_attr.bao_ji
		fight_mount_attr.jian_ren = fm_attr.jian_ren
		-- fight_mount_attr.per_pofang = fm_attr_2.per_pofang
		-- fight_mount_attr.per_mianshang = fm_attr_2.per_mianshang
		fight_mount_attr.client_grade = (fight_mount_info.grade or 0) - 1
		fight_mount_attr.used_imageid = fight_mount_info.used_imageid
		fight_mount_attr.level = fight_mount_info.shenyi_level
	end

	local xiannv_attr = role_info.xiannv_info
	local spirit_attr = role_info.jingling_info
	local foot_attr = role_info.foot_info
	local check_attr = {}
	check_attr.present_attr = present_attr
	check_attr.halo_attr = halo_attr
	check_attr.mount_attr = mount_attr
	check_attr.equip_attr = equip_attr
	check_attr.wing_attr = wing_attr
	check_attr.info_attr = info_attr
	check_attr.shengong_attr = shengong_attr
	check_attr.shenyi_attr = shenyi_attr
	check_attr.xiannv_attr = xiannv_attr
	check_attr.spirit_attr = spirit_attr
	check_attr.fight_attr = fight_mount_attr
	check_attr.foot_attr = foot_attr
	check_attr.waist_attr = role_info.waist_info
	check_attr.head_attr = role_info.head_info
	check_attr.arm_attr = role_info.arm_info
	-- ranktag
	check_attr.mask_attr = role_info.mask_info
	check_attr.lingzhu_attr = role_info.lingzhu_info
	check_attr.xianbao_attr = role_info.xianbao_info
	check_attr.lingchong_attr = role_info.lingchong_info
	check_attr.linggong_attr = role_info.linggong_info
	check_attr.lingqi_attr = role_info.lingqi_info

	return check_attr
end

function CheckData:GetEquipItemCfg(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("equipment_auto")[item_id]
end

function CheckData:GetGradeName(grade)
	return CommonDataManager.GetDaXie(grade)..Language.Common.Jie
end

--获得默认装备id
function CheckData:DefalutEquip(index)
	local equip_id = 0
	if index == 1 then
		equip_id = 8100
	elseif index == 2 then
		equip_id = 100
	elseif index == 3 then
		equip_id = 9100
	elseif index == 4 then
		equip_id = 9100
	elseif index == 5 then
		equip_id = 6100
	elseif index == 6 then
		equip_id = 1100
	elseif index == 7 then
		equip_id = 5100
	elseif index == 8 then
		equip_id = 2100
	elseif index == 9 then
		equip_id = 3100
	elseif index == 10 then
		equip_id = 4100
	end
	return equip_id
end

function CheckData:GetTabName(tab_index)
	return Language.Common.CheckTabName[tab_index] or ""
end

function CheckData:GetTabAsset(tab_index)
	local asset, name = "", ""
	if tab_index == CHECK_TAB_TYPE.JUE_SE then
		asset = "uis/images_atlas"
		name = "icon_juese"
	elseif tab_index == CHECK_TAB_TYPE.MOUNT then
		asset = "uis/images_atlas"
		name = "icon_zuoqi"
	elseif tab_index == CHECK_TAB_TYPE.WING then
		asset = "uis/images_atlas"
		name = "icon_yuyi"
	elseif tab_index == CHECK_TAB_TYPE.HALO then
		asset = "uis/images_atlas"
		name = "icon_guanghuan"
	elseif tab_index == CHECK_TAB_TYPE.SPIRIT then
		asset = "uis/images_atlas"
		name = "left_icon_jingling"
	elseif tab_index == CHECK_TAB_TYPE.GODDESS then
		asset = "uis/images_atlas"
		name = "icon_huoban"
	elseif tab_index == CHECK_TAB_TYPE.SHEN_GONG then
		asset = "uis/images_atlas"
		name = "icon_sprit_halo"
	elseif tab_index == CHECK_TAB_TYPE.SHEN_YI then
		asset = "uis/images_atlas"
		name = "icon_fazhen"
	elseif tab_index == CHECK_TAB_TYPE.FIGHT_MOUNT then
		asset = "uis/images_atlas"
		name = "icon_zhanqi"
	elseif tab_index == CHECK_TAB_TYPE.FOOT then
		asset = "uis/images_atlas"
		name = "icon_foot"
	elseif tab_index == CHECK_TAB_TYPE.WAIST then
		asset = "uis/images_atlas"
		name = "left_icon_yaoshi"
	elseif tab_index == CHECK_TAB_TYPE.HEAD then
		asset = "uis/images_atlas"
		name = "left_icon_toushi"
	elseif tab_index == CHECK_TAB_TYPE.ARM then
		asset = "uis/images_atlas"
		name = "left_icon_qilinbi"
	elseif tab_index == CHECK_TAB_TYPE.MASK then
		asset = "uis/images_atlas"
		name = "left_icon_mask"
	elseif tab_index == CHECK_TAB_TYPE.LINGZHU then
		asset = "uis/images_atlas"
		name = "left_icon_lingzhu"
	elseif tab_index == CHECK_TAB_TYPE.XIANBAO then
		asset = "uis/images_atlas"
		name = "left_icon_xianbao"
	elseif tab_index == CHECK_TAB_TYPE.LINGCHONG then
		asset = "uis/images_atlas"
		name = "icon_lingchong"
	elseif tab_index == CHECK_TAB_TYPE.LINGGONG then
		asset = "uis/images_atlas"
		name = "icon_linggong"
	elseif tab_index == CHECK_TAB_TYPE.LINGQI then
		asset = "uis/images_atlas"
		name = "icon_lingqi"
	end
	-- ranktag
	return asset, name
end

function CheckData:GetTabIsOpen(tab_index)
	if self.role_info then
		if tab_index == CHECK_TAB_TYPE.MOUNT then
			if not self.role_info.mount_info then
				return false
			end
			if self.role_info.mount_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.WING then
			if not self.role_info.wing_info then
				return false
			end
			if self.role_info.wing_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.HALO then
			if not self.role_info.halo_info then
				return false
			end
			if self.role_info.halo_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.SPIRIT then
			return self:CheckSpiritTabIsOpen()
		elseif tab_index == CHECK_TAB_TYPE.GODDESS then
			if not self.role_info.xiannv_info then
				return false
			end
			if self.role_info.xiannv_info.pos_list[1] == -1 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.SHEN_GONG then
			if not self.role_info.shengong_info then
				return false
			end
			if self.role_info.shengong_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.SHEN_YI then
			if not self.role_info.shenyi_info then
				return false
			end
			if self.role_info.shenyi_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.FIGHT_MOUNT then
			if not self.role_info.fight_mount_info then
				return false
			end
			if self.role_info.fight_mount_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.FOOT then
			if not self.role_info.foot_info then
				return false
			end
			if self.role_info.foot_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.WAIST then
			if not self.role_info.waist_info then
				return false
			end
			if self.role_info.waist_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.HEAD then
			if not self.role_info.head_info then
				return false
			end
			if self.role_info.head_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.ARM then
			if not self.role_info.arm_info then
				return false
			end
			if self.role_info.arm_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.MASK then
			if not self.role_info.mask_info then
				return false
			end
			if self.role_info.mask_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.LINGZHU then
			if not self.role_info.lingzhu_info then
				return false
			end
			if self.role_info.lingzhu_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.XIANBAO then
			if not self.role_info.xianbao_info then
				return false
			end
			if self.role_info.xianbao_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.LINGCHONG then
			if not self.role_info.lingchong_info then
				return false
			end
			if self.role_info.lingchong_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.LINGGONG then
			if not self.role_info.linggong_info then
				return false
			end
			if self.role_info.linggong_info.capability <= 0 then
				return false
			end
		elseif tab_index == CHECK_TAB_TYPE.LINGQI then
			if not self.role_info.lingqi_info then
				return false
			end
			if self.role_info.lingqi_info.capability <= 0 then
				return false
			end
			-- ranktag
		end
	else
		return false
	end
	return true
end

function CheckData:GetTabIndexByRankType(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		return CHECK_TAB_TYPE.MOUNT
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
		return CHECK_TAB_TYPE.WING
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
		return CHECK_TAB_TYPE.HALO
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
		return CHECK_TAB_TYPE.SPIRIT
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		return CHECK_TAB_TYPE.FIGHT_MOUNT
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then
		return CHECK_TAB_TYPE.GODDESS
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
		return CHECK_TAB_TYPE.SHEN_GONG
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		return CHECK_TAB_TYPE.SHEN_YI
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then
		return CHECK_TAB_TYPE.FOOT
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WAIST then
		return CHECK_TAB_TYPE.WAIST
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HEAD then
		return CHECK_TAB_TYPE.HEAD
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ARM then
		return CHECK_TAB_TYPE.ARM
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK then
		return CHECK_TAB_TYPE.MASK
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO then
		return CHECK_TAB_TYPE.XIANBAO
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU then
		return CHECK_TAB_TYPE.LINGZHU
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGCHONG then
		return CHECK_TAB_TYPE.LINGCHONG
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG then
		return CHECK_TAB_TYPE.LINGGONG
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI then
		return CHECK_TAB_TYPE.LINGQI
	else
		return CHECK_TAB_TYPE.JUE_SE
	end
	-- ranktag
end

function CheckData:CheckSpiritTabIsOpen()
	if not self.role_info.jingling_info then
		return false
	end
	for k,v in pairs(self.role_info.jingling_info.jingling_item_list) do
		if v.jingling_id ~= 0 then
			return true
		end
	end
	return false
end

function CheckData:GetShowTabIndex()
	local show_list = {}
	for k,v in pairs(CHECK_TAB_TYPE) do
		if self:GetTabIsOpen(v) then
			table.insert(show_list, v)
		end
	end

	function sortfun (a, b) --其他
		if a < b then
			return true
		else
			return false
		end
	end
	table.sort(show_list, sortfun)
	return show_list
end

function CheckData:GetShowJingLingAttr()
	if not self.role_info.jingling_info then
		return false
	end
	local jingling_item = nil
	for k,v in pairs(self.role_info.jingling_info.jingling_item_list) do
		if v.jingling_id == self.role_info.jingling_info.use_jingling_id then
			jingling_item = v
			break
		end
	end
	if jingling_item == nil then
		jingling_item = self.role_info.jingling_info.jingling_item_list[1]
	end
	return jingling_item
end

function CheckData:GetName(rank_type)
	local name = ""
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		if not self.role_info.mount_info then
			return name
		end

		local image_id = self.role_info.mount_info.used_imageid
		if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local cfg = MountData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if cfg then
				name = cfg.image_name
			end
		else
			local cfg = MountData.Instance:GetMountImageCfg()[image_id]
			if cfg then
				name = cfg.image_name
			end
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then
		if not self.role_info.xiannv_info then
			return name
		end

		local xiannv_info = self.role_info.xiannv_info
		if xiannv_info.xiannv_name ~= "" then
			name = xiannv_info.xiannv_name
		else
			if xiannv_info.pos_list[1] ~= -1 then
				local cfg = GoddessData.Instance:GetXianNvCfg(xiannv_info.pos_list[1])
				if cfg then
					name = cfg.name
				end
			end
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
		if not self.role_info.shengong_info then
			return name
		end

		local image_id = self.role_info.shengong_info.used_imageid
		if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local cfg = ShengongData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if cfg then
				name = cfg.image_name
			end
		else
			local cfg = ShengongData.Instance:GetShengongImageCfg()[image_id]
			if cfg then
				name = cfg.image_name
			end
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		if not self.role_info.shenyi_info then
			return name
		end

		local image_id = self.role_info.shenyi_info.used_imageid
		if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local cfg = ShenyiData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if cfg then
				name = cfg.image_name
			end
		else
			local cfg = ShenyiData.Instance:GetShenyiImageCfg()[image_id]
			if cfg then
				name = cfg.image_name
			end
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
		if not self.role_info.jingling_info then
			return name
		end

		local jingling_info = self.role_info.jingling_info

		if jingling_info.phantom_imgageid ~= -1 then
			local cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(jingling_info.phantom_imgageid)
			if cfg then
				name = cfg.name
			end
		else
			if jingling_info.use_jingling_id ~= 0 then
				local cfg = SpiritData.Instance:GetSpiritResIdByItemId(jingling_info.use_jingling_id)
				if cfg then
					name = cfg.name
				end
			end
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
		if not self.role_info.wing_info then
			return name
		end

		local image_id = self.role_info.wing_info.used_imageid
		if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local cfg = WingData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if cfg then
				name = cfg.image_name
			end
		else
			local cfg = WingData.Instance:GetWingImageCfg()[image_id]
			if cfg then
				name = cfg.image_name
			end
		end
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
		if not self.role_info.halo_info then
			return name
		end

		local image_id = self.role_info.halo_info.used_imageid
		if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local cfg = HaloData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if cfg then
				name = cfg.image_name
			end
		else
			local cfg = HaloData.Instance:GetHaloImageCfg()[image_id]
			if cfg then
				name = cfg.image_name
			end
		end
	else
		name = self.role_info.role_name
	end
	return name
end

function CheckData:GetEquipList(equip_list)
	local equip_index_list = {}
	for k,v in pairs(table_name) do
		index = EquipData.Instance:GetEquipIndexByType(equip_list[i].equip_id)
		tabel.insert(equip_index_list, v)
	end
end

function CheckData:GetOpenIndex()
	local rank_type = RankData.Instance:GetRankToggleType()
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL then
		return CHECK_TAB_TYPE.JUE_SE
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		return CHECK_TAB_TYPE.MOUNT
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
		return CHECK_TAB_TYPE.WING
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
		return CHECK_TAB_TYPE.HALO
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		return CHECK_TAB_TYPE.FIGHT_MOUNT
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
		return CHECK_TAB_TYPE.SPIRIT
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then
		return CHECK_TAB_TYPE.GODDESS
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
		return CHECK_TAB_TYPE.SHEN_GONG
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		return CHECK_TAB_TYPE.SHEN_YI
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT then
		return CHECK_TAB_TYPE.FOOT
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WAIST then
		return CHECK_TAB_TYPE.WAIST
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HEAD then
		return CHECK_TAB_TYPE.HEAD
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ARM then
		return CHECK_TAB_TYPE.ARM
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MASK then
		return CHECK_TAB_TYPE.MASK
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGZHU then
		return CHECK_TAB_TYPE.LINGZHU
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANBAO then
		return CHECK_TAB_TYPE.XIANBAO
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGCHONG then
		return CHECK_TAB_TYPE.LINGCHONG
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGGONG then
		return CHECK_TAB_TYPE.LINGGONG
	elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LINGQI then
		return CHECK_TAB_TYPE.LINGQI
		-- ranktag
	end
	return CHECK_TAB_TYPE.JUE_SE
end