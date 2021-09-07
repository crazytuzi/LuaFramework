ComposeData = ComposeData or BaseClass()

ComposeData.Type = {
	stone = 1,
	jinjie = 2,
	other = 3,
}

function ComposeData:__init()
	if ComposeData.Instance then
		print_error("[ComposeData] Attemp to create a singleton twice !")
	end
	ComposeData.Instance = self
	--self.is_click_item_state = {}

	RemindManager.Instance:Register(RemindName.ComposeStone, BindTool.Bind(self.CalcStoreRedPoint, self))
	RemindManager.Instance:Register(RemindName.ComposeOther, BindTool.Bind(self.CalcOtherRedPoint, self))
	RemindManager.Instance:Register(RemindName.ComposeJinjie, BindTool.Bind(self.CalcJinjieRedPoint, self))
end

function ComposeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ComposeStone)
	RemindManager.Instance:UnRegister(RemindName.ComposeOther)
	RemindManager.Instance:UnRegister(RemindName.ComposeJinjie)

	ComposeData.Instance = nil
end

--改变宝石红点
function ComposeData:CalcStoreRedPoint()
	local flag = 0
	local compose_list = self:GetTypeOfAllItem(ComposeData.Type.stone)
	local can_compose_id = self:CheckBagMat(compose_list)
	local data = self:GetTypeOfAllItem(ComposeData.Type.stone)
	local can_list = self:GetBagMatList(data)
	local new_num = 0
	for k,v in pairs(can_list) do
		new_num = v + new_num
	end

	local old_num = 0
	if self.is_click_item_state ~= nil and self.is_click_item_state[ComposeData.Type.stone] then
		for k,v in pairs(self.is_click_item_state[ComposeData.Type.stone]) do
			old_num = old_num + v.num
		end
	end

	if can_compose_id > 0 and (new_num ~= old_num) then
		flag = 1
		if self.is_click_item_state ~= nil and self.is_click_item_state[ComposeData.Type.stone] then
			for k,v in pairs(self.is_click_item_state[ComposeData.Type.stone]) do
				v.num = can_list[k]
				v.flag = v.num > 0 and 2 or 0
			end
		end
	elseif can_compose_id == 0 then
		self:ReSetRedState(ComposeData.Type.stone)
	end

	if self:GetClickFlag(ComposeData.Type.stone) then
		return 1
	end

	return flag
end

function ComposeData:ReSetRedState(compose_type)
	if self.is_click_item_state == nil then
		return 
	end

	if self.is_click_item_state[compose_type] == nil then
		return 
	end	

	for k,v in pairs(self.is_click_item_state[compose_type]) do
		v.num = 0
		v.flag = 0
	end
end

--改变其他红点
function ComposeData:CalcOtherRedPoint()
	local flag = 0
	local compose_list = self:GetTypeOfAllItem(ComposeData.Type.other)
	local can_compose_id = self:CheckBagMat(compose_list)
	local data = self:GetTypeOfAllItem(ComposeData.Type.other)
	local can_list = self:GetBagMatList(data)
	local new_num = 0
	for k,v in pairs(can_list) do
		new_num = v + new_num
	end

	local old_num = 0
	if self.is_click_item_state ~= nil and self.is_click_item_state[ComposeData.Type.other] then
		for k,v in pairs(self.is_click_item_state[ComposeData.Type.other]) do
			if v ~= nil then
				old_num = old_num + v.num
			end
		end
	end
	if can_compose_id > 0 and (new_num ~= old_num) then
		flag = 1
		for k,v in pairs(self.is_click_item_state[ComposeData.Type.other]) do
			if v ~= nil then
				v.num = can_list[k]
				v.flag = v.num > 0 and 2 or 0
			end
		end
	elseif can_compose_id == 0 then
		self:ReSetRedState(ComposeData.Type.other)
	end

	if self:GetClickFlag(ComposeData.Type.other) then
		return 1
	end

	return flag
end

