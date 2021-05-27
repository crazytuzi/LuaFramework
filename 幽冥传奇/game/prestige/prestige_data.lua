PrestigeData = PrestigeData or BaseClass(BaseData)

function PrestigeData:__init()
	if PrestigeData.Instance then
		ErrorLog("[PrestigeData] Attemp to create a singleton twice !")
	end
	PrestigeData.Instance = self

	self.duihuan_list = {}
	self.cfg_list = self:InitZhanGuiConfig()
end

function PrestigeData:__delete()
	PrestigeData.Instance = nil
end

function PrestigeData:GetAllPrestigeCfg()--获取配置内所有数据
	if self.all_prestige_cfg == nil then
		self.all_prestige_cfg = PrestigeSysConfig
	end
	return self.all_prestige_cfg
end

function PrestigeData:GetPrestigeCfg()--获取威望配置数据
	if self.prestige_cfg == nil then
		self.prestige_cfg = PrestigeSysConfig.levelcfg
	end
	return self.prestige_cfg
end

function PrestigeData:GetNowPrestigeByTotalValue(value)--根据总威望值获取当前威望数据
	-- 未传入威望值时,获取当前角色的威望
	local prestige_total_value = value ~= nil and value or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PRESTIGE_VALUE)--总威望值
	local prestige_cfg_data = self:GetPrestigeCfg()--所有威望数据
	self.now_prestige_data = {}
	for k, v in pairs(prestige_cfg_data) do
		if prestige_total_value >= v.NeedTotalValue then
			self.now_prestige_data = v
			self.now_prestige_data.index = k
		end
	end
	return self.now_prestige_data
end

function PrestigeData:GetNowPrestigeAttributeByJob()--根据职业获取当前威望属性
	local now_prestige_data = self:GetNowPrestigeByTotalValue()
	local now_prestige_attribute = now_prestige_data.attr or {}
	local now_job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)--当前主角职业
	self.now_attribute_list = {}
	for k, v in pairs(now_prestige_attribute) do
		if v.job == now_job then
			table.insert(self.now_attribute_list, v)
		end
	end
	return self.now_attribute_list
end

function PrestigeData:GetNextPrestigeByTotalValue()--根据总威望值获取下阶威望数据
	local prestige_total_value = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PRESTIGE_VALUE)--总威望值
	local prestige_cfg_data = self:GetPrestigeCfg()--所有威望数据
	local length = table.getn(prestige_cfg_data)
	self.next_prestige_data = {}
	local index = 1
	for k, v in pairs(prestige_cfg_data) do
		if prestige_total_value >= v.NeedTotalValue then
			if k < length then
				index = k + 1
			end
		end
	end
	if index > length then
		index = length
	end
	self.next_prestige_data = prestige_cfg_data[index]
	return self.next_prestige_data
end

function PrestigeData:GetNextPrestigeAttributeByJob()--根据职业获取下阶威望属性
	local next_prestige_data = self:GetNextPrestigeByTotalValue()
	local next_prestige_attribute = next_prestige_data.attr or{}
	local now_job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)--当前主角职业
	self.next_attribute_list = {}
	for k, v in pairs(next_prestige_attribute) do
		if v.job == now_job then
			table.insert(self.next_attribute_list, v)
		end
	end
	return self.next_attribute_list
end 


function PrestigeData:GetAttrDataByItemId(virtual_item_id)
	local now_job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)--当前主角职
	local attribute_list = {}
	for k, v in pairs(PrestigeSysConfig.levelcfg) do
		if v.virtual_item_id == virtual_item_id then
			for k1, v1 in pairs(v.attr) do
				if v1.job == now_job then
					table.insert(attribute_list, v1)
				end
			end
		end
	end
	return attribute_list
end


