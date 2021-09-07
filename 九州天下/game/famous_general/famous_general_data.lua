FamousGeneralData = FamousGeneralData or BaseClass()
FamousGeneralData.SHOW_ATTR = {
	"gongji",
	"fangyu",
	"maxhp",
	"ice_master",
	"fire_master",
	"thunder_master",
	"poison_master",
}

FamousGeneralData.Potential = {
	"max_gongji_potential",
	"max_fangyu_potential",
	"max_hp_potential",
}

FamousGeneralData.PotentialLimit = {
	"add_wash_upper_limit_gongji",
	"add_wash_upper_limit_fangyu",
	"add_wash_upper_limit_maxhp",
}

FamousGeneralData.TempPotential = {
	"max_gongji_tmp_potential",
	"max_fangyu_tmp_potential",
	"max_hp_tmp_potential",
}

FamousGeneralData.Change = {
	["gongji_tmp"] = "gongji",
	["fangyu_tmp"] = "fangyu",
	["hp_tmp"] = "hp",
}
function FamousGeneralData:__init()
	if FamousGeneralData.Instance then
		print_error("[FamousGeneralData] Attemp to create a singleton twice !")
	end
	FamousGeneralData.Instance = self
	self.config = nil
	self.general_info_cfg = nil
	self.passive_skill = nil
	self.normal_skill = nil
	self.zuhe_cfg = nil
	self.slot_cfg = nil
	self.other_cfg = nil
	self.draw_cfg = nil
	self.red_skill = nil
	self.solt_name = nil
	self.experience = nil
	self.solt_seq_level = nil
	self.chinese_zodiac_cfg = nil
	self.xinghun_cfg  = nil
	self.xinghun_cfg2  = nil
	self.xinghun_extra_cfg = nil
	self.starsoul_point_effect_cfg = nil

	self.general_info_list = {}
	self.last_wash_point = {}
	self.cur_used_seq = -1
	self.bianshen_end_timestamp = 0
	self.slot_info = {}

	self.active_list = {}
	self.data_change = false
	self.bianshen_cd = 0
	self.bianshen_cd_reduce_s = 0
	self.sort_list = {}
	self.bone_sort_list = {}
	self.has_dailyfirst_draw_ten = 0

	self.select_index = 1									-- 策划需求 切换第一第二标签不更换选中名将
	
	local great_soldier_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto") or {}
	self.soldier_name_cfg = ListToMap(great_soldier_cfg.slot_name,"seq") 
	self.soldier_leve_cfg = ListToMap(great_soldier_cfg.level,"seq")
	self.soldier_model_cfg = ListToMap(great_soldier_cfg.level,"image_id")
	self.soldier_draw_cfg = ListToMapList(great_soldier_cfg.draw, "is_show_item")
	self.soldier_zuhe_cfg = ListToMap(great_soldier_cfg.zuhe,"seq")
	self.soldier_skill_cfg = ListToMap(great_soldier_cfg.skill,"skill_id")
	self.experience_cfg = ListToMap(great_soldier_cfg.experience,"bs_id")
	self.soldier_passive_skill_cfg = ListToMap(great_soldier_cfg.passive_skill,"seq")
	self.item_list = {}							-- 抽奖获得的物品列表

	self.wash_point_limit_cfg = great_soldier_cfg.wash_attr_upper_limit_increase or {}

	-- 星座所有信息
	self.xingzuo_all_info = {
		zodiac_level_list = {},
		xinghun_level_list = {},
		xinghun_level_max_list = {},
		xinghun_baoji_value_list = {},
		chinesezodiac_equip_list = {},
		miji_list = {},
		zodiac_progress = 0,
		upgrade_zodiac = 0,
		xinghun_progress = 0,
	} 
end

function FamousGeneralData:__delete()
	FamousGeneralData.Instance = nil
	self.last_wash_point = {}
end

function FamousGeneralData:GetGeneralConfig()
	if not self.config then
		self.config = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto")
	end
	return self.config
end

function FamousGeneralData:GeneralInfoCfg()
	if not self.general_info_cfg then
		self.general_info_cfg = self:GetGeneralConfig().level
	end
	return self.general_info_cfg or {}
end