function ComposeData:GetClickFlag(compose_type)
	if self.is_click_item_state == nil then
		return false
	end

	if compose_type == nil then
		return false
	end

	local data = self.is_click_item_state[compose_type]
	if data ~= nil then
		for k,v in pairs(data) do
			if v.flag == 2 and v.num > 0 then
				return true
			end
		end
	end 

	return false
end

function ComposeData:GetNumIsChange(compose_type, sub_type)
	local is_change = false
	if compose_type == nil or sub_type == nil then
		return is_change
	end

	local data = self:GetTypeOfAllItem(compose_type)
	local can_list = self:GetBagMatList(data)
	local new_num = 0
	if can_list[sub_type] ~= nil then
		new_num = can_list[sub_type]
	end

	local old_num = 0
	if self.is_click_item_state ~= nil and self.is_click_item_state[compose_type] then
		if self.is_click_item_state[compose_type][sub_type] ~= nil then
			old_num = self.is_click_item_state[compose_type][sub_type].num
		end
	end

	return new_num > 0 and new_num ~= old_num
end

function ComposeData:InitRedList(reset)
	-- local compose_list = self:GetTypeOfAllItem(ComposeData.Type.stone)
	-- local compose_list = self:GetTypeOfAllItem(ComposeData.Type.other)

	-- self:GetBagMatList()
	if self.is_click_item_state ~= nil and reset == nil then
		return
	end

	self.is_click_item_state = {}

	for k,v in pairs(ComposeData.Type) do
		local data = self:GetTypeOfAllItem(v)
		local can_list = self:GetBagMatList(data)
		for k1, v1 in pairs(can_list) do
			if self.is_click_item_state[v] == nil then
				self.is_click_item_state[v] = {}
			end

			if self.is_click_item_state[v][k1] == nil then
				self.is_click_item_state[v][k1] = {}
			end

			self.is_click_item_state[v][k1].num = v1
			if v1 == 0 then
				self.is_click_item_state[v][k1].flag = 0
			else
				self.is_click_item_state[v][k1].flag = 2
			end
		end
	end

end

function ComposeData:GetIsClickRedPointState(current_type, list_index)
	local is_click = false
	if current_type == nil or list_index == nil then
		return is_click
	end

	if self.is_click_item_state == nil then
		return is_click
	end

	if self.is_click_item_state[current_type] == nil then
		return is_click
	end

	if self.is_click_item_state[current_type][list_index] then
		local data = self.is_click_item_state[current_type][list_index]
		return data.flag == 2 and data.num > 0 
	end

	return false
end

function ComposeData:SetIsClickRedPointState(current_type, list_index)
	if self.is_click_item_state == nil then
		return 
	end

	if self.is_click_item_state[current_type] == nil then
		self.is_click_item_state[current_type] = {}
	end

	if self.is_click_item_state[current_type][list_index] then
		if self.is_click_item_state[current_type][list_index].flag == 2 then
			self.is_click_item_state[current_type][list_index].flag = 1
		end
	end
end

function ComposeData:GetIsClickItemState()
	return self.is_click_item_state
end



--改变锻造红点
function ComposeData:CalcJinjieRedPoint()
	local flag = 0
	local compose_list = self:GetTypeOfAllItem(ComposeData.Type.jinjie)
	local can_compose_id = self:CheckBagMat(compose_list)
	local data = self:GetTypeOfAllItem(ComposeData.Type.jinjie)
	local can_list = self:GetBagMatList(data)
	local new_num = 0
	for k,v in pairs(can_list) do
		new_num = v + new_num
	end

	local old_num = 0
	if self.is_click_item_state ~= nil and self.is_click_item_state[ComposeData.Type.jinjie] then
		for k,v in pairs(self.is_click_item_state[ComposeData.Type.jinjie]) do
			old_num = old_num + v.num
		end
	end
	
	if can_compose_id > 0 and (new_num ~= old_num) then
		flag = 1
		if self.is_click_item_state ~= nil and self.is_click_item_state[ComposeData.Type.jinjie] then
			for k,v in pairs(self.is_click_item_state[ComposeData.Type.jinjie]) do
				v.num = can_list[k]
				v.flag = v.num > 0 and 2 or 0
			end
		end
	elseif can_compose_id == 0 then
		self:ReSetRedState(ComposeData.Type.jinjie)
	end

	if self:GetClickFlag(ComposeData.Type.jinjie) then
		return 1
	end

	return flag
