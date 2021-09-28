-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_help = i3k_class("wnd_help", ui.wnd_base)

function wnd_help:ctor()
	self._string = nil
end

function wnd_help:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.desc = self._layout.vars.desc
	self.scroll = self._layout.vars.scroll
	self.scroll:setBounceEnabled(false)
end

function wnd_help:onShow()
	
end

function wnd_help:onHide()
	
end

function wnd_help:refresh(msgText)
	if msgText then
		self.desc:hide()
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local gzText = {}
			if msgText.isMarriage then
				gzText = require("ui/widgets/bzt2")()
				gzText.vars.text:setText(msgText.name)
				gzText.vars.time:setText(msgText.time)
			else
				gzText = require("ui/widgets/bzt1")()
			gzText.vars.text:setText(msgText)
			end
			ui.scroll:addItem(gzText)
			g_i3k_ui_mgr:AddTask(self, {gzText}, function(ui)
				local textUI = gzText.vars.text
				local textUiTime = {}
				local size = gzText.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				if gzText.vars.time then
					textUiTime = gzText.vars.time
					local timeHeight = textUiTime:getInnerSize().height
					timeHeight = size.height > timeHeight and size.height or timeHeight
					gzText.rootVar:changeSizeInScroll(ui.scroll, width, timeHeight, true)
				end
				height = size.height > height and size.height or height
				gzText.rootVar:changeSizeInScroll(ui.scroll, width, height, true)
			end, 1)
		end, 1)
	end
end

function wnd_create(layout,...)
	local wnd = wnd_help.new()
	wnd:create(layout,...)
	return wnd
end