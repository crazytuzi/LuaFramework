
EquipmentData = EquipmentData or BaseClass()

EquipmentData.Equip = {
	{equip_slot = EquipData.EquipSlot.itWeaponPos, cell_img = {ResPath.EquipImg.WuQi, ResPath.EquipWord.WuQi}},	-- 武器
	{equip_slot = EquipData.EquipSlot.itHelmetPos, cell_img = {ResPath.EquipImg.TouKui, ResPath.EquipWord.TouKui}},	-- 头盔
	{equip_slot = EquipData.EquipSlot.itDressPos, cell_img = {ResPath.EquipImg.KuiJia, ResPath.EquipWord.KuiJia}},	-- 衣服
	{equip_slot = EquipData.EquipSlot.itNecklacePos, cell_img = {ResPath.EquipImg.XiangLian, ResPath.EquipWord.XiangLian}},	-- 项链
	{equip_slot = EquipData.EquipSlot.itLeftBraceletPos, cell_img = {ResPath.EquipImg.ShouZhuo, ResPath.EquipWord.ShouZhuo}},	-- 手镯左
	{equip_slot = EquipData.EquipSlot.itRightBraceletPos, cell_img = {ResPath.EquipImg.ShouZhuo, ResPath.EquipWord.ShouZhuo}},	-- 手镯右
	{equip_slot = EquipData.EquipSlot.itLeftRingPos, cell_img = {ResPath.EquipImg.JieZhi, ResPath.EquipWord.JieZhi}},	-- 戒指左
	{equip_slot = EquipData.EquipSlot.itRightRingPos, cell_img = {ResPath.EquipImg.JieZhi, ResPath.EquipWord.JieZhi}},	-- 戒指右
	{equip_slot = EquipData.EquipSlot.itGirdlePos, cell_img = {ResPath.EquipImg.YaoDai, ResPath.EquipWord.YaoDai}},	-- 腰带
	{equip_slot = EquipData.EquipSlot.itShoesPos, cell_img = {ResPath.EquipImg.XieZi, ResPath.EquipWord.XieZi}},	-- 鞋子
}

EquipmentData.TabIndex = {
	equipment_qianghua = 1,
	equipment_affinage = 2,
	equipment_stone = 3,
	equipment_molding_soul = 4,
}


function EquipmentData:__init()
	if EquipmentData.Instance then
		ErrorLog("[EquipmentData] Attemp to create a singleton twice !")
	end
	EquipmentData.Instance = self
	self.equip_bm_info = {}
end

function EquipmentData:__delete()
	EquipmentData.Instance = nil
end


function EquipmentData:GetAdvStuffWayConfig()
	return {
		[EquipmentData.TabIndex.equipment_qianghua] = {
			string.format(Language.Equipment.CommonTips, QianghuaData.Instance:GetStrengthConsume()) .. 
			string.format(Language.Common.ViewLink, "Recycle", Language.Equipment.WayTitles[1]),
			-- string.format(Language.Equipment.MoveTo, 24, Language.Equipment.WayTitles[8]) ..
		},
		[EquipmentData.TabIndex.equipment_affinage] = {
			string.format(Language.Equipment.CommonTips, AffinageData.Instance:GetAffinageConsume()) .. 
			string.format(Language.Common.ViewLink, "Boss", Language.Equipment.WayTitles[2]) .. 
			string.format(Language.Common.ViewLink, "Shop", Language.Equipment.WayTitles[3]),
		},
		[EquipmentData.TabIndex.equipment_stone] = {
			string.format(Language.Equipment.CommonTips, StoneData.GetStoneItemID(15)) .. 
			string.format(Language.Common.ViewLink, "Boss", Language.Equipment.WayTitles[2]) .. 
			string.format(Language.Common.ViewLink, "Shop", Language.Equipment.WayTitles[3]),
		},
		[EquipmentData.TabIndex.equipment_molding_soul] = {
			string.format(Language.Equipment.CommonTips, MoldingSoulData.Instance:GetSoulConsume()) .. 
			string.format(Language.Common.ViewLink, "Dungeon", Language.Equipment.WayTitles[4]) .. 
			string.format(Language.Common.ViewLink, "Shop", Language.Equipment.WayTitles[3]),
		},
	}
