-------------------------------------------------------
module(..., package.seeall)
local require = require;
require("ui/ui_funcs")
local ui = require("ui/add_sub")
-------------------------------------------------------
wnd_compoundItems = i3k_class("wnd_compoundItems", ui.wnd_add_sub)

function wnd_compoundItems:configure()
	local widget = self._layout.vars
	self.scroll = widget.scroll
	self.times_count = widget.times_count
	self.ok = widget.ok
	self.ok:onClick(self, self.onOkBtn)
	self.cancel = widget.cancel
	self.cancel:onClick(self, self.onCloseUI)

	self.add_btn = widget.jia
	self.sub_btn = widget.jian
	self.max_btn = widget.max
	self.current_num = 1
	self._count_label = widget.sale_count
	self._count_label:setText("1")
	self._max_str = nil
	self._min_str = nil
	self._fun = nil

	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self, self.onSub)
	self.max_btn:onTouchEvent(self, self.onMax)
	widget.times_count:hide()
	widget.item_count:setText(i3k_get_string(16878)) -- 改下标题
end

function wnd_compoundItems:refresh(itemID, data)
	self._itemID = itemID
	self._data = data
	self:updateFun()
	local maxCount = self:getMaxTimes()
	self.current_add_num = maxCount
	self:setScroll()
end

function wnd_compoundItems:updateFun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CompoundItems, "setNumCount", self.current_num)
	end
end

function wnd_compoundItems:setScroll()
	local itemID = self._itemID
	local count = self.current_num
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(itemID)
	local id = itemCfg.args1

	scroll:removeAllChildren()
	local items = self:getNeedItems(id)
	for k, v in ipairs(items) do
		local widget = require("ui/widgets/dhslt")()
		local cfg = g_i3k_db.i3k_db_get_common_item_cfg(v.id)
		-- widget.vars.name:setText(cfg.name)
		-- widget.vars.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id)))
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		widget.vars.item_count:setText(haveCount .."/".. v.count * count)
		widget.vars.item_count:setTextColor(g_i3k_get_cond_color(haveCount >= v.count * count))
		widget.vars.item_lock:setVisible(v.id > 0)
		widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		widget.vars.item_bg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id)))
		widget.vars.bt:onClick(self, self.itemInfo, v.id)
		scroll:addItem(widget)
	end
end

function wnd_compoundItems:setNumCount(count)
	local widgets = self._layout.vars
	widgets.sale_count:setText(count)
end

-- 代码这么乱的原罪就是导表结构不合理
function wnd_compoundItems:getNeedItems(index)
	local result = {}
	for i = 1, 6 do
		local id = i3k_db_compound[index]["needItemId" .. i]
		local count = i3k_db_compound[index]["needItemConunt" .. i]
		if count > 0 then
			table.insert(result, {id = id, count = count})
		end
	end
	return result
end

-- 根据背包道具数量，获取可以合成的最大次数
function wnd_compoundItems:getMaxTimes()
	local itemID = self._itemID
	local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(itemID)
	local index = itemCfg.args1
	local items = self:getNeedItems(index)
	local result = 999 -- 默认最大值
	local temp = {}
	for k, v in ipairs(items) do
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		table.insert(temp, math.floor(haveCount / v.count))
	end
	for k, v in ipairs(temp) do
		if v < result then -- 取这里面最小的
			result = v
		end
	end
	return result
end



function wnd_compoundItems:onOkBtn(sender)
	if self.current_add_num == 0 then
		g_i3k_ui_mgr:PopupTipMessage("材料不足")
		return
	end
	local data = self._data
	local count = self.current_num
	data.count = count

	local getItemID = i3k_db_compound[data.id].getItemID
	local getItemCount = i3k_db_compound[data.id].getItemCount * count
	local isEnoughTable = {}
	isEnoughTable[getItemID] = getItemCount
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16877))
		return
	end
	i3k_sbean.bag_piececompose(data)
end

function wnd_compoundItems:itemInfo(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end


function wnd_create(layout)
	local wnd =wnd_compoundItems.new()
	wnd:create(layout)
	return wnd
end
