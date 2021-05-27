ConsignData = ConsignData or BaseClass()

ConsignData.MaxConsignNum = 10		-- 最大售卖数
ConsignData.MinConsignGetNum = 50

ConsignData.MY_CONSIGN_DATA = "my_consign_data"--我的寄售数据
ConsignData.OTHER_CONSIGN_DATA="other_consign_data"--其他寄售数据
ConsignData.PUTAWAY_RESULT="putaway_result"--上架结果

function ConsignData:__init()
	if ConsignData.Instance then
		ErrorLog("[ConsignData] Attemp to create a singleton twice !")
	end
	
	ConsignData.Instance = self
	self:InitChoiceData()
	self.result=0
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()--绑定事件

	self.backstage_recharge_cfg_list = {}		-- 后台配置
	self.recharge_cfg_list = {}					-- 本地配置
	self:Initrechargecfg()

	EventProxy.New(RoleData.Instance):AddEventListener(OBJ_ATTR.ACTOR_RED_DIAMONDS, BindTool.Bind(self.OnRedDiamondsChange, self))
end

function ConsignData:__delete()
	ConsignData.Instance = nil
end

function ConsignData:SetMyConsignItemsData(protocol)
	self.my_consign_items_data = {}
	self.my_consign_items_data.item_num = protocol.item_num
	self.my_consign_items_data.item_list = protocol.item_list
	
	for k, v in pairs(self.my_consign_items_data.item_list) do
		v.remain_time = Status.NowTime + v.remain_time
	end
	self:DispatchEvent(ConsignData.MY_CONSIGN_DATA)--抛出事件
end

function ConsignData:GetMyConsignItemsData()
	return self.my_consign_items_data
end

function ConsignData:SetResult(protocol)
	self.result = protocol.result
	self:DispatchEvent(ConsignData.PUTAWAY_RESULT)--抛出事件
end

function ConsignData:GetResult()
	return self.result
end


-- 获取别人出售的物品记录
function ConsignData:SetSearchConsignItemsData(protocol)
	for k, v in pairs(protocol.item_list) do
		ItemData.Instance:GetItemConfig(v.item_data.item_id)
		v.remain_time = Status.NowTime + v.remain_time
	end
	if protocol.index == 0 then
		self.search_consign_items_data.item_list = protocol.item_list
		self.search_consign_items_data.item_num = protocol.item_num
	else
		for i, v in ipairs(protocol.item_list) do
			table.insert(self.search_consign_items_data.item_list, v)
		end
		self.search_consign_items_data.item_num = self.search_consign_items_data.item_num + protocol.item_num
	end
end

function ConsignData:AddConsignItem(item_info)
	table.insert(self.search_consign_items_data.item_list, item_info)
	self.search_consign_items_data.item_num = self.search_consign_items_data.item_num + 1
	self:DispatchEvent(ConsignData.OTHER_CONSIGN_DATA)--抛出事件
end

function ConsignData:DelConsignItem(item_handle)
	for i, v in ipairs(self.search_consign_items_data.item_list) do
		if v.item_handle == item_handle then
			self.search_consign_items_data.item_num = self.search_consign_items_data.item_num - 1
			table.remove(self.search_consign_items_data.item_list, i)
			self:DispatchEvent(ConsignData.OTHER_CONSIGN_DATA)--抛出事件
			break
		end
	end
end

-- 手动清除超时物品
function ConsignData:ClearupOutTimeItemsData()
	local num = #self.search_consign_items_data.item_list
	for i = num, 1, - 1 do
		self.search_consign_items_data.item_list[i].item_data.item_handle = self.search_consign_items_data.item_list[i].item_handle
		
		local mainrole = Scene.Instance:GetMainRole()
		-- 删除超时/自己卖的
		if self.search_consign_items_data.item_list[i].remain_time <= Status.NowTime + 30 or
		self.search_consign_items_data.item_list[i].remain_time > Status.NowTime + 8 * 24 * 60 * 60 then
			table.remove(self.search_consign_items_data.item_list, i)
		end
	end
	
	self.search_consign_items_data.item_num = #self.search_consign_items_data.item_list
