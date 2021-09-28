-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_catch_spirit_bag = i3k_class("wnd_catch_spirit_bag", ui.wnd_base)

function wnd_catch_spirit_bag:ctor()
	
end

function wnd_catch_spirit_bag:configure()
	self._layout.vars.openBtn:onClick(self, self.onOpenBag)
	self._layout.vars.guideBtn:onClick(self, self.onGuideBtn)
end

function wnd_catch_spirit_bag:refresh()
	
end

function wnd_catch_spirit_bag:onOpenBag(sender)
	i3k_sbean.ghost_island_info()
end

function wnd_catch_spirit_bag:onGuideBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_CatchSpiritGuide)
	g_i3k_ui_mgr:RefreshUI(eUIID_CatchSpiritGuide)
end
function wnd_create(layout)
	local wnd = wnd_catch_spirit_bag.new()
	wnd:create(layout)
	return wnd
end