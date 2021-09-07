MagicWeaponData = MagicWeaponData or BaseClass()
function MagicWeaponData:__init()
	if MagicWeaponData.Instance ~= nil then
		print_error("[MagicWeaponData] Attemp to create a singleton twice !")
	end
	MagicWeaponData.Instance = self
	self.MagicWeaponInfo = {}
	self.max_weapon_level = GameEnum.EQUIP_MAX_LEVEL
	self.weapons_type = {
		WEAPONS = 0,
		GARBAGE = 1,
		NONAME = 2,
	}
	local cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto")
	self.other_cfg = cfg.other[1]
	self.attr_cfg = cfg.slot_attr
	self.weapon_cfg = cfg.weapons
	self.identify_exp_cfg = cfg.identify_exp
	self.identify_level_cfg = cfg.identify_level
	self.melt_level_cfg = cfg.melt_level
	self.last_identify_level = 99999
	RemindManager.Instance:Register(RemindName.MagicWeapon, BindTool.Bind(self.GetMagicWeaponRemind, self))
end

function MagicWeaponData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MagicWeapon)
	MagicWeaponData.Instance = nil
	UnityEngine.PlayerPrefs.DeleteKey("exchange_exp")
end

function MagicWeaponData:GetGatherSceneId()
	return self.other_cfg.gather_scene_id
end

function MagicWeaponData:OnIdentifyResult(protocol)
	self.weapon_id = protocol.weapon_id
end

function MagicWeaponData:OnMagicWeaponInfo(protocol)
	self.MagicWeaponInfo.melt_level 						= protocol.melt_level or 0			--熔炼等级
	self.MagicWeaponInfo.identify_level 					= protocol.identify_level or 0		--鉴定等级
	self.MagicWeaponInfo.identify_star_level 				= protocol.identify_star_level or 0	--鉴定星级
	self.MagicWeaponInfo.melt_exp 							= protocol.melt_exp or 0			--熔炼经验
	self.MagicWeaponInfo.identify_exp 						= protocol.identify_exp or 0		--鉴定经验
	self.MagicWeaponInfo.all_weapon_level_list 				= protocol.all_weapon_level_list or {}--神州六器等级
	self.MagicWeaponInfo.back_pack_list 					= protocol.back_pack_list or {}		--背包物品列表
	self.MagicWeaponInfo.today_gather_times 				= protocol.today_gather_times or 0	--今日采集总数
	self.MagicWeaponInfo.today_exchange_identify_exp_times 	= protocol.today_exchange_identify_exp_times or 0--今日兑换鉴定经验次数

	if self.last_identify_level == 99999 then
		self.last_identify_level = self.identify_level
	end
end

----------获取数据--------
function MagicWeaponData:GetMagicWeaponCellData(index)
	local all_magic_weapon_list = {} -- 无用代码。。。
	if #all_magic_weapon_list >= index then
		local weapons_cfg = self:GetItemConfig(all_magic_weapon_list[index].item_id)
		all_magic_weapon_list[index].id = weapons_cfg.id
		all_magic_weapon_list[index].slot = weapons_cfg.slot
		all_magic_weapon_list[index].bag_index = index
		all_magic_weapon_list[index].exchange_exp = weapons_cfg.exchange_exp
		all_magic_weapon_list[index].type = weapons_cfg.type

		return all_magic_weapon_list[index]
	else
		return {}
	end
end

--有魔器相关装备时显示主界面按钮红点
function MagicWeaponData:GetMagicWeaponRemind()
	return self:GetRedPointStatus() and 1 or 0
end

--有魔器相关装备时显示主界面按钮红点
function MagicWeaponData:GetRedPointStatus()
	local all_magic_weapon_list = ItemData.Instance:GetAllMagicWeaponList()
	if #all_magic_weapon_list > 0 then
		return true
	end
	return false
end

function MagicWeaponData:GetMagicWeaponInfo()
	return self.MagicWeaponInfo
end
function MagicWeaponData:GetMetlLevel()
	return self.MagicWeaponInfo.melt_level or 0
end
function MagicWeaponData:GetIdentifyLevel()
	return self.MagicWeaponInfo.identify_level or 0
end
function MagicWeaponData:GetMeltExp()
	return self.MagicWeaponInfo.melt_exp or 0
end
function MagicWeaponData:GetIdentifyExp()
	return self.MagicWeaponInfo.identify_exp or 0
end
function MagicWeaponData:GetAllWeaponLevelList()
	return self.MagicWeaponInfo.all_weapon_level_list or {}
