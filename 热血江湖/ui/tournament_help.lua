-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_tournament_help = i3k_class("wnd_tournament_help", ui.wnd_base)

function wnd_tournament_help:ctor()
	
end

function wnd_tournament_help:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_tournament_help:onShow()
	
end

function wnd_tournament_help:refresh()
	local node = require("ui/widgets/hwgzt")()
	g_i3k_ui_mgr:AddTask(self, {node}, function (ui)
		local height = node.vars.desc:getInnerSize().height
		local containerSize = ui._layout.vars.scroll:getContainerSize()
		node.rootVar:changeSizeInScroll(ui._layout.vars.scroll, containerSize.width, height+20>containerSize.height and height+20 or containerSize.height, true)
	end, 1)
	self._layout.vars.scroll:addItem(node)
end

--[[function wnd_tournament_help:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TournamentHelp)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_tournament_help.new()
	wnd:create(layout, ...)
	return wnd;
end