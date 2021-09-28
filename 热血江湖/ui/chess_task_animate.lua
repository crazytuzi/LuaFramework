-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chess_task_animate = i3k_class("wnd_chess_task_animate", ui.wnd_base)

function wnd_chess_task_animate:ctor()
	
end

function wnd_chess_task_animate:configure()
	
end

function wnd_chess_task_animate:refresh()
	
end

function wnd_chess_task_animate:onHide()
	i3k_sbean.chess_game_receive()
end

function wnd_create(layout)
	local wnd = wnd_chess_task_animate.new()
	wnd:create(layout)
	return wnd
end