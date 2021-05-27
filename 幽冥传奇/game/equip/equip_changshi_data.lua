EquipData = EquipData or BaseClass(BaseData)
----------------------------------------------------
-- 传世 begin
-- ItemSynthesisConfig-合成      HandedDownConfig-血炼升级消耗     HandedDownSlotLevelAttrs-血炼属性配置  
----------------------------------------------------

local defualt_cs_equip = {
	[EquipData.EquipSlot.itHandedDownWeaponPos] = 217,	-- 传世_武器
    [EquipData.EquipSlot.itHandedDownDressPos] = 218,	-- 传世_衣服
    [EquipData.EquipSlot.itHandedDownHelmetPos] = 220,	-- 传世_头盔
    [EquipData.EquipSlot.itHandedDownNecklacePos] = 221,	-- 传世_项链
    [EquipData.EquipSlot.itHandedDownLeftBraceletPos] = 222,	-- 传世_左手镯
    [EquipData.EquipSlot.itHandedDownRightBraceletPos] = 222,	-- 传世_右手镯
    [EquipData.EquipSlot.itHandedDownLeftRingPos] = 223,	-- 传世_左戒指
    [EquipData.EquipSlot.itHandedDownRightRingPos] = 223,	-- 传世_右戒指
    [EquipData.EquipSlot.itHandedDownGirdlePos] = 224,	-- 传世_腰带
    [EquipData.EquipSlot.itHandedDownShoesPos] = 225,	-- 传世_鞋子
}

EquipData.CHUANSHI_COMPOSE_CHANGE = "chuanshi_compose_change"
EquipData.CHUANSHI_DECOMPOSE_CHANGE = "chuanshi_decompose_change"

EquipData.CS_DECOMPOSE_CFG_IDX = 1	--分解配置索引

function EquipData:InitChuanShi()
	self.chuanshi_slot_list = {}
	for i = EquipData.EquipSlot.itHandedDownWeaponPos, EquipData.EquipSlot.itHandedDownEquipMaxPos do
		-- 传世专属位置信息 0 ~ 9(这里不是传世装备位置索引)
		self.chuanshi_slot_list[i] = {
			level = 0,
		}
	end

	self.chuanshi_level_show_cfg = {
		{value = 16, num = 0, img_res = ResPath.GetCommon("sun")},
		{value = 4, num = 0, img_res = ResPath.GetCommon("moon")},
		{value = 1, num = 0, img_res = ResPath.GetCommon("star")},
	}

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetChuanShiCanUpRemind, self), RemindName.ChuanShiCanUp)
end

-- 获取最好的传世
function EquipData:GetBestCSEquip(role_equip, slot)
	local best_eq = role_equip
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	if slot == EquipData.EquipSlot.itHandedDownRightBraceletPos  then
		slot = EquipData.EquipSlot.itHandedDownLeftBraceletPos
	end

	if slot == EquipData.EquipSlot.itHandedDownRightRingPos  then
		slot = EquipData.EquipSlot.itHandedDownLeftRingPos
	end

	local is_right_sex = function (id)
		if slot == EquipData.EquipSlot.itHandedDownDressPos then
			for k, v in pairs(ItemData.Instance:GetItemConfig(id).conds) do
				if v.cond == ItemData.UseCondition.ucGender then
					if v.value ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) then
						return false
					end
				end
			end
		end
		return true
	end

	for i,v in pairs(BagData.Instance:GetItemDataList()) do
		if self:GetEquipSlotByType(v.type) == slot and 
			is_right_sex(v.item_id) and
			ItemData.Instance:GetItemScoreByData(best_eq) < ItemData.Instance:GetItemScoreByData(v) then
			best_eq = v
		end
	end

	return best_eq ~= role_equip and best_eq or nil
end

function EquipData:GetCSCup()
	local total_car = 0

	for i = EquipData.EquipSlot.itHandedDownWeaponPos, EquipData.EquipSlot.itHandedDownShoesPos do
		local equip_data = EquipData.Instance:GetEquipDataBySolt(i)
		if equip_data then
			-- local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
		    total_car = total_car + CommonDataManager.GetAttrSetScore(self:GetChuanShiBaseAttr(i,true) or {}) 
		end
	end

    return total_car