function FamousGeneralData:GetPassiveSkillCfg()
	if not self.passive_skill then 
		self.passive_skill = self:GetGeneralConfig().passive_skill
	end
	return self.passive_skill
end

function FamousGeneralData:GetSkillCfg()
	if not self.normal_skill then 
		self.normal_skill = self:GetGeneralConfig().skill
	end
	return self.normal_skill
end

function FamousGeneralData:GetSoltCfg()
	if not self.slot_cfg then
		self.slot_cfg = self:GetGeneralConfig().slot
	end
	return self.slot_cfg
end

function FamousGeneralData:GetOtherCfg()
	if not self.other_cfg then 
		self.other_cfg = self:GetGeneralConfig().other[1]
	end
	return self.other_cfg
end

function FamousGeneralData:GetRedSkill()
	if not self.red_skill then
		self.red_skill = self:GetGeneralConfig().specialskill_tips
	end
	return self.red_skill
end

function FamousGeneralData:GetSlotName(slot_seq)
	if not slot_seq then 
		return "", 0
	end

	local name_str = ""
	local need_level = 0
	if self.soldier_name_cfg[slot_seq] then
		name_str = self.soldier_name_cfg[slot_seq].name
		need_level = self.soldier_name_cfg[slot_seq].need_level
	end

	return name_str, need_level
end

function FamousGeneralData:GetSoldierCfg(slot_seq)
	if self.soldier_name_cfg[slot_seq] then
		return self.soldier_name_cfg[slot_seq]
	end
end

function FamousGeneralData:SetGreateSoldierItemInfo(protocol)
	local index = FamousGeneralCtrl.Instance:GetCurSelectIndex()
	if protocol.seq == index then
		self.last_wash_point = self:GetGeneralSingleInfoBySeq(index)
	end
	self.general_info_list[protocol.seq] = protocol.item_info
	self.general_info_list[protocol.seq].color = self:GetSingleDataBySeq(protocol.seq).color
	self.general_info_list[protocol.seq].active_skill_type = self:GetSingleDataBySeq(protocol.seq).active_skill_type
	self.general_info_list[protocol.seq].is_active = self:CheckGeneralIsActive(protocol.seq) and 0 or 2
	self.data_change = true
end

function FamousGeneralData:GetLastWashPointInfoBySeq()
	if next(self.last_wash_point) then
		return self.last_wash_point
	end
end

function FamousGeneralData:SetGreateSoldierOtherInfo(protocol)
	self.cur_used_seq = protocol.cur_used_seq
	self.has_dailyfirst_draw_ten = protocol.has_dailyfirst_draw_ten
	self.bianshen_end_timestamp = protocol.bianshen_end_timestamp
	self.bianshen_cd = protocol.bianshen_cd
	self.bianshen_cd_reduce_s = protocol.bianshen_cd_reduce_s
end

function FamousGeneralData:SetGreateSoldierSlotInfo(protocol)
	local index = 1
	for k,v in pairs(protocol.slot_param) do
		self.slot_info[index] = v
		self.slot_info[index].place = k
		index = index + 1
	end
end

function FamousGeneralData:GetGeneralInfoList()
	return self.general_info_list
end

function FamousGeneralData:GetSingleDataBySeq(seq)
	return self.soldier_leve_cfg[seq] or nil
end

function FamousGeneralData:GetGeneralSingleInfoBySeq(seq)
	return self.general_info_list[seq] or nil
end

function FamousGeneralData:GetActiveGeneral()
	if self.data_change then
		self.active_list = {}
		for k,v in pairs(self.general_info_list) do
			local info = self:GetSingleDataBySeq(v.seq)
			if v.level > 0 and info then
				table.insert(self.active_list, info)
			end
		end
		self.data_change = false
	end
	return self.active_list
end

function FamousGeneralData:CheckPassiveSkillIsActive(skill_seq)
	local active_list = self:GetActiveGeneral()
	for k,v in pairs(self.active_list) do
		if skill_seq == v.active_passive_skill_seq then
			return true
		end
	end
	return false
end

function FamousGeneralData:GetZuheCfg()
	if not self.zuhe_cfg then
		self.zuhe_cfg = self:GetGeneralConfig().zuhe
	end
	return self.zuhe_cfg
