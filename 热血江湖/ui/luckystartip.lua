-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_luckyStarTip = i3k_class("wnd_luckyStarTip", ui.wnd_base)

function wnd_luckyStarTip:ctor()

end

function wnd_luckyStarTip:configure()
	self._layout.vars.retrieveBtn:onClick(self, self.gotoAct)
end

function wnd_luckyStarTip:refresh()
	
end

function wnd_luckyStarTip:gotoAct()
	--i3k_sbean.lucklystar_sync_req_send()
	self:onCloseUI()
	g_i3k_game_context:setLuckyStarState(0)
	g_i3k_logic:openLuckyStar()
end

function wnd_create(layout, ...)
	local wnd = wnd_luckyStarTip.new()
	wnd:create(layout, ...)
	return wnd;
end