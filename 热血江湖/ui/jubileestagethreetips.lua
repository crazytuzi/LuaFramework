--[[
        @Date    : 2019-03-11
        @Author  : zhangbing
        @layout  : zhounianqingjg
    	@UIID	 : eUIID_jubileeStageThreeTips
--]]
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
---------------------------------------------------------------

wnd_jubileeStageThreeTips = i3k_class("wnd_jubileeStageThreeTips", ui.wnd_base)

function wnd_jubileeStageThreeTips:ctor()

end

function wnd_jubileeStageThreeTips:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_jubileeStageThreeTips:refresh()
	local stage = g_i3k_db.i3k_db_get_jubilee_stage()
	self._layout.vars.openIcon:setVisible(stage >= g_JUBILEE_COUNTDOWN_END)
	self._layout.vars.notOpenIcon:setVisible(stage <= g_JUBILEE_COUNTDOWN)
	if stage >= g_JUBILEE_COUNTDOWN_END then
		self._layout.vars.openIcon:setImage(g_i3k_db.i3k_db_get_icon_path(8545))
		local times = g_i3k_game_context:GetubileeStep3MineralTimes()
		local stage3Cfg = i3k_db_jubilee_base.stage3
		local dayLimitTimes = stage3Cfg.dayLimitTimes
		self._layout.vars.desc:setText(i3k_get_string(stage3Cfg.afterLoadingTxt, dayLimitTimes - times, dayLimitTimes))
	end
end

function wnd_create(layout)
	local wnd = wnd_jubileeStageThreeTips.new()
	wnd:create(layout)
	return wnd
end