end

-------------------------------------------------------
-----------******** 以下为无用功能代码 *******-----------
-------------------------------------------------------

-------- 血炼 began -------------

function EquipmentData:GetEqBmShowData()
	local data_list = {}
	for i = EquipData.EquipIndex.PeerlessWeaponPos, EquipData.EquipIndex.PeerlessShoesPos do
		local data = {equip = nil, bm_level = 0, remind = false}
		data.equip = EquipData.Instance:GetGridData(i)
		data.bm_level = self:GetEqBmLevelByEquipIndex(i)
		data.remind = self:CanEqBm(EquipmentData.EquipIndex2BmSlot(i), data.bm_level)
		table.insert(data_list, data)
	end
	return data_list
end

function EquipmentData.IsXuelianEquip(index)
	local xuelian_index = EquipmentData.GetXuelianIndex(index)
	return xuelian_index >= 0 and xuelian_index < MAX_STRENGTHEN_SLOT
end

function EquipmentData.FormatBmStrengthStar(star_level)
	if nil == star_level then return end
	local grade = math.floor(star_level / 12)
	local star = star_level % 12
	if grade > 0 and star == 0 then
		grade = grade - 1
		star = 12
	end
	return grade, star
end

function EquipmentData:CanEqBm(slot, level)
	local eq_index = EquipmentData.BmSlot2EquipIndex(slot)
	if not EquipData.Instance:GetGridData(eq_index) then
		return false
	end
	
	local consume_cfg = EquipmentData.GetBmStrengthenSlotCfg(slot, level + 1)
	if consume_cfg then
		local have = BagData.Instance:GetItemNumInBagById(consume_cfg[1])
		if have >= consume_cfg[2] then
			return true
		end
	end
	return false
end

function EquipmentData:GetCanBmStrengthNum()
	local num = 0
	for k, v in pairs(self.equip_soul_info) do
		if self:CanEqBm(k, v) then
			num = num + 1
		end
	end
	return num
end

function EquipmentData:GetEqBmLevelByEquipIndex(index)
	return self:GetEqBmLevel(EquipmentData.EquipIndex2BmSlot(index))
end

function EquipmentData:GetEqBmLevel(slot)
	return self.equip_bm_info[slot] or 0
end

function EquipmentData:GetEquipBmInfo()
	return self.equip_bm_info
end

function EquipmentData:SetEquipBmInfo(data)
	self.equip_bm_info = data
	GlobalEventSystem:Fire(OtherEventType.XUELIAN_INFO_CHANGE)
end

function EquipmentData:ChangeBmLevel(slot, new_level)
	self.equip_bm_info[slot] = new_level
	GlobalEventSystem:Fire(OtherEventType.XUELIAN_INFO_CHANGE, EquipmentData.BmSlot2EquipIndex(slot))
end

function EquipmentData:GetAllBmStrengthLevel()
	local n = 0
	for k, v in pairs(self.equip_bm_info) do
		n = n + v
	end
	return n
end

function EquipmentData.IsWangPeerless(item_id)
	return IsInTable(item_id, {2138, 2139, 2140, 2141, 2142, 2143, 2144, 2145, 2146,})
end

function EquipmentData.GetBmStrengthenAttrCfg(slot, level)
	if slot < 1 or slot > MAX_STRENGTHEN_SLOT then
		return nil
	end
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	return ConfigManager.Instance:GetServerConfig("equipSynthesis/PeerlessSlotStrongAttrs/PeerlessSlot" ..(slot - 1) .. "StrongAttrsCfg") [1] [prof] [level]
end

function EquipmentData.GetBmLimitAttrCfg(eq_index, level)
	local slot = EquipmentData.EquipIndex2BmSlot(eq_index)
	if level <= 10 then
		return EquipmentData.GetBmStrengthenAttrCfg(slot, level)
	else
		local equip = EquipData.Instance:GetGridData(eq_index)
		if equip and not EquipmentData.IsWangPeerless(equip.item_id) then
			return EquipmentData.GetBmStrengthenAttrCfg(slot, 10)
		else
			return EquipmentData.GetBmStrengthenAttrCfg(slot, level)
		end
	end
