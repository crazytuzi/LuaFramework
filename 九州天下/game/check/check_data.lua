CheckData = CheckData or BaseClass()

CHECK_TAB_TYPE =
{
	JUE_SE = 1,
	-- MOUNT = 2,
	-- WING = 3,
	-- HALO = 4,
	-- FIGHT_MOUNT = 5,
	-- -- SPIRIT = 6,
	-- -- GODDESS = 7,
	-- SHEN_GONG = 8,
	-- SHEN_YI = 9,
	DISPLAY = 2,
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
	self.set_role_info = {}

	self.mojieconfig_type_level = ListToMapList(ConfigManager.Instance:GetAutoConfig("mojieconfig_auto").level, "mojie_type","mojie_level")
	self.jiezhi_info = ConfigManager.Instance:GetAutoConfig("gouyu_config_auto").jiezhi_level
	self.guazhui_info = ConfigManager.Instance:GetAutoConfig("gouyu_config_auto").guazhui_level
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
	self.role_info = info
end

function CheckData:SetRoleInfoChange(info)
	self.set_role_info = info
end

function CheckData:GetRoleInfoChange()
	return self.set_role_info 
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
	info_attr.fujia_shanghai = role_info.fujia_shanghai 					-- 附加伤害
	info_attr.dikang_shanghai = role_info.dikang_shanghai 					-- 抵抗伤害
	info_attr.evil_val = role_info.evil_val
	info_attr.camp_id = role_info.camp_id 									-- 所属国家

	info_attr.per_jingzhun = role_info.per_jingzhun 						-- 精准
	info_attr.per_baoji = role_info.per_baoji 								-- 暴击
	info_attr.per_kangbao = role_info.per_kangbao 							-- 抗暴
	info_attr.per_pofang = role_info.per_pofang 							-- 破防百分比
	info_attr.per_mianshang = role_info.per_mianshang 						-- 免伤百分比

	info_attr.max_hp =role_info.max_hp
	info_attr.gong_ji = role_info.gongji
	info_attr.fang_yu = role_info.fangyu
	info_attr.ming_zhong = role_info.mingzhong
	info_attr.shan_bi = role_info.shanbi
	info_attr.bao_ji = role_info.baoji
	info_attr.jian_ren = role_info.jianren

	info_attr.base_max_hp = role_info.base_max_hp						-- 基础HP
	info_attr.base_gongji = role_info.base_gongji						-- 基础攻击
	info_attr.base_fangyu = role_info.base_fangyu						-- 基础防御
	info_attr.base_mingzhong = role_info.base_mingzhong					-- 基础命中
	info_attr.base_shanbi = role_info.base_shanbi						-- 基础闪避
	info_attr.base_baoji = role_info.base_baoji							-- 基础暴击
	info_attr.base_jianren = role_info.base_jianren						-- 基础坚韧

	info_attr.ignore_fangyu = role_info.ignore_fangyu					-- 无视防御
	info_attr.hurt_increase = role_info.hurt_increase					-- 伤害追加
	info_attr.hurt_reduce = role_info.hurt_reduce						-- 伤害减免
	info_attr.ice_master = role_info.ice_master							-- 冰精通
	info_attr.fire_master = role_info.fire_master						-- 火精通
	info_attr.thunder_master = role_info.thunder_master 				-- 雷精通
	info_attr.poison_master = role_info.poison_master					-- 毒精通
	info_attr.per_mingzhong = role_info.per_mingzhong					-- 命中率
	info_attr.per_shanbi = role_info.per_shanbi							-- 闪避率
	info_attr.per_pvp_hurt_increase = role_info.per_pvp_hurt_increase	-- pvp伤害增加率
	info_attr.per_pvp_hurt_reduce = role_info.per_pvp_hurt_reduce		-- pvp受伤减免率
	info_attr.per_xixue = role_info.per_xixue							-- 吸血率
	info_attr.per_stun = role_info.per_stun								-- 击晕率


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
		-- equip_info_list = temp_halo_info.equip_info_list,
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
		-- active_special_image_flag = temp_mount_info.active_special_image_flag,
		active_special_image_flag = temp_mount_info.active_special_image_flag_ex,
		-- equip_info_list = temp_mount_info.equip_info_list,
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
		active_special_image_flag = temp_wing_info.active_special_image_flag_ex,
		clear_upgrade_time = 0,
		-- equip_info_list = temp_wing_info.equip_info_list,
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
		clear_upgrade_time = 0,
		-- equip_info_list = temp_shengong_info.equip_info_list,
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
		-- local s_attr_2 = ShengongData.Instance:GetShengongEquipAttrSum(shengong_info)
		shengong_attr.gong_ji = s_attr.gong_ji
		shengong_attr.fang_yu = s_attr.fang_yu
		shengong_attr.max_hp = s_attr.max_hp
		shengong_attr.ming_zhong = s_attr.ming_zhong
		shengong_attr.shan_bi = s_attr.shan_bi
		shengong_attr.bao_ji = s_attr.bao_ji
		shengong_attr.jian_ren = s_attr.jian_ren
		-- shengong_attr.per_pofang = s_attr_2.per_pofang
		-- shengong_attr.per_mianshang = s_attr_2.per_mianshang
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
		star_level = temp_shenyi_info.star_level,
		clear_upgrade_time = 0,
		-- equip_info_list = temp_shenyi_info.equip_info_list,
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
		-- local sy_attr_2 = ShenyiData.Instance:GetShenyiEquipAttrSum(shenyi_info)
		shenyi_attr.gong_ji = sy_attr.gong_ji
		shenyi_attr.fang_yu = sy_attr.fang_yu
		shenyi_attr.max_hp = sy_attr.max_hp
		shenyi_attr.ming_zhong = sy_attr.ming_zhong
		shenyi_attr.shan_bi = sy_attr.shan_bi
		shenyi_attr.bao_ji = sy_attr.bao_ji
		shenyi_attr.jian_ren = sy_attr.jian_ren
		-- shenyi_attr.per_pofang = sy_attr_2.per_pofang
		-- shenyi_attr.per_mianshang = sy_attr_2.per_mianshang
		shenyi_attr.client_grade = (shenyi_info.grade or 0) - 1
		shenyi_attr.used_imageid = shenyi_info.used_imageid
		shenyi_attr.shenyi_level = shenyi_info.shenyi_level
	end

	local temp_fazhen_info = role_info.fazhen_info or {}

	local fazhen_info = {
		level = temp_fazhen_info.level,
		grade = temp_fazhen_info.grade,
		grade_bless_val = 0,
		used_imageid = temp_fazhen_info.used_imageid,
		shuxingdan_count = temp_fazhen_info.shuxingdan_count,
		chengzhangdan_count = temp_fazhen_info.chengzhangdan_count,
		active_image_flag = 0,
		active_special_image_flag = temp_fazhen_info.active_special_image_flag,
		clear_upgrade_time = 0,
		-- equip_info_list = temp_fazhen_info.equip_info_list,
		skill_level_list = temp_fazhen_info.skill_level_list,
		special_img_grade_list = {},
		star_level = temp_fazhen_info.star_level,
	}
	local fm_attr = FaZhenData.Instance:GetMountAttrSum(fazhen_info)
	local fazhen_attr = {}
	fazhen_attr.capability = temp_fazhen_info.capability
	if fm_attr == 0 then
		fazhen_attr.gong_ji = 0
		fazhen_attr.fang_yu = 0
		fazhen_attr.max_hp = 0
		fazhen_attr.ming_zhong = 0
		fazhen_attr.shan_bi = 0
		fazhen_attr.bao_ji = 0
		fazhen_attr.jian_ren = 0
		-- fazhen_attr.per_pofang = 0
		-- fazhen_attr.per_mianshang = 0
		fazhen_attr.client_grade = 0
		fazhen_attr.used_imageid = 0
		fazhen_attr.level = fazhen_info.level
	else
		fazhen_attr.gong_ji = fm_attr.gong_ji
		fazhen_attr.fang_yu = fm_attr.fang_yu
		fazhen_attr.max_hp = fm_attr.max_hp
		fazhen_attr.ming_zhong = fm_attr.ming_zhong
		fazhen_attr.shan_bi = fm_attr.shan_bi
		fazhen_attr.bao_ji = fm_attr.bao_ji
		fazhen_attr.jian_ren = fm_attr.jian_ren
		-- fazhen_attr.per_pofang = fm_attr_2.per_pofang
		-- fazhen_attr.per_mianshang = fm_attr_2.per_mianshang
		fazhen_attr.client_grade = (fazhen_info.grade or 0) - 1
		fazhen_attr.used_imageid = fazhen_info.used_imageid
		fazhen_attr.level = fazhen_info.shenyi_level
	end

	local xiannv_attr = role_info.xiannv_info
	local spirit_attr = role_info.jingling_info
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
	check_attr.fight_attr = fazhen_attr

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
	-- if tab_index == CHECK_TAB_TYPE.JUE_SE then
	-- 	asset = "uis/images"
	-- 	name = "tab_icon_1000"
	-- elseif tab_index == CHECK_TAB_TYPE.MOUNT then
	-- 	asset = "uis/views/advanceview_images"
	-- 	name = "left_icon_mount"
	-- elseif tab_index == CHECK_TAB_TYPE.WING then
	-- 	asset = "uis/views/advanceview_images"
	-- 	name = "left_icon_wing"
	-- elseif tab_index == CHECK_TAB_TYPE.HALO then
	-- 	asset = "uis/views/advanceview_images"
	-- 	name = "left_icon_guanghuan"
	-- elseif tab_index == CHECK_TAB_TYPE.SPIRIT then
	-- 	asset = "uis/views/spiritview_images"
	-- 	name = "left_icon_jingling"
	-- elseif tab_index == CHECK_TAB_TYPE.GODDESS then
	-- 	asset = "uis/views/rank_images"
	-- 	name = "left_icon_nvshen"
	-- elseif tab_index == CHECK_TAB_TYPE.SHEN_GONG then
	-- 	asset = "uis/views/goddess_images"
	-- 	name = "left_icon_gong"
	-- elseif tab_index == CHECK_TAB_TYPE.SHEN_YI then
	-- 	asset = "uis/views/goddess_images"
	-- 	name = "left_icon_wing"
	-- elseif tab_index == CHECK_TAB_TYPE.FIGHT_MOUNT then
	-- 	asset = "uis/views/advanceview_images"
	-- 	name = "left_icon_zd_mount"
	-- end

	if CHECK_TAB_TYPE.JUE_SE == tab_index then
		asset = "uis/views/checkview_images"
		name = "head_icon_1000"		
	elseif CHECK_TAB_TYPE.DISPLAY == tab_index then
		asset = "uis/views/player_images"
		name = "tab_Icon_1006"
	end

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
		end
	else
		return false
	end
	return true
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
		--if self:GetTabIsOpen(v) then
			table.insert(show_list, v)
		--end
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
	-- if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
	-- 	if not self.role_info.mount_info then
	-- 		return name
	-- 	end

	-- 	local image_id = self.role_info.mount_info.used_imageid
	-- 	if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
	-- 		local cfg = MountData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	else
	-- 		local cfg = MountData.Instance:GetMountImageCfg()[image_id]
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	end
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then
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
	-- elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
	-- 	if not self.role_info.shengong_info then
	-- 		return name
	-- 	end

	-- 	local image_id = self.role_info.shengong_info.used_imageid
	-- 	if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
	-- 		local cfg = ShengongData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	else
	-- 		local cfg = ShengongData.Instance:GetShengongImageCfg(image_id)
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	end
	-- elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
	-- 	if not self.role_info.shenyi_info then
	-- 		return name
	-- 	end

	-- 	local image_id = self.role_info.shenyi_info.used_imageid
	-- 	if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
	-- 		local cfg = ShenyiData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	else
	-- 		--local cfg = ShenyiData.Instance:GetShenyiImageCfg()[image_id]
	-- 		local cfg = ShenyiData.Instance:GetShenyiImageCfg(image_id)
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	end
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
	-- elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
	-- 	if not self.role_info.wing_info then
	-- 		return name
	-- 	end

	-- 	local image_id = self.role_info.wing_info.used_imageid
	-- 	if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
	-- 		local cfg = WingData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	else
	-- 		local cfg = WingData.Instance:GetWingImageCfg()[image_id]
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	end
	-- elseif rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
	-- 	if not self.role_info.halo_info then
	-- 		return name
	-- 	end

	-- 	local image_id = self.role_info.halo_info.used_imageid
	-- 	if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
	-- 		local cfg = HaloData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	else
	-- 		local cfg = HaloData.Instance:GetHaloImageCfg(image_id)
	-- 		if cfg then
	-- 			name = cfg.image_name
	-- 		end
	-- 	end
	elseif rank_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM then
		local guild_rank_info = RankData.Instance:GetGuildRankInfo()[RANK_INDEX] 
		if guild_rank_info then
			name = guild_rank_info.tuan_zhang_name
		end
	elseif rank_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_1
	or rank_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_2
	or rank_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_3 then
		local guild_rank_info = RankData.Instance:GetGuildRankInfo()[RANK_INDEX]
		name = guild_rank_info.tuan_zhang_name
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

-- 根绝魔戒等级获取魔戒显示ID
function CheckData:GetMoJieList(mpjie_type)
	local role_info = self:GetRoleInfo()
	local mojie_list = {}
	local mojie_type_cfg = self.mojieconfig_type_level[mpjie_type]
	local mojie_level = role_info.mojie_level_list[mpjie_type + 1]
	if mojie_type_cfg and mojie_type_cfg[mojie_level] then
		table.insert(mojie_list, mpjie_type + 1, mojie_type_cfg[mojie_level][1].up_level_stuff_id) 
	end
	return mojie_list
end


function CheckData:GetDisplayInfo()
	local show_list = {}
	local attr_str_list = {}
	local name_tab = Language.Common.CheckDisplayAttrName
	for i = 1, GameEnum.CHECK_DIS_ATTR_TYPE_NUM do
		attr_str_list[i] = name_tab[i] .. Language.Common.CheckViewNo
	end

	if self.role_info == nil or not next(self.role_info) then return show_list, attr_str_list end

	local f_str = Language.Common.CheckDisplayAttrStr
	local f_no_jie_str = Language.Common.CheckDisplayAttrStrNoJie
	local DaXie_tab = CommonDataManager.DAXIE

	--坐骑
	if self.role_info.mount_info ~= nil then
		show_list.mount_image_id = self.role_info.mount_info.used_imageid or 0
		local mount_level = self.role_info.mount_info.level
		if OpenFunData.Instance:CheckIsHide("mount_jinjie") then
			local cfg = {}
			if show_list.mount_image_id < 1000 then
				cfg = MountData.Instance:GetImageListInfo(show_list.mount_image_id)
			else
				cfg = MountData.Instance:GetSpecialImageCfg(show_list.mount_image_id - 1000)
				if cfg ~= nil then
					show_list.mount_image_id = cfg.res_id or 0
				end
			end
			if cfg ~= nil and next(cfg) ~= nil then
				show_list.mount_image_id = cfg.res_id or 0
				local grade_cfg = MountData.Instance:GetMountGradeCfg(self.role_info.mount_info.grade)
				local grade_str = (grade_cfg ~= nil and grade_cfg.gradename) or ""
				if "" ~= grade_str then
					attr_str_list[1] = string.format(f_str, name_tab[1], cfg.image_name or "", grade_str)
				else
					attr_str_list[1] = string.format(f_no_jie_str, name_tab[1], cfg.image_name or "")
				end
			end
		end
	end

	--天罡
	if self.role_info.halo_info ~= nil then
		show_list.halo_image_id = self.role_info.halo_info.used_imageid or 0
		if show_list.halo_image_id > 0 then
			local cfg = {}
			if show_list.halo_image_id < 1000 then
				cfg = HaloData.Instance:GetHaloImageCfg(show_list.halo_image_id)

			else
				cfg = HaloData.Instance:GetSpecialImageCfg(show_list.halo_image_id - 1000)
			end	

			if cfg ~= nil and next(cfg) ~= nil then
			show_list.halo_image_id = cfg.res_id or 0
			local grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.role_info.halo_info.grade)
			local grade_str = (grade_cfg ~= nil and grade_cfg.gradename) or ""
				if "" ~= grade_str then
					attr_str_list[2] = string.format(f_str, name_tab[2], cfg.image_name or "", grade_str)
				else
					attr_str_list[2] = string.format(f_no_jie_str, name_tab[2], cfg.image_name or "")
				end
			end		
		end
	end

	--足迹
	if self.role_info.shengong_info ~= nil then
		--show_list.foot_image_id = math.ceil(self.role_info.shengong_info.grade / 10)
		show_list.foot_image_id = self.role_info.shengong_info.used_imageid or 0
		if show_list.foot_image_id > 0 then
			local cfg = {}
			if show_list.foot_image_id < 1000 then
				cfg = ShengongData.Instance:GetImageListInfo(show_list.foot_image_id)
			else
				cfg = ShengongData.Instance:GetSpecialImageCfg(show_list.foot_image_id - 1000)
			end

			if cfg ~= nil and next(cfg) ~= nil then
				show_list.foot_image_id = cfg.res_id or 0
				local grade_cfg = ShengongData.Instance:GetShengongGradeCfg(self.role_info.shengong_info.grade)
				local grade_str = (grade_cfg ~= nil and grade_cfg.gradename) or ""
				if "" ~= grade_str then
					attr_str_list[3] = string.format(f_str, name_tab[3], cfg.image_name or "", grade_str)
				else
					attr_str_list[3] = string.format(f_no_jie_str, name_tab[3], cfg.image_name or "")
				end
			end	
		end
	end

	--披风
	if self.role_info.shenyi_info ~= nil then
		show_list.mantle_image_id = self.role_info.shenyi_info.used_imageid or 0
		if show_list.mantle_image_id > 0 then
			local cfg = {}
			if show_list.mantle_image_id < 1000 then
				cfg = ShenyiData.Instance:GetImageListInfo(show_list.mantle_image_id)
			else
				cfg = ShenyiData.Instance:GetSpecialImageCfg(show_list.mantle_image_id - 1000)
			end

			if cfg ~= nil and next(cfg) ~= nil then
				show_list.mantle_image_id = cfg.res_id or 0
				local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.role_info.shenyi_info.grade)
				local grade_str = (grade_cfg ~= nil and grade_cfg.gradename) or ""
				if "" ~= grade_str then
					attr_str_list[4] = string.format(f_str, name_tab[4], cfg.image_name or "", grade_str)
				else
					attr_str_list[4] = string.format(f_no_jie_str, name_tab[4], cfg.image_name or "")
				end
			end
		end
	end

	--武将
	if self.role_info.greate_soldier_info ~= nil then
		show_list.ming_image_id = self.role_info.greate_soldier_info.img_id or 0
		if show_list.ming_image_id >= 0 then
			local cfg = FamousGeneralData.Instance:GetSingleDataBySeq(show_list.ming_image_id)
			if cfg ~= nil and next(cfg) ~= nil then
				show_list.ming_image_id = cfg.image_id or 0
				attr_str_list[5] = string.format(f_no_jie_str, name_tab[5], cfg.name or "")
			end
		end
	end

	--时装
	if self.role_info.shizhuang_part_list ~= nil then
		if self.role_info.shizhuang_part_list[2] ~= nil then
			show_list.role_image_id = self.role_info.shizhuang_part_list[2].use_index or 0
			if show_list.role_image_id > 0 then
				local cfg = FashionData.Instance:GetClothingConfig(show_list.role_image_id)
				if cfg ~= nil and next(cfg) ~= nil then
					local index = string.format("resouce%s%s", self.role_info.prof, self.role_info.sex)
					if cfg[index] ~= nil then
						show_list.role_image_id = cfg[index]
					end
					attr_str_list[6] = string.format(f_no_jie_str, name_tab[6], cfg.name or "")
				end
			else
				show_list.role_image_id = "120" .. self.role_info.prof .. "001"
			end
		end
	end

	--羽翼
	if self.role_info.wing_info ~= nil then
		show_list.wing_image_id = self.role_info.wing_info.used_imageid or 0
		if show_list.wing_image_id > 0 then
			local cfg = {}
			if show_list.wing_image_id < 1000 then
				cfg = WingData.Instance:GetImageListInfo(show_list.wing_image_id)
			else
				cfg = WingData.Instance:GetSpecialImageCfg(show_list.wing_image_id - 1000)
			end

			if cfg ~= nil and next(cfg) ~= nil then
				show_list.wing_image_id = cfg.res_id or 0
				local grade_cfg = WingData.Instance:GetWingGradeCfg(self.role_info.wing_info.grade)
				local grade_str = (grade_cfg ~= nil and grade_cfg.gradename) or ""
				if "" ~= grade_str then
					attr_str_list[7] = string.format(f_str, name_tab[7], cfg.image_name or "", grade_str)
				else
					attr_str_list[7] = string.format(f_no_jie_str, name_tab[7], cfg.image_name or "")
				end
			end
		end
	end

	--法阵
	if self.role_info.fazhen_info ~= nil then
		show_list.fazhen_image_id = self.role_info.fazhen_info.used_imageid or 0
		if show_list.fazhen_image_id > 0 then
			local cfg = {}
			if show_list.fazhen_image_id < 1000 then
				cfg = FaZhenData.Instance:GetImageListInfo(show_list.fazhen_image_id)
			else
				cfg = FaZhenData.Instance:GetSpecialImageCfg(show_list.fazhen_image_id - 1000)
			end

			if cfg ~= nil and next(cfg) ~= nil then
				show_list.fazhen_image_id = cfg.res_id or ""
				local grade_cfg = FaZhenData.Instance:GetMountGradeCfg(self.role_info.fazhen_info.grade)
				local grade_str = (grade_cfg ~= nil and grade_cfg.gradename) or ""
				if "" ~= grade_str then
					attr_str_list[8] = string.format(f_str, name_tab[8], cfg.image_name or "", grade_str)
				else
					attr_str_list[8] = string.format(f_no_jie_str, name_tab[8], cfg.image_name or "")
				end
			end
		end
	end

	--法宝
	if self.role_info.spirit_fazhen_info ~= nil then
		show_list.fabao_image_id = self.role_info.spirit_fazhen_info.used_imageid or 0
		if show_list.fabao_image_id > 0 then
			local cfg = {}
			if show_list.fabao_image_id < 1000 then
				cfg = HalidomData.Instance:GetImageListInfo(show_list.fabao_image_id)
			else
				cfg = HalidomData.Instance:GetSpecialImageCfg(show_list.fabao_image_id - 1000)
			end

			if cfg ~= nil and next(cfg) ~= nil then
				show_list.fabao_image_id = cfg.res_id or 0
				local grade_cfg = HalidomData.Instance:GetHalidomGradeCfg(self.role_info.spirit_fazhen_info.grade)
				local grade_str = (grade_cfg ~= nil and grade_cfg.gradename) or ""
				if "" ~= grade_str then
					attr_str_list[9] = string.format(f_str, name_tab[9], cfg.image_name or "", grade_str)
				else
					attr_str_list[9] = string.format(f_no_jie_str, name_tab[9], cfg.image_name or "")
				end
			end			
		end
	end

	--芳华
	if self.role_info.spirit_halo_info ~= nil then
		show_list.beauty_halo_image_id = self.role_info.spirit_halo_info.used_imageid or 0
		if show_list.beauty_halo_image_id > 0 then
			local cfg = {}
			if show_list.beauty_halo_image_id < 1000 then
				cfg = BeautyHaloData.Instance:GetImageListInfo(show_list.beauty_halo_image_id)
			else
				cfg = BeautyHaloData.Instance:GetSpecialImageCfg(show_list.beauty_halo_image_id - 1000)
			end

			if cfg ~= nil and next(cfg) ~= nil then
				show_list.beauty_halo_image_id = cfg.res_id or 0
				local grade_cfg = BeautyHaloData.Instance:GetBeautyHaloGradeCfg(self.role_info.spirit_halo_info.grade)
				local grade_str = (grade_cfg ~= nil and grade_cfg.gradename) or ""
				if "" ~= grade_str then
					attr_str_list[10] = string.format(f_str, name_tab[10], cfg.image_name or "", grade_str)
				else
					attr_str_list[10] = string.format(f_no_jie_str, name_tab[10], cfg.image_name or "")
				end
			end			
		end		
	end

	--美人
	if self.role_info.beauty_info ~= nil then
		show_list.beauty_image_id = self.role_info.beauty_info.img_id or 0
		if show_list.beauty_image_id >= 0 then
			local cfg = {}
			if show_list.beauty_image_id < 100 then
				cfg = BeautyData.Instance:GetActiveCfgBySeq(show_list.beauty_image_id)
			else
				cfg = BeautyData.Instance:GetBeautyHuanhuaCfg(show_list.beauty_image_id - 100)
			end
			if cfg ~= nil and next(cfg) ~= nil then
				show_list.beauty_image_id = cfg.model or 0
				attr_str_list[11] = string.format(f_no_jie_str, name_tab[11], cfg.name or "")
			end
		end
	end

	--武器
	if self.role_info.shizhuang_part_list ~= nil then
		if self.role_info.shizhuang_part_list[1] ~= nil then
			show_list.wuqi_image_id = self.role_info.shizhuang_part_list[1].use_index or 0
			if show_list.wuqi_image_id > 0 then
				local cfg = FashionData.Instance:GetWuqiConfig(show_list.wuqi_image_id)
				if cfg ~= nil and next(cfg) ~= nil then
					local index = string.format("resouce%s%s", self.role_info.prof, self.role_info.sex)
					if cfg[index] ~= nil then
						show_list.wuqi_image_id = cfg[index]
					end

					attr_str_list[12] = string.format(f_no_jie_str, name_tab[12], cfg.name or "")
				end
			end
		end
	end

	--称号
	if self.role_info.title_list ~= nil then
		if self.role_info.title_list[1] ~= nil then
			show_list.title_image_id = self.role_info.title_list[1]
		end
	end
	return show_list, attr_str_list
end

function CheckData:GetJieZhiSkillID()
	if self.jiezhi_info[1] == nil or self.role_info == nil then return end
	local level = self.role_info.shipin_info_list[1]
	if level > 0 then
		return self.jiezhi_info[1].stuff_id
	end
end
function CheckData:GetGuaZhuiSkillID()
	if self.guazhui_info[1] == nil or self.role_info == nil then return end
	local level = self.role_info.shipin_info_list[2]
	if level > 0 then
		return self.guazhui_info[1].stuff_id
	end
end

function CheckData:GetJieZhiLevel()
	if self.role_info == nil then  return end

	if self.role_info.shipin_info_list == nil then
		return
	end

	return self.role_info.shipin_info_list[1] 
end

function CheckData:GetGuaZhuiLevel()
	if self.role_info == nil then  return end

	if self.role_info.shipin_info_list == nil then
		return
	end
	return self.role_info.shipin_info_list[2]
end