end

function FamousGeneralData:GetComboDisplayList(seq)
	if nil == seq then return {} end

	local total_cfg = self.soldier_zuhe_cfg[seq]
	return total_cfg and Split(total_cfg.greate_soldier_seq_list, "|") or {}
end

function FamousGeneralData:GetZuheSingleCfg(seq)
	if seq == nil then return end
	local zuhe_cfg = self.soldier_zuhe_cfg
	if zuhe_cfg[seq] then
		return zuhe_cfg[seq]
	end
end

function FamousGeneralData:CheckGeneralIsActive(seq)
	for k,v in pairs(self.general_info_list) do
		if seq == v.seq and v.level > 0 then
			return true
		end
	end
	return false
end

--检查名将池是否有已激活，出战的武将
function FamousGeneralData:CheckGeneralPoolHasActive()
	local fight_num = 0
	local totle_num = 0
	for k,v in pairs(self.slot_info) do
		if v.item_seq ~= -1 then
			fight_num = fight_num + 1
		end
	end

	if fight_num >= COMMON_CONSTS.GREATE_SOLDIER_SLOT_MAX_COUNT then
		return false
	end

	for k,v in pairs(self.general_info_list) do
		if v.level > 0 then
			totle_num = totle_num + 1
		end
		if totle_num > COMMON_CONSTS.GREATE_SOLDIER_SLOT_MAX_COUNT then
			break
		end
	end

	if totle_num > fight_num then
		return true
	end

	return false
end

function FamousGeneralData:GetslotInfo()
	return self.slot_info
end

function FamousGeneralData:GetSingleSlotInfo(slot_seq)--
	if nil == slot_seq then return end
	for k,v in pairs(self.slot_info) do
		if slot_seq == v.place then
			return v
		end
	end
	return {}
end

function FamousGeneralData:GetSlotLevelCfg(level, seq)
	local solt_seq_level = self:GetSlotSeqLevelCfg()
	if nil == level or nil == seq or nil == solt_seq_level then return end
	local solt_cfg = solt_seq_level[seq]
	if solt_cfg and solt_cfg[level] then
		return solt_cfg[level]
	end
end

function FamousGeneralData:GetSlotSeqLevelCfg()
	if nil == self.solt_seq_level then
		self.solt_seq_level = ListToMap(self:GetSoltCfg(), "seq","level")
	end
	return self.solt_seq_level
end

function FamousGeneralData:GetResIdBySeq(seq)
	local data = self.soldier_leve_cfg[seq]
	return data and data.image_id or 0
end

function FamousGeneralData:GetSeqByImageId(image_id)
	if nil == image_id then return end
	local data = self.soldier_model_cfg[image_id]
	return data.seq or 0
end

function FamousGeneralData:CheckShowSkill()
	for k,v in pairs(self.slot_info) do
		if v.place == 0 and v.item_seq ~= -1 then
			return true
		end
	end
	return false
end

function FamousGeneralData:GetEndTimestamp()
	return self.bianshen_end_timestamp
end

function FamousGeneralData:GetCurUseSeq()
	return self.cur_used_seq
end

function FamousGeneralData:CheckIsGeneralSkill(skill_id)
	if skill_id == nil then return false end

	local skill_cfg = self.soldier_skill_cfg[skill_id]
	return skill_cfg and true or false
end

function FamousGeneralData:GetExperience(seq)
	if seq == nil then return nil end
	local cfg = self.experience_cfg
	return cfg[seq] or nil
end

function FamousGeneralData:GetsinglePassive(seq)
	if seq == nil then return nil end
	local cfg = self.soldier_passive_skill_cfg
	return cfg[seq] or nil
end

function FamousGeneralData:GetSpePassive(seq)
	if not self.red_skill then
		self.red_skill = self:GetGeneralConfig().specialskill_tips
	end
	local active_skill_type = self.general_info_list[seq].active_skill_type
	for k,v in pairs(self.red_skill) do
		if v.active_skill_type == active_skill_type then
			return v
		end
	end
	return {}
end

function FamousGeneralData:CheckComboIsActive(combo_seq)	
	local temp = self:GetComboDisplayList(combo_seq)
	for k,v in pairs(temp) do
		if not self:CheckGeneralIsActive(tonumber(v)) then
			return false
		end
	end
	return true
