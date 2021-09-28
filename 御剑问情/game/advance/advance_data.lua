AdvanceData = AdvanceData or BaseClass()
AdvanceData.RemindFlag = {}
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
		SKILL_TYPE_HALO = 6,
		SKILL_TYPE_SHENGONG = 3,
		SKILL_TYPE_SHENYI = 4,
		SKILL_TYPE_FIGHT_MOUNT = 5,
		SKILL_TYPE_FOOT_PRINT = 2,
		SKILL_TYPE_MAX = 7,
}

local JINJIE_SKILL_ICON_ASSET = {
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_MOUNT] = "mount_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_WING] = "wing_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_HALO] = "foot_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENGONG] = "shengong_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENYI] = "shenyi_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FIGHT_MOUNT] = "fight_mount_skill_icon",
	[JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FOOT_PRINT] = "halo_skill_icon",
}

function AdvanceData:__init()
	if AdvanceData.Instance ~= nil then
		return
	end
	AdvanceData.Instance = self

	RemindManager.Instance:Register(RemindName.Advance, BindTool.Bind(self.GetRedPointState, self))

	local skill_cfg = ConfigManager.Instance:GetAutoConfig("upgradeskill_auto")
	self.equip_skill_cfg = ListToMap(skill_cfg.skill_cfg, "skill_type", "skill_level")
	self.equip_skill_gauge_cfg = ListToMap(skill_cfg.gauge_cfg, "skill_count")

end

function AdvanceData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Advance)
	AdvanceData.Instance = nil
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

function AdvanceData:GetShengongCanJinjie()
	local shengong_data = ShengongData.Instance
	local shengong_info = shengong_data:GetShengongInfo()
	if shengong_info.grade == nil or shengong_info.grade >= shengong_data:GetMaxGrade() or shengong_info.grade <= 0 then
		return false
	end

	local shengong_grade_cfg = shengong_data:GetShengongGradeCfg()
	if nil == shengong_grade_cfg or shengong_grade_cfg.is_clear_bless == 1 then
		return false
	end

	local num = ItemData.Instance:GetItemNumInBagById(shengong_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(shengong_grade_cfg.upgrade_stuff2_id)
	return num >= shengong_grade_cfg.upgrade_stuff_count
end

function AdvanceData:GetShenyiCanJinjie()
	local shenyi_data = ShenyiData.Instance
	local shenyi_info = shenyi_data:GetShenyiInfo()
	if shenyi_info.grade == nil or shenyi_info.grade >= shenyi_data:GetMaxGrade() or shenyi_info.grade <= 0 then
		return false
	end

	local shenyi_grade_cfg = shenyi_data:GetShenyiGradeCfg()
	if nil == shenyi_grade_cfg or shenyi_grade_cfg.is_clear_bless == 1 then
		return false
	end

	local num = ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff2_id)
	return num >= shenyi_grade_cfg.upgrade_stuff_count
end

function AdvanceData:IsShowMountRedPoint()
	local mount_data = MountData.Instance

	if OpenFunData.Instance:CheckIsHide("mount_jinjie") and (mount_data:IsCanHuanhuaUpgrade() ~= false
		or mount_data:IsShowZizhiRedPoint() or next(mount_data:CanSkillUpLevelList()) ~= nil
		or (mount_data:CanJinjie() and AdvanceData.GetViewOpenFlag(TabIndex.mount_jinjie)))
		or mount_data:CalAllEquipRemind() > 0 then
		return true
	end

	local red_vis = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.mount_jinjie)
	if red_vis then
		return true
	end

	--进阶奖励
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_MOUNT)
	if is_can_active_jinjie_reward then
		return true
	end

	return false
end

function AdvanceData:IsShowWingRedPoint()
	local wing_data = WingData.Instance

	if OpenFunData.Instance:CheckIsHide("wing_jinjie") and (wing_data:IsCanHuanhuaUpgrade() ~= false
		or wing_data:IsShowZizhiRedPoint() or next(wing_data:CanSkillUpLevelList()) ~= nil
		or (wing_data:CanJinjie() and AdvanceData.GetViewOpenFlag(TabIndex.wing_jinjie)))
		or wing_data:CalAllEquipRemind() > 0 then
		return true
	end

	local red_vis = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.wing_jinjie)
	if red_vis then
		return true
	end

	--进阶奖励
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_WING)
	if is_can_active_jinjie_reward then
		return true
	end

	return false