end
function MagicWeaponData:GetBackPackList()
	return self.MagicWeaponInfo.back_pack_list or {}
end
function MagicWeaponData:GetTodayGatherTimes()
	return self.MagicWeaponInfo.today_gather_times or 0
end
function MagicWeaponData:GetTodayExchangeIdentifyExpTimes()
	return self.MagicWeaponInfo.today_exchange_identify_exp_times or 0
end
function MagicWeaponData:GetIdentifyExpCfg()
	return self.identify_exp_cfg
end
function MagicWeaponData:GetLastIdentifyLevel()
	return self.last_identify_level or 0
end
function MagicWeaponData:GetLastIdentifyStarLevel()
	return self.MagicWeaponInfo.identify_star_level or 0
end
function MagicWeaponData:SetLastIdentifyLevel(level)
	self.last_identify_level = level
end
function MagicWeaponData:GetIdentifyLevelCfg()
	return self.identify_level_cfg
end

function MagicWeaponData:GetIdentifyCfgByTime(time)
	for k,v in pairs(self.identify_exp_cfg) do
		if time == v.seq then
			return v
		end
	end
end

function MagicWeaponData:GetItemConfig(item_id)
	for k,v in pairs(self.weapon_cfg) do
		if v.item_id == item_id then
			return v
		end
	end
end

function MagicWeaponData:GetWeaponCfgById(id)
	for k,v in pairs(self.weapon_cfg) do
		if v.id == id then
			return v
		end
	end
end

function MagicWeaponData:GetWeaponInfoById(id)
	local item_id = self:GetWeaponCfgById(id).item_id
	local temp_list = {}
	local all_magic_weapon_list = ItemData.Instance:GetAllMagicWeaponList()
	for k,v in pairs(all_magic_weapon_list) do
		if v.item_id == item_id then
			table.insert(temp_list,TableCopy(v)) --如果要改变v则需要返回零时的table
			return temp_list[1]
		end
	end
	return nil
end

--获取item_id的数量
function MagicWeaponData:GetGarbageNumById(id)
	local item_id = self:GetWeaponCfgById(id).item_id
	local all_magic_weapon_list = ItemData.Instance:GetAllMagicWeaponList()
	for k,v in pairs(all_magic_weapon_list) do
		if v.item_id == item_id then
			return v.num
		end
	end
	return 0
end

--获取总数量(绑定+非绑)
function MagicWeaponData:GetWeaponTotalNumById(id)
	local num = 0
	local item_id = self:GetWeaponCfgById(id).item_id
	local all_magic_weapon_list = ItemData.Instance:GetAllMagicWeaponList()
	for k,v in pairs(all_magic_weapon_list) do
		if v.item_id == item_id then
			num = num + v.num
		end
	end
	return num
end

function MagicWeaponData:GetWeaponCfgListByType(type)
	local data_list = {}
	local index = 0
	for i = 1, #self.weapon_cfg do
		if self.weapon_cfg[i].type == type then
			data_list[index] = self.weapon_cfg[i]
			index = index + 1
		end
	end
	return data_list
end

--根据部件获取魔器信息
function MagicWeaponData:GetWeaponCfgBySlot(slot)
	for k,v in pairs(self.weapon_cfg) do
		if v.slot == slot then
			return v
		end
	end
end

--根据等级获取熔炼等级信息
function MagicWeaponData:GetMeltLevelCfgByLevel(level)
	for k,v in pairs(self.melt_level_cfg) do
		if v.level == level then
			return v
		end
	end
end

function MagicWeaponData:GetDescByEquipNum(num)
	local desc_t = {cur_text1 = "", cur_text2 = "", next_text1 = ""}
	local value1 = 0
	local value2 = 0
	if num < GameEnum.SHENZHOU_WEAPON_SLOT_COUNT then
		value1 = self.other_cfg.all_active_add_percent
		desc_t.next_text1 = string.format(Language.ShenZhou.ZengJiaYuanYouShuXing, value1)
	elseif num == GameEnum.SHENZHOU_WEAPON_SLOT_COUNT then
		value1 = self.other_cfg.all_active_add_percent
		value2 = self.other_cfg.skill_rate
		desc_t.cur_text1 = string.format(Language.ShenZhou.ZengJiaYuanYouShuXing, value1)
		desc_t.next_text1 = string.format(Language.ShenZhou.MaxLevelEffectText, value2)
	elseif num == GameEnum.SHENZHOU_WEAPON_SLOT_COUNT + 1 then
		value1 = self.other_cfg.all_active_add_percent
		value2 = self.other_cfg.skill_rate
		desc_t.cur_text1 = string.format(Language.ShenZhou.ZengJiaYuanYouShuXing, value1)
		desc_t.cur_text2 = string.format(Language.ShenZhou.MaxLevelEffectText, value2)
	end

	return desc_t
