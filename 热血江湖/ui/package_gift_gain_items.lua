-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_package_gift_gain_items = i3k_class("wnd_package_gift_gain_items",ui.wnd_base)


local SYDJJL_WIDGET = "ui/widgets/sydjjlt"--layers/dhmlb
local RowitemCount = 3

function wnd_package_gift_gain_items:ctor()
	
end

function wnd_package_gift_gain_items:configure()
	local widgets = self._layout.vars
	
	self.scroll = widgets.scroll
	self.giftName = widgets.giftName
	widgets.ok:onClick(self, self.closeButton)
end

function wnd_package_gift_gain_items:refresh(title, itemsData)	
	local delay = cc.DelayTime:create(0.15)--序列动作 动画播了0.15秒后显示奖励
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self._layout.anis.c_dakai.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateScroll(title, itemsData)
	end))
	self:runAction(seq)
end

function wnd_package_gift_gain_items:updateScroll(title, itemsData)
	self.giftName:setText(title)
	self.scroll:removeAllChildren()
	for i, e in pairs(itemsData) do
		local _layer = require(SYDJJL_WIDGET)()
		local widget = _layer.vars
		local id = e.id
		widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		widget.item_count:setText("x"..e.count)
		widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(id))
		widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
		widget.item_btn:onClick(self, self.onItemInfo, id)
		self.scroll:addItem(_layer)
	end
end

function wnd_package_gift_gain_items:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_package_gift_gain_items:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_UseAnimateGainItems)
end

function wnd_create(layout)
	local wnd = wnd_package_gift_gain_items.new()
	wnd:create(layout)
	return wnd
end
