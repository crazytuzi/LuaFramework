module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_warehouse = i3k_class("wnd_warehouse", ui.wnd_base)

local QJ_WIDGETS = "ui/widgets/dj1"
local RowitemCount = 5
local EXPAND_GRADEICON = 453 --扩展背包底框

local WAREHOUSE_TYPE_DESC = {"个人仓库", "公共仓库", "家园仓库"}
-- aroundType around两种类型
local AROUND_WARE_HOUSE	= 1 -- 仓库(个人仓库，公共仓库，家园仓库)
local AROUND_ITEM		= 2 -- 右侧(全部，装备，筛选)
local SEARCHNAME1 =""
local SEARCHNAME2 = ""
local HAVEITEMS = false
function wnd_warehouse:ctor()
	-- around 按钮分组， around为1时 左侧(个人仓库，公共仓库，家园仓库)
	-- around为2时 右侧(全部，装备，筛选)
	self.around = 2
	-- 三种仓库 i3k_global定义 #仓库类型#
	self.warehouseType = 1
	-- 右侧(全部，装备，筛选)
	self.bagType = 1
	-- 筛选
	self.filterType = 1
	self.bag_items_changed = false
	self._fun = {}
	self.count = 0
	self.isbagSearch = false
	self.isckSearch  = false
end

function wnd_warehouse:configure()
	local widgets = self._layout.vars
	self.scroll1 = widgets.scroll1
	self.scroll2 = widgets.scroll2

	widgets.warehouse_btn:stateToPressed()
	widgets.all_btn:stateToPressed(true)
	widgets.personage_btn:stateToPressed(true)

	widgets.gradeLabel:setText(i3k_get_string(1086))

	local filterStrs = self:getFilterStrs()
	widgets.filterBtn:onClick(self,function ()
		if widgets.levelRoot:isVisible() then
			widgets.levelRoot:setVisible(false)
		else
			widgets.levelRoot:setVisible(true)
			widgets.filterScroll:removeAllChildren();
			for i = 1, #filterStrs do
				local _item = require("ui/widgets/bgsxt")();
				_item.id = i;
				_item.vars.levelLabel:setText(filterStrs[i])
				_item.vars.levelBtn:onClick(self, function ()
					widgets.levelRoot:setVisible(false)
					widgets.gradeLabel:setText(_item.vars.levelLabel:getText())
					self.filterType = _item.id
					self:setBagShowType(self, {around = AROUND_ITEM, showType = 3}, true)
				end)
				widgets.filterScroll:addItem(_item);
			end
		end
	end)

	widgets.add_diamond:onClick(self, self.addDiamondBtn)
	widgets.add_coin:onClick(self, self.addCoinBtn)
	widgets.fashion_btn:onClick(self, self.onFashionBtn)
	widgets.bag_btn:onClick(self, self.onBagBtn)
	widgets.role_btn:onClick(self, self.onRoleBtn)
	widgets.cksearch_btn:onClick(self,self.onCkSearchBtn) --查找按钮
	widgets.ckreturn_btn:onClick(self,self.onCkReturnBtn) --返回按钮
	widgets.bagsearch_btn:onClick(self,self.onBagSearchBtn)
	widgets.bagreturn_btn:onClick(self,self.onBagReturnBtn)

	widgets.equip_btn:disableWithChildren()
	self.bagItemTypeButton = {{widgets.personage_btn, widgets.commonality_btn, widgets.homelandBtn},{widgets.all_btn,nil, widgets.gradeBtn}}--widgets.equip_btn
	for i, e in pairs(self.bagItemTypeButton) do
		for k,v in pairs(e) do
			v:onClick(self, self.setBagShowType, {around = i, showType = k})
		end
	end

	widgets.sz_redPoint:setVisible(g_i3k_game_context:getFashionRedPoint())
	widgets.bg_redPoint:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2())

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	self._fun = {i3k_game_context.GetWarehouseInfoForType,i3k_game_context.GetBagInfo}
	self._layout.vars.noItemTips:setText(i3k_get_string(15522))
	widgets.quickStoreBtn:onClick(self, self.onQuickStoreBtn)
end

