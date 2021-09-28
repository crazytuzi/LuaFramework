-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_steedPracticeNew = i3k_class("wnd_steedPracticeNew", ui.wnd_base)

function wnd_steedPracticeNew:ctor()

end

function wnd_steedPracticeNew:configure()
	
end

function wnd_steedPracticeNew:refresh()

end


function wnd_create(layout)
	local wnd = wnd_steedPracticeNew.new()
	wnd:create(layout)
	return wnd
end
