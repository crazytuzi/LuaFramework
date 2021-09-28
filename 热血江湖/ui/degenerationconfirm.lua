-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_degenerationConfirm = i3k_class("wnd_degenerationConfirm", ui.wnd_base)

function wnd_degenerationConfirm:ctor()
	
end

function wnd_degenerationConfirm:configure()
	local widgets = self._layout.vars;
	widgets.cancel_btn:onClick(self, self.onCloseUI)
	widgets.ok_btn:onClick(self, self.Confirm)
	self.input_label = widgets.input_label;
	self.inputHint = widgets.inputHint;
	self.desc = widgets.desc;
end

function wnd_degenerationConfirm:refresh()
	self.desc:setText(i3k_db_string[4106]);
	self.inputHint:setText(i3k_get_string(4105,i3k_db_common.changeGender.inputNum));
end

function wnd_degenerationConfirm:Confirm(sender)
	local message = self.input_label:getText()
	if tonumber(message) == i3k_db_common.changeGender.inputNum then
		local gender = g_i3k_game_context:GetRoleGender();
		if gender == 1 then
			gender = 0;
		else
			gender = 1;
		end
		local Type = g_i3k_game_context:GetRoleType()
		local id = gender == 0 and Type*2 or Type*2-1
		local faceSkin = i3k_db_general_fashion[id].faceSkin[1];
		local hairSkin = i3k_db_general_fashion[id].hairSkin[1];
		i3k_sbean.chageGender(gender, faceSkin, hairSkin)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4108,i3k_db_common.changeGender.inputNum))
	end
end

function wnd_create(layout)
	local wnd = wnd_degenerationConfirm.new();
		wnd:create(layout);
	return wnd;
end