MarryEquipData = MarryEquipData or BaseClass()

QINGYUAN_EQUIP_REQ_TYPE =
	{
		SELF_EQUIP_INFO = 0,				-- 请求自己装备信息
		OTHER_EQUIP_INFO = 1,				-- 请求爱人装备信息
		ACTIVE_SUIT = 2,					-- 请求激活套装 param_1套装类型，param_2 套装槽，param_3 背包索引
		TAKE_OFF = 3,						-- 请求脱装备, param_1 装备索引
	}
function MarryEquipData:__init()
    if MarryEquipData.Instance then
        print_error("[MarryEquipData] Attemp to create a singleton twice !")
    end
    MarryEquipData.Instance = self

    self.cache_marry_equip_list = nil
    local marriage_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto")
    self.marry_level_cfg = ListToMap(marriage_cfg.marry_level_cfg, "level") or {}
    self.qingyuan_equip_handbook = ListToMapList(marriage_cfg.qingyuan_equip_handbook,"type") or {}
    self.marry_info = {
    	marry_level = 0,
		marry_level_exp = 0,
	}

	self.qingyuan_suit_flag = {}
	self.qy_equip_list = {}
	self.equip_cap_list = {}
	self.better_equip_t = {}

	self.lover_marry_info = {
		marry_level = 0,
		marry_level_exp = 0,
	}
	self.lover_qingyuan_suit_flag = {}
	self.lover_qy_equip_list = {}
	self.lover_equip_cap_list = {}
	RemindManager.Instance:Register(RemindName.MarryEquip, BindTool.Bind(self.GetMarryEquipRemind, self))
	RemindManager.Instance:Register(RemindName.MarrySuit, BindTool.Bind(self.GetMarrySuitRemind, self))
	RemindManager.Instance:Register(RemindName.MarryEquipRecyle, BindTool.Bind(self.GetMarryEquipRecyleRemind, self))
end

function MarryEquipData:__delete()
    MarryEquipData.Instance = nil
    RemindManager.Instance:UnRegister(RemindName.MarryEquip)
    RemindManager.Instance:UnRegister(RemindName.MarrySuit)
    RemindManager.Instance:UnRegister(RemindName.MarryEquipRecyle)
end

function MarryEquipData:ClearCacheQingYuanEquipList()
	self.cache_marry_equip_list = nil
	self.better_equip_t = {}
end

local function SortEquipList(a, b)
	local item_a_data = ItemData.Instance:GetItemConfig(a.item_id)
	local item_b_data = ItemData.Instance:GetItemConfig(b.item_id)

	if item_a_data == nil or item_b_data == nil then
		return false
	end

	if item_a_data.color ~= item_b_data.color then
		return item_a_data.color > item_b_data.color
	end
	return a.index < b.index
end

--从背包获取情缘装备列表
function MarryEquipData:GetAllQingYuanEquipList()
	if self.cache_marry_equip_list then
		return self.cache_marry_equip_list
	end
	self.cache_marry_equip_list = {}
	local bag_list = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and EquipData.IsMarryEqType(item_cfg.sub_type) then
			table.insert(self.cache_marry_equip_list, v)
		end
	end
	table.sort(self.cache_marry_equip_list, SortEquipList)
	return self.cache_marry_equip_list
end

function MarryEquipData.GetMarryEquipIndex(sub_type)
	if sub_type and sub_type >= GameEnum.E_TYPE_QINGYUAN_1 and sub_type <= GameEnum.E_TYPE_QINGYUAN_4 then
		return sub_type - GameEnum.E_TYPE_QINGYUAN_1
	end
	return -2
end

--设置结婚信息
function MarryEquipData:SetMarryInfo(info)
	self.marry_info.marry_level = info.marry_level
	self.marry_info.marry_level_exp = info.marry_level_exp
end

--获取结婚信息
function MarryEquipData:GetMarryInfo()
	return self.marry_info
end

--获取结婚信息
function MarryEquipData:GetLoverMarryInfo()
	return self.lover_marry_info
end


--获取结婚信息
function MarryEquipData:IsMaxMarryLevel()
	return self:GetMarryLevelCfg(self.marry_info.marry_level + 1) == nil
