MiJiComposeData = MiJiComposeData or BaseClass()

function MiJiComposeData:__init()
	if nil ~= MiJiComposeData.Instance then
		print_error("[MiJiComposeData] Attemp to Creat a singleton twice !")
		return
	end
	MiJiComposeData.Instance = self

	self.bag_list_cont = 0
	self.shen_ge_item_info = {}

	local chinese_zodiac_cfg_auto = ConfigManager.Instance:GetAutoConfig("chinese_zodiac_cfg_auto")
	self.miji_cfg = chinese_zodiac_cfg_auto.miji_cfg

	self.notify_data_change_callback_list = {}		--物品有更新变化时进行回调

end

function MiJiComposeData:__delete()
	MiJiComposeData.Instance = nil
end

function MiJiComposeData:GetCanComposeDataList(data_list, is_show_enough)
	if self.bag_list_cont <= 0 then
		return {}
	end

	local list = {}
	if data_list.count <= 0 then
		if is_show_enough then
			list = self:GetBagItemKindAndQualityList()
			return self:SortComposeList(list)
		end

		for _, v in pairs(self.shen_ge_item_info) do
			if v.shen_ge_data.quality < 3 then
				table.insert(list, v)
			end
		end
		return self:SortComposeList(list)
	end

	local temp_data_list = {}
	for k, v in pairs(data_list) do
		if type(v) == "table" then
			table.insert(temp_data_list, v)
		end
	end

	local index_1 = math.max(#temp_data_list - 0, 1)
	local index_2 = math.max(#temp_data_list - 1, 1)
	local index_3 = math.max(#temp_data_list - 2, 1)

	for k, v in pairs(self.shen_ge_item_info) do
		if temp_data_list[index_1].shen_ge_kind == v.shen_ge_kind and v.shen_ge_data.quality == temp_data_list[index_1].shen_ge_data.quality
			and (temp_data_list[index_1].shen_ge_data.index ~= k and temp_data_list[index_2].shen_ge_data.index ~= k and
				temp_data_list[index_3].shen_ge_data.index ~= k) and v.shen_ge_data.quality < 3  then

				table.insert(list, v)
		end
	end

	return self:SortComposeList(list)
end

function MiJiComposeData:SortComposeList(list)
	table.sort(list, function(a, b)
			if a.shen_ge_data.quality ~= b.shen_ge_data.quality then
				return a.shen_ge_data.quality < b.shen_ge_data.quality
			end

			if a.shen_ge_data.type ~= b.shen_ge_data.type then
				return a.shen_ge_data.type > b.shen_ge_data.type
			end

			return a.shen_ge_data.level < b.shen_ge_data.level
		end)
	return list
end

function MiJiComposeData:GetSameQuYuDataList(qu_yu)
	local list = {}
	local cfg = {}
	for k, v in pairs(self.shen_ge_item_info) do
		cfg = self:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
		list[cfg.quyu] = list[cfg.quyu] or {}
		table.insert(list[cfg.quyu], v)
	end

	for k, v in pairs(list) do
		table.sort(v, function(a, b)
			if a.shen_ge_data.quality ~= b.shen_ge_data.quality then
				return a.shen_ge_data.quality > b.shen_ge_data.quality
			end

			if a.shen_ge_data.level ~= b.shen_ge_data.level then
				return a.shen_ge_data.level > b.shen_ge_data.level
			end

			return a.shen_ge_data.type < b.shen_ge_data.type
		end)
	end

	return list[qu_yu] or {}
end

function MiJiComposeData:GetShenGeAttributeCfg(types, quality, level)
	if nil ~= level then
		if nil == self.attribute_cfg[quality] or nil == self.attribute_cfg[quality][types] then
			return {}
		end
		return self.attribute_cfg[quality][types][level]
	end

	if nil == self.attribute_cfg[quality] then
		return {}
	end
	return self.attribute_cfg[quality][types]
end

--had_dada_list是指放下去的物品列表
function MiJiComposeData:GetMiJiItemListByBag(had_data_list)
	local miji_bag_list = {}
	local all_bag = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(all_bag) do
		for k1,v1 in pairs(self.miji_cfg) do
			if v1.item_id == v.item_id then
				local vo = {}
				local bag_info = TableCopy(v)
				vo.bag_info = bag_info
				vo.item_id = v.item_id
				vo.level = v1.level
				table.insert(miji_bag_list, vo)
			end
		end
	end
	if not next(miji_bag_list) then
		return {}
	end
	if not next(had_data_list.list) then
		table.sort(miji_bag_list, SortTools.KeyLowerSorters("level"))
		return miji_bag_list
	end
	local new_data = {}
	local have_level = -1
	for k,v in pairs(had_data_list.list) do
		if v and v.level then
			have_level = v.level
		end
	end
	for k,v in pairs(miji_bag_list) do
		-- if have_level == v.level then
			table.insert(new_data, v)
		-- end
	end
	if next(new_data) then
		for i=#new_data,1,-1 do
			for k,v in pairs(had_data_list.list) do
				if new_data[i] and next(v) and new_data[i].bag_info.item_id == v.bag_info.item_id 
					and new_data[i].bag_info.is_bind == v.bag_info.is_bind then
					if new_data[i].bag_info.num > 1 then
						new_data[i].bag_info.num = new_data[i].bag_info.num - 1
					else
						table.remove(new_data, i)
					end
				end
			end
		end
	end
	table.sort(new_data, SortTools.KeyLowerSorters("level"))
	return new_data
end


--筛选出能够合成的item
function MiJiComposeData:IsCanCompose(item,had_data_list, count)
	local flag = false
	if count == 0 then
		flag = true
	else 
		local key = next(had_data_list) or 0                  --判空，并且取出item_id
		local temp = had_data_list[key] or {}
		local item_id = temp.item_id or 0
		local cfg = ShengXiaoData.Instance:GetMijiCfgByItemId(item_id)
		if cfg then
			if cfg.level == item.level then
				flag = true
			end
		end
	end
	return flag
end

function MiJiComposeData:GetMiJicfg()
	return self.miji_cfg
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function MiJiComposeData:NotifyDataChangeCallBack(callback)
	if callback == nil then
		return
	end

	self.notify_data_change_callback_list[callback] = callback
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function MiJiComposeData:UnNotifyDataChangeCallBack(callback)
	if nil == self.notify_data_change_callback_list[callback] then
		return
	end

	self.notify_data_change_callback_list[callback] = nil
end
