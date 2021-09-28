-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_rob_escort_show_coin = i3k_class("wnd_rob_escort_show_coin", ui.wnd_base)

function wnd_rob_escort_show_coin:ctor()
	
end

function wnd_rob_escort_show_coin:configure()
	self.count = self._layout.vars.count 
	local coin_icon = self._layout.vars.coin_icon 
	coin_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_ESCORTT_MONEY,i3k_game_context:IsFemaleRole()))
end

function wnd_rob_escort_show_coin:onShow()
	
end

function wnd_rob_escort_show_coin:refresh(count)
	self.count:setText("+"..count)
end


function wnd_create(layout, ...)
	local wnd = wnd_rob_escort_show_coin.new()
	wnd:create(layout, ...)
	return wnd;
end