end

--情缘装备提醒
function MarryEquipData:GetMaxCapEquip(index)
	local equip = nil
	for k,v in pairs(self:GetAllQingYuanEquipList()) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and item_cfg.limit_level <= self.marry_info.marry_level
			and MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type) == index and self:IsBetterMarryEquip(v.item_id) then
			if equip then
				local better_equip_cfg = ItemData.Instance:GetItemConfig(equip.item_id)
				if better_equip_cfg == nil or CommonDataManager.GetCapability(item_cfg) > CommonDataManager.GetCapability(better_equip_cfg) then
					equip = v
				end
			else
				equip = v
			end
		end
	end
	return equip
end

--获取结婚信息
function MarryEquipData:IsBetterMarryEquip(item_id)
	if self.better_equip_t[item_id] ~= nil then
		return self.better_equip_t[item_id]
	end
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg.limit_sex ~= GameVoManager.Instance:GetMainRoleVo().sex then
		return false
	end
	local fight_power = CommonDataManager.GetCapability(item_cfg)
	local qy_dess_index = MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type)
	local dress_fight_power = self.equip_cap_list[qy_dess_index] or 0
	self.better_equip_t[item_id] = fight_power > dress_fight_power
	return fight_power > dress_fight_power
end

--设置结婚装备信息
function MarryEquipData:SetMarryEquipInfo(info)
	if info.is_self == 1 then
		self.marry_info.marry_level = info.marry_level
		self.marry_info.marry_level_exp = info.marry_level_exp
		self.qingyuan_suit_flag = info.qingyuan_suit_flag
		self.qy_equip_list = info.qy_equip_list
		self.equip_cap_list = {}
		for k,v in pairs(self.qy_equip_list) do
			if v.item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				self.equip_cap_list[k] = item_cfg and CommonDataManager.GetCapability(item_cfg) or 0
			else
				self.equip_cap_list[k] = 0
			end
		end
		self:ClearCacheQingYuanEquipList()
	else
		self.lover_marry_info.marry_level = info.marry_level
		self.lover_marry_info.marry_level_exp = info.marry_level_exp
		self.lover_qingyuan_suit_flag = info.qingyuan_suit_flag
		self.lover_qy_equip_list = info.qy_equip_list
		self.lover_equip_cap_list = {}
		if self.lover_qy_equip_list == nil or next(self.lover_qy_equip_list) == nil then return end
		
		for k,v in pairs(self.lover_qy_equip_list) do
			if v.item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				self.lover_equip_cap_list[k] = item_cfg and CommonDataManager.GetCapability(item_cfg) or 0
			else
				self.lover_equip_cap_list[k] = 0
			end
		end
	end
end

--设置结婚装备信息
function MarryEquipData:GetMarryEquipInfo()
	return self.qy_equip_list
end

--设置结婚装备信息
function MarryEquipData:GetLoverMarryEquipInfo()
	return self.lover_qy_equip_list
end

--设置结婚装备战力
function MarryEquipData:GetMarryEquipAllCap()
	local cap = 0
	for k,v in pairs(self.qy_equip_list) do
		if v.item_id > 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local eq_cap = item_cfg and CommonDataManager.GetCapability(item_cfg, nil, nil, true) or 0
			cap = cap + eq_cap
		end
	end
	local marry_level_cfg = self:GetMarryLevelCfg(self.marry_info.marry_level) or {}
	cap = cap + CommonDataManager.GetCapability(marry_level_cfg, nil, nil, true)

	for k,v in pairs(self.qingyuan_equip_handbook) do
		if self:GetMarrySuitActive(v.type, v.slot) then
			cap = cap + CommonDataManager.GetCapability(v, nil, nil, true)
		end
	end
	return cap
end

