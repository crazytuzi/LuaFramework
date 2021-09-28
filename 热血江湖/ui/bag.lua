-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------

wnd_bag = i3k_class("wnd_bag",ui.wnd_profile)

local QJ_WIDGETS = "ui/widgets/dj1"
local RowitemCount = 5       --每行5个格子
local EXPAND_GRADEICON = 453 --扩展背包底框
local ONE = 1
local ISSEARCH = false
local KEYWORD--查找到的物品

--显示不同类型中对应其满足条件的物品 1:除代币条件， 2：是代币条件 3：筛选
local SHOWTYPE_ALL = 1
local SHOWTYPE_DAIBI = 2
local SHOWTYPE_FILTER = 3

--ITEM显示只分代币和非代币
local ITEMSHOWTYPE_DAIBI = 1 --代币
local ITEMSHOWTYPE_OTHERS = 2 --非代币

local SHOW_TIME = 3 --代币tips显示时间
local FILTER_EQUIP	= 1 --筛选第一个，装备

local DAIBI_SHOW_MAX_TIMES = 3 --代币tips的显示次数
function wnd_bag:ctor()
	self.bag_items_changed = false  --背包item改变
	self.showType = 1            --显示类型   1:全部，2：代币，3：其他
	self.showItemID = nil		--显示物品的ID
	self.filterType = 1			--筛选类型
	self.changeIcon = false  --是否改变ICON
	self.count = 0             --查找到的物品所占用的格子

	self.record_time = 0 --记录时间
end
--初始化
function wnd_bag:configure()
	local widgets = self._layout.vars
	widgets.add_diamond:onClick(self, self.addDiamondBtn)
	widgets.add_coin:onClick(self , self.addCoinBtn)
	if g_i3k_game_context:GetIsGlodCoast() then
		widgets.add_diamond_img:disable()
		widgets.add_coin_img:disable()
	end
	widgets.yjhb_btn:onClick(self, self.quickCombined)
	widgets.warZoneCard:onClick(self, self.onWarZoneCard) -- 战区卡片
	widgets.gradeLabel:setText(i3k_get_string(1086))
   	--下拉列表
   	--添加新筛选类型filterNum + 1
	local filterStrs = self:getFilterStrs()
	widgets.filterBtn:onClick(self,function ()
		if widgets.levelRoot:isVisible() then                 --如果下拉列表已经显示
			widgets.levelRoot:setVisible(false)				 --则把列表关闭
		else
			widgets.levelRoot:setVisible(true)					--如果没显示就打开下拉列表
			widgets.filterScroll:removeAllChildren();          --清空scroll
			for i = 1, #filterStrs do
				local _item = require("ui/widgets/bgsxt")();
				_item.id = i;
				_item.vars.levelLabel:setText(filterStrs[i]);
				_item.vars.levelBtn:onClick(self, function ()
					widgets.levelRoot:setVisible(false)                          --点击之后关闭下拉列表
					widgets.gradeLabel:setText(_item.vars.levelLabel:getText())  --背包面板的显示更变
					self.filterType = _item.id
					self:setBagShowType(3, true)
				end)
				widgets.filterScroll:addItem(_item);       --添加到scroll
			end
		end
	end)

	self.scroll = widgets.scroll

	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon
	self.bg_redPoint = widgets.bg_redPoint
	self.sz_redPoint = widgets.sz_redPoint
	self:initWearEquipWidget(widgets)

	--飞升部分修改
	self:initEquipBtnState(widgets, true)
	widgets.bag_btn:stateToPressed()
	widgets.all_btn:stateToPressed(true)
	self.bagItemTypeButton = {widgets.all_btn, widgets.equip_btn, widgets.gradeBtn}

	for i, e in ipairs(self.bagItemTypeButton) do
		e:onClick(self, self.onShowTypeChanged, i)
	end

	widgets.sale_bat:onClick(self, self.onSaleBatButton)
	widgets.fashion_btn:onClick(self, self.onFashionBtn)
	widgets.role_btn:onClick(self, self.onRoleBtn)
	widgets.warehouse_btn:onClick(self, self.onWarehouseBtn)
	widgets.yjzb_btn:onClick(self, self.onAutoWearButton)

	--[[widgets.streng_pro:onClick(self, self.onStrengTips)
	widgets.up_star_pro:onClick(self, self.onUpStarTips)
	widgets.suit_btn:onClick(self, self.onSuitEquip)--]]

	widgets.sealBtn:onClick(self, self.wearingSevenEquipTips)--龙印系统
	widgets.sealLevel:hide()

	widgets.search_btn:onClick(self, self.searchItemBtn) --搜索按钮点击事件
	widgets.return_btn:onClick(self, self.onReturnBtn) --搜索按钮点击事件

	self:updateHeirloomIcon()
	widgets.heirloomLevel:hide()
	widgets.heirloomBtn:onClick(self, self.onClickArtifact)--传家宝系统

	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	-- self.strengthen = widgets.strengthen_btn

 	-- self.strengthen:onClick(self,self.OnStrengthen)
 	self.yulingBagBtn = widgets.yulingBagBtn
 	self.yulingBagBtn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_catch_spirit_base.common.openLevel)
 	self.yulingBagBtn:onClick(self, self.onSpriteFragmentBagClick)
 	--self.recentlyGetBtn:onClick(self, self.onRecentlyGetBtnClick)

	self._layout.vars.noItemTips:setText(i3k_get_string(15522))
	self.type_desc = widgets.type_desc
	self._layout.vars.chooseTypeBtn1:onClick(self, self.onChangeWeaponShowBtn)
	ISSEARCH = false
