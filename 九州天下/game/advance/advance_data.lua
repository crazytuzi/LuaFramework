AdvanceData = AdvanceData or BaseClass()

AdvanceDataIndex = {
	"mount", "wing", "halo", "shengong", "shenyi"
}

MountEquipExpItemId = {
	{26370, 26380, 26390}, {26340, 26350, 26360}
}
WingEquipExpItemId = {
	{26371, 26381, 26391}, {26341, 26351, 26361}
}
HaloEquipExpItemId = {
	{26372, 26382, 26392}, {26342, 26352, 26362}
}
ShengongEquipExpItemId = {
	{26373, 26383, 26393}, {26343, 26353, 26363}
}
ShenyiEquipExpItemId = {
	{26374, 26384, 26394}, {26344, 26354, 26364}
}

JINJIE_EQUIP_SKILL_TYPE = {
		SKILL_TYPE_MOUNT = 0,
		SKILL_TYPE_WING = 1,
		SKILL_TYPE_HALO = 2,
		SKILL_TYPE_SHENGONG = 3,
		SKILL_TYPE_SHENYI = 4,
		SKILL_TYPE_FIGHT_MOUNT = 5,
		SKILL_TYPE_FOOT_PRINT = 6,
		SKILL_TYPE_PIFENG_PRINT = 7,
		SKILL_TYPE_HEADWEAR = 8,
		SKILL_TYPE_MASK = 9,
		SKILL_TYPE_WAIST = 10,
		SKILL_TYPE_BEAD = 11,
		SKILL_TYPE_FABAO = 12,
		SKILL_TYPE_KIRINARM = 13,
		SKILL_TYPE_MAX = 14,
}

local JINJIE_SKILL_ICON_ASSET = {
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_MOUNT] = "mount_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_WING] = "wing_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_HALO] = "halo_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENGONG] = "shengong_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENYI] = "shenyi_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FIGHT_MOUNT] = "fight_mount_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FOOT_PRINT] = "foot_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_PIFENG_PRINT] = "foot_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_HEADWEAR] = "headwear_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_MASK] = "mask_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_WAIST] = "waist_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_BEAD] = "bead_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FABAO] = "fabao_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_KIRINARM] = "kirin_arm_skill_icon",
}

ViewState = {
	MOUNT = 1,
	WING = 2,
	HALO = 3,
	FIGHT_MOUNT = 4,		-- 法印
	HUASHEN = 5,			-- 美人光环
	HALIDOM = 6,
	FOOTMARK = 7,
	MANTLE = 8,
	MULTI_MOUNT = 9,

	MAX = 10,
}
function AdvanceData:__init()
	if AdvanceData.Instance ~= nil then
		return
	end
	AdvanceData.Instance = self

	RemindManager.Instance:Register(RemindName.Advance, BindTool.Bind(self.GetRedPointState, self))
	-- local skill_cfg = ConfigManager.Instance:GetAutoConfig("upgradeskill_auto")
	self.equip_skill_cfg = nil
	self.equip_skill_gauge_cfg = nil
	self.equip_skill_level = nil
end

function AdvanceData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Advance)
	AdvanceData.Instance = nil
end

function AdvanceData:GetAllSkillCfg()
	return ConfigManager.Instance:GetAutoConfig("upgradeskill_auto") or {}
end

function AdvanceData:GetCanUplevel()
	return false
end

-- 坐骑装备
function AdvanceData:GetMountCanUplevel(is_bind, is_bind_equip)
	local mount_equip_exp = {}
	local mount_exp_sum = 0
	local had_list ={}
	return had_list
end

function AdvanceData:GetWingCanUplevel()
	local had_list ={}
	return had_list
end

function AdvanceData:GetHaloCanUplevel()
	local had_list ={}
	return had_list
end

function AdvanceData:GetEquipSkillCfg()
	local skill_cfg = self:GetAllSkillCfg()
	if nil == self.equip_skill_cfg then
		self.equip_skill_cfg = ListToMap(skill_cfg.skill_cfg, "skill_type", "skill_level")
	end
	return self.equip_skill_cfg
end

function AdvanceData:GetEquipSkill(skill_type, skill_level)
	if nil == self:GetEquipSkillCfg()[skill_type] then
		return
	end
	return self:GetEquipSkillCfg()[skill_type][skill_level]
end

