-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_danceTip = i3k_class("wnd_danceTip", ui.wnd_base)


function wnd_danceTip:ctor()
end

function wnd_danceTip:configure()
	self._layout.vars.closeBtn:onClick(self,self.onCloseUI)
	
end

function wnd_danceTip:refresh(exp)
    self._layout.vars.getExp:setText(exp)
end


function wnd_create(layout)
	local wnd = wnd_danceTip.new()
	wnd:create(layout)
	return wnd;
end