end
--关闭
function wnd_bag:onHide()
	if self.isInCoroutine then
		g_i3k_coroutine_mgr:StopCoroutine(self.updateCoroutine)
		self.updateCoroutine = nil
		self.isInCoroutine = false
	end
end

function wnd_bag:getFilterStrs()
	local strs = {}
	table.insert(strs, i3k_get_string(1086))
	for index = 1, 10 do
		table.insert(strs, i3k_get_string(15483 + index))
	end
	table.insert(strs, i3k_get_string(15596)) -- 家园index 11
	table.insert(strs, i3k_get_string(15597)) -- 暗器index 12
	return strs
end

function wnd_bag:quickCombined()

	local combinedItems = g_i3k_game_context:GetCanCombinedItems()
	if #combinedItems == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15479))
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Quick_Combine);
	g_i3k_ui_mgr:RefreshUI(eUIID_Quick_Combine,combinedItems);
end
function wnd_bag:onWarZoneCard(sender)
	i3k_sbean.global_world_sect_panel(function ()
        g_i3k_logic:OpenWarZoneCard() 
    end, true)
end

function wnd_bag:updateHeirloomIcon()
	if g_i3k_game_context:heirloomRedPoint() then
		self._layout.vars.heirloomTip:show()
	else
		self._layout.vars.heirloomTip:hide()
	end
end
--初始化穿着装备控件
function wnd_bag:initWearEquipWidget(widgets)
	for i=1, eEquipCount do
		local equip_btn = "equip"..i
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		local repair_icon = "repair"..i
		local is_select = "is_select"..i
		local level_label = "qh_level"..i
		local red_tips = "tips"..i

		self.wear_equip[i] = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			repair_icon	= widgets[repair_icon],
			is_select	= widgets[is_select],
			level_label	= widgets[level_label],
			red_tips	= widgets[red_tips],
		}
	end
end

--要注意了，刷新包裹已经不是同步的了，会由协程分两到三帧来做了
function wnd_bag:refresh(showItemID)
	self.showItemID = showItemID
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
	self:updateWearEquipsData(g_i3k_game_context:GetRoleDetail())
	self:deepRefreshBag()
	g_i3k_game_context:LeadCheck()
	--i3k_sbean.bag_merge_all(ids)
	self:refreshLongYinRedPoint()
	self:setPropertyScroll()
	self:initShowType(g_i3k_game_context:GetWearEquips())
	self:setWarZoneCardBtn()
end
function wnd_bag:setWarZoneCardBtn()
	local widgets = self._layout.vars
	local roleLevel = g_i3k_game_context:GetLevel();
	widgets.warZoneCard:setVisible(roleLevel >= i3k_db_war_zone_map_cfg.needLvl)
	widgets.card_red:setVisible(i3k_db.i3k_db_get_war_zone_card_personal_red())
end

function wnd_bag:OnStrengthen(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_StrengthenSelf)
end
function wnd_bag:onRecentlyGetBtnClick(sender)
	i3k_sbean.item_history_sync()
	--self:onSpriteFragmentBagClick()
end
function wnd_bag:onSpriteFragmentBagClick()
	i3k_sbean.ghost_island_info()
end