function AdvanceData:GetShengongCanJinjie()
	local up_star_cfg = ShengongData.Instance:GetShengongUpStarPropCfg()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local star_level_cfg = ShengongData.Instance:GetShengongUpStarCfgByLevel(shengong_info.star_level)
	local grade_bless_val = shengong_info.grade_bless_val
	local max_grade = ShengongData.Instance:GetMaxGrade()
	if not grade_bless_val or not star_level_cfg or not shengong_info or not up_star_cfg then
		return
	end
	if shengong_info.grade >= max_grade then
		 return false
	end

	local sum_exp = 0
	for k, v in ipairs(up_star_cfg) do
		local num = ItemData.Instance:GetItemNumInBagById(v.up_star_item_id)
		-- sum_exp = num * v.star_exp + sum_exp
		if num > 0 then
			return true
		end
	end
	-- if sum_exp - (star_level_cfg.up_star_level_exp - grade_bless_val) > 0  then
	-- 	return true
	-- end
	return false
end

function AdvanceData:GetShenyiCanJinjie()
	local up_star_cfg = ShenyiData.Instance:GetShenyiUpStarPropCfg()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local star_level_cfg = ShenyiData.Instance:GetShenyiUpStarCfgByLevel(shenyi_info.star_level)
	local grade_bless_val = shenyi_info.grade_bless_val
	local max_grade = ShenyiData.Instance:GetMaxGrade()
	if not grade_bless_val or not star_level_cfg or not shenyi_info or not up_star_cfg then
		return
	end
	if shenyi_info.grade >= max_grade then
		return false
	end

	local sum_exp = 0
	for k, v in ipairs(up_star_cfg) do
		local num = ItemData.Instance:GetItemNumInBagById(v.up_star_item_id)
		-- sum_exp = num * v.star_exp + sum_exp
		if num > 0 then
			return true
		end
	end
	-- if sum_exp - (star_level_cfg.up_star_level_exp - grade_bless_val) > 0  then
	-- 	return true
	-- end
	return false
end

-- 坐骑标签红点
function AdvanceData:IsShowMountRedPoint()
	return MountData.Instance:GetInAdvanceRedNum() > 0
end

--羽翼标签红点
function AdvanceData:IsShowWingRedPoint()
	return WingData.Instance:GetInAdvanceRedNum() > 0
end

--天罡标签红点
function AdvanceData:IsShowHaloRedPoint()
	return HaloData.Instance:GetInAdvanceRedNum() > 0
end

--法印标签红点
function AdvanceData:IsShowFightMountRedPoint()
	return FaZhenData.Instance:GetInAdvanceRedNum() > 0
end

--芳华标签红点
function AdvanceData:IsShowBeautyHaloRedPoint()
	return BeautyHaloData.Instance:GetInAdvanceRedNum() > 0
end

--圣物标签红点
function AdvanceData:IsShowHalidomRedPoint()
	return HalidomData.Instance:GetInAdvanceRedNum() > 0
end

--足迹标签红点
function AdvanceData:IsShowFootRedPoint()
	return ShengongData.Instance:GetInAdvanceRedNum() > 0
end

--披风标签红点
function AdvanceData:IsShowMantleRedPoint()
	return ShenyiData.Instance:GetInAdvanceRedNum() > 0
end

function AdvanceData:GetRedPointState()
	return self:IsShowRedPoint() and 1 or 0
end

function AdvanceData:IsShowRedPoint()
	if self:IsShowMountRedPoint() or self:IsShowWingRedPoint() or self:IsShowHaloRedPoint() or self:IsShowFightMountRedPoint() or self:IsShowBeautyHaloRedPoint()
		or self:IsShowHalidomRedPoint() or self:IsShowFootRedPoint() or self:IsShowMantleRedPoint() or self:IsShowMultiMountRedPoint() then
		return true
	end
	return false
end

function AdvanceData:IsShowHuaShenRedPoint()
	if self:IsShowTopHuashenRedPoint() or self:IsShowHuashenHuanhuaRedPoint() or self:IsShowHuaShenProtectRedPoint() then
		return true
	end
	return false
end

function AdvanceData:IsShowTopHuashenRedPoint()
	for i = 0, GameEnum.HUASHEN_MAX_ID - 1 do
		local level_info_list = HuashenData.Instance:GetHuashenInfo().level_info_list
		if not level_info_list then return end

		local level = level_info_list[i] and level_info_list[i].level or 0
		level = (level ~= 0) and level or 1
		local level_cfg = HuashenData.Instance:GetHuashenLevelCfg(i, level)
		if level_cfg and level_cfg.stuff_id then
			if ItemData.Instance:GetItemNumInBagById(level_cfg.stuff_id) > 0 then
				return true
			end
		end
	end
	return false
end

