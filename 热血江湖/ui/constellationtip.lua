-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_constellationTip = i3k_class("wnd_constellationTip", ui.wnd_base)

function wnd_constellationTip:ctor()
end

function wnd_constellationTip:configure()
	local ok = self._layout.vars.ok
	ok:onClick(self, self.onOK)
	local cancel = self._layout.vars.cancel
	cancel:onClick(self, self.onCancel)
end

function wnd_constellationTip:onShow()
end

function wnd_constellationTip:onHide()
end


function wnd_constellationTip:onOK(sender)
	local callback = self.__callback
	g_i3k_ui_mgr:CloseUI(eUIID_ConstellationTip)
	
	if callback then
		callback(true)
	end
end

function wnd_constellationTip:onCancel(sender)
	local callback = self.__callback
	g_i3k_ui_mgr:CloseUI(eUIID_ConstellationTip)
	
	if callback then
		callback(false)
	end
end

function wnd_constellationTip:refresh(yesName, noName, msgText, callback)
	local yesLabel = self._layout.vars.yes_name
	yesLabel:setText(yesName)
	local noLabel = self._layout.vars.no_name
	noLabel:setText(noName)
	local desc = self._layout.vars.desc
	desc:setText(msgText)
	self.__callback = callback
end

function wnd_create(layout)
	local wnd = wnd_constellationTip.new()
	wnd:create(layout)
	return wnd
end

