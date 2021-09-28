-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chess_task_diff_animate = i3k_class("wnd_chess_task_diff_animate", ui.wnd_base)

function wnd_chess_task_diff_animate:ctor()
	self.callback = nil
end

function wnd_chess_task_diff_animate:configure()
	
end

function wnd_chess_task_diff_animate:refresh(isSuccess, callback)
	self.callback = callback
	if isSuccess == 0 then
		self._layout.anis.c_sb.play()
	else
		self._layout.anis.c_sl.play()
	end
	g_i3k_coroutine_mgr:StartCoroutine(function ()
		g_i3k_coroutine_mgr.WaitForSeconds(0.6)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChessTaskDiffAnimate, "closeUI")
	end)
end

function wnd_chess_task_diff_animate:closeUI()
	if self.callback then
		self.callback()
	end
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_chess_task_diff_animate.new()
	wnd:create(layout)
	return wnd
end