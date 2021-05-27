--------------------------------------------------------
-- 背包Data
--------------------------------------------------------
BagData = BagData or BaseClass()

--密码锁操作
LOCK_OP_ID =
{
	OP_UNLOCK = 1,			--临时解锁
	OP_LOCK = 2,			--恢复保护
	OP_SET_LOCK = 3,		--设置密锁
	OP_CHG_LOCK = 4,		--修改密锁
	OP_DEL_LOCK = 5,		--取消密锁
}

--密码锁状态
LOCKSTATEID =
{
	NOT_LOCKED = 0,	--未锁定
	UNLOCKED = 1,		--临时解锁
	LOCKED = 2,		--已锁定		
}

BagData.STORAGE_PAGE = 10
BagData.STORAGE_PAGE_COUNT = 30
BagData.RECYCLE_MAX_NUM = 16

BagData.BAG_ITEM_CHANGE = "bag_item_change"
BagData.BAG_EQUIP_CHANGE = "bag_equip_change"
BagData.STORAGE_LOCK_TYPE_CHANGE = "storage_lock_type_change"
BagData.STORAGE_ITEM_CHANGE = "storage_item_change"
BagData.RECYCLE_LIST_CHANGE = "recycle_list_change"
BagData.RECYCLE_SUCCESS = "recycle_success"
BagData.BAG_STONE_DATA_CHANGE = "bag_stone_data_change"
BagData.BAG_MELTING_CHESS_CHANGE = "bag_melting_change"
BagData.DURABILITY_CHANGE = "durability_change"
BagData.DECOME_SET_DATA = "DECOME_SET_DATA"

ITEM_CHANGE_TYPE = {-- 物品改变类型
	ADD = 1, 		-- 增加
	DEL = 2,		-- 删除
	CHANGE = 3,		-- 改变
	LIST = 4,		-- 多个
}

BagData.BagType =
{
	all = 1, 						--全部
	equip = 2,						--装备
	prop = 3,						--材料
	medicaments = 4,				--药品(其他)
}

function BagData:__init()
	if BagData.Instance then
		ErrorLog("[BagData] Attemp to create a singleton twice !")
	end	
	BagData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	-- 背包需管理的数据
	self.grid_data_series_list = {}					 --uid索引物品 背包所有物品

	self.item_id_by_series_list = {}				 --item_id索引uid 背包所有uid

	--背包分类数据
	self.bag_item_list = {
		[BagData.BagType.all] = {},				    --全部
		[BagData.BagType.equip] = {},				--装备
		[BagData.BagType.prop] = {},				--道具
		[BagData.BagType.medicaments] = {},			--药品(其他)
	} 
	--背包所有物品数据
	self.bag_item_count_list = {} 					-- 背包所有物品数量
	self.bag_item_type_list = {}					-- 背包所有物品类型列表

	--仓库数据
	self.storage_list = {}							--仓库物品
	self.storage_lock_type = 0						--仓库上锁类型

	--熔炼相关 缓存的数据 
	self.recycle_item_list = {}						--缓存的回收列表 每次打开回收面板时筛选一次 数据变化时更新
	self.select_item_list = {}						--可选择熔炼的装备列表 同上
	self.new_recycle_list = {} 						-- 新回收装备列表

	self.recyle_index = 1
	self.compose_data = {}
	self.type_show = {[1] = 1, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0}
	self.choice_item = nil

	self.collection_list = {
		[0] = {}, --按类型来 -共12个类型
		[1] = {},
		[2] = {},

		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
		[8] = {},
		[9] = {},
		[10] = {},
		[11] = {},
	} -- 星魂数据

	self.rexue_data_list = {}

	self.special_use_num = 0

	self.can_auto_use = false

	self.basis_select_count = 0
	self.basis_resolve_cfg = {}
	self:InitBasisResolveCfg()

	--===红点== ---- 
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindnameNum, self), RemindName.BagCompose)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindnameNum, self), RemindName.BagUseRemind)
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end


function BagData:__delete()
	BagData.Instance = nil

	self.grid_data_series_list = nil

	self.storage_list = nil

	self.recycle_item_list = nil

	self.bag_item_list = nil
	self.collection_list = nil
end

function BagData:GetBagGridNum()
	local buy_grid_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BAG_BUY_GRID_COUNT)
	local defualt_grid_num = BagConfig.default
	local vip_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	local vip_grid_num = vip_level > 0 and VipConfig.VipGrade[vip_level].bagAddGrid or 0
	
	return buy_grid_num + defualt_grid_num + vip_grid_num
end

