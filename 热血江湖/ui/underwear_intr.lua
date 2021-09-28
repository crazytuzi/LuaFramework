-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_underwear_intr = i3k_class("wnd_underwear_intr", ui.wnd_base)
--内甲介绍

function wnd_underwear_intr:ctor()
	
end
function wnd_underwear_intr:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.desTab = {}
	for i = 1, 4 do
		local des = string.format("des%s",i)
		table.insert(self.desTab,widgets[des])
	end
end


function wnd_underwear_intr:refresh()
	for i,v in ipairs(self.desTab) do
		v:setText(i3k_get_string(807+i))
	end
end

function wnd_underwear_intr:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_Introduce)
end

function wnd_create(layout)
	local wnd = wnd_underwear_intr.new();
	wnd:create(layout);
	return wnd;
end


