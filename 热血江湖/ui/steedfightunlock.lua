-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steed_fight_unlock = i3k_class("wnd_steed_fight_unlock", ui.wnd_base)

local WIDGET_ZQQZJH = "ui/widgets/zqqzjht"

function wnd_steed_fight_unlock:ctor()
	self._showID = 0
end

function wnd_steed_fight_unlock:configure( )
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOk)
end

function wnd_steed_fight_unlock:refresh(showID)
	self._showID = showID
	self:loadScroll()
end

function wnd_steed_fight_unlock:loadScroll()
	self.scroll:removeAllChildren()
	for _, e in ipairs(i3k_db_steed_fight_base.unlockItems) do
		local widget = require(WIDGET_ZQQZJH)()
		widget.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
		widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID, g_i3k_game_context:IsFemaleRole()))
		if math.abs(e.itemID) == g_BASE_ITEM_DIAMOND or math.abs(e.itemID) == g_BASE_ITEM_COIN then
			widget.vars.item_count:setText(e.itemCount)
		else
			widget.vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID).."/"..e.itemCount)
		end
		widget.vars.item_count:setTextColor(g_i3k_get_cond_color(e.itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)))
		widget.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		widget.vars.tip_btn:onClick(self, self.onItemTips, e.itemID)
		self.scroll:addItem(widget)
	end
end

function wnd_steed_fight_unlock:getIsCanUnlock()
	local num = 0
	for _, e in ipairs(i3k_db_steed_fight_base.unlockItems) do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)
		if canUseCount >= e.itemCount then
			num = num + 1
		end
	end
	return num == #i3k_db_steed_fight_base.unlockItems
end

function wnd_steed_fight_unlock:onOk(sender)
	if not self:getIsCanUnlock() then
		return g_i3k_ui_mgr:PopupTipMessage("材料不足")
	end
	i3k_sbean.horse_showfight_requst(self._showID)
end

function wnd_steed_fight_unlock:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_steed_fight_unlock.new()
	wnd:create(layout)
	return wnd
end