function PrestigeData:InitZhanGuiConfig( ... )
	local cfg = PrestigeSysConfig.changecfg

	local data = {}
	for k, v in pairs(cfg) do
		local cur_data = {
			limit = 0,
			needCount = 0, 
			order = 0,
			had_times = 0,
			itemIdList = {},
			can_duihuan_count = 0,
			is_can_duihuan = 0,
			desc = "",
			award = {},
		}

		cur_data.limit = v.limit
		cur_data.needCount = v.needCount
		cur_data.order = v.order
		cur_data.itemIdList = v.itemIdList
		cur_data.desc = v.dest
		cur_data.award = v.award

		table.insert(data, cur_data)
	end
	return data
end

function PrestigeData:setDuiHuanCishu(protocol)
	self.duihuan_list[protocol.index] = {}
	if self.duihuan_list[protocol.index] then
		self.duihuan_list[protocol.index] = protocol.times
	end
	-- for k, v in pairs(self.cfg_list) do
	-- 	if v.order == protocol.index then
	-- 		v.had_times = protocol.times
	-- 		v.can_duihuan_count = self:GetIsCanDuiHuan(v.limit, v.had_times, v.itemIdList)
	-- 		v.is_can_duihuan = v.can_duihuan_count > 0 and 1 or 0
	-- 		break
	-- 	end
	-- end
	self:FlushCfgList()
	GlobalEventSystem:Fire(ZHANGUDUIHUANEVENT.RESULT)
end


function PrestigeData:setPrestigeTaskResult(protocol)
	self.duihuan_list = {}
	self.duihuan_list = protocol.duihuan_list
	self:FlushCfgList()
end

function PrestigeData:GetIsCanDuiHuan(limit, had_times, itemIdList)
	if ( (had_times or 0) >= (limit or 0)) then  return 0 end
	local num = 0 
	for k, v in pairs(itemIdList) do

		num = num +  BagData.Instance:GetItemNumInBagById(v, nil)
	end
	return num
end


function PrestigeData:FlushCfgList()
	-- for k, v in pairs(self.cfg_list) do
	-- 	v.had_times = self.duihuan_list[v.order]
	-- 	v.can_duihuan_count = self:GetIsCanDuiHuan(v.limit, v.had_times, v.itemIdList)
	-- 	v.is_can_duihuan = v.can_duihuan_count > 0 and 1 or 0
	-- end

	-- local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
	-- 	return function(c, d)
	-- 		if c.is_can_duihuan ~= d.is_can_duihuan then
	-- 			return c.is_can_duihuan > d.is_can_duihuan
	-- 		end
	-- 		return c.order < d.order
	-- 	end
	-- end
end


function PrestigeData:GetCfgList()
	for k, v in pairs(self.cfg_list) do
		v.had_times = self.duihuan_list[v.order] or 0
		v.can_duihuan_count = self:GetIsCanDuiHuan(v.limit, v.had_times, v.itemIdList)
		v.is_can_duihuan = v.can_duihuan_count > 0 and 1 or 0
	end

	local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
		return function(c, d)
			if c.is_can_duihuan ~= d.is_can_duihuan then
				return c.is_can_duihuan > d.is_can_duihuan
			end
			return c.order < d.order
		end
	end
	table.sort(self.cfg_list, sort_list())
	return self.cfg_list
end

function PrestigeData:GetCurVirtualItemIdByValue(value)

	local prestige_cfg_data = self:GetPrestigeCfg()--所有威望数据
	local length = table.getn(prestige_cfg_data)
	self.cur_prestige_data = {}
	for k, v in pairs(prestige_cfg_data) do
		if value >= v.NeedTotalValue then
			if k < length then
				self.cur_prestige_data = prestige_cfg_data[k]
			else
				self.cur_prestige_data = prestige_cfg_data[length]
			end
		end
	end
	return self.cur_prestige_data.virtual_item_id
end


function PrestigeData:GetCanDuiHuan()
	for k, v in pairs(self.cfg_list) do
		v.had_times = self.duihuan_list[v.order] or 0
		v.can_duihuan_count = self:GetIsCanDuiHuan(v.limit, v.had_times, v.itemIdList)
		if v.can_duihuan_count > 0 then
			return 1
		end
	end
	return 0
end