--------------------------------------------------------
-- 背包数据改变派发
--------------------------------------------------------
BagData = BagData or BaseClass()

BAG_CHANGE_CACHE_INFO_NUM = 10 			--一帧内缓存的背包物品派发数据数量 当大于该值时 将统一派发

BagData.CACHE_LIST = {}					--背包操作缓存列表

--[[
	通用方法 设置背包操作延迟;
	调用SetDaley(ture) 开始缓存数据 期间背包产生的数据变化 均缓存至BagData.CACHE_LIST
	调用SetDaley(false) 一次性更新数据
]]

--每个物品所需派发的数据格式
--@{change_type = ITEM_CHANGE_TYPE.ADD/DEL, data = @改变的物品数据, reason = ItemGetType.TakeOffItem/AwardItem/DealGetItem...}
function BagData:SetDaley(is_daley, time)
	self.is_daley = is_daley
	if is_daley then
		if nil == self.item_daley_timer then
			self.item_daley_timer = GlobalTimerQuest:AddDelayTimer(function()
				self:SetDaley(false)
			end, time or 5)
		else
			self.item_daley_timer[3] = Status.NowTime + 5
		end
	else
		GlobalTimerQuest:CancelQuest(self.item_daley_timer)
		self.item_daley_timer = nil
		for k, v in ipairs(BagData.CACHE_LIST) do
			if v.change_type == ITEM_CHANGE_TYPE.ADD then
				self:AddOneItem(v.data)
			elseif v.change_type == ITEM_CHANGE_TYPE.DEL then
				self:DeleteOneItem(v.data)
			elseif v.change_type == ITEM_CHANGE_TYPE.CHANGE then
				self:BagItemNumChange(v.data.series, v.data.num, v.data.is_stone)
			end
		end

		--数据设置完成 通知监听者
		self:NoticeItemsChange(BagData.CACHE_LIST)
		--播放获取动画
		for k,v in ipairs(BagData.CACHE_LIST) do
			if v.change_type == ITEM_CHANGE_TYPE.ADD then
				BagCtrl.Instance:PlayAnimationOnGetItem(v.data.item_id)
			end
		end

		--清除缓存
		BagData.CACHE_LIST = {}
	end
end

function BagData:UpdateData(change_type, data, reason)
	--0.01秒期间 只更新设置一次数据
	if not self.is_daley then
		self:SetDaley(true)
		GlobalTimerQuest:AddDelayTimer(function()
				self:SetDaley(false)
		end, 0)
	end

	--加入缓存列表
	table.insert(BagData.CACHE_LIST, {change_type = change_type, data = data, reason = reason})
end

--缓存后派发 与之前的事件派发不兼容 数据格式不一致 需一一修改
--创建一个背包数据改变事件
local function CreateItemsChangeEvent(items_change_info_list)
	local event = {}

	function event.GetChangeDataList()
		return items_change_info_list
	end

	function event.CheckAllItemDataByFunc(func)
		local start_time = os.clock()
		for k,v in pairs(items_change_info_list) do
			if v.data then 
				func(v)
			end
		end

		-- 卡顿调试
		if os.clock() - start_time >= 0.2 then
			if PLATFORM == cc.PLATFORM_OS_WINDOWS then
				print("事件回调，函数调用时间:  ", os.clock() - start_time) 
				DebugLog()
			end
		end
	end

	return event
end

function BagData:NoticeItemsChange(items_change_info_list)
	self:DispatchEvent(BagData.BAG_ITEM_CHANGE, CreateItemsChangeEvent(items_change_info_list))
end

--更新数据
function BagData:DeleteOneItem(item_data, is_stone)
	local item_id = item_data.item_id or 0
	local item_type = item_data.type or 0
	local series = item_data.series or 0
	self.bag_item_type_list[item_type] = self.bag_item_type_list[item_type] or {}
	self.bag_item_type_list[item_type][series] = nil
	self.bag_item_count_list[item_id] = self.bag_item_count_list[item_id] or 0
	self.bag_item_count_list[item_id] = self.bag_item_count_list[item_id] - item_data.num

	self:BagShowChange("delete", item_data)

	if is_stone then
		self:DispatchEvent(BagData.BAG_STONE_DATA_CHANGE, {change_type = ITEM_CHANGE_TYPE.DEL, data = item_data})
	end
end

function BagData:AddOneItem(item, is_stone)
	local item_id = item.item_id or 0
	local item_type = item.type or 0
	local series = item.series or 0
	self.bag_item_type_list[item_type] = self.bag_item_type_list[item_type] or {}
	self.bag_item_type_list[item_type][series] = item

	self.bag_item_count_list[item_id] = self.bag_item_count_list[item_id] or 0
	self.bag_item_count_list[item_id] = self.bag_item_count_list[item_id] + item.num

	self:BagShowChange("add", item)
	if is_stone then
		self:DispatchEvent(BagData.BAG_STONE_DATA_CHANGE, {change_type = ITEM_CHANGE_TYPE.ADD, data = item})
	end
end

function BagData:BagItemNumChange(series, num, is_stone)
	local item = self.grid_data_series_list[series]
	if item then
		local old_num = self.grid_data_series_list[series].num
		self.grid_data_series_list[series].num = num

		local item_id = item.item_id or 0
		self.bag_item_count_list[item_id] = self.bag_item_count_list[item_id] or 0
		self.bag_item_count_list[item_id] = self.bag_item_count_list[item_id] + num - old_num

		self:CheckUseItemEff(ITEM_CHANGE_TYPE.CHANGE, series, old_num, num)
		if old_num < num then
			BagCtrl.Instance:PlayAnimationOnGetItem(item_id)
		end
		self:BagShowChange("change", item)
		self:NoticeItemsChange{{change_type = ITEM_CHANGE_TYPE.CHANGE, data = item}}
	end

	if is_stone then
		self:DispatchEvent(BagData.BAG_STONE_DATA_CHANGE, {change_type = ITEM_CHANGE_TYPE.CHANGE, data = item})
	end
end

function BagData:BagItemInfoChange(equip, is_stone)
	self.grid_data_series_list[equip.series] = equip

	local item_id = equip.item_id or 0
	local item_type = equip.type or 0
	local series = equip.series or 0
	self.bag_item_type_list[item_type] = self.bag_item_type_list[item_type] or {}
	self.bag_item_type_list[item_type][series] = equip

	self:BagShowChange("change", equip)

	self:NoticeItemsChange{{change_type = ITEM_CHANGE_TYPE.CHANGE, data = equip}}
	if is_stone then
		self:DispatchEvent(BagData.BAG_STONE_DATA_CHANGE, {change_type = ITEM_CHANGE_TYPE.CHANGE, data = equip})
	end
end

function BagData:SetDataList(protocol)
	-- protocol.item_list 服务端从零开始
	for k, v in pairs(protocol.item_list) do
		if nil == self.grid_data_series_list[v.series] then
			self.grid_data_series_list[v.series] = v
			self:AddOneItem(v)
		end
	end
	
	--通知列表改变
	self:NoticeItemsChange{{change_type = ITEM_CHANGE_TYPE.LIST}}
	self:DispatchEvent(BagData.BAG_STONE_DATA_CHANGE, {change_type = ITEM_CHANGE_TYPE.LIST})
end