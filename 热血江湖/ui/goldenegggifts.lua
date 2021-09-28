-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_goldenEggGifts = i3k_class("wnd_goldenEggGifts", ui.wnd_base)

local ITEM_WIDGET = "ui/widgets/jindantipst"

function wnd_goldenEggGifts:ctor()
	
end

function wnd_goldenEggGifts:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_goldenEggGifts:refresh(goods)
	local scroll = self._layout.vars.itemScroll
	scroll:removeAllChildren()
	local children = scroll:addChildWithCount(ITEM_WIDGET, 5, #goods)
	for i, v in ipairs(children) do
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(goods[i].id, g_i3k_game_context:IsFemaleRole()))
		v.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(goods[i].id))
		--v.vars.item_count:setText("x" .. goods[i].item.count)
		v.vars.item_count:hide()
		v.vars.lock:setVisible(goods[i].id > 0)
		v.vars.item_btn:onClick(self, self.showItemInfo, goods[i].id)
	end
end

function wnd_goldenEggGifts:showItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd =wnd_goldenEggGifts.new()
	wnd:create(layout)
	return wnd
end