end

--获取compose_menu配置
function ComposeData:GetComposeMenuList()
	return ConfigManager.Instance:GetAutoConfig("compose_auto").compose_menu
end

--获取compose_list配置
function ComposeData:GetComposeList()
	return ConfigManager.Instance:GetAutoConfig("compose_auto").compose_list
end

function ComposeData:GetComposeTypeOfCount(compose_type)
	local compose_menu_list = self:GetComposeMenuList()
	local count = 0
	for k,v in pairs(compose_menu_list) do
		if v.type == compose_type then
			count = count + 1
		end
	end
	return count
end

function ComposeData:GetComposeTypeOfNameList(compose_type)
	local compose_menu_list = self:GetComposeMenuList()
	local name_list = {}
	for k,v in pairs(compose_menu_list) do
		if v.type == compose_type then
			name_list[#name_list + 1] = v.sub_name
		end
	end
	return name_list
end

--通过一级类型获取二级类型
function ComposeData:GetSubTypeList(compose_type)
	local compose_menu_list = self:GetComposeMenuList()
	local temp_list = {}
	for k,v in pairs(compose_menu_list) do
		if v.type == compose_type then
			temp_list[#temp_list + 1] = v.sub_type
		end
	end
	return temp_list
end

--通过二级类型获取二级类型的集合
function ComposeData:GetComposeItemList(sub_type)
	local compose_list = self:GetComposeList()
	local temp_list = {}
	for k,v in pairs(compose_list) do
		if v.sub_type == sub_type then
			temp_list[#temp_list + 1] = v
		end
	end
	function sortfun(a, b)
		return a.producd_seq < b.producd_seq
	end
	table.sort(temp_list, sortfun)
	return temp_list
end

--得到一个composeItem
function ComposeData:GetComposeItem(product_id)
	local compose_list = self:GetComposeList()
	for k,v in pairs(compose_list) do
		if v.product_id == product_id then
			return v
		end
	end
end

--获得物品的资料
function ComposeData:GetItemInfo(product_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[product_id]
end

function ComposeData:GetShowId(one_type)
	local the_list = self:GetTypeOfAllItem(one_type)
	for k,v in pairs(the_list) do
		if self:GetCanByNum(v.product_id) then
			return v.product_id
		end
	end
	return the_list[1].product_id
end

--该合成集合,背包是否有一个可合成
function ComposeData:CheckBagMat(the_compose_item_list)
	local compose_item_list = the_compose_item_list
	local min_can_num = 0
	local can_list = {}

	for k,v in pairs(compose_item_list) do
		can_list = {}
		for i = 1, 3 do
			if v["stuff_id_" .. i] == nil or v["stuff_count_" .. i] == nil or
				v["stuff_id_" .. i] == 0 or v["stuff_count_" .. i] == 0 then break end
			local stuff_id_count = ItemData.Instance:GetItemNumInBagById(v["stuff_id_" .. i])
			local stuff_need_count = v["stuff_count_" .. i]
			local can_num = math.floor(stuff_id_count / stuff_need_count)
			if can_num > 0 then
				table.insert(can_list, can_num)
			else
				table.insert(can_list, 0)
			end
		end
		if next(can_list) ~= nil then
			min_can_num = math.min(unpack(can_list))
			if min_can_num > 0 then
				return v.product_id
			end
		end
	end

	return min_can_num
end

function ComposeData:GetBagMatList(the_compose_item_list)
	local compose_item_list = the_compose_item_list
	local min_can_num = 0
	local can_list = {}

	for k,v in pairs(compose_item_list) do
		if can_list[v.sub_type] == nil then
			can_list[v.sub_type] = 0
		end

		for i = 1, 3 do
			if v["stuff_id_" .. i] == nil or v["stuff_count_" .. i] == nil or
				v["stuff_id_" .. i] == 0 or v["stuff_count_" .. i] == 0 then break end
			local stuff_id_count = ItemData.Instance:GetItemNumInBagById(v["stuff_id_" .. i])
			local stuff_need_count = v["stuff_count_" .. i]
			local can_num = math.floor(stuff_id_count / stuff_need_count)

			-- if can_num > 0 then
			-- 	--table.insert(can_list[v.sub_type], can_num)
			-- 	can_list[v.sub_type] = can_num
			-- else
			-- 	can_list[v.sub_type] = 0
			-- 	--table.insert(can_list[v.sub_type], 0)
			-- end

			can_list[v.sub_type] = can_num +  can_list[v.sub_type]
		end
	end

	return can_list
end

--一级类型的所有物品
function ComposeData:GetTypeOfAllItem(one_type)  --一级类型
	local list = self:GetComposeList()
	local new_list = {}
	for k,v in pairs(list) do
		if v.type == one_type then
			new_list[#new_list + 1] = v
		end
	end
	function sortfun(a, b)
		return a.producd_seq < b.producd_seq
	end
	table.sort(new_list, sortfun)
	return new_list
end

function ComposeData:SetToProductId(product_id)
	if product_id then
		local compose_cfg = self:GetComposeItem(self:GetProductIdByStuffId(product_id))
		if compose_cfg then
			self.to_product_id = compose_cfg.product_id
		end
	else
		self.to_product_id = product_id
	end
end

function ComposeData:GetToProductId()
	return self.to_product_id
end

-- function ComposeData:GetMaxCompose(item_id)
-- 	local stuff_id_1 = self:GetComposeItem(item_id).stuff_id_1
-- 	local stuff_id_count = ItemData.Instance:GetItemNumInBagById(stuff_id_1)
-- 	local stuff_need_count = self:GetComposeItem(item_id).stuff_count_1
-- 	local product_id_pile_limit = self:GetItemInfo(item_id).pile_limit
-- 	local can_buy_num = 0
-- 	if stuff_id_count/stuff_need_count > product_id_pile_limit then
-- 		can_buy_num = math.floor(product_id_pile_limit)
-- 	else
-- 		can_buy_num = math.floor(stuff_id_count/stuff_need_count)
-- 	end
-- 	if stuff_id_count/stuff_need_count == 0 then
-- 		can_buy_num = 1
-- 	end
-- 	return can_buy_num
-- end

--这一列sub_type是否有可合成的
function ComposeData:GetSubIsHaveCompose(sub_type)
	local the_list = self:GetComposeItemList(sub_type)
	for k,v in pairs(the_list) do
		if self:JudgeMatRich(v.product_id) then
			return true
		end
	end
	return false
end

function ComposeData:GetProductIdByStuffId(stuff_id)
	local the_list = self:GetComposeList()
	for k,v in pairs(the_list) do
		if v.stuff_id_1 == stuff_id then
			return v.product_id
		end
	end
	return 0
end

function ComposeData:GetProductCfg(stuff_id)
	local the_list = self:GetComposeList()
	for k,v in pairs(the_list) do
		if v.stuff_id_1 == stuff_id then
			return v
		end
	end
	return nil
end

function ComposeData:GetCurrentListIndex()
	local sub_type_list = self:GetSubTypeList(ComposeContentView.Instance:GetCurrentType())
	local compose_item_list = {}
	for k,v in pairs(sub_type_list) do
		compose_item_list[#compose_item_list + 1] = self:GetComposeItemList(v)
	end
	local list_index = 0
	for k,v in pairs(compose_item_list) do
		for m,n in pairs(v) do
			local cur_item_id = ComposeContentView.Instance:GetCurrentItemId()
			if self.to_product_id then
				cur_item_id = self.to_product_id
			end
			if n.product_id == cur_item_id then
				list_index = k
				return list_index
			end
		end
	end
	return list_index
end

----新data
function ComposeData:JudgeMatRich(product_id) --判断材料是否足够
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	for i=1,3 do
		if compose_cfg["stuff_id_"..i] ~= 0 then
			if ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i]) <  compose_cfg["stuff_count_"..i] then
				return false
			end
		end
	end
	return true
end

function ComposeData:GetCanByNum(product_id) --获得可合成数量
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	local can_buy_list = {}
	local can_buy_num = 0
	for i=1,3 do
		if compose_cfg["stuff_id_"..i] ~= 0 then
			local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i])
			local cfg_count = compose_cfg["stuff_count_"..i]
			if my_count >= cfg_count  then
				local temp_num = math.floor(my_count / cfg_count)
				table.insert(can_buy_list, temp_num)
			else
				table.insert(can_buy_list, 0) -- 需要存一个值作比较
			end
		end
	end
	if next(can_buy_list) == nil then
		can_buy_num = 0
	else
		can_buy_num = math.min(unpack(can_buy_list))
	end
	return can_buy_num
end

--获得商城中是否有这些物品中的之一
function ComposeData:GetIsHaveItemOfShop(product_id)
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	local shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item
	for k,v in pairs(shop_cfg) do
		if v.itemid == compose_cfg["stuff_id_"..1] or v.itemid == compose_cfg["stuff_id_"..2] or v.itemid == compose_cfg["stuff_id_"..3] then
			return true
		end
	end
	return false
end

--获得商城中是否有该单个物品
function ComposeData:GetIsHaveSingleItemOfShop(product_id, index)
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	local shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item
	for k,v in pairs(shop_cfg) do
		if v.itemid == compose_cfg["stuff_id_"..1] or v.itemid == compose_cfg["stuff_id_"..2] or v.itemid == compose_cfg["stuff_id_"..3] then
			return true
		end
	end
	return false
end

--单个物品是否足够合成
function ComposeData:GetSingleMatRich(product_id,index)
	local compose_cfg = ComposeData.Instance:GetComposeItem(product_id)
	if compose_cfg["stuff_id_"..index] == 0 then
		return true
	end
	local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..index])
	local cfg_count = compose_cfg["stuff_count_"..index]
	if my_count > cfg_count then
		return true
	else
		return false
	end
