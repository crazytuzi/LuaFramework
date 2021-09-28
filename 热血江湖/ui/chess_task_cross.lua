-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chess_task_cross = i3k_class("wnd_chess_task_cross", ui.wnd_base)

function wnd_chess_task_cross:ctor()
	self.time = 0
end

function wnd_chess_task_cross:configure()
	--self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_chess_task_cross:refresh()
	ui_set_hero_model(self._layout.vars.model, 2538)
end

function wnd_chess_task_cross:onUpdate(dTime)
	self.time = self.time + dTime
	if self.time >= 3 then
		i3k_sbean.auto_chess_game_trans()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChessTaskCross, "onCloseUI")
		--self:onCloseUI()
	end
end

function wnd_create(layout)
	local wnd = wnd_chess_task_cross.new()
	wnd:create(layout)
	return wnd
end