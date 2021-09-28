-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_factionFightGroupScore = i3k_class("wnd_factionFightGroupScore", ui.wnd_base)

function wnd_factionFightGroupScore:ctor()
end

function wnd_factionFightGroupScore:configure()
	self._layout.vars.infoBtn:onClick(self,function ()
		i3k_sbean.request_query_sectwar_result()
	end)
end

function wnd_factionFightGroupScore:refresh()
	
end

function wnd_factionFightGroupScore:updateScore(myScore, defScore)
	local vars = self._layout.vars
	vars.myScore:setText(myScore)
	vars.defScore:setText(defScore)
end

function wnd_factionFightGroupScore:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroupScore)
end

function wnd_create(layout, ...)
	local wnd = wnd_factionFightGroupScore.new()
		wnd:create(layout, ...)
	return wnd
end