-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedFightPropUnlock = i3k_class("wnd_steedFightPropUnlock", ui.wnd_base)

local WIDGET_ZQQZJH = "ui/widgets/zqqzjht"

function wnd_steedFightPropUnlock:ctor()
	self._index = 0;
	self._lvl = 0;
	self._item = {};
end

function wnd_steedFightPropUnlock:configure( )
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.des = widgets.des
	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOk)
end

function wnd_steedFightPropUnlock:refresh(lvl, index)
	self._index = index;
	self._lvl = lvl;
	self.des:setText(i3k_get_string(1261))
	self:loadScroll()
end

function wnd_steedFightPropUnlock:loadScroll()
	self._item = {};
	self.scroll:removeAllChildren()
	local havaCount = g_i3k_game_context:havaUnLocksCount(self._lvl);
	local item = i3k_db_steed_fight_up_prop[self._lvl].needItem[havaCount];
	for i, e in ipairs(item) do
		if e.itemID ~= 0 then
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
			table.insert(self._item, e);
			self.scroll:addItem(widget)
		end
	end
end

function wnd_steedFightPropUnlock:onOk(sender)
	local count = 0;
	for i,e in ipairs(self._item) do
		if g_i3k_game_context:GetCommonItemCanUseCount(e.itemID) >= e.itemCount then
			count = count + 1;
		else
			return g_i3k_ui_mgr:PopupTipMessage("材料不足")
		end
		if count == #self._item then
			i3k_sbean.horse_master_unlock(self._lvl, self._index, self._item)
		end
	end
end

function wnd_steedFightPropUnlock:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_steedFightPropUnlock.new()
	wnd:create(layout)
	return wnd
end
