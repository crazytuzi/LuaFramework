DeitySuitData = DeitySuitData or BaseClass()

DeitySuitData.SHEN_EQUIP_NUM = 8						-- 神装部位数量

-------------------神装----------------------

function DeitySuitData:__init()
	if DeitySuitData.Instance then
		print_error("[DeitySuitData] 尝试创建第二个单例模式")
	end
	DeitySuitData.Instance = self

	self:InitShenData()

	RemindManager.Instance:Register(RemindName.ShenEquip, BindTool.Bind(self.GetShenEquipRemind, self))
end

function DeitySuitData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShenEquip)

	DeitySuitData.Instance = nil

	self:ShenDataDelete()
end

function DeitySuitData:InitShenData()
	self.level_cfg = ConfigManager.Instance:GetAutoConfig("shenzhuangcfg_auto").uplevel
	self.level_cfg_list = ListToMap(self.level_cfg, "index", "level")

	self.init_server_time = 0
	self.act_suit_id = 0
	self.part_list = {}
	for i = 0, DeitySuitData.SHEN_EQUIP_NUM do
		self.part_list[i] = {
			index = i, 
			level = 0,
			-- grade = 0,
			-- jinjie_bless_val = 0,
			-- szlevel = 0
		}
	end
	self.eh_effect = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE, BindTool.Bind1(self.OnFightEffectChange, self))
end

function DeitySuitData:ShenDataDelete()
	if self.eh_effect then
		GlobalEventSystem:UnBind(self.eh_effect)
		self.eh_effect = nil
	end
end

function DeitySuitData:GetShenzhuangCfg(index, level)
	if self.level_cfg_list[index] and self.level_cfg_list[index][level] then
		return self.level_cfg_list[index][level]
	end
end

function DeitySuitData:GetNextUpSpecialAttr(index, level, star_num)
	local cur_level_cfg = self:GetShenzhuangCfg(index, level)
	for i = 1, 999 do
		local level_cfg = self:GetShenzhuangCfg(index, level + i)
		if nil == level_cfg then
			break
		end
		local cur_value
		local dif
		if star_num < 4 then
			cur_value = nil ~= cur_level_cfg and cur_level_cfg["red_ratio_" .. star_num] or 0
			dif = level_cfg["red_ratio_" .. star_num] - cur_value
		else
			cur_value = nil ~= cur_level_cfg and cur_level_cfg["pink_ratio"] or 0
			dif = level_cfg["pink_ratio"] - cur_value
		end

		if dif > 0 then
			return dif, level + i
		end
	end
	return 0, 0
end

-- 激活套装id
function DeitySuitData:SetActSuitId(suit_id)
	self.act_suit_id = suit_id
end

function DeitySuitData:GetActSuitId()
	return self.act_suit_id
end

-- 部位等级
function DeitySuitData:SetPartList(part_list)
	self.part_list = part_list
end

function DeitySuitData:GetPartList()
	return self.part_list
end

function DeitySuitData:GetEquipData(index)
	return self.part_list[index]
end

function DeitySuitData:GetShenSuitCfg(suit_id, is_next)
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
function DeitySuitData:GetShenEquipTotalCapability(part_list, equip_list)
	local part_list = part_list or self.part_list
	local equip_list = equip_list or EquipData.Instance:GetDataList()

	local total_attribute = CommonStruct.Attribute()
	for k, v in pairs(part_list) do
		local cfg = self:GetShenzhuangCfg(v.index, v.level)
		local attribute = CommonDataManager.GetAttributteByClass(cfg)
		total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)

		if cfg and equip_list[k] and equip_list[k].item_id and equip_list[k].param and equip_list[k].param.xianpin_type_list then
			local star_num = #equip_list[k].param.xianpin_type_list
			if star_num > 0 and star_num <= 3 then
				local add_rate = cfg["red_ratio_" .. star_num] / 10000
				local item_cfg = ItemData.Instance:GetItemConfig(equip_list[k].item_id)
				local equip_base_attr = CommonDataManager.GetAttributteByClass(item_cfg)
				local add_attr = CommonDataManager.MulAttribute(equip_base_attr, add_rate)
				total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
			end
		end
	end

	return CommonDataManager.GetCapability(total_attribute), total_attribute
end

function DeitySuitData:GetIsShenProtectTime()
	return self.init_server_time > 0 and TimeCtrl.Instance:GetServerTime() < self.init_server_time
end

function DeitySuitData:OnFightEffectChange()
	local item_config = ItemData.Instance:GetItemConfig(24019) or {}
	local all_time = item_config.param1
	local role_effect_list = FightData.Instance:GetMainRoleShowEffect()
	for k,v in pairs(role_effect_list) do
		if v.client_effect_type == EFFECT_CLIENT_TYPE.ECT_SZ_PROTECT then
			self.init_server_time = math.floor(v.param_list[1] / 1000) + TimeCtrl.Instance:GetServerTime()
		end
	end
end

function DeitySuitData:GetInitServerTime()
	return self.init_server_time
end

function DeitySuitData:GetShenEquipRemind()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local flag = OpenFunData.Instance:CheckIsHide("shenzhuang")
	for k,v in pairs(self.part_list) do
		local cfg = self:GetShenzhuangCfg(k, v.level + 1)
		if nil ~= cfg then
			local num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
			if num >= cfg.stuff_num and flag then
				return 1
			end
		end
	end
	return 0
end

function DeitySuitData.ReplacePrefix(name)
	for k,v in pairs(Language.Common.QualityNameList) do
		local str, p = string.gsub(name, v, Language.Common.SpecialQuality)
		if p > 0 then
			return str
		end
	end
	return name
end