function wnd_bag:addDiamondBtn(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
	end
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_bag:addCoinBtn(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
	end
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_bag:updateMoney(diamondF, diamondR, coinF, coinR)
	self._layout.vars.diamond:setText(diamondF)
	self._layout.vars.diamondLock:setText(diamondR)
	self._layout.vars.coin:setText(i3k_get_num_to_show(coinF))
	self._layout.vars.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_bag:updateWearEquipsData(ctype, level, fightpower, wEquips)--左侧已穿装备的信息
	self:updateProfile(ctype, level, fightpower, wEquips)
	for i=1, eEquipCount do
		if g_i3k_game_context:isFlyEquip(i) and not g_i3k_game_context:isFinishFlyingTask(1) then
			self.wear_equip[i].equip_btn:hide()
		else
		local equip = wEquips[i].equip
			if self._layout.vars["an"..i.."1"] and self._layout.vars["an"..i.."2"] then --这里要跳过“魂玉”“神器”
		self._layout.vars["an"..i.."1"]:hide()
		self._layout.vars["an"..i.."2"]:hide()
			end
		if equip then
			self.wear_equip[i].repair_icon:hide()
			self.wear_equip[i].equip_btn:onClick(self, self.wearingEquipTips, {partID = i, equip = equip})
			local now_value = equip.naijiu
			if now_value ~= -1 then
				local MaxVlaue = i3k_db_common.equip.durability.durabilityMax
				local repairMark = i3k_db_common.equip.durability.repairMark
				self.wear_equip[i].repair_icon:show()
				self.wear_equip[i].repair_icon:setVisible(now_value/MaxVlaue <= repairMark)
			end
			local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(equip.equip_id, equip.naijiu)
			if rankIndex ~= 0 then
				local index = rankIndex == 1 and 2 or 1
				self._layout.vars["an"..i..index]:show()
			end
		else
			self.wear_equip[i].equip_btn:enable()
			self.wear_equip[i].equip_btn:onClick(self, self.notwearingEquipTips, {partID = i})
		end

		self.wear_equip[i].red_tips:hide()
		self.wear_equip[i].level_label:hide()
		end
	end

	local widgets = self._layout.vars

	local argData = g_i3k_db.i3k_db_LongYin_arg
	local isOpenImage
	local isOpen = g_i3k_game_context:GetIsHeChengLongYin()
	if isOpen ~= 0 then
		local quality = g_i3k_game_context:GetLongYinQuality(isOpen)
		isOpenImage = argData.args.openItemIronID
		widgets.sealIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_game_context:GetLongYinIronForGrade(isOpen)))
		widgets.sealBg:setImage(g_i3k_get_icon_frame_path_by_rank(quality))
	else
		isOpenImage = argData.args.closeItemIronID
		widgets.sealIcon:setImage(g_i3k_db.i3k_db_get_icon_path(isOpenImage))
		widgets.sealBg:setImage(g_i3k_get_icon_frame_path_by_rank(1))
	end
	widgets.sealTips:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2() or g_i3k_game_context:getFulingRedPoint())
	self.bg_redPoint:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2())
	self.sz_redPoint:setVisible(g_i3k_game_context:getFashionRedPoint() or g_i3k_game_context:getMetamorphosisRedPoint())

	local heirloom = g_i3k_game_context:getHeirloomData()
	if heirloom.isOpen == 1 then
		widgets.heirloomIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_game_context:getHeirloomIconID()))
		widgets.heirloomBg:setImage(g_i3k_get_icon_frame_path_by_rank(5))
	end
	self:setChangeWeaponShow()
end

function wnd_bag:showAllItem(itemId, stack_count)
	if stack_count > 0 then
		return ITEMSHOWTYPE_OTHERS
	end
	return false
end

local NotShowInBag = 
{
	[g_COMMON_ITEM_TYPE_PET_EQUIP] = true,
	[g_COMMON_ITEM_TYPE_HORSE_EQUIP] = true,
}
function wnd_bag:showDaibiItem(itemId, stack_count)
	local itemType = g_i3k_db.i3k_db_get_common_item_type(itemId)
	if stack_count == 0 and not NotShowInBag[itemType] then
		return ITEMSHOWTYPE_DAIBI
	end
	return false
end


function wnd_bag:showFilterItem(itemId, stack_count)
	if (self.filterType == FILTER_EQUIP and g_i3k_db.i3k_db_get_common_item_type(itemId) == g_COMMON_ITEM_TYPE_EQUIP) 
		or (self.filterType == g_i3k_db.i3k_db_getItemFilter(itemId) + 1 and stack_count > 0) then
		return ITEMSHOWTYPE_OTHERS
	end
	return false
end

local showTb = {
	[SHOWTYPE_ALL]		= wnd_bag.showAllItem,
	[SHOWTYPE_DAIBI]	= wnd_bag.showDaibiItem,
	[SHOWTYPE_FILTER]	= wnd_bag.showFilterItem,
}

function wnd_bag:ItemShowType(itemId, stack_count)
	local func = showTb[self.showType]
	if func and func(self, itemId, stack_count) then
		return func(self, itemId, stack_count)
	end

	return 0
end

function wnd_bag:updateCells(items, currentItemIndex, cells, last_cell, bagSize)
	local itemCount = #items
	local cellCount = #cells
	local cell_index = 1
	local realCellCount = 0;
	while currentItemIndex <= itemCount and cell_index <= cellCount do
		local e = items[currentItemIndex]
		currentItemIndex = currentItemIndex + 1

		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		local itemShowType = self:ItemShowType(e.id, stack_count)
		if itemShowType == ITEMSHOWTYPE_OTHERS then

			realCellCount = realCellCount + 1


			local item_cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
			--max_item_index就是增加这个item的循环上限，last_cell就是循环起点，含义是当前格子是这个物品的第几格
			--（无论是第几批更新，都是从这个物品的第一次循环的第一个格子开始计算）
			--（也就是说，第二批更新的时候，如果上一批已经扔了这个item的前几个格子了，那么last_cell就不会是1
			local max_item_index = item_cell_count
			if item_cell_count - last_cell > cellCount - cell_index then
				--这个物品这一批更新要占item_cell_count - last_cell + 1个格子，但是只剩下cellCount - cell_index + 1个空格子了，格子不够
				max_item_index = cellCount - cell_index + last_cell
			end
			for k=last_cell, max_item_index do
				local widgetVars = cells[cell_index].vars
				local itemCount = k == item_cell_count and e.count-(item_cell_count-1)*stack_count or stack_count
				self:updateCell(widgetVars, e.id, itemCount, e.guids[k])
				widgetVars.bt:setVisible(true)
				cell_index = cell_index + 1
			end
			if max_item_index == item_cell_count then
				last_cell = 1
			else
				currentItemIndex = currentItemIndex - 1
				last_cell = max_item_index + 1
			end
		end

		if itemShowType == ITEMSHOWTYPE_DAIBI then
			realCellCount = realCellCount + 1
			local itemCount=e.count
			local widgetVars = cells[cell_index].vars
			self:updateCell(widgetVars, e.id, itemCount, e.guids[last_cell])--last_cell
			widgetVars.bt:setVisible(true)
			cell_index = cell_index + 1
			last_cell = 1
		end

	end
	for k = cell_index, cellCount do
	local widgetVars = cells[k].vars
		self:updateCell(widgetVars, 0, 0, nil)
		if k > bagSize then
			widgetVars.bt:enable()
			widgetVars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(EXPAND_GRADEICON))
			if widgetVars._tipArgs == nil then
				widgetVars._tipArgs = {}
				widgetVars.bt:onClick(self, self.onTips, widgetVars._tipArgs)
			end
			widgetVars._tipArgs.func = self.packageExtend
		end
		widgetVars.bt:setVisible(self.showType == 1)
	end
	return currentItemIndex, last_cell, realCellCount
