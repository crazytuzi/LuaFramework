
GodFurnaceData = GodFurnaceData or BaseClass(BaseData)

-- 神炉存储位置索引
GodFurnaceData.Slot = {
	LeftSpecialRingPos = 0,		-- 左边特戒
	RightSpecialRingPos = 1,	-- 右边特戒
	TheDragonPos = 2,		-- 龙符
	ShieldPos = 3,			-- 护盾
	GemStonePos = 4,		-- 宝石
	DragonSpiritPos = 5,	-- 龙魂
	ShenDing = 6,			-- 神鼎

	MaxPos = 6,
}

GodFurnaceData.ItemType2Slot = {
	[ItemData.ItemType.itTheDragon] = GodFurnaceData.Slot.TheDragonPos,		-- 龙符
	[ItemData.ItemType.itShield] = GodFurnaceData.Slot.ShieldPos,		-- 护盾
	[ItemData.ItemType.itGemStone] = GodFurnaceData.Slot.GemStonePos,		-- 宝石
	[ItemData.ItemType.itDragonSpirit] = GodFurnaceData.Slot.DragonSpiritPos,		-- 龙魂
	[ItemData.ItemType.itShenDing] = GodFurnaceData.Slot.ShenDing,		-- 龙魂
}

-- 神炉装备位置索引
GodFurnaceData.EquipPos = {
	-- 左边特戒开始
	gfLeftFirstDragonPos = 0,				-- 第一个青龙
	gfLeftFirstWhileTiggerPos = 1,			-- 第一个白虎
	gfLeftFirstRosefinchPos = 2,			-- 第一个朱雀
	gfLeftFirstXuanWuPos = 3,				-- 第一玄武
	gfLeftFirstUnicornPos = 4,				-- 第一个麒麟
	gfLeftSecondtDragonPos = 5,				-- 第二个青龙
	gfLeftSecondWhileTiggerPos = 6,			-- 第二个白虎
	gfLeftSecondRosefinchPos = 7,			-- 第二个朱雀
	gfLeftSecondXuanWuPos = 8,				-- 第二个玄武
	gfLeftSecondUnicornPos = 9,				-- 第二个麒麟

	gfLeftSpecialRingMaxPos = 9,			-- 左边特戒最大的装备位
	-- 右边特戒
	gfRightFirstDragongPos = 10,			-- 第一个青龙
	gfRightFirstWhileTiggerPos = 11,		-- 第一个白虎
	gfRightFirstRosefinchPos = 12,			-- 第一个朱雀
	gfRightFirstXuanWuPos = 13,				-- 第一玄武
	gfRightFirstUnicornPos = 14,			-- 第一个麒麟
	gfRightSecondtDragonPos = 15,			-- 第二个青龙
	gfRightSecondWhileTiggerPos = 16,		-- 第二个白虎
	gfRightSecondRosefinchPos = 17,			-- 第二个朱雀
	gfRightSecondXuanWuPos = 18,			-- 第二个玄武
	gfRightSecondUnicornPos = 19,			-- 第二个麒麟

	gfRightSpecialRingMaxPos = 19,			-- 右边特戒最大的装备位

	-- 心法
	gfFirstHeartMin = 20,
	gfFirstHeartPos = 20,			-- 首篇心法
	gfPartOneHeartPos = 21,			-- 上篇心法
	gfNoveletteHeartPos = 22,		-- 中篇心法
	gfPartTwoHeartPos = 23,			-- 下篇心法
	gfFinalChapterHeartPos = 24,	-- 终篇心法
	gfFirstHeartMax = 24,

	GodFurnaceEquipMax = 24,			-- 最大神炉装备
}

-- 心法套装激活所需要的装备数量
GodFurnaceData.HEART_SUIT_NEED_COUNT = GodFurnaceData.EquipPos.gfFirstHeartMax - GodFurnaceData.EquipPos.gfFirstHeartMin + 1

-- 圣物最大品质
HolyMaxQuality = 4