--设置结婚装备战力
function MarryEquipData:GetLoverMarryEquipAllCap()
	local cap = 0
	for k,v in pairs(self.lover_qy_equip_list) do
		if v.item_id > 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local eq_cap = item_cfg and CommonDataManager.GetCapability(item_cfg, nil, nil, true) or 0
			cap = cap + eq_cap
		end
	end
	local marry_level_cfg = self:GetMarryLevelCfg(self.lover_marry_info.marry_level) or {}
	cap = cap + CommonDataManager.GetCapability(marry_level_cfg, nil, nil, true)

	for k,v in pairs(self.qingyuan_equip_handbook) do
		if self:GetLoverMarrySuitActive(v.type, v.slot) then
			cap = cap + CommonDataManager.GetCapability(v, nil, nil, true)
		end
	end

	return cap
end

--套装是否激活
function MarryEquipData:GetMarrySuitActive(suit_type, slot)
	if self.qingyuan_suit_flag[suit_type] then
		return bit:_and(1, bit:_rshift(self.qingyuan_suit_flag[suit_type], slot)) > 0
	end
	return false
end

--套装是否激活
function MarryEquipData:GetLoverMarrySuitActive(suit_type, slot)
	if self.lover_qingyuan_suit_flag[suit_type] then
		return bit:_and(1, bit:_rshift(self.lover_qingyuan_suit_flag[suit_type], slot)) > 0
	end
	return false
end

--套装是否激活
function MarryEquipData:GetMarryLevelCfg(level)
	return self.marry_level_cfg[level]
end

--情缘装备提醒
function MarryEquipData:GetMarryEquipRemind()
	for k,v in pairs(self:GetAllQingYuanEquipList()) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and item_cfg.limit_level <= self.marry_info.marry_level and self:IsBetterMarryEquip(v.item_id) then
			return 1
		end
	end
	return 0
end

--情缘珍藏提醒
function MarryEquipData:GetMarrySuitRemind()
	for i = 0, #self:GetCurrentHandBook() do
		for j = 0, 3 do
			if self:CanBeUpGrade(i, j) then
				return 1
			end
		end
	end
	return 0
end

--情缘装备回收提醒
function MarryEquipData:GetMarryEquipRecyleRemind()
	local marry_info = self:GetMarryInfo()
	if marry_info == nil then
		return 0
	end
	local marry_level_cfg = self:GetMarryLevelCfg(marry_info.marry_level)
	local marry_level_n_cfg = self:GetMarryLevelCfg(marry_info.marry_level + 1)
	if marry_level_cfg == nil or marry_level_n_cfg == nil then
		return 0
	end

	for k,v in pairs(self:GetAllQingYuanEquipList()) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		-- and not self:IsBetterMarryEquip(v.item_id)
		if item_cfg and (item_cfg.limit_level <= self.marry_info.marry_level or item_cfg.limit_sex ~= GameVoManager.Instance:GetMainRoleVo().sex) then
			return 1
		end
	end
	return 0
end

function MarryEquipData:CanBeUpGrade(suit_type, slot)
	local is_active = self:GetMarrySuitActive(suit_type, slot)
	if is_active then
		return false
	end
	slot = slot + 1
	local data = self:GetCurrentHandBook()[suit_type][slot]

	local item_id = 0
	if GameVoManager.Instance:GetMainRoleVo().sex == 1 then
		item_id = data.man_item
	else
		item_id = data.woman_item
	end
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count <= 0 then
		return false
	end
	local equip_data = {}
	for k,v in pairs(self:GetMarryEquipInfo()) do
		if v.item_id <= 0 then
			return false
		end
		equip_data = ItemData.Instance:GetItemConfig(v.item_id)
		if equip_data.color < data.color_limit or equip_data.order < data.order_limit then
			return false
		end
	end
	return true
end

function MarryEquipData:IsSuitActive(suit_type)
	local data = {}
	local equip_data = {}
	for i = 1, 4 do
		data = self:GetCurrentHandBook()[suit_type][i]
		for k,v in pairs(self:GetMarryEquipInfo()) do
			if v.item_id <= 0 then
				return false
			end
			equip_data = ItemData.Instance:GetItemConfig(v.item_id)
			if equip_data.color < data.color_limit or equip_data.order < data.order_limit then
				return false
			end
		end
	end
	return true
end

function MarryEquipData:GetCurrentHandBook()
	return self.qingyuan_equip_handbook
end