function AdvanceData:IsShowHuashenHuanhuaRedPoint()
	for i = 0, GameEnum.HUASHEN_MAX_ID - 1 do
		local huashen_info = HuashenData.Instance:GetHuashenInfo()
		local grade_list = huashen_info.grade_list
		local activie_flag = huashen_info.activie_flag
		if not grade_list or not activie_flag then return end

		local level = grade_list[i] and grade_list[i] or 0
		level = (level ~= 0) and level or 1
		local image_cfg = HuashenData.Instance:GetHuashenImageCfg(i, level)
		if image_cfg and image_cfg.stuff_id then
			local image_info = HuashenData.Instance:GetHuashenInfoCfg()[i]
			local data = (1 == activie_flag[i]) and image_cfg or image_info
			local item_id = (1 == activie_flag[i]) and image_cfg.stuff_id or image_info.item_id
			local need_num = (1 == activie_flag[i]) and image_cfg.stuff_num or 1
			if ItemData.Instance:GetItemNumInBagById(item_id) >= need_num then
				return true
			end
		end
	end
	return false
end

function AdvanceData:IsShowHuaShenProtectRedPoint()
	for i = 0, GameEnum.HUASHEN_MAX_ID - 1 do
		for j = 0, GameEnum.HUASHEN_SPIRIT_MAX_ID_LIMIT - 1 do
			local protect_cfg = HuashenData.Instance:GetHuashenProtectLevelCfg(i, j)
			if protect_cfg and protect_cfg.consume_item_id then
				if ItemData.Instance:GetItemNumInBagById(protect_cfg.consume_item_id) > 0 then
					return true
				end
			end
		end
	end
	return false
end

function AdvanceData:GetDefaultOpenView()
	local default_open = ""
	local open_data = OpenFunData.Instance
	local list = {"mount_jinjie", "wing_jinjie", "halo_jinjie", "fight_mount"}
	for k,v in pairs(list) do
		if open_data:CheckIsHide(v) then
			default_open = v
			return default_open
		end
	end
	return default_open
end

function AdvanceData:GetIsShowRed(view_type)
	if not view_type then return false end
	if view_type == ViewState.MOUNT then
		return self:IsShowMountRedPoint()

	elseif view_type == ViewState.WING then
		return self:IsShowWingRedPoint()

	elseif view_type == ViewState.HALO then
		return self:IsShowHaloRedPoint()

	elseif view_type == ViewState.FIGHT_MOUNT then
		return self:IsShowFightMountRedPoint()

	elseif view_type == ViewState.HUASHEN then
		return false
		
	elseif view_type == ViewState.HALIDOM then
		return false
		
	elseif view_type == ViewState.FOOTMARK then
		return false
		
	elseif view_type == ViewState.MANTLE then
		return false
		
	end
end

function AdvanceData:GetMedalPlusNum(str)
	local medal_index = MedalData.Instance:GetMedalTotalDataIndex()
	local medal_data = MedalData.Instance:GetMedalSuitCfg()[medal_index]
	if medal_data and medal_data[str] then
		return medal_data[str]/100
	end
	return 0
end

function AdvanceData:GetJinjieSkillTotalCount()
	local oount = 0
	if MountData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if WingData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if HaloData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if FaZhenData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if ShengongData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if ShenyiData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if HalidomData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if BeautyHaloData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if HeadwearData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if MaskData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if WaistData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if BeadData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if FaBaoData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if KirinArmData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end
	
	-- if FootData.Instance:IsActiveEquipSkill() then
	-- 	oount = oount + 1
	-- end
	return oount
end

function AdvanceData:GetEquipSkillGaugeCfg()
	local  skill_cfg = self:GetAllSkillCfg()
	if nil == self.equip_skill_gauge_cfg then
		self.equip_skill_gauge_cfg = ListToMap(skill_cfg.gauge_cfg, "skill_count")
	end
	return self.equip_skill_gauge_cfg
end

function AdvanceData:GetJinjieGaugeCount(skill_count)
	local skill_count = skill_count or self:GetJinjieSkillTotalCount()

	if nil == self:GetEquipSkillGaugeCfg()[skill_count] then
		return -1
	end
	return self:GetEquipSkillGaugeCfg()[skill_count].gauge
end

