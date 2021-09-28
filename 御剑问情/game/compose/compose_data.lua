ComposeData = ComposeData or BaseClass()

ComposeData.Type = {
	stone = 1,
	jinjie = 2,
	other = 3,
	equip = 4,
}

function ComposeData:__init()
	if ComposeData.Instance then
		print_error("[ComposeData] Attemp to create a singleton twice !")
	end
	ComposeData.Instance = self

	self.compose_menu_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("compose_auto").compose_menu, "type")

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
	-- local compose_list = self:GetTypeOfAllItem(ComposeData.Type.stone)
	-- local can_compose_id = self:CheckBagMat(compose_list)
	-- if can_compose_id > 0 then
	-- 	flag = 1
	-- end

	return flag
end

--改变其他红点
function ComposeData:CalcOtherRedPoint()
	local flag = 0
	-- local compose_list = self:GetTypeOfAllItem(ComposeData.Type.other)
	-- local can_compose_id = self:CheckBagMat(compose_list)
	-- if can_compose_id > 0 then
	-- 	flag = 1
	-- end

	return flag
end

--改变锻造红点
function ComposeData:CalcJinjieRedPoint()
	local flag = 0
	-- local compose_list = self:GetTypeOfAllItem(ComposeData.Type.jinjie)
	-- local can_compose_id = self:CheckBagMat(compose_list)
	-- if can_compose_id > 0 then
	-- 	flag = 1
	-- end

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

function ComposeData:GetComposeCfgList(compose_type)
	return self.compose_menu_cfg[compose_type]
end

function ComposeData:GetComposeTypeOfCount(compose_type)
	if self.compose_menu_cfg[compose_type] then
		return #self.compose_menu_cfg[compose_type]
	end

	return 0
end

function ComposeData:GetComposeTypeOfNameList(compose_type)
	local name_list = {}
	if nil == self.compose_menu_cfg[compose_type] then
		return name_list
	end

	for _, v in ipairs(self.compose_menu_cfg[compose_type]) do
		table.insert(name_list, v.sub_name)
	end

	return name_list
end

--通过一级类型获取二级类型
function ComposeData:GetSubTypeList(compose_type)
	local temp_list = {}
	if nil == self.compose_menu_cfg[compose_type] then
		return temp_list
	end

	for _, v in ipairs(self.compose_menu_cfg[compose_type]) do
		table.insert(temp_list, v.sub_type)
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
		return a.product_id < b.product_id
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
	for k,v in pairs(compose_item_list) do
		local stuff_id_count = ItemData.Instance:GetItemNumInBagById(v.stuff_id_1)
		local stuff_need_count = v.stuff_count_1
		if stuff_need_count <= stuff_id_count then
			return v.product_id
		end
	end
	return 0
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

function ComposeData:GetProductCfg(stuff_id,ignore_t)
	ignore_t = ignore_t or {}
	local the_list = self:GetComposeList()
	for k,v in pairs(the_list) do
		if v.stuff_id_1 == stuff_id and not ignore_t[v.type] then
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
	local list_index = 1
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
	local can_buy_num = nil
	for i=1,3 do
		if compose_cfg["stuff_id_"..i] ~= 0 then
			local my_count = ItemData.Instance:GetItemNumInBagById(compose_cfg["stuff_id_"..i])
			local cfg_count = compose_cfg["stuff_count_"..i]
			if my_count >= cfg_count  then
				local temp_num = math.floor(my_count/cfg_count)
				if can_buy_num == nil then
					can_buy_num = temp_num
				else
					if temp_num <= can_buy_num then
						can_buy_num = temp_num
					end
				end
			end
		end
	end
	if can_buy_num == nil then
		can_buy_num = 0
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
				my_count_text = ToColorStr(tostring(my_count), TEXT_COLOR.BLUE_SPECIAL)
				text = my_count_text .. " / " .. green_text
			else
				my_count_text = ToColorStr(tostring(my_count), TEXT_COLOR.RED)
				text = my_count_text .. " / " .. green_text
			end
		end
		table.insert(list, text)
	end
	return list
end

function ComposeData:GetShenShouComposeTypeOfCount()
	return #self:GetSSEquipHeChengAccordionDataList()
end