end

function FamousGeneralData:GetTextColor(percent)
	local color =  GameEnum.ITEM_COLOR_GREEN
	if percent >= 90 then
		color = GameEnum.ITEM_COLOR_ORANGE
	elseif percent >= 80 then
		color = GameEnum.ITEM_COLOR_PURPLE
	elseif percent >= 70 then
		color = GameEnum.ITEM_COLOR_BLUE
	elseif percent >= 60 then
		color = GameEnum.ITEM_COLOR_GREEN
	end
	return color
end

function FamousGeneralData:GetShowReward()
	return self.soldier_draw_cfg[1] or {}
end

function FamousGeneralData:GetBianShenCds()
	local real_cd = self.bianshen_cd / 1000 - self.bianshen_cd_reduce_s
	if real_cd < 0 then
		real_cd = 0
	end

	return real_cd
end

function FamousGeneralData:CheckSpecialSkillIsActive(id)
	if not id then return false end
	local level_cfg = self.soldier_leve_cfg
	for k,v in pairs(level_cfg) do
		if id == v.active_skill_type then
			return self:CheckGeneralIsActive(v.seq)
		end
	end
	return false
end

function FamousGeneralData:AfterSortList()
	if next(self.sort_list) then return self.sort_list end
	local level_cfg = TableCopy(self.soldier_leve_cfg)
	local other_cfg = self:GetOtherCfg()
	local data_list = {}
	for k,v in pairs(level_cfg) do
		local temp = v
		local cur_cfg = self:GetGeneralSingleInfoBySeq(v.seq)
		temp.is_active = self:CheckGeneralIsActive(v.seq) and 0 or 2
		temp.can_active = (ItemData.Instance:GetItemNumIsEnough(v.item_id, 1) and cur_cfg.level < other_cfg.max_level) and 1 or 2
		table.insert(data_list, v)
	end
	SortTools.SortAsc(data_list, "can_active", "is_active", "color", "seq")
	self.sort_list = data_list
	return self.sort_list
end

function FamousGeneralData:AfterSortListWithOpenLevel()
	if next(self.bone_sort_list) then return self.bone_sort_list end
	local level_cfg = TableCopy(self.soldier_leve_cfg)
	local other_cfg = self:GetOtherCfg()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local data_list = {}
	for k,v in pairs(level_cfg) do
		local temp = v
		local cur_cfg = self:GetGeneralSingleInfoBySeq(v.seq)
		local cur_level = self:GetStarSoulLevelByIndex(v.seq + 1)
		local open_level = self:GetStarSoulInfoByIndexAndLevel(v.seq + 1, cur_level).open_level
		local level_flag = main_role_vo.level >= open_level
		temp.open_level = open_level
		temp.is_active = (self:CheckGeneralIsActive(v.seq) and level_flag) and 0 or 2
		temp.can_active = (ItemData.Instance:GetItemNumIsEnough(v.item_id, 1) and cur_cfg.level < other_cfg.max_level) and 1 or 2
		table.insert(data_list, v)
	end
	SortTools.SortAsc(data_list, "is_active", "open_level", "can_active", "color", "seq")
	self.bone_sort_list = data_list
	return self.bone_sort_list
end

function FamousGeneralData:GetBianShenTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local cd_s = (self.bianshen_end_timestamp - now_time)
	return cd_s
end

function FamousGeneralData:SetSelectIndex(select_index)
	self.select_index = select_index
end

function FamousGeneralData:GetSelectIndex()
	return self.select_index
end

function FamousGeneralData:GetIndexBySeq(cur_seq)
	local data_list = self:AfterSortList()
	for k,v in pairs(data_list) do
		if cur_seq == v.seq then
			return k
		end
	end
	return 1
end

function FamousGeneralData:SetItemList(item_list)
	self.item_list = item_list
end

function FamousGeneralData:GetItemList()
	return self.item_list or {}
end

function FamousGeneralData:GetCurSlotBySeq(seq)
	for k,v in pairs(self.slot_info) do
		if seq == v.item_seq then
			return v.place
		end
	end
	return nil
end

