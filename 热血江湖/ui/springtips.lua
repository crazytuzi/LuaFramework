module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_springTips = i3k_class("wnd_springTips", ui.wnd_base)

function wnd_springTips:ctor()
end

function wnd_springTips:configure()

end

function wnd_springTips:refresh(desc,tips,callback)
    local vars = self._layout.vars
    vars.desc:setText(desc)
    vars.desc_1:setText(tips)
    vars.cancel:onClick(self, function  ()
        g_i3k_ui_mgr:CloseUI(eUIID_SpringTips)
        callback(false)
    end)

    vars.ok:onClick(self, function ()
        g_i3k_ui_mgr:CloseUI(eUIID_SpringTips)
        callback(true)
    end)

end

-------------------------------------
function wnd_create(layout)
	local wnd = wnd_springTips.new();
		wnd:create(layout);
	return wnd;
end