local EQUIP_SLOT_NAME = {
	[0] = "青龙", "白虎", "朱雀", "玄武", "麒麟",
	"青龙", "白虎", "朱雀", "玄武", "麒麟",

	"青龙", "白虎", "朱雀", "玄武", "麒麟",
	"青龙", "白虎", "朱雀", "玄武", "麒麟",

	"首篇心法", "上篇心法", "中篇心法", "下篇心法", "终篇心法",
}

local EQUIP_SLOT_TYPE = {
	[0] = ItemData.ItemType.itDragonHoly, ItemData.ItemType.itWhiteTigerHoly, ItemData.ItemType.itRosefinchHoly, ItemData.ItemType.itXuanWuHoly, ItemData.ItemType.itUnicornHoly,
	ItemData.ItemType.itDragonHoly, ItemData.ItemType.itWhiteTigerHoly, ItemData.ItemType.itRosefinchHoly, ItemData.ItemType.itXuanWuHoly, ItemData.ItemType.itUnicornHoly,

	ItemData.ItemType.itDragonHoly, ItemData.ItemType.itWhiteTigerHoly, ItemData.ItemType.itRosefinchHoly, ItemData.ItemType.itXuanWuHoly, ItemData.ItemType.itUnicornHoly,
	ItemData.ItemType.itDragonHoly, ItemData.ItemType.itWhiteTigerHoly, ItemData.ItemType.itRosefinchHoly, ItemData.ItemType.itXuanWuHoly, ItemData.ItemType.itUnicornHoly,

	ItemData.ItemType.itFirstHeart, ItemData.ItemType.itPartOneHeart, ItemData.ItemType.itNoveletteHeart, ItemData.ItemType.itPartTwoHeart, ItemData.ItemType.itFinalChapterHeart,
}

-- 神炉装备 图标美术资源 client\tools\uieditor\ui_res\godfurnace
local EQUIP_SLOT_ICON_IMG = {
	[GodFurnaceData.EquipPos.gfFirstHeartPos] = "heart_img_1",
	[GodFurnaceData.EquipPos.gfPartOneHeartPos] = "heart_img_2",
	[GodFurnaceData.EquipPos.gfNoveletteHeartPos] = "heart_img_3",
	[GodFurnaceData.EquipPos.gfPartTwoHeartPos] = "heart_img_4",
	[GodFurnaceData.EquipPos.gfFinalChapterHeartPos] = "heart_img_5",
}

-- 圣物合成
GodFurnaceData.HOLY_POS = {
	MATERIAL1 = 1,	-- 合成原物品1
	MATERIAL2 = 2,	-- 合成原物品2
	MATERIAL3 = 3,	-- 合成原物品3
	SYNTHESIS = 4,	-- 合成物品
}

GodFurnaceData.STAR_NUM = 10

-- 事件
GodFurnaceData.SLOT_DATA_CHANGE = "slot_data_change"--神炉数据改变
GodFurnaceData.EQUIP_CHANGE = "equip_change"--神炉装备数据改变
GodFurnaceData.GOD_POWER_LEVEL_CHANGE = "god_power_level_change"--烈焰神力等级数据改变
GodFurnaceData.GOD_POWER_VAL_CHANGE = "god_power_val_change"--烈焰神力值数据改变
GodFurnaceData.SYNTHESISSUCC = "synthesissucc"				-- 圣物合成成功

local FlamingpowerConfig = FlamingpowerConfig
local HeartSuitPlusAttrCfg = HeartSuitPlusAttrCfg

