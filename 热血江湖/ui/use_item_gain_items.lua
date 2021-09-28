-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_use_item_gain_items = i3k_class("wnd_use_item_gain_items",ui.wnd_base)


local SYDJJL_WIDGET = "ui/widgets/sydjjlt"
local RowitemCount = 3

function wnd_use_item_gain_items:ctor()
	self._itemsData = {}
end

function wnd_use_item_gain_items:configure()
	local widgets = self._layout.vars
	
	self.scroll = widgets.scroll
	widgets.ok:onClick(self, self.closeButton)
end

function wnd_use_item_gain_items:refresh(itemsData, callback, needMerge)
	self._callback = callback
	if needMerge then 
		itemsData = self:updateItemsData(itemsData)
	else
		self._itemsData = {}
	end 
	
	local delay = cc.DelayTime:create(0.15)--序列动作 动画播了0.15秒后显示奖励
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self._layout.anis.c_dakai.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateScroll(itemsData)
	end))
	self:runAction(seq)
end

function wnd_use_item_gain_items:updateScroll(itemsData)
	self.scroll:removeAllChildren()
	for i, e in pairs(itemsData) do
		local _layer = require(SYDJJL_WIDGET)()
		local widget = _layer.vars
		local id = e.id
		widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		local count = 0
		if e.count then
			count = e.count
		end
		widget.item_count:setText("x"..count)
		widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(id))
		widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
		widget.item_btn:onClick(self, self.onItemInfo, id)
		self.scroll:addItem(_layer)
	end
end

function wnd_use_item_gain_items:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_use_item_gain_items:closeButton(sender)
	local callback = self._callback
	g_i3k_ui_mgr:CloseUI(eUIID_UseItemGainItems)
	if callback then callback() end
end

function wnd_use_item_gain_items:updateItemsData(newData)
	local itemDataHash = {}
	--合并新旧数据
	for i, e in ipairs(newData) do 
		itemDataHash[e.id] = e.count 
	end
	for i, e in ipairs(self._itemsData) do 
		if itemDataHash[e.id] then 
			itemDataHash[e.id] = itemDataHash[e.id] + e.count
		else 
			itemDataHash[e.id] = e.count
		end
	end
	
	local itemData = {}
	for k, v in pairs(itemDataHash) do 
		table.insert(itemData, {id = k, count = v})
	end
	self._itemsData = itemData
	return itemData
end

function wnd_create(layout)
	local wnd = wnd_use_item_gain_items.new()
	wnd:create(layout)
	return wnd
end
