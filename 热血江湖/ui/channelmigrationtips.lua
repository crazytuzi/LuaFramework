-------------------------------------------------------
module(..., package.seeall)

local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_channelMigrationTips = i3k_class("wnd_channelMigrationTips", ui.wnd_base)

function wnd_channelMigrationTips:ctor()
	
end

function wnd_channelMigrationTips:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.okBtn:onClick(self, self.onCloseUI)
end

function wnd_channelMigrationTips:refresh(uid)
	local widgets = self._layout.vars
	local item = require("ui/widgets/zhanghaoqianyit")()
	item.vars.desc:setText(i3k_get_string(1656))
	widgets.scroll:addItem(item)
	g_i3k_ui_mgr:AddTask(self, {item}, function(ui)
		local textUI = item.vars.desc
		local size = item.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		item.rootVar:changeSizeInScroll(widgets.scroll, width, height, true)
	end, 1)
	
	widgets.uidText:setText(i3k_get_string(1657, uid))
end

function wnd_create(layout, ...)
	local wnd = wnd_channelMigrationTips.new();
		wnd:create(layout, ...);
	return wnd;
end