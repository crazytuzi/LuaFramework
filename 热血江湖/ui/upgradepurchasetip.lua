-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_upgradepurchaseTip = i3k_class("wnd_upgradepurchaseTip", ui.wnd_base)

function wnd_upgradepurchaseTip:ctor()
	self._actName = ""
end

function wnd_upgradepurchaseTip:configure()
	self._layout.vars.actBtn:onClick(self, self.gotoAct)
	self.btnImg = self._layout.vars.btnImg
end

function wnd_upgradepurchaseTip:refresh(actName, actIcon)
	self._actName = actName
	self.btnImg:setImage(g_i3k_db.i3k_db_get_icon_path(actIcon))
end

function wnd_upgradepurchaseTip:gotoAct()
	g_i3k_logic:OpenDynamicActivityUI(self._actName)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_upgradepurchaseTip.new()
	wnd:create(layout, ...)
	return wnd;
end