end

function wnd_bag:deepRefreshBag()--删除所有的子并且重新添加，会用协程分帧进行，
	local bagSize, BagItems = g_i3k_game_context:GetBagInfo()

	if self.isInCoroutine then
		g_i3k_coroutine_mgr:StopCoroutine(self.updateCoroutine)
		self.updateCoroutine = nil
	end
	--因为每帧的update都会检查bag_items_changed，如果是true就会进来，所以只要开始更新就设成false，尽管还没有更新完
	--如果还没有更新完，包裹数据又有变化，那么bag_items_changed还可以被设为true，重新进来，取消旧的协程，开始新一轮更新
	self.bag_items_changed = false
	self.scroll:removeAllChildren()
	self.isInCoroutine = true
	self.updateCoroutine = g_i3k_coroutine_mgr:StartCoroutine(function()
		local items = self:itemSort(BagItems)
		local leftCount = bagSize + RowitemCount
		local batchSize = RowitemCount * 5
		local batch = math.ceil(leftCount / batchSize)
		local last_cell = 1
		local currentItemIndex = 1
		for b=1, batch do
			if leftCount > batchSize then
				leftCount = leftCount - batchSize
			else
				batchSize = leftCount
			end
			local all_layer = self.scroll:addItemAndChild(QJ_WIDGETS,RowitemCount,batchSize)
			currentItemIndex, last_cell = self:updateCells(items, currentItemIndex, all_layer, last_cell, bagSize)
			bagSize = bagSize - batchSize
			if b < batch then
				g_i3k_coroutine_mgr.WaitForNextFrame()
			end
		end
		self.isInCoroutine = false
		self.updateCoroutine = nil
	end)
end

--更新背包大小
function wnd_bag:updateBagSize(expandSize)
	if self.isInCoroutine then
		g_i3k_coroutine_mgr:StopCoroutine(self.updateCoroutine)
		self.updateCoroutine = nil
		self:deepRefreshBag()
	else
		self.scroll:addItemAndChild(QJ_WIDGETS, RowitemCount, expandSize)
		self:updateBag(g_i3k_game_context:GetBagInfo())
	end
end
-----更新背包
function wnd_bag:updateBag(bagSize, BagItems)

	 if self.isInCoroutine then
		g_i3k_coroutine_mgr:StopCoroutine(self.updateCoroutine)
		self.updateCoroutine = nil
		self:deepRefreshBag()
		--在deepRefreshBag里面会self.bag_items_changed = false
	else
		local _, _,realCellCount = self:updateCells(self:itemSort(BagItems), 1, self.scroll:getAllChildren(), 1, bagSize)
		if self.showType ~= 1 then
			self._layout.vars.noItemTips:setVisible(realCellCount == 0)
		else
			self._layout.vars.noItemTips:setVisible(false)
		end
		self.bag_items_changed = false
	end
	self:refreshLongYinRedPoint() --longyin红点更新
end

