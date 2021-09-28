-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_return = i3k_class("wnd_return", ui.wnd_base)

function wnd_return:ctor()
end

function wnd_return:configure()
	self.btnReturn = self._layout.vars.btnReturn;
	self.btnReturn:onClick(self, self.onReturn);
	self.onReturnCB = ui.i3k_ui_callback.new();
end


function wnd_return:onReturn(sender)
	if not g_i3k_ui_mgr:TryCloseUnderUI(eUIID_Return, eUIType_MAIN) then
		g_i3k_logic:OpenBattleUI()
	end
end

function wnd_create(layout)
	local wnd = wnd_return.new()
		wnd:create(layout)
	return wnd
end

