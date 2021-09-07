DressUpData = DressUpData or BaseClass()

DressUpViewState = {
	HEADWEAR = 1,
	MASK = 2,
	WAIST = 3,
	BEAD = 4,	
	FABAO = 5,		
	KIRINARM = 6,

	MAX = 6,
}
function DressUpData:__init()
	if DressUpData.Instance ~= nil then
		return
	end
	DressUpData.Instance = self

	RemindManager.Instance:Register(RemindName.DressUp, BindTool.Bind(self.GetRedPointState, self))
	-- local skill_cfg = ConfigManager.Instance:GetAutoConfig("upgradeskill_auto")
	self.equip_skill_cfg = nil
	self.equip_skill_gauge_cfg = nil
	self.equip_skill_level = nil
end

function DressUpData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DressUp)
	DressUpData.Instance = nil
end

function DressUpData:GetAllSkillCfg()
	return ConfigManager.Instance:GetAutoConfig("upgradeskill_auto") or {}
end

function DressUpData:GetCanUplevel()
	return false
end

-- 坐骑装备
function DressUpData:GetMountCanUplevel(is_bind, is_bind_equip)
	local mount_equip_exp = {}
	local mount_exp_sum = 0
	local had_list ={}
	return had_list
end

function DressUpData:GetWingCanUplevel()
	local had_list ={}
	return had_list
end

function DressUpData:GetHaloCanUplevel()
	local had_list ={}
	return had_list
end

function DressUpData:GetEquipSkillCfg()
	local skill_cfg = self:GetAllSkillCfg()
	if nil == self.equip_skill_cfg then
		self.equip_skill_cfg = ListToMap(skill_cfg.skill_cfg, "skill_type", "skill_level")
	end
	return self.equip_skill_cfg
end

function DressUpData:GetEquipSkill(skill_type, skill_level)
	if nil == self:GetEquipSkillCfg()[skill_type] then
		return
	end
	return self:GetEquipSkillCfg()[skill_type][skill_level]
end

function DressUpData:GetShengongCanJinjie()
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

function DressUpData:GetShenyiCanJinjie()
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

-- 头饰标签红点
function DressUpData:IsShowHeadwearRedPoint()
	return HeadwearData.Instance:GetInAdvanceRedNum() > 0
end

--面饰标签红点
function DressUpData:IsShowMaskRedPoint()
	return MaskData.Instance:GetInAdvanceRedNum() > 0
end

--腰饰标签红点
function DressUpData:IsShowWaistRedPoint()
	return WaistData.Instance:GetInAdvanceRedNum() > 0
end

--灵珠标签红点
function DressUpData:IsShowBeadRedPoint()
	return BeadData.Instance:GetInAdvanceRedNum() > 0
end

--法宝标签红点
function DressUpData:IsShowFaBaoRedPoint()
	return FaBaoData.Instance:GetInAdvanceRedNum() > 0
end

--麒麟臂标签红点
function DressUpData:IsShowKirinArmRedPoint()
	return KirinArmData.Instance:GetInAdvanceRedNum() > 0
end

function DressUpData:GetRedPointState()
	return self:IsShowRedPoint() and 1 or 0
end

function DressUpData:IsShowRedPoint()
	if self:IsShowHeadwearRedPoint() or self:IsShowMaskRedPoint() or self:IsShowWaistRedPoint() or self:IsShowBeadRedPoint() 
		or self:IsShowFaBaoRedPoint() or self:IsShowKirinArmRedPoint() then
		return true
	end
	return false
end

function DressUpData:IsShowHuaShenRedPoint()
	if self:IsShowTopHuashenRedPoint() or self:IsShowHuashenHuanhuaRedPoint() or self:IsShowHuaShenProtectRedPoint() then
		return true
	end
	return false
end

function DressUpData:IsShowTopHuashenRedPoint()
	for i = 0, GameEnum.FABAO_MAX_ID - 1 do
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

