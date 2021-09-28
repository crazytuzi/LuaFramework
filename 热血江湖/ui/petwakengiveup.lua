-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_petWakenGiveUp = i3k_class("wnd_petWakenGiveUp",ui.wnd_base)

function wnd_petWakenGiveUp:ctor()
end

function wnd_petWakenGiveUp:configure(...)
	local widgets		= self._layout.vars;
	self.input_label 	= widgets.input_label;
	self.inputHint 		= widgets.inputHint;
	self.desc 			= widgets.desc;
	self.ok_btn 		= widgets.ok_btn;
	widgets.cancel_btn:onClick(self, self.onCloseUI)
end

function wnd_petWakenGiveUp:refresh(taskId)
	self:updateData(taskId)
end

function wnd_petWakenGiveUp:updateData(taskId)
	self.desc:setText(i3k_get_string(16839));
	self.ok_btn:onClick(self, self.Confirm, taskId)
end

function wnd_petWakenGiveUp:Confirm(sender, taskId)
	local message = self.input_label:getText()
	local petId = g_i3k_game_context:getPetWakening();
	if petId and  tostring(message) == i3k_db_mercenariea_waken_cfg.authCode then
		i3k_sbean.awakeTaskQuit(petId, taskId)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16864))
	end
end

function wnd_create(layout)
	local wnd = wnd_petWakenGiveUp.new()
	wnd:create(layout)
	return wnd
end