function wnd_bag:updateCell(widgetVars, id, count, guid)

	widgetVars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id == 0 and 106 or id))
	widgetVars.item_icon:setImage(id == 0 and g_i3k_db.i3k_db_get_icon_path(2396) or g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widgetVars.item_count:setText(count)
	if guid or count <= 0 then
		widgetVars.item_count:hide()
	else
		widgetVars.item_count:show()
	end
	if widgetVars._naijiuBrightNode ~= nil then
		widgetVars.bt:removeChild(widgetVars._naijiuBrightNode)
	end
	self:setMaskIsShow(id, widgetVars)
	self:setUpIsShow(id, guid, widgetVars)
	if g_i3k_db.i3k_db_get_bag_item_stack_max(id) == 0 then
		widgetVars.suo:setVisible(false)
	else
		widgetVars.suo:setVisible(id>0)
	end
	widgetVars.is_select:hide()
	widgetVars.lizi:hide()
	widgetVars.lizi2:hide()
	if id == 0 then
		widgetVars.bt:disable()
	else
		widgetVars.bt:enable()
		if widgetVars._tipArgs == nil then
			widgetVars._tipArgs = {}
			widgetVars.bt:onClick(self, self.onTips, widgetVars._tipArgs)
		end
		widgetVars._tipArgs.args = { widgetVars = widgetVars, id = id, guid = guid }
		if not guid and g_i3k_db.i3k_db_get_bag_item_fashion_able(id) then
			widgetVars._tipArgs.func = self.onFashionTips
		elseif not guid and g_i3k_db.i3k_db_get_bag_item_metamorphosis_able(id) then
			widgetVars._tipArgs.func = self.onMetamorphosisTips		
		else
			if self.showItemID and self.showItemID == id then
				widgetVars.is_select:show()
				widgetVars.lizi:show()
				widgetVars.lizi2:show()
				self.showItemID = nil
			end
			widgetVars._tipArgs.func = guid and self.onEquipTips or self.onItemTips
		end
		if g_i3k_game_context:GetIsGlodCoast() then
			widgetVars.item_icon:disable()
		end
		if guid then
			local equip = g_i3k_game_context:GetBagEquip(id, guid)
			if equip then
				local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(equip.equip_id, equip.naijiu)
				if rankIndex ~= 0 then
					widgetVars._naijiuBrightNode = require("ui/widgets/zbtx")()
					widgetVars._naijiuBrightNode.vars["an"..rankIndex]:show()
					widgetVars.bt:addChild(widgetVars._naijiuBrightNode)
				end
			end
		end
	end
end

function wnd_bag:setMaskIsShow(id, widgetVars)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		if g_i3k_db.i3k_db_check_equip_level(id) then
			widgetVars.is_show:hide()
		else
			local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
			local bwType = g_i3k_game_context:GetTransformBWtype()
			local isSameBwType = equip_cfg.M_require == 0 or equip_cfg.M_require == bwType
			if equip_cfg.roleType == 0 and g_i3k_game_context:GetLevel() >= equip_cfg.levelReq then--装备全系,不分职业
				widgetVars.is_show:hide()
			elseif g_i3k_game_context:GetRoleType() ~= equip_cfg.roleType or g_i3k_game_context:GetLevel() < equip_cfg.levelReq or not isSameBwType then
				widgetVars.is_show:show()
			else
				if equip_cfg.C_require ~= 0 then
					widgetVars.is_show:setVisible(g_i3k_game_context:GetTransformLvl() < equip_cfg.C_require)
				else
					widgetVars.is_show:hide()
				end
			end
		end
	else
		widgetVars.is_show:hide()
	end
end

function wnd_bag:setUpIsShow(id, guid, widgetVars)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
		local bwType = g_i3k_game_context:GetTransformBWtype()
		local isSameBwType = equip_cfg.M_require == 0 or equip_cfg.M_require == bwType
		local equip = g_i3k_game_context:GetBagEquip(id, guid)
		if (g_i3k_game_context:GetRoleType() == equip_cfg.roleType or equip_cfg.roleType == 0) and equip and isSameBwType then
			local wearEquips = g_i3k_game_context:GetWearEquips()
			local _data = wearEquips[equip_cfg.partID].equip
			if _data then
				local wAttribute = _data.attribute
				local wNaijiu = _data.naijiu
				local wEquip_id = _data.equip_id
				local wPower = g_i3k_game_context:GetBagEquipPower(wEquip_id,wAttribute,wNaijiu, _data.refine, _data.legends, _data.smeltingProps)
				local total_power = g_i3k_game_context:GetBagEquipPower(id,equip.attribute,equip.naijiu,equip.refine,equip.legends, equip.smeltingProps)
				widgetVars.isUp:show()
				if wPower > total_power then
					widgetVars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				elseif wPower < total_power then
					widgetVars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				else
					widgetVars.isUp:hide()
				end
			else
				widgetVars.isUp:show()
				widgetVars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
			end
		else
			widgetVars.isUp:hide()
		end
	else
		widgetVars.isUp:hide()
	end
end

function wnd_bag:packageExtend(sender)
	local bagSize, expandTimes = g_i3k_game_context:GetBagSize()
	expandTimes = expandTimes + 1

	if expandTimes > i3k_db_common.bag.expandNumber then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(124))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_Bag_extend)
		g_i3k_ui_mgr:RefreshUI(eUIID_Bag_extend,{
			desc = i3k_get_string(15474),
			itemId = i3k_db_common.bag.useItemId,
			costCount = g_i3k_db.i3k_db_get_bag_extend_price(expandTimes),
			itemCount = g_i3k_db.i3k_db_get_bag_extend_itemCount(expandTimes),
			expandTimes = expandTimes
		})
	end
end

--背包物品排序
function wnd_bag:itemSort(items)
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

--一键装备排序
function wnd_bag:equipSort(equips)
	table.sort(equips,function(a,b)
		return a.power > b.power
	end)
	return equips
end