function wnd_warehouse:getFilterStrs()
	local strs = {}
	table.insert(strs, i3k_get_string(1086)) -- 装备index 1
	for index = 1, 10 do
		table.insert(strs, i3k_get_string(15483 + index))
	end
	table.insert(strs, i3k_get_string(15596)) -- 家园
	table.insert(strs, i3k_get_string(15597)) -- 暗器
	return strs
end

function wnd_warehouse:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_warehouse:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_warehouse:updateMoney(diamondF, diamondR, coinF, coinR)
	self._layout.vars.diamond:setText(diamondF)
	self._layout.vars.diamondLock:setText(diamondR)
	self._layout.vars.coin:setText(i3k_get_num_to_show(coinF))
	self._layout.vars.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_warehouse:refresh(warehouseType, daibis)
	self.warehouseType = warehouseType
	self.bagType = 1
	self._layout.vars.quickStoreIcon:setVisible(g_i3k_game_context:getQuickStoreState())
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
	for i, e in ipairs(self._fun) do
		local size,items = e(g_i3k_game_context, warehouseType)
		self:updateBag(i, size, items, daibis)
	end
end

function wnd_warehouse:updateBag(around, bagSize, BagItems, daibis) -- 左侧scroll 物品信息的遍历并排序
	self["scroll" .. around]:removeAllChildren()
	local items = self:itemSort(BagItems)
	local nowBagSize
	if self.isckSearch == true then
		nowBagSize = around == AROUND_WARE_HOUSE and bagSize or bagSize
	else
		nowBagSize = around == AROUND_WARE_HOUSE and bagSize + RowitemCount or bagSize
	end
	local all_layer = self["scroll" .. around]:addChildWithCount(QJ_WIDGETS,RowitemCount,nowBagSize)
	local cell_index = 1
	local Type = around == AROUND_WARE_HOUSE and self.warehouseType or self.bagType
	--筛选判断
	for i,e in ipairs(items) do
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		if around == AROUND_ITEM then
			if (self.bagType == 1 and stack_count > 0)
			or (self.bagType == 3 and self.filterType == 1 and self.bagType == self:getBagItemShowType(e.id,around)) --下拉第一个装备，
			or (self.bagType == 3 and self.filterType == g_i3k_db.i3k_db_getItemFilter(e.id) +1 and stack_count > 0) then--因为道具表里有filter显示第几个字段，之前定死的。现在需求改了，第一个多加一个装备
				
				local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
				for k=1,cell_count do
					if all_layer[cell_index] then
						local widget = all_layer[cell_index].vars
						local itemCount = k == cell_count and e.count-(cell_count-1)*stack_count or stack_count
						self:updateCell(widget, e.id, itemCount, e.guids[k], around)
						self:setUpIsShow(e.id, e.guids[k], widget, around)
						cell_index = cell_index + 1
					end
				end
			end

		else
			if Type == self:getBagItemShowType(e.id, around) and stack_count > 0 then
				--local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
				local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
				for k=1,cell_count do
					if all_layer[cell_index] then
						local widget = all_layer[cell_index].vars
						local itemCount = k == cell_count and e.count-(cell_count-1)*stack_count or stack_count
						self:updateCell(widget, e.id, itemCount, e.guids[k], around)
						self:setUpIsShow(e.id, e.guids[k], widget, around)
						cell_index = cell_index + 1
					end
				end
			end

				
			if daibis and Type == self:getBagItemShowType(e.id, around) and stack_count == 0 then
				table.insert(daibis, e)
					end
				end
			end
	

	for k = cell_index, nowBagSize do
		local widget = all_layer[k].vars
		self:updateCell(widget, 0, 0, nil, around)
		widget.bt:disable()
		if k > bagSize then
			widget.bt:enable()
			widget.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(EXPAND_GRADEICON))
			widget.bt:onClick(self, self.packageExtend, around)
		end
		if around ~= 1 then
			widget.bt:setVisible(self.bagType == 1)

		end
	end
	if self.bagType ~= 1 then
		self._layout.vars.noItemTips:setVisible(cell_index == 1)
	else
		self._layout.vars.noItemTips:setVisible(false)
	end
	self.bag_items_changed = false

