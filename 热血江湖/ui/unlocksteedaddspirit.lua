-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_unlockSteedAddSpirit = i3k_class("wnd_unlockSteedAddSpirit", ui.wnd_base)

function wnd_unlockSteedAddSpirit:ctor()
end

function wnd_unlockSteedAddSpirit:configure()
	local widgets = self._layout.vars
	widgets.cancelBtn:onClick(self, self.onCloseUI)
	widgets.okBtn:onClick(self, self.onUnlock)
end

function wnd_unlockSteedAddSpirit:refresh(showID)
	self._showID = showID
	self:updateItem()
end

function wnd_unlockSteedAddSpirit:updateItem()
	local widgets = self._layout.vars 
	if self._showID then
		local needItemID = i3k_db_steed_fight_spirit_show[self._showID].needItem
		local needItemCount = i3k_db_steed_fight_spirit_show[self._showID].needItemCount
		widgets.suo_icon:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needItemID))
		widgets.desc:setText(i3k_get_string(1072, i3k_db_steed_fight_spirit_show[self._showID].showName))
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemID))
		widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needItemID,i3k_game_context:IsFemaleRole()))
		widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needItemID))
		widgets.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(needItemID))
		widgets.item_name:setTextColor(name_colour)
		if needItemID == g_BASE_ITEM_DIAMOND or needItemID == g_BASE_ITEM_COIN then
			widgets.item_count:setText(needItemCount)
		else
			widgets.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(needItemID) .."/".. needItemCount)
		end
		widgets.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(needItemID) >= needItemCount))
		widgets.bt:onClick(self, self.onItemTips, needItemID);
	end
end

function wnd_unlockSteedAddSpirit:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_unlockSteedAddSpirit:onUnlock(sender)
	local UseCount = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_steed_fight_spirit_show[self._showID].needItem)
	if  UseCount >= i3k_db_steed_fight_spirit_show[self._showID].needItemCount then
		i3k_sbean.unlock_steed_add_spirit(self._showID)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1070))
	end
end

function wnd_create(layout)
	local wnd = wnd_unlockSteedAddSpirit.new();
		wnd:create(layout);
	return wnd;
end