-- 形象-装备按钮的红点
function AdvanceData:IsEquipRedPointShow(index)
	local flag = false
	for i = 0, 3 do
		local item_flag = 0
		if index == ADVANCE_EQUIP_TYPE.MOUNT then
			item_flag = MountData.Instance:CalEquipRemind(i)			
		elseif index == ADVANCE_EQUIP_TYPE.WING then
			item_flag = WingData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.HALO then
			item_flag = HaloData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.FAZHEN then
			item_flag = FaZhenData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.BEAUTY_HALO then
			item_flag = BeautyHaloData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.HALIDOM then
			item_flag = HalidomData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.FOOT then
			item_flag = ShengongData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.MANTLE then
			item_flag = ShenyiData.Instance:CalEquipRemind(i)
		end
		if item_flag > 0 then
			flag = true
			break
		end
	end	
	return flag
end

function AdvanceData:IsOpenEquip(tab_index)
	if tab_index == TabIndex.mount_jinjie then
		return MountData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.wing_jinjie then
		return WingData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.halo_jinjie then
		return HaloData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.meiren_guanghuan then
		return BeautyHaloData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.fight_mount then
		return FaZhenData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.halidom_jinjie then
		return HalidomData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.shengong_jinjie then
		return ShengongData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.shenyi_jinjie then
		return ShenyiData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.headwear then
		return HeadwearData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.mask then
		return MaskData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.waist then
		return WaistData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.bead then
		return BeadData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.fabao then
		return FaBaoData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.kirin_arm then
		return KirinArmData.Instance:IsOpenEquip()
	end

	return false, 0
end

function AdvanceData:GetEquiplevelCfg()
	if nil == self.equip_skill_level then
		self.equip_skill_level = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").equip_skill_level,"equip_skill_level")
	end
	return self.equip_skill_level
end

function AdvanceData:GetEquiplevel(index)
	if self:GetEquiplevelCfg()[index] then
		return self:GetEquiplevelCfg()[index].equip_min_level
	end 
	return 0
end

function AdvanceData:GetSpecialImageIsActive(display_type, image_id)
	local is_grade = false
	if display_type == 2 then
		if MountData.Instance:GetMountIsActive(image_id) then
			MountHuanHuaCtrl.Instance:MountSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 3 then
		if WingData.Instance:GetWingIsActive(image_id) then
			WingHuanHuaCtrl.Instance:WingSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 5 then
		if HaloData.Instance:GetHoloIsActive(image_id) then
			HaloHuanHuaCtrl.Instance:HaloSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 7 then
		if FaZhenData.Instance:GetFaZhenIsActive(image_id) then
			FaZhenCtrl.Instance:SendFaZhenOpera(FAZHEN_OPERA_REQ_TYPE.FAZHEN_OPERA_REQ_TYPE_UPGRADE_IMG, image_id)
			is_grade = true
		end
	elseif display_type == 8 then
		if ShengongData.Instance:GetShengongIsActive(image_id) then
			ShengongHuanHuaCtrl.Instance:ShengongSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 9 then
		if ShenyiData.Instance:GetShenyiIsActive(image_id) then
			ShenyiHuanHuaCtrl.Instance:ShenyiSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 10 then
		if BeautyHaloData.Instance:GetBeautyHaloIsActive(image_id) then
			BeautyHaloHuanHuaCtrl.Instance:MountSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 11 then
		if HalidomData.Instance:GetHalidomIsActive(image_id) then
			HalidomHuanHuaCtrl.Instance:SendSpiritFazhenSpecialImgUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 38 then
		if HeadwearData.Instance:GetHeadwearIsActive(image_id) then
			HeadwearHuanHuaCtrl.Instance:HeadwearSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 39 then
		if MaskData.Instance:GetMaskIsActive(image_id) then
			MaskHuanHuaCtrl.Instance:MaskSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 40 then
		if WaistData.Instance:GetWaistIsActive(image_id) then
			WaistHuanHuaCtrl.Instance:WaistSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 41 then
		if BeadData.Instance:GetBeadIsActive(image_id) then
			BeadHuanHuaCtrl.Instance:BeadSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 42 then
		if FaBaoData.Instance:GetFaBaoIsActive(image_id) then
			FaBaoHuanHuaCtrl.Instance:FaBaoSpecialImaUpgrade(image_id)
			is_grade = true
		end
	elseif display_type == 43 then
		if KirinArmData.Instance:GetKirinArmIsActive(image_id) then
			KirinArmHuanHuaCtrl.Instance:KirinArmSpecialImaUpgrade(image_id)
			is_grade = true
		end
	end
	if is_grade then
		SysMsgCtrl.Instance:ErrorRemind(Language.Advance.SuccessGrade)
	end
	return is_grade
end

function AdvanceData:IsShowMultiMountRedPoint()
	return MultiMountData.Instance:GetMultiMountRed() > 0
end