-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_use_item_gain_items = i3k_class("wnd_use_item_gain_items",ui.wnd_base)


local SYDJJL_WIDGET = "ui/widgets/sydjjlt"
local RowitemCount = 3

function wnd_use_item_gain_items:ctor()
	
end

function wnd_use_item_gain_items:configure()
	local widgets = self._layout.vars
	
	self.scroll = widgets.scroll
	widgets.ok:onClick(self, self.closeButton)
end

function wnd_use_item_gain_items:refresh(itemsData, callback)
	self._callback = callback
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
	local all_layer = self.scroll:addChildWithCount(SYDJJL_WIDGET, RowitemCount, #itemsData)
	local index = 0
	for i, e in pairs(itemsData) do
		index = index + 1
		local widget = all_layer[i].vars
		local id = e.id
		widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		widget.item_count:setText("x"..e.count)
		widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(id))
		widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
		widget.item_btn:onClick(self, self.onItemInfo, id)
	end
	if index <=6 then
		self.scroll:stateToNoSlip()
	else
		self.scroll:stateToSlip()
	end
end

function wnd_use_item_gain_items:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_use_item_gain_items:closeButton(sender)
	local callback = self._callback
	g_i3k_ui_mgr:CloseUI(eUIID_UseItemGainMoreItems)
	if callback then callback() end
end

function wnd_create(layout)
	local wnd = wnd_use_item_gain_items.new()
	wnd:create(layout)
	return wnd
end
