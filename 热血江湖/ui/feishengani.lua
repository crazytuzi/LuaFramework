-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_feishengAni = i3k_class("wnd_feishengAni", ui.wnd_base)

function wnd_feishengAni:ctor()

end

function wnd_feishengAni:configure()
	
end

function wnd_feishengAni:refresh()
	self._layout.anis["c_dakai"].play(function()
		g_i3k_ui_mgr:CloseUI(eUIID_FeishengAni)
	end)
end


function wnd_create(layout)
	local wnd = wnd_feishengAni.new()
	wnd:create(layout)
	return wnd
end