function GodFurnaceData:__init()
	if	GodFurnaceData.Instance then
		ErrorLog("[GodFurnaceData]:Attempt to create singleton twice!")
	end
	GodFurnaceData.Instance = self

	-- 神炉列表
	self.slot_data = {}
	for i = 0, GodFurnaceData.Slot.MaxPos do
		self.slot_data[i] = {level = 0}
	end

	-- 装备列表
	self.equip_list = {}

	-- 烈焰神力
	self.god_power_level = 0
	self.god_power_val = 0

	-- 圣物
	self.holy_synthesis_item = {}
	self.holy_bag_list = {}

	self.virtual_data = {}
	self.other_virtual_data = {}

	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetGodFurnaceCanUpRemind, self, GodFurnaceData.Slot.TheDragonPos), RemindName.TheDragonCanUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetGodFurnaceCanUpRemind, self, GodFurnaceData.Slot.ShieldPos), RemindName.ShieldCanUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetGodFurnaceCanUpRemind, self, GodFurnaceData.Slot.GemStonePos), RemindName.GemStoneCanUp)--//*宝石红点修改*
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetGodFurnaceCanUpRemind, self, GodFurnaceData.Slot.DragonSpiritPos), RemindName.DragonSpiritCanUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetGodFurnaceCanUpRemind, self, GodFurnaceData.Slot.ShenDing), RemindName.GodFurnaceShenDingCanUp)

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetFireGodPowerCanUpRemind, self), RemindName.FireGodPowerCanUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetHeartEquipRemind, self), RemindName.HeartEquip)
end

function GodFurnaceData:__delete()
	GodFurnaceData.Instance = nil
end

function GodFurnaceData:RecvMainInfoCallBack()
end


-- 神炉物品可提升的提醒数量
function GodFurnaceData:GetGodFurnaceCanUpRemind(gf_slot)
	local prof = RoleData.Instance:GetRoleBaseProf()
	local cfg = self:GetProfCfg(gf_slot, prof)
	local consume_cfg = self:GetNextConsume(cfg, self:GetSlotData(gf_slot).level)
	if consume_cfg then -- 有消耗配置说明没满级
		local consume_item = consume_cfg[1]
		local bag_num = BagData.Instance:GetItemNumInBagById(consume_item.id)
		if bag_num >= consume_item.count then--有足够的消耗物品
			return 1
		end
	end
	return 0
end

function GodFurnaceData:GetFireGodPowerCanUpRemind()
	local level = self:GetGodPowerlevel()
	local cur_attr, next_attr = self:FireGodSkillAttrCfg(level)
	if nil == next_attr then -- 满级
		return 0
	end

	local consumes = self:GetGFImprintItemList()
	for k, v in pairs(consumes) do
		local bag_num = BagData.Instance:GetItemNumInBagById(v.item_id)
		if bag_num > 0 then--背包中有可提升的物品
			return 1
		end
	end
	return 0
end

function GodFurnaceData:GetHeartEquipRemind()
	local is_open = GameCondMgr.Instance:GetValue("CondId14")
	if not is_open then--心法装备是否开启
		return 0
	end
	local num = 0
	for i = GodFurnaceData.EquipPos.gfFirstHeartMin, GodFurnaceData.EquipPos.gfFirstHeartMax do
		local equip_is_open = self:GetEquipIsOpen(i)
		local have_best_equip = self:GetBestEquipInBag(i)
		if equip_is_open and have_best_equip then
				
			-- if show_remind then
				num = num + 1
			-- end
		end
	end
	return num
end

function GodFurnaceData.IsHeartEquipCondMatch(data)
	if not data then return false end
	local show_remind = true
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	for k,v in pairs(item_cfg.conds or {}) do
		if v.cond == ItemData.UseCondition.ucLevel then
			if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				show_remind = false
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				show_remind = false
			end
		end
	end
	return show_remind
end

----------------------------------------------------------------------------------------------
-- 烈焰神力等级
function GodFurnaceData:SetGodPowerLevel(god_power_level)
	if self.god_power_level ~= god_power_level then
		self.god_power_level = god_power_level
		self:DispatchEvent(GodFurnaceData.GOD_POWER_LEVEL_CHANGE, god_power_level)

		RemindManager.Instance:DoRemindDelayTime(RemindName.FireGodPowerCanUp)
	end
end