end

function EquipData:SetChuanShiLevelList(list)
	for k, v in pairs(list) do
		self.chuanshi_slot_list[EquipData.ChuanShiEquipIndex(k)].level = v.level
	end
	self:DispatchEvent(EquipData.CHUANSHI_DATA_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ChuanShiCanUp)
end

function EquipData:SetChuanShiLevel(slot, level)
	local equip_slot = EquipData.ChuanShiEquipIndex(slot)
	if self.chuanshi_slot_list[equip_slot] then
		self.chuanshi_slot_list[equip_slot].level = level
		self:DispatchEvent(EquipData.CHUANSHI_DATA_CHANGE)
		RemindManager.Instance:DoRemindDelayTime(RemindName.ChuanShiCanUp)
	end
end

-- 只有默认装备（一阶）可通过材料合成
function EquipData:GetEquipComposeCfgBySolt(equip_slot)
	local cfg = ItemSynthesisConfig[ITEM_SYNTHESIS_TYPES.CHUANSHI]
	if nil == cfg then
		return
	end
	for i,v in ipairs(cfg.itemList) do
		if v.award[1].id == defualt_cs_equip[equip_slot] then
			return v, ITEM_SYNTHESIS_TYPES.CHUANSHI, i
		end
	end
end

function EquipData:GetEquipAttrBySolt(equip_slot)
	local equip_data = EquipData.Instance:GetEquipDataBySolt(equip_slot)
	local attrs = {}
	if nil == equip_data then
		attrs = ItemData.GetStaitcAttrs(ItemData.Instance:GetItemConfig(defualt_cs_equip[equip_slot]))
	else
		attrs = self:GetChuanShiBaseAttr(equip_slot,true)
	end
	return RoleData.FormatRoleAttrStr(attrs, nil, 0)
end

function EquipData:GetChuanShiInfo(equip_slot)
	return self.chuanshi_slot_list[equip_slot]
end

function EquipData.GetChuanShiLevelRich(level)
	level = level or 0
	local rich_content = ""
	for k, v in ipairs(EquipData.Instance.chuanshi_level_show_cfg) do
		local num = math.floor(level / v.value)
		for i = 1, num do
			rich_content = rich_content .. "{image;" .. v.img_res .. ";35,20}"
		end
		level = level - (num * v.value)
	end

	return rich_content
end

-- 传世激活配置
function EquipData.GetChuanShiActiveCfg(equip_slot)
	return EquipData.GetChuanShiGradeCfg(equip_slot, 0)
end

-- 传世装备特殊数据
function EquipData.GetChuanShiSpecialCfg(equip_slot, equip_id, prof)
	local special_cfg = ConfigManager.Instance:GetConfig("scripts/config/client/chuanshi_cfg")
	if special_cfg then
		prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		if special_cfg.chuanshi_equip_cfg[equip_slot] and special_cfg.chuanshi_equip_cfg[equip_slot][prof] then
			return special_cfg.chuanshi_equip_cfg[equip_slot][prof][equip_id]
		end
	end
end

function EquipData.GetChuanShiBaseAttrDef(prof)
	local special_cfg = ConfigManager.Instance:GetConfig("scripts/config/client/chuanshi_cfg")
	if special_cfg then
		prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		return special_cfg.base_attr_types[prof]
	end
end