end

function EquipmentData.GetBmStrengthenSlotCfg(slot, level)
	return PeerlessSlotStrongCfg.slotConsumeList[slot].upgradeCfgs[level]
end

function EquipmentData.BmSlot2EquipIndex(slot)
	return slot + EquipData.EquipIndex.PeerlessWeaponPos - 1
end

function EquipmentData.EquipIndex2BmSlot(index)
	return index - EquipData.EquipIndex.PeerlessWeaponPos + 1
end

function EquipmentData:CanEquipWangPeerless(index)
	self:GetEqBmLevelByEquipIndex(index)
end

function EquipmentData.GetXuelianEquipIndex(index)
	return index + EquipData.EquipIndex.PeerlessWeaponPos
end

function EquipmentData.GetXuelianIndex(index)
	return index - EquipData.EquipIndex.PeerlessWeaponPos
end

function EquipmentData:GetOneBmEquipInfo(slot)
	local index = EquipmentData.GetXuelianEquipIndex(slot)
	return EquipData.Instance:GetGridData(index)
end

-------- 血炼 end -------------


------------------- 附灵begin -------------------
function EquipmentData.GetSpiritSlotStrongAttrsCfg(equip_data)
	if nil == equip_data then
		return nil
	end
	
	local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	if nil == item_cfg then
		return nil
	end
	
	local equip_type = item_cfg.type
	
	if false == StoneData.IsStoneEquip(equip_type) then
		return nil
	end
	
	local zhuan = 0
	local prof_limit = 1
	for k, v in pairs(item_cfg.conds) do
		if v.cond == ItemData.UseCondition.ucMinCircle then
			zhuan = v.value
		end
		if v.cond == ItemData.UseCondition.ucJob then
			prof_limit = v.value
		end
	end
	
	local config = ConfigManager.Instance:GetServerConfig("equipSynthesis/SpiritSlotStrongAttrs/SpiritSlot" .. equip_type .. "StrongAttrsCfg")
	
	circle_index = zhuan - 4
	return config and config[1] [circle_index] and config[1] [circle_index] [equip_data.fuling_level] and config[1] [circle_index] [equip_data.fuling_level] [prof_limit]
end

function EquipmentData.GetFlConsumeCfgKey(equip_type)
	local key_name = "jewelryConsume"
	if ItemData.ItemType.itWeapon == equip_type then
		key_name = "weaponConsume"
	elseif ItemData.ItemType.itDress == equip_type then
		key_name = "clotheConsume"
	end
	
	return key_name
end

-- 附灵下级所需绑金
function EquipmentData.GetFulingConsumeMoney(cost_type, equip_type, circle_level, fuling_level)
	local money = 0
	
	local key_name = 1 == cost_type and "needJB" or "movecost"
	local cfg_key = EquipmentData.GetFlConsumeCfgKey(equip_type)
	local consume_cfg = SpiritSlotStrongCfg[cfg_key] [circle_level]
	if nil ~= consume_cfg and nil ~= consume_cfg[key_name] [fuling_level + 1] then
		money = consume_cfg[key_name] [fuling_level + 1]
	end
	
	return money
end

-- 附灵下级所需经验
function EquipmentData.GetFulingNextExp(equip_type, circle_level, fuling_level)
	if nil == circle_level or nil == fuling_level then
		return nil
	end
	
	local cfg_key = EquipmentData.GetFlConsumeCfgKey(equip_type)
	local consume_cfg = SpiritSlotStrongCfg[cfg_key] [circle_level]
	if nil ~= consume_cfg then
		return consume_cfg.needexp[fuling_level + 1]
	end
	
	return nil
end

-- 不同转数附灵材料经验
function EquipmentData.GetMateFulingExp(equip_type, circle_level)
	local cfg_key = EquipmentData.GetFlConsumeCfgKey(equip_type)
	return SpiritSlotStrongCfg[cfg_key] [circle_level] and SpiritSlotStrongCfg[cfg_key] [circle_level].Giveexp or 0