-- 烈焰神力值
function GodFurnaceData:SetGodPowerVal(god_power_val)
	if self.god_power_val ~= god_power_val then
		self.god_power_val = god_power_val
		self:DispatchEvent(GodFurnaceData.GOD_POWER_VAL_CHANGE, god_power_val)

		RemindManager.Instance:DoRemindDelayTime(RemindName.FireGodPowerCanUp)
	end
end

-- 所有神炉装备数据
function GodFurnaceData:SetAllEquip(equip_list)
	self.equip_list = equip_list
	self:DispatchEvent(GodFurnaceData.EQUIP_CHANGE)

	RemindManager.Instance:DoRemindDelayTime(RemindName.HeartEquip)
end

-- 一件神炉装备数据
function GodFurnaceData:SetOneEquip(equip)
	self.equip_list[equip.deport_id] = equip
	self:DispatchEvent(GodFurnaceData.EQUIP_CHANGE)

	RemindManager.Instance:DoRemindDelayTime(RemindName.HeartEquip)
end

-- 神炉数据
function GodFurnaceData:SetSlotData(slot, data)
	local slot_data = self.slot_data[slot]	
	if slot_data and slot_data.level ~= data.level then
		if slot_data.level == 0 and data.level == 1 then
			GlobalEventSystem:Fire(OtherEventType.GODFURNACE_ACTIVE, slot)
		else
			GlobalEventSystem:Fire(OtherEventType.GODFURNACE_UP_SUCCED, slot)
		end

		slot_data.level = data.level
		self:SetVirtualEquipdata(slot)

		self:DispatchEvent(GodFurnaceData.SLOT_DATA_CHANGE, slot, slot_data)

		if slot == GodFurnaceData.Slot.TheDragonPos then
			RemindManager.Instance:DoRemindDelayTime(RemindName.TheDragonCanUp)
		elseif slot == GodFurnaceData.Slot.ShieldPos then
			RemindManager.Instance:DoRemindDelayTime(RemindName.ShieldCanUp)
		elseif slot == GodFurnaceData.Slot.GemStonePos then
			RemindManager.Instance:DoRemindDelayTime(RemindName.GemStoneCanUp)
			RemindManager.Instance:DoRemindDelayTime(REMIND_ACT_LIST[ACT_ID.BSJJ])
		elseif slot == GodFurnaceData.Slot.DragonSpiritPos then
			RemindManager.Instance:DoRemindDelayTime(RemindName.DragonSpiritCanUp)
			RemindManager.Instance:DoRemindDelayTime(RemindName.HeartEquip)
			RemindManager.Instance:DoRemindDelayTime(REMIND_ACT_LIST[ACT_ID.HZJJ])
		elseif slot == GodFurnaceData.Slot.ShenDing then
			RemindManager.Instance:DoRemindDelayTime(RemindName.GodFurnaceShenDingCanUp)
		end
	end
end

------------------------------------------------------------------------------------------
-- 神炉装备对应的物品类型 item_type
function GodFurnaceData.GetEquipSlotItemType(equip_slot)
	return EQUIP_SLOT_TYPE[equip_slot]
end

function GodFurnaceData:GetEquipSlotIconImgName(equip_slot)
	return EQUIP_SLOT_ICON_IMG[equip_slot] or "heart_img_1"
end

-- 神炉装备名称
function GodFurnaceData:GetEquipSlotName(equip_slot)
	return EQUIP_SLOT_NAME[equip_slot] or ""
end

-- 获取背包中最好的神炉装备
function GodFurnaceData:GetBestEquipInBag(equip_slot)
	local item_type = self.GetEquipSlotItemType(equip_slot)
	if nil == item_type then
		return
	end

	local cur_score = ItemData.Instance:GetItemScoreByData(self:GetEquip(equip_slot))
	local best_score = cur_score
	local best_equip_data = nil
	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		if v.type == item_type and ItemData.Instance:GetItemScoreByData(v) > best_score and GodFurnaceData.IsHeartEquipCondMatch(v) then
			best_equip_data = v
			best_score = ItemData.Instance:GetItemScoreByData(v)
		end
	end
	return best_equip_data
