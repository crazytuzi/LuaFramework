-- zengqingfeng
-- 2018/4/20
--eUIID_UseVit 
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_useVit = i3k_class("useVit", ui.wnd_base)

local QJ_WIDGETS = "ui/widgets/tlsyt"

function wnd_useVit:ctor()
	self._vitItemsInfo = {} --加体力的道具
end

function wnd_useVit:configure()
	local widgets = self._layout.vars
	if not widgets then return end 
	widgets.close:onClick(self, self.onCloseUI)
	widgets.cancel:onClick(self, self.openBuyVitUI)
	widgets.ok:onClick(self, self.autoUseVitBagItem)
	widgets.desc:setText(i3k_get_string(1385))
	self.scroll = widgets.scroll
end

function wnd_useVit:onShow()

end

function wnd_useVit:onHide()
	g_i3k_game_context:clearCanUseVitItems()
end 

function wnd_useVit:refresh(isRefresh)
	vitItems = g_i3k_game_context:getCanUseVitItems(isRefresh)
	if next(vitItems) then 
		self:deepRefreshBag(vitItems)
	elseif isRefresh then  
		self:onCloseUI()
	end
end 

--体力道具
function wnd_useVit:deepRefreshBag(vitItems)
	local bagSize, itemsInfo = self:itemSort(vitItems)
	local scrollView = self.scroll
	scrollView:removeAllChildren()
	for i, info in ipairs(itemsInfo) do 
		local item = require(QJ_WIDGETS)()
		local widgets = item.vars 
		self:updateCell(widgets, info.id, info.count, info.guids[i], info.value)
		scrollView:addItem(item)
	end
	self._vitItemsInfo = itemsInfo
end

function wnd_useVit:itemSort(items)
	local sort_items = {}
	local bagSize = 0
	for k,v in pairs(items) do
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(v.id)
		bagSize = bagSize + 1
		local guids = {}
		for kk, vv in pairs(v.equips) do
			table.insert(guids, kk)
		end
		local value = item_cfg and item_cfg.args1 or 1
		table.insert(sort_items, { value = value, sortid = g_i3k_db.i3k_db_get_bag_item_order(k), id = v.id, count = v.count, guids = guids})
	end
	table.sort(sort_items,function (a,b)
		if a.value == b.value then 
			return a.sortid < b.sortid
		else 
			return a.value > b.value
		end
	end)
	return bagSize, sort_items
end 

function wnd_useVit:updateCell(widgetVars, id, count, guid, value)
	widgetVars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id == 0 and 106 or id))
	widgetVars.item_icon:setImage(id == 0 and g_i3k_db.i3k_db_get_icon_path(2396) or g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widgetVars.item_count:setText(count)

	local totalValue = value * count
	widgetVars.item_value:setText(i3k_get_num_to_show(totalValue))
	if guid or count <= 0 then
		widgetVars.item_count:hide()
	else
		widgetVars.item_count:show()
	end
	if widgetVars._naijiuBrightNode ~= nil then
		widgetVars.bt:removeChild(widgetVars._naijiuBrightNode)
	end
	widgetVars.suo:setVisible(id>0)
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
			widgetVars._tipArgs.func = guid and self.onEquipTips or self.onItemTips
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

function wnd_useVit:onTips(sender, args)
	if args.func then 
		args.func(self, sender, args.args)
	end 
end

function wnd_useVit:onItemTips(sender, args)
	g_i3k_ui_mgr:OpenUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_BagItemInfo, args.id)
end

function wnd_useVit:getBagItemShowType(id)
	return g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP and 2 or 3
end 

function wnd_useVit:openBuyVitUI(sender)
	g_i3k_logic:OpenBuyVitUI(true)
	self:onCloseUI()
end 

--自动使用加体力物品--优先使用加成最多的一直到加满
function wnd_useVit:autoUseVitBagItem()
	--一键使用
	if not self._vitItemsInfo or #self._vitItemsInfo <= 0 then 
		--没有物品意外的情况
		return 
	end
	
	local cur = g_i3k_game_context:GetVit() --本地获取玩家状态
	local max = g_i3k_game_context:GetVitRealMax() --根据等级读表
	local need = max - cur 
	if need <= 0 then 
		--不需要使用
		g_i3k_ui_mgr:PopupTipMessage("体力值已满，不需要使用体力包")
		return 
	end 
	
	local isOutLimit = false
	local itemTable = {}
	for index, item in ipairs(self._vitItemsInfo) do 
		--贪心算法:策略为数值最大的优先使用
		local value = item.value
		local dayTimes = g_i3k_db.i3k_db_get_day_use_item_day_use_times(item.id) or math.huge
		local count = math.min(item.count, dayTimes) 
		local totalValue = value * count 
		if need > totalValue then 
			--还不够继续使用下一个道具
			if count > 0 then 
				need = need - totalValue
				itemTable[item.id] = count
			else 
				isOutLimit = true
			end 
		else 
			--刚好够了或者超出了就是用当前的道具(不能超过最大值所有向下取整)
			local needCount = math.floor(need / value) 
			if needCount > 0 then 
				itemTable[item.id] = needCount
				need = need - needCount * value
			end 
		end			
	end
	
	if next(itemTable) then 
		--向后端发送批量使用协议
		i3k_sbean.bag_batchuseitemvit(itemTable)
	else 
		--不需要使用物品
		if isOutLimit then --有的物品超过每日使用极限了
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(291))
		else
			g_i3k_ui_mgr:PopupTipMessage("体力值已满，不需要使用体力包")
		end 
	end
end

function wnd_create(layout,...)
	local wnd = wnd_useVit.new()
	wnd:create(layout,...)
	return wnd
end
