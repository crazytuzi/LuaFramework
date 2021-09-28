-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamInviteConfirm = i3k_class("wnd_fightTeamInviteConfirm", ui.wnd_base)

function wnd_fightTeamInviteConfirm:ctor()
	self._isShow=false
end

function wnd_fightTeamInviteConfirm:configure()
	local widgets = self._layout.vars
	widgets.markImg:setVisible(false)

	self.ok = widgets.ok	
	self.cancel = widgets.cancel
	self.cancel:onClick(self, self.onCancel)
	self.ok:onClick(self, self.onOK)
	widgets.markBtn:onClick(self, self.onRadioBtn)
end

function wnd_fightTeamInviteConfirm:refresh(yesName, noName, msg, rtext, callback, callbackRadioButton)
	self._layout.vars.inputTxt:setText(i3k_get_string(1256, i3k_db_fightTeam_base.team.confirmText))
	self._layout.vars.yes_name:setText(yesName)
	self._layout.vars.no_name:setText(noName)
	self._layout.vars.desc:setText(msg)
	self._layout.vars.prompt:setText(rtext)
	self.__callback = callback
	self.__callbackRadioButton = callbackRadioButton
end

function wnd_fightTeamInviteConfirm:onRadioBtn(sender)
	self._isShow = not self._isShow
	self._layout.vars.markImg:setVisible(self._isShow)
	local callbackRadioButton = self.callbackRadioButton
	if callbackRadioButton then
		callbackRadioButton(self._isShow, self.ok, self.cancel)
	end
end

function wnd_fightTeamInviteConfirm:onOK(sender)
	if not self._isShow then
		local inputTxt = self._layout.vars.input_label:getText()
		if inputTxt == "" or inputTxt ~= i3k_db_fightTeam_base.team.confirmText then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1256, i3k_db_fightTeam_base.team.confirmText))
		end
	end

	local callback = self.__callback
	if callback then
		callback(true, self._isShow)
	end
end

function wnd_fightTeamInviteConfirm:onCancel(sender)
	local callback = self.__callback
	if callback then
		callback(false, self._isShow)
	end
end

function wnd_create(layout)
	local wnd = wnd_fightTeamInviteConfirm.new()
	wnd:create(layout)
	return wnd
end