function wnd_bag:showDaiBiTips()
	local usecfg = i3k_get_load_cfg()
    if usecfg then
	    local daibiShowtimes = usecfg:GetDaibiTipsShowTimes()
		if not (daibiShowtimes > DAIBI_SHOW_MAX_TIMES) then
			self.record_time = i3k_game_get_time() --onUpdate有判断
		    self.type_desc:setVisible(true)
		    daibiShowtimes = daibiShowtimes + 1 --> DAIBI_SHOW_TIMES and DAIBI_SHOW_TIMES + 1 or daibiShowtimes + 1
		    usecfg:SetDaibiTipsShowTimes(daibiShowtimes)
		end
	end
end
--设置背包显示类型
function wnd_bag:setBagShowType(showType,force)
	if showType == 2 then
		if g_i3k_game_context:GetIsGlodCoast() then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		end
	end
    --当点击了所选的下拉列表并且类型不一样
	if force or self.showType ~= showType then
		--改变类型
		self.showType = showType
		if self.showType == SHOWTYPE_DAIBI then
		    self:showDaiBiTips()
		end
		--按钮恢复正常状态
		for i, e in ipairs(self.bagItemTypeButton) do
			e:stateToNormal(true)
		end
		--设置点击过后的样子
		self.bagItemTypeButton[showType]:stateToPressed(true)
		--更新背包
		self:updateBag(g_i3k_game_context:GetBagInfo())
		self.scroll:jumpToListPercent(0)
		self._layout.vars.search_btn:setVisible(true)
		if showType == SHOWTYPE_DAIBI then
			self._layout.vars.search_btn:disableWithChildren()
		else
			self._layout.vars.search_btn:enableWithChildren()
		end
		self._layout.vars.return_btn:setVisible(false)
	end

end


--当展示类型发生改变
function wnd_bag:onShowTypeChanged(sender, tag)
	if ISSEARCH == true then
		self:deepBag()
	    self:deleteNoItemTips()  --删除第一次没有物品的提示
		self:setBagShowType(tag)
		if tag == 1 then
			self:onReturnBtn()
		end
		ISSEARCH =false
	else
		self:setBagShowType(tag)
	end
end

function wnd_bag:onTips(sender, args)
	args.func(self, sender, args.args)
end

function wnd_bag:onItemTips(sender, args)
	if g_i3k_game_context:GetIsGlodCoast() then
		if not i3k_db_war_zone_map_cfg.canUseItems[args.id] then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		end
	end
	self:setCellIsSelectHide()
	args.widgetVars.is_select:show()
	args.widgetVars.lizi:show()
	args.widgetVars.lizi2:show()
	g_i3k_ui_mgr:OpenUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_BagItemInfo, args.id)
end

function wnd_bag:onEquipTips(sender, args)
	if g_i3k_game_context:GetIsGlodCoast() then
		if not i3k_db_war_zone_map_cfg.canUseItems[args.id] then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		end
	end
	self:setCellIsSelectHide()
	args.widgetVars.is_select:show()
	args.widgetVars.lizi:show()
	args.widgetVars.lizi2:show()
	local equip = g_i3k_game_context:GetBagEquip(args.id, args.guid)
	local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip.equip_id)
	if g_i3k_game_context:isFlyEquip(equipCfg.partID) then
		g_i3k_ui_mgr:OpenUI(eUIID_FlyingEquipInfo)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipInfo, "updateBagEquipInfo", equip)
	else
	g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "updateBagEquipInfo", equip)
	end
end

function wnd_bag:onFashionTips(sender, args)
	self:setCellIsSelectHide()
	args.widgetVars.is_select:show()
	args.widgetVars.lizi:show()
	args.widgetVars.lizi2:show()
	local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(args.id)
	local fashionID = itemCfg.args1
	local info = g_i3k_db.i3k_db_get_fashion_cfg(fashionID)
	g_i3k_ui_mgr:OpenUI(eUIID_FashionDressTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_FashionDressTips, args.id ,true, info.getPathway, nil, info.sex, false, false)
end

--幻形
function wnd_bag:onMetamorphosisTips(sender, args)
	self:setCellIsSelectHide()
	args.widgetVars.is_select:show()
	args.widgetVars.lizi:show()
	args.widgetVars.lizi2:show()
	g_i3k_ui_mgr:OpenUI(eUIID_MetamorphosisDressTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_MetamorphosisDressTips, args.id)
end
function wnd_bag:setCellIsSelectHide()
	for i, e in ipairs(self.scroll:getAllChildren()) do
		e.vars.is_select:hide()
		e.vars.lizi:hide()
		e.vars.lizi2:hide()
	end
end

function wnd_bag:onFashionBtn(sender)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
		g_i3k_logic:OpenFashionDressUI(nil, eUIID_Bag)
	end
end

function wnd_bag:onRoleBtn(sender)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Bag)
	g_i3k_logic:OpenRoleLyUI2()
end

function wnd_bag:onWarehouseBtn(sender)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_logic:OpenWarehouseUI(eUIID_Bag)
end

function wnd_bag:onRoleTitleBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Bag)
	g_i3k_logic:OpenRoleTitleUI()