function EquipData.ChuanshiBaseAttrFilter(attr_cfg)
	local def_cfg = EquipData.GetChuanShiBaseAttrDef()
	local map = {}
	for k, v in pairs(def_cfg) do
		map[v] = 1
	end
	local filter_cfg = {}
	for k, v in pairs(attr_cfg) do
		if map[v.type] then
			filter_cfg[#filter_cfg + 1] = v
		end
	end
	return filter_cfg
end

-- 传世进阶配置
function EquipData.GetChuanShiGradeCfg(equip_slot, equip_id, prof)
	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local advanced = HandedDownEquipConfig.advanced
	if advanced[equip_slot] and advanced[equip_slot][prof] then
		return advanced[equip_slot][prof][equip_id]
	end
end

-- 传世等级配置
function EquipData.GetChuanShiLevelCfg(equip_slot, level)
	local upLevel = HandedDownEquipConfig.upLevel
	if upLevel[equip_slot] then
		return upLevel[equip_slot][level]
	end
end

-- 传世等级属性配置
function EquipData.GetChuanShiLevelAttr(equip_slot, level, prof)
	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local slot_cfg = ConfigManager.Instance:GetServerConfig("item/itemEnhance/HandedDownSlotLevelAttrs/HandedDownSlot" .. equip_slot .. "LvAttrsCfg")
	slot_cfg = slot_cfg and slot_cfg[1]
	if slot_cfg and slot_cfg[prof] then
		return slot_cfg[prof][level]
	end
end

-- 获取传世装备的基础属性（带等级属性）
-- equip_slot 装备位置
-- add_level_attr 加上等级属性
function EquipData:GetChuanShiBaseAttr(equip_slot, add_level_attr)
	local equip = self:GetEquipDataBySolt(equip_slot)
	local attr = {}
	if equip then
		local item_cfg = ItemData.Instance:GetItemConfig(equip.item_id)
		attr = ItemData.GetStaitcAttrs(item_cfg)

		if add_level_attr then
			local cs_slot = EquipData.ChuanShiCfgIndex(equip_slot)
			local level_attr_cfg = EquipData.GetChuanShiLevelAttr(cs_slot, self:GetChuanShiInfo(equip_slot).level)
			if level_attr_cfg then
				attr = CommonDataManager.AddAttr(attr, level_attr_cfg)
			end
		end
	end
	return attr
end

-- 传世任意一个传世装备可提升
function EquipData:GetChuanShiCanUpRemind()
	for i = EquipData.EquipSlot.itHandedDownWeaponPos, EquipData.EquipSlot.itHandedDownEquipMaxPos do
		if self:GetChuanShiCanUp(i) > 0 then
			return 1
		end
	end
	return 0
end

-- 传世装备可操作
function EquipData:GetChuanShiCanUp(cs_slot)
	return (self:GetChuanShiCanUpLevel(cs_slot) + self:GetChuanShiCanUpGrade(cs_slot))
end

-- 传世装备是否可升级
function EquipData:GetChuanShiCanUpLevel(cs_slot)
	local equip = self:GetEquipDataBySolt(cs_slot)
	if nil == equip then
		return 0
	end

	local is_enough = false
	local cs_info = EquipData.Instance:GetChuanShiInfo(cs_slot)
	local level_cfg = EquipData.GetChuanShiLevelCfg(EquipData.ChuanShiCfgIndex(cs_slot), cs_info.level + 1)
	local is_enough = false
	if level_cfg then
		local consume_cfg = level_cfg.consume
		local need_item_id = consume_cfg[1].id
		local need_num = consume_cfg[1].count
		local bag_num = BagData.Instance:GetItemNumInBagById(need_item_id)
		is_enough = bag_num >= need_num
	end
	return is_enough and 1 or 0
end

-- 传世装备是否可进阶/激活
function EquipData:GetChuanShiCanUpGrade(cs_slot)
	local equip = self:GetEquipDataBySolt(cs_slot)
	local is_enough = false
	if nil == equip then
		local act_cfg = EquipData.GetChuanShiActiveCfg(EquipData.ChuanShiCfgIndex(cs_slot))
		if act_cfg then
			local consume_cfg = act_cfg.consume
			local need_item_id = consume_cfg[1].id
			local need_num = consume_cfg[1].count
			local bag_num = BagData.Instance:GetItemNumInBagById(need_item_id)
			is_enough = bag_num >= need_num
		end
	else
		local cur_grade_cfg = EquipData.GetChuanShiGradeCfg(EquipData.ChuanShiCfgIndex(cs_slot), equip.item_id)
		if cur_grade_cfg then
			local consume_cfg = cur_grade_cfg.consume
			local need_item_id = consume_cfg[1].id
			local need_num = consume_cfg[1].count
			local bag_num = BagData.Instance:GetItemNumInBagById(need_item_id)
			is_enough = bag_num >= need_num
		end
	end
	return is_enough and 1 or 0
end

-- 传世专属位置->传世装备位置
function EquipData.ChuanShiEquipIndex(cs_slot)
	return cs_slot + EquipData.EquipSlot.itHandedDownWeaponPos
end

-- 传世装备位置->传世专属位置
function EquipData.ChuanShiCfgIndex(slot)
	return slot - EquipData.EquipSlot.itHandedDownWeaponPos
end

------------------------
-- 分解

function EquipData:GetEquipDecomposeCfgById(id)
	local cfg = ItemSynthesisConfig[ITEM_SYNTHESIS_TYPES.CHUANSHI]
	if nil == cfg then
		return
	end
	for i,v in ipairs(cfg.itemList) do
		if v.consume[1].id == id then
			return v, ITEM_SYNTHESIS_TYPES.CHUANSHI, i
		end
	end
end


function EquipData:InputCsDecompose(data)
	if nil == self.cs_decompose_data then
		self.cs_decompose_data = {}
	end

	local cfg = EquipDecomposeConfig[EquipData.CS_DECOMPOSE_CFG_IDX]
	if nil == cfg then return end

	self.cs_decompose_data = {
		input_data = data,
		get_data = {item_id = cfg.itemList[data.item_id].award[1].id, right_top_num = cfg.itemList[data.item_id].award[1].count},
 	}

	self:DispatchEvent(EquipData.CHUANSHI_DECOMPOSE_CHANGE)
end

function EquipData:ClearCsDecomposeData()
	self.cs_decompose_data = nil
	self:DispatchEvent(EquipData.CHUANSHI_DECOMPOSE_CHANGE)
end

function EquipData:GetCsDecompose()
	return self.cs_decompose_data
end


------------------------
-- 合成升阶

function EquipData:GetEquipComposeCfgById(id)
	local cfg = ItemSynthesisConfig[ITEM_SYNTHESIS_TYPES.CHUANSHI]
	if nil == cfg then
		return
	end
	for i,v in ipairs(cfg.itemList) do
		if v.consume[1].id == id then
			return v, ITEM_SYNTHESIS_TYPES.CHUANSHI, i
		end
	end
end

function EquipData:ClearCsComposeData()
	self.cs_compose_data = nil
	self:DispatchEvent(EquipData.CHUANSHI_COMPOSE_CHANGE)
end

function EquipData:GetCsCompose()
	return self.cs_compose_data
end

function EquipData:InputCsCompose(data)
	if nil == self.cs_compose_data then
		local consum_cfg, synthesis_type, item_index = EquipData.Instance:GetEquipComposeCfgById(data.item_id)
		if nil == consum_cfg then return end
		self.cs_compose_data = {
			pre_data = {item_id = consum_cfg.award[1].id, num = consum_cfg.award[1].count, is_bind = consum_cfg.award[1].bind},
			consum_data = {},
			synthesis_type = synthesis_type,
			item_index = item_index,
	 	}
	end

	--Max
	if #self.cs_compose_data.consum_data > 3 then
		return false
	end

	for i,v in ipairs(self.cs_compose_data.consum_data) do
		if v.item_id ~= data.item_id then
			SysMsgCtrl.Instance:FloatingTopRightText("需投入同类型装备")
			return 
		end
		if v.series == data.series then
			SysMsgCtrl.Instance:FloatingTopRightText("不可重复投入")
			return
		end
	end
	self.cs_compose_data.consum_data[#self.cs_compose_data.consum_data + 1] = data

	self:DispatchEvent(EquipData.CHUANSHI_COMPOSE_CHANGE)
end

-- ui
local defualt_data = {
	title = "标题1",
	curr_txt = "{wordcolor;ff2828;text2}",
	next_txt = "{wordcolor;ff2828;text2}",
}

-- 装备的存储位置每一个表示什么
-- EquipData.EquipSlot = {
-- 	itHandedDownWeaponPos = 18,			-- 传世_武器  18
-- 	itHandedDownDressPos = 19,			-- 传世_衣服
-- 	itHandedDownHelmetPos = 20,			-- 传世_头盔
-- 	itHandedDownNecklacePos = 21,		-- 传世_项链
-- 	itHandedDownLeftBraceletPos = 22,	-- 传世_左手镯
-- 	itHandedDownRightBraceletPos = 23,	-- 传世_右手镯
-- 	itHandedDownLeftRingPos = 24,		-- 传世_左戒指
-- 	itHandedDownRightRingPos = 25,		-- 传世_右戒指
-- 	itHandedDownGirdlePos = 26,			-- 传世_腰带
-- 	itHandedDownShoesPos = 27,			-- 传世_鞋子
-- }

Language.ChuanShi = {}
Language.ChuanShi.BloodTip = [[
{wordcolor;%s;钢纹总等级: }{wordcolor;%s;%s/%s(%s)}
%s
]]
Language.ChuanShi.SuitTip = [[
{wordcolor;%s;%s阶传世套装: }{wordcolor;%s;%s/%s(%s):}
{wordcolor;%s;武器  }{wordcolor;%s;衣服  }{wordcolor;%s;头盔  }{wordcolor;%s;项链  }{wordcolor;%s;手镯  }
{wordcolor;%s;手镯  }{wordcolor;%s;戒指  }{wordcolor;%s;头盔  }{wordcolor;%s;腰带  }{wordcolor;%s;靴子  }
%s
]]
function EquipData:GetCsSuitTxt()
	local suitlevel = EquipData.Instance:GetChuanShiSuitLevel()
	suitlevel = suitlevel == 0 and 1 or suitlevel
	-- suitlevel = 4
	local is_c_active, c_num = EquipData.Instance:GetChuanSHiSuitData(suitlevel, 10)
	local is_n_active, n_num = EquipData.Instance:GetChuanSHiSuitData(suitlevel + 1, 10)

	local total_attrs = SuitPlusConfig[9].list[suitlevel]
	local next_attrs = SuitPlusConfig[9].list[suitlevel + 1]
	local normat_attrs, special_attr =  RoleData.Instance:GetSpecailAttr(total_attrs.attrs)
	local next_normat_attrs, next_special_attr =  RoleData.Instance:GetSpecailAttr(next_attrs and next_attrs.attrs or {})

	local active_color = COLORSTR.GREEN
	local un_active_color = COLORSTR.G_W2

	local eq_color = function (solt)
		local equip = EquipData.Instance:GetEquipDataBySolt(solt)
		local tip_color = "a6a6a6"
		if equip then
			local itemm_config = ItemData.Instance:GetItemConfig(equip.item_id)
			if itemm_config.suitId >= suitlevel then
				tip_color = "00ff00"
			end
		end
		return tip_color
	end

	local n_eq_color = function (solt)
		local equip = EquipData.Instance:GetEquipDataBySolt(solt)
		local tip_color = "a6a6a6"
		if equip then
			local itemm_config = ItemData.Instance:GetItemConfig(equip.item_id)
			if itemm_config.suitId >= suitlevel + 1 then
				tip_color = "00ff00"
			end
		end
		return tip_color
	end
	
	return {
		title = "传世套装属性",
		title_color = COLOR3B.ORANGE,
		curr_txt = string.format(Language.ChuanShi.SuitTip,
			COLORSTR.G_W2, suitlevel, is_c_active == 1 and COLORSTR.GREEN or COLORSTR.RED, c_num, 10, is_c_active == 1 and "已激活" or "未激活",
			eq_color(EquipData.EquipSlot.itHandedDownWeaponPos),  eq_color(EquipData.EquipSlot.itHandedDownDressPos), eq_color(EquipData.EquipSlot.itHandedDownHelmetPos), eq_color(EquipData.EquipSlot.itHandedDownNecklacePos),eq_color(EquipData.EquipSlot.itHandedDownLeftBraceletPos), 
			eq_color(EquipData.EquipSlot.itHandedDownRightBraceletPos), eq_color(EquipData.EquipSlot.itHandedDownLeftRingPos), eq_color(EquipData.EquipSlot.itHandedDownRightRingPos), eq_color(EquipData.EquipSlot.itHandedDownGirdlePos),eq_color(EquipData.EquipSlot.itHandedDownShoesPos), 
			RoleData.FormatAttrContent(normat_attrs) .. "\n" .. "{wordcolor;ff2828;" .. RoleData.FormatAttrContent(special_attr) ..":}"
		),
		next_txt = next_attrs and string.format(Language.ChuanShi.SuitTip,
			COLORSTR.G_W2, suitlevel + 1, is_n_active == 1 and COLORSTR.GREEN or COLORSTR.RED, n_num, 10, is_n_active == 1 and "已激活" or "未激活",
			n_eq_color(EquipData.EquipSlot.itHandedDownWeaponPos), n_eq_color(EquipData.EquipSlot.itHandedDownDressPos), n_eq_color(EquipData.EquipSlot.itHandedDownHelmetPos), n_eq_color(EquipData.EquipSlot.itHandedDownNecklacePos), n_eq_color(EquipData.EquipSlot.itHandedDownLeftBraceletPos), 
			n_eq_color(EquipData.EquipSlot.itHandedDownRightBraceletPos), n_eq_color(EquipData.EquipSlot.itHandedDownLeftRingPos), n_eq_color(EquipData.EquipSlot.itHandedDownRightRingPos), n_eq_color(EquipData.EquipSlot.itHandedDownGirdlePos), n_eq_color(EquipData.EquipSlot.itHandedDownShoesPos), 
			RoleData.FormatAttrContent(next_normat_attrs) .. "\n" .. "{wordcolor;ff2828;" .. RoleData.FormatAttrContent(next_special_attr) ..":}"
		) or "",
	}
end

function EquipData:GetCsBloodTxt()
	local lv = 0
	for k,v in pairs(self.chuanshi_slot_list) do
		lv = lv + v.level
	end
	
	-- lv = 280

	local curr_data = {}
	local next_data = {}
	local key = nil

	local show_lv = lv < 10 and 10 or lv
	for i,v in ipairs(BloodSlotPlusConfig[1]) do
		if show_lv >= v.level then
			curr_data.attrs = v.attrs
			curr_data.lv = v.level
			key = i + 1
		end
	end
	if BloodSlotPlusConfig[1][key] then
		next_data.attrs = BloodSlotPlusConfig[1][key].attrs
		next_data.lv = BloodSlotPlusConfig[1][key].level
		-- PrintTable(next_data.attrs, level)
	end

	local normat_attrs, special_attr = RoleData.Instance:GetSpecailAttr(curr_data.attrs)
	local next_normat_attrs, next_special_attr =  RoleData.Instance:GetSpecailAttr(next_data.attrs or {})

	return {
		title = "传世钢纹套装属性",
		title_color = COLOR3B.ORANGE,
		curr_txt = string.format(Language.ChuanShi.BloodTip,
			COLORSTR.G_W2, lv >= curr_data.lv and COLORSTR.GREEN or COLORSTR.RED, lv, curr_data.lv, lv >= curr_data.lv and "已激活" or "未激活",
			RoleData.FormatAttrContent(normat_attrs)
		),
		next_txt = next_data.attrs and string.format(Language.ChuanShi.BloodTip,
			COLORSTR.G_W2, lv >= next_data.lv and COLORSTR.GREEN or COLORSTR.RED, lv, next_data.lv, lv >= next_data.lv and "已激活" or "未激活",
			RoleData.FormatAttrContent(next_normat_attrs)
		) or "",
	}
end


----------------------------------------------------
-- 传世 end
----------------------------------------------------
