-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_update_announcement = i3k_class("wnd_update_announcement", ui.wnd_base)

function wnd_update_announcement:ctor()
	
end

function wnd_update_announcement:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_update_announcement:refresh()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local annText = require("ui/widgets/ggt1")()
		annText.vars.text:setText(i3k_get_announcement_content(g_Game_Update))
		self._layout.vars.scroll:addItem(annText)
		g_i3k_ui_mgr:AddTask(self, {annText}, function(ui)
			local textUI = annText.vars.text
			local size = annText.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			annText.rootVar:changeSizeInScroll(self._layout.vars.scroll, width, height, true)
		end, 1)
	end, 1)
end

function wnd_create(layout)
	local wnd = wnd_update_announcement.new()
	wnd:create(layout)
	return wnd
end