function DressUpData:IsShowHuashenHuanhuaRedPoint()
	for i = 0, GameEnum.FABAO_MAX_ID - 1 do
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

function DressUpData:IsShowHuaShenProtectRedPoint()
	for i = 0, GameEnum.FABAO_MAX_ID - 1 do
		for j = 0, GameEnum.FABAO_SPIRIT_MAX_ID_LIMIT - 1 do
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

function DressUpData:GetDefaultOpenView()
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

function DressUpData:GetIsShowRed(view_type)
	if not view_type then return false end
	if view_type == DressUpViewState.HEADWEAR then
		return self:IsShowHeadwearRedPoint()

	elseif view_type == DressUpViewState.MASK then
		return self:IsShowMaskRedPoint()

	elseif view_type == DressUpViewState.WAIST then
		return self:IsShowWaistRedPoint()

	elseif view_type == DressUpViewState.BEAD then
		return self:IsShowBeadRedPoint()

	elseif view_type == DressUpViewState.FABAO then
		return self:IsShowFaBaoRedPoint()
		
	elseif view_type == DressUpViewState.KIRINARM then
		return self:IsShowKirinArmRedPoint()
	end
end

function DressUpData:GetMedalPlusNum(str)
	local medal_index = MedalData.Instance:GetMedalTotalDataIndex()
	local medal_data = MedalData.Instance:GetMedalSuitCfg()[medal_index]
	if medal_data and medal_data[str] then
		return medal_data[str]/100
	end
	return 0
end

function DressUpData:GetJinjieSkillTotalCount()
	local oount = 0
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
	return oount
end

function DressUpData:GetEquipSkillGaugeCfg()
	local  skill_cfg = self:GetAllSkillCfg()
	if nil == self.equip_skill_gauge_cfg then
		self.equip_skill_gauge_cfg = ListToMap(skill_cfg.gauge_cfg, "skill_count")
	end
	return self.equip_skill_gauge_cfg
end

function DressUpData:GetJinjieGaugeCount(skill_count)
	local skill_count = skill_count or self:GetJinjieSkillTotalCount()

	if nil == self:GetEquipSkillGaugeCfg()[skill_count] then
		return -1
	end
	return self:GetEquipSkillGaugeCfg()[skill_count].gauge
end

-- 形象-装备按钮的红点
function DressUpData:IsEquipRedPointShow(index)
	local flag = false
	for i = 0, 3 do
		local item_flag = 0
		if index == ADVANCE_EQUIP_TYPE.HEADWEAR then
			item_flag = HeadwearData.Instance:CalEquipRemind(i)			
		elseif index == ADVANCE_EQUIP_TYPE.MASK then
			item_flag = MaskData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.WAIST then
			item_flag = WaistData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.BEAD then
			item_flag = BeadData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.FABAO then
			item_flag = FaBaoData.Instance:CalEquipRemind(i)
		elseif index == ADVANCE_EQUIP_TYPE.KIRINARM then
			item_flag = KirinArmData.Instance:CalEquipRemind(i)
		end
		if item_flag > 0 then
			flag = true
			break
		end
	end	
	return flag
end

function DressUpData:IsOpenEquip(tab_index)
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
		return BeautyWaistData.Instance:IsOpenEquip()
	end
	if tab_index == TabIndex.fabao then
		return BeadData.Instance:IsOpenEquip()
	end
	if tab_index == TabIndex.kirin_arm then
		return HalidomData.Instance:IsOpenEquip()
	end
	return false, 0
end

function DressUpData:GetEquiplevelCfg()
	if nil == self.equip_skill_level then
		self.equip_skill_level = ListToMap(ConfigManager.Instance:GetAutoConfig("mount_auto").equip_skill_level,"equip_skill_level")
	end
	return self.equip_skill_level
end

function DressUpData:GetEquiplevel(index)
	if self:GetEquiplevelCfg()[index] then
		return self:GetEquiplevelCfg()[index].equip_min_level
	end 
	return 0
end