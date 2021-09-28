-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chess_task_accept = i3k_class("wnd_chess_task_accept", ui.wnd_base)

function wnd_chess_task_accept:ctor()
	
end

function wnd_chess_task_accept:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_chess_task_accept:refresh()
	self._layout.vars.accept_btn:onClick(self, self.onAcceptBtn)
	self._layout.vars.desc:setText(i3k_get_string(17269))
end

function wnd_chess_task_accept:onAcceptBtn(sender)
	local callback = function (isOk)
		if isOk then
			i3k_sbean.chess_game_receive()
		end
	end
	g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(17270), callback)
end

function wnd_create(layout)
	local wnd = wnd_chess_task_accept.new()
	wnd:create(layout)
	return wnd
end