end

-- 神炉装备是否开启
function GodFurnaceData:GetEquipIsOpen(equip_slot)
	local open_cfg = GodFurnaceEquipOpenCfg[(equip_slot + 1)]
	if open_cfg then
		local level = self:GetSlotData(open_cfg.type).level
		return level >= open_cfg.needlv, string.format("%d级%s可激活", open_cfg.needlv, self:GetSlotName(open_cfg.type))
	else
		return true
	end
end

-- 神炉装备
function GodFurnaceData:GetEquip(equip_slot)
	return self.equip_list[equip_slot]
end

-- 神炉配置
function GodFurnaceData:GetCfg(slot)
	local cfg = ConfigManager.Instance:GetServerConfig("godfurnace/godfurnaceslotlvcfg/GodFurnaceSlot" .. slot .. "LvCfg")
	return cfg and cfg[1]
end

-- 神炉职业配置
function GodFurnaceData:GetProfCfg(slot, prof)
	prof = prof or RoleData.Instance:GetRoleBaseProf()
	local cfg = self:GetCfg(slot)
	return cfg and cfg.job[prof]
end

-- 神炉名称
function GodFurnaceData:GetSlotName(slot, prof)
	prof = prof or RoleData.Instance:GetRoleBaseProf()
	local prof_cfg = self:GetProfCfg(slot, prof)
	return prof_cfg and prof_cfg.slotName or slot
end

-- 神炉显示资源信息
function GodFurnaceData:GetSlotResInfo(slot, level, prof)
	prof = prof or RoleData.Instance:GetRoleBaseProf()

	local prof_cfg = self:GetProfCfg(slot, prof)
	local eff_res_id = 0
	local name_path = "word_mbtj"
	local name = ""
	local gf_item_cfg = nil
	if prof_cfg then
		eff_res_id = prof_cfg.lvcfg[level] and prof_cfg.lvcfg[level].icon or prof_cfg.lvcfg[1].icon or eff_res_id
		name_path = prof_cfg.lvcfg[level] and prof_cfg.lvcfg[level].nameImgPath or prof_cfg.lvcfg[1].nameImgPath or name_path
		name = prof_cfg.lvcfg[level] and prof_cfg.lvcfg[level].name or prof_cfg.lvcfg[1].name or ""
		gf_item_cfg = prof_cfg.lvcfg[level] and prof_cfg.lvcfg[level].itemCfg or nil
	end
	return {eff_res_id = eff_res_id, name_path = name_path, name = name, gf_item_cfg = gf_item_cfg}
end

-- 获取神炉数据
function GodFurnaceData:GetSlotData(slot)
	return self.slot_data[slot] or {level = 0}
end

-- 是否激活神炉
function GodFurnaceData:IsActSlot(slot)
	return self:GetSlotData(slot).level > 0
end

-- 神炉属性配置
function GodFurnaceData:GetAttrCfg(cfg, level)
	return cfg.lvcfg[level] and cfg.lvcfg[level].attr,
		cfg.lvcfg[level + 1] and cfg.lvcfg[level + 1].attr
end

-- 神炉提升到下一级的消耗配置
function GodFurnaceData:GetNextConsume(cfg, level)
	return cfg.lvcfg[level + 1] and cfg.lvcfg[level + 1].consume
end

-- 神炉星数计算(显示用)
function GodFurnaceData:GetStarNum(level)
	return math.max(level, 0) % (GodFurnaceData.STAR_NUM + 1)
end

-- 神炉大等级计算(显示用)
function GodFurnaceData:GetGradeNum(level)
	return (level == 0) and 0 or (1 + math.floor(level / (GodFurnaceData.STAR_NUM + 1)))
end

function GodFurnaceData:GetGodPowerlevel()
	return self.god_power_level
end

function GodFurnaceData:GetGodPowerVal()
	return self.god_power_val
end

