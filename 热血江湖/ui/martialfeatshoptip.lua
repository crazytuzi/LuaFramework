-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_MFShopTip = i3k_class("wnd_MFShopTip", ui.wnd_base)

function wnd_MFShopTip:ctor()

end

function wnd_MFShopTip:configure()
	self._layout.vars.ok:onClick(self, self.onCloseUI)
end

function wnd_MFShopTip:onShow()
	
end

function wnd_MFShopTip:refresh(info)
	local uiVars = self._layout.vars

	uiVars.item_desc:setText(g_i3k_db.i3k_db_get_common_item_name(info.id).."x"..info.count)
	uiVars.item_desc:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(info.id)))
	uiVars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.id))
	uiVars.item_bg:onClick(self, self.onTips, info.id)
	uiVars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.id,i3k_game_context:IsFemaleRole()))
	uiVars.bindIcon:setVisible(info.id > 0)
end

function wnd_MFShopTip:onTips(sender,id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_MFShopTip.new();
		wnd:create(layout, ...);

	return wnd;
end