end

-- 获取附灵预览装备data
function EquipmentData.GetMateFulingPreviewData(main_data, mate_data)
	if nil == main_data or nil == mate_data then
		return nil
	end
	
	local mate_cfg = ItemData.Instance:GetItemConfig(mate_data.item_id)
	local main_cfg = ItemData.Instance:GetItemConfig(main_data.item_id)
	if nil == mate_cfg or nil == main_cfg then
		return nil
	end
	
	local main_level, main_zhuan = ItemData.GetItemLevel(main_data.item_id)
	local mate_level, mate_zhuan = ItemData.GetItemLevel(mate_data.item_id)
	
	local add_exp = EquipmentData.GetMateFulingExp(mate_cfg.type, mate_zhuan)
	local fl_level = main_data.fuling_level
	local fl_exp = main_data.fuling_exp + add_exp
	
	local add_exp_calc
	add_exp_calc = function(main_zhuan, fl_level, fl_exp)
		local next_level_exp = EquipmentData.GetFulingNextExp(main_cfg.type, main_zhuan, fl_level)
		if nil ~= next_level_exp then
			if 0 <=(fl_exp - next_level_exp) then
				return add_exp_calc(main_zhuan, fl_level + 1, fl_exp - next_level_exp)
			end
		end
		return fl_level, fl_exp
	end
	local preview_fl_level, preview_fl_exp = add_exp_calc(main_zhuan, fl_level, fl_exp)
	local preview_data = TableCopy(main_data)
	preview_data.fuling_level = preview_fl_level
	preview_data.fuling_exp = EquipmentData.IsFulingLevelMax(preview_data) and 0 or preview_fl_exp
	
	return preview_data
end

-- 获取装备附灵总经验
function EquipmentData.GetEqFulingAllExp(eq_data)
	local exp = 0
	if nil ~= eq_data then
		local eq_cfg = ItemData.Instance:GetItemConfig(eq_data.item_id)
		if nil ~= eq_cfg then
			local _, zhuan = ItemData.GetItemLevel(eq_data.item_id)
			local fuling_level = 0
			local get_fl_next_exp = EquipmentData.GetFulingNextExp
			for i = 0, eq_data.fuling_level - 1 do
				exp = exp + get_fl_next_exp(eq_cfg.type, zhuan, i)
			end
			exp = exp + eq_data.fuling_exp
		end
	end
	
	return exp
end

-- 装备附灵等级是否满级
function EquipmentData.IsFulingLevelMax(equip_data)
	if nil == equip_data then
		return false
	end
	
	local eq_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	local _, zhuan = ItemData.GetItemLevel(equip_data.item_id)
	
	if nil ~= eq_cfg then
		local next_level_exp = EquipmentData.GetFulingNextExp(eq_cfg.type, zhuan, equip_data.fuling_level)
		if nil == next_level_exp then
			return true
		end
	end
	
	return false
end

function EquipmentData.GetShiftFulingPreviewData(aim_data, shift_data)
	if nil == aim_data or nil == shift_data then
		return nil
	end
	
	local aim_cfg = ItemData.Instance:GetItemConfig(aim_data.item_id)
	local shift_cfg = ItemData.Instance:GetItemConfig(shift_data.item_id)
	if nil == aim_cfg or nil == shift_cfg then
		return nil
	end
	
	local _, aim_zhuan = ItemData.GetItemLevel(aim_data.item_id)
	local fl_level = 0
	local fl_exp = 0
	local shift_exp = EquipmentData.GetEqFulingAllExp(shift_data)
	local aim_exp = EquipmentData.GetEqFulingAllExp(aim_data)
	if aim_exp > shift_exp then		-- 转移经验取装备最高值
		fl_exp = aim_exp
	else
		fl_exp = shift_exp
	end
	
	local add_exp_calc
	add_exp_calc = function(aim_zhuan, fl_level, fl_exp)
		local next_level_exp = EquipmentData.GetFulingNextExp(aim_cfg.type, aim_zhuan, fl_level)
		if nil ~= next_level_exp then
			if 0 <=(fl_exp - next_level_exp) then
				return add_exp_calc(aim_zhuan, fl_level + 1, fl_exp - next_level_exp)
			end
		end
		return fl_level, fl_exp
	end
	local preview_fl_level, preview_fl_exp = add_exp_calc(aim_zhuan, fl_level, fl_exp)
	local preview_data = TableCopy(aim_data)
	preview_data.fuling_level = preview_fl_level
	preview_data.fuling_exp = EquipmentData.IsFulingLevelMax(preview_data) and 0 or preview_fl_exp
	
	return preview_data