end

--获取武器战力差值
function MagicWeaponData:GetEquipCapacityLerp(card_id, cur_equip_level, next_equip_level)
	local cur_cfg = self:GetStrengthInfoByIdAndLevel(card_id, cur_equip_level)
	local next_cfg = self:GetStrengthInfoByIdAndLevel(card_id, next_equip_level)
	local cur_attribute = CommonDataManager.GetAttributteByClass(cur_cfg)
	local next_attribute = CommonDataManager.GetAttributteByClass(next_cfg)

	local capacity = CommonDataManager.LerpAttributeAttr(cur_attribute, next_attribute)
	return CommonDataManager.GetCapability(capacity)
end

--获取武器战力
function MagicWeaponData:GetEquipCapacity(card_id, cur_equip_level)
	local cur_cfg = self:GetStrengthInfoByIdAndLevel(card_id, cur_equip_level)
	local cur_attribute = CommonDataManager.GetAttributteByClass(cur_cfg)
	return CommonDataManager.GetCapability(cur_attribute)
end

--获取熔炼等级战力
function MagicWeaponData:GetMeltCapacity( cur_melt_level)
	local cur_cfg = self:GetMeltLevelCfgByLevel(cur_melt_level)
	local cur_attribute = CommonDataManager.GetAttributteByClass(cur_cfg)
	return CommonDataManager.GetCapability(cur_attribute)
end

--获取星级战力
function MagicWeaponData:GetStarCapacity(star_cfg)
	local cur_attribute = CommonDataManager.GetAttributteByClass(star_cfg)
	return CommonDataManager.GetCapability(cur_attribute)
end

function MagicWeaponData:GetStrengthInfoByIdAndLevel(card_id, level)
	local strength_level = level --or self:GetStrengthLevelById(card_id)
	for k,v in pairs(self.attr_cfg) do
		if card_id == v.slot and strength_level == v.level then
			return v
		end
	end
	return nil
end

--查看所有魔器是否都达到了指定的等级
function MagicWeaponData:CheckAllWeaponLevelByLevel(level)
	if nil == level then return false end
	for k,v in pairs(self:GetAllWeaponLevelList()) do
		if v < level then
			return false
		end
	end
	return true
end

function MagicWeaponData:GetMeltAttr(level)
	local melt_level_cfg = self:GetMeltLevelCfgByLevel(level)

	return CommonDataManager.GetAttributteByClass(melt_level_cfg)
end

function MagicWeaponData:GetEquipTotalCapabilityAndAttr()
	local total_attribute = self:GetTotalAttrCap()
	if nil == total_attribute then return end

    --已激活装备数量
	local num = self:GetEquipActiveNum()
	local percent_addition = 0
	if num == GameEnum.SHENZHOU_WEAPON_SLOT_COUNT then
		percent_addition = self.other_cfg.all_active_add_percent
	end

    --激活六件装备增加的套装属性
	local attr_add = CommonDataManager.MulAttribute(total_attribute, percent_addition / 100)
	total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attr_add)

	-- 熔炼属性
	local melt_level = MagicWeaponData.Instance:GetMeltLevel()
	total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, MagicWeaponData.Instance:GetMeltAttr(melt_level))

	local capability = CommonDataManager.GetCapability(total_attribute)

	return capability,total_attribute
end

--神州六器总属性
function MagicWeaponData:GetTotalAttrCap()
	local total_attr = CommonStruct.Attribute()
	for k,v in pairs(self:GetAllWeaponLevelList()) do
		if v > 0 then
			local cur_attr = self:GetStrengthInfoByIdAndLevel(k, v)

			local attribute = CommonDataManager.GetAttributteByClass(cur_attr)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, attribute)
		end
	end

	return total_attr
end

function MagicWeaponData:GetEquipActiveNum()
	local num = 0
	for k,v in pairs(self:GetAllWeaponLevelList()) do
		if v>0 then
			num = num + 1
		end
	end
	return num
end

-- 背包排序
function MagicWeaponData:GetBagBestMagic()

end

-- 获取当前星级属性
function MagicWeaponData:GetStarLevelCfg(identify_level, star_level)
	local identify_level_data = self:GetIdentifyLevelCfg()
	for k,v in pairs(identify_level_data) do
		if identify_level == v.level and star_level == v.star_level then
			return v
		end
	end
end

