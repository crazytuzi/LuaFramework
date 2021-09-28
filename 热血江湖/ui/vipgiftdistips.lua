-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_vipGiftDisTips = i3k_class("wnd_vipGiftDisTips", ui.wnd_base)

function wnd_vipGiftDisTips:ctor()
	
end

function wnd_vipGiftDisTips:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self, self.onCloseUI)
end

function wnd_vipGiftDisTips:refresh()
	local widgets = self._layout.vars
	local level = g_i3k_game_context:GetVipLevel()
	local endTime = i3k_db_kungfu_vip[level].discountCloseDate
	local t = os.date("*t", endTime)
	local finitetime = string.format("%d年%d月%d日", t.year, t.month, t.day)
	widgets.desc:setText(i3k_get_string(17294, finitetime))
end

function wnd_create(layout, ...)
	local wnd = wnd_vipGiftDisTips.new()
	wnd:create(layout, ...)
	return wnd
end