function ComposeData:GetShenShouComposeTypeOfNameList()
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	local role_level = PlayerData.Instance:GetRoleLevel()
	local data_list = {}
	for k, v in ipairs(equipforge_cfg.equip_exchange) do
		if role_level >= v.level then
			local name = CommonDataManager.GetDaXie(v.compose_equip_best_attr_num) .. Language.Compose.HeChengItemFatherName[v.type]
			table.insert(data_list, name)
		end
	end
	return data_list
end

function ComposeData:GetShenShouComposeItemList(sub_type)
	local list = {}
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	for k, v in ipairs(equipforge_cfg.equip_exchange) do
		if sub_type == v.type then
			table.insert(list, v)
			break
		end
	end
	return list
end

function ComposeData:GetSehnShouSubTypeList()
	local list = {}
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	local role_level = PlayerData.Instance:GetRoleLevel()
	local data_list = {}
	for k, v in ipairs(equipforge_cfg.equip_exchange) do
		if role_level >= v.level then
			local type = v.type
			table.insert(list, type)
		end
	end
	return list
end

function ComposeData:OnClickAccordionSSHechengChild(data)
	local equip_ss_hecheng_list = {}
	if data and next(data) then
		for index = 1, 5 do
			if data["cao" .. index] ~= nil and data["cao" .. index] ~= 0 then
				local param_t = {}
				param_t.star_level = data.compose_equip_best_attr_num
				local data_vo = {item_id = data["cao" .. index], compose_equip_best_attr_num = data.compose_equip_best_attr_num, type = data.type, param = param_t}
				table.insert(equip_ss_hecheng_list, data_vo)
			end
		end
	end
	return equip_ss_hecheng_list
end

function ComposeData:GetSSEquipHeChengAccordionDataList()
	local equipforge_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto")
	local role_level = PlayerData.Instance:GetRoleLevel()
	local data_list = {}
	for k, v in ipairs(equipforge_cfg.equip_exchange) do
		if role_level >= v.level then
			if data_list[v.type * 100 + v.compose_equip_best_attr_num] == nil then
				data_list[v.type * 100 + v.compose_equip_best_attr_num] = {}
			end
			table.insert(data_list[v.type * 100 + v.compose_equip_best_attr_num], v)
		end
	end

	local acc_data_list = {}
	for k, child_list in pairs(data_list)do
		local item_data = {}
		for k,v in ipairs(child_list)do
			table.insert(item_data, v)
		end
		table.insert(acc_data_list, {child = item_data, star_level = item_data[1].compose_equip_best_attr_num, name_type = item_data[1].type})
	end

	return acc_data_list
end

-- 获取兑换菜单列表
function ComposeData:GetDuihuanMenuList()
	local cfg = ConfigManager.Instance:GetAutoConfig("compose_auto").duihuan_menu
	local list = {}
	for i=1,#cfg do
		if #self:GetItemIdListBySubType(cfg[i].type, cfg[i].sub_type) > 0 then
			table.insert(list, cfg[i])
		end
	end
	return list
end

function ComposeData:GetItemIdListBySubType(type, sub_type)
	local all_item_cfg = self:GetComposeList()
	local item_id_list = {}
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k,v in pairs(all_item_cfg) do
		if v.type == type and v.visible_open_day <= day then
			item_id_list[#item_id_list + 1] = v
		end
	end

	table.sort(item_id_list, function (a, b)
		if a.visible_open_day > b.visible_open_day then
			return true
		elseif a.visible_open_day == b.visible_open_day and a.producd_seq < b.producd_seq then
			return true
		end
		return false
	end)

	return item_id_list
end

function ComposeData:GetItemListByTypeAndIndex(type, sub_type, index)
	local item_id_list = self:GetItemIdListBySubType(type, sub_type)
	local job_id_list = {}
	if index == 1 then
		for i=1,8 do
			job_id_list[#job_id_list + 1] = item_id_list[i] or {}
		end
		return job_id_list
	end

	for i=1,8 do
		if item_id_list[(index - 1)*8 + i] == nil then
			item_id_list[(index - 1)*8 + i] = {}
		end
		job_id_list[#job_id_list + 1] = item_id_list[(index - 1)*8 + i]
	end
	return job_id_list
end