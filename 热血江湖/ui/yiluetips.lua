-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_yilueTips = i3k_class("wnd_yilueTips", ui.wnd_base)

function wnd_yilueTips:ctor()
	
end

function wnd_yilueTips:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.desc = self._layout.vars.desc
	self.scroll = self._layout.vars.scroll
end

function wnd_yilueTips:refresh()
	self.desc:setText(i3k_get_string(18250))
end

function wnd_yilueTips:getTextStr()

end

function wnd_create(layout)
	local wnd = wnd_yilueTips.new()
	wnd:create(layout)
	return wnd
end