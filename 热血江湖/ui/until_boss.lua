-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_until_boss = i3k_class("wnd_until_boss", ui.wnd_base)


function wnd_until_boss:ctor( )

end

function wnd_until_boss:configure( )
	local widgets = self._layout.vars
	widgets.ok:onClick(self,self.onCloseUI)
	local desc = i3k_db_dialogue[440000][1].txt
	widgets.desc:setText(desc)
end

function wnd_create(layout)
	local wnd = wnd_until_boss.new()
	wnd:create(layout)
	return wnd
end


	