-- 获取背包全部格子开放
function BagData:BagAllCell()
	local bag_num = BagConfig.default
	local index = VipConfig.VipGrade[#VipConfig.VipGrade].bagAddGrid
	
	return index + bag_num
end

function BagData:GetBagItemCount()
	local count = 0
	for i,v in pairs(self.grid_data_series_list) do
		count = count + 1
	end
	return count
end


function BagData:GetItemBagType(id)
	local bag_type_list = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.bag_type_list or {}
	local cfg = ItemData.Instance:GetItemConfig(id)
	if bag_type_list.zb_type_list and bag_type_list.zb_type_list[cfg.type] then
		return BagData.BagType.equip
	elseif bag_type_list.material_type_list and bag_type_list.material_type_list[cfg.type] then
		return BagData.BagType.prop
	else
		return BagData.BagType.medicaments
	end
end

-- 设置直接使用物品 接受技能列表后才开启
function BagData:SetAutoUse(bool)
	self.can_auto_use = bool
end

function BagData:BagShowChange(tag, data)
	local item_id = data.item_id or 0
	if self.can_auto_use and tag == "add" then
		-- 增加物品时,直接使用.
		if item_id == CLIENT_GAME_GLOBAL_CFG.GetUsetitle or GuideCtrl.Instance:IsNormalUseItem(item_id) then
			BagCtrl.Instance:SendUseItem(data.series, 0, data.num)
			if item_id == CLIENT_GAME_GLOBAL_CFG.GetUsetitle then
				TitleCtrl.SendTitleReq(8)
			end
		end
	end

	if nil == data then return end
	local bag_type = self:GetItemBagType(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)

	if tag == "add" then
		table.insert(self.bag_item_list[bag_type], data)

		if ItemData.GetIsConstellation(item_id) then
			table.insert(self.collection_list[item_cfg.stype], data)
		end
		if ItemData.IsRexue(item_cfg.type) then
			table.insert(self.rexue_data_list, data)
		end

		self.item_id_by_series_list[item_id] = self.item_id_by_series_list[item_id] or {}
		self.item_id_by_series_list[item_id][data.series] = data
	elseif tag == "change" then
		for i,v in ipairs(self.bag_item_list[bag_type]) do
			if v.series == data.series then
				self.bag_item_list[bag_type][i] = data
				break
			end
		end
		if ItemData.GetIsConstellation(item_id) then
			for i,v in ipairs(self.collection_list[item_cfg.stype]) do
				if v.series == data.series then
					self.collection_list[item_cfg.stype][i] = data
					break
				end
			end
		end
		if ItemData.IsRexue(item_cfg.type) then
			for i, v in ipairs(self.rexue_data_list) do
				if v.series == data.series then
					self.rexue_data_list[i] = data
					break
				end
			end
		end

	elseif tag == "delete" then
		for i,v in ipairs(self.bag_item_list[bag_type]) do
			if v.series == data.series then
				table.remove(self.bag_item_list[bag_type], i)
				break
			end
		end
		if ItemData.GetIsConstellation(item_id) then
			for i,v in ipairs(self.collection_list[item_cfg.stype]) do
				if v.series == data.series then
					table.remove(self.collection_list[item_cfg.stype], i)
					break
				end
			end
		end
		if ItemData.IsRexue(item_cfg.type) then
			for i, v in ipairs(self.rexue_data_list) do
				if v.series == data.series then
					table.remove(self.rexue_data_list,i)
					break
				end
			end
		end

		self.item_id_by_series_list[item_id] = self.item_id_by_series_list[item_id] or {}
		self.item_id_by_series_list[item_id][data.series] = nil
	end
end

-- 用item_id获取物品series列表
function BagData:GetSeriesByItemId(item_id)
	if item_id then
		return self.item_id_by_series_list[item_id] or {}
	else
		return self.item_id_by_series_list
	end
end

function BagData:GetBagItemDataListByBagType(bag_type)
	local tab_cfg = {}
	if bag_type == 1 then
		-- tab_cfg = DeepCopy(self.grid_data_series_list)
		local index = 1
		for k, v in pairs(self.grid_data_series_list) do
			tab_cfg[index] = v
			index = index + 1
		end
		table.sort(tab_cfg, function(a, b)
			if a.type < b.type then
				return true
			elseif a.type == b.type then
				if a.item_id < b.item_id then
					return true
				elseif a.item_id == b.item_id then
					if a.series < b.series then
						return true
					end
				end
			end
			return false
		end)
	else
		local index = 0
		for i, item in ipairs(self.bag_item_list[bag_type]) do
			tab_cfg[index] = item
			index = index + 1
		end
	end

	if not tab_cfg[0] and tab_cfg[1] then
		tab_cfg[0] = table.remove(tab_cfg, 1)
	end
	
	return tab_cfg
end

--背包战纹
function BagData:GetBagBattleLineList()
	return self.bag_item_type_list[ItemData.ItemType.itZhanwen] or {}
end

--整理整个背包
function BagData:SortAllBagList()
	for k,v in pairs(BagData.BagType) do
		self:SortBagList(v)
	end
end

function BagData:SortBagList(bag_type)
	if nil == self.bag_item_list[bag_type] then return end

	local get_level_priority = function (id)
		local item_cfg = ItemData.Instance:GetItemConfig(id)
		local zhuan = 0
		local limit_level = 0

		for k,v in pairs(item_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucLevel then
				limit_level = v.value
			end
			if v.cond == ItemData.UseCondition.ucMinCircle then
				zhuan = v.value
			end
		end
		return zhuan * 1000 + limit_level
	end

	if bag_type == BagData.BagType.equip then
		table.sort(self.bag_item_list[bag_type], function(a, b)
			local a_showQuality = ItemData.Instance:GetItemConfig(a.item_id).showQuality
			local b_showQuality = ItemData.Instance:GetItemConfig(b.item_id).showQuality
			if a_showQuality ~= b_showQuality then		--品质
				return a_showQuality > b_showQuality
			elseif a.type and a.type ~= b.type then		--类型大小
				return a.type < b.type
			elseif get_level_priority(a.item_id) ~= get_level_priority(b.item_id) then		--穿戴等级
				return get_level_priority(a.item_id) > get_level_priority(b.item_id)
			else
				return false
			end
		end)
	else
		table.sort(self.bag_item_list[bag_type], function(a, b)
			if a.type and a.type ~= b.type then		--类型大小
				return a.type < b.type
			elseif a.item_id ~= b.item_id then		--id大小
				return a.item_id > b.item_id
			elseif a.num ~= b.num then				--数量大小
				return a.num < b.num 				
			elseif a.is_bind ~= b.is_bind then 		--是否绑定
				return a.is_bind < b.is_bind
			else
				return false
			end
		end)
	end

	self:NoticeItemsChange{{change_type = ITEM_CHANGE_TYPE.LIST}}
end

function BagData:GetEmptyNum()
	return self:GetBagGridNum() - self:GetBagItemCount()
end

--获得背包里的物品数量 
-- @item_id:物品id @bind_type: nil 不区分 0非绑 1绑
function BagData:GetItemNumInBagById(item_id, bind_type)
	if ItemData.GetIsTransferStone(item_id) then
		return BagData.Instance:GetItemDurabilityInBagById(item_id) / 1000
	end
	local num = 0
	if bind_type == nil then
		num = self.bag_item_count_list[item_id] or 0
	else
		for k, v in pairs(self.grid_data_series_list) do
			if	v.item_id == item_id then
				if bind_type == nil then
					num = num + v.num
				elseif bind_type == v.is_bind then
					num = num + v.num
				end
			end
		end
	end
	return num
end

-- 获取消耗数量
function BagData.GetConsumesCount(item_id, item_type, bind_type)
	if nil == item_type or item_type == tagAwardType.qatEquipment then
		return BagData.Instance:GetItemNumInBagById(item_id, bind_type)
	else
		-- 获取虚拟物品对应的人物属性
		local attr_key = RoleData.RewardRypeAttrName[item_type] or -1
		return RoleData.Instance:GetAttr(attr_key) or 0
	end
end

-- 检查消耗数量是否充足
-- consumes的格式 {{id = 0, type = 0, count = 1}, ...}
function BagData.CheckConsumesCount(consumes)
	local bool = false
	if type(consumes) == "table" then
		bool = next(consumes) ~= nil
		for i, consume in ipairs(consumes) do
			local has_count = BagData.GetConsumesCount(consume.id, consume.type)
			local consume_count = consume.count
			bool = bool and type(consume_count) == "number" and has_count >= consume_count
		end
	end

	return bool
end

-- 逐次检查消耗数量是否充足
-- consumes_cfg 的格式 {{id = 0, type = 0, count = 1}, ...}
-- consumes_list = {item_id = count, ...} -- 物品消耗记录
-- virtual_consumes_list = {_type = count, ...} -- 虚拟物品消耗记录
function BagData.ContinueCheckConsumesCount(consumes_cfg, consumes_list, virtual_consumes_list)
	local can_upgrade = false
	consumes_list = consumes_list or {}
	virtual_consumes_list = virtual_consumes_list or {}

	if type(consumes_cfg) == "table"
	and type(consumes_list) == "table"
	and type(virtual_consumes_list) == "table"
	then
		can_upgrade = nil ~= next(consumes_cfg) -- 当前槽位是否可升级
		for i, consume in ipairs(consumes_cfg) do
			local item_id = consume.id or 1
			local _type = consume.type or 0
			local has_been_consume_count -- 本次一键升级已消耗的数量
			if _type == tagAwardType.qatEquipment then
				has_been_consume_count = consumes_list[item_id] or 0
			else
				has_been_consume_count = virtual_consumes_list[_type] or 0
			end
			local consume_count = BagData.GetConsumesCount(item_id, _type) -- 此方法有区分虚拟物品数量获取
			local cfg_consume_count = consume.count or 0
			if (consume_count - has_been_consume_count) < cfg_consume_count then
				can_upgrade = false
			end
		end
	end

	return can_upgrade
end

-- 逐次增加消耗数量
-- consumes_cfg 的格式 {{id = 0, type = 0, count = 1}, ...}
-- consumes_list = {item_id = count, ...} -- 物品消耗记录
-- virtual_consumes_list = {_type = count, ...} -- 虚拟物品消耗记录
function BagData.ContinueRecordConsumesCount(consumes_cfg, consumes_list, virtual_consumes_list)
	if type(consumes_cfg) == "table"
	and type(consumes_list) == "table"
	and type(virtual_consumes_list) == "table"
	then
		-- 记录已消耗数量
		for i, consume in ipairs(consumes_cfg) do
			local item_id = consume.id or 1
			local _type = consume.type or 0
			local cfg_consume_count = consume.count or 0
			if consume.type == tagAwardType.qatEquipment then
				local has_been_consume_count = consumes_list[item_id] or 0
				consumes_list[item_id] = has_been_consume_count + cfg_consume_count
			else
				local has_been_consume_count = virtual_consumes_list[_type] or 0
				virtual_consumes_list[_type] = has_been_consume_count + cfg_consume_count
			end
		end
	end
end

-- 以上两个接口的扩展操作
-- 单次检查消耗数量是否充足
-- consumes_list = {item_id = count, ...} -- 物品消耗记录
-- virtual_consumes_list = {_type = count, ...} -- 虚拟物品消耗记录
-- order = {{type = 1}, {item_id = 1}, ...} -- 多种物品提醒顺序 一般需要策划配
function BagData.OnceCheckConsumesCount(consumes_list, virtual_consumes_list, need_open_tip, order)
	local can_upgrade = false
	local list = need_open_tip and {item_id = {}, type = {}} or nil

	if type(consumes_list) == "table"
	and type(virtual_consumes_list) == "table"
	then
		can_upgrade = nil ~= next(consumes_list) or nil ~= next(virtual_consumes_list) -- 当前槽位是否可升级
		for item_id, count in pairs(consumes_list) do
			local consume_count = BagData.GetConsumesCount(item_id, 0) -- 此方法有区分虚拟物品数量获取
			if consume_count < count then
				can_upgrade = false
				if list then
					local item_id_list = list.item_id or {}
					item_id_list[item_id] = count - consume_count
					list.item_id = item_id_list
				end
			end
		end

		for _type, count in pairs(virtual_consumes_list) do
			local consume_count = BagData.GetConsumesCount(0, _type) -- 此方法有区分虚拟物品数量获取
			if consume_count < count then
				can_upgrade = false
				if list then
					local type_list = list.type or {}
					type_list[_type] = count - consume_count
					list.type = type_list
				end
			end
		end
	end

	local tip_data = nil
	if need_open_tip and (next(list.item_id) or next(list.type)) then
		if type(order) == "table" then
			for i, v in ipairs(order) do
				local item_id = v.item_id
				local _type = v.type
				if list.item_id[item_id] then
					tip_data = {id = item_id, type = 0, count = list.item_id[item_id]}
				elseif list.type[_type] then
					tip_data = {id = 0, type = _type, count = list.type[_type]}
				end

				if tip_data then
					break
				end
			end
		else
			local item_id = next(list.item_id)
			local _type = next(list.type)
			if list.item_id[item_id] then
				tip_data = {id = item_id, type = 0, count = list.item_id[item_id]}
			elseif list.type[_type] then
				tip_data = {id = 0, type = _type, count = list.type[_type]}
			end
		end

		local item_cfg = ItemData.InitItemDataByCfg(tip_data) or {}
		local item_id = item_cfg.item_id
		local num = item_cfg.num
		TipCtrl.Instance:OpenGetNewStuffTip(item_id, num)
	end

	return can_upgrade, list
end

-- 获取最大合成次数 (用于固定消耗的判断)
-- consumes_cfg 的格式 {{id = 0, type = 0, count = 1}, ...}
-- upper_limit 单次合成上限,限制返回的 max_num 最大为upper_limit
function BagData:GetNumByCompose(consumes_cfg, upper_limit)
	local max_num = upper_limit or COMMON_CONSTS.MAX_LOOPS

	local consumes_list, virtual_consumes_list = {}, {}
	BagData.ContinueRecordConsumesCount(consumes_cfg, consumes_list, virtual_consumes_list)
	for item_id, count in pairs(consumes_list) do
		local consume_count = BagData.GetConsumesCount(item_id, 0) -- 此方法有区分虚拟物品数量获取
		local cur_max_num = math.floor(consume_count / count)
		if consume_count > count then
			max_num = cur_max_num < max_num and cur_max_num or max_num
		else
			max_num = 0
		end
	end

	for _type, count in pairs(virtual_consumes_list) do
		local consume_count = BagData.GetConsumesCount(0, _type) -- 此方法有区分虚拟物品数量获取
		local cur_max_num = math.floor(consume_count / count)
		if consume_count > count then
			max_num = cur_max_num < max_num and cur_max_num or max_num
		else
			max_num = 0
		end
	end

	max_num = math.max(max_num, 1) -- 最小为1

	return max_num
end

--获得背包里的物品耐久
function BagData:GetItemDurabilityInBagById(item_id, bind_type)
	local durability = 0
	if item_id ~= nil then
		for series, item in pairs(self:GetSeriesByItemId(item_id)) do
			if bind_type == nil then
				durability = durability + item.durability
			elseif bind_type == item.is_bind then
				durability = durability + item.durability
			end
		end
	end

	return durability
end

--获得背包格子里的物品数量
function BagData:GetItemNumInBagByIndex(index, item_id)
	local data = self:GetGridData(index)
	if data then
		if item_id then
			if data.item_id == item_id then
				return data.num
			end
		else
			return data.num
		end
	end
	return 0
end

-- 获取背包物品类型中 评分最高的 
function BagData:GetBestEqByType(item_type, data)
	if nil == self.bag_item_type_list[item_type] then return end
	local best_data = data
	for i,v in pairs(self.bag_item_type_list[item_type]) do
		local last_score = best_data and ItemData.Instance:GetItemScore(ItemData.Instance:GetItemConfig(best_data.item_id)) or -1
		local score = ItemData.Instance:GetItemScore(ItemData.Instance:GetItemConfig(v.item_id))
		if score > last_score then
			best_data = v
		end
	end
	return best_data ~= data and best_data or nil
end

function BagData:GetBagItemDataListByType(item_type)
	return self.bag_item_type_list[item_type] or {}
end

-- 获得背包里的所有物品
function BagData:GetItemDataList(item_type)
	if item_type then
		return self.bag_item_type_list[item_type] or {}
	else
		return self.grid_data_series_list
	end
end

function BagData:GetOneItemBySeries(series)
	return self.grid_data_series_list[series]
end

--获得背包里的物品数据
function BagData:GetItemInBagBySeries(series)
	return self.grid_data_series_list[series]
end

function BagData:GetDataListSeries()
	return self.grid_data_series_list
end

--根据序列号获得背包里的物品数量
function BagData:GetItemNumInBagBySeries(series)
	local item = self.grid_data_series_list[series]
	return item and item.num or 0
end

-- 获取背包所有翅膀装备（根据装备位置）
function BagData:GetWingEquipData(type)
	local data = {}
	local bag_data = self:GetDataListSeries()
	for k, v in pairs(bag_data) do
		local index = WingData.Instance:GetWingIndex(v.item_id)
		if index and (type == index - 11) then
			table.insert(data, v)
		end
	end
	-- return data
	local item = {}
	if #data > 0 then 
		local o_index = 0
		for k1, v1 in pairs(data) do
			local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
			local item_cfg = ItemData.Instance:GetItemConfig(v1.item_id)
			local is_circle = circle >= item_cfg.conds[1].value
			if is_circle then
			 	local n_index = ItemData.Instance:GetItemScoreByData(v1)
			 	if n_index > o_index then
			 		item = v1
			 	end
			 	o_index = n_index
			end
		end 
	end
	return item
end

--获得背包里的序列号
function BagData:GetItemSeriesInBagById(id)
	for k, v in pairs(self.grid_data_series_list) do
		if v.item_id == id then
			return v.series
		end
	end
	return nil
end

--根据物品id获得在背包中的index
function BagData:GetItemIndex(item_id)
	for k, v in pairs(self.grid_data_series_list) do
		if v.item_id == item_id and v.index < COMMON_CONSTS.MAX_BAG_COUNT then
			return v.index
		end
	end
	return - 1
end

--根据物品id获得在背包中的物品
function BagData:GetOneItem(item_id)
	local item_list = self:GetSeriesByItemId(item_id) or {}
	local series, item = next(item_list)

	return item
end

--根据物品id获得在背包中物品（如果同个物品出现在多个格子只能拿到第一个）
function BagData:GetItem(item_id)
	local item = self:GetOneItem(item_id)
	
	return item
end

-- 背包里是否有某个物品
function BagData:GetHasItemInBag(item_id)
	local num = self:GetItemNumInBagById(item_id)
	if num >= 0 then
		return true
	else
		return false
	end
end

--获取背包所有装备
function BagData:GetBagEquipList()
	local equip_list = {}
	for k, v in pairs(self.grid_data_series_list) do
		if ItemData.GetIsEquip(v.item_id) then
			table.insert(equip_list, v)
		end
	end
	return equip_list
end

--获取背包所有星魂
function BagData:GetBagConstellationList(type)
	
	return self.collection_list[type] or {}
end

--获取背包所有星魂和星魂石头
function BagData:GetBagConstellationAndStoneList()
	local constellation_list = {}
	local n = 0
	for k, v in pairs(self.grid_data_series_list) do
		if ItemData.GetIsConstellation(v.item_id) or 866 == v.item_id then
			local item_config1 = ItemData.Instance:GetItemConfig(v.item_id)
			v.is_put_in = 0
			-- if item_config1.quality == 1 or item_config1.quality == 2 then
			-- 	v.is_put_in = 1
			-- end 
			table.insert(constellation_list, v)
			n = n + 1
		end
	end
	
	local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
		return function(c, d)
			local item_config1 = ItemData.Instance:GetItemConfig(c.item_id)
			local item_config2 = ItemData.Instance:GetItemConfig(d.item_id)
			if item_config1.quality ~= item_config2.quality then
				if item_config1.quality == nil then
					return true
				elseif item_config2.quality == nil then
					return false
				else
					return  item_config1.quality < item_config2.quality
				end
			else
				if c.item_id ~= d.item_id then
					return c.item_id < d.item_id
				else
					return c.num >d.num
				end
			end
			return item_config1.quality < item_config2.quality
		end
	end
	if n >=2 then
		table.sort(constellation_list,sort_list())
	end
	if not constellation_list[0] and constellation_list[1] then
		constellation_list[0] = table.remove(constellation_list, 1)
	end
	
	return constellation_list
end


--获取背包所有手套
function BagData:GetBagHandList()
	local t = {}
	for k, v in pairs(self.grid_data_series_list) do
		if ItemData.GetIHandEquip(v.item_id) then
			table.insert(t, v)
		end
	end
	return t
end

--获取背包手套材料
function BagData:GetBagHandItemList()
	local t = {}
	for k, v in pairs(self.grid_data_series_list) do
		if MeiBaShouTaoData.Instance:GetIsConsumeItem(v.item_id) then
			table.insert(t, v)
		end
	end
	if not t[0] and t[1] then
		t[0] = table.remove(t, 1)
	end
	return t
end

--获取背包所有传世
function BagData:GetBagHandedDownList()
	local t = {}
	for k, v in pairs(self.grid_data_series_list) do
		if ItemData.GetIsHandedDown(v.item_id) then
			table.insert(t, v)
		end
	end
	if not t[0] and t[1] then
		t[0] = table.remove(t, 1)
	end
	return t
end

function BagData:GetBagEquipAndFuwenList()
	local equip_fuwen_list = {}
	for k, v in pairs(self.grid_data_series_list) do
		if ItemData.GetIsEquip(v.item_id) or ItemData.GetIsFuwen(v.item_id) then
			table.insert(equip_fuwen_list, v)
		end
	end
	return equip_fuwen_list
end

function BagData:CheckUseItemEff(change_type, series, old_num, new_num)
	if ItemData.USE_ITEM_EFF_CACHE and ItemData.USE_ITEM_EFF_CACHE.series == series
	and(change_type == ITEM_CHANGE_TYPE.DEL or(change_type == ITEM_CHANGE_TYPE.CHANGE and new_num < old_num)) then
		local item_cfg = ItemData.USE_ITEM_EFF_CACHE.item_cfg
		local fly_node = ItemData.GetViewNameByFlyType(item_cfg.flyType)
		if fly_node then
			BagCtrl.Instance:StartFlyEff(fly_node)
		end
	end
end

-- 获取是否有可快速使用的物品
-- function BagData:GetIsHasQuickUseItem()
-- 	local item_cfg = nil
-- 	for k, v in pairs(self.grid_data_series_list) do
-- 		item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
-- 		if nil ~= item_cfg and 1 == item_cfg.choose_use then
-- 			return true
-- 		end
-- 	end
	
-- 	return false
-- end

-- 获取下一个存满的经验珠
function BagData:GetNextFullExpBall()
	if not  self:GetCanUseJiYanZhu() then
		return false
	end

	for k, v in pairs(self.grid_data_series_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if ItemData.IsJinYanZhuUseItemType(item_cfg.type) and tonumber(v.durability) >= tonumber(v.durability_max) then
			return v
		end
	end
	return nil
end

-- -- 获取下一个存满的内功珠
-- function BagData:GetNextFullNGBall()
-- 	local item_cfg = nil
-- 	for k, v in pairs(self.grid_data_series_list) do
-- 		item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
-- 		if nil ~= v and v.item_id == ItemConvertExpCfg.InnerBeadCfg.itemid
-- 			and nil ~= item_cfg and tonumber(v.durability) >= tonumber(item_cfg.dura) then
-- 			return v
-- 		end
-- 	end
-- 	return nil
-- end

function BagData:GetMaxEquipByIndex(index)
	local score = 0
	local data = nil
	local equip_data = EquipData.Instance:GetGridData(index)
	local equip_type = EquipData.GetEquipTypeByIndex(index)
	if equip_data then
		local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
		if item_cfg then
			score = ItemData.Instance:GetItemScore(item_cfg)
		end
	end
	for k, v in pairs(self.grid_data_series_list) do
		if v.type == equip_type then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local new_score = ItemData.Instance:GetItemScore(item_cfg)
			if item_cfg and not EquipData.CheckHasLimit(item_cfg) and score < new_score then
				if index >= EquipData.EquipIndex.PeerlessBeginIndex and index <= EquipData.EquipIndex.PeerlessEndIndex
				and EquipmentData.IsWangPeerless(v.item_id) then
					if EquipmentData.Instance:GetEqBmLevelByEquipIndex(index) >= 10 then
						score = new_score
						data = v
					end
				else
					score = new_score
					data = v
				end
			end
		end
	end
	return data
end

function BagData:GetMaxShenyuByIndex(shenyu_index)
	local score = 0
	local data = nil
	local old_car_list =  WingShenyuData.Instance:GetCarList()
	score = old_car_list[shenyu_index]
	for k, v in pairs(self.grid_data_series_list) do
		if v.type == shenyu_index + 136 then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local new_score = ItemData.Instance:GetItemScore(item_cfg)
			if old_car_list[shenyu_index] == nil or score < new_score then
				score = new_score
				data = v
			end
		end
	end
	return data
end

function BagData:GetMaxShenyuEquipList()
	local data = {}
	local index = 1
	for k, v in pairs(self.grid_data_series_list) do
		if v.type == 136 or v.type == 137 or v.type == 138 or v.type == 139 then
			table.insert(data, v )
			data.index = index
			index = index + 1
		end
	end
	return data
end

function BagData:GetFeatherListByType(feather_type)
	local data = {}
	local count = 0
	local index = 1
	for k, v in pairs(self.grid_data_series_list) do
		if v.type == feather_type then
			
			-- table.insert(data, v )
			-- data.index = index
			-- index = index + 1
		end
	end
	return data
end

function BagData:GetPropRemindNum()
	  for k,v in pairs (self.bag_item_list[BagData.BagType.prop]) do
    	local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		-- local remind = item_cfg and not EquipData.CheckHasLimit(item_cfg) and (item_cfg.type == 102 or item_cfg.type == 103 or item_cfg.type == 104)
		-- 	and not CLIENT_GAME_GLOBAL_CFG.ignore_remind_items[item_cfg.item_id] and ItemData.GetIsTransferStone(item_cfg.item_id)
		local remind = item_cfg and (item_cfg.type == 102 or item_cfg.type == 144) and not CLIENT_GAME_GLOBAL_CFG.ignore_remind_items[item_cfg.item_id]
		if remind then
			return true
		end
    end
    return false
end

function BagData:GetZWRemindNum()
	for k,v in pairs (self.bag_item_list[BagData.BagType.battle_lines]) do
    	local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		local remind = item_cfg and not EquipData.CheckHasLimit(item_cfg) and (item_cfg.type == 102 or item_cfg.type == 103 or item_cfg.type == 104)
			and not CLIENT_GAME_GLOBAL_CFG.ignore_remind_items[item_cfg.item_id] and ItemData.GetIsTransferStone(item_cfg.item_id)
		if remind then
			return true
		end
    end
    return false
end

function BagData:GetRemindNum()
	self.get_remind_array = self.get_remind_array or {}
	self.get_remind_array[BagData.BagType.all] = self:GetPropRemindNum()
  	self.get_remind_array[BagData.BagType.prop] = self:GetPropRemindNum()
  	-- self.get_remind_array[BagData.BagType.battle_lines] = self:GetZWRemindNum()
  	for k,v in pairs (self.get_remind_array) do
  		if v then
  			return self.get_remind_array ,true
  		end
 	end 	
    return self.get_remind_array,false
end

function BagData:GetBagRemind()
	local list,vis = self:GetRemindNum()
	return vis
end

function BagData:GetTabRemindList()
	return self.get_remind_array or {}
end

function BagData:GetDataByItemId(item_id)
	local data = {}

	for k, v in pairs(self.grid_data_series_list) do
		if v.item_id == item_id then
			table.insert(data, v)
		end
	end
	return data
end

--====合成===-----
function BagData:InitComposeData()
	self.compose_data = {}
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local r_index = 1
	for k, v in pairs(ClientComposeCfg) do
		local cfg = ItemSynthesisConfig[v]
		if circle >= cfg.openlimit.circle  and level >= cfg.openlimit.level and open_day >= cfg.openlimit.serverday then
			local color = cfg.color and Str2C3b(cfg.color) or COLOR3B.WHITE
			local cur_data = {name = cfg.name, type = r_index, index = v,color = color, child = {}}
			cur_data.child = self:InitChildList(cfg.list, v, level, circle, open_day)
			table.insert(self.compose_data, cur_data)
			r_index = r_index + 1
		end
	end
end


function BagData:GetComposeData()
	return self.compose_data
end


function BagData:InitChildList(list, tree_index, level, circle, open_day, type)
	local data = {}
	for k, v in ipairs(list or {}) do
		--if type == nil or type == v.child_index then
			if level >= (v.openlimit.level or 0) and  
				circle >= (v.openlimit.circle or 0) and 
				open_day >= (v.openlimit.serverday or 0) and( level >= (v.openlimit.minlevel or 0) and level <= (v.openlimit.maxlevel or 9999)) then
				local color = v.color and Str2C3b(v.color) or COLOR3B.WHITE
				local cur_data = {name = v.name, color = color, type = i, tree_index = tree_index , index = k, color = color}
				--cur_data.data_list = self:InitSecondChild(v.itemList, tree_index, i, level, circle, open_day)
				table.insert(data,cur_data)
			end
	--	end
	end
	return data
end

function BagData:InitSecondChild(tree_index, child_index, level, circle, open_day, sex)
	local tree_config = ItemSynthesisConfig[tree_index]
	local data = {} 
	if tree_config then
		local second_config = tree_config.list[child_index]
		if second_config then
			for k, v in pairs(second_config.itemList) do
				if level >= (v.openlimit.level or 0) and  
					circle >= (v.openlimit.circle or 0) and 
					open_day >= (v.openlimit.serverday or 0) and( level >= (v.openlimit.minlevel or 0) and level <= (v.openlimit.maxlevel or 9999))
					and (v.openlimit.sex == sex or (v.openlimit.sex or -1) == -1) then
					local item_cfg = ItemData.Instance:GetItemConfig(v.award[1].id)
					local name = 	item_cfg.name
					local color = Str2C3b(string.format("%06x", item_cfg.color))
					local cur_data = {name = name, type = i, tree_index = tree_index, child_index = child_index, index = k, color = color, data1 = v, award = v.award, consume = v.consume, isClient = v.isClient}
					table.insert(data,cur_data)
				end
			end
		end
	end
	return data
end

function BagData:GetAllPoint()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(ClientComposeCfg) do
		local cfg = ItemSynthesisConfig[v]
		if circle >= cfg.openlimit.circle  and level >= cfg.openlimit.level and open_day >= cfg.openlimit.serverday then
			if  self:SetTreepoint(v, circle, level, open_day, sex) then
				return true
			end
		end
	end
	return false
end

function BagData:SetTreepoint(tree_index, circle, level, open_day, sex)
	local config = ItemSynthesisConfig[tree_index] and ItemSynthesisConfig[tree_index].list or {}
	for k, v in pairs(config or {}) do
		if circle >= v.openlimit.circle  and level >= v.openlimit.level and open_day >= v.openlimit.serverday then
			if self:SetChildpoint(tree_index, k) then
				return true
			end
		end
	end
	return false
end


function BagData:SetChildpoint(tree_index, child_index)
	local config = ItemSynthesisConfig[tree_index].list or {}
	local cur_config = config[child_index].itemList or {}

	for k, v in pairs(cur_config) do
		local child_point = self:SetSecondPoint(v)
		if child_point then
			return true
		end
	end
	return false
end


function BagData:SetSecondPoint(data)
	if data.openlimit and data.openlimit.isClient then
		return false
	end
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	if level >= (data.openlimit.level or 0)
	and circle >= (data.openlimit.circle or 0)
	and open_day >= (data.openlimit.serverday or 0)
	and (level >= (data.openlimit.minlevel or 0) and level <= (data.openlimit.maxlevel or 9999))
	and (data.openlimit.sex == sex or (data.openlimit.sex or -1) == -1)
	then
		local consumes_list, virtual_consumes_list = {}, {}
		self.ContinueRecordConsumesCount(data.consume, consumes_list, virtual_consumes_list)
		local bool = self.OnceCheckConsumesCount(consumes_list, virtual_consumes_list)
		return bool
	end

	return false
end

function BagData:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_COIN or vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		RemindManager.Instance:DoRemindDelayTime(RemindName.BagCompose, 0.2)
	end
end


function BagData:ItemDataListChangeCallback()
	RemindManager.Instance:DoRemindDelayTime(RemindName.BagUseRemind)
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	self:InitComposeData()
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
			RemindManager.Instance:DoRemindDelayTime(RemindName.BagCompose)
			if self.delay_timer then
				GlobalTimerQuest:CancelQuest(self.delay_timer)
				self.delay_timer = nil
			end
	end, 0.5)
	
end


function BagData:GetRemindnameNum(remind_name)
	if remind_name == RemindName.BagCompose then
		return self:GetAllPoint() and 1 or 0
	elseif remind_name == RemindName.BagUseRemind then
		return self:GetBagRemind() and 1 or 0
	end
end

function BagData:GetTreeIndex()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	for i, v in ipairs(ClientComposeCfg) do
		local cfg = ItemSynthesisConfig[v]
		if circle >= cfg.openlimit.circle  and level >= cfg.openlimit.level and open_day >= cfg.openlimit.serverday then
			return v
		end
	end
end


function BagData:GetChildIndex(tree_index)
	-- local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	-- local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	-- local open_day = OtherData.Instance:GetOpenServerDays()
	-- --for k, v in pairs(ClientComposeCfg) do
	-- 	local cfg = ItemSynthesisConfig[tree_index]
	-- 	if cfg and cfg.itemList then
	-- 		for i, v1 in ipairs(cfg.itemList) do
	-- 			if level >= (v1.level or 0) and  
	-- 				circle >= (v1.circle or 0) and 
	-- 				open_day >= (v1.serverday or 0) and( level >= (v1.minlevel or 0) and level <= (v1.maxlevel or 9999)) then
	-- 				return i
	-- 			end
	-- 		end
	-- 	end
			
	--end
	return 1
end

function BagData:GetIsOpenByIndex(index)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()

	local cfg = ItemSynthesisConfig[index]
	if circle >= cfg.openlimit.circle  and level >= cfg.openlimit.level and open_day >= cfg.openlimit.serverday then
		return true
	end
	return false
end



---====热血
function BagData:GetReXueData(  )
	return self.rexue_data_list
end


-- 装备的耐久发生变化
function BagData:SetDurabilityChange(protocol)
	local series = protocol.series or 0
	local item = self.grid_data_series_list[series] or {}
	item.durability = protocol.durability
	item.durability_max = protocol.durability_max
	self:DispatchEvent(BagData.DURABILITY_CHANGE, item)
end

-- 装备使用的冻结时间发生变化
function BagData:SetFrozenTimeChange(protocol)
	local series = protocol.gildid or 0
	local item = self.grid_data_series_list[series] or {}
	item.frozen_times = protocol.frozen_times
end


--经验珠次数
function BagData:SetSpecialItemNUm(protocol)
	self.special_use_num = protocol.jianzhu_use_time
	GlobalEventSystem:Fire(USE_NUM_EVENT.NUM_CHANGE)
end


function BagData:GetSpecialUseNUm()
	return self.special_use_num
end


function BagData:GetCanUseJiYanZhu()
	if self.special_use_num >= ItemConvertExpCfg.EpxBeadCfg.maxUseTms then
		return false
	end
	return true
end