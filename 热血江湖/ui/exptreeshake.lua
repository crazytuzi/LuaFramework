-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_expTreeShake = i3k_class("wnd_expTreeShake", ui.wnd_base)

function wnd_expTreeShake:ctor()
end

function wnd_expTreeShake:configure()
	self._layout.vars.ok:onClick(self,self.onClose)
end

function wnd_expTreeShake:refresh(data)
	local vars = self._layout.vars
	vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path( data.id))
	vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(data.id,i3k_game_context:IsFemaleRole()))
	vars.btn:onClick(self,function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(data.id)
	end)
	vars.count:setText("X" .. data.count);
	vars.text:setText(i3k_get_string(15497))
	vars.leftNum:setText(string.format("今日剩余%d次", i3k_db_exptree_common.shakeNum - g_i3k_game_context:getWatchingTimes()))
end

function wnd_expTreeShake:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_ExpTreeShake)
end

function wnd_create(layout, ...)
	local wnd = wnd_expTreeShake.new()
		wnd:create(layout, ...)
	return wnd
end