end

function wnd_warehouse:itemSort(items)
	local sort_items = {}
	for k,v in pairs(items) do
		local guids = {}
		local sorit = g_i3k_db.i3k_db_get_bag_item_order(k)
		for kk, vv in pairs(v.equips) do
			table.insert(guids, kk)
		end
		table.insert(sort_items, { sortid = g_i3k_db.i3k_db_get_bag_item_order(k), id = v.id, count = v.count, guids = guids})
	end
	table.sort(sort_items,function (a,b)
		return a.sortid < b.sortid
	end)
	return sort_items
end

function wnd_warehouse:updateCell(widget, id, count, guid, around)
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widget.item_count:setText(count)
	if guid or count <= 0 then
		widget.item_count:hide()
		self:setMaskIsShow(id, widget)
	else
		widget.item_count:show()
	end

	if g_i3k_db.i3k_db_get_bag_item_stack_max(id) == 0 then
		widget.suo:setVisible(false)
	else
		widget.suo:setVisible(id>0)
	end

	local isCanSave = g_i3k_db.i3k_db_get_bag_item_warehouseType(id, self.warehouseType)
	if isCanSave and around == AROUND_ITEM then
		widget.save:setVisible(true);
		if self.warehouseType == g_PUBLIC_WAREHOUSE then
			if id > 0 then
				widget.save:setVisible(false);
			end
		end
	else
		widget.save:setVisible(false);
	end
	if g_i3k_game_context:getQuickStoreState() then
		if around == AROUND_ITEM then
			if isCanSave then
				if self.warehouseType == g_PUBLIC_WAREHOUSE then
					if id > 0 then
						widget.bt:disableWithChildren()
					end
				end
			else
				if id ~= 0 then
					widget.bt:disableWithChildren()
				end
			end
		end
	end
	if not guid and g_i3k_db.i3k_db_get_bag_item_fashion_able(id) then
		widget.bt:onClick(self, self.onFashionTips, {is_select = widget.is_select, id = id, isCanSave = isCanSave, around = around})
	elseif not guid and g_i3k_db.i3k_db_get_bag_item_metamorphosis_able(id) then
		widget.bt:onClick(self, self.onMetamorphosisTips, {is_select = widget.is_select, id = id, isCanSave = isCanSave, around = around})	
	else
		widget.bt:onClick(self, guid and self.onEquipTips or self.onItemTips, {is_select = widget.is_select, id = id, guid = guid, isCanSave = isCanSave, around = around})
	end
end

function wnd_warehouse:setMaskIsShow(id, widget)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
		if equip_cfg.roleType == 0 and g_i3k_game_context:GetLevel() >= equip_cfg.levelReq then--装备全系,不分职业
			widget.is_show:hide()
		elseif g_i3k_game_context:GetRoleType() ~= equip_cfg.roleType or g_i3k_game_context:GetLevel() < equip_cfg.levelReq then
			widget.is_show:show()
		else
			if equip_cfg.C_require ~= 0 then
				widget.is_show:setVisible(g_i3k_game_context:GetTransformLvl() < equip_cfg.C_require)
			else
				widget.is_show:hide()
			end
		end
	end
end

function wnd_warehouse:setUpIsShow(id, guid, widget, around)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
		if g_i3k_game_context:GetRoleType() == equip_cfg.roleType or equip_cfg.roleType == 0 then
			local equip = around == 1 and g_i3k_game_context:GetWarehouseEquip(id, guid, self.warehouseType) or g_i3k_game_context:GetBagEquip(id, guid)
			local wearEquips = g_i3k_game_context:GetWearEquips()
			local _data = wearEquips[equip_cfg.partID].equip
			if _data then
				local wAttribute = _data.attribute
				local wNaijiu = _data.naijiu
				local wEquip_id = _data.equip_id
				local wPower = g_i3k_game_context:GetBagEquipPower(wEquip_id,wAttribute,wNaijiu,_data.refine,_data.legends, _data.smeltingProps)
				local total_power = g_i3k_game_context:GetBagEquipPower(id,equip.attribute,equip.naijiu,equip.refine,equip.legends, equip.smeltingProps)
				widget.isUp:show()
				if wPower > total_power then
					widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				elseif wPower < total_power then
					widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				else
					widget.isUp:hide()
				end
			else
				widget.isUp:show()
				widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
			end

		end
	end
