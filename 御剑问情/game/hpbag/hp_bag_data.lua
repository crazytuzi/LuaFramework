HpBagData = HpBagData or BaseClass()

function HpBagData:__init()
	if HpBagData.Instance ~= nil then
		print_error("[HpBagData] Attemp to create a singleton twice !")
	end
	HpBagData.Instance = self

	-- 服务器数据
	self.supply_list = {}
	self.supply_type_max = 0

	-- 配置表数据
	self.supply_item_list = ConfigManager.Instance:GetAutoConfig("supplyconfig_auto").supply_item_list
	self.supply_recover_value_list = ConfigManager.Instance:GetAutoConfig("supplyconfig_auto").supply_recover_value_list
	self.supply_interval = ConfigManager.Instance:GetAutoConfig("supplyconfig_auto").supply_interval
	self.other = ConfigManager.Instance:GetAutoConfig("supplyconfig_auto").other

	self.is_show_repdt = false

	RemindManager.Instance:Register(RemindName.HpBag, BindTool.Bind(self.GetRemind, self))
end

function HpBagData:__delete()
    RemindManager.Instance:UnRegister(RemindName.HpBag)

	HpBagData.Instance = nil
end

-- 服务器数据
function HpBagData:GetSupplyInfo(data)
	self.supply_list = data.supply_list
	self.supply_type_max = data.supply_type_max
end

function HpBagData:GetSupplySeverData()
	local data = {}
	for k,v in pairs(self.supply_list) do
		if k == 1 then
			table.insert(data,v)
		end
	end

	return data[1]
end

-- 获取配置表数据
-- 获取血包数据
function HpBagData:GetSupplyData()
	return self.supply_item_list
end

-- 获取脱离战斗回复速度倍数
function HpBagData:GetSupplyRate()
	return self.other[1].not_fight_rate
end

function HpBagData:GetPercent()
	return self.other[1].recover_per or 0
end

-- 获取每十秒恢复的血量通过等级
function HpBagData:GetRecoverHpByLevel(level)
	local data = {}
	for k,v in pairs(self.supply_recover_value_list) do
		if level == v.level then
			table.insert(data,v)
		end
	end

	return data[1]
end

function HpBagData:HpNumberChangeCallback(value)
	if value > 99999 and value <= 99999999 then
		value = value / 10000
		value = math.floor(value)
		value = value .. Language.Common.Wan
	elseif value > 99999999 then
		value = value / 100000000
		value = math.floor(value)
		value = value .. Language.Common.Yi
	end
	return value
end

-- 打开一次后设为false
function HpBagData:SetIsShowRepdt(value)
	self.is_show_repdt = value
end

--当等级大于130级，血量少于20%并且没有补给的时候提示
function HpBagData:GetRemind()
	if nil == self:GetSupplySeverData() then return 0 end
	local all_hp = self:GetSupplySeverData().supply_left_value
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_level = role_vo.level
	local limit_hp = role_vo.max_hp * 0.2
	if self.is_show_repdt and all_hp <= 0 and role_level >= COMMON_CONSTS.XIN_SHOU_LEVEL and limit_hp >= role_vo.hp then
		return 1
	end
	return 0
end