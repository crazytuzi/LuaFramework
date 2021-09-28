-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_useShowLoveItem = i3k_class("wnd_useShowLoveItem",ui.wnd_base)

function wnd_useShowLoveItem:ctor()
end

function wnd_useShowLoveItem:configure()

end

function wnd_useShowLoveItem:refresh(roleID)
	self._roleID = roleID
	local typeNormalID = i3k_db_show_love_item.typeNormalID
	local typeLuxuryID = i3k_db_show_love_item.typeLuxuryID
	self:setItemInfo(1, typeNormalID)
	self:setItemInfo(2, typeLuxuryID)
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_useShowLoveItem:setItemInfo(index, itemID)
	local item_bg = "item_bg"..index
	local item_icon = "item_icon"..index
	local item_name = "item_name"..index
	local btn = "btn"..index
	local item_desc = "item_desc"..index
	local item_count = "item_count"..index
	local countLabel = "count"..index
	local widgets = self._layout.vars

	local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(itemID)
	local ironImage = g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole())
	local count = g_i3k_game_context:GetCommonItemCanUseCount(itemID)

	widgets[item_icon]:setImage(ironImage)
	widgets[item_bg]:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemID)))
	widgets[item_name]:setText(itemCfg.name)
	widgets[item_desc]:setText(itemCfg.desc)
	widgets[btn]:onClick(self, self.onShowLoveItem, itemID)
	-- widgets[item_count]:setText(count)
	widgets[countLabel]:setText("x"..count)
end

function wnd_useShowLoveItem:onShowLoveItem(sender, itemID)
	local count = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	if count == 0 then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	if not g_i3k_db.i3k_db_check_use_show_love_item_pos() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16963))
		return
	end

	i3k_sbean.useShowLoveItem(itemID, self._roleID)
end


function wnd_create(layout)
	local wnd = wnd_useShowLoveItem.new()
	wnd:create(layout)
	return wnd
end