function FamousGeneralData:IsAllOrangeo(select_seq)
	if not select_seq then return false end

	local select_cfg = self:GetSingleDataBySeq(select_seq)
	if not select_cfg then return false end
	local select_info = self:GetGeneralSingleInfoBySeq(select_cfg.seq)
	if not select_info then return false end

	for k,v in pairs(select_info) do
		if select_cfg["max_" .. k .. "_potential"] then
			local percent = v * 100 / select_cfg["max_" .. k .. "_potential"]
			if percent < 90 then
				return false
			end
		end
	end

	return true
end

function FamousGeneralData:IsTempAllOrangeo(select_seq)
	if not select_seq then return false end

	local select_cfg = self:GetSingleDataBySeq(select_seq)
	if not select_cfg then return false end
	local select_info = self:GetGeneralSingleInfoBySeq(select_cfg.seq)
	if not select_info then return false end

	for k,v in pairs(select_info) do
		local cfg_name = FamousGeneralData.Change[k] or ""
		if select_cfg["max_" .. cfg_name .. "_potential"] then
			local percent = v * 100 / select_cfg["max_" .. cfg_name .. "_potential"]
			if percent < 90 then
				return false
			end
		end
	end

	return true
end

function FamousGeneralData:ClearSortList()
	self.sort_list = {}
end

function FamousGeneralData:IsFirstTenChou()
	return self.has_dailyfirst_draw_ten == 0
end

function FamousGeneralData:GetFamousCapAndAttr()
	local cap = 0
	local all_attr = CommonStruct.Attribute()

	if self.general_info_list ~= nil then
		local slot_list = {}
		if self.slot_info ~= nil then
			for k,v in pairs(self.slot_info) do
				slot_list[v.item_seq] = v
			end
		end

		for k,v in pairs(self.general_info_list) do
			if v ~= nil and v.level > 0 then
				local attr = CommonStruct.Attribute()
				local level_cfg = self:GetSingleDataBySeq(v.seq)
				if level_cfg ~= nil and next(level_cfg) ~= nil then
					local level_attr = CommonDataManager.GetAttributteByClass(level_cfg)
					attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.MulAttribute(level_attr, v.level))
				end

				if slot_list[v.seq] ~= nil then
					local solt_data = slot_list[v.seq]
					local slot_cfg = self:GetSlotLevelCfg(solt_data.level, solt_data.place)
					if slot_cfg ~= nil and next(slot_cfg) ~= nil then
						attr["gong_ji"] = attr["gong_ji"] + math.floor(v.gongji * 0.01 * slot_cfg.gongji_conv_rate)
						attr["fang_yu"] = attr["fang_yu"] + math.floor(v.fangyu * 0.01 * slot_cfg.fangyu_conv_rate)
						attr["max_hp"] = attr["max_hp"] + math.floor(v.hp * 0.2 * slot_cfg.hp_conv_rate)
					end
				end

				all_attr = CommonDataManager.AddAttributeAttr(all_attr, attr)
			end
		end
	end

	local zuhe_attr = CommonStruct.Attribute()
	if self.soldier_zuhe_cfg ~= nil then
		for k,v in pairs(self.soldier_zuhe_cfg) do
			if self:CheckComboIsActive(v.seq) then
				local attr = CommonDataManager.GetAttributteByClass(v)
				zuhe_attr = CommonDataManager.AddAttributeAttr(zuhe_attr, CommonDataManager.GetAttributteByClass(attr))
			end
		end
	end

	all_attr = CommonDataManager.AddAttributeAttr(all_attr, zuhe_attr)
	cap = CommonDataManager.GetCapability(all_attr)

	return all_attr, cap
end

----------------------根骨--------------
function FamousGeneralData:SetShengXiaoAllInfo(protocol)
	self.xingzuo_all_info.zodiac_level_list = protocol.zodiac_level_list
	self.xingzuo_all_info.xinghun_level_list = protocol.xinghun_level_list
	self.xingzuo_all_info.xinghun_level_max_list = protocol.xinghun_level_max_list
	self.xingzuo_all_info.xinghun_baoji_value_list = protocol.xinghun_baoji_value_list
	self.xingzuo_all_info.chinesezodiac_equip_list = protocol.chinesezodiac_equip_list
	self.xingzuo_all_info.miji_list = protocol.miji_list
	self.xingzuo_all_info.zodiac_progress = protocol.zodiac_progress
	self.xingzuo_all_info.upgrade_zodiac = protocol.upgrade_zodiac
	self.xingzuo_all_info.xinghun_progress = protocol.xinghun_progress
