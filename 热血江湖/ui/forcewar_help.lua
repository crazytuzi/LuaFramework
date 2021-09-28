-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_forcewar_help = i3k_class("wnd_forcewar_help", ui.wnd_base)

function wnd_forcewar_help:ctor()
	
end

function wnd_forcewar_help:configure()
	self._layout.vars.closeBtn:onClick(self,self.onCloseUI)
end

function wnd_forcewar_help:onShow()
	
end

function wnd_forcewar_help:refresh()
	local node = require("ui/widgets/slzgzt")()
	g_i3k_ui_mgr:AddTask(self, {node}, function (ui)
		local height = node.vars.text:getInnerSize().height
		local containerSize = ui._layout.vars.item_scroll:getContainerSize()
		node.rootVar:changeSizeInScroll(ui._layout.vars.item_scroll, containerSize.width, height+20>containerSize.height and height+20 or containerSize.height, true)
	end, 1)
	self._layout.vars.item_scroll:addItem(node)
end 

--[[function wnd_forcewar_help:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ForceWarHelp)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_forcewar_help.new()
	wnd:create(layout, ...)
	return wnd;
end