end

function AdvanceData:IsShowHaloRedPoint()
	local halo_data = HaloData.Instance

	if OpenFunData.Instance:CheckIsHide("halo_jinjie") and (halo_data:IsCanHuanhuaUpgrade() ~= false
		or halo_data:IsShowZizhiRedPoint() or next(halo_data:CanSkillUpLevelList()) ~= nil
		or (halo_data:CanJinjie() and AdvanceData.GetViewOpenFlag(TabIndex.halo_jinjie)))
		or halo_data:CalAllEquipRemind() > 0 then
		return true
	end

	local red_vis = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.halo_jinjie)
	if red_vis then
		return true
	end
	
	--进阶奖励
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_HALO)
	if is_can_active_jinjie_reward then
		return true
	end

	return false
end

function AdvanceData:IsShowFootRedPoint()
	local foot_data = FootData.Instance

	if OpenFunData.Instance:CheckIsHide("foot_jinjie") and (foot_data:CanHuanhuaUpgrade() ~= nil
		or foot_data:IsShowZizhiRedPoint() or next(foot_data:CanSkillUpLevelList()) ~= nil
		or (foot_data:CanJinjie() and AdvanceData.GetViewOpenFlag(TabIndex.foot_jinjie)))
		or foot_data:CalAllEquipRemind() > 0 then
		return true
	end

	local red_vis = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.foot_jinjie)
	if red_vis then
		return true
	end

	--进阶奖励
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT)
	if is_can_active_jinjie_reward then
		return true
	end

	return false
end

function AdvanceData:IsShowLingChongRed()
	if not OpenFunData.Instance:CheckIsHide("lingchong_jinjie") then
		return false
	end

	if AdvanceData.GetViewOpenFlag(TabIndex.lingchong_jinjie) and LingChongData.Instance:IsShowRedPoint() then
		return true
	end

	return false
end

function AdvanceData:IsShowShengongRedPoint()
	local shengong_data = ShengongData.Instance
	if shengong_data:IsCanHuanhuaUpgrade() ~= false or shengong_data:IsShowZizhiRedPoint()
		or next(shengong_data:CanSkillUpLevelList()) ~= nil or (self:GetShengongCanJinjie() and AdvanceData.GetViewOpenFlag(TabIndex.goddess_shengong))
		or shengong_data:CalAllEquipRemind() > 0 then
		return true
	end

	local red_vis = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.goddess_shengong)
	if red_vis then
		return true
	end
	
	--进阶奖励
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_SHENGONG)
	if is_can_active_jinjie_reward then
		return true
	end
	
	return false
end

function AdvanceData:IsShowShenyiRedPoint()
	local shenyi_data = ShenyiData.Instance
	if shenyi_data:IsCanHuanhuaUpgrade() ~= false or shenyi_data:IsShowZizhiRedPoint()
		or next(shenyi_data:CanSkillUpLevelList()) ~= nil or (self:GetShenyiCanJinjie() and AdvanceData.GetViewOpenFlag(TabIndex.goddess_shenyi))
		or shenyi_data:CalAllEquipRemind() > 0 then
		return true
	end

	local red_vis = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.goddess_shenyi)
	if red_vis then
		return true
	end
	
	--进阶奖励
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_SHENYI)
	if is_can_active_jinjie_reward then
		return true
	end
	
	return false
end

function AdvanceData:IsShowShenbingRedPoint()
	if ShenBingData.Instance:GetRemind() == 1 then
		return true
	end
	return false
end

function AdvanceData:GetRedPointState()
	return self:IsShowRedPoint() and 1 or 0
end

function AdvanceData:IsShowRedPoint()
	if self:IsShowMountRedPoint() or self:IsShowWingRedPoint() or self:IsShowHaloRedPoint() or self:IsShowFightMountRedPoint()
		or self:GetCanUplevel() or self:IsShowShenbingRedPoint() or self:IsShowFootRedPoint() or self:IsShowCloakRedPoint()
		or self:IsShowLingChongRed() then--or self:IsShowHuaShenRedPoint()
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