end
------------------- 附灵 end -------------------


------- 神佑 Begin -------
function EquipmentData.GetGodSaveEquipIndex()
	return {
		EquipData.EquipIndex.Weapon,
		EquipData.EquipIndex.Dress,
		EquipData.EquipIndex.Helmet,
		EquipData.EquipIndex.Necklace,
		EquipData.EquipIndex.Bracelet,
		EquipData.EquipIndex.BraceletR,
		EquipData.EquipIndex.Ring,
		EquipData.EquipIndex.RingR,
		EquipData.EquipIndex.Girdle,
		EquipData.EquipIndex.Shoes,
		EquipData.EquipIndex.WeaponExtend,
		EquipData.EquipIndex.FashionDress,
		EquipData.EquipIndex.ElbowPads,
		EquipData.EquipIndex.Earring,
		EquipData.EquipIndex.HeartMirror,
		EquipData.EquipIndex.ShoulderPads,
		EquipData.EquipIndex.Kneecap,

		EquipData.EquipIndex.PeerlessWeaponPos,
		EquipData.EquipIndex.PeerlessDressPos,
		EquipData.EquipIndex.PeerlessHelmetPos,
		EquipData.EquipIndex.PeerlessNecklacePos,
		EquipData.EquipIndex.PeerlessBraceletPos,
		EquipData.EquipIndex.PeerlessBraceletPosR,
		EquipData.EquipIndex.PeerlessRingPos,
		EquipData.EquipIndex.PeerlessRingPosR,
		EquipData.EquipIndex.PeerlessGirdlePos,
		EquipData.EquipIndex.PeerlessShoesPos,
	}
end

local map_t = {
	[EquipData.EquipIndex.Weapon] = 0,
	[EquipData.EquipIndex.Dress] = 1,
	[EquipData.EquipIndex.Helmet] = 2,
	[EquipData.EquipIndex.Necklace] = 3,
	[EquipData.EquipIndex.Bracelet] = 5,
	[EquipData.EquipIndex.BraceletR] = 6,
	[EquipData.EquipIndex.Ring] = 7,
	[EquipData.EquipIndex.RingR] = 8,
	[EquipData.EquipIndex.Girdle] = 9,
	[EquipData.EquipIndex.Shoes] = 10,
	
	[EquipData.EquipIndex.FashionDress] = 13,
	[EquipData.EquipIndex.WeaponExtend] = 15,
	[EquipData.EquipIndex.Earring] = 22,
	[EquipData.EquipIndex.ShoulderPads] = 23,
	[EquipData.EquipIndex.ElbowPads] = 24,
	[EquipData.EquipIndex.Kneecap] = 25,
	[EquipData.EquipIndex.HeartMirror] = 26,

	[EquipData.EquipIndex.PeerlessWeaponPos] = 29,		
	[EquipData.EquipIndex.PeerlessDressPos] = 30,		
	[EquipData.EquipIndex.PeerlessHelmetPos] = 31,		
	[EquipData.EquipIndex.PeerlessNecklacePos] = 32,	
	[EquipData.EquipIndex.PeerlessBraceletPos] = 33,	
	[EquipData.EquipIndex.PeerlessBraceletPosR] = 34,	
	[EquipData.EquipIndex.PeerlessRingPos] = 35,		
	[EquipData.EquipIndex.PeerlessRingPosR] = 36,		
	[EquipData.EquipIndex.PeerlessGirdlePos] = 37,		
	[EquipData.EquipIndex.PeerlessShoesPos] = 38,		
}
function EquipmentData.EquipIndex2ConfigIndex(index)
	return map_t[index]