end

function wnd_warehouse:getBagItemShowType(id, around)
	if around ~= AROUND_WARE_HOUSE then
		if self.bagType == 1 then
			return self.bagType
		end
		return g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP and 3 or 4 --装备已经在下拉中显示了
	end
	return self.warehouseType
end

function wnd_warehouse:setBagShowType(sender, data, force)
	self.isckSearch = false
	self._layout.vars.cksearch_btn:setVisible(true)
	self._layout.vars.ckreturn_btn:setVisible(false)
	self.isckSearch = false
	self._layout.vars.ckTips:setVisible(false)
	self.isbagSearch = false
	if data.around == AROUND_WARE_HOUSE and data.showType == g_PUBLIC_WAREHOUSE then
		local step = g_i3k_game_context:getRecordSteps()
		if step == -1 then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(846))
		else
		if g_i3k_game_context:getMarryType()==1 then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17900))
		else
			i3k_sbean.public_warehouse();
			end
		end
	end

	if data.around == AROUND_WARE_HOUSE and data.showType == g_PERSONAL_WAREHOUSE then
		i3k_sbean.private_warehouse();
	end

	if data.around == AROUND_WARE_HOUSE and data.showType == g_HOMELAND_WAREHOUSE then
		if g_i3k_game_context:GetHomeLandLevel() == 0 then
			return g_i3k_ui_mgr:PopupTipMessage("拥有家园后自动启动家园仓库")
		end
		i3k_sbean.sync_homeland_warehouse()
	end

	if not force and self.bagItemTypeButton[data.around][data.showType]:isStatePressed() then
		return
	end

	self.around = data.around
	for _,v in pairs(self.bagItemTypeButton[self.around]) do
		v:stateToNormal(true)
	end
	self.bagItemTypeButton[self.around][data.showType]:stateToPressed(true)
	if self.around == AROUND_WARE_HOUSE then
		self.warehouseType = data.showType
	else
		self.bagType = data.showType
	end
	self:updateBag(self.around, self._fun[self.around](g_i3k_game_context, self.warehouseType))
	self["scroll" .. self.around]:jumpToListPercent(0)
	--self:updateBag(AROUND_WARE_HOUSE,self._fun[AROUND_WARE_HOUSE](g_i3k_game_context, self.warehouseType))
end

function wnd_warehouse:onItemTips(sender, args)
	if g_i3k_game_context:getQuickStoreState() then
		self:onSaveItem(args)
	else
	self:setCellIsSelectHide()
	args.is_select:show()
	self.around = args.around
	local count = args.around == 1 and g_i3k_game_context:GetWarehouseItemCount(args.id, self.warehouseType) or g_i3k_game_context:GetCommonItemCount(args.id)
	local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(args.id)
	local nowCount = count > stack_count and stack_count or count
	local tab = {around = args.around, warehouseType = self.warehouseType, id = args.id, count = nowCount, isCanSave = args.isCanSave}
	g_i3k_ui_mgr:OpenUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_BagItemInfo, args.id, tab)
end
end

function wnd_warehouse:onEquipTips(sender, args)
	if g_i3k_game_context:getQuickStoreState() then
		self:onSaveItem(args)
	else
	self:setCellIsSelectHide()
	args.is_select:show()
	self.around = args.around
	local tab = {around = args.around, warehouseType = self.warehouseType, id = args.id, count = 1, isCanSave = args.isCanSave, guid = args.guid}
	local equip = args.around == 1 and g_i3k_game_context:GetWarehouseEquip(args.id, args.guid, self.warehouseType) or g_i3k_game_context:GetBagEquip(args.id, args.guid)
		local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip.equip_id)
		if g_i3k_game_context:isFlyEquip(equipCfg.partID) then
			g_i3k_ui_mgr:OpenUI(eUIID_FlyingEquipInfo)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipInfo, "updateBagEquipInfo", equip, tab)
		else
	g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "updateBagEquipInfo", equip, tab)
		end
