-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_2v2_dan_result = i3k_class("wnd_2v2_dan_result", ui.wnd_base)

function wnd_2v2_dan_result:ctor()
	
end

function wnd_2v2_dan_result:configure()
	
end

function wnd_2v2_dan_result:onShow()
	
end

function wnd_2v2_dan_result:refresh(result)
	if result==0 then
		self._layout.anis.c_sb.play()
	elseif result==1 then
		self._layout.anis.c_sl.play()
	else
		self._layout.anis.c_pj.play()
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_2v2_dan_result.new()
	wnd:create(layout, ...)
	return wnd;
end