function AdvanceData:IsShowFightMountRedPoint()
	local fight_mount_data = FightMountData.Instance
	if OpenFunData.Instance:CheckIsHide("fight_mount") and (fight_mount_data:IsCanHuanhuaUpgrade() ~= false
		or fight_mount_data:IsShowZizhiRedPoint()
		or (fight_mount_data:CanJinjie() and AdvanceData.GetViewOpenFlag(TabIndex.fight_mount)))
		or fight_mount_data:CalAllEquipRemind() > 0 then
		return true
	end

	local red_vis = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.fight_mount)
	if red_vis then
		return true
	end
	
	--进阶奖励
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT)
	if is_can_active_jinjie_reward then
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

function AdvanceData:GetEquipSkill(skill_type, skill_level)
	if nil == self.equip_skill_cfg[skill_type] then
		return
	end
	return self.equip_skill_cfg[skill_type][skill_level]
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

	if tab_index == TabIndex.fight_mount then
		return FightMountData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.goddess_shengong then
		return ShengongData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.goddess_shenyi then
		return ShenyiData.Instance:IsOpenEquip()
	end

	if tab_index == TabIndex.foot_jinjie then
		return FootData.Instance:IsOpenEquip()
	end

	return false, 0
end

function AdvanceData:IsShowCloakRedPoint()
	if not OpenFunData.Instance:CheckIsHide("cloak_jinjie") then
		return false
	end
	if CloakData.Instance:GetRemind() == 1 then
		return true
	end
	return false
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

	if FightMountData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if ShengongData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end

	if ShenyiData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end
	if FootData.Instance:IsActiveEquipSkill() then
		oount = oount + 1
	end
	return oount
end

function AdvanceData:GetJinjieGaugeCount(skill_count)
	skill_count = skill_count or self:GetJinjieSkillTotalCount()

	if nil == self.equip_skill_gauge_cfg[skill_count] then
		return -1
	end
	return self.equip_skill_gauge_cfg[skill_count].gauge
end

function AdvanceData:GetEquipSkillResPath(skill_type)
	local asset = JINJIE_SKILL_ICON_ASSET[skill_type]
	return ResPath.GetAdvanceEquipIconByMain(asset)
end

function AdvanceData:CalFulingRemind(type)
	local temp_list = ImageFuLingCtrl.Instance:GetCanConsumeStuffData(type)
	if #temp_list > 0 then
		return true
	else
		return false
	end
end

function AdvanceData.GetViewOpenFlag(view_index)
	return not AdvanceData.RemindFlag[view_index] or AdvanceData.RemindFlag[view_index] < Status.NowTime
end

function AdvanceData:SetViewOpenFlag(view_name, view_index)
	if view_name == ViewName.Advance then
		if view_index == TabIndex.mount_jinjie then
			if MountData.Instance:CanJinjie() then
				AdvanceData.RemindFlag[view_index] = Status.NowTime + 7200
			end
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif view_index == TabIndex.wing_jinjie then
			if WingData.Instance:CanJinjie() then
				AdvanceData.RemindFlag[view_index] = Status.NowTime + 7200
			end
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif view_index == TabIndex.halo_jinjie then
			if HaloData.Instance:CanJinjie() then
				AdvanceData.RemindFlag[view_index] = Status.NowTime + 7200
			end
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif view_index == TabIndex.fight_mount then
			if FightMountData.Instance:CanJinjie() then
				AdvanceData.RemindFlag[view_index] = Status.NowTime + 7200
			end
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif view_index == TabIndex.foot_jinjie then
			if FootData.Instance:CanJinjie() then
				AdvanceData.RemindFlag[view_index] = Status.NowTime + 7200
			end
			RemindManager.Instance:Fire(RemindName.Advance)
		elseif view_index == TabIndex.lingchong_jinjie then
			if LingChongData.Instance:CalcUpgradeRemind() > 0 then
				AdvanceData.RemindFlag[view_index] = Status.NowTime + 7200
			end
			RemindManager.Instance:Fire(RemindName.Advance)
		end
	elseif view_name == ViewName.Goddess then
		if view_index == TabIndex.goddess_shengong then
			if self:GetShengongCanJinjie() then
				AdvanceData.RemindFlag[view_index] = Status.NowTime + 7200
			end
			RemindManager.Instance:Fire(RemindName.Goddess_Shengong)
		elseif view_index == TabIndex.goddess_shenyi then
			if self:GetShenyiCanJinjie() then
				AdvanceData.RemindFlag[view_index] = Status.NowTime + 7200
			end
			RemindManager.Instance:Fire(RemindName.Goddess_Shenyi)
		end
	end
end