function GodFurnaceData:GetGFImprintItemList()
	local list = {}
	for k, v in pairs(FlamingpowerConfig.itemImprint) do
		list[#list + 1] = {item_id = k}
	end
	table.sort(list, function(a, b) return a.item_id > b.item_id end)	-- 简单的排一下
	return list
end

function GodFurnaceData:IsGFImprintItem(item_id)
	return nil ~= FlamingpowerConfig.itemImprint[item_id]
end

function GodFurnaceData:FireGodSkillCfg(prof)
	prof = prof or RoleData.Instance:GetRoleBaseProf()
	return ConfigManager.Instance:GetServerConfig("godfurnace/flamingpowerjobcfg/FlamingPowerJob" .. prof .. "Config")[1]
end

-- 烈焰神力下一级所需消耗
function GodFurnaceData:FireGodSkillNextConsume(level, prof)
	local fire_skill_cfg = self:FireGodSkillCfg(prof)
	if fire_skill_cfg and fire_skill_cfg[level + 1] then
		return fire_skill_cfg[level + 1].consume
	end
end

-- 烈焰神力属性
function GodFurnaceData:FireGodSkillAttrCfg(level, prof)
	local fire_skill_cfg = self:FireGodSkillCfg(prof)
	if fire_skill_cfg then
		return fire_skill_cfg[level] and fire_skill_cfg[level].attr,
			fire_skill_cfg[level + 1] and fire_skill_cfg[level + 1].attr
	end
	return nil, nil
end

-- 烈焰神力技能配置
function GodFurnaceData:GetFireGodSkillInfo(level, prof)
	-- local fire_skill_cfg = self:FireGodSkillCfg(prof)
	-- local name = ""
	-- local desc = ""
	-- if fire_skill_cfg and fire_skill_cfg[level] then
	-- 	local cfg = fire_skill_cfg[level]
	-- 	local skill_lv_cfg = SkillData.GetSkillLvCfg(cfg.skillid, cfg.skilllv)
	-- 	local skill_cfg = SkillData.GetSkillCfg(cfg.skillid)
	-- 	if skill_cfg then
	-- 		name = skill_cfg.name
	-- 	end
	-- 	if skill_lv_cfg then
	-- 		desc = skill_lv_cfg.desc
	-- 	end
	-- end

	local cfg = ConfigManager.Instance:GetClientConfig("fire_god_power_cfg")
	if cfg and cfg.skill[level] then
		return cfg.skill[level]
	end
	return {name = "", desc = ""}
end

-- 烈焰神力消耗的物品在背包中的数据
function GodFurnaceData:GetGFImprintItemInBag(search_num)
	local item_list = {}
	local num = 0
	search_num = search_num or 1
	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		if self:IsGFImprintItem(v.item_id) then
			table.insert(item_list, v)
			num = num + 1
			if num >= search_num then
				break
			end
		end
	end

	return item_list
end

-- 抗暴心法详细配置
function GodFurnaceData.GetHeartSuitInfo(id)
	return ConfigManager.Instance:GetClientConfig("heart_suit_plus_cfg")[id]
end

-- 下一级抗暴心法详细配置
function GodFurnaceData.GetNextHeartSuitInfo(id)
	return GodFurnaceData.GetHeartSuitInfo(math.min(GodFurnaceData.GetHeartSuitNextId(id), #HeartSuitPlusAttrCfg))
end

-- 下一级抗暴心法的id
function GodFurnaceData.GetHeartSuitNextId(id)
	return id + 1
end

-- 符合心法套装id的数量
function GodFurnaceData:GetHeartSuitIdCount(id)
	local count = 0
    for i = GodFurnaceData.EquipPos.gfFirstHeartMin, GodFurnaceData.EquipPos.gfFirstHeartMax do
    	local data = self:GetEquip(i)
    	if data then
    		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
    		if (item_cfg.quality + 1) >= id then
	    		count = count + 1
    		end
    	end
    end
    return count
end

-- 心法套装id
function GodFurnaceData:GetHeartSuitId()
	local min
    for i = GodFurnaceData.EquipPos.gfFirstHeartMin, GodFurnaceData.EquipPos.gfFirstHeartMax do
    	local data = self:GetEquip(i)
    	if data then
    		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
    		if (nil == min) or (min > item_cfg.quality) then
    			min = item_cfg.quality
    		end
    	else
    		return 0
    	end
    end
	return min + 1
end

-----------------------------------------------------------------------------
-- 圣物合成

GodFurnaceData.HOLY_SYNTHESIS_ITEM_CHANGE = "holy_synthesis_item_change"
GodFurnaceData.HOLY_BAG_ITEM_CHANGE = "holy_bag_item_change"

-- 初始化合成列表
function GodFurnaceData:InitHolySynthesis()
	for i = GodFurnaceData.HOLY_POS.MATERIAL1, GodFurnaceData.HOLY_POS.MATERIAL3 do
		self:ChangeOneHolySynthesis(i, nil)
	end
end

-- 该物品是否在合成列表中
function GodFurnaceData:IsInSynthesis(data)
	for k, v in pairs(self.holy_synthesis_item) do
		if v.series == data.series then
			return true
		end
	end
	return false
end

-- 更新合成列表
function GodFurnaceData:UpdateHolySynthesisList()
	local is_change = false
	for k, v in pairs(self.holy_synthesis_item) do
		if nil == BagData.Instance:GetOneItemBySeries(v.series) then
			self.holy_synthesis_item[k] = nil
			is_change = true
			self:DispatchEvent(GodFurnaceData.HOLY_SYNTHESIS_ITEM_CHANGE, k)
		end
	end
end

-- 更新圣物背包列表
function GodFurnaceData:UpdateHolyBagList()
	self.holy_bag_list = {}
	for i = ItemData.ItemType.itHolyMin, ItemData.ItemType.itHolyMax do
		local bag_item_data = BagData.Instance:GetBagItemDataListByType(item_type)
		for i,v in pairs(bag_item_data) do
			table.insert(self.holy_bag_list, v)
		end
	end

	self:DispatchEvent(GodFurnaceData.HOLY_BAG_ITEM_CHANGE)
end

-- 得到一个合成圣物的空位
function GodFurnaceData:GetOneEmptyHolySynthesis()
	for i = GodFurnaceData.HOLY_POS.MATERIAL1, GodFurnaceData.HOLY_POS.MATERIAL3 do
		if nil == self.holy_synthesis_item[i] then
			return i
		end
	end
	return nil
end

-- 将背包物品投入到合成列表中
function GodFurnaceData:AddToHolySynthesis(data)
	local pos = self:GetOneEmptyHolySynthesis()
	if pos then
		local cur_quality = ItemData.Instance:GetItemConfig(data.item_id).quality
		for k, v in pairs(self.holy_synthesis_item) do
			if cur_quality ~= ItemData.Instance:GetItemConfig(v.item_id).quality then
				SysMsgCtrl.Instance:FloatingTopRightText("{color;ff2828;品质不同，不可合成}")
				return false
			end
		end
		self:ChangeOneHolySynthesis(pos, data)
		return true
	end
	return false
end

-- 将背包物品从合成列表中取出
function GodFurnaceData:TakeOutHolySynthesis(data)
	for k, v in pairs(self.holy_synthesis_item) do
		if v == data then
			self:ChangeOneHolySynthesis(k, nil)
		end
	end
end

-- 改变一个合成列表中的数据
function GodFurnaceData:ChangeOneHolySynthesis(pos, data)
	self.holy_synthesis_item[pos] = data
	self:UpdateHolyBagList()
	self:DispatchEvent(GodFurnaceData.HOLY_SYNTHESIS_ITEM_CHANGE, pos)

	if pos == GodFurnaceData.HOLY_POS.SYNTHESIS and nil ~= data then
		-- 合成成功的物品在2秒后会从列表中消失
		GlobalTimerQuest:CancelQuest(self.synthesis_disappear_timer)
		self.synthesis_disappear_timer = GlobalTimerQuest:AddDelayTimer(function()
			self:ChangeOneHolySynthesis(GodFurnaceData.HOLY_POS.SYNTHESIS, nil)
		end, 2)
	end
end

-- 圣物背包列表
function GodFurnaceData:GetHolyBagList()
	return self.holy_bag_list
end

-- 圣物合成列表
function GodFurnaceData:GetHolySynthesisItem(pos)
	return self.holy_synthesis_item[pos]
end

--------------------------------------------------------------------------------------
-- 神炉虚拟物品
-- 设置一个神炉虚拟物品配置
function GodFurnaceData:SetVirtualEquipCfg(prof, slot, level, item_id)
	local godfurance_cfg = self:GetProfCfg(slot, prof)
	if nil == godfurance_cfg then
		return
	end
	local info = self:GetSlotResInfo(slot, level)
	local cur_attr = self:GetAttrCfg(godfurance_cfg, level)
	if nil == info or nil == cur_attr then
		return
	end

	local gf_cfg = CommonStruct.ItemConfig()
	gf_cfg.item_id = item_id
	gf_cfg.id = item_id
	gf_cfg.name = info.name
	gf_cfg.desc = ""
	gf_cfg.color = 0xff8a00
	gf_cfg.type = (ItemData.ItemType.itLeftSpecialRing + slot)
	gf_cfg.icon = (BaseCell.ITEM_EFFSET_OFFSET + info.eff_res_id)
	gf_cfg.showQuality = 4
	gf_cfg.staitcAttrs = cur_attr

	if info.gf_item_cfg then
		for k, v in pairs(info.gf_item_cfg) do
			gf_cfg[k] = v
		end
	end

	return ItemData.Instance:AddVirtualItemConfig(gf_cfg, item_id)
end

-- 主角神炉虚拟装备
function GodFurnaceData:SetVirtualEquipdata(slot)
	local level = self:GetSlotData(slot).level
	if level < 1 then
		return
	end
	local prof = RoleData.Instance:GetRoleBaseProf()
	local last_item_id = nil ~= self.virtual_data[slot] and self.virtual_data[slot].item_id or nil

	local virtual_item_id = self:SetVirtualEquipCfg(prof, slot, level, last_item_id)
	if nil == virtual_item_id then
		return
	end

	local data = CommonStruct.ItemDataWrapper()
	data.item_id = virtual_item_id
	self.virtual_data[slot] = data
end

-- 其它角色神炉虚拟装备
function GodFurnaceData:SetOtherVirtualEquipData(prof, slot, level)
	if level < 1 then
		self.other_virtual_data[slot] = nil
		return
	end

	local last_item_id = nil ~= self.other_virtual_data[slot] and self.other_virtual_data[slot].item_id or nil
	
	local virtual_item_id = self:SetVirtualEquipCfg(prof, slot, level, last_item_id)
	if nil == virtual_item_id then
		self.other_virtual_data[slot] = nil
		return
	end

	local data = CommonStruct.ItemDataWrapper()
	data.item_id = virtual_item_id
	self.other_virtual_data[slot] = data
end

function GodFurnaceData:GetGfSlotByItemType(item_type)
	return item_type - ItemData.ItemType.itLeftSpecialRing
end

-- 是否是神炉虚拟物品
function GodFurnaceData:IsVirtualEquipType(item_type)
	return item_type >= ItemData.ItemType.itLeftSpecialRing and item_type <= ItemData.ItemType.itDragonSpirit
end

-- 获取主角神炉虚拟装备data
function GodFurnaceData:GetVirtualEquipData(gf_slot)
	return self.virtual_data[gf_slot]
end

-- 获取其它角色神炉虚拟装备data
function GodFurnaceData:GetOtherVirtualEquipData(gf_slot)
	return self.other_virtual_data[gf_slot]
end
