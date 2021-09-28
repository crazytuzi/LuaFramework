module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_battleDesertPunish = i3k_class("wnd_battleDesertPunish", ui.wnd_base)

function wnd_battleDesertPunish:ctor()
	self._timer = 1
end
function wnd_battleDesertPunish:configure()
	local widget = self._layout.vars
	widget.desc:setText(i3k_get_string(17620))
	widget.okBtn:onClick(self, self.onCloseUI)
end

function wnd_battleDesertPunish:onUpdate(dTime)
	self._timer = self._timer + dTime
	if self._timer >= 1 then
		self._timer  = 0
		local punishTime = g_i3k_game_context:getBattleDesertPunishTime() - i3k_game_get_time()
		if punishTime <= 0 then
			self:onCloseUI()
			return
		else
			local min = punishTime / 60
			local sec = punishTime % 60
			local str = i3k_get_string(17649,min,sec)
			self._layout.vars.time:setText(i3k_get_string(17621, str))
		end
	end
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleDesertPunish.new();
		wnd:create(layout);
	return wnd;
end
