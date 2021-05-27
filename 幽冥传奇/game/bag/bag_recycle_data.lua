
-- 回收
BagData = BagData or BaseClass()

function BagData:RecycleSuccess()
	self:DispatchEvent(BagData.RECYCLE_SUCCESS)
end

function BagData:CheckCanAutoRecycle(bag_item)
	local item_cfg = ItemData.Instance:GetItemConfig(bag_item.item_id) 
	if nil == item_cfg then return end
	if not ItemData.GetIsEquip(bag_item.item_id) then return end

	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 自身的等级
	local self_prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)			-- 自身的职业
	local limit_level, zhuan = ItemData.GetItemLevel(bag_item.item_id)			-- 装备的等级和转数
	local prof_judge = false

	for k, v in pairs(item_cfg.conds) do
		if v.cond == ItemData.UseCondition.ucJob then
			prof_judge = not (v.value == self_prof)   -- 是否是非本职业的
			break
		end
	end

	local function compare_equip(a, b)
		return ItemData.Instance:GetItemScoreByData(a) > ItemData.Instance:GetItemScoreByData(b)
	end

	--战斗力比穿戴装备低 或 非本职业 均自动投入熔炼
	--否则加入选择列表
	local equip_level_t = self:GetEquipLevel(item_cfg.type) -- {limit_level = limit_level, zhuan = zhuan, item_data = v}
	local bool = false
	if prof_judge or equip_level_t and compare_equip(bag_item, equip_level_t.item_data) then
		bool = true
	end

	return bool 
end

local cur_equip_list
function BagData:GetEquipLevel(cfg_type)
	if nil == cur_equip_list then
		cur_equip_list = {}
		for k, v in pairs(EquipData.Instance:GetEquipData()) do
			local cfg = ItemData.Instance:GetItemConfig(v.item_id) 
			if nil ~= cfg then
				local item_type = cfg.type or -1
				local equip = cur_equip_list[item_type]
				local limit_level, zhuan = ItemData.GetItemLevel(v.item_id)
				if(nil == equip) then
					equip = {limit_level = limit_level, zhuan = zhuan, item_data = v}
				else
					local old_cfg = ItemData.Instance:GetItemConfig(equip.item_data.item_id) or CommonStruct.ItemConfig()
					local is_low = ItemData.Instance:GetItemScore(cfg, v) < ItemData.Instance:GetItemScore(old_cfg, equip.item_data) 
					if(is_low) then				--如果有两件相同的装备，取评分低的
						equip = {limit_level = limit_level, zhuan = zhuan, item_data = v}
					end
				end	
				cur_equip_list[item_type] = equip
			end	
		end
	end

	return cur_equip_list[cfg_type]
end

-- 重置"装备比对信息"缓存
function BagData.ResetRecycelEquipList()
	cur_equip_list = nil
end

function BagData:IsInRecleList(item_id)
	return nil ~= BaseEquipMeltingConfig.equipList[item_id]
end

function BagData:IsInRecleList2(item_id)
	return nil ~= self.basis_resolve_cfg[item_id]
end

-- 合并装备和材料回收
function BagData:EquipAndPropBag()
	local data = {}
	if self.recyle_index == 1 or self.recyle_index == 3 then
		data = BagData.Instance:GetDataListSeries()
	elseif self.recyle_index == 2 then
		data = ExploreData.Instance:GetWearHouseAllData()
	end

	return data
end

function BagData:InitRecycleList()
	self.recycle_item_list = {}
	self.new_recycle_list = {}

	for k, bag_item in pairs(self:EquipAndPropBag()) do
		if not self:CheckCanAutoRecycle(bag_item) then
			if self:IsInRecleList(bag_item.item_id) then
				table.insert(self.recycle_item_list, bag_item)
			end

			if self:IsSpecialEquip(bag_item.type) or self:IsInRecleList2(bag_item.item_id) then
				table.insert(self.new_recycle_list, bag_item)
			end
		end
	end
	self:DispatchEvent(BagData.RECYCLE_LIST_CHANGE)
end

--删除回收网格数据
function BagData:DelRecycleGridData(item_data)
	if nil == item_data then return end
	for k,v in pairs(self.recycle_item_list) do
		if v.series == item_data.series then
			self.recycle_item_list[k] = nil
			self:DispatchEvent(BagData.RECYCLE_LIST_CHANGE)
			break
		end
	end
end

-- 回收仓库选择
function BagData:RecycleStorageChree(index)
	self.recyle_index = index
end

-- 获取回收背包类型
function BagData:GetRecycleType()
	return self.recyle_index
end

-- 取消回收一个装备
function BagData:CancelRecycleGridData(item_data)
	self:DelRecycleGridData(item_data)
end

-- 分解分类配置 level 等级范围,circle 转生范围, type 物品类型
local lev_limit = CLIENT_GAME_GLOBAL_CFG.recycle_lev_limit

local lev_limit_type = {}
for i,v in ipairs(lev_limit) do
	for _, _type in ipairs(v.type or {}) do
		lev_limit_type[_type] = true
	end
end

local special_limit = CLIENT_GAME_GLOBAL_CFG.sprice_equip
local special_limit_type = {}
for i, _type in ipairs(special_limit.type or {}) do
	special_limit_type[_type] = true
end

-- 判断是普通的装备
function BagData:IsEquip(item_type)
	return lev_limit_type[item_type]
end

-- 判断是特殊的装备
function BagData:IsSpecialEquip(item_type)
	return special_limit_type[item_type]
end