end

function FamousGeneralData:GetChineseZodiacCfg()
	if not self.chinese_zodiac_cfg then
		self.chinese_zodiac_cfg = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto") or {}
	end
	return self.chinese_zodiac_cfg
end

function FamousGeneralData:GetXingHunCfg()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.xinghun_cfg then
		self.xinghun_cfg = ListToMap(chinese_zodiac_cfg.xinghun, "seq", "level")
	end
	return self.xinghun_cfg
end

function FamousGeneralData:GetXingHunCfg2()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.xinghun_cfg2 then
		self.xinghun_cfg2 = ListToMap(chinese_zodiac_cfg.xinghun, "seq")
	end
	return self.xinghun_cfg2
end

function FamousGeneralData:GetXingHunExtraCfg()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.xinghun_extra_cfg then
		self.xinghun_extra_cfg = chinese_zodiac_cfg.xinghun_extra_info
	end
	return self.xinghun_extra_cfg
end

function FamousGeneralData:GetXingHunExtraCfg()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.xinghun_extra_cfg then
		self.xinghun_extra_cfg = chinese_zodiac_cfg.xinghun_extra_info
	end
	return self.xinghun_extra_cfg
end

function FamousGeneralData:GetStarSoulPointEffectCfg()
	local chinese_zodiac_cfg = self:GetChineseZodiacCfg()
	if not self.starsoul_point_effect_cfg then
		self.starsoul_point_effect_cfg = chinese_zodiac_cfg.xinghun_effect
	end
	return self.starsoul_point_effect_cfg
end

function FamousGeneralData:GetStarSoulPointCfg(index)
	local point_effect_list = {}
	local starsoul_point_effect_cfg = self:GetStarSoulPointEffectCfg()
	local cfg = {}
	for k,v in pairs(starsoul_point_effect_cfg) do
		if v.seq + 1 == index then
			cfg = v
		end
	end
	for i = 1, 10 do
		if cfg["point" .. i .. "_x"] and cfg["point" .. i .. "_y"]
			and cfg["point" .. i .. "_y"] ~= "" and cfg["point" .. i .. "_x"] ~= "" then
			point_effect_list[i] = {}
			point_effect_list[i].x = cfg["point" .. i .. "_x"]
			point_effect_list[i].y = cfg["point" .. i .. "_y"]
		end
	end
	return point_effect_list
end

function FamousGeneralData:GetStarSoulLevelList()
	return self.xingzuo_all_info.xinghun_level_list
end

function FamousGeneralData:GetStarSoulLevelByIndex(index)
	return self.xingzuo_all_info.xinghun_level_list[index] or 0
end

function FamousGeneralData:GetStarSoulMaxLevelList()
	return self.xingzuo_all_info.xinghun_level_max_list
end

function FamousGeneralData:GetStarSoulMaxLevelByIndex(index)
	return self.xingzuo_all_info.xinghun_level_max_list[index] or 0
end

function FamousGeneralData:GetStarSoulBaojiList()
	return self.xingzuo_all_info.xinghun_baoji_value_list
end

function FamousGeneralData:GetStarSoulBaojiByIndex(index)
	return self.xingzuo_all_info.xinghun_baoji_value_list[index] or 0
end

-- 得到星魂开锁进程
function FamousGeneralData:GetStarSoulProgress()
	return self.xingzuo_all_info.xinghun_progress
end

function FamousGeneralData:GetStarSoulInfoByIndexAndLevel(index, level)
	local xinghuncfg = self:GetXingHunCfg()
	local cfg = xinghuncfg[index - 1]
	return cfg and cfg[level] or nil
end

function FamousGeneralData:GetLowestOpenLevelGeneralSeq()
	local xinghuncfg2 = self:GetXingHunCfg2()
	local cfg = xinghuncfg2
	local level = 999
	local seq = -1
	for k,v in pairs(xinghuncfg2) do
		local is_active = self:CheckGeneralIsActive(k)
		if level > v.open_level and not is_active then
			level = v.open_level
			seq = k
		end
	end
	return seq