end
end

function wnd_warehouse:onFashionTips(sender, args)
	if g_i3k_game_context:getQuickStoreState() then
		self:onSaveItem(args)
	else
	self:setCellIsSelectHide()
	args.is_select:show()
	self.around = args.around
	local tab = {around = args.around, warehouseType = self.warehouseType, id = args.id, count = 1, isCanSave = args.isCanSave}
	g_i3k_ui_mgr:OpenUI(eUIID_FashionDressTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_FashionDressTips, args.id ,true, nil, tab)
	end
end

--幻形onMetamorphosisTips
function wnd_warehouse:onMetamorphosisTips(sender, args)
	if g_i3k_game_context:getQuickStoreState() then
		self:onSaveItem(args)
	else
	self:setCellIsSelectHide()
	args.is_select:show()
	self.around = args.around
	local tab = {around = args.around, warehouseType = self.warehouseType, id = args.id, count = 1, isCanSave = args.isCanSave}
	g_i3k_ui_mgr:OpenUI(eUIID_MetamorphosisDressTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_MetamorphosisDressTips, args.id ,tab)
	end
end
function wnd_warehouse:setCellIsSelectHide()
	for i = 1, 2 do
		for _, e in ipairs(self["scroll" .. i]:getAllChildren()) do
			e.vars.is_select:hide()
		end
	end
end

function wnd_warehouse:onUpdate(dTime)
	if self.bag_items_changed then
		for i,e in ipairs(self._fun) do
			self:updateBag(i, e(g_i3k_game_context, self.warehouseType))
		end
		self:onUpdateType()
	end
end
function wnd_warehouse:onUpdateType()
	if HAVEITEMS == true then
		if self.isckSearch == true and self.isbagSearch == true then
			self:searchItemInWarehouse(SEARCHNAME1)
			self:searchItemInBag(SEARCHNAME2)
		elseif self.isckSearch == true then
			self:searchItemInWarehouse(SEARCHNAME1)
		end
	end
	if  self.isbagSearch== true then
		self:searchItemInBag(SEARCHNAME2)
	end
	self._layout.vars.ckTips:setVisible(false)
end

function wnd_warehouse:setBagItemsChanged()
	self.bag_items_changed = true
end

function wnd_warehouse:packageExtend(sender, around)
	local wareHouseCfg = i3k_db_common.warehouse
	self.around = around
	local expandTimes = g_i3k_game_context:GetWarehouseExpandTimesForType(self.warehouseType)
	expandTimes = expandTimes + 1
	local desc = WAREHOUSE_TYPE_DESC[self.warehouseType]
	if expandTimes > wareHouseCfg["expandNumber" .. self.warehouseType] then
		g_i3k_ui_mgr:PopupTipMessage(desc .. "扩充已达上限，扩充失败。")
	else
		local itemID = self.warehouseType == g_HOMELAND_WAREHOUSE and wareHouseCfg.useItemId3 or wareHouseCfg.useItemId
		g_i3k_ui_mgr:OpenUI(eUIID_Bag_extend)
		g_i3k_ui_mgr:RefreshUI(eUIID_Bag_extend,{
			desc = i3k_get_string(15475),
			itemId = itemID,
			costCount = g_i3k_db.i3k_db_get_bag_extend_price(expandTimes, self.warehouseType),
			itemCount = g_i3k_db.i3k_db_get_bag_extend_itemCount(expandTimes, self.warehouseType),
			expandTimes = expandTimes,
			warehouseType = self.warehouseType
		})
	end
end

function wnd_warehouse:onBagBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_Warehouse)
	g_i3k_logic:OpenBagUI()
end

function wnd_warehouse:onRoleBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_Warehouse)
	g_i3k_logic:OpenRoleLyUI2()
end

function wnd_warehouse:onFashionBtn(sender)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
	g_i3k_logic:OpenFashionDressUI(nil, eUIID_Warehouse)
	end
end

function wnd_warehouse:onCkSearchBtn()
	g_i3k_ui_mgr:OpenUI(eUIID_BagSearch)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BagSearch,"setSearchType",AROUND_WARE_HOUSE)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BagSearch,"setWarehouseType",self.warehouseType)

