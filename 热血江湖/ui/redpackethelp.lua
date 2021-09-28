
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_redPacketHelp = i3k_class("wnd_redPacketHelp",ui.wnd_base)

function wnd_redPacketHelp:ctor()

end

function wnd_redPacketHelp:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	self.ui = widgets
end

function wnd_redPacketHelp:refresh(text, title)
	self.ui.desc:setText(text)
	if title then
		self.ui.title:setText(title)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_redPacketHelp.new()
	wnd:create(layout, ...)
	return wnd;
end

