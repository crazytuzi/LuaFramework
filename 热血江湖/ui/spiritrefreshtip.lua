-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_spiritRefreshTip = i3k_class("wnd_spiritRefreshTip", ui.wnd_base)

-------------------------------------------------------

function wnd_spiritRefreshTip:ctor()

end

function wnd_spiritRefreshTip:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self.scroll = self._layout.vars.scroll
end

function wnd_spiritRefreshTip:refresh()
	self.scroll:removeAllChildren()
	local node = require("ui/widgets/gdylsmt2")()
	node.vars.desc:setText(i3k_get_string(18618, i3k_db_catch_spirit_base.spiritFragment.accumulate, i3k_db_catch_spirit_base.spiritFragment.lianhuaNeedCount))
	self.scroll:addItem(node)

	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local textUI = node.vars.desc
		local size = node.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(self.scroll, width, height, true)
	end, 1)
end

function wnd_create(layout, ...)
	local wnd = wnd_spiritRefreshTip.new()
	wnd:create(layout, ...)
	return wnd;
end