end
--返回按钮
function wnd_warehouse:onCkReturnBtn()
	self._layout.vars.cksearch_btn:setVisible(true)
	self._layout.vars.ckreturn_btn:setVisible(false)
	self.isckSearch = false
	self._layout.vars.ckTips:setVisible(false)
	self:updateBag(AROUND_WARE_HOUSE,self._fun[AROUND_WARE_HOUSE](g_i3k_game_context, self.warehouseType))
end

function wnd_warehouse:onBagSearchBtn()
	g_i3k_ui_mgr:OpenUI(eUIID_BagSearch)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BagSearch,"setSearchType",AROUND_ITEM)
end

function wnd_warehouse:onBagReturnBtn()
	self._layout.vars.bagsearch_btn:setVisible(true)
	self._layout.vars.bagreturn_btn:setVisible(false)
	self.isbagSearch = false
	self:updateBag(AROUND_ITEM,self._fun[AROUND_ITEM](g_i3k_game_context, self.bagType))
end

function wnd_warehouse:isCkSearch()
	self.isckSearch = true
	self._layout.vars.cksearch_btn:setVisible(false)
	self._layout.vars.ckreturn_btn:setVisible(true)
end
function wnd_warehouse:isBagSearch()
	self.isbagSearch = true
	self._layout.vars.bagsearch_btn:setVisible(false)
	self._layout.vars.bagreturn_btn:setVisible(true)
end
function wnd_warehouse:CKNoItemTips()
	self["scroll" .. AROUND_WARE_HOUSE]:removeAllChildren()
	self._layout.vars.ckTips:setVisible(true)
end
function wnd_warehouse:BagNoItemTips()
	self["scroll" .. AROUND_ITEM]:removeAllChildren()
	self._layout.vars.noItemTips:setVisible(true)
end

function wnd_warehouse:setCkSearchName(keyword)
	SEARCHNAME1=keyword
end
--背包搜索到的物品
function wnd_warehouse:setBagSearchName(keyword)
	SEARCHNAME2=keyword
end

function wnd_warehouse:searchItemInWarehouse(keyWord)
	local _, BagItems = g_i3k_game_context:GetWarehouseInfoForType(self.warehouseType)
	local newTab=g_i3k_db.i3k_db_get_items_after_search(BagItems,keyWord)
	self.count = g_i3k_db.i3k_db_get_search_items_count(newTab)
	self:updateBag(AROUND_WARE_HOUSE,self.count,newTab)
	self._layout.vars.ckTips:setVisible(false)
end

function wnd_warehouse:searchItemInBag(keyWord)
	local _, BagItems = g_i3k_game_context:GetBagInfo()
	local newTab=g_i3k_db.i3k_db_get_items_after_search(BagItems,keyWord)
	self.count = g_i3k_db.i3k_db_get_search_items_count(newTab)
	self:updateBag(AROUND_ITEM,self.count,newTab)
end
function wnd_warehouse:haveItems(isHave)
	HAVEITEMS = isHave
end

function wnd_warehouse:onQuickStoreBtn(sender)
	g_i3k_game_context:changeQuickStoreState()
	self._layout.vars.quickStoreIcon:setVisible(g_i3k_game_context:getQuickStoreState())
	local size, items = g_i3k_game_context:GetBagInfo()
	self:updateBag(2, size, items)
end
function wnd_warehouse:onSaveItem(args)
	local count = args.around == 1 and g_i3k_game_context:GetWarehouseItemCount(args.id, self.warehouseType) or g_i3k_game_context:GetCommonItemCount(args.id)
	local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(args.id)
	local nowCount = count > stack_count and stack_count or count
	if args.around == 1 then
		i3k_sbean.goto_take_out_warehouse(args.id, nowCount, self.warehouseType, args.guid)
	elseif args.around == 2 then
		i3k_sbean.goto_put_in_warehouse(args.id, nowCount, self.warehouseType, args.guid)
	end
end
function wnd_create(layout)
	local wnd = wnd_warehouse.new();
		wnd:create(layout);
	return wnd;
end
