TulongEquipData = TulongEquipData or BaseClass()

TulongEquipData.EQUIP_MAX_PART = 10						-- 屠龙装备部位数量

TulongEquipData.OPERATE_TYPE =
	{
		NONE = 0,
		UP_COMMON_LEVEL = 1,			--普通装备升级
		UP_GREAT_LEVEL = 2,				--传世装备升级
	};
-------------------屠龙装备----------------------

function TulongEquipData:__init()
	if TulongEquipData.Instance then
		print_error("[TulongEquipData] 尝试创建第二个单例模式")
	end
	TulongEquipData.Instance = self

	self:InitShenData()

	RemindManager.Instance:Register(RemindName.TulongEquip, BindTool.Bind(self.GetShenEquipRemind, self))
	RemindManager.Instance:Register(RemindName.CSTulongEquip, BindTool.Bind(self.GetCSShenEquipRemind, self))
end

function TulongEquipData:__delete()
	RemindManager.Instance:UnRegister(RemindName.TulongEquip)
	RemindManager.Instance:UnRegister(RemindName.CSTulongEquip)

	TulongEquipData.Instance = nil
end

function TulongEquipData:InitShenData()
	self.level_cfg = ConfigManager.Instance:GetAutoConfig("combine_server_equip_cfg_auto").common_equip_uplevel
	self.level_cfg_list = ListToMap(self.level_cfg, "index", "level")

	self.cs_level_cfg = ConfigManager.Instance:GetAutoConfig("combine_server_equip_cfg_auto").great_equip_uplevel
	self.cs_level_cfg_list = ListToMap(self.cs_level_cfg, "index", "level")

	self.equip_icon_cfg = ConfigManager.Instance:GetAutoConfig("combine_server_equip_cfg_auto").equip_icon

	self.init_server_time = 0
	self.part_list = {}
	self.cs_part_list = {}
	for i = 0, TulongEquipData.EQUIP_MAX_PART - 1 do
		self.part_list[i] = {
			index = i,
			level = 0,
		}
		self.cs_part_list[i] = {
			index = i,
			level = 0,
		}
	end
end

function TulongEquipData:GetShenzhuangCfg(tab_index, index, level)
	if tab_index == 2 then
		return self:GetChuanshiCfg(index, level)
	else
		return self:GetTulongCfg(index, level)
	end
end

function TulongEquipData:GetTulongCfg(index, level)
	if self.level_cfg_list[index] and self.level_cfg_list[index][level] then
		return self.level_cfg_list[index][level]
	end
end

function TulongEquipData:GetChuanshiCfg(index, level)
	if self.cs_level_cfg_list[index] and self.cs_level_cfg_list[index][level] then
		return self.cs_level_cfg_list[index][level]
	end
end

function TulongEquipData:GetNextUpSpecialAttr(index, level, key)
	local cur_level_cfg = self:GetTulongCfg(index, level)
	for i = 1, 999 do
		local level_cfg = self:GetTulongCfg(index, level + i)
		if nil == level_cfg then
			break
		end

		local cur_value = nil ~= cur_level_cfg and cur_level_cfg[key] or 0
		local dif = level_cfg[key] - cur_value
		if dif > 0 then
			return dif, level + i
		end
	end
	return 0, 0
end

-- 部位等级
function TulongEquipData:SetPartList(part_list)
	self.part_list = part_list
end

-- 传世部位等级
function TulongEquipData:SetCSPartList(cs_part_list)
	self.cs_part_list = cs_part_list
end

function TulongEquipData:GetPartList(tab_index)
	if tab_index == 2 then
		return self:GetCSPartList()
	else
		return self:GetTLPartList()
	end
end

function TulongEquipData:GetTLPartList()
	return self.part_list
end

function TulongEquipData:GetCSPartList()
	return self.cs_part_list
end

function TulongEquipData:GetEquipData(tab_index, index)
	if tab_index == 2 then
		return self:GetCSEquipData(index)
	else
		return self:GetTLEquipData(index)
	end
end

function TulongEquipData:GetTLEquipData(index)
	return self.part_list[index]
end

function TulongEquipData:GetCSEquipData(index)
	return self.cs_part_list[index]
end

-- 获取当前装备总战力（加套装加成）
function TulongEquipData:GetTulongEquipIconRes(tab_index, index)
	local res_id = 0
	if tab_index == 2 then
		res_id = self.equip_icon_cfg[2]["equip_" ..index] or 0
	else
		res_id = self.equip_icon_cfg[1]["equip_" ..index] or 0
	end
	if res_id > 0 then
		return ResPath.GetItemIcon(res_id)
	end
	return "", ""
end

-- 获取当前装备总战力（加套装加成）
function TulongEquipData:GetShenEquipTotalCapability(tab_index, part_list, equip_list)
	if tab_index == 2 then
		return self:GetCSShenEquipTotalCapability(part_list, equip_list)
	else
		return self:GetTLShenEquipTotalCapability(part_list, equip_list)
	end
end

-- 获取当前装备总战力（加套装加成）
function TulongEquipData:GetTLShenEquipTotalCapability(part_list)
	local part_list = part_list or self.part_list

	local total_attribute = CommonStruct.Attribute()
	for k, v in pairs(part_list) do
		local cfg = self:GetTulongCfg(v.index, v.level)
		if cfg then
			local attribute = CommonDataManager.GetAttributteByClass(cfg)
			total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
			local extra_attr = CommonStruct.Attribute()
			extra_attr.max_hp = cfg.extra_maxhp
			extra_attr.gong_ji = cfg.extra_gongji
			extra_attr.fang_yu = cfg.extra_fangyu
			total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, extra_attr)
		end

	end

	return CommonDataManager.GetCapability(total_attribute), total_attribute
end

-- 获取当前装备总战力（加套装加成）
function TulongEquipData:GetCSShenEquipTotalCapability(part_list)
	local part_list = part_list or self.cs_part_list

	local total_attribute = CommonStruct.Attribute()
	for k, v in pairs(part_list) do
		local cfg = self:GetChuanshiCfg(v.index, v.level)
		if cfg then
			local attribute = CommonDataManager.GetAttributteByClass(cfg)
			total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
		end
	end

	return CommonDataManager.GetCapability(total_attribute), total_attribute
end

function TulongEquipData:GetShenEquipRemind()
	for k,v in pairs(self.part_list) do
		local cfg = self:GetTulongCfg(k, v.level + 1)
		if nil ~= cfg then
			local num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
			if num >= cfg.stuff_num then
				return 1
			end
		end
	end
	return 0
end

function TulongEquipData:GetCSShenEquipRemind()
	for k,v in pairs(self.cs_part_list) do
		local cfg = self:GetChuanshiCfg(k, v.level + 1)
		if nil ~= cfg then
			local num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
			if num >= cfg.stuff_num then
				return 1
			end
		end
	end
	return 0
end


