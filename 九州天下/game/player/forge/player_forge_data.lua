--------------------------------------------------------
--熔炉数据管理
--------------------------------------------------------
PlayerForgeData = PlayerForgeData or BaseClass()
local MAX_COLOR = 5
function PlayerForgeData:__init()
	if PlayerForgeData.Instance then
		print_error("[PlayerForgeData] Attemp to create a singleton twice !")
	end
	PlayerForgeData.Instance = self

	self.ronglu_cfg = nil
	self.is_check = true
	self.ronglu_info = {}

	self.forge_data_list = {}
	self.forge_exp = 0
	self.forge_list = {}
	self.forge_count = 0
	self.get_level_attr = ListToMap(self:GetLevelAttrCfg() or {}, "ronglu_level")
	self.get_exp_cfg = ListToMap(self:GetExpCfg() or {}, "item_id")
	RemindManager.Instance:Register(RemindName.PlayerForge, BindTool.Bind(self.GetForgeRemind, self))
end

function PlayerForgeData:__delete()
	PlayerForgeData.Instance = nil
	self.ronglu_cfg = nil
	RemindManager.Instance:UnRegister(RemindName.PlayerForge)
end

function PlayerForgeData:SetCheck(bool)
	self.is_check = bool
end

function PlayerForgeData:GetCheck()
	return self.is_check
end

function PlayerForgeData:GetRongluCfg()
	if nil == self.ronglu_cfg then
		self.ronglu_cfg = ConfigManager.Instance:GetAutoConfig("ronglu_config_auto")
	end
	return self.ronglu_cfg
end

-- 熔炉属性配置
function PlayerForgeData:GetLevelAttrCfg()
	return self:GetRongluCfg().ronglu_attr
end

-- 熔炉经验配置
function PlayerForgeData:GetExpCfg()
	return self:GetRongluCfg().ronglu_jingyan
end

-- 获取熔炉最高等级
function PlayerForgeData:GetRongluMaxLevel()
	return #self:GetLevelAttrCfg()
end

function PlayerForgeData:SetRongluInfo(info)
	self.ronglu_info = info
end

-- 获取熔炉信息
function PlayerForgeData:GetRongluInfo()
	return self.ronglu_info
end

function PlayerForgeData:GetIsMaxLevel()
	if self.ronglu_info.ronglu_level then
		return self.ronglu_info.ronglu_level >= self:GetRongluMaxLevel()
	end
	return false
end		

-- 根据等级获取属性配置
function PlayerForgeData:GetRongluAttrCfg(level)
	local attr_data = {}
	-- for k,v in pairs(self:GetLevelAttrCfg()) do
	-- 	if level == v.ronglu_level then
	-- 		attr_data = v
	-- 	end
	-- end

	if self.get_level_attr then
		attr_data = self.get_level_attr[level]
	end

	return attr_data
end

-- 是否是可熔炼物品
function PlayerForgeData:IsForgeItem(item_id)
	-- for k,v in pairs(self:GetExpCfg()) do
	-- 	if item_id == v.item_id then
	-- 		return true
	-- 	end
	-- end
	if nil ~= self.get_exp_cfg[item_id] then
		return true
	end
	return false
end

--清空熔炼列表
function PlayerForgeData:EmptyForgeList()
	self.forge_data_list = {}
end

-- 获取可熔炼物品列表
function PlayerForgeData:GetForgeItemDataList()
	self.forge_list = {}
	self.forge_count = 0
	local equip_list = self:GetForgeEquipList()
	for i = 1,8 do
		self.forge_list[i] = equip_list[i] or {}
		self.forge_list[i].item_index = i
		if equip_list[i] then
			self.forge_count = self.forge_count + 1
		end
	end
end

--获取可回收的装备列表
function PlayerForgeData:GetForgeEquipList()
	local data_list = {}
	local bg_data_list = ItemData.Instance:GetBagItemDataList()
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	for k , v in pairs(bg_data_list) do
		if v ~= nil then
			local is_add = true
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(v.item_id)

			if item_cfg ~= nil then 
				for k1,v1 in pairs(self.forge_data_list) do
					if v1.index == v.index and v1.item_id == v.item_id then
						is_add = false
					end
				end
				if item_cfg.color >= MAX_COLOR and v.is_bind == 0 then
					is_add = false
				end
				if (item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and item_cfg.recycltype == 6 and item_cfg.color <= MAX_COLOR and is_add and item_cfg.shield_button == 0) or v.item_id == self:GetRongliandanCfg() then
					if v.item_id == self:GetRongliandanCfg() or (item_cfg.limit_prof ~= gamevo.prof and item_cfg.limit_prof ~= 5) or not self.is_check then
						table.insert(data_list, v)
					else
						if v.item_id == self:GetRongliandanCfg() or (EquipData.Instance:GetEquipLegendFightPowerByData(v) <= gamevo.capability) and item_cfg.color < MAX_COLOR then
							table.insert(data_list, v)
						end
					end
				end
			end
			
		end
	end
	return data_list
end

--当前属性
function PlayerForgeData:GetForgeAttr(cfg)
	local attr = {}
	if cfg then
		attr.gongji = cfg.c_gongji
		attr.fangyu = cfg.c_fangyu
		attr.maxhp = cfg.c_maxhp
	end
	return attr
end

-- 熔炼丹id
function PlayerForgeData:GetRongliandanCfg()
	local rongliandan_cfg = self:GetRongluCfg().rongliandan_cfg
	if rongliandan_cfg then
		return rongliandan_cfg[1].rongliandan_id
	end
end

-- 获取当前熔炼装备列表
function PlayerForgeData:GetCurForgeEquipList()
	return self.forge_list, self.forge_count
end

function PlayerForgeData:SetItemListData(data)
	self.forge_list[data.item_index] = {}
end

function PlayerForgeData:GetForgeRemind()
	if self:GetForgeEquipList()[1] then
		return 1
	end
	return 0
end

function PlayerForgeData:CheckEquipRongLian(item_id)
	if not item_id then return false end
	local equip_list = self:GetForgeEquipList()
	for k,v in pairs(equip_list) do
		if v.item_id == item_id then
			return true
		end
	end
	return false
end