-- 回收分类
function BagData:RevertTypeEquip(data)
	local tab_item = {}
	local index = 0
	for k, v in pairs(data) do
		if v == 1 then
			local data = self:RquipTypeShow(k)
			for k1, v1 in pairs(data) do
				table.insert(tab_item, v1)
			end
		end
	end
	if not tab_item[0] and tab_item[1] then
		tab_item[0] = table.remove(tab_item, 1)
	end
	return tab_item
end

-- （新  等级转生回收判断）
function BagData:RquipTypeShow(type)
	local item_cfg = nil
	local item_data = {}
	local index = 0
	for k,v in pairs(self.recycle_item_list) do
		if v.item_id ~= nil then
			item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			for i = 1, #lev_limit[type].type do
				if item_cfg.type == lev_limit[type].type[i] then
					if lev_limit[type].level == nil then
						for k1, v1 in pairs(item_cfg.conds) do
							if v1.cond == ItemData.UseCondition.ucMinCircle then
								if lev_limit[type].circle[1] <= v1.value and lev_limit[type].circle[2] > v1.value and self:IsEquip(item_cfg.type) then
									index = index + 1
									table.insert(item_data, v)
								end
							end
						end
					elseif lev_limit[type].circle == nil and self:IsEquip(item_cfg.type) then
						local lv, zhuan = ItemData.GetItemLevel(item_cfg.item_id)
							
						if zhuan == 0 and lev_limit[type].level[1] <= lv and lev_limit[type].level[2] >= lv then
							index = index + 1
							table.insert(item_data, v)
						end
					end
				end
			end
		end
	end
	return item_data, index
end

-- 分类回收获得
function BagData:GetRecycle(data)
	local all_reward = {}
	local cfg = BaseEquipMeltingConfig or {}
	for k,v in pairs(data) do
		if k < BaseEquipMeltingConfig.limitCount then
			if v.item_id and cfg.equipList[v.item_id] then
				for k1,v1 in pairs(cfg.equipList[v.item_id].award) do
					if v1.id == 0 then 
						v1.id = ItemData.GetVirtualItemId(v1.type)
					end
					all_reward[v1.id] = (all_reward[v1.id] or 0) + v1.count
				end		
			end
		end
	end
	return all_reward
end

function BagData:SetMeltingChessData(index, vis)
	self.type_show[index] = vis and 1 or 0

	self:DispatchEvent(BagData.BAG_MELTING_CHESS_CHANGE)
end

function BagData:GetRecycleChess()
	return self.type_show
end

-- 分解类装备显示
function BagData:GetSpecialEqip()

	local data = CLIENT_GAME_GLOBAL_CFG.sprice_equip
	local item_cfg = nil
	local item_data = {}
	for k,v in pairs(self.new_recycle_list) do
		if v.item_id ~= nil then
			v.choice = 0 -- 默认选中 0-不选中 1-选中
			item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if self:IsSpecialEquip(item_cfg.type) then
				table.insert(item_data, v)
			elseif self.basis_resolve_cfg[v.item_id] then
				table.insert(item_data, v)
			end
		end
	end

	table.sort(item_data, function(a, b)
		if a.type < b.type then
			return true
		elseif a.type == b.type and a.item_id < b.item_id then
			return true
		end
	end)

	if not item_data[0] and item_data[1] then
		item_data[0] = table.remove(item_data, 1)
	end

	return item_data
end

-- 选择分解装备数据
function BagData:SetIsChoiceData(choice, index, data)
	local item = self.choice_item and self.choice_item[index] or {}
	item.choice = choice
	self.spe_data = self:DecomposeGetItem(self.choice_item)
end

function BagData:GetDecomeData(data)
	self.choice_item = data
	self.spe_data = self:DecomposeGetItem(self.choice_item)
end

function BagData:GetSpeData()
	
	return self.choice_item, self.spe_data
end

-- 分解回收获得
function BagData:DecomposeGetItem(data)
	self.basis_select_count = 0

	local all_reward = {}
	local cfg = BaseEquipMeltingConfig or {}
	for k,v in pairs(data) do
		if v.item_id and v.choice == 1 then
			-- 优先取合成配置中的奖励
			if self.basis_resolve_cfg[v.item_id] then
				local cur_cfg = self.basis_resolve_cfg[v.item_id]
				local award = cur_cfg.award or {}
				for _, item in ipairs(award) do
					local award_id = item.id
					if award_id == 0 then 
						award_id = ItemData.GetVirtualItemId(item.type)
					end
					all_reward[award_id] = (all_reward[award_id] or 0) + item.count
				end

				self.basis_select_count = self.basis_select_count + 1
			elseif cfg.equipList[v.item_id] then
				for _, item in pairs(cfg.equipList[v.item_id].award) do
					local award_id = item.id
					if award_id == 0 then 
						award_id = ItemData.GetVirtualItemId(item.type)
					end
					all_reward[award_id] = (all_reward[award_id] or 0) + item.count
				end

				self.basis_select_count = self.basis_select_count + 1
			end
		end
	end

	return all_reward
end

function BagData:GetBasisSelectCount()
	return self.basis_select_count
end

function BagData:ResetBasisSelectCount()
	self.basis_select_count = 0
end

-- 初始化"基础装备分解"配置(不同于 基础装备回收)
function BagData:InitBasisResolveCfg()
	local cfg = ItemSynthesisConfig and ItemSynthesisConfig[3] or {}
	local cur_cfg = cfg.list and cfg.list[1] and cfg.list[1].itemList or {}
	for index, v in ipairs(cur_cfg) do
		local item_id = v.consume and v.consume[1] and v.consume[1].id
		if item_id then
			v.index = index -- 增加字段 用于请求分解
			self.basis_resolve_cfg[item_id] = v
		end
	end
end

-- 基础装备分解配置
function BagData:GetBasisResolveCfg()
	return self.basis_resolve_cfg
end