end

function ComposeData:GetEnoughMatEqualNeedCount(item_id)
	local compose_cfg = self:GetComposeItem(item_id)
	if compose_cfg == nil then return false end
	for i=1,3 do
		if compose_cfg["stuff_id_"..i] ~= 0 then
			local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i])
			local cfg_count = compose_cfg["stuff_count_"..i]
			if my_count ~= cfg_count then
				return false
			end
		end
	end
	return true
end

function ComposeData:GetShowItemId(the_type, sub_type)
	local first_list = self:GetComposeItemList(sub_type)
	for _,v in pairs(first_list) do
		if self:JudgeMatRich(v.product_id) then
			return v.product_id
		end
	end
	sub_type_list = self:GetSubTypeList(the_type)
	for k,v in pairs(sub_type_list) do  --移除遍历过的
		if v == sub_type then
			table.remove(sub_type_list, k)
			break
		end
	end
	for _,v in pairs(sub_type_list) do
		local the_list = self:GetComposeItemList(v)
		for _,v2 in pairs(the_list) do
			if self:JudgeMatRich(v2.product_id) then
				return v2.product_id
			end
		end
	end
	return -1
end

function ComposeData:GetCountText(product_id)
	local list = {}
	local compose_cfg = self:GetComposeItem(product_id)
	for i=1,3 do
		local text = ""
		if compose_cfg["stuff_id_"..i] ~= 0 then
			local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i])
			local cfg_count = compose_cfg["stuff_count_"..i]
			local green_text = ToColorStr(tostring(cfg_count), TEXT_COLOR.BLACK_1)
			local my_count_text = ""
			if my_count >= cfg_count then
				my_count_text = ToColorStr(tostring(my_count), TEXT_COLOR.GREEN_4)
				text = my_count_text .. "/" .. green_text
			else
				my_count_text = ToColorStr(tostring(my_count), TEXT_COLOR.RED)
				text = my_count_text .. "/" .. green_text
			end
		end
		table.insert(list, text)
	end
	return list
end