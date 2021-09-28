-- modify by zhangbing 2018/07/18
-- eUIID_HuoBanCode
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_huobanCode= i3k_class("wnd_huobanCode",ui.wnd_base)

function wnd_huobanCode:ctor()
	self._upperRoleId = 0
end

function wnd_huobanCode:configure()
	local widgets = self._layout.vars
	self.descLabel	= widgets.descLabel 
	self.editBox	= widgets.editBox
	local callback = function ()
		widgets.inputLabel:hide()
	end
	widgets.editBox:addEventListener(callback)
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.sure_btn:onClick(self, self.onSureBtn)
end

function wnd_huobanCode:onSureBtn(sender)
	local cfg = i3k_db_partner_base.cfg
	if not g_i3k_checkIsInDateByStringTime(cfg.openTime, cfg.closeTime) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17380))
	end
	
	local roleLvl = g_i3k_game_context:GetLevel()
	if roleLvl < cfg.openLvl or roleLvl > cfg.maxLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17381))
	end

	if self._upperRoleId > 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17382))
	end

	local str = self.editBox:getText() --获取输入框信息
	i3k_sbean.add_partner_code(str)
end

function wnd_huobanCode:refresh(upperRoleId)
	self._upperRoleId = upperRoleId
	self.descLabel:setText(i3k_get_string(17346))
end

function wnd_create(layout)
	local wnd = wnd_huobanCode.new()
	wnd:create(layout)
	return wnd
end
