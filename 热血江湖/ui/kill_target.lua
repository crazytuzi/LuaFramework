-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
kill_target = i3k_class("kill_target",ui.wnd_base)

local REDWordColor	= "FFFF0000"
local GREENWordColor	= "FF00FF00"

function kill_target:ctor()
	
end

function kill_target:refresh(mapid)
	
	
	
	self._cfg = i3k_db_climbing_tower_fb[mapid]

	if self._cfg.success == 2 then
		--胜利条件为2时
		
		self._layout.vars.taskDesc:setText(i3k_get_string(675))
	elseif self._cfg.success == 3 then
		local activitysuccess3 = i3k_get_string(676,0,self._cfg.successArg)
		self._layout.vars.taskDesc:setText(activitysuccess3)
	end
	
end

function kill_target:configure(...)

	local widget = self._layout.vars
	self._layout.vars.target:show()
	self._layout.vars.taskDesc:show()
	self._layout.vars.target:setText(i3k_get_string(677))
	
end

function kill_target:showInfo(killcount)
	---改变杀怪数量
	if self._cfg.success == 2 then
		self._layout.vars.taskDesc:setText(i3k_get_string(675))
	elseif self._cfg.success == 3 then
		self._layout.anis.c_dakai.play()
		
		self._layout.vars.taskDesc:setText(i3k_get_string(676,killcount,self._cfg.successArg)) 
		if self._cfg.successArg ~= killcount  then
			self._layout.vars.taskDesc:setTextColor(REDWordColor)
		else
			self._layout.vars.taskDesc:setTextColor(GREENWordColor)
		end
	end

	
end


function wnd_create(layout, ...)
	local wnd = kill_target.new()
	wnd:create(layout, ...)
	return wnd
end