end

function wnd_bag:wearingEquipTips(sender, data)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	for i, e in ipairs(self.wear_equip) do
		e.is_select:setVisible(i == data.partID)
	end
	local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(data.equip.equip_id)
	if g_i3k_game_context:isFlyEquip(equipCfg.partID) then
		g_i3k_ui_mgr:OpenUI(eUIID_FlyingEquipInfo)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipInfo, "updateWearEquipInfo", data.equip)
	else
	g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "updateWearEquipInfo", data.equip)
	end
end

function wnd_bag:notwearingEquipTips(sender, data)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local str = g_i3k_db.i3k_db_get_equip_gain_resource_desc(data.partID)
	g_i3k_ui_mgr:ShowMessageBox1(str)
end

function wnd_bag:onAutoWearButton(sender)
	if g_i3k_game_context:GetIsSpringWorld() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17285))
		return
	end
	self:GetBestWearEquip()
end
	--self:onReturnBtn()

function wnd_bag:onUpdate(dTime)
	if i3k_game_get_time() - self.record_time >  SHOW_TIME then
		self.type_desc:setVisible(false)
	end
	if 	self.bag_items_changed then
		--正常刷新
		self:updateBag(g_i3k_game_context:GetBagInfo())
		if ISSEARCH == true then
			self:searchItemInBag(KEYWORD)
		end
	end
end

function wnd_bag:setBagItemsChanged()
	self.bag_items_changed = true
end

function wnd_bag:onSaleBatButton(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SaleItemBat)
	g_i3k_ui_mgr:RefreshUI(eUIID_SaleItemBat)
end

function wnd_bag:getBagEquips()
	local temp = {}
	local bagSize, bagItems = g_i3k_game_context:GetBagInfo()
	for k, v in pairs(bagItems) do
		if g_i3k_db.i3k_db_get_common_item_type(k) == g_COMMON_ITEM_TYPE_EQUIP then
			if next(v.equips) then
				for a, b in pairs(v.equips) do
					table.insert(temp, {id = k, guid = a, refine = b.refine, legends = b.legends})
				end
			end
		end
	end
	return temp
end

function wnd_bag:GetBestWearEquip()
	local equips = self:getBagEquips()
	local wEquips = g_i3k_game_context:GetWearEquips()
	local best_equip = {}
	local replace_count = 0
	local temp_pos = {}
	for i=1,eEquipCount do
		local w_grade = 0
		local w_power = 0
		local w_levelReq = 0
		local temp1 = {}
		local equip = wEquips[i].equip
		if equip then
			w_levelReq = g_i3k_db.i3k_db_get_common_item_level_require(equip.equip_id)
			w_grade = g_i3k_db.i3k_db_get_common_item_rank(equip.equip_id)
			w_power = self:GetEquipPower(equip.equip_id, equip.attribute, equip.naijiu, equip.refine, equip.legends, equip.smeltingProps, equip.hammerSkill)
		end
		for j, e in pairs(equips) do
			local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(e.id)
			local equipData = g_i3k_game_context:GetBagEquip(e.id, e.guid)
			local transfromLvl = g_i3k_game_context:GetTransformLvl()
			local role_ctype = g_i3k_game_context:GetRoleType()
			local cur_level = g_i3k_game_context:GetLevel()
			local all_class_type = equip_cfg.roleType == 0 and true or role_ctype == equip_cfg.roleType
			local bwType = g_i3k_game_context:GetTransformBWtype()
			local isSameBwType = equip_cfg.M_require == 0 or equip_cfg.M_require == bwType
			if equip_cfg.partID == i and all_class_type and ((cur_level >= equip_cfg.levelReq and transfromLvl >= equip_cfg.C_require and isSameBwType)
			or g_i3k_db.i3k_db_check_equip_level(e.id) )then
				local t = {
					equip_id = e.id,
					equip_guid = e.guid,
					partID = equip_cfg.partID,
					rank = equip_cfg.rank,
					power = self:GetEquipPower(e.id, g_i3k_get_equip_attributes(equipData), g_i3k_get_equip_durability(equipData),e.refine,e.legends, e.smeltingProps, e.hammerSkill)
				}
				table.insert(temp1,t)
			end
		end

		local equip_tb = self:equipSort(temp1)
		local _equip = i3k_sbean.KinEquips.new()
		if next(equip_tb) ~= nil then
			if equip_tb[ONE].power > w_power then
				local tmp = {}
				replace_count = replace_count + 1
				_equip.id = equip_tb[ONE].equip_id
				tmp[equip_tb[ONE].equip_guid] = true
				_equip.guids = tmp
				best_equip[equip_tb[ONE].equip_id] = _equip
				temp_pos[equip_tb[ONE].equip_id] = equip_tb[ONE].partID
			end
		end

	end
	if replace_count ~= 0 then
		if self:getIsHaveFreeEquip(best_equip) then
			local fun = (function(ok)
				if ok then
					i3k_sbean.equip_autoupwear(best_equip, temp_pos)
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(308, g_i3k_db.i3k_db_get_free_equip_desc(best_equip)), fun)
		else
			i3k_sbean.equip_autoupwear(best_equip, temp_pos)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("没有更好的装备可以穿戴")
	end