end

function EquipmentData.IsGodSaveEquip(equip_index)
	return IsInTable(equip_index, EquipmentData.GetGodSaveEquipIndex())
end

function EquipmentData.GetMaxElemInjectNum()
	return EquipGodBlessesCfg and EquipGodBlessesCfg.maxCount or 10
end

function EquipmentData.GetMaxElemLevel()
	return #EquipGodBlessesCfg.attr
end

function EquipmentData.GetElemUplvConsumeData(index, level)
	return EquipGodBlessesCfg.uplevelconsume[index] [level]
end

function EquipmentData.GetElemInjectConsumeData(slot, index, level)
	return EquipGodBlessesCfg.consume[slot] [index] [level], EquipGodBlessesCfg.ConsumeCoin
end

function EquipmentData.GetElemNumAndLevel(value)
	local num, level = 0, 0
	if value ~= nil then
		num = bit:_and(value, 15)					
		level = bit:_and(bit:_rshift(value, 4), 15)
	end
	return num, level
end

function EquipmentData.GetFormatElemText(data)
	local text = ""
	for i = 1, 5 do
		local color = "a6a6a6"
		if data[i].num > 0 then
			color = EquipmentData.GetElemColor(i)
		end
		if data[i].level > 0 then
			text = text .. string.format(Language.Equipment.GodSaveElement[i], color)
		end
	end
	return text
end

local elem_color = {
	"ffc800",
	"00ff00",
	"36c4ff",
	"ff0000",
	"ff7f00",
}
function EquipmentData.GetElemColor(slot)
	return elem_color[slot]
end

function EquipmentData.GetElemAttr(index, level)
	local text = ""
	local attr = EquipGodBlessesCfg.attr[level] and EquipGodBlessesCfg.attr[level][index]
	if attr then
		text = string.format(Language.Equipment.ElementAttrs[index], attr * 100)
	end
	return text
end


function EquipmentData.GetElemActiveEffectId(index)
	local effect_t = {1231, 1235, 1234, 1233, 1232,}
	return effect_t[index]
end

function EquipmentData:GetLastGodsaveLevel()
	return self.last_gadsave_level or 0
end

function EquipmentData:SetLastGodsaveLevel(level)
	self.last_gadsave_level = level
end

function EquipmentData.CanEquipGodsave(equip_data, elem_list)
	if equip_data then
		for k, v in pairs(elem_list or {}) do
			local equip_index = EquipData.Instance:GetEquipIndexByType(equip_data.type, equip_data.hand_pos)
			local index = EquipmentData.EquipIndex2ConfigIndex(equip_index)
			if EquipmentData.CanElemUpgrade(index, v.level) or EquipmentData.CanElemInject(k - 1, index, v.num) then
				return true
			end
		end
	end
	return false
end

function EquipmentData.CanElemUpgrade(index, level)
	if level < EquipmentData.GetMaxElemLevel() then
		local need = EquipmentData.GetElemUplvConsumeData(index, level + 1)
		local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		return gold >= need
	end
	return false
end

function EquipmentData.CanElemInject(slot, index, num)
	if num < EquipmentData.GetMaxElemInjectNum() then
		local cfg, need_coin = EquipmentData.GetElemInjectConsumeData(slot, index, num + 1)
		if cfg and cfg[1] then
			local count = BagData.Instance:GetItemNumInBagById(cfg[1].id)
			local coin = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
			return count >= cfg[1].count and coin >= need_coin
		end
	end
	return false
end

-------  神佑 End  -------
function EquipmentData:GetMaxValueByQualityAndtype(item_id, quality, type)
	local cfg = AppraisalCfg.CircleAttr[item_id] or {}
	local cur_cfg = cfg.Qualitys or {}
	local attr_cfg = cur_cfg[quality + 1] or {} --因为品质从0开始，但是数据从第一个开始，需要加1
	local attr = attr_cfg.attr or {}
	for k, v in pairs(attr) do
		if v.type == type then
			return v.max
		end
	end
	return 0 
end
