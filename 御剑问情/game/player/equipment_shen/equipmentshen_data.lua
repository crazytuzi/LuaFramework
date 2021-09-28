EquipmentShenData = EquipmentShenData or BaseClass()

EquipmentShenData.SHEN_EQUIP_NUM = 10						-- 神装部位数量

-------------------神装----------------------

function EquipmentShenData:__init()
	if EquipmentShenData.Instance then
		print_error("[EquipmentShenData] 尝试创建第二个单例模式")
	end
	EquipmentShenData.Instance = self

	self:InitShenData()

	RemindManager.Instance:Register(RemindName.ShenEquip, BindTool.Bind(self.GetShenEquipRemind, self))
end

function EquipmentShenData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShenEquip)

	EquipmentShenData.Instance = nil

	self:ShenDataDelete()
end

function EquipmentShenData:InitShenData()
	self.level_cfg = ConfigManager.Instance:GetAutoConfig("shenzhuangcfg_auto").uplevel
	self.level_cfg_list = ListToMap(self.level_cfg, "index", "level")

	self.init_server_time = 0
	self.act_suit_id = 0
	self.part_list = {}
	self.select_index = -1
	self.select_list = {}
	for i = 0, EquipmentShenData.SHEN_EQUIP_NUM - 1 do
		self.part_list[i] = {
			index = i,
			level = 0,
			-- grade = 0,
			-- jinjie_bless_val = 0,
			-- szlevel = 0
		}
	end
	self.eh_effect = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE, BindTool.Bind1(self.OnFightEffectChange, self))
	self:SetSelectList()
end

function EquipmentShenData:SetSelectList()
	local temp_list = ListToMap(self.level_cfg, "index")
	for k,v in pairs(temp_list) do
		self.select_list[v.stuff_id] = k
	end
end

function EquipmentShenData:ShenDataDelete()
	if self.eh_effect then
		GlobalEventSystem:UnBind(self.eh_effect)
		self.eh_effect = nil
	end
end

function EquipmentShenData:GetShenzhuangCfg(index, level)
	if self.level_cfg_list[index] and self.level_cfg_list[index][level] then
		return self.level_cfg_list[index][level]
	end
end

function EquipmentShenData:GetNextUpSpecialAttr(index, level, star_num)
	local cur_level_cfg = self:GetShenzhuangCfg(index, level)
	for i = 1, 999 do
		local level_cfg = self:GetShenzhuangCfg(index, level + i)
		if nil == level_cfg then
			break
		end
		local str = "red_ratio_" .. star_num
		if star_num > 3 then
			str = "pink_ratio"
		end
		local cur_value = nil ~= cur_level_cfg and cur_level_cfg[str] or 0
		local dif = level_cfg[str] - cur_value
		if dif > 0 then
			return dif, level + i
		end
	end
	return 0, 0
end

-- 激活套装id
function EquipmentShenData:SetActSuitId(suit_id)
	self.act_suit_id = suit_id
end

function EquipmentShenData:GetActSuitId()
	return self.act_suit_id
end

-- 部位等级
function EquipmentShenData:SetPartList(part_list)
	self.part_list = part_list
end

function EquipmentShenData:GetPartList()
	return self.part_list
end

function EquipmentShenData:GetEquipData(index)
	return self.part_list[index]
end

function EquipmentShenData:GetShenSuitCfg(suit_id, is_next)
	local suit_cfg = ConfigManager.Instance:GetAutoConfig("shenzhuangcfg_auto").suit
	if suit_id == 0 and is_next then return suit_cfg[1] end
	for i,v in ipairs(suit_cfg) do
		if v.suit_id == suit_id then
			if is_next then
				return suit_cfg[i + 1]
			else
				return v
			end
		end
	end
	return nil
end

-- 获取当前装备总战力（加套装加成）
function EquipmentShenData:GetShenEquipTotalCapability(part_list, equip_list)
	local part_list = part_list or self.part_list
	local equip_list = equip_list or EquipData.Instance:GetDataList()

	local total_attribute = CommonStruct.Attribute()
	for k, v in pairs(part_list) do
		local cfg = self:GetShenzhuangCfg(v.index, v.level)
		local attribute = CommonDataManager.GetAttributteByClass(cfg)
		total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)

		if cfg and equip_list[k] and equip_list[k].item_id and equip_list[k].param and equip_list[k].param.xianpin_type_list then
			local star_num = #equip_list[k].param.xianpin_type_list
			if star_num > 0 and star_num <= 4 then
				local str = "red_ratio_" .. star_num
				if star_num > 3 then
					str = "pink_ratio"
				end
				local add_rate = cfg[str] / 10000
				local item_cfg = ItemData.Instance:GetItemConfig(equip_list[k].item_id)
				local equip_base_attr = CommonDataManager.GetAttributteByClass(item_cfg)
				local add_attr = CommonDataManager.MulAttribute(equip_base_attr, add_rate)
				total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
			end
		end
	end

	return CommonDataManager.GetCapability(total_attribute), total_attribute
end

function EquipmentShenData:GetIsShenProtectTime()
	return self.init_server_time > 0 and TimeCtrl.Instance:GetServerTime() < self.init_server_time
end

function EquipmentShenData:OnFightEffectChange()
	local item_config = ItemData.Instance:GetItemConfig(24019) or {}
	local all_time = item_config.param1
	local role_effect_list = FightData.Instance:GetMainRoleShowEffect()
	for k,v in pairs(role_effect_list) do
		if v.client_effect_type == EFFECT_CLIENT_TYPE.ECT_SZ_PROTECT then
			self.init_server_time = math.floor(v.param_list[1] / 1000) + TimeCtrl.Instance:GetServerTime()
		end
	end
end

function EquipmentShenData:GetInitServerTime()
	return self.init_server_time
end

function EquipmentShenData:GetShenEquipRemind()
	for k,v in pairs(self.part_list) do
		local cfg = self:GetShenzhuangCfg(k, v.level + 1)
		if nil ~= cfg then
			local num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
			if num >= cfg.stuff_num then
				return 1
			end
		end
	end
	return 0
end

function EquipmentShenData.ReplacePrefix(name)
	for k,v in pairs(Language.Common.QualityNameList) do
		local str, p = string.gsub(name, v, Language.Common.SpecialQuality)
		if p > 0 then
			return str
		end
	end
	return name
end

function EquipmentShenData:SetSelectedIndex(item_id)
	if item_id == -1 then
		self.select_index = -1
		return
	end
	self.select_index = self.select_list[item_id]
end

function EquipmentShenData:GetSelectedIndex()
	return self.select_index
end