end

function wnd_bag:getIsHaveFreeEquip(best_equip)--一键装备时是否有非绑定的装备
	for k, v in pairs(best_equip) do
		if k < 0 then
			return true
		end
	end
	return false
end

function wnd_bag:GetEquipPower(equip_id,attribute,naijiu, refine,legends, smeltingProps, hammerSkill)
	return g_i3k_game_context:GetBagEquipPower(equip_id,attribute,naijiu,refine,legends, smeltingProps)
end

--[[function wnd_bag:onStrengTips(sender, eventType)
	g_i3k_ui_mgr:OpenUI(eUIID_RoleTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RoleTips, g_i3k_db.i3k_db_get_streng_reward_info_for_type())
end

function wnd_bag:onUpStarTips(sender, eventType)
	g_i3k_ui_mgr:OpenUI(eUIID_Danyao)
	g_i3k_ui_mgr:RefreshUI(eUIID_Danyao)
end

function wnd_bag:onSuitEquip(sender)
	g_i3k_logic:OpenSuitUI()
end--]]

function wnd_bag:refreshLongYinRedPoint()
	--self._layout.vars.sealTips:setVisible(true)
	self._layout.vars.sealTips:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2() or g_i3k_game_context:getFulingRedPoint() or g_i3k_game_context:GetLongYinRedpoint3() or  g_i3k_game_context:jingxiuUnlock())
	self.bg_redPoint:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2() or g_i3k_game_context:GetLongYinRedpoint3() or  g_i3k_game_context:jingxiuUnlock())
end

-------------------------------------------------------------------------

--打开搜索面板
function wnd_bag:searchItemBtn()
	g_i3k_ui_mgr:OpenUI(eUIID_BagSearch)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BagSearch,"setSearchType",0)
end
--返回
function wnd_bag:closeSearchBtn()
	self._layout.vars.search_btn:setVisible(false)
	self._layout.vars.return_btn:setVisible(true)
end

--删除背包物品
function wnd_bag:deepBag()
 	if self.isInCoroutine then
		g_i3k_coroutine_mgr:StopCoroutine(self.updateCoroutine)
		self.updateCoroutine = nil
	end
	self.bag_items_changed = false
	self.scroll:removeAllChildren()
	self.isInCoroutine = true
end

--删除没有物品的提示
function wnd_bag:deleteNoItemTips()
	self._layout.vars.noItemTips:setVisible(false)
end

--更新查找后的背包显示
function wnd_bag:updateSearchBag(bagSize, BagItems)
	ISSEARCH = true
	self:SearchBagItems(bagSize, BagItems)
	local _, _,realCellCount = self:updateCells(self:itemSort(BagItems), 1, self.scroll:getAllChildren(), 1, bagSize)
	if self.showType then
		self._layout.vars.noItemTips:setVisible(realCellCount == 0)
	else
		self._layout.vars.noItemTips:setVisible(false)
	end
	self.bag_items_changed = false

end

--查找物品
function wnd_bag:SearchBagItems(_bagSize, _BagItems)--删除所有的子并且重新添加，会用协程分帧进行，
	local bagSize = _bagSize
	local BagItems = _BagItems
	self.bag_items_changed = false
	self.scroll:removeAllChildren()
	self.isInCoroutine = true
	self.updateCoroutine = g_i3k_coroutine_mgr:StartCoroutine(function()
		local items = self:itemSort(BagItems)
		local leftCount = bagSize  --+ RowitemCount   不显示锁
		local batchSize = RowitemCount * 5              --背包大小
		local batch = math.ceil(leftCount / batchSize)
		local last_cell = 1
		local currentItemIndex = 1
		for b=1, batch do
			if leftCount > batchSize then
				leftCount = leftCount - batchSize
			else
				batchSize = leftCount
			end
			local all_layer = self.scroll:addItemAndChild(QJ_WIDGETS,RowitemCount,batchSize)
			currentItemIndex, last_cell = self:updateCells(items, currentItemIndex, all_layer, last_cell, bagSize)
			bagSize = bagSize - batchSize
			if b < batch then
				g_i3k_coroutine_mgr.WaitForNextFrame()
			end
		end
		self.isInCoroutine = false  --
		self.updateCoroutine = nil
	end)
end
--返回背包
function wnd_bag:onReturnBtn()
	ISSEARCH = false
	g_i3k_ui_mgr:CloseUI(eUIID_Bag)
	g_i3k_logic:OpenBagUI()
end

function wnd_bag:setSearchName(keyword)
	KEYWORD=keyword
end

function wnd_bag:searchItemInBag(keyWord)
	local _, BagItems = g_i3k_game_context:GetBagInfo()
	local newTab=g_i3k_db.i3k_db_get_items_after_search(BagItems,keyWord)
	self.count = g_i3k_db.i3k_db_get_search_items_count(newTab)
	self:updateSearchBag(self.count,newTab)
end

function wnd_create(layout)
	local wnd = wnd_bag.new()
	wnd:create(layout)
	return wnd
end
