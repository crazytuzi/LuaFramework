-------------------------------------------------------
-- eUIID_HelpPanel
------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_help_panel = i3k_class("wnd_help_panel", ui.wnd_base)

function wnd_help_panel:ctor()
	
end

function wnd_help_panel:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.desc = self._layout.vars.desc
	self.title = self._layout.vars.title
	self.scroll = self._layout.vars.scroll
	--self.scroll:setBounceEnabled(false)
	self.title:setText("效果说明")
end

function wnd_help_panel:refresh(str)
	local msgText = str or self:getTextStr()
	if msgText then
		self.desc:hide()
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local gzText = require("ui/widgets/bzt1")()
			gzText.vars.text:setText(msgText)
			ui.scroll:addItem(gzText)
			g_i3k_ui_mgr:AddTask(self, {gzText}, function(ui)
				local textUI = gzText.vars.text
				local size = gzText.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				gzText.rootVar:changeSizeInScroll(ui.scroll, width, height, true)
			end, 1)
		end, 1)
	end
end

function wnd_help_panel:getTextStr()
	local str = i3k_get_string(5152).."\n"..i3k_get_string(5153)
	return "没有可显示文本传入"
end

function wnd_create(layout)
	local wnd = wnd_help_panel.new()
	wnd:create(layout)
	return wnd
end
