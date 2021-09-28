-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarReLife = i3k_class("wnd_defenceWarReLife", ui.wnd_base)

-- 城战复活
-- [eUIID_DefenceWarReLife]	= {name = "defenceWarReLife", layout = "chengzhanfh", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_defenceWarReLife:ctor()
	self._timeCounter = 0
	self._reLifeTime = i3k_db_defenceWar_cfg.reviveCooling
end

function wnd_defenceWarReLife:configure()
	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(5204, i3k_db_defenceWar_cfg.reviveCooling))
end

function wnd_defenceWarReLife:refresh()
	local reviveTime = g_i3k_game_context:getDefenceWarReviveTime()
	local timeTick = i3k_game_get_logic_tick()
	local tickStep = i3k_engine_get_tick_step()
	local leftTime = math.floor(((reviveTime - timeTick * tickStep) / 1000))
	self._reLifeTime = leftTime >= 0 and leftTime or i3k_db_defenceWar_cfg.reviveCooling

	self._layout.vars.leftTime:setText(i3k_get_format_time_to_show(self._reLifeTime))
end

function wnd_defenceWarReLife:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 1 then
		self._reLifeTime = self._reLifeTime - 1
		self._layout.vars.leftTime:setText(i3k_get_format_time_to_show(self._reLifeTime))
		if self._reLifeTime <= 0 then
			g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarReLife)
		end
		self._timeCounter = 0
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_defenceWarReLife.new()
	wnd:create(layout, ...)
	return wnd;
end