end

function FamousGeneralData:GetWashPointLimitByIndexAndLevel(index, level)
	local data = {}
	data.add_wash_upper_limit_gongji = 0
	data.add_wash_upper_limit_fangyu = 0
	data.add_wash_upper_limit_maxhp = 0
	for k,v in pairs(self.wash_point_limit_cfg) do
		if v.seq == index - 1 and v.level <= level then
			data.add_wash_upper_limit_gongji = data.add_wash_upper_limit_gongji + v.add_wash_upper_limit_gongji
			data.add_wash_upper_limit_fangyu = data.add_wash_upper_limit_fangyu + v.add_wash_upper_limit_fangyu
			data.add_wash_upper_limit_maxhp = data.add_wash_upper_limit_maxhp + v.add_wash_upper_limit_maxhp
		end
	end
	return data
end

function FamousGeneralData:GetNextStarSoulInfoByIndexAndLevel(index, level, attr_type)
	local cur_cfg = self:GetStarSoulInfoByIndexAndLevel(index, level)
	local xinghuncfg = self:GetXingHunCfg()
	local cfg = xinghuncfg[index - 1]
	for i,v in ipairs(cfg) do
		if v[attr_type] > cur_cfg[attr_type] then
			return v
			-- return v[attr_type] - cur_cfg[attr_type]
		end
	end
	return {}
end

function FamousGeneralData:GetStarSoulMaxLevel(index)
	local xinghuncfg = self:GetXingHunCfg()
	local cfg = xinghuncfg[index - 1]
	return cfg and #cfg or 0
end

function FamousGeneralData:GetStarSoulCanUp(index)
	if self:CheckGeneralIsActive(index - 1) then
		local befor_level = self:GetStarSoulMaxLevelByIndex(index - 1)
		local cfg = self:GetStarSoulInfoByIndexAndLevel(index, 0)
		if befor_level and cfg then
			if befor_level >= cfg.backwards_highest_level then
				return true
			end
		end
	end
	return false
end

function FamousGeneralData:GetStarSoulTotal()
	local extra_cfg = self:GetXingHunExtraCfg()
	local total_level = 0
	for k,v in pairs(self.xingzuo_all_info.xinghun_level_list) do
		total_level = total_level + v
	end
	local cur_cfg, next_cfg = nil, nil
	if total_level < extra_cfg[1].level then
		next_cfg = extra_cfg[1]
	elseif total_level >= extra_cfg[#extra_cfg].level then
		cur_cfg = extra_cfg[#extra_cfg]
	else
		for k,v in pairs(extra_cfg) do
			if v.level > total_level then
				cur_cfg = extra_cfg[k - 1]
				next_cfg = v
				break
			end
		end
	end
	return cur_cfg, next_cfg, total_level
end

function FamousGeneralData:CheckGeneralBoneUprise()
	local cur_select_index = self:GetSelectIndex()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(self.general_info_list) do
		local cur_level = self:GetStarSoulLevelByIndex(v.seq + 1)
		if v.level > 0 and cur_level < 50 then -- 根骨最高等级
			local cur_cfg = self:GetStarSoulInfoByIndexAndLevel(v.seq + 1, cur_level)
			local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)

			--local is_reach = ItemData.Instance:GetItemNumIsEnough(item_num, cur_cfg.consume_stuff_num)
			if item_num > 0 and main_role_vo.level >= cur_cfg.open_level then
				return true
			end
		end
	end
	return false
end

function FamousGeneralData:GetExperienceCfg(bs_type, param)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local great_soldier_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto") or {}
	for k, v in pairs(great_soldier_cfg.experience) do
		if bs_type == v.bs_type and param == v["param" .. vo.camp] then
			return v
		end
	end

	return {}
end

function FamousGeneralData:GetHasGeneralSkill()
	local skill_list = SkillData.Instance:GetSkillList()
	for k, v in pairs(skill_list) do
		if v.skill_id == 600 or v.skill_id == 601 or v.skill_id == 602 then
			return true
		end
	end

	return false
end