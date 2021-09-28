-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_qiankunreset = i3k_class("wnd_qiankunreset", ui.wnd_base)

local LAYER_QKCZT = "ui/widgets/qkczt"

function wnd_qiankunreset:ctor()
	self._condition = false
end

function wnd_qiankunreset:configure( )
	local widgets = self._layout.vars
	
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	self.item_name = widgets.item_name
	self.item_count = widgets.item_count
	self.item_btn = widgets.item_btn
	self.scroll = widgets.scroll
	
	widgets.close:onClick(self, self.onCloseUI)	
	widgets.reset_btn:onClick(self, self.onClickResetBtn)	
end

function wnd_qiankunreset:refresh()
	local resetItemId = i3k_db_experience_args.experienceUniverse.resetItemId
	local resetItemCount = i3k_db_experience_args.experienceUniverse.resetItemCount
	self._condition = g_i3k_game_context:GetCommonItemCanUseCount(resetItemId) >= resetItemCount
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(resetItemId) )
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(resetItemId, g_i3k_game_context:IsFemaleRole()))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(resetItemId))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(resetItemId)))
	self.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(resetItemId).."/"..resetItemCount)
	self.item_count:setTextColor(g_i3k_get_cond_color(self._condition))
	self.item_btn:onClick(self, self.onItemTips, resetItemId)
	
	self:updateScroll()
end

function wnd_qiankunreset:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_qiankunreset:updateScroll()
	self.scroll:removeAllChildren()
	for i, e in ipairs(self:getItems()) do
		local widget = require(LAYER_QKCZT)()
		--widget.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
		widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID, g_i3k_game_context:IsFemaleRole()))
		widget.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.itemID))
		widget.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemID)))
		widget.vars.item_count:setText("x"..e.itemCount)
		widget.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		widget.vars.tip_btn:onClick(self, self.onItemTips, e.itemID)
		self.scroll:addItem(widget)
	end
end

function wnd_qiankunreset:getItems()
	local items = {}
	local returnItems = g_i3k_game_context:getQiankunRetrunItems()
	for k, v in pairs(g_i3k_game_context:getQiankunRetrunItems()) do
		table.insert(items, {itemID = k, itemCount = v})
	end
	return items
end

function wnd_qiankunreset:onClickResetBtn()
	if not self._condition then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(925))
		return
	end
	if g_i3k_game_context:IsBagEnough(g_i3k_game_context:getQiankunRetrunItems()) then
		i3k_sbean.dmgtransfer_reset()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(926))
	end
end

function wnd_create(layout)
	local wnd = wnd_qiankunreset.new()
	wnd:create(layout)
	return wnd
end