end

function ConsignData:GetSearchConsignItemsData()
	-- self:ClearupOutTimeItemsData()
	return self.search_consign_items_data
end

function ConsignData:GetNowConsignItemsNum()
	return self.search_consign_items_data.item_num
end

function ConsignData:GetItemSellerIsMe(data)
	if nil == data or nil == data.seller_name then return false end
	local mainrole = Scene.Instance:GetMainRole()
	return mainrole.name == data.seller_name
end



---- 购买 ----
function ConsignData:GetSearchChoiceData(tag)
	local data_list = {}
	local cfg = ConsignmentType
	if cfg == nil then return {} end
	if tag == "type" then
		for i, v in ipairs(cfg.typeList) do
			data_list[#data_list + 1] = v
			data_list[#data_list].search_type = "types"
		end
	elseif tag == "level" then
		for i, v in ipairs(cfg.levels) do
			data_list[#data_list + 1] = v
			data_list[#data_list].search_type = "levels"
		end
		for i, v in ipairs(cfg.circles) do
			data_list[#data_list + 1] = v
			data_list[#data_list].search_type = "circles"
		end
	elseif tag == "profession" then
		for i, v in ipairs(cfg.jobs) do
			data_list[#data_list + 1] = v
			data_list[#data_list].search_type = "jobs"
		end
	end
	return data_list
end

function ConsignData:InitChoiceData()
	self.cur_choice_index_list = {
		["type"] = 1,
		["level"] = 1,
		["profession"] = 1,
	}
	self.search_consign_items_data = {
		item_num = 0,
		item_list = {},
	}
	self.my_consign_items_data = {
		item_num = 0,
		item_list = {},
	}
end

function ConsignData:SetNowChoiceData(tag, index)
	index = index > 0 and index or 1
	self.cur_choice_index_list[tag] = index
end

function ConsignData:GetNowChoiceData(tag)
	return self:GetSearchChoiceData(tag) [self.cur_choice_index_list[tag]]
end

function ConsignData:GetNowChoiceIndex(tag)
	return self.cur_choice_index_list[tag]
end

-- 根据条件筛选数据
local show_data_list = {}
local limit_cache = {}	-- 做个缓存
function ConsignData:GetSearchChoiceItemDataList(count)
	count = count or 0
	if ConsignData.MinConsignGetNum == count then
		limit_cache = {}
		table.sort(self.search_consign_items_data.item_list, ConsignData.SortConsignData())
	end
	local data_list = self:GetSearchConsignItemsData()
	
	local tag_datas = {}
	tag_datas["type"] = self:GetNowChoiceData("type")
	tag_datas["level"] = self:GetNowChoiceData("level")
	tag_datas["profession"] = self:GetNowChoiceData("profession")
	show_data_list = {}
	if tag_datas["type"].value == 0 and tag_datas["level"].value == 0 and tag_datas["profession"].value == 0 then
		for i, v in ipairs(data_list.item_list) do
			if #show_data_list < count then
				table.insert(show_data_list, v)
			else
				break
			end
		end
		return show_data_list
	end
	
	for i, item in ipairs(data_list.item_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(item.item_data.item_id)
		local is_ignore_job = false
		local is_add = true
		
		if nil ~= item_cfg then
			
			---- 物品类型 ----
			if tag_datas["type"].value > 0 then
				for equ_index = 1, #tag_datas["type"].type do
					is_add = item_cfg.type == tag_datas["type"].type[equ_index]
					if is_add then break end
				end
			end
			-- "所有系列"不处理
			-- if tag_datas["type"].value > 0 and tag_datas["type"].value <= 9 then 	-- 武器~靴子
			-- 	is_add = is_add and(tag_datas["type"].value == item_cfg.type)
			-- end
			-- if tag_datas["type"].value >= 10 and tag_datas["type"].value <= 12 then	-- 药品、材料、其他
			-- 	is_ignore_job = false 	-- 不限职业开关
				
			-- 	if tag_datas["type"].value == 10 then 	-- 药品
			-- 		local condition =(item_cfg.type == ItemData.ItemType.itFastMedicaments) or
			-- 		(item_cfg.type == ItemData.ItemType.itPetMedicaments) or
			-- 		(item_cfg.type == ItemData.ItemType.itPetFastMedicaments)
			-- 		is_add = is_add and condition
			-- 	end
			-- 	if tag_datas["type"].value == 11 then 	-- 材料(现在type>=100当材料)
			-- 		local condition =(item_cfg.type >= 100)
			-- 		is_add = is_add and condition
			-- 	end
			-- 	if tag_datas["type"].value == 12 then 	-- 其他(暂当材料处理)
			-- 		local condition =(item_cfg.type >= 100)
			-- 		is_add = is_add and condition
			-- 	end
			-- end
			
			---- 等级限制 ----
			if tag_datas["level"].search_type == "circles" then 		-- 转
				local has_circle = false
				for k, v in pairs(item_cfg.conds) do
					if v.cond == ItemData.UseCondition.ucMinCircle then
						has_circle = true
						is_add = is_add and(v.value >= tag_datas["level"].value)
					end
				end
				is_add = is_add and has_circle
			end
			
			if tag_datas["level"].search_type == "levels" then 			-- 等级
				for k, v in pairs(item_cfg.conds) do
					if v.cond == ItemData.UseCondition.ucLevel then
						if tag_datas["level"].value ~= 0 then 			--"不限等级"不处理
							is_add = is_add and(v.value >= tag_datas["level"].value)
						end
					end
				end
			end
			
			---- 职业限制 ----
			if tag_datas["profession"].value ~= 0 then 	 				-- 职业
				local has_job = false
				for k, v in pairs(item_cfg.conds) do
					if v.cond == ItemData.UseCondition.ucJob then
						has_job = true
						is_add = is_add and(v.value == tag_datas["profession"].value)
					end
				end
				if not is_ignore_job then
					is_add = is_add and has_job
				end
			end
			
			if is_add then
				table.insert(show_data_list, item)
			end
			if #show_data_list >= count then
				break
			end
		end
	end
	return show_data_list
end

local a_value = 1000
local b_value = 1000
local a_level, a_zhuan = 0, 0
local b_level, b_zhuan = 0, 0
local a_cfg = nil
local b_cfg = nil
function ConsignData.SortConsignData()
	return function(a, b)
		a_cfg = ItemData.Instance:GetItemConfig(a.item_data.item_id)
		b_cfg = ItemData.Instance:GetItemConfig(b.item_data.item_id)
		if nil == a_cfg or nil == b_cfg then
			return false
		end
		if ItemData.GetIsEquipType(a_cfg.type) and not ItemData.GetIsEquipType(b_cfg.type) then
			return true
		end
		if not ItemData.GetIsEquipType(a_cfg.type) and ItemData.GetIsEquipType(b_cfg.type) then
			return false
		end
		a_value = 1000
		b_value = 1000
		if ConsignData.IsEnoughLimit(a.item_data) then
			a_value = a_value + 100
		end
		if ConsignData.IsEnoughLimit(b.item_data) then
			b_value = b_value + 100
		end
		if a_value == 1000 and b_value == 1000 then
			return false
		end
		a_level, a_zhuan = ItemData.GetItemLevel(a.item_data.item_id)
		b_level, b_zhuan = ItemData.GetItemLevel(b.item_data.item_id)
		if a_zhuan < b_zhuan then
			a_value = a_value + 10
		elseif b_zhuan < a_zhuan then
			b_value = b_value + 10
		else
			if a_level < b_level then
				a_value = a_value + 10
			elseif b_level < a_level then
				b_value = b_value + 10
			end
		end
		if a.item_data.item_id < b.item_data.item_id then
			a_value = a_value + 1
		elseif b.item_data.item_id < a.item_data.item_id then
			b_value = b_value + 1
		end
		return a_value > b_value
	end
end


function ConsignData.IsEnoughLimit(data)
	if nil ~= limit_cache[data.item_id] then
		return limit_cache[data.item_id]
	end
	limit_cache[data.item_id] = EquipData.Instance:GetIsBetterEquip(data)
	return limit_cache[data.item_id]
end

---- 出售 ----
-- 获取背包物品数据
function ConsignData:GetBagItemDataList()
	local data_list = TableCopy(BagData.Instance:GetItemDataList())
	local show_data_list = {}

	-- for i=#data_list, 0, -1 do
	-- 	if data_list[i] ~= nil and data_list[i].is_bind ~= 0 then
	-- 		if i ~= 0 then
	-- 			table.remove(data_list, i)
	-- 		else
	-- 			data_list[0] = table.remove(data_list, 1)
	-- 		end
	-- 	end
	-- end
	-- 重新排序
	for k, v in pairs(data_list) do
		if v.is_bind == 0 and ItemData.Instance:GetItemConfig(v.item_id).sellBuyType ~= 0 then
			show_data_list[#show_data_list + 1] = v
		end
	end
	show_data_list[0] = table.remove(show_data_list, 1)
	
	return show_data_list
end 

-- 保存从后台过来的充值配置
function ConsignData:SetRechargeCfgByBackstage(data)
	self.backstage_recharge_cfg_list = {}
	for k, v in pairs(data.recharge_list) do
		local t = {id = tonumber(v.id), money = tonumber(v.money), gold = tonumber(v.gold), money_type = v.type or Language.Common.MoneyTypeStr[0]}
		table.insert(self.backstage_recharge_cfg_list, t)
	end
	table.sort(self.backstage_recharge_cfg_list, SortTools.KeyLowerSorter('id'))
end

function ConsignData:Initrechargecfg()
	-- body
	-- 如果是IOS(不分正版越狱)的话显示的金额额度和安卓用不一样的配置
	if cc.PLATFORM_OS_IPHONE == PLATFORM or cc.PLATFORM_OS_IPAD == PLATFORM then
		self.recharge_cfg_list = ConfigManager.Instance:GetAutoConfig("red_diamondappstore_auto").recharge_list
	else
		self.recharge_cfg_list = ConfigManager.Instance:GetAutoConfig("red_diamond_auto").recharge_list
	end
end

-- 红钻显示配置
function ConsignData:GetRechargeCfg()
	local finial_cfg_list = {}
	if nil ~= next(self.backstage_recharge_cfg_list) then
		-- （优先使用后台发过来的配置）
		finial_cfg_list =  self.backstage_recharge_cfg_list
	else
		finial_cfg_list = self.recharge_cfg_list
	end
	-- if self:GetIsOpenDouble() == 1 then
	-- 	if finial_cfg_list then
	-- 		for k,v in pairs(finial_cfg_list) do
	-- 			v.show_double = 0
	-- 		end
	
	-- 		if self.chongzhi_info_list ~= nil then
	-- 			for k,v in pairs(self.chongzhi_info_list) do
	-- 				for key,value in pairs(finial_cfg_list) do
	-- 					if tonumber(v.money) == tonumber(value.gold)  then
	-- 						value.show_double = v.times
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	return finial_cfg_list
end

function ConsignData:OnRedDiamondsChange(param_t)
	local old_value = param_t.old_value or 0
	local value = param_t.value or 0
	local num = value - old_value

	if num > 0 then
		ConsignCtrl.Instance:OpenRedDrilleTip(num)
	end
end