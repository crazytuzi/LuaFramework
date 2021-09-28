
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_changeProfessionConfirm = i3k_class("wnd_changeProfessionConfirm",ui.wnd_base)

function wnd_changeProfessionConfirm:ctor()
	self.bwType = 0
	self.classType = 0
end

function wnd_changeProfessionConfirm:configure()
	local widgets = self._layout.vars;
	widgets.cancel_btn:onClick(self, self.onCloseUI)
	widgets.ok_btn:onClick(self, self.Confirm)
	self.input_label = widgets.input_label;
	self.inputHint = widgets.inputHint;
	self.desc = widgets.desc;

	self.desc:setText("");
	widgets.input_label:setPlaceHolder(i3k_get_string(1042, i3k_db_common.changeProfession.confirmTxt));
	widgets.inputHint:setText(i3k_get_string(1043,i3k_db_common.changeProfession.confirmTxt))
end

function wnd_changeProfessionConfirm:refresh(titleName, bwType, classType, isBiography)
	self.desc:setText(titleName)
	self.bwType = bwType
	self.classType = classType
	self.isBiography = isBiography
end

function wnd_changeProfessionConfirm:Confirm(sender)
	local message = self.input_label:getText()
	message = string.gsub(message, " ", "")
	if tostring(message) == i3k_db_common.changeProfession.confirmTxt then
		local gender = g_i3k_game_context:GetRoleGender();

		local fashionId = i3k_db_generals[self.classType].fashion[gender]
		local faceSkin = i3k_db_general_fashion[fashionId].faceSkin[1];
		local hairSkin = i3k_db_general_fashion[fashionId].hairSkin[1];
		if not self.isBiography then
		i3k_sbean.change_role_professionReq(self.classType, g_i3k_game_context:GetTransformLvl(), self.bwType, faceSkin, hairSkin)
		elseif self.isBiography == g_BIOGRAPHY_TRANSFORM_FORWARD then
			i3k_sbean.biography_class_change_profession(self.classType, g_i3k_game_context:GetTransformLvl(), self.bwType, hairSkin, faceSkin)
		elseif self.isBiography == g_BIOGRAPHY_TRANSFORM_REGRET then
			i3k_sbean.biography_class_regret_profession(self.classType, g_i3k_game_context:GetTransformLvl(), self.bwType, hairSkin, faceSkin)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1049, i3k_db_common.changeProfession.confirmTxt))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_changeProfessionConfirm.new()
	wnd:create(layout, ...)
	return wnd;
end

